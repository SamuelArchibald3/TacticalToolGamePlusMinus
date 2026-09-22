/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


--Where a player has been, so the Rewind ability can put them back.
--
--Methods only - the hook that drives them lives in ingame_functions.lua beside
--the other Start_/End_ pairs, the same split metaplayer_invuln and
--metaplayer_limbo use. Keeping the buffer out of a Think body is also what
--makes it testable.
--
--All the numbers come from tool_abil_rewind in table_tool.lua so the shop
--description and the sampler cannot drift apart. Read at call time rather than
--cached in a local, because table_tool.lua loads before this file does.
local function Ref()
	return TOOL_TABLE.tool_abil_rewind
end


--Nothing recorded, and no playback in flight. Called between rounds, and
--lazily the first time a player is sampled.
function TTGPlayer:RewindBufferReset()
	self.RewindBuffer = {}
	self.RewindHead = 0
	self.RewindCount = 0

	self.RewindFrom = nil
	self.RewindTo = nil
	self.RewindWasFrozen = nil
end


--Everything about this player that a rewind puts back.
--
--Velocity is in here because a destination can be in mid-air: somebody three
--seconds into a jump across a gap is over the gap, not on either side of it,
--and putting them there at rest drops them straight down it.
function TTGPlayer:RewindSampleNow()
	return {
		pos = self:GetPos(),
		vel = self:GetVelocity(),
		health = self:Health(),
		ammo = self:RewindAmmoSnapshot(),
		cooldowns = self:RewindCooldownSnapshot(),
		t = CurTime(),
	}
end


--What is loaded, by weapon class. Guns are in here too - rewinding a clip
--undoes the shots the same way rewinding health undoes what they hit.
function TTGPlayer:RewindAmmoSnapshot()
	local out = {}

	for _, wep in pairs( self:GetWeapons() ) do
		out[ wep:GetClass() ] = wep:Clip1()
	end

	return out
end


--What is cooling down, by ability class. Keyed by class rather than by slot
--because abilities can be moved between slots while this is being recorded.
function TTGPlayer:RewindCooldownSnapshot()
	local out = {}

	for _, abil in pairs( self:GetAbilitySlots() ) do
		if IsValid( abil ) then
			out[ abil:GetClass() ] = { on = abil.Cooldown == true, time = abil.Time or 0 }
		end
	end

	return out
end


function TTGPlayer:RewindPush( sample )
	if self.RewindBuffer == nil then self:RewindBufferReset() end

	local size = Ref().buffer_size
	local head = ( self.RewindHead % size ) + 1

	self.RewindBuffer[ head ] = sample
	self.RewindHead = head

	if self.RewindCount < size then
		self.RewindCount = self.RewindCount + 1
	end
end


--The newest sample at or older than `time`, as index + sample. nil when the
--buffer does not reach that far back, which is the whole of the shallow-buffer
--case - see TTG_RewindTargets. Deliberately does NOT fall back to the oldest
--entry it has: a rewind that silently covers 0.4 seconds instead of 3 is worse
--than one that refuses and says so.
function TTGPlayer:RewindSampleAt( time )
	if self.RewindCount == nil or self.RewindCount == 0 then return nil end

	local size = Ref().buffer_size

	for step = 0, self.RewindCount - 1 do
		local index = ( ( self.RewindHead - step - 1 ) % size ) + 1
		local sample = self.RewindBuffer[ index ]

		if sample != nil and sample.t <= time then return index, sample end
	end

	return nil
end


--One step back toward the present. nil at the head, so a walk that starts
--anywhere in the buffer always terminates.
function TTGPlayer:RewindSampleNewer( index )
	if self.RewindBuffer == nil then return nil end
	if index == self.RewindHead then return nil end

	local newer = ( index % Ref().buffer_size ) + 1

	return newer, self.RewindBuffer[ newer ]
end


--Whether the player's standing hull fits here now. The position was legitimate
--when it was recorded, but a barrier may have been built on it or a door may
--have closed since.
--
--Standing hull, never the crouched one: a spot recorded while ducked is 36
--units tall and the player can stand up in it a moment later, which is how you
--wedge somebody in a vent for the rest of the round - there is no fall damage
--and no mid-round respawn to get them out.
--
--Only self is filtered out. Other players staying in the trace is what makes
--two people rewinding into the same spot sort itself out, as long as the
--destinations are resolved one player at a time.
function TTGPlayer:RewindCanFit( pos )
	local mins, maxs = self:GetHull()

	local tr = util.TraceHull( {
		start = pos,
		endpos = pos,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID,
		filter = self,
	} )

	return not ( tr.Hit or tr.StartSolid )
end


--Wall-grab parks the player on MOVETYPE_NONE and only its own DetachJump puts
--MOVETYPE_WALK back. Move them without detaching and they hang motionless in
--open air until they press the key again.
--
--Reaching into the slot by class from outside the ability is how
--ActivateDropSlams already does this - see table_buff.lua.
function TTGPlayer:RewindDetachWallgrab()
	for _, abil in pairs( self:GetAbilitySlots() ) do
		if IsValid( abil ) and abil:GetClass() == "tool_abil_wallgrab" and abil.Step == 2 then
			abil:DetachJump()
			abil.Step = 1
		end
	end
end


--Freeze for the duration, or the player's own movement fights the SetPos every
--tick. Whoever was already frozen - by Buff_Stun, by Barrage - stays frozen at
--the end, so a rewind does not quietly cure a stun.
function TTGPlayer:RewindBeginPlayback( dest_index )
	self.RewindFrom = self.RewindHead
	self.RewindTo = dest_index
	self.RewindWasFrozen = self:IsFlagSet( FL_FROZEN )

	self:Freeze( true )
end


--How many samples this player has to travel. Each one's span differs, which is
--why progress is mapped per player rather than stepped one sample per tick -
--that way everybody lands together.
function TTGPlayer:RewindSpan()
	if self.RewindFrom == nil or self.RewindTo == nil then return 0 end

	return ( self.RewindFrom - self.RewindTo ) % Ref().buffer_size
end


--progress is 0 at the moment of firing and 1 at the end of the playback
--window. Lerping between the two bracketing samples keeps it smooth at any
--framerate, and hides the 0.1s sampling grid.
function TTGPlayer:RewindStepPlayback( progress )
	local span = self:RewindSpan()
	if span == 0 then return end

	local size = Ref().buffer_size
	local travelled = span * math.Clamp( progress, 0, 1 )
	local whole = math.floor( travelled )

	local here = self.RewindBuffer[ ( ( self.RewindFrom - whole - 1 ) % size ) + 1 ]
	if here == nil then return end

	if whole >= span then
		self:SetPos( here.pos )
		return
	end

	local next_back = self.RewindBuffer[ ( ( self.RewindFrom - whole - 2 ) % size ) + 1 ]
	if next_back == nil then
		self:SetPos( here.pos )
		return
	end

	self:SetPos( LerpVector( travelled - whole, here.pos, next_back.pos ) )
end


function TTGPlayer:RewindFinishPlayback()
	local dest = nil
	if self.RewindBuffer != nil and self.RewindTo != nil then
		dest = self.RewindBuffer[ self.RewindTo ]
	end

	--before the SetPos, because DetachJump both restores the movetype and
	--applies a launch velocity of its own, which the velocity set at the bottom
	--of this function then replaces
	self:RewindDetachWallgrab()

	if dest != nil then
		--no Z lift. Quickport adds 32 because it teleports onto a prop's
		--origin; this lands on a position the player already stood in, and
		--which RewindCanFit has re-checked, so lifting it would turn a known
		--good spot into an unknown one - and show as a hop at the end of every
		--rewind.
		self:SetPos( dest.pos )

		--max health is not 100. SetSpawnStuff builds it per player out of
		--TTG_HandicapHealth, so it has to be read now rather than assumed.
		--Clamping the bottom to 1 is what stops a rewind ever killing anybody.
		self:SetHealth( math.Clamp( dest.health, 1, self:GetMaxHealth() ) )

		--ammo and the things it threw go back together, or one of them is a
		--duplicator on its own
		self:RewindUnthrow( dest.t )
		self:RewindRestoreAmmo( dest.ammo )

		self:RewindRestoreCooldowns( dest.cooldowns )
	end

	if self:GetMoveType() == MOVETYPE_LADDER then
		self:SetMoveType( MOVETYPE_WALK )
	end

	--unfrozen before the velocity goes on rather than after, because a frozen
	--player is not going anywhere and the momentum would have to survive the
	--unfreeze to mean anything
	self:RewindAbandonPlayback()

	if dest == nil then return end

	--The velocity they had at that moment. Not the one they have now, and not
	--nothing.
	--
	--Not the one they have now, or somebody rewound out of a dash keeps the
	--dash and is back where they started within a second - the rewind visibly
	--fails to stick.
	--
	--And not nothing, which is what this did at first. A destination is only
	--checked for whether a player fits in it, and mid-air fits: three seconds
	--into a jump across a gap is over the gap rather than on either side of it,
	--and put there at rest they drop straight down it. Handing back the jump
	--means the jump finishes the way it was going to.
	--
	self:RewindSetVelocity( dest.vel )
end


--Put the clips back where they were.
--
--Only for weapons they are still holding. Something bought inside the window
--is not un-bought - the token was spent, and refunding purchases is a much
--larger idea than putting a clip back.
--
--Three numbers per weapon rather than one: the clip itself, the networked copy
--the client reads because Clip1 does not survive the trip, and the tool list
--the hud draws.
function TTGPlayer:RewindRestoreAmmo( recorded )
	if recorded == nil then return end

	local listed = self:GetSwepToolInfo() or {}

	for _, wep in pairs( self:GetWeapons() ) do
		local clip = recorded[ wep:GetClass() ]
		if clip == nil then continue end

		wep:SetClip1( clip )
		wep:SetTTGAmmo( clip )

		for _, tool in pairs( listed ) do
			if tool.name == wep:GetClass() then
				self:SetSwepToolInfo( tool.name, clip, tool.numguns )
			end
		end
	end
end


--Put the cooldowns back where they were.
function TTGPlayer:RewindRestoreCooldowns( recorded )
	if recorded == nil then return end

	for _, abil in pairs( self:GetAbilitySlots() ) do
		if not IsValid( abil ) then continue end

		--Rewind never hands itself back. Three seconds ago it had not been
		--fired, so restoring its own cooldown makes it free - and it would do
		--that for everybody else holding one at the same time, not just for
		--whoever pressed it.
		if abil:GetClass() == "tool_abil_rewind" then continue end

		local was = recorded[ abil:GetClass() ]

		--bought since; there is no earlier state to put it in
		if was == nil then continue end

		abil.Cooldown = was.on
		abil.Time = was.time
		abil:UpdateNetworkedVars( was.on, was.time )

		--base_ttgabil's Think stops rescheduling itself the moment a cooldown
		--reaches zero, so an ability that had finished cooling has no pending
		--think left to count this restored one down with. Without re-arming it
		--the number sits on the hud forever and the ability never comes back.
		if was.on then abil:NextThink( CurTime() + 1 ) end
	end
end


--Un-throw whatever this player threw since then.
--
--Without this, restoring the ammo would be a duplicator: the charge comes back
--while what it deployed is still standing there. Only things thrown count -
--TTG_ThrownAt is set in base_ttgtool's ThrowEnt, which is the one path that
--spends a charge.
--
--It cannot un-explode anything. A bomb thrown and detonated inside the window
--gives its charge back with the damage already dealt, because there is no
--entity left to remove.
function TTGPlayer:RewindUnthrow( since )
	for _, ent in pairs( ents.GetAll() ) do
		if ent.Creator != self then continue end
		if ent.TTG_ThrownAt == nil or ent.TTG_ThrownAt < since then continue end

		ent:Remove()
	end
end


--Set a player's velocity to exactly this, rather than adding to it.
--
--SetVelocity adds where players are concerned, which is why default_melee and
--ent_airblastmachine cancel the current velocity by adding its negation. Same
--idiom, just named, because the interesting part at the call site is which
--velocity is being chosen and not the arithmetic of getting it there.
function TTGPlayer:RewindSetVelocity( vel )
	self:SetVelocity( vel - self:GetVelocity() )
end


--Give up without moving them: they died partway through, or the round ended
--mid-playback. Unfreezing still has to happen or they are stuck there.
function TTGPlayer:RewindAbandonPlayback()
	if self.RewindWasFrozen != true then
		self:Freeze( false )
	end

	self.RewindFrom = nil
	self.RewindTo = nil
	self.RewindWasFrozen = nil
end

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


--How many samples the ring holds: enough to cover the window it serves, plus
--the slack past it.
--
--Worked out rather than written down, so duration is the only number anybody
--has to change. A ring shorter than its own window is not a smaller rewind, it
--is a broken one - nothing in it would ever be old enough to reach for, so
--every rewind would refuse. Leaving those two numbers to be kept in step by
--hand is leaving that trap lying around.
--
--The world's ring in ingame_functions.lua is the same length for the same
--reasons, and asks here rather than working it out again.
function TTG_RewindBufferSize()
	local ref = Ref()

	return math.ceil( ( ref.duration + ref.buffer_slack ) / ref.sample_interval )
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
	self.RewindWasRevived = nil
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
		abilities = self:RewindAbilitySnapshot(),
		buffs = self:BuffSnapshot(),
		t = CurTime(),
	}
end


--What is loaded, by weapon class. Guns are in here too - rewinding a clip
--undoes the shots the same way rewinding health undoes what they hit.
--
--The gun count comes along because somebody who is revived has to be handed
--the weapon back from nothing, and a double gun that returns single is a
--purchase quietly lost.
function TTGPlayer:RewindAmmoSnapshot()
	local out = {}

	for _, wep in pairs( self:GetWeapons() ) do
		out[ wep:GetClass() ] = { clip = wep:Clip1(), guns = wep:GetNumGuns() }
	end

	return out
end


--What abilities are held and what they are doing, by class.
--
--Keyed by class rather than by slot because abilities can be moved between
--slots, but the slot is carried along - a revived player needs their abilities
--rebuilt into the keys they were already using.
function TTGPlayer:RewindAbilitySnapshot()
	local out = {}

	for slot, abil in pairs( self:GetAbilitySlots() ) do
		if IsValid( abil ) then
			out[ abil:GetClass() ] = {
				on = abil.Cooldown == true,
				time = abil.Time or 0,
				slot = slot,
			}
		end
	end

	return out
end


function TTGPlayer:RewindPush( sample )
	if self.RewindBuffer == nil then self:RewindBufferReset() end

	local size = TTG_RewindBufferSize()
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

	local size = TTG_RewindBufferSize()

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

	local newer = ( index % TTG_RewindBufferSize() ) + 1

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

	return ( self.RewindFrom - self.RewindTo ) % TTG_RewindBufferSize()
end


--progress is 0 at the moment of firing and 1 at the end of the playback
--window. Lerping between the two bracketing samples keeps it smooth at any
--framerate, and hides the 0.1s sampling grid.
function TTGPlayer:RewindStepPlayback( progress )
	local span = self:RewindSpan()
	if span == 0 then return end

	local size = TTG_RewindBufferSize()
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

		self:RewindRestoreCooldowns( dest.abilities, self.RewindWasRevived == true )

		--last of the four, and the only one whose effects land a tick later
		--rather than now: gravity, jump, freeze and god mode all come off
		--BuffEffectJunction's edge detection, and speed off SlowJunction
		self:RestoreBuffs( dest.buffs )
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
		local had = recorded[ wep:GetClass() ]
		if had == nil then continue end

		wep:SetClip1( had.clip )
		wep:SetTTGAmmo( had.clip )

		for _, tool in pairs( listed ) do
			if tool.name == wep:GetClass() then
				self:SetSwepToolInfo( tool.name, had.clip, tool.numguns )
			end
		end
	end
end


--Put the cooldowns back where they were.
function TTGPlayer:RewindRestoreCooldowns( recorded, revived )
	if recorded == nil then return end

	for _, abil in pairs( self:GetAbilitySlots() ) do
		if not IsValid( abil ) then continue end

		--Rewind never hands a living player their own cooldown back. Three
		--seconds ago it had not been fired, so restoring it makes it free - and
		--for everybody else holding one at that moment, not only for whoever
		--pressed it.
		--
		--Somebody revived is the exception, and it is not a loophole: whoever
		--fired is alive by definition, so a dead player's recorded cooldown is
		--genuinely theirs. Skipping them would hand back a Rewind they died
		--with half spent.
		if abil:GetClass() == "tool_abil_rewind" and not revived then continue end

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


--Whether this player died recently enough for a rewind to reach them.
--
--No death timestamp is needed for this. Sampling stops the moment
--IsValidGamePlayer goes false, so the newest entry a dead player has is the
--last tick they were alive - if that is inside the window, so was their death.
--
--Somebody who died four seconds ago is not revived: their newest sample is
--already older than the destination, and bringing them back would be reaching
--further into the past for them than for everybody else.
function TTGPlayer:RewindDiedWithin( cutoff )
	if self:Alive() then return false end
	if self:Team() == TEAM_SPEC then return false end
	if self.RewindBuffer == nil or self.RewindCount == 0 then return false end

	local newest = self.RewindBuffer[ self.RewindHead ]

	return newest != nil and newest.t >= cutoff
end


--Put them back on their feet, ready to be rewound like anybody else.
--
--Called at the start of the playback rather than the end, so a revived player
--gets up where they fell and walks their own path back with everyone else
--instead of appearing at the destination.
--
--Note this can only ever run while a teammate is still alive. A team losing
--its last player ends the round through CheckIfTeamsAlive, and a round that
--has ended is not in Combat, which is what the ability checks before firing.
function TTGPlayer:RewindRevive( sample )
	--DeathSpectateTick re-attaches the spectate every tick while this is set,
	--so it has to be cleared before the spawn rather than after, or they are
	--put straight back into it
	self.DeathSpectate = false
	self.CurSpectateTarget = nil
	self.SpectateTargets = nil

	self:StripWeapons()
	self:UnSpectate()
	self:Spawn()

	--model, team colour, speed, jump and a fresh melee. It also sets them to
	--full health at a spawn point, both of which the playback overwrites within
	--the tick.
	SetSpawnStuff( self )

	self.RewindWasRevived = true

	self:RewindReequip( sample )
end


--Hand back what they were carrying when they died.
--
--Buffs are not in here, but only because they are put back at the end of the
--playback along with everybody else's - death cleared them, and by then this
--player is an ordinary living one again.
function TTGPlayer:RewindReequip( sample )
	for class, had in pairs( sample.ammo or {} ) do
		local wep = self:Give( class )
		if not IsValid( wep ) then continue end

		--replayed rather than assumed, so a double gun does not come back
		--single. AddOneGun only touches the weapon's own stats.
		for _ = 2, ( had.guns or 1 ) do
			wep:AddOneGun()
		end

		wep:SetClip1( had.clip )
		wep:SetTTGAmmo( had.clip )
		self:SetSwepToolInfo( class, had.clip, had.guns or 1 )
	end

	local slots = self:GetAbilitySlots()

	for class, had in pairs( sample.abilities or {} ) do
		if IsValid( slots[ had.slot ] ) then continue end

		local abil = ents.Create( class )
		if not IsValid( abil ) then continue end

		--same order fGiveTool builds one in: owner, slot on both sides, then
		--spawn, or the hud has an ability it cannot name
		abil:SetOwner( self )
		slots[ had.slot ] = abil
		abil:SetAbilitySlot( had.slot )
		abil:Spawn()
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
	self.RewindWasRevived = nil
end

ENT.Type 	= "point"
ENT.Base 	= "base_point"

--which ability slot this belongs to, 1 to MAX_ABILITY_SLOTS. Set at purchase,
--and changed if the player moves the ability to another key.
ENT.AbilitySlot = nil


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:SetBaseVars()
	self.Ref = self:GetAbilityRef()
end

function ENT:SetAbilitySlot( slot )
	self.AbilitySlot = slot
end


function ENT:UpdateNetworkedVars(cooldown, time)
	if not IsValid(self.Owner) then return end

	self.Owner:SetAbilityInfo( self.AbilitySlot, self.Ref.name, cooldown, time )
end


--Pushes the cooldown state this ent is already in, without changing it. Used
--when an ability moves slot, so it does not come back off cooldown for free.
function ENT:RefreshNetworkedVars()
	self:UpdateNetworkedVars( self.Cooldown == true, self.Time or 0 )
end


function ENT:Initialize()
	self:SetBaseVars()
	
	self:UpdateNetworkedVars( false, 0 )
	
	--add the ability to the player's serverside table list of his abilities, so the ent can be removed if need be
	//table.insert( self.Owner.Abilities, self )
end


--thinks every second
function ENT:Think()
	if self.Cooldown == true then
		self.Time = self.Time - 1
		
		self:UpdateNetworkedVars( true, self.Time )
	
		if self.Time <= 0 then
			self.Cooldown = false
			self:UpdateNetworkedVars( false, 0 )
			return
		end
		
		self:NextThink( CurTime() + 1 )
		return true
	end
end

--What to put right after a rewind has finished.
--
--Most abilities are only a cooldown, and that is restored from the snapshot
--already, so they have nothing to do here. This is for the ones holding a step
--or a flag of their own, which a rewind can leave pointing at something that
--is no longer there - a quickport still believing its port is out after the
--port has just been taken off the map.
--
--Called once everything else is back: the buffs, the buildings, the clock. An
--override can work out what it should be from those rather than from a
--snapshot of itself, which is both simpler and harder to get wrong.
function ENT:RewindReset()
end


function ENT:CooldownSound()
	umsg.Start("Sound_OnCooldown", self.Owner)
	umsg.End()
end

function ENT:InitiateCooldown()
	self.Cooldown = true
	self.Time = self.Ref.cooldown
	self:UpdateNetworkedVars( true, self.Time )

	self:NextThink( CurTime() + 1)
end


--The hud and the buy menu counter both read a networked copy of the slot, so an
--ability that goes away without the round reset running would keep showing on
--them and the counter would claim a slot that is actually free.
function ENT:OnRemove()
	if not IsValid( self.Owner ) then return end
	if self.AbilitySlot == nil then return end

	local slots = self.Owner:GetAbilitySlots()

	--only clear the slot if it is still ours. A swap may have moved another
	--ability into it, and the round reset may have emptied it already
	if slots[ self.AbilitySlot ] != self then return end

	self.Owner:ClearAbilityInfo( self.AbilitySlot )
	slots[ self.AbilitySlot ] = nil
end

ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


--Eat a corpse: a moment held still over it, then health back and the body
--gone. What counts as a corpse, and where, is TTGPlayer:NearestCorpse.
function ENT:DoAbility()
	if self.Cooldown == true or self.Eating == true then
		self:CooldownSound()
	return
	end

	--Corpses are a Combat thing, and the guard is unconditional like Rewind's
	--rather than the attackers-only one most abilities carry.
	if G_CurrentPhase != "Combat" or not self.Owner:IsValidGamePlayer() then
		self:CooldownSound()
	return
	end

	--Refused rather than started: no cooldown for pressing it with nothing to
	--eat, the same as Rewind with nothing to rewind to.
	local corpse = self.Owner:NearestCorpse( self.Ref.reach )
	if not IsValid( corpse ) then
		self.Owner:ChatPrint( "There is no corpse close enough to eat." )
		self:CooldownSound()
	return
	end

	self:StartEating( corpse )
end


--The cast. Held still for it by Buff_Eating, which also puts it on the hud,
--leaning down over the body with the crunch going.
function ENT:StartEating( corpse )
	local ply = self.Owner

	self.Eating = true

	--which meal the timer below belongs to, so one cancelled by a rewind cannot
	--finish anyway, or finish a later one early
	self.MealToken = ( self.MealToken or 0 ) + 1
	local token = self.MealToken

	ply:AddBuff( "Buff_Eating", self.Ref.cast_time )
	ply:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_GESTURE, ACT_GMOD_GESTURE_ITEM_PLACE )
	ply:EmitSound( self.Ref.sound_eat )

	timer.Simple( self.Ref.cast_time, function()
		--gone with its owner's death: dying takes the abilities with it
		if not IsValid( self ) or self.MealToken != token then return end

		self:FinishEating( corpse )
	end )
end


function ENT:FinishEating( corpse )
	self.Eating = false

	local ply = self.Owner
	if not IsValid( ply ) or not ply:IsValidGamePlayer() then return end

	--somebody else finished it first, or the round cleared it away. Nothing
	--eaten, so nothing charged.
	if not IsValid( corpse ) then
		ply:ChatPrint( "The corpse is gone." )
		return
	end

	ply:TTG_Heal( self.Ref.heal )

	local effect = EffectData()
		effect:SetOrigin( corpse:GetPos() + Vector( 0, 0, 10 ) )
	util.Effect( "BloodImpact", effect )

	--Taking the server's entity takes the body off every screen with it: the
	--ragdoll each client simulates belongs to this.
	corpse:Remove()

	ply:EmitSound( self.Ref.sound_done )

	self:InitiateCooldown()
end


--A meal in progress when a rewind lands is called off: the timer cannot be
--called back, and finishing would heal somebody who has just been put back to
--where they were ten seconds ago. Buff_Eating goes with the rest of the buffs,
--to whatever they had then.
function ENT:RewindReset()
	if self.Eating != true then return end

	self.MealToken = ( self.MealToken or 0 ) + 1
	self.Eating = false
end

ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:DoAbility()
	if self.Cooldown == true then
		self:CooldownSound()
	return 
	end
	if GetTeamRole( self.Owner:Team() ) == "Attacking" then
		if G_CurrentPhase == "GameSetup" then
			return 
		elseif G_CurrentPhase == "DefendersBuy" then
			return 
		elseif G_CurrentPhase == "AttackersBuy" then
			return 
		elseif G_CurrentPhase == "Planning" then
			return 
		elseif G_CurrentPhase == "Setup" then
			return 
		end
	end
	

	local orgin_ents = ents.FindInSphere( self.Owner:GetPos(), self.Ref.radius )
	
	--explodes when any enemy players are within the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() and ent:Team() != self.Owner:Team() then
		
			//ent:BuffForDuration_Ensnare( self.Ref.duration )
			ent:AddBuff( "Buff_Snare", self.Ref.duration )
			
		end
	end
	
	self.Owner:EmitSound( self.Ref.sound_ensnare )

	self:InitiateCooldown()
end
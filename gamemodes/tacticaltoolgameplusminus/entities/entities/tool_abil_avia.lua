ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:DoAbility()
	--Avia is single_use, so this is the press after the one that spent it. The
	--ent is on its way out but is still valid until the end of the tick.
	if self:IsSpent() then
		self:CooldownSound()
	return
	end

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
	
	if self.Owner:HowManyOfThisBuff( "Buff_Avia" ) > 0 then
		self:CooldownSound()
	return 
	end
	
	//ability code
	self.Owner:AddBuff( "Buff_Avia", self.Ref.duration )
	//self.Owner:AddBuff( "Buff_SlowLow", self.Ref.duration )


	--One use and it is gone for the round. Buy it again next round.
	self:MarkSpentIfSingleUse()
end
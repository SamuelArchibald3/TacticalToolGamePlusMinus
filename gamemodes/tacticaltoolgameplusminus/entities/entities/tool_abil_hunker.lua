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
	
	--Toggle. Pressing it used to be a decision you were then stuck with for the
	--full duration, and refusing the second press was the only thing that
	--happened. Now the second press stands you back up.
	--
	--The cooldown still starts on the way in, not on the way out, so ending it
	--early costs you the rest of the time rather than buying a fresh one.
	if self.Owner:HowManyOfThisBuff( "Buff_Hunker" ) > 0 then
		self.Owner:RemoveBuff_ByName( "Buff_Hunker" )
	return
	end

	//ability code
	--The slow lives on Buff_Hunker itself rather than a second buff stacked
	--alongside it, so it shows as one thing on the hud and the figure is tunable
	--in table_buff. The AddBuff( "Buff_SlowLow" ) that used to sit here
	--commented out was the same idea, half done.
	self.Owner:AddBuff( "Buff_Hunker", self.Ref.duration )


	self:InitiateCooldown()
end
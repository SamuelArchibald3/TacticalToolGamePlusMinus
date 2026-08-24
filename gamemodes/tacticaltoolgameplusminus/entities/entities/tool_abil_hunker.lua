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
	
	--A gap between toggles, not a cooldown on the ability.
	--
	--Hunker costs speed the whole time it is on, and that is the price. What it
	--should not allow is flickering in and out fast enough to be hunkered for
	--every incoming shot and mobile in between, so each toggle books the next
	--one a moment later. toggle_cooldown in table_tool.lua is that moment.
	if self.NextToggle != nil and CurTime() < self.NextToggle then
		self:CooldownSound()
	return
	end

	self.NextToggle = CurTime() + ( self.Ref.toggle_cooldown or 1 )

	--Toggle. Pressing it used to be a decision you were then stuck with for the
	--full duration, and refusing the second press was the only thing it did.
	if self.Owner:HowManyOfThisBuff( "Buff_Hunker" ) > 0 then
		self.Owner:RemoveBuff_ByName( "Buff_Hunker" )
	return
	end

	//ability code
	--The slow lives on Buff_Hunker itself rather than a second buff stacked
	--alongside it, so it shows as one thing on the hud and the figure is tunable
	--in table_buff. The AddBuff( "Buff_SlowLow" ) that used to sit here
	--commented out was the same idea, half done.
	--
	--No duration. You stay hunkered until you press it again, which is what a
	--toggle should mean - it used to run out after eight seconds whether or not
	--you were done with it, so the ability ended itself mid-fight and you had to
	--notice. The slow is the price, and you decide how long to pay it.
	--
	--Nothing has to expire it for safety: RemoveAllBuffs clears every slot on
	--death ( server_death.lua ) and between rounds ( ingame_functions.lua ), so
	--this cannot outlive the round that started it.
	--
	--showtime false because there is no time left to show. The hud counter would
	--otherwise sit on 0 for as long as you held it.
	self.Owner:AddBuff( "Buff_Hunker", nil, false )
end
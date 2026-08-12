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


	if self.Owner:HowManyOfThisBuff( "Buff_RateOfFire" ) > 0 then
		self:CooldownSound()
	return 
	end
	
	
	//ability code
	self.Owner:AddBuff( "Buff_RateOfFire", self.Ref.duration )
	
	
	self:InitiateCooldown()
end


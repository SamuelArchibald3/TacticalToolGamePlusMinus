/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")



--[[

--This is exclusively used for attackers during the setup time

--Freezes a player, they can still look around and use sweps but cant move
function TTGPlayer:TTG_Freeze(x)
	if x == true then
		self.HasFreeze = true
	
		self:SetWalkSpeed( 1 )
		self:SetRunSpeed( 1 )
		self:SetJumpPower( 1 )
	else
		self.HasFreeze = false
	
		self:SetWalkSpeed(  self:GetBaseSpeed() )
		self:SetRunSpeed(  self:GetBaseSpeed() )
		self:SetJumpPower( 240 )
	end
	
end

]]--
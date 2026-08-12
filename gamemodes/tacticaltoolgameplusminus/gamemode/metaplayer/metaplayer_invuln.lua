/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")









--Makes a player invulnerable to damage
--probably should make this into a normal buff in the future
function TTGPlayer:TTG_Invuln(x)
	if x == true then
		self.HasInvuln = true
		
		self:GodEnable()
		
		self:SetMaterial("models/props_combine/com_shield001a")
		
		self:SetInvulnInfo(true)

	else
		self.HasInvuln = false
	
		self:GodDisable()
		
		self:SetMaterial(self.TTG_OrigMat)
		
		self:SetInvulnInfo(false)
	end
end

--[[
--Makes a player invulnerable to damage, does not change players material
--this is used by the barrel disguise
--probably should make this into a normal buff in the future
function TTGPlayer:TTG_InvulnSecret(x)
	if x == true then
		self.HasInvuln = true
		
		self:GodEnable()
		
		self:SetInvulnInfo(true)

	else
		self.HasInvuln = false
	
		self:GodDisable()
		
		self:SetInvulnInfo(false)
	end
end
]]--


--for client displaying 'INVULNERABLE' text, sets whether or not it shows
function TTGPlayer:SetInvulnInfo(bool)
	self:SetNetworkedBool("Invuln", bool)
end

--for client displaying 'INVULNERABLE' text, returns true if they are.
function TTGPlayer:GetInvulnInfo()
	return (self:GetNetworkedBool("Invuln", false))
end



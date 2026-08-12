ENT.Type 	= "point"
ENT.Base 	= "base_point"

--the letter slot of the abil, can be "a", "b", or "c"
ENT.LetterSlot = nil


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:SetBaseVars()
	self.Ref = self:GetAbilityRef()
end

--[[
function ENT:SetLetterSlot( x )
	self.LetterSlot = x
end
]]--

function ENT:UpdateNetworkedVars(cooldown, time)
	if not IsValid(self.Owner) then return end

	if self.LetterSlot == "a" then
		self.Owner:SetNetworkedString( "Ability_A_name", self.Ref.name )
		self.Owner:SetNetworkedBool( "Ability_A_cooldown", cooldown )
		self.Owner:SetNetworkedInt( "Ability_A_time", time )
		
	elseif self.LetterSlot == "b" then
		self.Owner:SetNetworkedString( "Ability_B_name", self.Ref.name )
		self.Owner:SetNetworkedBool( "Ability_B_cooldown", cooldown )
		self.Owner:SetNetworkedInt( "Ability_B_time", time )
		
	elseif self.LetterSlot == "c" then
		self.Owner:SetNetworkedString( "Ability_C_name", self.Ref.name )
		self.Owner:SetNetworkedBool( "Ability_C_cooldown", cooldown )
		self.Owner:SetNetworkedInt( "Ability_C_time", time )
		
	end
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

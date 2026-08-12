

/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")






--Put the player in a limbo state, where they cannot move or look around
function TTGPlayer:Limbo(x)

	--------------------------------turn ON limbo------------------
	if x == true then
		
		self:Freeze(true)
		self.InLimbo = true
		self:SetLimboInfo(true)
		
		self:SetMaterial("models/debug/debugwhite")
		
		if (SERVER) then
			--sound
		end
		
		timer.Destroy("LimboTimer_" .. self:UniqueID())
		timer.Create( "LimboTimer_" .. self:UniqueID(), 10, 1, function()
			self:Limbo(false)
		end)
		
		
	------------------------------turn OFF limbo-----------------
	elseif x == false then
		self:Freeze(false)
		self.InLimbo = false
		self:SetLimboInfo(false)
		
		self:SetMaterial(self.TTG_OrigMat)
		
		timer.Destroy("LimboTimer_" .. self:UniqueID())
		
		if (SERVER) then
			--sound
		end
	end
	
end

function TTGPlayer:SetLimboInfo(bool)
	self:SetNetworkedBool("Limbo", bool)
end

function TTGPlayer:GetLimboInfo()
	return (self:GetNetworkedBool("Limbo", false))
end
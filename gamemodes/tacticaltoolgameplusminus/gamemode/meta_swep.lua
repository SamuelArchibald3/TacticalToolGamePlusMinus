/*---------------------------------------------------------
	SWEP Meta Table
---------------------------------------------------------*/
local TTGWeapon = FindMetaTable("Weapon")




--all tool sweps will run this on startup, so i can easily add more stuff to them
function TTGWeapon:SpecialInit()
	--make weapons not cast shadows
	self:DrawShadow( false )
end


function TTGWeapon:SetTTGAmmo(ammo) --this is needed cause Clip1 is fucked up for clients reading it
	self:SetNWInt("TTGAmmo", ammo) 
end

function TTGWeapon:GetTTGAmmo() --this is needed cause Clip1 is fucked up for clients reading it
	val = self:GetNWInt("TTGAmmo", 0) 
	return val
end

function TTGWeapon:SetIfInvis(bool)
	self:SetNWBool("Invis", bool) 
end

function TTGWeapon:GetIfInvis()
	return self:GetNWBool("Invis", false) 
end

function TTGWeapon:SetIfReloading(bool)
	self:SetNWBool("Reloading", bool) 
end

function TTGWeapon:GetIfReloading()
	return self:GetNWBool("Reloading", false) 
end


function TTGWeapon:GetRef()
	return ToolReference(self:GetClass())
end





--Double and Triple gun creation
--set this when buying multiple guns

function TTGWeapon:AddOneGun(  )
	local toolref = self:GetRef()

	//self.ReloadTime = self.ReloadTime + ( toolref.reload_time * .20 )	--make the gun have more reload time
	
	
	if toolref.upgrades_clipsize == true then
		if toolref.clipsize_add_amount == nil then
			--add default amount to the clipsize if theres no override, which is 1/4th of a normal clip
			local addnum = nil
			local clipsize = toolref.clip_size
			if clipsize <= 1 then
				self.Primary.ClipSize = self.Primary.ClipSize + toolref.clip_size
			elseif clipsize > 1 then
				local divnum = toolref.clip_size/4
				addnum = math.floor( divnum + 0.5)
				if addnum < 1 then
					addnum = 1
				end
			end
			self.Primary.ClipSize = self.Primary.ClipSize + addnum
		else
			--add custom amount to the clipsize if the override exists
			self.Primary.ClipSize = self.Primary.ClipSize + toolref.clipsize_add_amount
		end
		
		self:SetClip1( self.Primary.ClipSize )
	end
	
	
	if toolref.upgrades_rateoffire == true then
		self.Primary.Delay = self.Primary.Delay - ( toolref.rate_of_fire * .20 )	--make the gun have have a faster rate of fire
		self.BaseDelay = self.Primary.Delay 
	end
	
	
	self:SetNWInt( "NumGuns", self:GetNumGuns() + 1 ) 
end

function TTGWeapon:GetNumGuns()
	return self:GetNWInt("NumGuns", 1) 
end
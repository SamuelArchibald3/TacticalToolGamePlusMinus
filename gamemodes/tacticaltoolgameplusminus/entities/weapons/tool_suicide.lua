AddCSLuaFile( "tool_suicide.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )


	if (!SERVER) then return end
		self:Charge( )
end



function SWEP:SecondaryAttack()
	return false
end



function SWEP:Charge( )
	self.Owner:EmitSound( self.Ref.sound_charge )
	
	self.Charging = true
	
	timer.Simple( self.Ref.charge_time, function()
		if not IsValid(self) then return end
		
		self:Explode( )
				
	end)
end



function SWEP:Explode( )
	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( self.Owner:GetPos() + Vector(0,0,50) )
		explosion:SetOwner( self.Owner )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.Ref.iradiusoverride )
		explosion:SetKeyValue( "iMagnitude", self.Ref.imagnitude )
		explosion:Fire( "Explode", 0, 0 )

	self.Owner:EmitSound( self.Ref.sound_explode )
	self.Charging = false
	
	//self.Owner:Kill()
end


function SWEP:Holster( wep )
	if self.Charging == true then return false
	else
		return true
	end
end
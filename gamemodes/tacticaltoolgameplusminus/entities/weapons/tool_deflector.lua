AddCSLuaFile( "tool_deflector.lua" )

SWEP.Base = "base_ttgtool"

SWEP.PlayerIsDecoy = false

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowEnt()
end


function SWEP:SecondaryAttack()
	return false
end

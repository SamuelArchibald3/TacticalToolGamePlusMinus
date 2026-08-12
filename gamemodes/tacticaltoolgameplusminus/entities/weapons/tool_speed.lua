AddCSLuaFile( "tool_speed.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowEnt()
end


--The secondary attack uses the capsule on the weapon holder
function SWEP:SecondaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:OwnerGiveBuff()
end

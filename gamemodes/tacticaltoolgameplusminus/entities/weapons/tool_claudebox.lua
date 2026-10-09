AddCSLuaFile( "tool_claudebox.lua" )

SWEP.Base = "base_ttgtool"


--Claude, the item: deployed like the Heal Dispenser. What it does once it is
--built is ent_claudebox's business.
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

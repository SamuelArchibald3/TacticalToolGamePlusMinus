AddCSLuaFile( "tool_claude.lua" )

SWEP.Base = "base_ttgtool"


--Claude, the weapon: thrown like the Crippler. What it does when it lands is
--ent_claude's business.
function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )

	if (!SERVER) then return end
		self.Owner:EmitSound( self.Ref.shoot_sound )
		self:ThrowEnt()
end


function SWEP:SecondaryAttack()
	return false
end

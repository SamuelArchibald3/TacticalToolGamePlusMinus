AddCSLuaFile( "tool_revolver.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	self:RevolverShoot( )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
end



function SWEP:SecondaryAttack()
	return false
end



function SWEP:RevolverShoot( )

	local bullet = {}
		bullet.Num 		= 1
		bullet.Src 		= self.Owner:GetShootPos()	// Source
		bullet.Dir 		= self.Owner:GetAimVector()	// Dir of bullet
		bullet.Spread 	= Vector( self.AimCone, self.AimCone, 0 )		// Aim Cone
		bullet.Tracer	= 1	// Show a tracer on every x bullets 
		bullet.TracerName = "Tracer" // what Tracer Effect should be used
		bullet.Force	= 0	// Amount of force to give to phys objects
		bullet.Damage	= self.BulletDamage
		bullet.AmmoType = "Pistol"
		bullet.Callback = function ( owner, tr, dmginfo )
		end
	
	self.Owner:FireBullets( bullet )
 
	self:ShootEffects()
end
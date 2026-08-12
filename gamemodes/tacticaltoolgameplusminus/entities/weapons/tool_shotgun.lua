AddCSLuaFile( "tool_shotgun.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	self:ShotgunShoot( )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
end



function SWEP:SecondaryAttack()
	return false
end


--knocks back any ents that were hit by any of the bullets of the last shot
function SWEP:PushHitPlys( )

	for _, ent in pairs( self.LastShotHitEnts ) do
		if ent:IsPlayer() then
			if ent:OnGround() then
				ent:Knockback( self.Owner:GetAimVector(), self.Ref.force_player_blast )
			else
				ent:Knockback( self.Owner:GetAimVector(), self.Ref.force_player_blast/6 )
			end
		
		elseif ent:GetPhysicsObject( ):IsValid() then
			ent:Knockback( self.Owner:GetAimVector(),  self.Ref.force_physics_blast )
				
		end
	end
	
	
end


function SWEP:ShotgunShoot( )
	self.LastShotHitEnts = {}
	table.Empty( self.LastShotHitEnts )
	
	local bullet = {}
		bullet.Num 		= self.BulletsPerShot
		bullet.Src 		= self.Owner:GetShootPos()	// Source
		bullet.Dir 		= self.Owner:GetAimVector()	// Dir of bullet
		bullet.Spread 	= Vector( self.AimCone, self.AimCone, 0 )		// Aim Cone
		bullet.Tracer	= 1	// Show a tracer on every x bullets 
		bullet.TracerName = "Tracer" // what Tracer Effect should be used
		bullet.Force	= 0	// Amount of force to give to phys objects
		bullet.Damage	= self.BulletDamage
		bullet.AmmoType = "Pistol"
		bullet.Callback = function ( owner, tr, dmginfo )
			if not table.HasValue( self.LastShotHitEnts, tr.Entity ) then
				table.insert( self.LastShotHitEnts, tr.Entity )
			end
		end
	
	
	self.Owner:FireBullets( bullet )
	self:PushHitPlys()
 
	self:ShootEffects()
end
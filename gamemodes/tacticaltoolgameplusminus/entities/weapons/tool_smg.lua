AddCSLuaFile( "tool_smg.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	self:SMGShoot( )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
end



function SWEP:SecondaryAttack()
	return false
end




function SWEP:SMGShoot( )
	local function CreateBullet()
		local bullet = {}
			bullet.Num 		= 1
			bullet.Src 		= self.Owner:GetShootPos()	// Source
			bullet.Dir 		= self.Owner:GetAimVector()	// Dir of bullet
			bullet.Spread 	= Vector( self.AimCone, self.AimCone, 0 )		// Aim Cone
			bullet.Tracer	= 1	// Show a tracer on every x bullets 
			bullet.TracerName = "Tracer" // what Tracer Effect should be used
			bullet.Force	= .01	// Amount of force to give to phys objects
			bullet.Damage	=  self.BulletDamage
			bullet.AmmoType = "Pistol"
			bullet.Callback = function ( owner, tr, dmginfo )
				if tr.Entity:IsPlayer() then
					if tr.Entity:OnGround() then
						tr.Entity:Knockback( self.Owner:GetAimVector(), self.Ref.force_player_blast )
					else
						tr.Entity:Knockback( self.Owner:GetAimVector(), self.Ref.force_player_blast/4 )
					end
				
				
				elseif tr.Entity:GetPhysicsObject( ):IsValid() then
					tr.Entity:Knockback( self.Owner:GetAimVector(), self.Ref.force_physics_blast )
					
				end
			end
		self.Owner:FireBullets( bullet )
		
		if SERVER then
			self.Owner:EmitSound( self.ShootSound )
		end
	end
	
	
	local numshot = 0
	local function BulletShoot()
		timer.Simple( self.Ref.rate_of_fire_1shot, function()
			CreateBullet()
			self:ShootEffects()
			numshot = numshot + 1
			
			if not (numshot >= self.Ref.bullets_per_shot) then
				BulletShoot()
			end
		end)
	end
	
	BulletShoot()
	
	//for i = 1, self.Ref.bullets_per_shot do
		//print ("shot:", i)
		//self.Owner:FireBullets( bullet )
	//end
	
 
	//self:ShootEffects()
end
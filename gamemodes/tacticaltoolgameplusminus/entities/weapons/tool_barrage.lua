AddCSLuaFile( "tool_barrage.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	self:Shoot( )
	
	if (!SERVER) then return end
		//self.Owner:EmitSound( self.Ref.charge_sound )
end



function SWEP:SecondaryAttack()
	return false
end


function SWEP:ThrowBarrageBomb()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		

		obj.TTG_Team = self.Owner:Team()
		obj.Creator = self.Owner
		obj.CreatorSwep = self
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj.TTG_Angles = (self.Owner:EyeAngles())
	
	//self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim( ACT_VM_THROW );
	timer.Simple( 0.4, function()
		if not IsValid(self) then return end
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	end )
	
	//self.Owner:DoAttackEvent( )
	
	local phys = obj:GetPhysicsObject()
	local norm_aim = self.Owner:GetAimVector()
	//print( norm_aim )
	//print(  Vector(norm_aim[0],norm_aim[1],norm_aim[2]) )
		//phys:ApplyForceCenter(   Vector(norm_aim[0]*math.random(),norm_aim[1]*math.random(),norm_aim[2])  *  (self.ThrowForce)   )
		norm_aim:Rotate( Angle(math.random(-10,10), math.random(-10,10), math.random(-10,10)) )
		phys:ApplyForceCenter( norm_aim*  self.ThrowForce   )
end



function SWEP:Shoot()
	if !SERVER then return end
	
	self.BuffSlot = self.Owner:AddBuff( "Buff_Barrage" )
	//self.Owner:Freeze( true )
	
	
	self.Charging = true
	
	timer.Simple( self.Ref.time_charge, function()
		if not IsValid( self ) then return end
		
		
		self.Owner:EmitSound( self.Ref.shoot_sound )

		

		self.Charging = false
		self.Barraging = true
		
		local function ShootBarrage()
			self.Owner:EmitSound( self.Ref.shoot_sound )
			//print("shooting a bomb")
			self:ThrowBarrageBomb()
			
			timer.Simple( self.Ref.barrage_rate, function()
				if not IsValid( self ) then return end
				if self.Barraging == true then
					ShootBarrage()	
				end			
			end)
		end
		
		ShootBarrage()
		
		
		
		--set this variable dependent on the level of the gun which created this ent
		local time_barrage = self.Ref.time_barrage_level1
		if self:GetNumGuns() == 1 then
			time_barrage = self.Ref.time_barrage_level1
		elseif self:GetNumGuns() == 2 then
			time_barrage = self.Ref.time_barrage_level2
		elseif self:GetNumGuns() == 3 then
			time_barrage = self.Ref.time_barrage_level3
		end
		//print( "this is duration", time_barrage )
		
		
		timer.Simple( time_barrage, function()
			if not IsValid( self ) then return end
			self.Owner:RemoveBuff_BySlot( self.BuffSlot )
			//self.Owner:Freeze( false )
			self.Barraging = false
		end)
	end)
		
		
end

--[[
function SWEP:Think()
	if !SERVER then return end
	
	if self.Barraging == true then
		
		local function ShootOne()
			self.Owner:EmitSound( self.Ref.shoot_sound )
			nextshoot = ( CurTime() + self.Ref.barrage_rate )
		end
		
	end
	
	
	
	
	
	--Base ttg tool stuff
	if not self.Ref.class == "gun" then return end
	
	if self.Reloading then
		if CurTime() >= self.ReloadFinishTime then
			self:SetClip1(self.Primary.ClipSize)
			self.Reloading = false
			self:SendWeaponAnim( ACT_VM_IDLE  )
			

			self.Owner:RemoveBuff_BySlot( self.BuffSlot_Reload )
			
			self.Owner:EmitSound( self.ReloadSound )
		end
	end
	
end


function SWEP:Think()
	if !SERVER then return end
	
	if self.Barraging != true then return end
	

	self.Owner:EmitSound( self.Ref.shoot_sound )

	print("shooting a bomb")
	//self:ThrowEnt()
	
	
	self:NextThink( CurTime() + self.Ref.think_rate )
	return true
end
]]--


function SWEP:Holster( wep )
	if self.Charging == true or self.Barraging == true then
		return false
	end
	
	
	
	if self.Reloading then
		self.Owner:RemoveBuff_BySlot( self.BuffSlot_Reload )
	end
	
	self.Reloading = false
	self:SetNextPrimaryFire(CurTime())
	self:SetNextSecondaryFire(CurTime())
	return true
end

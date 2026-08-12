AddCSLuaFile( "tool_stepbox.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowBox( false )
	
end

function SWEP:SecondaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	if self:Clip1() < 5 then return end
	
	self:TakePrimaryAmmo(5)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowBox( true )
end


function SWEP:ThrowBox( bigbox )
	if (!SERVER) then return end
	
	local thrown_ent = nil
	if bigbox == true then
		thrown_ent = self.Ref.thrown_ent_big
	else
		thrown_ent = self.Ref.thrown_ent
	end
	
	
	local obj = ents.Create( thrown_ent )

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
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end
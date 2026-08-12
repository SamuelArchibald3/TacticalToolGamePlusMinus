AddCSLuaFile( "tool_quickport.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	if self.Owner.HasFreeze == true then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowQuickPort()
	
end

function SWEP:SecondaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	if self.Owner.HasFreeze == true then return end
	
	--teleport to the quickport
	if IsValid( self.CurQuickPort ) then
		if self.CurQuickPort.Built != true then return end
	
		self:TakePrimaryAmmo(1)
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
		local portpos = self.CurQuickPort:GetPos()
			portpos:Add(Vector(0,0,32))
			
		self.Owner:SetPos( portpos )
		
		self.CurQuickPort:EmitSound( self.Ref.sound_teleport )
	end
end

function SWEP:ThrowQuickPort()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		
		--if a jump pad is already out, destroy it and set the new one as curquickport
		if IsValid( self.CurQuickPort ) then
			self.CurQuickPort:Remove()
		end
		self.CurQuickPort = obj
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj.TTG_Team = self.Owner:Team()
		obj.TTG_Angles = (self.Owner:EyeAngles())
		obj.Creator = self.Owner
		obj.CreatorSwep = self
	
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end
AddCSLuaFile( "tool_whistlemissile.lua" )

SWEP.Base = "base_ttgtool"

--table that holds all the active ents this SWEP has created
SWEP.EntTable = {}


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowMissile()
end


function SWEP:SecondaryAttack()
	return false
end


function SWEP:ThrowMissile()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		local eyepos_lower = self.Owner:EyePos() - Vector(0,0,15)
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(eyepos_lower + (self.Owner:GetAimVector()))
		else
			obj:SetPos(eyepos_lower + (self.Owner:GetAimVector() * 32))
		end
		

		obj.TTG_Team = self.Owner:Team()
		obj.Creator = self.Owner
		obj.CreatorSwep = self
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() +Angle(-90,0,0) )
		obj:SetPos(obj:GetPos() + Vector(0,0,15))
		obj:Spawn()
		
		obj.TTG_Angles = (self.Owner:EyeAngles())
	
		for k,ent in pairs( self.EntTable ) do
			constraint.NoCollide( obj, ent, 0, 0 )
		end
	
		--add the object to the ent table, so the swep remembers it
		table.insert( self.EntTable, obj )
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end
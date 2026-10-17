AddCSLuaFile( "tool_airblastmachine.lua" )

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


function SWEP:ThrowEnt()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		

		
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj.Creator = self.Owner
		obj.TTG_Angles = (self.Owner:EyeAngles())
		obj.TTG_Team = self.Owner:Team()

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end


--fire your traps, and nobody else's (SWEP:OwnThrown)
function SWEP:SecondaryAttack()
	for _, ent in ipairs( self:OwnThrown() ) do
		ent:AirblastAbility( true )
	end
end

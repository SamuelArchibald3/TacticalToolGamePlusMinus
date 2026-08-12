AddCSLuaFile( "tool_airblastmachine.lua" )

SWEP.Base = "base_ttgtool"


--table that holds all the active buildables this SWEP has placed
SWEP.EntTable = {}



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
		
		--add the object to the ent table, so the swep remembers it to activate its ability
		table.insert( self.EntTable, obj )
		obj.CreatorTool = self
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end


function SWEP:SecondaryAttack()
	for k, ent in pairs( self.EntTable ) do
		if IsValid(ent) then
			ent:AirblastAbility( true )
		end
	end
end

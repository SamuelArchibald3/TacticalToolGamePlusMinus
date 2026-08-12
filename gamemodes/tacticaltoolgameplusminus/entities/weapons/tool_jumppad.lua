AddCSLuaFile( "tool_jumppad.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowJumppad()
	
end

--[[
function SWEP:SecondaryAttack()
	--destroy the jump pad if it exists
	if IsValid( self.CurJumpPad ) then
		self.CurJumpPad:Remove()
	end
end
]]--

function SWEP:ThrowJumppad()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		
		--[[
		--if a jump pad is already out, destroy it and set the new one as curjumppad
		
		if IsValid( self.CurJumpPad ) then
			self.CurJumpPad:Remove()
		end
		self.CurJumpPad = obj
		]]--
		
		
		obj.TTG_Team = self.Owner:Team()
		obj.Creator = self.Owner
		obj.CreatorSwep = self
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj.TTG_Angles = (self.Owner:EyeAngles())
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end
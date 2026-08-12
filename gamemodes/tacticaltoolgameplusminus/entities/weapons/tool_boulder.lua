AddCSLuaFile( "tool_boulder.lua" )

SWEP.Base = "base_ttgtool"



--table that holds all the active buildables this SWEP has placed
SWEP.EntTable = {}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowBoulder()
	
end


function SWEP:ThrowBoulder()
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
	if CurTime() < self:GetNextSecondaryFire() then return end
	//if ( !self:CanSecondaryAttack() ) then return end

	for k, ent in pairs( self.EntTable ) do
		if IsValid(ent) then
		
		--pull towards player
		--[[
		local owner_vec = self.Owner:GetPos()
		local target_vec = ent:GetPos()
		
		local shoot_ang = ( target_vec - owner_vec):GetNormal()
		local rot = Angle(0, 0, 0)
		shoot_ang:Rotate( rot )
		
		
		ent:Knockback( -shoot_ang, self.Ref.force_phys )
		]]--
		
		
		if ent.CanControl != false then
			--pull towards player's aiming position
			//local tr = self.Owner:GetEyeTrace()
			local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 16384 ,
			filter = {self.Owner, self.EntTable[1], self.EntTable[2], self.EntTable[3]}
			} )
				
			local tr_target = tr.HitPos
			local ent_pos = ent:GetPos()
			
			

			local shoot_ang = ( ent_pos - tr_target ):GetNormal()
			local rot = Angle(0, 0, 0)
			shoot_ang:Rotate( rot )
			
			
		--cant use ENT:KnockBack() here anymore, because this whole control gets disabled specifically by knockbacks happening to the boulder
			//ent:Knockback( -shoot_ang, self.Ref.force_phys )
			local move_ang = -shoot_ang
			
			ent:GetPhysicsObject():SetVelocity( Vector( move_ang.x, move_ang.y, 0 ) * self.Ref.force_phys )
			
			end
		end
		
	end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Ref.rate_of_fire_secondary )
end





function SWEP:Think( )
	
end

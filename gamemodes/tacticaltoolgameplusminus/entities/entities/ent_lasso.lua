AddCSLuaFile("ent_lasso.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	
	self.Model = self.Ref.model
	self.HitSurface = false
end


function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	self:SetSkin( self.Ref.skin )
	
	//self:SetAngles( Angle(90, 0, 0))
	//self:SetAngles( Angle(0, 0, 90))
end



function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	if data.HitNormal[3] < 0 then
		--once its collided with something
		phys:EnableMotion(false)
		self.HitSurface = true
		
		timer.Simple( self.Ref.sit_time, function()
			if not IsValid( self ) then return end
			self:Remove()
		end)
	end
end


//does the affect at the pos position
function ENT:PullBack( ent, enttype )
	if not IsValid( self.Creator ) then return end
	
	
	local owner_vec = self.Creator:GetPos()
	local target_vec = ent:GetPos()
	
	local shoot_ang = ( target_vec - owner_vec):GetNormal()
	local rot = Angle(0, 0, 0)
	shoot_ang:Rotate( rot )
	
	
	self:SetPos( target_vec + Vector(0,0,5) )
	self:SetParent( ent )
	
	if enttype == "phys" then
		ent:Knockback( -shoot_ang, self.Ref.force_physics_blast, 300 )
		
	elseif enttype == "ply" then
		if ent:OnGround() then
			ent:Knockback( -shoot_ang, self.Ref.force_player_blast, 300 )
		else
			ent:Knockback( -shoot_ang, self.Ref.force_player_blast/2, 300 )
			
		end
	end
	
	timer.Simple( self.Ref.sit_time, function()
		if not IsValid( self ) then return end
		self:Remove()
	end)
	//self:Remove()
end


function ENT:Think()
	//if self.HitSurface == false then return end
	if self.PulledBack == true then return end
	
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.radius )
	
	
	--pull back players in the radius
	for k, ent in pairs( orgin_ents ) do
		--cant lasso someone whos been lasso'd within the last 1 second
		if ent:IsValidGamePlayer() and ent != self.Creator and ent:HowManyOfThisBuff( "Buff_Lassod" ) <= 0 then
			ent:AddBuff( "Buff_Lassod", 1 )
			self:PullBack( ent, "ply" )
			self.PulledBack = true
			return
			
		--can lasso props for now
		elseif CheckIfInEntTable( ent ) then
			local entref = EntReference(ent:GetClass())
			
			if entref.affected_by_lasso == true then
				self:PullBack( ent, "phys" )
				self.PulledBack = true
				return
			end
		end
	end
	
	self:NextThink( CurTime() + self.Ref.think_rate )
	return true
end
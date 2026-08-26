AddCSLuaFile("ent_pucknade.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




local angle = Angle( 0, 0, 0 )


//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth( self.Ref.health )
	
	self.Model = self.Ref.model
	self.IMagnitude = self.Ref.imagnitude
	self.IRadiusOverride = self.Ref.iradiusoverride
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	//self:SetGravity( self.Ref.friction )
	//construct.SetPhysProp( self:GetOwner(), self, 2, nil,  { false, "ice" } ) 
	//local phys = self:GetPhysicsObject()
		//self:SetMaterial("ice")
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )
	
	self:SetAngles( Angle(90, 0, 0))
	
	//construct.SetPhysProp( self.Owner, self:GetPhysicsObject(), 1, nil,  { GravityToggle = true, Material = "ice" } ) 
	local phys = self:GetPhysicsObject()
		phys:SetMaterial("ice")
	
	
	self:Fuse()
	
	--this ent comes from a weapon tool so it does not collide with spawn doors
	self:AddSpawnDoorNoCollide()

	//local physobj = self:GetPhysicsObject()
	//self:SetFriction( self.Ref.friction )
end


function ENT:PhysicsCollide(data, phys)
	--once its collided with something
	//self:SetOwner(nil)
	
	//if data.HitEntity:IsPlayer() then
		//if data.HitEntity:Team() != self.TTG_Team then
			//self:StartEffect()
		//end
	//end
	
	
	--this makes it so physics damage wont be taken
	if data.HitEntity:IsPlayer() then
		if data.HitEntity:Team() != self.TTG_Team then
			phys:EnableMotion(false)
		end
	end
end

function ENT:Fuse()
	timer.Simple( self.Ref.fuse, function()
		if not IsValid( self ) then return end
		
		self:StartEffect()
	end)
end


function ENT:KnockBackStuff()
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.force_radius );

	for k, ent in pairs( orgin_ents ) do
	
		--special var to give to stuff i dont want to be knockbackable for some reason
		if ent.CanAirblast != false then
		
			//local self_vec = self:GetPos()
			//local target_vec = ent:GetPos()
			
			local knock_ang = ( ent:GetPos() - self:GetPos() ):GetNormal()
			local rot = Angle(0, 0, 0)
			knock_ang:Rotate( rot )
		
			--blast back a player
			if ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
				


				if ent:OnGround() then
					//ent:SetVelocity( knock_ang * self.Ref.force_player_blast + Vector(0, 0, 400))
					ent:Knockback( knock_ang, self.Ref.force_player_blast, self.Ref.force_player_blast_vert )
			
				else
					//ent:SetVelocity( knock_ang * self.Ref.force_player_blast )
					ent:Knockback( knock_ang, self.Ref.force_player_blast )
				end
				break
				
			--blast back physics ent
			elseif ent:GetPhysicsObject( ):IsValid() and CheckIfInEntTable( ent ) then
				//local phys = ent:GetPhysicsObject()
				//phys:SetVelocity( knock_ang *  self.Ref.force_physics_blast )
				
				ent:Knockback( knock_ang, self.Ref.force_physics_blast )
					
			end
		end
	end
end

//does the affect at the pos position
function ENT:StartEffect(  )
	self.Exploded = true

	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( self:GetPos() )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.IRadiusOverride )
		explosion:SetKeyValue( "iMagnitude", self.IMagnitude )
		explosion:SetKeyValue("spawnflags","64")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamagePlyOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
	self:KnockBackStuff()
		
	self:Remove()
end





function ENT:OnRemove( )
	local swep = self.CreatorTool 
	if IsValid(swep) then
		table.RemoveByValue( swep.EntTable, self )
	end
end


--explosion is no longer triggered by a player being within range
--[[
function ENT:Think()

	local orgin_ents = ents.FindInSphere( self:GetPos() + Vector(0,0,15), self.Ref.radius )
	
	
	--stun players in the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() then
			if ent:Team() != self.TTG_Team then
				self:StartEffect(  )
			end
		end
	end
	
	self:NextThink( CurTime() + self.Ref.think_rate )
	return true
end

]]--
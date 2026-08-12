AddCSLuaFile("ent_buildingbomb.lua")

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
	
	self.Model = self.Ref.model
	self.IMagnitude = self.Ref.imagnitude
	self.IRadiusOverride = self.Ref.iradiusoverride
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )
	
	--this ent comes from a weapon tool so it does not collide with spawn doors
	self:AddSpawnDoorNoCollide()
end


function ENT:PhysicsCollide(data, phys)
	local pos = self:GetPos()
	local hitent = data.HitEntity
	
	--this makes it so physics damage wont be taken
	phys:EnableMotion(false)
	
	self:StartEffect(pos, true)

	
	
	self:SetOwner(nil)
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
			if ent:IsPlayer() and ent != self:GetOwner() then
				
				--player knockback turned off for now
				--[[
				if ent:OnGround() then
					ent:SetVelocity( knock_ang * self.Ref.force_player_blast + Vector(0, 0, 400))
				else
					ent:SetVelocity( knock_ang * self.Ref.force_player_blast )
				end
				]]--
				break
				
			--blast back physics ent
			elseif ent:GetPhysicsObject( ):IsValid() then
			
				//local phys = ent:GetPhysicsObject()
					//phys:SetVelocity( knock_ang *  self.Ref.force_physics_blast )
					//self.Ref.force_physics_blast
				ent:Knockback( knock_ang, self.Ref.force_physics_blast )
				
			end
		end
	end
end

//does the affect at the pos position
function ENT:StartEffect( pos, hitply )

	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( pos )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.IRadiusOverride )
		explosion:SetKeyValue( "iMagnitude", self.IMagnitude )
		explosion:SetKeyValue("spawnflags","64")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamageBuildingOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
	self:KnockBackStuff()
		
	self:Remove()
end


--[[

function ENT.DisablePlyDamage( ent, dmginfo )
	if dmginfo:GetInflictor() == self and ent:IsPlayer() then
		dmginfo:ScaleDamage( 0 )
	end
end
hook.Add("EntityTakeDamage", "DisablePlyDamage", ENT.DisablePlyDamage)

]]--
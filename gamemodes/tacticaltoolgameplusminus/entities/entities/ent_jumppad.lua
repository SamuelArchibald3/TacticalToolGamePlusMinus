AddCSLuaFile("ent_jumppad.lua")

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
	self:SetHealth(self.Ref.health)
	//self:SetMaterial("models/debug/debugwhite")
	
	
	self.Built = false
	self.HitSurface = false
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	if data.HitNormal[3] < 0 and data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" then
		local pos = data.HitPos
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine(pos, wallnormal)
		
		self.HitSurface = true
		
		self.HitPostion = data.HitPos
	end
	
end


function ENT:ObjToMachine( pos, wallnormal )

	self:SetAngles(angle)
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		--change the pos of the model, since its changing into the pad
		local vec = self.HitPostion
		vec:Add(Vector(0,0, 5))
		self:SetPos(vec)

		self:EmitSound(self.Ref.sound_b)
		self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WEAPON )
		
		--angle must be changed because the wheel is on its side
		self:SetAngles( Angle(0, 0, 90))
			
		self.Built = true
	end)
		
end


function ENT:Touch( hitent )
	if self.Built != true then return end
	
	if CheckIfInEntTable( hitent ) and hitent:GetPhysicsObject():IsValid() then
		hitent:GetPhysicsObject():SetVelocity( Vector(0,0,800))
	end
end


function ENT:Think()

	if self.Built != true then return end

	local selfvector = self:GetPos() + Vector(0,0,64)
	local orgin_ents = ents.FindInSphere( selfvector, self.Ref.radius )
	
	
	--send any ents that are within the bounds of the thing, flying into the air
	for k, ent in pairs( orgin_ents ) do
		//print(ent)
		if ent:IsValidGamePlayer() and ent:Team() == self.TTG_Team then
			ent:SetVelocity( Vector(0,0,800))
			
		//elseif CheckIfInEntTable( ent ) and ent:GetPhysicsObject():IsValid() then
			//ent:GetPhysicsObject():SetVelocity( Vector(0,0,800))
			
		end
	end
	
end

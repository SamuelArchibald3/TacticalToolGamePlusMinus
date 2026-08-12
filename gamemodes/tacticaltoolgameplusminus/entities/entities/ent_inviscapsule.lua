AddCSLuaFile("ent_inviscapsule.lua")

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
	
	self.Built = false
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self:SetModel(self.Ref.model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS  )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	phys:Wake()
	if phys:IsValid() then
		phys:SetMass(200)
	end
end


function ENT:PhysicsCollide(data, phys)
	if data.HitNormal[3] < 0 and data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" then
		local pos = data.HitPos
		local world = data.HitEntity
		self:CapsuleToCloud(pos)
	end
	
	//function self:PhysicsCollide() end
end


function ENT:CapsuleToCloud( pos )

	self:SetAngles(angle)
	
	self:SetOwner(nil)
	
	self.Built = true
	self:EmitSound(self.Ref.sound_a)
	self:SetModel(self.Ref.built_model)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
end


function ENT:GiveBuff(ply)
	if (ply:TempInvisBuff())== true then
		self:Remove()
	else
		return
	end
end


function ENT:Think()
	if self.Built != true then return end

	local orgin_ents = ents.FindInSphere( self:GetPos(), 32 )
	
	--send any ents that are within the bounds of the thing, flying into the air
	for k, ent in pairs( orgin_ents ) do
		if ent:IsPlayer() then
			self:GiveBuff(ent)
		end
	end


end



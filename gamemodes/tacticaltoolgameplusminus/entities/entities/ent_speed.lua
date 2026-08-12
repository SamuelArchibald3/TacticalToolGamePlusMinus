AddCSLuaFile("ent_speed.lua")

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
	
	self.Deployed = false
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
	
	self.Deployed = true
	self:EmitSound(self.Ref.sound_a)
	self:SetModel(self.Ref.built_model)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
end


function ENT:GiveBuff(ply)
	if (ply:TempSpeedBuff())== true then
		self:Remove()
	else
		return
	end
end


function ENT:Think()
	if self.Deployed != true then return end

	local selfvector = self:GetPos()
	local mins = Vector(-64, -64, -64)
	local maxs = Vector(64, 64, 64)
	
	mins:Add(selfvector)
	maxs:Add(selfvector)

	--check if any of all of the players in the game are touching this ent
	for k, ply in pairs(player.GetAll()) do
		if (ply:Team() == TEAM_BLUE) or (ply:Team() == TEAM_RED) then
			plyvector = ply:GetPos()
		
			if plyvector:WithinAABox(mins, maxs) then
				self:GiveBuff(ply)
			end
		end
	end


end




--[[

function ENT:GiveBuff(ply)
	if (ply:TempSpeedBuff())== true then
		self:Remove()
	else
		return
	end
end

function ENT:Think()
	if self.Deployed != true then return end
	
	local vec = self:GetPos()
			vec:Add(Vector(0,0,128))

	local tr = util.TraceHull( {
			start = self:GetPos(),
			endpos = vec,
			filter = {self,game:GetWorld( )},
			//mask = ,
			mins = Vector(-64, -64, 0),
			maxs = Vector(64, 64, 128),
			} )
		
		print(tr.Hit)
		print(tr.Entity)

			
	if ( IsValid( tr.Entity )) and tr.Entity:IsPlayer() then
		if (tr.Entity:Team() == TEAM_SPEC) or (tr.Entity:Team() == TEAM_RED_SPEC) or (tr.Entity:Team() == TEAM_BLUE_SPEC) then
		return end
		
		self:GiveBuff(tr.Entity)
	end
			
end

]]--
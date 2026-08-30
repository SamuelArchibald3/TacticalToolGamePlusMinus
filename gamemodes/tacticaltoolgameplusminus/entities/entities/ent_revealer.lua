AddCSLuaFile("ent_revealer.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

--table that holds all the revealed ents its currently revealing
ENT.MarkedTable = {}



//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth(self.Ref.health)
	//self:SetMaterial("models/debug/debugwhite")
	
	
	self.Built = false
	self.HitSurface = false
	self.NextBeep = nil
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
	//self.TTG_Team = TEAM_BLUE
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	if data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" or data.HitEntity:GetClass() == "ent_stepbox_big" then
		local pos = data.HitPos
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:BuildFromCollision( data, pos, wallnormal )
		
		self.HitSurface = true
	end
	
end


function ENT:ObjToMachine( pos, wallnormal )

	local angle = Angle( 0, 0, 0 )
	self:SetAngles(angle)
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		
		self:EmitSound(self.Ref.sound_b)
		self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WEAPON )
		
		self.Built= true
	end)
		
end


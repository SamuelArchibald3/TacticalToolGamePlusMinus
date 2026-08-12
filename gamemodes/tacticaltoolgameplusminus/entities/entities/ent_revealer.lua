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
		self:ObjToMachine(pos, wallnormal)
		
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

--[[
--Create a table of marked ents
function ENT:Think()
	if self.Built != true then return end

	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.radius )
	
	self.ShouldDoBeep = false
	
	function TryToMark( ent )
		if not ent:Get_RevealerMarkerNum() < 0 then
			ent:Add_RevealerMarker()
			table.insert( self.MarkedTable, ent )
		end
	end

	--mark all enemy ents within the radius, except those which are invisible
	for k, ent in pairs( orgin_ents ) do
		if not ent:GetIfInvisible() then
		
			if ent:IsValidGamePlayer() and not table.HasValue( self.MarkedTable, ent ) then
				if ent:Team() != self.TTG_Team then
					//print("adding mark to:", ent)
					ent:Add_RevealerMarker()
					table.insert( self.MarkedTable, ent )
				end
			end
			
		end
	end


	if self.ShouldDoBeep == true then
		if self.NextBeep >= CurTime() or self.NextBeep == nil then
			self:EmitSound( self.Ref.sound_beep )
			self.NextBeep = CurTime() + self.Ref.beep_delay
		end
	end

	
	--if an ent that was once being marked is no longer within the radius, then unmark it and remove it from the table
	for k, ent in pairs( self.MarkedTable ) do
		if not table.HasValue( orgin_ents, ent ) or ent:GetIfInvisible() then
			//print("removing mark from:", ent)
			ent:Remove_RevealerMarker()
			table.RemoveByValue( self.MarkedTable, ent )
		end
	end
end


function ENT:OnRemove( )
	
	--unmark everything it was marking before it died
	for k, ent in pairs( self.MarkedTable ) do
		ent:Remove_RevealerMarker()
		table.RemoveByValue( self.MarkedTable, ent )
	end
	
end
]]--
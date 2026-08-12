AddCSLuaFile("ent_quickport.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT


--[[

--make it so the ent will only render for players of one team
function ENT:SetEntRenderTeam(teamnum)
	self:SetNWInt("TTGTeam", teamnum) 
end

function ENT:GetEntRenderTeam()
	return self:GetNWInt("TTGTeam", 10) 
end




function ENT:Draw()
	--if it hasnt had its render team set, then just render it normally
	if self:GetEntRenderTeam() == 10 then 
		self:DrawModel()
		return
	end
	
	//draw the model if the player's team is the render team, or the player is a spectator
	if LocalPlayer():Team() == self:GetEntRenderTeam() or LocalPlayer():Team() == TEAM_SPEC then
		self:DrawModel()
	else
		return
	end
end

]]--


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
	self.CurTakeDamage = true
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
end


function ENT:KillIfTouchingTriggerHurt()
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.radius_die )
	
	--hurt players and ents in the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:GetClass() == "trigger_hurt" then
			self:Remove()
		end
	end
end



function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	local normalang = data.HitNormal:Angle() 
	if ( data.HitEntity:IsWorld() and data.HitNormal[3] < 0 ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox" and data.HitEntity.Built == true and normalang.y == 0  ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true and data.HitNormal[3] < 0  ) then
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

	--we cant have a teleporter to a trigger hurt, so die automatically if touching a trigger hurt
	self:KillIfTouchingTriggerHurt()


	self:SetAngles(angle)
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		
		--change the pos of the model, since its changing into the pad
		local vec = self.HitPostion
		vec:Add(Vector(0,0,15))
		self:SetPos(vec)

		self:EmitSound(self.Ref.sound_build_finish)
		self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WEAPON )
			
		self.Built = true
		
		
		
		--invis stuff
		self:Invisibility_Start( self.TTG_Team )
		
		
	end)
		
end




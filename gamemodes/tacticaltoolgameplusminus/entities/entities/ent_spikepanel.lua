AddCSLuaFile("ent_spikepanel.lua")

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
	self.ReadyToFinishBuild = false
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
	--disable gravity so it can fly through the air
	//local phys = self:GetPhysicsObject()
		//phys:EnableGravity(false) 
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	if data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" or data.HitEntity:GetClass() == "ent_stepbox_big" then
		self:EmitSound(self.Ref.sound_a)
		
		self:ObjToMachine( data.HitNormal )
		
		self.HitSurface = true
		
		self.HitPostion = data.HitPos

	end
	
end


function ENT:ObjToMachine( wallnormal, hitstepbox )
	self.WallNormal = wallnormal
	self.HitStepBox = hitstepbox

	--set the angle of it to be straight
	self:SetAngles(Angle( 0, 0, 0 ))
	
	self.Entity:EmitSound(self.Ref.sound_b)
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	//self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	
		--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build );
	self.BuildingSound:Play();
	
	
	
	timer.Simple( self.Ref.build_time, function()
		--dont do anything if the thing is gone when the timers up for some reason, add this to all timers
		if not IsValid(self) then return end

		self.ReadyToFinishBuild = true

		
	end)
		
end


function ENT:FinishBuild()
	self.Built = true

	//local vec = self:GetPos()
		//vec:Add(-(self.WallNormal*2))
		//self:SetPos(vec)
	
	local minusang = Angle(90, 0, 0)
	
	local ang = self.WallNormal:Angle( )
		self:SetAngles( ang - minusang )
	
	self:SetPos( self.HitPostion )
	
	self:EmitSound( self.Ref.sound_c) 
	
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	--stop the looping build sound
	self.BuildingSound:Stop()
	

end


function ENT:Touch( ent )
	if not self.Built then return end

	if ent:IsPlayer() and ent:Team() != TEAM_SPEC and ent:Team() != self.TTG_Team then
		ent:Kill()
		self:EmitSound( self.Ref.sound_kill) 
	end
end


function ENT:Think()
	//if self.HitSurface != true then 
		//self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetForward()*6000) // Make the rocket fly forward...
	//end
	
	--when ready to build before building, wait until there are no players in the way to do it
	if self.ReadyToFinishBuild and not self.Built then
		if not self:CheckIfPlayerInWay() then
			self:FinishBuild()
		else
			--make the building looping sound get lower pitched so show that someones in the way
			self.BuildingSound:ChangePitch( 50, .1 )
		end
	end
end
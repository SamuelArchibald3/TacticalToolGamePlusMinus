AddCSLuaFile("ent_stepbox.lua")

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

	if data.HitEntity:IsWorld() then
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine( wallnormal )
		
		self.HitSurface = true
		self.HitPostion = data.HitPos
		
	elseif data.HitEntity:GetClass() == "ent_stepbox_big" then
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine( wallnormal )
		
		self.HitSurface = true
		self.HitPostion = data.HitPos
		
	elseif data.HitEntity:GetClass() == "ent_stepbox" then
		local hitstepbox = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine( wallnormal, hitstepbox )
	
		self.HitSurface = true
		self.HitPostion = data.HitPos
	end
	
	//function self:PhysicsCollide() end
end


function ENT:ObjToMachine( wallnormal, hitstepbox )
	self.WallNormal = wallnormal
	self.HitStepBox = hitstepbox

	--set the angle of the box to be straight
	self:SetAngles(Angle( 0, 0, 0 ))
	
	//self.Entity:EmitSound(self.Ref.sound_b)
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	
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

	--turn this back on once the box is remodelled to have pyramid polygon shaped faces so the textures do not clash on the same plane
	self:SetPos( self.HitPostion )
	
	--change the pos of the model, since its changing
	local vec = self:GetPos()
		vec:Add(-(self.WallNormal*32))
		self:SetPos(vec)
	
	if self.HitStepBox != nil then
		local pos = self.HitStepBox:GetPos()

		local x = self.WallNormal.x
		local y = self.WallNormal.y
		local z = self.WallNormal.z
		
		self.WallNormal.x = math.floor(self.WallNormal.x + 0.5)
		self.WallNormal.y = math.floor(self.WallNormal.y + 0.5)
		self.WallNormal.z = math.floor(self.WallNormal.z + 0.5)
	
		pos:Add(-(self.WallNormal*64))
		self:SetPos( pos )
	end
	
	
	self:EmitSound( self.Ref.sound_c) 
	
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	--stop the looping build sound
	self.BuildingSound:Stop()
	
	
	
	
	local function DestroyAndReturn()
		self:DestroyMachine()
		--return 1 ammo to the swep of the player if someone was in the way of the building
		if IsValid( self.CreatorSwep ) then
			self.CreatorSwep:SetClip1( self.CreatorSwep:Clip1() + 1 )
		end
	end
	
	
			
	--check once if any player is in its space, if so, destroy itself to free the player
	local mins = self:GetPos() + Vector(-30,-30,-30)
	local maxs = self:GetPos() + Vector(30,30,30) 

	local orgin_ents =  ents.FindInBox( mins, maxs )


	for k, ent in pairs( orgin_ents ) do
		--if a players in the way
		if ent:IsValidGamePlayer() then
			DestroyAndReturn()
			
		--if an enemy building is in the way
		elseif CheckIfInEntTable( ent ) and ent.TTG_Team != self.TTG_Team then
			DestroyAndReturn()
			
		end
	end

end



function ENT:Think()
	//if self.HitSurface != true then 
		//self.Entity:GetPhysicsObject():SetVelocity(self.Entity:GetForward()*6000) // Make the rocket fly forward...
	//end
	
	--when ready to build before building, wait until there are no players in the way to do it
	if self.ReadyToFinishBuild and not self.Built then
		//if not self:CheckIfPlayerInWay() then
			self:FinishBuild()
		//else
			--make the building looping sound get lower pitched so show that someones in the way
			//self.BuildingSound:ChangePitch( 50, .1 )
		//end
	end
end
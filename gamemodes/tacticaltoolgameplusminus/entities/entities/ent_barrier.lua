AddCSLuaFile("ent_barrier.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

if !SERVER then return end

------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

--remember to compile barrier model with cstrike studiomdl so the bullets wont collide with it


//ENT.TTG_Angles = Angle( 0, 0, 0 )
local angle = Angle( 0, 0, 0 )


//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth( self.Ref.health_building )
	self.OrigMat = self:GetMaterial( )
	
	self.Built = false
	self.CurTakeDamage = false
	self.HitSurface = false
	self.ReadyToFinishBuild = false
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self.Pos = "up"
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
	self:DrawShadow( false )
	
	
	//self.TTG_Team = TEAM_BLUE
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	local normalang = data.HitNormal:Angle() 
	if ( data.HitEntity:IsWorld() ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox" and data.HitEntity.Built == true  ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true  ) then
		local pos = data.HitPos
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		self.HitPostion = data.HitPos
		self.WallNormal = data.HitNormal
		
		if data.HitNormal[3] < 0 then
			//print("on ground")
			self.OnWall = false
		else
			//print("on wall")
			self.OnWall = true
		end
		
		
		self:ObjToMachine()
		
	end
end


function ENT:ObjToMachine(  )
	self.HitSurface = true
	self.CurTakeDamage = true

	
	if self.OnWall == true then
		local minusang = Angle(90, 0, 0)
		local ang = self.WallNormal:Angle( )
		local new_ang = ( ang - minusang )
		new_ang:RotateAroundAxis( self.WallNormal, 90 ) 
			self:SetAngles( new_ang )
		
			
			//self:SetAngles( ang -  )
	
	else
		--set the angle of the fence to be that of the player when he threw it on the Y axis, TTG_angles is set in SWEP
		self:SetAngles(Angle( 0, self.TTG_Angles.y-90, 0 ))
		
	end	
		
		
	self:SetOwner(nil)
	
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	self.Entity:EmitSound(self.Ref.sound_b)
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build );
	self.BuildingSound:Play();
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		self.ReadyToFinishBuild = true
		
	end)
		
end


function ENT:FinishBuild()
	self.Built = true

	--change the pos of the model, since its changing into the fence
	//local vec = self:GetPos()
		//vec:Add(Vector(0,0,70))
		//self:SetPos(vec)

	self:SetPos( self.HitPostion )
	
	self:EmitSound(self.Ref.sound_c)
	
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	self:NoCollideAllTeamProps( )
	
	--stop the looping build sound
	self.BuildingSound:Stop()
	
	local subtract_hp = self.Ref.health_building - self:Health() 
		self:SetHealth( self.Ref.health - subtract_hp )
	
	--make it so the function in meta_ent.lua will check players that are colliding with it
	//self:SetCustomCollisionCheck( true )
	
	self:StuckPlyTest( )
end


function ENT:Think()

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




function ENT:TogglePos(  )
	if self.Built == false then return end
	if self.Toggling == true then return end
	
	//self:SetSolid( SOLID_BBOX )
	//self:SetTrigger( true )
	
	//if SERVER then
		self:EmitSound(self.Ref.sound_toggle)
		self.Toggling = true
	//end
	
	timer.Simple( self.Ref.toggle_time, function()
		if not IsValid(self) then return end
		if self.Pos == "up" then
			self.Pos = "down"
			
			//self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WEAPON )
			self:SetNotSolid(true)
			self:GetPhysicsObject():EnableCollisions( false )
			self:Invisibility_Start( self.TTG_Team )
			self:SetMaterial( self.Ref.special_mat )
		else
			self.Pos = "up"
			
			//self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
			self:SetNotSolid(false)
			self:GetPhysicsObject():EnableCollisions( true )
			self:Invisibility_End()
			self:SetMaterial( self.OrigMat )
			
			self:StuckPlyTest( )
		end
		
		self:EmitSound(self.Ref.sound_c)
		self.Toggling = false
	end)	
end



--returns true if a player is in the way within the build radius of the tool
function ENT:CheckIfPlayerInWay_Box()
	local orgin_ents = nil
	
	if self.OnWall == true then
		local mins,maxs = self:GetCollisionBounds()
		local bang =  self.WallNormal:Angle()
		mins:Rotate( bang - Angle(0,90,-90) )
		maxs:Rotate( bang - Angle(0,90,-90) )

		orgin_ents = ents.FindInBox( (self:GetPos() + mins), (self:GetPos() + maxs) )
		
		//CreatePosMark( (self:GetPos() + mins) )
		//CreatePosMark( (self:GetPos() + maxs) )	
			
	else
		local mins,maxs = self:GetCollisionBounds()
		mins:Rotate(Angle( 0, self.TTG_Angles.y-90, 0))
		maxs:Rotate(Angle( 0, self.TTG_Angles.y-90, 0))

		orgin_ents = ents.FindInBox( (self:GetPos() + mins), (self:GetPos() + maxs) )
		
		//CreatePosMark( (self:GetPos() + mins) )
		//CreatePosMark( (self:GetPos() + maxs) )
	end
	
	
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() then
			return true
		end
	end
	return false
end




--temporarily disable collision then re enable it and check if a player is still in the way
function ENT:TempDisableCollision( )
	self:SetNotSolid( true )
	self:SetMaterial("models/props_combine/com_shield001a")
	
	timer.Simple( self.Ref.time_disable_collision, function()
		if not IsValid(self) then return end
		self:SetNotSolid( false )
		self:SetMaterial(self.TTG_OrigMat)
		self:StuckPlyTest( )
	end)
end

--makes it so start touch will temporarily check if a player is stuck in it, by seeing if someone starts touch
function ENT:StuckPlyTest( )
	if self:CheckIfPlayerInWay_Box() then
		self:TempDisableCollision( )
	end
end

--[[
function ENT:Touch( ent )
	//print(ent)
	if self.ShouldCheckTouch != true then return end
	
	if ent:IsValidGamePlayer() then
		print("ply is touching")
		self:EmitSound(self.Ref.sound_pass)
		self:TempDisableCollision( )
	end
end
]]--


function ENT:NoCollideAllTeamProps( )
	for k,ent in pairs(ents.GetAll()) do
		if CheckIfInEntTable( ent ) and ent:GetPhysicsObject():IsValid() and ent.TTG_Team == self.TTG_team then
			local ref = ent:GetRef()
			if ref.collides_with_barriers != true then
				constraint.NoCollide( self, ent, 0, 0 )
			end
		end
	end	
end



--remove the machine from the swep's list of active machines
function ENT:OnRemove( )
	local swep = self.CreatorTool 
	if IsValid(swep) then
		table.RemoveByValue( swep.EntTable, self )
	end
	
	--stop the looping build sound if its building
	if self.BuildingSound != nil then
		self.BuildingSound:Stop()
	end
end

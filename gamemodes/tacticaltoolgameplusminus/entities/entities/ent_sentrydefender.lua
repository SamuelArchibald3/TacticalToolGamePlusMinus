AddCSLuaFile("ent_sentrydefender.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




--Has a different modes at any given time

--self.SentryMode = "none"			-has this at setup
--self.SentryMode = "search"		-when its looking for a new target
--self.SentryMode = "chargeup"		-when its spotted a target and is charging up getting ready to shoot
--self.SentryMode = "shoot"			-when its shooting a target

ENT.SentryMode = "search"

ENT.SentryTarget = nil



//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth(self.Ref.health)

	
	self.Built = false
	self.CurTakeDamage = false
	self.HitSurface = false
	self.ReadyToFinishBuild = false
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
	//self.TTG_Team = TEAM_BLUE
	
	
	//if self.TTG_Team == TEAM_BLUE then
		//self:SetColor( Color( 50, 50, 255, 130 ) ) 
	//elseif self.TTG_Team == TEAM_RED then
		//self:SetColor( Color( 255, 50, 50, 130 ) ) 
	//end
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end
	
	local normalang = data.HitNormal:Angle() 
	if ( data.HitEntity:IsWorld() and data.HitNormal[3] < 0 ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox" and data.HitEntity.Built == true and normalang.y == 0  ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true and data.HitNormal[3] < 0  ) then
		
		
		local pos = data.HitPos
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine(pos, wallnormal)
		
		self.HitSurface = true
		
		self.HitPostion = data.HitPos
	end

end




function ENT:ObjToMachine( pos, wallnormal )
	
	self.CurTakeDamage = true

	self:SetAngles(Angle( 0, 0, 0 ))
	
	self:SetOwner(nil)	--makes it so the owners bullets will collide with it, and the owner will as well
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build );
	self.BuildingSound:Play();
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		self.ReadyToFinishBuild = true
		
	end)
		
end







function ENT:FinishBuild()
	self.Built = true

	--change the pos of the model, since its changing into the pad
	local vec = self:GetPos()
		vec:Add(Vector(0,0,35))
		self:SetPos(vec)
	
	self:EmitSound(self.Ref.sound_b)
	
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	self.SentryMode = "search"
	
	--stop the looping build sound
	self.BuildingSound:Stop()
end









------------------------------------------------------------------------------------------------
--Sentry stuff code
------------------------------------------------------------------------------------------------

--makes the visual muzzle flash effect
function ENT:DoShootEffect( forward )
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + Vector(0, 0, 40) )
		effectdata:SetStart( self.SentryTarget:GetPos() + Vector(0, 0, 40) )
		effectdata:SetScale( 8 )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self )
	util.Effect( "HelicopterMegaBomb", effectdata )
end


--shoots at the current target
function ENT:Shoot( )
	if not IsValid( self.SentryTarget ) then return end

	
	local self_vec = self:GetPos() + Vector(0, 0, 40)
	local target_vec = self.SentryTarget:GetPos() + Vector(0, 0, 40)
	
	local shoot_ang = ( target_vec - self_vec):GetNormal()
	local rot = Angle(0, 0, 0)
	shoot_ang:Rotate( rot )
	
	
	local bullet = {}
		bullet.Num 		= 1
		bullet.Src 		= self:GetPos() + Vector(0, 0, 40)	// Source
		bullet.Dir 		= shoot_ang	// Dir of bullet
		bullet.Spread 	= Vector( self.Ref.aim_cone, self.Ref.aim_cone, 0 )		// Aim Cone
		bullet.Tracer	= 1	// Show a tracer on every x bullets 
		bullet.TracerName = "Tracer" // what Tracer Effect should be used
		bullet.Force	= 0	// Amount of force to give to phys objects
		bullet.Damage	= self.Ref.bullet_damage
		bullet.AmmoType = "Pistol"
	
	self:FireBullets( bullet )
	self:EmitSound(self.Ref.sound_d)
	self:DoShootEffect(  )
end



--do a trace on the current target, return true if target still in sight
function ENT:CheckTargetTrace()

	-- Make a trace to check if the sentry can see the target
	local Trace = {}
		Trace.start = self:GetPos() + Vector(0, 0, 40)
		Trace.endpos = self.SentryTarget:GetPos() + Vector(0, 0, 45)
		Trace.filter = self
		Trace.mask = MASK_SOLID - CONTENTS_GRATE
		Trace = util.TraceLine(Trace) 
	
	local hit = false
	if (Trace.Entity) == self.SentryTarget then
		hit = true
	end

	
	return hit
end



function ENT:Think()

	--when ready to build before building, wait until there are no players in the way to do it
	if self.ReadyToFinishBuild and not self.Built then
		if not self:CheckIfPlayerInWay() then
			self:FinishBuild()
		else
			--make the building looping sound get lower pitched so show that someones in the way
			self.BuildingSound:ChangePitch( 50, .1 )
		end
	end
	
	
	if self.Built != true then return end
	
	if self.SentryMode == "search" then
	
		--start shooting any enemy players it can see
		for k,v in pairs(player.GetAll()) do

			if v:Alive() and v:Team() != TEAM_SPEC and v:Team() != self.TTG_Team then
			
				-- Make a trace to see if it can shoot this player
				local Trace = {}
					Trace.start = self:GetPos() + Vector(0, 0, 40)
					Trace.endpos = v:GetPos() + Vector(0, 0, 45)
					Trace.filter = self
					Trace.mask = MASK_SOLID - CONTENTS_GRATE
					Trace = util.TraceLine(Trace) 
				
				local hit = false
				
				--if it hit the player then check if they are too far
				if (Trace.Entity) == v then
					local ply_dist = v:GetPos():Distance(self:GetPos())
					if ply_dist > self.Ref.radius then
						hit = false
					else
						hit = true
					end
				end

				
				if hit then
					--play beep sound to signify it sees an enemy
					self:EmitSound(self.Ref.sound_c)
					
					self.SentryMode = "chargeup"
					self.SentryTarget = v
					self.TimeToShoot = CurTime() + self.Ref.charge_time
					break
				end
			end
		end
		
		
	elseif self.SentryMode == "chargeup" then
	
		--if the sentry can no longer see the target, then switch back to search mode begin looking for a new target
		if not self:CheckTargetTrace() then
			self.SentryMode = "search"
			self.SentryTarget = nil
			
		--if the chargeup time has eclapsed, then start shooting the target on the next think
		elseif CurTime() >= self.TimeToShoot then
			self.SentryMode = "shoot"
			
		end
		
		
		
		
	elseif self.SentryMode == "shoot" then
	
		--shoot at the current target
		self:Shoot()
		
		--if the sentry can no longer see the target, then switch back to search mode begin looking for a new target
		if not self:CheckTargetTrace() then
			self.SentryMode = "search"
			self.SentryTarget = nil
		end
		
		--if the player is out of the range then lose its target
		if  self.SentryTarget != nil then
			local ply_dist = self.SentryTarget:GetPos():Distance(self:GetPos())
			if ply_dist > self.Ref.radius then
				self.SentryMode = "search"
				self.SentryTarget = nil
			end
		end
	
	
	end
	
	
	
	self:NextThink( CurTime() + .1 )
	return true
end

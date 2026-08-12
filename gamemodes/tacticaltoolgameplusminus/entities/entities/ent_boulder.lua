AddCSLuaFile("ent_boulder.lua")

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
end


function ENT:PhysicsCollide(data, phys)
	--this runs if the boulder is not yet built
	if not self.Built then
		if self.HitSurface == true then return end

		if data.HitNormal[3] < 0 and data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" then
			local pos = data.HitPos
			local world = data.HitEntity
			self:EmitSound(self.Ref.sound_hit)
			
			local wallnormal = data.HitNormal
			self:ObjToMachine(pos, wallnormal)
			
			self.HitSurface = true
			
			self.HitPostion = data.HitPos
		end
		
		
		
	--this runs if the boulder is active and applies damage to players it touches
	elseif self.Built then
		if data.HitEntity:IsValidGamePlayer() and data.HitEntity:Team() != self.TTG_Team then
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( self.Ref.damage )
				dmginfo:SetInflictor( self )
				if IsValid( self.Creator ) then
					dmginfo:SetAttacker( self.Creator )
				end
			data.HitEntity:TakeDamageInfo( dmginfo )
			
			self:EmitSound( self.Ref.sound_kill) 
		end
	
	
	end

end




function ENT:ObjToMachine( pos, wallnormal )
	self:SetAngles(Angle( 0, 0, 0 ))
	
	self:SetOwner(nil)	--makes it so the owners bullets will collide with it, and the owner will as well
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build );
	self.BuildingSound:Play();
	
	self.CurTakeDamage = true
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		self.ReadyToFinishBuild = true
		
	end)
		
end


--[[
function ENT:Touch( ent )
	if not self.Built then return end

	if ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
		local dmginfo = DamageInfo()
			dmginfo:SetDamage( self.Ref.damage )
			dmginfo:SetInflictor( self )
			dmginfo:SetAttacker( self.Creator )
		ent:TakeDamageInfo( dmginfo )
		
		self:EmitSound( self.Ref.sound_kill) 
	end
end
]]--

function ENT:FinishBuild()
	self.Built = true

	--change the pos of the model, since its changing into the pad
	local vec = self.HitPostion
		vec:Add(Vector(0,0,80))
		self:SetPos(vec)
	
	self:EmitSound(self.Ref.sound_builddone)
	
	self:ChangePhysicsModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	self.CurTakeDamage = false
	
	//self:SetSkin( 3 )
	
	--stop the looping build sound
	self.BuildingSound:Stop()
end



function ENT:BreakControl()
	self.CanControl = false
	
	timer.Simple( self.Ref.time_break_control, function()
		if not IsValid(self) then return end
		
		self.CanControl = true
	end)
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
	
	
	
	self:NextThink( CurTime() + .1 )
	return true
end

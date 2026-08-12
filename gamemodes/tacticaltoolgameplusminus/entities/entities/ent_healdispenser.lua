AddCSLuaFile("ent_healdispenser.lua")

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
	self.CurTakeDamage = false
	self.HitSurface = false
	self.ReadyToFinishBuild = false
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
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
	end
	
end


function ENT:ObjToMachine( pos, wallnormal )
	self.CurTakeDamage = true
	
	self:SetAngles(angle)
	
	self:SetOwner(nil)	--makes it so the owners bullets will collide with it, and the owner will as well
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build )
	self.BuildingSound:Play()
	
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		self.ReadyToFinishBuild = true
		
	end)
		
end






function ENT:FinishBuild()
	self.Built = true

	--change the pos of the model, since its changing into the pad
	local vec = self:GetPos()
		vec:Add(Vector(0,0,-5))
		self:SetPos(vec)
	
	self:EmitSound(self.Ref.sound_b)
	
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	--stop the looping build sound
	self.BuildingSound:Stop()
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

	local selfvector = self:GetPos()
	local orgin_ents = ents.FindInSphere( selfvector, self.Ref.radius )
	
	
	--heal ents in the radius
	for k, ent in pairs( orgin_ents ) do
		//if ent:IsValidGamePlayer() or CheckIfInEntTable( ent ) then
		if ent:IsValidGamePlayer() then
			if ent:IsPlayer() and ent:Team() == self.TTG_Team then
				local health = ent:Health()
				
				if health <= 100 then
					if (health + self.Ref.heal_amount) > 100 then
						ent:SetHealth( 100 )
					else
						ent:SetHealth( health + self.Ref.heal_amount )
					end
				end
			elseif not ent:IsPlayer() then
				--add code to heal buildings
			end
		end
	end
	
	self:NextThink( CurTime() + self.Ref.heal_rate )
	return true
end

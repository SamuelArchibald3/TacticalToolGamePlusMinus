AddCSLuaFile("ent_airblastmachine.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end

------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




//ENT.TTG_Angles = Angle( 0, 0, 0 )


//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth(self.Ref.health)
	
	
	self.Built = false
	self.HitSurface = false
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
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true and data.HitNormal[3] < 0 ) then
	
		local pos = data.HitPos
		local world = data.HitEntity
		self:ObjToMachine(pos)
		
		self.HitSurface = true
		self.WallNormal = data.HitNormal
		self.HitPostion = data.HitPos
	end
	
end


function ENT:ObjToMachine( pos )
	--set the angle of the fence to be that of the player when he threw it on the Y axis, TTG_angles is set in SWEP
	//self:SetAngles(Angle( 0, self.TTG_Angles.y, 0 ))
	
	self:SetAngles(Angle( 0, 0, 0 ))
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	
	self.Entity:EmitSound(self.Ref.sound_a)
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	
	
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		--change the pos of the model
		local vec = self.HitPostion
			//vec:Add(-(self.WallNormal*28))
			self:SetPos(vec)
		
		
		self:EmitSound(self.Ref.sound_b)
		//self.TTG_Team = TEAM_BLUE
		self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WEAPON )
		
		self.Built = true
	end)	
end


function ENT:Think()
	if !SERVER then return end
	
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.radius_activation )
	
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
			//print(ent)
			if self.OnCooldown != true then
				self:AirblastAbility(  )
			end
		elseif CheckIfInEntTable( ent ) and ent != self and ent.TTG_Team != self.TTG_Team then
			if self.OnCooldown != true then
				self:AirblastAbility(  )
			end
		end
	end
	
	self:NextThink( CurTime() + self.Ref.think_rate )
	return true
end


function ENT:AirblastAbility( blastallies )
	if self.Built != true then return end
	if self.OnCooldown == true then return end
	
	self:EmitSound(self.Ref.sound_c)

	
	local function BlastEnt( ent )
		if ent:IsPlayer() then
		
			--if the player doesnt have hunker on, then snare them
			if ent:HowManyOfThisBuff( "Buff_Hunker" ) < 1 then
				ent:AddBuff( "Buff_Snare", self.Ref.snare_duration, false )
				ent:SetVelocity( -ent:GetVelocity() * 1 )
			end
			
			timer.Simple( .1, function()
				if not IsValid(self) then return end
				local newang = Angle(0,self.TTG_Angles.y,0)
				local finalang = newang:Forward()
				
				ent:Knockback( finalang, 1000, 300 )
			end)

		elseif ent:GetPhysicsObject( ):IsValid() and not ent:IsPlayer() then
			local newang = Angle(0,self.TTG_Angles.y,0)
			local finalang = newang:Forward()
			
			ent:Knockback( finalang, self.Ref.force_physics_blast, 300 )
		end
	end
	
	
	
	
	
	//local orgin_ents = ents.FindInSphere( self:GetPos() + ( self.TTG_Angles:Forward( ) * (self.Ref.radius_effect - 30) ), self.Ref.radius_effect )
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.radius_effect )
	
	for k, ent in pairs( orgin_ents ) do
	
		if ent:IsValidGamePlayer() then
		
			if blastallies == true then 
				BlastEnt( ent )
			elseif  blastallies != true then 
				if ent:Team() != self.TTG_Team then
					BlastEnt( ent )
				end
			end
			
		elseif ent:GetPhysicsObject( ):IsValid() and not ent:IsPlayer() then
			BlastEnt( ent )
		end
	end
	
	self.OnCooldown = true
	
	timer.Simple( self.Ref.cooldown, function()
		if not IsValid(self) then return end
		self.OnCooldown = false
	end)
end


--remove the machine from the swep's list of active machines
function ENT:OnRemove( )
	local swep = self.CreatorTool 
	if swep:IsValid() then
		table.RemoveByValue( swep.EntTable, self )
	end
end


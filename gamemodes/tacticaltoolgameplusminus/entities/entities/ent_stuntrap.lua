AddCSLuaFile("ent_stuntrap.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT




if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth(self.Ref.health)
	
	self.Built = false
	self.CurTakeDamage = false
	self.HitSurface = false
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
	
	//self.TTG_Team = TEAM_BLUE
end



function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end
	
	if data.HitNormal[3] < 0 and data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" then
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

	self:SetAngles(Angle( 0, 0, 0 ))
	
	self:SetOwner(nil)
	
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build );
	self.BuildingSound:Play();
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
	
		
		self:EmitSound(self.Ref.sound_b)
		self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WORLD )
		self:SetNotSolid(true)
		
		
		--invis stuff
		//self:SetEntRenderTeam( self.TTG_Team )
		//self:SetRenderMode( RENDERMODE_TRANSALPHA )

		//if self.TTG_Team == TEAM_BLUE then
		//	self:SetColor( Color( 50, 50, 255, 70 ) ) 
		//elseif self.TTG_Team == TEAM_RED then
		//	self:SetColor( Color( 255, 50, 50, 70 ) ) 
		//end
		
		self:Invisibility_Start( self.TTG_Team )
		
		
		
		self.Built = true
		self.CurTakeDamage = false	--stops taking damage once built
		
		--stop the looping build sound
		self.BuildingSound:Stop()
	end)
		
end

--makes it so the model is briefly visible to everyone, then it disappears, this runs when it stuns someone so they know what happened
function ENT:RevealThenRemove()
	self:SetEntVisibleForAll()

	timer.Simple( self.Ref.reveal_time, function()
		if not IsValid(self) then return end
		self:Remove()
	end)
end



function ENT:Think()
	if self.Built != true then return end
	if self.StopThink == true then return end
	
	local orgin_ents = ents.FindInSphere( self:GetPos() + Vector(0,0,40), self.Ref.radius )
	
	
	--stun players in the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
		
			--stun the one player and remove self
			self:EmitSound(self.Ref.sound_c)
			//ent:BuffForDuration_Stun( self.Ref.stun_duration )
			ent:AddBuff( "Buff_Stun", self.Ref.stun_duration )
			
			self.StopThink = true
			self:RevealThenRemove()
		end
	end
	
	self:NextThink( CurTime() + self.Ref.think_rate )
	return true
end

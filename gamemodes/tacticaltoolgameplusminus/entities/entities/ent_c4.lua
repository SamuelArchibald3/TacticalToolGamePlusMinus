AddCSLuaFile("ent_c4.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




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
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )
end



function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	local normalang = data.HitNormal:Angle() 
	if ( data.HitEntity:IsWorld() and data.HitNormal[3] < 0 ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox" and data.HitEntity.Built == true and normalang.y == 0  ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true and data.HitNormal[3] < 0  ) then
	
		local pos = data.HitPos
		local world = data.HitEntity
		self:ObjToMachine()
		
		self.HitSurface = true
		self.WallNormal = data.HitNormal
		self.HitPostion = data.HitPos
	end
	
end


function ENT:ObjToMachine(  )
	--set the angle of the fence to be that of the player when he threw it on the Y axis, TTG_angles is set in SWEP
	//self:SetAngles(Angle( 0, self.TTG_Angles.y, 0 ))
	
	self:SetAngles(Angle( 0, 0, 0 ))
	
	self:SetOwner(nil)
	
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)
	
	
	self.Entity:EmitSound(self.Ref.sound_hit)
	
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
	--change the pos of the model
	local vec = self.HitPostion
		vec:Add( Vector(0,0,25) )
		self:SetPos(vec)
		
	
	self:EmitSound(self.Ref.sound_built)
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	self.Built = true
	self:Fuse()
	
	--stop the looping build sound
	self.BuildingSound:Stop()
end



function ENT:Fuse()
	self.FuseOn = true
	self.CurBeepRate = self.Ref.beep_rate


	timer.Simple( self.Ref.fuse, function()
		if not IsValid( self ) then return end
		
		self:Explode()
	end)
end


function ENT:DoEffect(  )
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + Vector(0, 0, 40) )
		effectdata:SetStart( self:GetPos() + Vector(0, 0, 80) )
		effectdata:SetScale( 15 )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self )
	util.Effect( "HelicopterMegaBomb", effectdata )
end



//does the affect
function ENT:Explode(  )
	self.Exploded = true

	
	local function HurtEnt( ent )
		local dmginfo = DamageInfo()
			dmginfo:SetDamage( self.Ref.damage )
			dmginfo:SetInflictor( self )
			dmginfo:SetAttacker( self.Creator )

		ent:TakeDamageInfo( dmginfo )
		
		self:DoEffect(  )
	end
	
	
	
	local orgin_ents = ents.FindInSphere( self:GetPos() + Vector(0,0,15), self.Ref.radius )
	
	--hurt players and ents in the radius
	for k, ent in pairs( orgin_ents ) do
		if CheckIfInEntTable( ent ) and ent.TTG_Team != self.TTG_Team then
			//damage building
			HurtEnt( ent )
		elseif ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
			//damage enemy player
			if self.Ref.damages_players == true then
				HurtEnt( ent )
			end
		end
	end
	
	self:EmitSound( self.Ref.sound_explode )
	
	--resets the vars, even though we dont really need to cause its being removed but who cares
	self.FuseOn = false
	self.CurBeepRate = self.Ref.beep_rate
	
	--knock back props
	self:KnockBackStuff()
	
	self:Remove()
end



function ENT:Think()
	if self.Built != true then
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

	
	
	if self.FuseOn == true then
		self:EmitSound( self.Ref.sound_beep )
		
		self:NextThink( CurTime() + self.CurBeepRate )
		self.CurBeepRate = self.CurBeepRate - self.Ref.beep_rate_amp
		
		return true
	end
end





function ENT:KnockBackStuff()
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.force_radius );

	for k, ent in pairs( orgin_ents ) do
	
		--special var to give to stuff i dont want to be knockbackable for some reason
		if ent.CanAirblast != false then

			local knock_ang = ( ent:GetPos() - self:GetPos() ):GetNormal()
			local rot = Angle(0, 0, 0)
			knock_ang:Rotate( rot )
		
			--blast back props
			if ent:GetPhysicsObject( ):IsValid() and not ent:IsPlayer() then
				ent:Knockback( knock_ang, self.Ref.force_physics_blast )
			end
		end
	end
end

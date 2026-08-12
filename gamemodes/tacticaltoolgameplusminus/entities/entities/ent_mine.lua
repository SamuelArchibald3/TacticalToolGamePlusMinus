AddCSLuaFile("ent_mine.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
--that render group makes it able to go invisible



if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth(self.Ref.health)
	
	self.Built = false
	self.CurTakeDamage = true
	self.HitSurface = false
end

function ENT:Initialize()

	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )

end



function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end
	
	if data.HitNormal[3] < 0 and data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "ent_stepbox" then
		local pos = data.HitPos
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_hit)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine(pos, wallnormal)
		
		self.HitSurface = true
		self.WallNormal = data.HitNormal
		self.HitPostion = data.HitPos
		
	end
end


function ENT:ObjToMachine( pos, wallnormal )

	self.CurTakeDamage = true

	self:SetAngles(Angle( 0, 0, 0 ))
	
	self:SetOwner(nil)
	
	//self.TTG_Team = TEAM_BLUE
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build );
	self.BuildingSound:Play();
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
	
		--change the pos of the model
		local vec = self.HitPostion
			vec:Add(-(self.WallNormal*28))
			self:SetPos(vec)
		
		self:EmitSound(self.Ref.sound_builddone)
		self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_WORLD )
		self:SetNotSolid(true)
		
		self:Invisibility_Start( self.TTG_Team )
		
		
		self.Built = true
		self.CurTakeDamage = false	--stops taking damage once built
		
		--stop the looping build sound
		self.BuildingSound:Stop()
	end)
		
end


function ENT:Trigger()
	if self.Built != true then return end
	self:SetEntVisibleForAll()
	self:EmitSound( self.Ref.sound_beep )
	
	timer.Simple( self.Ref.fuse, function()
		if not IsValid(self) then return end
		self:Explode()
	end)
end

function ENT:Explode()
	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( self:GetPos() )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.Ref.iradiusoverride )
		explosion:SetKeyValue( "iMagnitude", self.Ref.imagnitude )
		explosion:SetKeyValue("spawnflags","64")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamagePlyOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
	self:Remove()
end

--remove the machine from the swep's list of active machines
function ENT:OnRemove( )
	local swep = self.CreatorTool 
	if swep:IsValid() then
		table.RemoveByValue( swep.EntTable, self )
	end
	
	--stop the looping build sound if its building
	if self.BuildingSound != nil then
		self.BuildingSound:Stop()
	end
end
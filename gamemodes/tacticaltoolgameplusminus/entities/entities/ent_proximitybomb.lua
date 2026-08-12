AddCSLuaFile("ent_proximitybomb.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




local angle = Angle( 0, 0, 0 )


//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	
	self.Model = self.Ref.model
	self.IMagnitude = self.Ref.imagnitude
	self.IRadiusOverride = self.Ref.iradiusoverride
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()
	
	//it doesnt really build, just needs this to take damage
	//self.Built = true
	
	self:SetOwner(nil)
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
	self.OrigMat = self:GetMaterial( )
	
	//self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetMaterial( self.Ref.special_mat )
	
	
	//if self.TTG_Team == TEAM_BLUE then
		//self:SetColor( Color( 50, 50, 255, 130 ) ) 
	//else
		//self:SetColor( Color( 255, 50, 50, 130 ) ) 
	//end
	
	self.CanKnockback = false
	self.CanExplode = false
	
	
	timer.Simple( self.Ref.delay, function()
		--dont do anything if the thing is gone when the timers up for some reason, add this to all timers
		if not IsValid(self) then return end
		
		//if self.TTG_Team == TEAM_BLUE then
			//self:SetColor( Color( 50, 50, 255, 255 ) ) 
		//else
			//self:SetColor( Color( 255, 50, 50, 255 ) ) 
		//end
		
		self:SetMaterial( self.OrigMat )
		self.CanKnockback = true
		self.CanExplode = true
	end)
end


function ENT:PhysicsCollide(data, phys)
	
end


function ENT:Think()
	if self.CanExplode != true then return end

	local selfvector = self:GetPos()
	local orgin_ents = ents.FindInSphere( selfvector, self.Ref.radius )
	
	--explodes when any enemy players are within the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
			self:StartEffect()
		end
	end
	
end


--[[
function ENT:Touch( hitEnt )
	if hitEnt:IsPlayer() then
		//if hitEnt:Team() != self.TTG_Team then
			self:StartEffect(self:GetPos())
		//end
	end
end
]]--

//does the affect at the pos position
function ENT:StartEffect(  )
	self.AlreadyExploded = true

	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( self:GetPos() )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.IRadiusOverride )
		explosion:SetKeyValue( "iMagnitude", self.IMagnitude )
		explosion:SetKeyValue("spawnflags","64")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamagePlyOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
		
	self:Remove()
end

function ENT:OnRemove( )
	if self.AlreadyExploded == true then return end
	if self.ExplodeOnRemove == false then return end
	
	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( self:GetPos() )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.IRadiusOverride )
		explosion:SetKeyValue( "iMagnitude", self.IMagnitude )
		explosion:SetKeyValue("spawnflags","64")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamagePlyOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
end
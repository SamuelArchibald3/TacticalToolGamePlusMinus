AddCSLuaFile("ent_bomb_barrage.lua")

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
	
	self.Model = self.Ref.model
	self.IMagnitude = self.Ref.imagnitude
	self.IRadiusOverride = self.Ref.iradiusoverride
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )
	
	--this ent comes from a weapon tool so it does not collide with spawn doors
	self:AddSpawnDoorNoCollide()
end


function ENT:PhysicsCollide(data, phys)
	local pos = self:GetPos()
	local hitent = data.HitEntity
	
	--this makes it so physics damage wont be taken
	phys:EnableMotion(false)
	
	self:StartEffect( )

	
	
	self:SetOwner(nil)
end





function ENT:StartEffect(  )
	self.Exploded = true

	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( self:GetPos() )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.Ref.iradiusoverride )
		explosion:SetKeyValue( "iMagnitude", self.Ref.imagnitude )
		explosion:SetKeyValue("spawnflags","80")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamagePlyOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
		
	self:Remove()
end

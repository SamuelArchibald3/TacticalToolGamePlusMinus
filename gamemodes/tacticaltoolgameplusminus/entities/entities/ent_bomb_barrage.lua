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
	--Once, whatever happens. Same defect the building bomb had: PhysicsCollide
	--calls this and then self:Remove(), but Remove waits for the end of the
	--tick and EnableMotion( false ) inside a physics callback is not guaranteed
	--to stop it there and then, so two contacts put two explosions on one spot.
	--Clipping a player on the way in was the usual way to get it.
	--
	--Measured at two explosions from two collisions before this, one after -
	--explode_once.lua counts them.
	if self.Exploded == true then return end
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

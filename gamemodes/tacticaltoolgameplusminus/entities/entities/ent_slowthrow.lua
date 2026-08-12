AddCSLuaFile("ent_slowthrow.lua")

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
	
	--this makes it so things wont by pushed by it
	phys:EnableMotion(false)
	
	self:Explode( )

	
	
	self:SetOwner(nil)
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

	
	--set this variable dependent on the level of the gun which created this ent
	local duration = nil
	if self.CreatorSwep:GetNumGuns() == 1 then
		duration = self.Ref.duration_level1
	elseif self.CreatorSwep:GetNumGuns() == 2 then
		duration = self.Ref.duration_level2
	elseif self.CreatorSwep:GetNumGuns() == 3 then
		duration = self.Ref.duration_level3
	else
		duration = self.Ref.duration_level1
	end
	//print( "this is duration", duration )
	
	local function SlowEnt( ent )
		ent:AddBuff( "Buff_Cripple", duration )
	end
	
	
	
	local orgin_ents = ents.FindInSphere( self:GetPos() + Vector(0,0,15), self.Ref.radius )
	
	--hurt players and ents in the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() and ent:Team() != self.TTG_Team then
			//damage player
			SlowEnt( ent )
		end
	end
	
	self:DoEffect(  )
	self:EmitSound( self.Ref.sound_explode )
	
	self:Remove()
end



AddCSLuaFile("ent_missile.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------



//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	
	//self.Model = self.Ref.model
	self.FlyingVector = self:GetVelocity( )
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )
	
	self:AddSpawnDoorNoCollide()
	
	//local phys = self:GetPhysicsObject()
		//phys:EnableGravity(false) 
end


function ENT:PhysicsCollide(data, phys)
	local pos = self:GetPos()
	local hitent = data.HitEntity
	
	phys:EnableMotion(false)
	
	//if hitent:IsWorld() != true then
		self:DamageEnt( hitent )
	//end
		
	self:SetOwner(nil)
end




//does the affect at the pos position
function ENT:DamageEnt( hitent )
	local function HitWorld()
		self:EmitSound( self.Ref.sound_hitworld )
		
		local phys = self:GetPhysicsObject()
			phys:EnableMotion(false)
		self:SetNotSolid(true)
		
		timer.Simple( self.Ref.time_stick, function()
			self:Remove()
		end)
	end
	
	
	if hitent:IsWorld() then
		HitWorld()

	elseif hitent:IsValidGamePlayer() or CheckIfInEntTable( hitent ) then 
		if hitent:GetClass() == "ent_missile" and hitent.TTG_Team == self.TTG_Team and hitent.Creator == self.Creator then return end
		
		if hitent:IsPlayer() then
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( self.Ref.damage_player )
				dmginfo:SetInflictor( self )
				dmginfo:SetAttacker( self.Creator )

			hitent:TakeDamageInfo( dmginfo )
		else
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( self.Ref.damage_ent )
				dmginfo:SetInflictor( self )
				dmginfo:SetAttacker( self.Creator )

			hitent:TakeDamageInfo( dmginfo )
		end
			
		
		self:EmitSound( self.Ref.sound_hitent )
		self:Remove()
	else
		HitWorld()
	end
end

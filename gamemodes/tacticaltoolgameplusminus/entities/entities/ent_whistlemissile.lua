AddCSLuaFile("ent_whistlemissile.lua")

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
	
	--this ent comes from a weapon tool so it does not collide with spawn doors
	self:AddSpawnDoorNoCollide()
	
	local phys = self:GetPhysicsObject()
		phys:EnableGravity(false) 
	
	self.StartingPos = self:GetPos()
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
			if not IsValid(self) then return end
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

			if self.StartingPos:Distance( self:GetPos() ) > self.Ref.distance_damage_player then
				hitent:TakeDamageInfo( dmginfo )
			end
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


--remove the machine from the swep's list of active machines
function ENT:OnRemove( )
	local swep = self.CreatorSwep
	if swep:IsValid() then
		table.RemoveByValue( swep.EntTable, self )
	end
end
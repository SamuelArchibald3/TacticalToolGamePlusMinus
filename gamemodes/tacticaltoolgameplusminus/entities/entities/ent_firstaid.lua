AddCSLuaFile("ent_firstaid.lua")

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
	
	self.HitSurface = false
	self.CurCanHealCreator = false
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()
	
	self:SetOwner(nil)
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
	
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	self.CurCanHealCreator = true
	
	self.HitSurface = true
end


function ENT:Think()

	local selfvector = self:GetPos()
	local orgin_ents = ents.FindInSphere( selfvector, self.Ref.radius )
	
	--heal any ents in the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() then
			if ent == self.Creator then
				if self.CurCanHealCreator then
					if ent:Health() < 100 then
						self:Heal( ent )
						break
					end
				end
			else
				if ent:Health() < 100 then
					self:Heal( ent )
					break
				end
			end
				
			
		end
	end
	
end



--heal a player
function ENT:Heal( ply )
	local newhealth = ply:Health() + self.Ref.heal_amount
		
	if newhealth <= 100 then
		ply:SetHealth( newhealth )
	else
		ply:SetHealth( 100 )
	end
	
	ply:EmitSound( self.Ref.sound_heal )
	self:Remove()
end




//function ENT:Touch( hitEnt )
	//if hitEnt:IsPlayer() and ent:Team() != TEAM_SPEC then
		//self:Heal( hitEnt )
	//end
//end




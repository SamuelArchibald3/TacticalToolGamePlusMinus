AddCSLuaFile("ent_claude.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


--Claude, thrown: where it lands it looks at who is in reach and does whatever
--helps its thrower's side more. Enemies at least as many as the hurt allies
--there, and it hits the enemies; more hurt allies than enemies, and it heals
--the allies instead; nobody, and it does nothing. Then it tells the thrower
--what it chose.


function ENT:SetBaseVars()
	self.Ref = self:GetRef()
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )

	--this ent comes from a weapon tool so it does not collide with spawn doors
	self:AddSpawnDoorNoCollide()
end


--Out of the physics callback before anything happens: hurting a player can
--kill them, and a body made inside a physics callback is a crash. See BUG-9.
function ENT:PhysicsCollide( data, phys )
	if self.Landed then return end
	self.Landed = true

	phys:EnableMotion( false )
	self:SetOwner( nil )

	timer.Simple( 0, function()
		if IsValid( self ) then self:Decide() end
	end )
end


--Who is in reach: (allies who are hurt, enemies), players in play only.
function ENT:WhoIsHere()
	local hurt, foes = {}, {}

	for _, ent in ipairs( ents.FindInSphere( self:GetPos() + Vector( 0, 0, 15 ), self.Ref.radius ) ) do
		if ent:IsPlayer() and ent:IsValidGamePlayer() then
			if ent:Team() == self.TTG_Team then
				if ent:Health() < ent:GetMaxHealth() then table.insert( hurt, ent ) end
			else
				table.insert( foes, ent )
			end
		end
	end

	return hurt, foes
end


function ENT:Decide()
	local hurt, foes = self:WhoIsHere()
	local ref = self.Ref
	local said

	if #foes > 0 and #foes >= #hurt then
		for _, ply in ipairs( foes ) do
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( ref.damage )
				dmginfo:SetAttacker( IsValid( self.Creator ) and self.Creator or self )
				dmginfo:SetInflictor( self )
				dmginfo:SetDamageType( DMG_GENERIC )
			ply:TakeDamageInfo( dmginfo )
		end

		self.Choice = "hit"
		said = #foes == 1 and "That one looked hostile, so I dealt with it."
			or "Those looked hostile, so I dealt with them."

		local effect = EffectData()
			effect:SetOrigin( self:GetPos() )
		util.Effect( "Explosion", effect, true, true )
		self:EmitSound( ref.sound_hit )

	elseif #hurt > 0 then
		for _, ply in ipairs( hurt ) do
			ply:TTG_Heal( ref.heal )
		end

		self.Choice = "heal"
		said = "Your side needed it more, so I healed them instead."

		local effect = EffectData()
			effect:SetOrigin( self:GetPos() )
		util.Effect( "cball_explode", effect, true, true )
		self:EmitSound( ref.sound_heal )

	else
		self.Choice = "nothing"
		said = "Nobody there to help. I'll sit this one out."
		self:EmitSound( ref.sound_nothing )
	end

	if IsValid( self.Creator ) then
		self.Creator:ChatPrint( "Claude: " .. said )
	end

	self:Remove()
end

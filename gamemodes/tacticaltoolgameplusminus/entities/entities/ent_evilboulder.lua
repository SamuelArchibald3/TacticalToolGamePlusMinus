AddCSLuaFile("ent_evilboulder.lua")

ENT.Type 			= "anim"
ENT.Base 			= "ent_boulder"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

DEFINE_BASECLASS( "ent_boulder" )


--The Evil Boulder: a Boulder in every way but one. Built, it hurts every player
--it touches - its thrower's team and its thrower as well as the enemy.
--
--Who the damage comes from matters. GM:PlayerShouldTakeDamage refuses any
--damage whose attacker is a player on the victim's own team, so the thrower
--is the attacker only against the enemy, where the kill is theirs to have;
--against anybody on the thrower's side, the boulder itself is.


--Its own colour rather than its team's: it is on nobody's side, and somebody
--about to walk into one has to be able to tell.
function ENT:InitializeColor()
	self.BaseColor = self.Ref.color

	local alpha = 255
	if self.AlphaAmount != nil then
		alpha = self.AlphaAmount
	end

	--darker as it is damaged, as every building is
	local colordeci = self:Health() / self:FullHealthNow()
	self:SetColor( Color( self.BaseColor.r * colordeci, self.BaseColor.g * colordeci, self.BaseColor.b * colordeci, alpha ) )
end


function ENT:PhysicsCollide( data, phys )
	--landing and building is the Boulder's own business
	if not self.Built then
		return BaseClass.PhysicsCollide( self, data, phys )
	end

	local ply = data.HitEntity
	if not ply:IsValidGamePlayer() then return end

	local dmginfo = DamageInfo()
		dmginfo:SetDamage( self.Ref.damage )
		dmginfo:SetInflictor( self )
		if ply:Team() != self.TTG_Team and IsValid( self.Creator ) then
			dmginfo:SetAttacker( self.Creator )
		else
			dmginfo:SetAttacker( self )
		end
	ply:TakeDamageInfo( dmginfo )

	self:EmitSound( self.Ref.sound_kill )
end

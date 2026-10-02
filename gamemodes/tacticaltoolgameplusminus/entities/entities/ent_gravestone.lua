ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName	= "Gravestone"
ENT.Spawnable	= false


--Where somebody died, for Cannibalism to eat from - see gravestones.lua. Small,
--floating and slowly turning, so it reads as a marker rather than a prop, and
--nothing collides with it or shoots it.

function ENT:Initialize()
	self:SetModel( "models/props_c17/gravestone001a.mdl" )
	self:SetModelScale( 0.35 )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:DrawShadow( false )
end


if CLIENT then
	function ENT:Draw()
		--offset by its index so a row of them does not bob in step
		local t = CurTime() + self:EntIndex()

		self:SetRenderOrigin( self:GetPos() + Vector( 0, 0, math.sin( t * 2 ) * 3 ) )
		self:SetRenderAngles( self:GetAngles() + Angle( 0, ( t * 45 ) % 360, 0 ) )
		self:DrawModel()

		self:SetRenderOrigin()
		self:SetRenderAngles()
	end
end

ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName	= "Gravestone"
ENT.Spawnable	= false


--Where somebody died, for Cannibalism to eat from - see gravestones.lua. Small,
--floating and slowly turning, so it reads as a marker rather than a prop, and
--nothing collides with it or shoots it.

local MODEL = "models/props_c17/gravestone001a.mdl"
local SCALE = 0.45

function ENT:Initialize()
	self:SetModel( MODEL )
	self:SetModelScale( SCALE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:DrawShadow( false )
end


if CLIENT then

	--A photo on both faces of the stone, as a cameo, when this machine has one:
	--materials/tacticaltoolgame_mats/gravestone_portrait. It is a local file -
	--never committed, since it is a real person's picture and the repos are on
	--GitHub - which the server sends to whoever joins (gravestones.lua). Without
	--it the stones are plain. Looked up once, the first time a stone is drawn.
	local portrait = nil

	local function Portrait()
		if portrait == nil then
			local mat = Material( "tacticaltoolgame_mats/gravestone_portrait" )
			portrait = ( not mat:IsError() ) and mat or false
		end

		return portrait or nil
	end


	--Where the photo goes, in the model's own units before scaling. The slab is
	--thin along its forward axis (8 deep, 33 wide, 90 tall, centred on its
	--origin), so its faces point forward and back; the photo sits in the upper
	--half of each, 4:5 like the picture.
	local FACE = 4
	local PHOTO_UP = 14
	local PHOTO_W, PHOTO_H = 21, 26.25

	--world units to one 2D unit while drawing it
	local PX = 0.05


	local function DrawPortrait( pos, ang, scale, mat )
		local w, h = PHOTO_W * scale / PX, PHOTO_H * scale / PX

		--the front face, then the back: the same again turned round
		for _, turn in ipairs( { 0, 180 } ) do
			local face = Angle( ang.p, ang.y + turn, ang.r )
			local at = pos + face:Forward() * ( FACE * scale + 0.1 ) + face:Up() * ( PHOTO_UP * scale )

			--a 2D plane facing out of that face, x to the viewer's right and y
			--down, so the picture is upright and the right way round
			face:RotateAroundAxis( face:Up(), 90 )
			face:RotateAroundAxis( face:Forward(), 90 )

			cam.Start3D2D( at, face, PX )
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( mat )
				surface.DrawTexturedRect( -w / 2, -h / 2, w, h )
			cam.End3D2D()
		end
	end


	function ENT:Draw()
		--offset by its index so a row of them does not bob in step
		local t = CurTime() + self:EntIndex()

		local pos = self:GetPos() + Vector( 0, 0, math.sin( t * 2 ) * 3 )
		local ang = self:GetAngles() + Angle( 0, ( t * 45 ) % 360, 0 )

		self:SetRenderOrigin( pos )
		self:SetRenderAngles( ang )
		self:DrawModel()
		self:SetRenderOrigin()
		self:SetRenderAngles()

		local mat = Portrait()
		if mat then DrawPortrait( pos, ang, self:GetModelScale(), mat ) end
	end
end

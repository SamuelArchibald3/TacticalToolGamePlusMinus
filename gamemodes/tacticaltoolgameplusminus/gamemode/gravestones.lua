/*---------------------------------------------------------
	Gravestones
---------------------------------------------------------*/

--A marker where somebody died, for Cannibalism to eat from.
--
--The body is the engine's death ragdoll, which each client simulates for
--itself: the server never knows where it ends up, and it can lie in different
--places on different screens. So what gets eaten is not the body but this - a
--small floating gravestone the server puts where the player last stood on the
--ground. Standing at the stone is standing at the meal, for everybody.
--
--Where they last stood, not where they died: somebody knocked off a ledge or
--blasted into the air dies over nothing, or at the bottom of a kill plane, and
--a stone floating there could never be reached. The rewind recording knows the
--last spot each player had their feet down, which is why it now runs every
--Combat whether anybody bought a Rewind or not - see Start_RewindSampler.
--
--The stone goes when its player spawns again (a new round, a revive by
--Rewind), when they leave, and when it is eaten, which takes the body too.
--
--This is the default of the two corpse styles - ttg_var_corpses,
--CORPSE_STYLE. The other, "body", has the server make the body itself so it
--lies in the same place for everybody (corpses.lua).

if not SERVER then return end

local TTGPlayer = FindMetaTable( "Player" )

--How high the stone's middle floats over the spot. The model is centred on its
--origin and stands 90 tall, 40 or so at ent_gravestone's scale, so this keeps
--its base clear of the ground.
local FLOAT = 30


--The photo on the stones, sent to everybody who joins - when this server has
--it. It is a local file and never committed: a real person's picture, and the
--repos are on GitHub. See ent_gravestone.
local PORTRAIT = "materials/tacticaltoolgame_mats/gravestone_portrait.vmt"

if file.Exists( PORTRAIT, "GAME" ) then
	resource.AddFile( PORTRAIT )
end


--Where this player's gravestone goes: where they are if they died on their
--feet, otherwise the last place the recording has them on the ground - and
--where they are anyway if it has none, at the start of a round or just after a
--rewind landed and the recording started over.
function TTGPlayer:GravestoneSpot()
	if self:IsOnGround() then return self:GetPos() end

	return self:LastGroundedPos() or self:GetPos()
end


function TTGPlayer:PlaceGravestone()
	self:RemoveGravestone()

	local ground = self:GravestoneSpot()

	local stone = ents.Create( "ent_gravestone" )
	if not IsValid( stone ) then return end

	stone:SetPos( ground + Vector( 0, 0, FLOAT ) )
	stone:SetAngles( Angle( 0, self:EyeAngles().y, 0 ) )
	stone:Spawn()

	stone.TTG_GraveOf = self
	stone.TTG_Ground = ground
	self.TTG_Gravestone = stone

	return stone
end


function TTGPlayer:RemoveGravestone()
	if IsValid( self.TTG_Gravestone ) then self.TTG_Gravestone:Remove() end
	self.TTG_Gravestone = nil
end


--Eaten: the gravestone goes, and the body with it. The body is the engine's,
--but the ragdoll each client draws belongs to its server half, so removing
--that takes the body off every screen.
function TTGPlayer:RemoveRemains()
	self:RemoveGravestone()

	local body = self:GetRagdollEntity()
	if IsValid( body ) then body:Remove() end
end


--The gravestone nearest this player within `reach`, and how far, or nil. Only
--for somebody who is dead right now, and measured from the spot it stands over.
function TTGPlayer:NearestGravestone( reach )
	local here = self:GetPos()
	local best, bestdist = nil, reach

	for _, other in ipairs( player.GetAll() ) do
		local stone = other.TTG_Gravestone

		if other != self and not other:Alive() and IsValid( stone ) then
			local dist = stone.TTG_Ground:Distance( here )
			if dist <= bestdist then best, bestdist = stone, dist end
		end
	end

	return best, bestdist
end


--Before the death is dealt with rather than after, while where they were
--standing is still what the player says: this runs ahead of GM:DoPlayerDeath.
hook.Add( "DoPlayerDeath", "TTG_PlaceGravestone", function( ply )
	if TTG_CorpseStyle() != "gravestone" then return end

	ply:PlaceGravestone()
end )

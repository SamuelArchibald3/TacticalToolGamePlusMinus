/*---------------------------------------------------------
	Corpses
---------------------------------------------------------*/

--What Cannibalism eats, and clearing it away between rounds.
--
--A death leaves the engine's body as it always has, and a gravestone where the
--player last stood (gravestones.lua). The server never knows where the
--engine's body ends up - each client simulates it for itself - so the
--gravestone is the corpse as far as anything here is concerned: standing at the
--stone is standing at the meal, for everybody.
--
--There used to be a second style, chosen by ttg_var_corpses: a body the server
--made and simulated itself, so it lay in the same place for everybody. It went,
--and every death leaves a gravestone.

if not SERVER then return end

local TTGPlayer = FindMetaTable( "Player" )


--The corpse within `reach` to eat: the nearest gravestone.
function TTGPlayer:NearestCorpse( reach )
	return self:NearestGravestone( reach )
end


--Where a corpse is eaten from: the spot under its gravestone.
function TTG_CorpseSpot( corpse )
	return corpse.TTG_Ground or corpse:GetPos()
end


--Every corpse goes, at the start of a round: every player's gravestone, a
--spectator's included, and every gravestone on the map whoever's it was - one
--from ttg_devgrave belongs to nobody, and only going by player left those
--standing round after round.
function TTG_ClearCorpses()
	for _, ply in ipairs( player.GetAll() ) do
		ply:RemoveGravestone()
	end

	for _, stone in ipairs( ents.FindByClass( "ent_gravestone" ) ) do
		stone:Remove()
	end
end


--Eaten: the gravestone goes, and its player's body with it. A stone that
--belongs to nobody just goes.
function TTG_ConsumeCorpse( corpse )
	if IsValid( corpse.TTG_GraveOf ) then
		corpse.TTG_GraveOf:RemoveRemains()
	else
		corpse:Remove()
	end
end

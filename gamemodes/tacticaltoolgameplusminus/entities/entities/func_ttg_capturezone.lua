AddCSLuaFile("func_ttg_capturezone.lua")

ENT.Type 			= "brush"
ENT.Base 			= "base_anim"
ENT.PrintName		= ""



if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

ENT.TTG_IsActive = nil
ENT.TouchingPlyList = {}


function ENT:Initialize()
	self.TouchingPlyList = {}
	
	self:CreateMarker()
end


function ENT:EmptyTable()
	table.Empty( self.TouchingPlyList )
end


//The list from where everybody is right now, for straight after a rewind has
//teleported them all.
//
//The engine does report a teleport - StartTouch or EndTouch on the next tick,
//frozen or not, measured on ttg_arena_v1's zone. This only saves the capture
//from spending that tick on where people stood before the rewind. It used to
//be the cause of the very thing it was meant to prevent: it listed somebody
//rewound onto the point, the engine's StartTouch listed them again, and
//walking off took one of the two away. The other stayed for the rest of the
//round, so a defender who had left went on contesting the point and the
//attackers could not cap. StartTouch now never lists anybody twice.
//
//The player's hull against the zone's box, as the engine tests it, rather than
//just their centre - otherwise somebody on the very edge comes out of this
//off the list while the engine still has them on the point, and so never
//sends the StartTouch that would put them back.
function ENT:RebuildTouchList()
	table.Empty( self.TouchingPlyList )

	if self.TTG_IsActive != true then return end

	local mins, maxs = self:GetCollisionBounds()

	for _, ply in pairs( player.GetAll() ) do
		if ply:Team() == TEAM_SPEC then continue end

		--the hull in the zone's own space. Zones are unrotated boxes, so the
		--player's box can be carried across as it is
		local at = self:WorldToLocal( ply:GetPos() )
		local lo, hi = at + ply:OBBMins(), at + ply:OBBMaxs()

		local overlaps = lo.x <= maxs.x and hi.x >= mins.x
			and lo.y <= maxs.y and hi.y >= mins.y
			and lo.z <= maxs.z and hi.z >= mins.z

		if overlaps then
			table.insert( self.TouchingPlyList, ply )
		end
	end
end



//TEAM_RED_SPEC and TEAM_BLUE_SPEC used to be tested for here as well. Neither
//was ever defined - shared.lua sets up TEAM_RED, TEAM_BLUE and TEAM_SPEC and
//stops - so both comparisons were Team() == nil, which is always false. They read
//as though per-team spectators exist, and they do not.
//
//The idea behind them was presumably that the dead should count as spectators
//rather than as players on their team. That is worth having, but it does not
//need two more teams: IsValidGamePlayer() already means alive, playing, not
//spectating, and ChangeCapture now asks it. See capturetimer.lua.
function ENT:StartTouch( entity )
	if self.TTG_IsActive != true then return end

	if IsValid( entity ) and entity:IsPlayer() then
		if entity:Team() == TEAM_SPEC then return end

		//Once each. EndTouch takes one copy off, so a second one would be a
		//player still counted on the point after they have left it.
		if table.HasValue( self.TouchingPlyList, entity ) then return end

		table.insert( self.TouchingPlyList, entity )
	end
end

function ENT:EndTouch( entity )
	if self.TTG_IsActive != true then return end

	//No spectator check on the way out. It used to match StartTouch, which meant
	//somebody who joined spectators while standing in the zone could never be
	//taken off the list - the one case where leaving matters most.
	if IsValid( entity ) and entity:IsPlayer() then
		table.RemoveByValue( self.TouchingPlyList, entity )
	end
end

function ENT:Think()
	//print(table.ToString(self.TouchingPlyList))
end


function ENT:CreateMarker()
	local MarkerPos = self:OBBCenter( ) + Vector(0, 0, 55)
	local Marker = ents.Create("marker_capturezone")
		Marker:SetPos(MarkerPos) 
		Marker:Spawn()
		
	self.MarkerEnt = Marker
end


//Whether this zone's marker is showing. Only the live zone's should be: a map
//can hold several zones and ChooseAttackSite makes one of them the objective each
//round, but every zone makes a marker as it spawns, so without this a three-point
//map shows three points. The client's [ ] over the marker follows the same flag.
function ENT:ShowMarker( show )
	if IsValid( self.MarkerEnt ) then
		self.MarkerEnt:SetNoDraw( show != true )
	end
end


//for _, v in pairs(player.GetAll()) do
	//v:PrintMessage(HUD_PRINTTALK, entity:GetName().. " has entered the lua brush area.")
//end

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


//The list below is built purely out of StartTouch and EndTouch, and neither
//fires reliably when a player is teleported rather than walked out - which is
//exactly what the Rewind ability does to everybody at once. Left stale it
//decides rounds: somebody rewound off the point keeps contesting it forever, so
//G_CurCaptureMode sticks on "stuck" and the attackers can never cap, and
//somebody rewound onto it never starts capturing.
//
//Tests the player's centre against the brush rather than their whole hull, so
//it is an approximation of what the engine does - somebody balanced on the very
//edge of the zone can come out of a rewind on the other side of this from where
//StartTouch would have put them. Close enough, given the alternative is a list
//that is simply wrong.
function ENT:RebuildTouchList()
	table.Empty( self.TouchingPlyList )

	if self.TTG_IsActive != true then return end

	local mins, maxs = self:GetCollisionBounds()

	for _, ply in pairs( player.GetAll() ) do
		if ply:Team() == TEAM_SPEC then continue end

		if self:WorldToLocal( ply:WorldSpaceCenter() ):WithinAABox( mins, maxs ) then
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

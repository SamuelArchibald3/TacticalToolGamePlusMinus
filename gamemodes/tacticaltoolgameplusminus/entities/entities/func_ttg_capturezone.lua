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


//for _, v in pairs(player.GetAll()) do
	//v:PrintMessage(HUD_PRINTTALK, entity:GetName().. " has entered the lua brush area.")
//end

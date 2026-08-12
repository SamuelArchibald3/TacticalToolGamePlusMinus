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



function ENT:StartTouch( entity )
	if self.TTG_IsActive != true then return end
	
	if entity:IsPlayer() and entity:IsValid() then
		if (entity:Team() == TEAM_SPEC) or (entity:Team() == TEAM_RED_SPEC) or (entity:Team() == TEAM_BLUE_SPEC) then
		return end
		
		table.insert( self.TouchingPlyList, entity )
	end
end

function ENT:EndTouch( entity )
	if self.TTG_IsActive != true then return end
	
	if entity:IsPlayer() and entity:IsValid() then
		if (entity:Team() == TEAM_SPEC) or (entity:Team() == TEAM_RED_SPEC) or (entity:Team() == TEAM_BLUE_SPEC) then
		return end
	
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

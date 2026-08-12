/*---------------------------------------------------------
	special functions used by stuff in 'ingame.lua'
---------------------------------------------------------*/





/*---------------------------------------------------------
	Globals and their possible vars ("G_" symbolizes it)
---------------------------------------------------------*/
--G_CurrentPhase:
	--"GameSetup"
	--"DefendersBuy"
	--"AttackersBuy"
	--"Planning"
	--"Setup"
	--"Combat"
	--"Winning"
	--"GameEnd"

	
--G_GameBegun
	-- true or false

--G_CurAttackZone
	--this will be one of the func_bomb_zones of the map, chosen at random each round




	
/*---------------------------------------------------------
	Derma panel opening stuff
---------------------------------------------------------*/

function Open_BuyingMenus()
	for k,ply in pairs(player.GetAll()) do
	
		if ply:Team() != TEAM_SPEC then
			umsg.Start("Open_BuyingVgui", ply)
			umsg.End()
			
			umsg.Start("Open_TeamPurchasesVgui", ply)
			umsg.End()
		else
			umsg.Start("Open_TeamPurchasesVgui", ply)
			umsg.End()
			
		end
	end
end

function Close_BuyingMenus()
	for k,ply in pairs(player.GetAll()) do
		
		if ply:Team() != TEAM_SPEC then
			umsg.Start("Close_BuyingVgui", ply)
			umsg.End()
			
			umsg.Start("Close_TeamPurchasesVgui", ply)
			umsg.End()
		else
			umsg.Start("Close_TeamPurchasesVgui", ply)
			umsg.End()
			
		end
	end
end

--this is if the player joins spec in the middle of a round, the menus need to close out
function Close_BuyingMenusForPly( ply )
	umsg.Start("Close_BuyingVgui", ply)
	umsg.End()
	
	umsg.Start("Close_TeamPurchasesVgui", ply)
	umsg.End()
end



/*---------------------------------------------------------
	functions that run during the round sometimes
---------------------------------------------------------*/

//Choses what will be the attack site for this round, if there are multiple like on de_ maps
function ChooseAttackSite()
	//find the capture areas (bomb sites) and set one to be active this round.
	local SitesTable = {}
	
	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "func_ttg_capturezone" then
			table.insert( SitesTable, ent )
		end
	end
	
	local Count = table.Count( SitesTable  )
	
	//if there is no attack site then dont create a marker
	if Count <= 0 then
	print("Error, there is no func_ttg_capturezone in this map, so there's no objective")
	return end
	
	for k,site in pairs(SitesTable) do
		site:EmptyTable()
	end
	
	local ChosenSite = SitesTable[ math.random( 1, Count ) ]
	
		
	--sets the global 'G_CurAttackZone' to be the chosen func_ttg_capturezone entity for this round
	G_CurAttackZone = ChosenSite
	G_CurAttackZone.TTG_IsActive = true
end



//Sets the attacking teams doors to be closed at the beginning of a round
function CloseAttackersDoors()
	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "func_brush" then
			if ent:GetName() == BRUSH_DOOR_NAME then
				ent:Fire( "Enable", 0, 0 )
			end
		end
	end
end


//Opens the attacking teams doors at the end of the defender's setup time
function OpenAttackersDoors()
	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "func_brush" then
			if ent:GetName() == "TTG_Brush_Door" then
				ent:Fire( "Disable", 0, 0 )
			end
		end
	end
end







function CheckIfTeamsAlive( )
	--if we're in the mode where im editting code solo, for testing purposes turn off this round ending thing
	if END_ROUND_IF_ONE_TEAM_DEAD == false then return end
	
	//print("checking if team alive")
	
	local attacking_team = nil
	local defending_team = nil
	
	if GetTeamRole(TEAM_RED) == "Attacking" then
		attacking_team = TEAM_RED
		defending_team = TEAM_BLUE
	elseif GetTeamRole(TEAM_BLUE) == "Attacking" then
		attacking_team = TEAM_BLUE
		defending_team = TEAM_RED
	end
	
	
	local defending_aliveplayers = 0
	for _,ply in pairs(team.GetPlayers(defending_team)) do
		if ply:GetObserverMode( ) == OBS_MODE_NONE then
			defending_aliveplayers = defending_aliveplayers + 1
		end
	end
	
	local attacking_aliveplayers = 0
	for _,ply in pairs(team.GetPlayers(attacking_team)) do
		if ply:GetObserverMode( ) == OBS_MODE_NONE then
			attacking_aliveplayers = attacking_aliveplayers + 1
		end
	end
	
	--if both teams somehow die at the same time, the defending team still wins.
	if defending_aliveplayers == 0 and attacking_aliveplayers == 0 then
		return WinningPhase(defending_team)
	end
	
	if defending_aliveplayers == 0 then
		return WinningPhase(attacking_team)
	end
	
	if attacking_aliveplayers == 0 then
		return WinningPhase(defending_team)
	end
	
end



//makes it constantly make sure atleast one person on each team is alive, otherwise end the round
function Start_TeamsAliveCheck()
	hook.Add("Think", "CheckIfTeamsAlive", CheckIfTeamsAlive)
end

//makes it stop checking if theres atleast one person on each team is alive
function End_TeamsAliveCheck()
	hook.Remove( "Think", "CheckIfTeamsAlive" )
end












/*---------------------------------------------------------
	Resetting stuff
---------------------------------------------------------*/

//reset the player's ability slots, so the ents are destroyed
function Reset_PlyAbilities( ply )
	if ply.Ability_A != nil then
		//print("removing", ply.Ability_A)
		ply.Ability_A:Remove()
		ply.Ability_A = nil
	end
	
	if ply.Ability_B != nil then
		//print("removing", ply.Ability_B)
		ply.Ability_B:Remove()
		ply.Ability_B = nil
	end
	
	if ply.Ability_C != nil then
		//print("removing", ply.Ability_C)
		ply.Ability_C:Remove()
		ply.Ability_C = nil
	end
	
	ply:ResetAbilityInfo()
	ply:ResetSwepToolInfo()
end



--Reset the information the player carries about his buffs, as well as the buffs themselves if they were on
function Reset_PlyBuffs( ply )

	ply.BuffAmountsTable_Cur = nil
	ply.BuffAmountsTable_Prev = nil
	
	ply:RemoveAllBuffs(  )
end





function ResetVarsBetweenRounds()
	--global vars to be reset between rounds
	G_CaptureTimeMoving = false
	G_Overtime = false
	G_CurCaptureMode = "none"
	G_WinAlreadyTriggered = false
	
	--Sets there to be no current attack zone and turns off the zone
	if IsValid(G_CurAttackZone) then
		G_CurAttackZone:EmptyTable()
		G_CurAttackZone.TTG_IsActive = false
		G_CurAttackZone = nil
	end
	
	--global bools that communicate stuff to the client
	SetGlobalBool("CL_DrawOvertime", false)
	SetGlobalBool("CL_PlayTimerCountSounds", false)
	
	--turns off the capture hud thing
	umsg.Start( "IfCaptureOn" )
    umsg.Bool( false )
	umsg.End()

	--clears old client vars
	umsg.Start("ClearOldClientVars")
	umsg.End()
	
	for k,v in pairs(player.GetAll()) do
		
		//Invuln stuff
		v:SetInvulnInfo(false)
		v.HasFreeze = false
		v:SetMaterial(v.TTG_OrigMat)
		--redo invuln to be a buff
	
	
		//death spectating stuff
		v.DeathSpectate = false
		v.CurSpectateTarget = nil
		v.SpectateTargets = nil
	
	
		v:SetIfHasGun( false )
		v:ResetAll_RevealerMarker()
		
		//reset the player's ability slots, so the ents are destroyed
		Reset_PlyAbilities( v )
		
		//Reset the information the player carries about his buffs, as well as the buffs themselves if they were on
		Reset_PlyBuffs( v )
		
		//reset the player's spawn for the round
		v.CurRoundSpawn = nil
	end
end



--disables stuff like the sentry gun, proximity mines, etc
function DisableAllEnts()
	--remove all proximity bombs (so they dont blow up in peoples faces when they spawn next round)
	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "ent_proximitybomb" then
			ent.ExplodeOnRemove = false
		end
	end
	
	--add more stuff later
end


--Remove all leftover TTG ents in the world.  (for example: barriers, invis reveal devices, etc)
function RemoveAllGameEnts()
	--Ents
	for k,ent in pairs(ents.GetAll()) do
		if CheckIfInEntTable(ent) then
			ent:Remove()
		end
	end
	
end







--[[
--set the player to join the team of their choice at the end of this round
function JoinTeamNextRound( ply, teamchoice )
	//G_JoiningPlayers = {}
	
	--add the player and their team choice to the table
	--if theyre already in the table then replace what they chose last
	
end
]]--


--For all spectating players who want to join, make them join the team they chose ( runs between rounds )
function NextRoundJoinAllPlayers()
	for _, ply in pairs( T_BlueJoiners ) do
		ply:SetTeam( TEAM_BLUE )
		ply:SetJoiningTeam( "none" )
	end
	
	for _, ply in pairs( T_RedJoiners ) do
		ply:SetTeam( TEAM_RED )
		ply:SetJoiningTeam( "none" )
	end

	table.Empty( T_BlueJoiners )
	table.Empty( T_RedJoiners )
end


--adds all the spawns to the spawn tables
--the tables are used so no two players spawn at the same spawn, a spawn is removed from the table when a player spawns at that spawn
function SetupRoundSpawnTables()
	T_Spawns_Avail_Defending = {}
	T_Spawns_Avail_Attacking = {}

	--this is just in case there were spawns already in the table for some reason
	table.Empty( T_Spawns_Avail_Defending )
	table.Empty( T_Spawns_Avail_Attacking )
	
	--Allies and counterterrorists are defenders
	T_Spawns_Avail_Defending  = ents.FindByClass( "info_player_allies" )
	T_Spawns_Avail_Defending = table.Add( T_Spawns_Avail_Defending, ents.FindByClass( "info_player_counterterrorist" ) )
	
	--Axis and terrorists are attackers
	T_Spawns_Avail_Attacking  = ents.FindByClass( "info_player_axis" )
	T_Spawns_Avail_Attacking = table.Add( T_Spawns_Avail_Attacking, ents.FindByClass( "info_player_terrorist" ) )	
end















//if all players have bought their tools, end their teams buying phase early
function CheckIfPlayersBought( )
	
	if not ( G_CurrentPhase == "DefendersBuy" or G_CurrentPhase == "AttackersBuy")  then return end

	
	//returns true if all the players on the team have spent all their tool tokens
	local function CheckIfTeamHasBought( teamnum )
		for k,v in pairs(player.GetAll()) do	
			if v:Team() == teamnum then
				if v:GetToolTokens() > 0 then
					return false
				end
			end
		end
		return true
	end
	
	
	//ends the current team's buying and moves to the next phase
	local function MoveToNextPhase()
		if G_CurrentPhase == "DefendersBuy" then
			Clear_Timer()
			AttackersBuyPhase()
			
		elseif G_CurrentPhase == "AttackersBuy" then
			Clear_Timer()
			PlanningPhase()
			
		end
	end
	
	
	
	
	local attackers = nil
	local defenders = nil
	
	if GetTeamRole( TEAM_RED ) == "Defending" then
		defenders = TEAM_RED
		attackers = TEAM_BLUE
	elseif GetTeamRole( TEAM_RED ) == "Attacking" then
		defenders = TEAM_BLUE
		attackers = TEAM_RED
	end
	
	
	if G_CurrentPhase == "DefendersBuy" then
		if CheckIfTeamHasBought( defenders ) then
			MoveToNextPhase()
		end
		
	elseif G_CurrentPhase == "AttackersBuy" then
		if CheckIfTeamHasBought( attackers ) then
			MoveToNextPhase()
			End_CheckIfPlayersBought()
		end
	
	
	end
	
	
end



//makes it constantly make sure atleast one person on each team is alive, otherwise end the round
function Start_CheckIfPlayersBought()
	hook.Add("Tick", "CheckIfPlayersBought", CheckIfPlayersBought)
end

//makes it stop checking if theres atleast one person on each team is alive
function End_CheckIfPlayersBought()
	hook.Remove( "Tick", "CheckIfPlayersBought" )
end



--dev function
function CreatePosMark( pos )
	local obj = ents.Create("dev_posmark")
		obj:SetPos( pos )
		obj:Spawn()
end



function CreateTimerEnt( time_amount, globalint_name )
	local obj = ents.Create("ttg_timer")
		obj.Time = time_amount
		obj.GlobalIntName = globalint_name
		obj:Spawn()
	return obj
end




function ChatPrintToAll( str )
	for _, ply in pairs(player.GetAll()) do
		ply:ChatPrint( str )
	end
end







/*---------------------------------------------------------
	Trigger Hurt Check, saves players who fall into a pit during the defender's setup phase
---------------------------------------------------------*/

--if the player touches a trigger_hurt during setup time then have them instantly teleport back to spawn, and
function TriggerHurtCheck( )
	if G_CurrentPhase != "Setup" then return end
	for k,ply in pairs(player.GetAll()) do
		if ply:IsValidGamePlayer() then
			local orgin_ents = ents.FindInSphere( ply:GetPos(), 32 )
	
			--teleport players who are in trigger hurts at setup
			for k, ent in pairs( orgin_ents ) do
				if ent:GetClass() == "trigger_hurt" then
					ply:SetPos( ply.CurRoundSpawn:GetPos() )
				end
			end
		end
	end
end

function Start_TriggerHurtCheck()
	hook.Add("Think", "TriggerHurtCheck", TriggerHurtCheck)
end

function End_TriggerHurtCheck()
	hook.Remove( "Think", "TriggerHurtCheck" )
end


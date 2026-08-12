--G_CurrentPhase:
	--"GameSetup"
	--"DefendersBuy"
	--"AttackersBuy"
	--"Planning"
	--"Setup"
	--"Combat"
	--"Winning"
	--"GameEnd

	
	function NextRound()

		ResetVarsBetweenRounds()
		
		--[[
		//join all players who signed up to join last round, if pub mode is on
		if PUB_MODE == true then
			NextRoundJoinAllPlayers()
		end
		]]--
		
		--end the whole game if one team has no players at all
		if DEV_MODE != true then
			local redplys = team.NumPlayers( TEAM_RED )
			local blueplys = team.NumPlayers( TEAM_BLUE )
		
			if redplys == 0 then
				GameRestart()
				ChatPrintToAll( "All of red team's players have left, restarting!" )
				return
			end
			if blueplys == 0 then
				GameRestart()
				ChatPrintToAll( "All of blue team's players have left, restarting!" )
				return
			end
		end
		
		//set all spawns to be availible
		SetupRoundSpawnTables()
		
		--Remove all leftover TTG ents in the world.  (for example: barriers, invis reveal devices, etc) And Abilities as well
		RemoveAllGameEnts()
		
		
		G_CurRound = G_CurRound + 1
		SetRound(G_CurRound)
		
		--if its not the first round, then flip around the teams roles
		if G_CurRound != 1 then
			if GetTeamRole(TEAM_RED) == "Attacking" then
				SetTeamRole(TEAM_RED, "Defending")
				SetTeamRole(TEAM_BLUE, "Attacking")
			elseif GetTeamRole(TEAM_RED) == "Defending" then
				SetTeamRole(TEAM_RED, "Attacking")
				SetTeamRole(TEAM_BLUE, "Defending")
			end
		end
	
		
		--Checks if this will be a tie breaker round, randomly gives roles out
		if G_CurRound == G_TotalRounds + 1 then
			--Set the roles randomly for the first round
			local rand = math.random(2)
			
			if rand == 1 then
				SetTeamRole(TEAM_RED, "Defending")
				SetTeamRole(TEAM_BLUE, "Attacking")
			elseif rand == 2 then
				SetTeamRole(TEAM_RED, "Attacking")
				SetTeamRole(TEAM_BLUE, "Defending")
			end
		end
	
		
		//set the zone the teams are vying for control over to be at one of the bomb sites of the de_ map
		ChooseAttackSite()
		
		//makes it constantly make sure atleast one person on each team is alive, otherwise end the round
		Start_TeamsAliveCheck()
		Start_TriggerHurtCheck()
		
		for k,v in pairs(player.GetAll()) do	
			if v:Team() != TEAM_SPEC then
				-- take away all the players tools from the previous round
				v:StripWeapons()
			
				--make sure they arent in specate mode like they are when theyre dead
				v:UnSpectate()
			
				--spawn all players, except specs
				v:Spawn()
				
				--sets the default stuff for the player, speed, model, default_melee, etc
				SetSpawnStuff( v )
			
				--lock all players so they cant move at all while the buying screen is open
				v:Freeze( true )
				
				--Set everyones tokens to 3, so they can purchase 3 tools in the round
				v:SetToolTokens(ROUND_TOKENS)
				
				--give attackers god mode so they cant be killed in setup phase later
				if GetTeamRole(v:Team()) == "Attacking" then
					v:TTG_Invuln( true )
					//v:TTG_Freeze( true )
				end	
				
				--give defending god mode so they cant be killed in setup phase later
				if GetTeamRole(v:Team()) == "Defending" then
					v:TTG_Invuln( true )
					//v:TTG_Freeze( true )
					hook.Remove("KeyPress", "SpectatorKeyPress")
				end	
			end
		end
		
		
		DefendersBuyPhase()
		
		CloseAttackersDoors()
	end
	
--Redo this so it just triggers resetvarsbetweenrounds, and does extra stuff for the vars beyond that
function Reset_AllGlobalVars()
	--global vars that pass information around, as well as their methods for the client
	
	ResetVarsBetweenRounds()
	
	G_CurrentPhase = "GameSetup"
	G_GameBegun = false
	G_CurRound = 0
		SetRound(0)
	G_FirstAttacker = nil
	G_TotalRounds = 0
		SetTotalRounds(0)
	G_MaxScore = 0
		SetMaxScore(0)
	G_GameWinners = nil
	
	--Global tables, make sure theyre empty
	T_BlueJoiners = {}
	T_RedJoiners = {}
	table.Empty( T_BlueJoiners )
	table.Empty( T_RedJoiners )
	
	--Set both team's scores to be 0
	team.SetScore (TEAM_RED, 0)
	team.SetScore (TEAM_BLUE, 0)
	

	
	--global bools that communicate stuff to the client
	SetGlobalString("CL_CurPhase", "GameSetup")
	SetGlobalString("CL_CurBuyingRole", "None")
	
	
	--make sure all players are their original materials, not the invulnerable material, and other stuff
	for k,v in pairs(player.GetAll()) do
		
		//midgame team joining stuff
		v:SetJoiningTeam( "none" )
		
		//if their join menu was open, close it
		if v:GetIfTeamJoinMenuOpen() then 
			Close_JoinMenu( v )
		end
	end
	
	
	--this is pretty much a local var to gamesetup
	StartedCountDown = false
end






--Starts the whole game up and resets everything in the map to 0
--Also runs right when the game first starts in init.lua
function GameRestart()
	if P_JustSwitchedMaps == true then
		--add a 'waiting for players' timer thing activated here later
		P_JustSwitchedMaps = false
	end
	


	--If the game was restart during the buy phase, close out of all the menus
	if G_CurrentPhase == "DefendersBuy" or G_CurrentPhase == "AttackersBuy" or G_CurrentPhase == "Planning" then
		Close_BuyingMenus()
	--if the game was restart during setup, close the team setup menu
	elseif G_CurrentPhase == "GameSetup" then
		for k,ply in pairs(player.GetAll()) do		
			Close_TeamSetupMenu( ply )
		end
	end
	
	
	
	--end any ongoing votes
	if G_VoteInProgress == true then
		EndVote()
	end
	--remove all old ent timers
	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "ttg_timer" then
			ent:Remove()
		end
	end
	
	
	
	--Turns off the two things that run on think during the round.
	End_CaptureCheck()
	End_TeamsAliveCheck()

	--destroy all timers that may have been set to trigger events
	timer.Destroy("CountdownTimer")
	timer.Destroy("NextRoundTimer")
	
	--resets a lot of global vars to their default states
	Reset_AllGlobalVars()
	
	--Clears the time and turns it off
	Clear_Timer()
	
	--Remove all leftover TTG ents in the world.  (for example: barriers, invis reveal devices, etc)
	for k,ent in pairs(ents.GetAll()) do
		if CheckIfInEntTable(ent) then
			ent:Remove()
		end
	end
	
	--Set player to spectator, take away all their weapons, force them to respawn, reset their money, open the team setup menu
	for k,v in pairs(player.GetAll()) do		
		v:StripWeapons()
		v:SetTeam(TEAM_SPEC)
		v:Spawn()
		v:SetMoney(0)
		
		
		v:Freeze( true )	--makes so camera doesnt keep moving if they were walking forward, unfreeze right after
		timer.Simple( 2, function()
			if not IsValid(v) then return end
			v:Freeze( false )
		end)
		
		Open_TeamSetupMenu(v)
	end
end




--Opens the Teams Panel menu for a player
function Open_TeamSetupMenu( ply )
	ply:SetReady(false)

	umsg.Start( "GCTeamsPanel_open", ply )
	umsg.End()
end


--Closes the Teams Panel menu for all players
function Close_TeamSetupMenu( ply )

	umsg.Start( "GCTeamsPanel_close", ply )
	umsg.End()
end



--Opens the joining panel menu for a player
function Open_JoinMenu( ply )
	ply:SetIfTeamJoinMenuOpen( true )

	umsg.Start("TeamJoinPanel_open", ply)
	umsg.End()
end


--Closes the Teams Panel menu for a player
function Close_JoinMenu( ply )
	ply:SetIfTeamJoinMenuOpen( false )

	umsg.Start("TeamJoinPanel_close", ply)
	umsg.End()
end




--Returns true if both teams have enough players and all players are ready to start
function CheckIfAllReady()

	--If theres not atleast 1 player in the server then return false, if no one is there no one is ready
	if table.Count(player.GetAll()) < 1 then 
	return false 
	end
	
	
	--Make sure both teams have enough players
	--if dev mode is on, playercounts for each team dont matter, so skip this
	if MUST_HAVE_FULL_TEAMS == true then
		if team.NumPlayers(TEAM_RED) < PLAYERS_PER_TEAM or team.NumPlayers(TEAM_BLUE) < PLAYERS_PER_TEAM then
			return false
		end
	end
	
	if MUST_HAVE_ATEAST_1PLAYER_PERTEAM == true then
		if team.NumPlayers( TEAM_RED ) < 1 then return false end
		if team.NumPlayers( TEAM_BLUE ) < 1 then return false end
	end
	
	--if both of the teams have no players, then we cannot start yet, this is mostly for dev mode so it wont auto start with 1 ply on spec
	if team.NumPlayers( TEAM_RED ) < 1 and team.NumPlayers( TEAM_BLUE ) < 1 then return false end
	
	--Make sure no blue or red team players are not ready
	for k,v in pairs(player.GetAll()) do
		if v:GetIfReady() == false and v:Team() != TEAM_SPEC then
		return false
		end
	end

	return true --if past both checks
end



//Checks if all players are ready every Think, if they are it triggers the countdown to beginning the round.
function ReadyChecker()

	//only run this if the game hasnt begun yet
	if G_GameBegun then return end
	
	//if everyones ready and the countdown hasnt started, start it
	if CheckIfAllReady() == true then
		if StartedCountDown == false then
			CountdownToRound()
			StartedCountDown = true
		end
	else
		//if players suddenly become unready when the countdown is started, cancel it
		if StartedCountDown == true then
			CancelCountdown()
		end
	end
end
hook.Add("Think", "ReadyChecker", ReadyChecker)




function CountdownToRound()
	//print("Counting Down!")
	umsg.Start("GCTeamsPanel_startcount")
	umsg.End()
	
	timer.Create( "CountdownTimer", BEGINNING_COUNTDOWN, 1, function()
		
		//close out of the game team setup menu
		for k,ply in pairs(player.GetAll()) do		
			Close_TeamSetupMenu( ply )
		end
		
		//start the game
		BeginGame()
		end)
end


function CancelCountdown()
	StartedCountDown = false

	timer.Destroy("CountdownTimer")
	
	umsg.Start("GCTeamsPanel_cancelcount")
	umsg.End()
end


--Starts the actual gameplay game of TTG, meaning the rounds start, we arent in team setup menu
function BeginGame()

	--sets the total rounds to be the num set in shared rounds
	G_TotalRounds = ROUNDS
	SetTotalRounds(G_TotalRounds)
	
	--set the total rounds to be itself minus 1 if its an odd number, makes it into an even number
	local num,deci = math.modf(ROUNDS/2)
	if deci != 0 then
		G_TotalRounds = ROUNDS - 1
		SetTotalRounds(G_TotalRounds)
	end
	

	--sets how many points a team must get to win the game
	G_MaxScore = (G_TotalRounds/2 + 1)
	SetMaxScore(G_MaxScore)
	
	print("Beginning the Game!  It's best of " .. G_TotalRounds + 1 .. " rounds!")
	
	
	
	G_GameBegun = true
	
	--Set the roles randomly for the first round
	local rand = math.random(2)
	
	if rand == 1 then
		G_FirstAttacker = TEAM_BLUE
		G_FirstDefender = TEAM_RED
	elseif rand == 2 then
		G_FirstAttacker = TEAM_RED
		G_FirstDefender = TEAM_BLUE
	end
	
	SetTeamRole(G_FirstAttacker, "Attacking")
	SetTeamRole(G_FirstDefender, "Defending")
	
	for k,v in pairs(player.GetAll()) do
		--unfreeze people since they were froze during team setup menu
		v:Freeze( false )
	end
	
	NextRound()
end
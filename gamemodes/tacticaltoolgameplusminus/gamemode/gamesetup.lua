--G_CurrentPhase:
	--"GameSetup"
	--"DefendersBuy"
	--"AttackersBuy"
	--"Planning"
	--"Setup"
	--"Combat"
	--"Winning"
	--"GameEnd

	
	--NextRound was defined here as well as in ingame.lua. init.lua includes
	--gamesetup before ingame, so this copy was overwritten at load and never ran:
	--BeginGame's call to NextRound() further down resolves to ingame.lua's
	--version at runtime.
	--
	--It had drifted from the live one, and those differences therefore never took
	--effect. Removed rather than merged, because folding them in would be a
	--gameplay change rather than a refactor. For the record, this copy also:
	--  * gave DEFENDERS TTG_Invuln( true ) during setup, not just attackers
	--  * did hook.Remove( "KeyPress", "SpectatorKeyPress" ) for them
	
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
	SetGamePhase("GameSetup")
	SetBuyingRole("None")
	
	
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
		
		--back to nobody having picked a side, so Randomize Teams deals everyone in
		v.TTG_ChoseSpectator = false
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



--Something to tell one player from another for the shuffle history.
--
--Every bot answers "BOT" to SteamID, so they would all look like the same
--player and a lobby of them would have one arrangement in it.
function TTG_PlayerShuffleKey( ply )
	if ply:IsBot() then return "bot" .. ply:UserID() end

	return ply:SteamID() or ( "uid" .. ply:UserID() )
end


--n choose k, for counting how many arrangements a lobby has.
function TTG_Choose( n, k )
	if k < 0 or k > n then return 0 end
	if k == 0 or k == n then return 1 end

	local result = 1
	for i = 1, k do
		result = result * ( n - k + i ) / i
	end

	return math.Round( result )
end


--Everyone the shuffle is going to deal, in a fixed order.
--
--Sorted by key rather than left in whatever order player.GetAll() gave, because
--the pool below is a set of positions - position 3 has to mean the same player
--from one shuffle to the next or the remembered arrangements stop matching.
--
--Only players who actually pressed Join Spectators are left out. Everyone else
--gets a side, including people sitting on spectators because they have not
--picked yet, which is when the button is most useful.
local function Participants()
	local playing = {}

	for _, ply in pairs( player.GetAll() ) do
		if ply.TTG_ChoseSpectator != true then
			table.insert( playing, ply )
		end
	end

	table.sort( playing, function( a, b )
		return TTG_PlayerShuffleKey( a ) < TTG_PlayerShuffleKey( b )
	end )

	return playing
end


--Who is in the lobby, as a string, so a change of roster can be noticed.
local function RosterKey( playing )
	local keys = {}
	for _, ply in ipairs( playing ) do
		table.insert( keys, TTG_PlayerShuffleKey( ply ) )
	end

	return table.concat( keys, "," )
end


--Every way this many players can be split into two sides.
--
--An arrangement is the set of positions that go red; blue is whatever is left,
--so there is nothing to store for it.
--
--With an even lobby the first player is always put on red. That is what stops
--the mirror being counted twice: { A B } against { C D } is the same pairing
--whichever side wears which colour, and pinning one player to a side names each
--pairing exactly once. With an odd lobby the sides are different sizes and red
--always takes the bigger one, so the mirror never comes up and every set counts.
local function Arrangements( count )
	local red = math.ceil( count / 2 )
	local even = count % 2 == 0

	local out = {}
	local current = {}

	local function step( from )
		if table.Count( current ) == red then
			table.insert( out, table.Copy( current ) )
			return
		end

		for i = from, count do
			--stop when there are not enough players left to finish a side
			if count - i + 1 < red - table.Count( current ) then break end

			table.insert( current, i )
			step( i + 1 )
			table.remove( current )
		end
	end

	if even and count > 0 then
		table.insert( current, 1 )
		step( 2 )
	else
		step( 1 )
	end

	return out
end


--How many different arrangements a lobby of this size has.
--
--Exposed so the sums can be checked directly: getting them wrong means the pool
--is refilled at the wrong moment, which brings repeats back quietly.
function TTG_ShuffleArrangements( count )
	if count < 2 then return 1 end

	local red = math.ceil( count / 2 )

	--the even case pins the first player to red, which is the same as choosing
	--the rest of that side from everybody else
	if count % 2 == 0 then
		return TTG_Choose( count - 1, red - 1 )
	end

	return TTG_Choose( count, red )
end


--Shuffles the lobby across red and blue.
--Everyone lands on spectators when they connect without having picked anything,
--so those players get dealt a side as well - otherwise the button does nothing
--in a fresh lobby, which is exactly when it is most useful. Only players who
--actually pressed Join Spectators are left where they are.
--
--The same teams do not come up twice until every arrangement has been used.
--Every arrangement is worked out up front and they are drawn from a bag: the
--one that comes out is removed, and when the bag is empty it is refilled. That
--is instead of rolling and re-rolling until something unused turns up, which
--needed a cap to avoid hanging and could therefore hand out a repeat while
--arrangements were still going spare.
--
--Twelve players is the most this game has, which is 462 arrangements. Building
--that is nothing; it is only the number of players sitting out that would make
--the maths explode, and nobody sits out any more.
--
--The bag belongs to a set of players. Somebody joining or leaving makes a
--different lobby with different arrangements in it, so it is built again rather
--than carrying over something that no longer applies.
function RandomizeTeams()

	local playing = Participants()
	local count = table.Count( playing )

	if count > 0 then
		local roster = RosterKey( playing )

		if G_ShuffleRoster != roster or G_ShufflePool == nil then
			G_ShuffleRoster = roster
			G_ShufflePool = Arrangements( count )
		end

		--everything has been used, so let it all round again
		if table.Count( G_ShufflePool ) == 0 then
			G_ShufflePool = Arrangements( count )
		end

		local pick = math.random( table.Count( G_ShufflePool ) )
		local reds = G_ShufflePool[ pick ]
		table.remove( G_ShufflePool, pick )

		local isred = {}
		for _, position in ipairs( reds ) do
			isred[ position ] = true
		end

		for i, v in ipairs( playing ) do
			if isred[ i ] then
				v:SetTeam( TEAM_RED )
			else
				v:SetTeam( TEAM_BLUE )
			end

			--Clear ready, so nobody gets counted down into a game on a side they
			--have not seen. ReadyChecker runs on Think, so it cancels a countdown
			--already in progress by itself.
			v:SetReady( false )
		end
	end
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

	//push the opening roles to clients rather than relying on the networked
	//global alone - see BroadcastTeamRoles() in ingame_functions.lua
	BroadcastTeamRoles()
	
	for k,v in pairs(player.GetAll()) do
		--unfreeze people since they were froze during team setup menu
		v:Freeze( false )
	end
	
	NextRound()
end
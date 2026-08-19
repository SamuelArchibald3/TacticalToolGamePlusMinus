/*---------------------------------------------------------
	Game Settings
---------------------------------------------------------*/


//makes it so people can join a team mid-game
PUB_MODE = false











BEGINNING_COUNTDOWN = 3		//seconds to countdown from when beginning the round once all players are ready
PLAYERS_PER_TEAM = 6		//amount of players per team
RESTRICT_PLAYERS_PER_TEAM = true
TEAM_SHUFFLE_COOLDOWN = 3		//seconds before the Randomize Teams button can be used again



LIMBO_ENABLED = false

PLAYER_BASE_SPEED = 190
PLAYER_BASE_CROUCHMULTIPLIER = .6

PLAYER_BASE_SPEED_SETUP = 350
PLAYER_BASE_CROUCHMULTIPLIER_SETUP = .2


PLAYER_BASE_TANKSPEED = 150
PLAYER_BASE_JUMPPOWER = 240
PLAYER_BASE_MAXHEALTH = 100


--Uneven Teams Handicap
--When one team has fewer players than the other, these hand the short handed
--side something to make up for it. Each scales with how many players they are
--down by, so being two down is worth twice being one down. 0 turns a lever off.
--Applied by TTG_HandicapHealth() and friends in ingame_functions.lua.
BALANCE_HEALTH_PER_PLAYER = 25		//extra max health per player the team is down
BALANCE_TOKENS_PER_PLAYER = 0		//extra tool tokens per player the team is down
BALANCE_NO_FIRSTAID = false			//stop the team with more players buying First Aid


VOTING_TIME = 30

BEGINNING_INVULN_TIME = 2

TIME_TO_CAPTURE = 30

ROUND_TOKENS = 4	//cant decide between 3 or 4

//How many bought tools can be listed at once. Every tool costs a token, so a
//player can never own more than ROUND_TOKENS of them - this only has to stay
//ahead of any sane token setting.
//
//There used to be three, named A/B/C. A fourth tool was still bought and worked
//perfectly, but its info never reached the client, so it was missing from the
//bought list with no warning beyond a print on the server. ROUND_TOKENS is 4,
//so the stock settings already reached it.
MAX_TOOL_SLOTS = 10



--Makes it so teams dont have to be full for the game to start, the player just has to press the ready button
MUST_HAVE_FULL_TEAMS = false


--the func_brush which the game will disable at the end of the setup time every round
BRUSH_DOOR_NAME = "TTG_Brush_Door"




VOTE_CHANGEMAP_ENABLED = true
SERVER_MAPS = { "ttg_1path_v1", "ttg_2path_v1", "ttg_hole_a1", "ttg_knavey_a4", "ttg_canyon_a1", "ttg_foundry_a1",  }






--Custom settings
if SERVER then
	--Number of Rounds
	--The number of rounds to play per game
	--this will be turned into the closest even number if its not already
	--nil is tested first on purpose. Comparing nil with a number is a hard error
	--in Lua, so "set_rounds <= 0 or set_rounds == nil" would have thrown before it
	--ever reached the nil check. It never fired only because GetConVarNumber
	--returns 0, not nil, for a convar that does not exist.
	local set_rounds = GetConVarNumber( "ttg_var_rounds" )
	if set_rounds == nil or set_rounds <= 0 then
		set_rounds = 4
	end
	ROUNDS = set_rounds

	--Developer mode
	//makes it so menus switch fast, noclip is enabled, the game doesnt end if one teams dead, etc
	local set_devmode = GetConVarNumber( "ttg_var_devmode" )
	if set_devmode == nil or set_devmode <= 0 then
		DEV_MODE = false
	else
		DEV_MODE = true
	end


	--Tool Tokens Per Round
	--How many tools each player can buy in a single round. Read via
	--TTG_RoundStartTokens() in ingame_functions.lua, which every round-setup
	--path calls when handing tokens out.
	--
	--The setting is declared in tacticaltoolgameplusminus.txt so it shows up in the
	--gamemode settings menu, but it is created here as well so it still works when
	--the menu never runs - a dedicated server started from server.cfg or the command
	--line, for example.
	if not ConVarExists( "ttg_var_tokens" ) then
		CreateConVar( "ttg_var_tokens", tostring( ROUND_TOKENS ), FCVAR_NOTIFY, "How many tools each player can buy each round" )
	end

	--nil is checked first: GetConVarNumber returns 0 for a missing convar, but
	--comparing nil with a number would error outright
	local set_tokens = GetConVarNumber( "ttg_var_tokens" )
	if set_tokens == nil or set_tokens <= 0 then
		set_tokens = ROUND_TOKENS
	end
	ROUND_TOKENS = set_tokens

	--Applies from the next round, since gamesetup.lua reads ROUND_TOKENS when it
	--hands out tokens - so no map restart needed, unlike the rounds setting.
	local function Callback_Tokens( CVar, PreviousValue, NewValue )
		local newtokens = tonumber( NewValue )
		if newtokens == nil or newtokens <= 0 then return end

		ROUND_TOKENS = newtokens
		ChatPrintToAll( "Tool tokens per round set to  " .. newtokens .. "  (applies next round)" )

		--every tool costs a token, so more tokens than slots means the extras
		--would be bought and usable but missing from the bought list
		if newtokens > MAX_TOOL_SLOTS then
			print( "TTG: ttg_var_tokens is " .. newtokens .. " but only " .. MAX_TOOL_SLOTS ..
				" tools can be listed - raise MAX_TOOL_SLOTS in shared_settings.lua" )
		end
	end
	cvars.AddChangeCallback( "ttg_var_tokens", Callback_Tokens, "ttg_var_tokens_setting" )




	--No Tokens On Tie Breaker
	--When enabled, everyone gets 0 tool tokens on the tie breaker round, so the
	--decider is played out with no new purchases. gamesetup.lua checks this when
	--handing out tokens; the tie breaker is the round after the last normal one
	--( G_CurRound == G_TotalRounds + 1 ).
	if not ConVarExists( "ttg_var_tiebreak_notokens" ) then
		CreateConVar( "ttg_var_tiebreak_notokens", "1", FCVAR_NOTIFY, "Give everyone 0 tool tokens on the tie breaker round" )
	end

	TIEBREAK_NO_TOKENS = GetConVarNumber( "ttg_var_tiebreak_notokens" ) > 0

	local function Callback_TiebreakTokens( CVar, PreviousValue, NewValue )
		local newvalue = tonumber( NewValue )
		if newvalue == nil then return end

		TIEBREAK_NO_TOKENS = newvalue > 0

		if TIEBREAK_NO_TOKENS then
			ChatPrintToAll( "Tie breaker round will now give 0 tool tokens" )
		else
			ChatPrintToAll( "Tie breaker round will now give the usual  " .. ROUND_TOKENS .. "  tool tokens" )
		end
	end
	cvars.AddChangeCallback( "ttg_var_tiebreak_notokens", Callback_TiebreakTokens, "ttg_var_tiebreak_notokens_setting" )




	--Uneven Teams Handicap
	--Three separate levers for making a short handed team competitive, each one
	--scaling with how many players down they are. 0 turns a lever off, which is
	--why these accept 0 where the token setting above does not. All three apply
	--from the next round, since the handicap is worked out during round setup.
	if not ConVarExists( "ttg_var_balance_health" ) then
		CreateConVar( "ttg_var_balance_health", tostring( BALANCE_HEALTH_PER_PLAYER ), FCVAR_NOTIFY, "Extra max health for each player a team is short by" )
	end
	if not ConVarExists( "ttg_var_balance_tokens" ) then
		CreateConVar( "ttg_var_balance_tokens", tostring( BALANCE_TOKENS_PER_PLAYER ), FCVAR_NOTIFY, "Extra tool tokens for each player a team is short by" )
	end
	if not ConVarExists( "ttg_var_balance_nofirstaid" ) then
		CreateConVar( "ttg_var_balance_nofirstaid", "0", FCVAR_NOTIFY, "Stop the team with more players buying First Aid" )
	end

	local set_balhealth = GetConVarNumber( "ttg_var_balance_health" )
	if set_balhealth != nil and set_balhealth >= 0 then
		BALANCE_HEALTH_PER_PLAYER = set_balhealth
	end

	local set_baltokens = GetConVarNumber( "ttg_var_balance_tokens" )
	if set_baltokens != nil and set_baltokens >= 0 then
		BALANCE_TOKENS_PER_PLAYER = set_baltokens
	end

	BALANCE_NO_FIRSTAID = GetConVarNumber( "ttg_var_balance_nofirstaid" ) > 0


	local function Callback_BalanceHealth( CVar, PreviousValue, NewValue )
		local newvalue = tonumber( NewValue )
		if newvalue == nil or newvalue < 0 then return end

		BALANCE_HEALTH_PER_PLAYER = newvalue

		if newvalue == 0 then
			ChatPrintToAll( "Short handed teams will no longer get extra health" )
		else
			ChatPrintToAll( "Short handed teams now get  " .. newvalue .. "  extra max health per player they are down (applies next round)" )
		end
	end
	cvars.AddChangeCallback( "ttg_var_balance_health", Callback_BalanceHealth, "ttg_var_balance_health_setting" )


	local function Callback_BalanceTokens( CVar, PreviousValue, NewValue )
		local newvalue = tonumber( NewValue )
		if newvalue == nil or newvalue < 0 then return end

		BALANCE_TOKENS_PER_PLAYER = newvalue

		if newvalue == 0 then
			ChatPrintToAll( "Short handed teams will no longer get extra tool tokens" )
		else
			ChatPrintToAll( "Short handed teams now get  " .. newvalue .. "  extra tool tokens per player they are down (applies next round)" )
		end

		--every tool costs a token, and the bought list only has room for so many
		if ROUND_TOKENS + newvalue > MAX_TOOL_SLOTS then
			print( "TTG: a short handed player could reach " .. ( ROUND_TOKENS + newvalue ) ..
				" tokens but only " .. MAX_TOOL_SLOTS .. " tools can be listed - raise MAX_TOOL_SLOTS in shared_settings.lua" )
		end
	end
	cvars.AddChangeCallback( "ttg_var_balance_tokens", Callback_BalanceTokens, "ttg_var_balance_tokens_setting" )


	local function Callback_BalanceFirstAid( CVar, PreviousValue, NewValue )
		local newvalue = tonumber( NewValue )
		if newvalue == nil then return end

		BALANCE_NO_FIRSTAID = newvalue > 0

		if BALANCE_NO_FIRSTAID then
			ChatPrintToAll( "The team with more players can no longer buy First Aid (applies next round)" )
		else
			ChatPrintToAll( "First Aid is available to both teams again (applies next round)" )
		end
	end
	cvars.AddChangeCallback( "ttg_var_balance_nofirstaid", Callback_BalanceFirstAid, "ttg_var_balance_nofirstaid_setting" )
	
	
	
	
	
	
	
	
	--[[
	CreateConVar("ttg_var_devmode", GetConVarNumber( "default_ttg_devmode" ), FCVAR_NOTIFY, "Enables developers mode (allows you to start the game with 1 person, noclip, etc)")
	CreateConVar("ttg_var_rounds", GetConVarNumber( "default_ttg_rounds" ), FCVAR_NOTIFY, "Amount of rounds to play in one game")
	
	
	local function Callback_Devmode(CVar, PreviousValue, NewValue)
		if tonumber(NewValue) >= 1 then
			ChatPrintToAll( "Developer Mode turned ON! RESTARTING" )
			DEV_MODE = true
			GameRestart()
		elseif tonumber(NewValue) <= 0 then
			ChatPrintToAll( "Developer Mode turned OFF! RESTARTING" )
			DEV_MODE = false
			GameRestart()
		end
	end
	cvars.AddChangeCallback("ttg_var_devmode", Callback_Devmode)
	
	
	local function Callback_Rounds(CVar, PreviousValue, NewValue)
		ChatPrintToAll( "Number of rounds set to  " .. NewValue .. "  RESTARTING" )
		ROUNDS = tonumber(NewValue)
		GameRestart()
	end
	cvars.AddChangeCallback("ttg_var_rounds", Callback_Rounds)
]]--

end










if SERVER then
	print("Restarted!")
end







if DEV_MODE == true then
	if SERVER then
		print("This is Dev mode!")
	end
	
	--Makes it so the thing that ends the round based on if one of the teams is dead does not function
	END_ROUND_IF_ONE_TEAM_DEAD = false	//true

	CAN_NOCLIP = true
	
	--allows the game to start even if theres only one player on one of the two teams
	MUST_HAVE_ATEAST_1PLAYER_PERTEAM = false

	--buying phase times
	DEFENDERSBUYPHASE_TIME = 3000 //30
	ATTACKERSBUYPHASE_TIME = 3000 //30
	PLANNINGPHASE_TIME = 3		//10

	--other phase times
	SETUPPHASE_TIME = 40	//60
	COMBATPHASE_TIME = 500	//150
	WINNINGPHASE_TIME = 7

else

	--Makes it so the thing that ends the round based on if one of the teams is dead functions
	END_ROUND_IF_ONE_TEAM_DEAD = true	//true

	CAN_NOCLIP = false
	
	MUST_HAVE_ATEAST_1PLAYER_PERTEAM = true

	--buying phase times
	DEFENDERSBUYPHASE_TIME = 30 //30
	ATTACKERSBUYPHASE_TIME = 30 //30
	PLANNINGPHASE_TIME = 5		//10

	--other phase times
	SETUPPHASE_TIME = 45	//60
	COMBATPHASE_TIME = 180	//180
	WINNINGPHASE_TIME = 7

end





LIMBO_REVIVE_SOUND = Sound("buttons/button9.wav")
LIMBO_KILL_SOUND = Sound( "physics/flesh/flesh_squishy_impact_hard3.wav" )
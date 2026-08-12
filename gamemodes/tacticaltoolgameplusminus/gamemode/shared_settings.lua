/*---------------------------------------------------------
	Game Settings
---------------------------------------------------------*/


//makes it so people can join a team mid-game
PUB_MODE = false











BEGINNING_COUNTDOWN = 3		//seconds to countdown from when beginning the round once all players are ready
PLAYERS_PER_TEAM = 6		//amount of players per team
RESTRICT_PLAYERS_PER_TEAM = true



LIMBO_ENABLED = false

PLAYER_BASE_SPEED = 190
PLAYER_BASE_CROUCHMULTIPLIER = .6

PLAYER_BASE_SPEED_SETUP = 350
PLAYER_BASE_CROUCHMULTIPLIER_SETUP = .2


PLAYER_BASE_TANKSPEED = 150
PLAYER_BASE_JUMPPOWER = 240
PLAYER_BASE_MAXHEALTH = 100


VOTING_TIME = 30

BEGINNING_INVULN_TIME = 2

TIME_TO_CAPTURE = 30

ROUND_TOKENS = 4	//cant decide between 3 or 4



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
	local set_rounds = GetConVarNumber( "ttg_var_rounds" )
	if set_rounds <= 0 or set_rounds == nil then
		set_rounds = 4
	end
	ROUNDS = set_rounds
	
	--Developer mode
	//makes it so menus switch fast, noclip is enabled, the game doesnt end if one teams dead, etc
	local set_devmode = GetConVarNumber( "ttg_var_devmode" )
	if set_devmode <= 0 then
		DEV_MODE = false
	elseif set_devmode > 0 then
		DEV_MODE = true
	end
	
	
	
	
	
	
	
	
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
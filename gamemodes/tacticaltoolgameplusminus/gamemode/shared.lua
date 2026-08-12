GM.Name = "Tactical Tool Game"
GM.Author = "Sean 'Heyo' Cutino"
GM.Email = ""
GM.Website = ""



--Disable footsteps
	--[[
 function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf ) 

	--Dont disable local players footsteps ONLY
	if CLIENT then
		if ply == LocalPlayer() then
			return false
		end
	end

	
	//return true 
 end
]]--







/*---------------------------------------------------------
	Team Set Up and team methods
---------------------------------------------------------*/

TEAM_RED = 1
TEAM_BLUE = 2
TEAM_SPEC = 3
team.SetUp( TEAM_RED, "Red Team", Color( 255, 0, 0, 255 ), true )
team.SetUp( TEAM_BLUE, "Blue Team", Color( 0, 0, 255, 255 ), true )
team.SetUp( TEAM_SPEC, "Spectators", Color( 200, 200, 200, 255 ), true )



function SetTeamRole(teamnum, role)
	if teamnum == TEAM_BLUE then
		if role == "Attacking" then
			SetGlobalString("Blue_Role", "Attacking")
		elseif role == "Defending" then
			SetGlobalString("Blue_Role", "Defending")
		else
			print("Invalid role")
		end
	elseif teamnum == TEAM_RED then
		if role == "Attacking" then
			SetGlobalString("Red_Role", "Attacking")
		elseif role == "Defending" then
			SetGlobalString("Red_Role", "Defending")
		else
			print("Invalid role")
		end
	elseif teamnum == TEAM_SPEC then
		print("you shouldn't be setting the spectating team's role...")
	end
end


function GetTeamRole(teamnum)
	local role = nil 
	if teamnum == TEAM_BLUE then
		role = GetGlobalString("Blue_Role")
	elseif teamnum == TEAM_RED then
		role = GetGlobalString("Red_Role")	
	elseif teamnum == TEAM_SPEC then
		role = "Spectator"
	end
	
	
	if role == nil then 
		print("Team has no role!")
	end
	
	return role
end


function SetRound(num)
	SetGlobalInt("Round", num)
end

function GetRound()
	local round = GetGlobalInt("Round")
	return round
end

function ConvertToTeamName(num)
	local printname = "Invalid Team"

	if num == 1 then
		printname = "Team Red"
	elseif num == 2 then
		printname = "Team Blue"
	elseif num == 3 then
		printname = "Spectators"
	end
	
	return printname
end








/*---------------------------------------------------------
	Methods for setting information the client hud needs to get
---------------------------------------------------------*/

function SetMaxScore(num)
	SetGlobalInt("MaxScore", num)
end

function GetMaxScore()
	local maxscore = GetGlobalInt("MaxScore")
	return maxscore
end



function SetTotalRounds(num)
	SetGlobalInt("TotalRounds", num)
end

function GetTotalRounds()
	local num = GetGlobalInt("TotalRounds")
	return num
end

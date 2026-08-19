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



//Uses the Global2 ( NW2 ) functions rather than the legacy SetGlobalString.
//The legacy globals were not reaching remote clients promptly: the role text
//was correct for the listen server host, who reads the value in-process with no
//networking involved, while everyone else kept the previous round's role until
//some later global write happened to flush it. The buy phase writing
//CL_CurBuyingRole is what appeared to "fix" it, which is why the text only ever
//refreshed when the buying side switched.
//
//BroadcastTeamRoles() in ingame_functions.lua also pushes these over the net
//library at every point the roles can change, so a missed update self-corrects.
function SetTeamRole(teamnum, role)
	if teamnum == TEAM_BLUE then
		if role == "Attacking" then
			SetGlobal2String("Blue_Role", "Attacking")
		elseif role == "Defending" then
			SetGlobal2String("Blue_Role", "Defending")
		else
			print("Invalid role")
		end
	elseif teamnum == TEAM_RED then
		if role == "Attacking" then
			SetGlobal2String("Red_Role", "Attacking")
		elseif role == "Defending" then
			SetGlobal2String("Red_Role", "Defending")
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
		role = GetGlobal2String("Blue_Role")
	elseif teamnum == TEAM_RED then
		role = GetGlobal2String("Red_Role")
	elseif teamnum == TEAM_SPEC then
		role = "Spectator"
	end


	if role == nil then
		print("Team has no role!")
	end

	return role
end




/*---------------------------------------------------------
	Current phase, and whose turn it is to buy
---------------------------------------------------------*/

//Wrapped for the same reason the team roles were: these were written straight
//to legacy SetGlobalString from a dozen places, so they carried exactly the
//staleness that made the role text wrong for everyone except the listen server
//host. Going through a setter means the Global2 write and the explicit resend
//happen together and cannot be forgotten at a new call site.
//
//BroadcastGameState lives in ingame_functions.lua and is server-only, so the
//push is guarded - a client setting these only ever updates its own copy.

function SetGamePhase( phase )
	SetGlobal2String( "CL_CurPhase", phase )

	if SERVER then BroadcastGameState() end
end

function GetGamePhase()
	//callers compare against "" for "no phase yet", so never hand back nil
	return GetGlobal2String( "CL_CurPhase" ) or ""
end


function SetBuyingRole( role )
	SetGlobal2String( "CL_CurBuyingRole", role )

	if SERVER then BroadcastGameState() end
end

function GetBuyingRole()
	return GetGlobal2String( "CL_CurBuyingRole" ) or ""
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




/*---------------------------------------------------------
	Purchases withheld from a team
---------------------------------------------------------*/

--First Aid can be withheld from whichever team has the extra players, as one of
--the uneven team handicaps. The server decides per player and networks it,
--because the client cannot read the setting itself. TTG_HandicapNoFirstAid()
--in ingame_functions.lua is where the decision is made.
--
--Shared because both ends need it: the buy menu leaves a withheld purchase out
--of its list, and fGiveTool refuses it if the click gets through anyway.
function TTG_PurchaseBlocked( ply, purchasename )
	if not IsValid( ply ) then return false end
	if purchasename != "purchase_firstaid" then return false end

	return ply:GetNW2Bool( "TTG_NoFirstAid", false )
end

function GetTotalRounds()
	local num = GetGlobalInt("TotalRounds")
	return num
end

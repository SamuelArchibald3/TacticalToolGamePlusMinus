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
	How many ability slots are in play
---------------------------------------------------------*/

--MAX_ABILITY_SLOTS is set from a convar, and convars only exist on the server,
--so a client would always believe the shared default. The hud and the buy menu
--both need the real number, so it is networked.
function SetAbilitySlotCount( num )
	SetGlobal2Int( "TTG_AbilitySlots", num )
end

--Falls back to the shared default, which covers the moment before the first
--push and anywhere the count was never set.
function TTG_AbilitySlotCount()
	local num = GetGlobal2Int( "TTG_AbilitySlots", 0 )

	if num == nil or num < 1 then
		return MAX_ABILITY_SLOTS
	end

	return num
end


--What key this player has for an ability slot, as they would recognise it.
--
--The labels in ABILITY_KEYS used to be printed straight onto the hud, so
--somebody who moved +speed off shift in the options menu was still told to press
--shift. This asks the client's own binding instead, and only falls back to the
--table when there is nothing bound at all - which is the honest answer for the
--two additions that ship unbound.
--
--CLIENT only: the input library does not exist on the server, which is also why
--the swap command names slots rather than keys.
if CLIENT then
	function TTG_AbilityKeyLabel( slot )
		local entry = ABILITY_KEYS[ slot ]
		if entry == nil then return "?" end

		local bound = input.LookupBinding( entry.command )
		if bound != nil and bound != "" then return string.upper( bound ) end

		return "UNBOUND"
	end
end


--Whether the Radar should mark this candidate on viewingTeam's hud.
--
--Pulled out of cl_init.lua's two nearly-identical reveal loops (your own
--team's view and the spectator view, which only ever differed in how
--viewingTeam was worked out) so the decision has one shape and can be tested
--from here rather than only from the draw loop that calls it.
--
--Distance used to be part of this - a candidate only counted within
--ent_revealer.radius of the device. The Radar is map-wide now, so there is no
--position check left: this is purely about the candidate, not where any
--revealer happens to be standing.
function TTG_RevealerCanSee( candidate, viewingTeam )
	return candidate:IsValidGamePlayer()
		and not candidate:GetIfInvisible()
		and candidate:HowManyOfThisBuff( "Buff_BarrelDisguise" ) == 0
		and candidate:Team() != viewingTeam
end




/*---------------------------------------------------------
	Purchases withheld from a team
---------------------------------------------------------*/

--How many different tools a player may carry.
--
--Networked for the same reason the ability count is: it comes from a convar,
--convars only exist on the server, and the two things that need it - the buy
--menu and the weapon selector - are both client side. Falls back to the shared
--default, which covers the moment before the first push.
function SetDifferentToolCount( num )
	SetGlobal2Int( "TTG_DifferentTools", num )
end

function TTG_DifferentToolCount()
	local num = GetGlobal2Int( "TTG_DifferentTools", 0 )

	if num == nil or num < 1 then
		return MAX_DIFFERENT_TOOLS
	end

	return num
end


--How many of this purchase a team already has between them.
--
--Counted from what the players are actually carrying rather than from a tally
--of what was bought. Nothing has to be reset between rounds that way - tools
--and abilities are cleared along with everything else, so the count falls back
--to zero on its own - and it self-corrects if somebody disconnects.
--
--Both accessors read the broadcast copy for other players rather than their
--networked vars, so the buy menu can ask exactly the same question the server
--does. See the note above TTG_SendPlayerLists for why that distinction exists.
function TTG_TeamPurchaseCount( teamid, purchasename )
	local purchase = Shop_Reference( purchasename )
	if purchase == nil then return 0 end

	local count = 0

	for _, ply in pairs( player.GetAll() ) do
		if ply:Team() != teamid then continue end

		if purchase.class == "ability" then
			for _, name in pairs( ply:GetAbilityNames() ) do
				if name == purchase.tool_name then count = count + 1 end
			end
		else
			for _, tool in pairs( ply:GetSwepToolInfo() or {} ) do
				if tool.name == purchase.tool_name then count = count + 1 end
			end
		end
	end

	return count
end


--Whether this purchase is off limits to this player right now, and why.
--
--Returns the reason as a second value so a new rule does not mean editing the
--message at the call site. Callers that only want the yes or no can carry on
--reading it as a plain boolean.
--
--Shared because both ends need it: the buy menu leaves a blocked purchase out
--of its list, and fGiveTool refuses it if the click gets through anyway.
--
--Two rules so far.
--
--First Aid can be withheld from whichever team has the extra players, as one
--of the uneven team handicaps. The server decides per player and networks it,
--because the client cannot read the setting itself. TTG_HandicapNoFirstAid()
--in ingame_functions.lua is where that decision is made.
--
--And any purchase can cap how many one team may hold at once by declaring
--team_limit in table_shop.lua. That is the whole of opting in - nothing here
--or in the buy menu names a particular purchase.
function TTG_PurchaseBlocked( ply, purchasename )
	if not IsValid( ply ) then return false end

	if purchasename == "purchase_firstaid" and ply:GetNW2Bool( "TTG_NoFirstAid", false ) then
		return true, "Your team has the extra players, so First Aid is not available"
	end

	local purchase = Shop_Reference( purchasename )

	--One tool too many is one with no number key to reach it - the weapon
	--selector answers to slot1 through slot6 and swallows the rest, and the
	--melee already has the first of those, so it would be sold as something
	--only scrolling can find.
	--
	--Owning it already is always fine. That is ammo going into a bucket that
	--exists rather than a new key to look for, which is why this counts what
	--is carried instead of what has been spent.
	if purchase != nil and purchase.class != "ability" then
		local carried = 0
		local already = false

		for _, tool in pairs( ply:GetSwepToolInfo() or {} ) do
			carried = carried + 1

			if tool.name == purchase.tool_name then already = true end
		end

		if not already and carried >= TTG_DifferentToolCount() then
			return true, "You can carry " .. TTG_DifferentToolCount() ..
				" different tools - buy more of one you already have instead"
		end
	end

	if purchase != nil and purchase.team_limit != nil then
		if TTG_TeamPurchaseCount( ply:Team(), purchasename ) >= purchase.team_limit then
			return true, "Your team is limited to " .. purchase.team_limit .. " " ..
				purchase.print_name .. " and already has that many"
		end
	end

	return false
end

function GetTotalRounds()
	local num = GetGlobalInt("TotalRounds")
	return num
end

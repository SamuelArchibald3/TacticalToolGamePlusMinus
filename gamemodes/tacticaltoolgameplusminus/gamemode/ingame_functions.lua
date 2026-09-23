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
	Aiming at a player
---------------------------------------------------------*/

//Where to aim at, or trace to, when something wants to hit a player.
//
//Measured as a fraction of the target's CURRENT collision hull rather than a
//fixed height off the floor. A standing player is 72 units tall and a crouched
//one is 36, so an offset picked to hit a standing chest sails straight over a
//crouched head. That is what made crouching a complete counter to sentries: the
//sight trace missed, so the target was never acquired, was dropped the moment
//they crouched, and would have been shot over anyway.
//
//A fraction keeps the point tied to the hull, so it follows a player down as
//they crouch, while still letting each weapon pick where it aims - .5 is the
//waist, .7 is about the chest. Sentries pass their aim_height from table_ent.
//
//Deliberately NOT a bone lookup. Source traces a player as a box, so the aim
//point has to stay inside that box: a bone follows the animation and can sit
//outside it, which would miss the hull entirely and bring the original bug
//back through a different door. The clamp keeps a mistuned aim_height inside
//the hull for the same reason.
//
//Callers must have checked IsValid first.
local AIM_HEIGHT_DEFAULT = 0.7

function TTG_AimPointFor( ent, fraction )
	fraction = math.Clamp( fraction or AIM_HEIGHT_DEFAULT, 0.05, 0.95 )

	local mins = ent:OBBMins()
	local maxs = ent:OBBMaxs()
	local height = maxs.z - mins.z

	return ent:GetPos() + Vector( 0, 0, mins.z + height * fraction )
end



/*---------------------------------------------------------
	Winning the game
---------------------------------------------------------*/

//Returns the team with enough points to win the game outright, or nil if
//neither has yet.
//
//One place for the rule, because the two callers had already drifted apart:
//EndRound compared against G_MaxScore while NextRound had "> 2" written into it.
//G_MaxScore is ( G_TotalRounds/2 + 1 ), so from 6 rounds up the two disagreed -
//the real target was 4 or more while NextRound ended the game at 3, restarting
//before anyone could reach it and making the rounds setting look like it did
//nothing at all.
//
//G_MaxScore is 0 until BeginGame() sets it, so it is only trusted once positive.
//Without that guard every score would count as a win before the game starts.
function TTG_TeamThatHasWon()
	if not G_MaxScore or G_MaxScore <= 0 then return nil end

	if team.GetScore( TEAM_RED ) >= G_MaxScore then
		return TEAM_RED
	elseif team.GetScore( TEAM_BLUE ) >= G_MaxScore then
		return TEAM_BLUE
	end

	return nil
end



/*---------------------------------------------------------
	Team roles - explicit push to clients
---------------------------------------------------------*/

util.AddNetworkString( "TTG_TeamRoles" )
util.AddNetworkString( "TTG_GameState" )

//Pushes the current phase and whose turn it is to buy to every client.
//
//Called automatically by SetGamePhase( ) and SetBuyingRole( ) in shared.lua, so
//every phase change resends both. Same reasoning as BroadcastTeamRoles: the
//networked global alone left remote clients a phase behind while the listen
//server host was always correct, because the host reads the value in-process.
function BroadcastGameState()
	net.Start( "TTG_GameState" )
		net.WriteString( GetGamePhase() )
		net.WriteString( GetBuyingRole() )
	net.Broadcast()
end

//Pushes the current team roles to every client over the net library.
//
//The roles already live in Global2 vars, which network on their own. This is a
//belt and braces resend for the case that made the roles look broken: the text
//was right for the listen server host ( who reads the value in-process ) while
//remote clients sat on the previous round's role until some unrelated global
//write flushed it. net messages are reliable and ordered, so calling this at
//every point the roles can change means a client cannot be left showing a stale
//role for a whole phase.
function BroadcastTeamRoles()
	net.Start( "TTG_TeamRoles" )
		net.WriteString( GetTeamRole( TEAM_RED )  or "" )
		net.WriteString( GetTeamRole( TEAM_BLUE ) or "" )
	net.Broadcast()
end



/*---------------------------------------------------------
	Uneven team handicap
---------------------------------------------------------*/

//Teams are not always even - somebody leaves, or there is an odd number of
//players in the lobby. These give the short handed side something back for it.
//
//Everything scales off one number, how badly a team is outnumbered, so no lever
//has to work that out for itself.


//How a team compares to the other one in player count. Positive when it has
//spare players, negative when it is short handed, 0 when they are level.
//Spectators are on neither team, so they do not count either way.
function TTG_TeamNumberEdge( teamnum )
	local red  = team.NumPlayers( TEAM_RED )
	local blue = team.NumPlayers( TEAM_BLUE )

	if teamnum == TEAM_RED then
		return red - blue
	elseif teamnum == TEAM_BLUE then
		return blue - red
	end

	//spectators, and anything else that is not a playing team
	return 0
end


//How badly a team is outnumbered, as a fraction of its own size. 0 when the
//teams are level or it has the extra players.
//
//A ratio rather than the plain difference, because the difference is a bad
//measure of how hard the fight is: 1v2 and 3v4 are both one player apart, but
//the 1v2 player faces twice the opposition while the 3v4 player faces a third
//more again. Handing them the same bonus was wrong.
//
//	1v2  ->  1.0     twice the numbers
//	2v3  ->  0.5
//	3v4  ->  0.333
//	1v3  ->  2.0     three times the numbers
function TTG_TeamOutnumberedBy( teamnum )
	local mine, theirs = team.NumPlayers( TEAM_RED ), team.NumPlayers( TEAM_BLUE )

	if teamnum == TEAM_BLUE then
		mine, theirs = theirs, mine
	elseif teamnum != TEAM_RED then
		//spectators, and anything else that is not a playing team
		return 0
	end

	//an empty team cannot be handicapped, and dividing by it would be an error
	//rather than an enormous bonus
	if mine <= 0 then return 0 end
	if theirs <= mine then return 0 end

	return ( theirs / mine ) - 1
end


//The same for one player, which is how every lever below asks
function TTG_PlayerOutnumberedBy( ply )
	if not IsValid( ply ) then return 0 end

	return TTG_TeamOutnumberedBy( ply:Team() )
end


//Extra max health for an outnumbered player. Applied in SetSpawnStuff().
//
//Snapped to the nearest whole BALANCE_HEALTH_STEP, which is one melee hit at 20
//damage. Health that does not land on a multiple of that buys nothing against
//the weapon everybody carries: 33 extra health takes the same two melee hits to
//chew through as 20 does, so it may as well be 20 and read honestly on the bar.
//
//With the setting at its default of 40, that works out as
//	1v2  ->  40    two extra melee hits
//	2v3  ->  20
//	3v4  ->  20
//	5v6  ->   0    too close to matter
function TTG_HandicapHealth( ply )
	if BALANCE_ENABLED != true then return 0 end
	if BALANCE_HEALTH_OUTNUMBERED <= 0 then return 0 end

	local raw = TTG_PlayerOutnumberedBy( ply ) * BALANCE_HEALTH_OUTNUMBERED

	//a step of 0 would divide by zero, so fall back to no rounding at all
	if BALANCE_HEALTH_STEP == nil or BALANCE_HEALTH_STEP <= 0 then
		return math.Round( raw )
	end

	return math.Round( raw / BALANCE_HEALTH_STEP ) * BALANCE_HEALTH_STEP
end


//Extra tool tokens for an outnumbered player. Applied through
//TTG_RoundStartTokens(), so it lands wherever tokens are handed out.
//
//Rounded, like the health lever above. This was floored, on the reasoning that a
//token is a whole extra tool and should take a real imbalance to earn - but the
//floor was throwing away most of a token it had already worked for, and in one
//case a whole one it had:
//
//	( 4/3 ) - 1  is 0.33333333333333326, times 3 is 0.9999999999999998
//
//so a 3v4 earned nothing at all, a hair under the one token the arithmetic says
//it is owed. Nobody chose that, and no setting can express it.
//
//At the shipped setting of 3 the rounding gives
//	1v2  ->  3
//	2v3  ->  2     was 1
//	3v4  ->  1     was 0
//	5v6  ->  1     was 0
//which does mean a one-player gap is now worth a token at any team size.
function TTG_HandicapTokens( ply )
	if BALANCE_ENABLED != true then return 0 end
	if BALANCE_TOKENS_OUTNUMBERED <= 0 then return 0 end

	local bonus = math.Round( TTG_PlayerOutnumberedBy( ply ) * BALANCE_TOKENS_OUTNUMBERED )

	//A lopsided enough game scales past what the bought list can show: at a
	//setting of 3, a 1v4 earns 9 on top of the usual 4, and only MAX_TOOL_SLOTS
	//of them can be listed. A tool that is bought and usable but missing from
	//the list is exactly the bug MAX_TOOL_SLOTS was raised to fix, so cap it.
	local room = math.max( MAX_TOOL_SLOTS - ROUND_TOKENS, 0 )

	return math.min( bonus, room )
end


//True if this player is on the bigger team while First Aid is being withheld
//from it.
function TTG_HandicapNoFirstAid( ply )
	if BALANCE_ENABLED != true then return false end
	if BALANCE_NO_FIRSTAID != true then return false end
	if not IsValid( ply ) then return false end

	return TTG_TeamNumberEdge( ply:Team() ) > 0
end


//Networks the First Aid lock to each player and says out loud what the uneven
//teams are worth this round. Called once during round setup.
//
//The buy menu reads the networked flag when it builds its list, so a locked out
//team never sees First Aid in the first place. That is the nice version rather
//than the reliable one - a client could build the menu before the flag reaches
//it - so fGiveTool refuses the purchase as well, and that is the authority.
function TTG_ApplyHandicaps()

	for k,ply in pairs(player.GetAll()) do
		ply:SetNW2Bool( "TTG_NoFirstAid", TTG_HandicapNoFirstAid( ply ) )
	end

	local red  = team.NumPlayers( TEAM_RED )
	local blue = team.NumPlayers( TEAM_BLUE )
	if red == blue then return end

	local shortteam, bigteam = TEAM_RED, TEAM_BLUE
	if blue < red then
		shortteam, bigteam = TEAM_BLUE, TEAM_RED
	end

	//ask for one of them, so the numbers announced are the ones players get
	local sample = team.GetPlayers( shortteam )[ 1 ]

	//built up as a list so the line reads properly with one lever on or both
	local gains = {}

	local bonushealth = TTG_HandicapHealth( sample )
	if bonushealth > 0 then
		table.insert( gains, "+" .. bonushealth .. " max health" )
	end

	local bonustokens = TTG_HandicapTokens( sample )
	if bonustokens > 0 then
		table.insert( gains, "+" .. bonustokens .. " tool tokens" )
	end

	if table.Count( gains ) > 0 then
		ChatPrintToAll( ConvertToTeamName( shortteam ) .. " are outnumbered " ..
			math.min( red, blue ) .. " to " .. math.max( red, blue ) ..
			", so they get  " .. table.concat( gains, " and " ) )
	end

	//asked of a real player rather than read off the setting, so this can only
	//say First Aid was withheld in the cases where it actually was
	if TTG_HandicapNoFirstAid( team.GetPlayers( bigteam )[ 1 ] ) then
		ChatPrintToAll( ConvertToTeamName( bigteam ) .. " have the extra players, so no First Aid for them this round" )
	end
end




/*---------------------------------------------------------
	The tie breaker round
---------------------------------------------------------*/

//The decider, played when the teams finish level. It is the round after the
//last normal one.
//
//Four separate rules now key off this - no tokens, random roles, no setup
//phase, no invulnerability - so the comparison lives here rather than being
//written out at each one. Four copies of a condition is how DEBT-1 started.
function TTG_IsTiebreakRound()
	return G_CurRound == G_TotalRounds + 1
end




/*---------------------------------------------------------
	Tokens for the round
---------------------------------------------------------*/

//How many tool tokens a player should start the current round with.
//
//This lives in one place on purpose: the round-setup block is copy-pasted in
//three spots ( gamesetup.lua for the first round, and twice in ingame.lua for
//every round after ), so any rule about token amounts has to be shared or the
//copies drift apart.
//ply is optional. Without one this is just the amount a player on an even team
//gets, which is what the tie breaker rule and the settings tests care about.
function TTG_RoundStartTokens( ply )

	//the tie breaker is the round after the last normal one. If the setting is
	//on, it is played out with whatever you can already carry - no purchases.
	if TIEBREAK_NO_TOKENS == true and TTG_IsTiebreakRound() then
		return 0
	end

	return ROUND_TOKENS + TTG_HandicapTokens( ply )
end



/*---------------------------------------------------------
	Derma panel opening stuff
---------------------------------------------------------*/

function Open_BuyingMenus()
	for k,ply in pairs(player.GetAll()) do

		if ply:Team() != TEAM_SPEC then

			//no point showing the buy menu to someone with no tokens - every
			//purchase would just be refused. The team purchases panel still
			//opens so they can watch what their team is buying.
			if ply:GetToolTokens() > 0 then
				umsg.Start("Open_BuyingVgui", ply)
				umsg.End()
			end

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

--Shuts the ability keys panel for one player, and remembers that it is shut.
function Close_AbilityKeysForPly( ply )
	umsg.Start("Close_AbilityKeysVgui", ply)
	umsg.End()

	ply.AbilityKeysMenuIsOpen = false
end


--Shuts it for everybody. Called when combat starts: the panel turns on the
--screen clicker, so leaving it open would hand somebody a cursor instead of a
--crosshair for the round.
function Close_AbilityKeysMenus()
	for k,ply in pairs(player.GetAll()) do
		Close_AbilityKeysForPly( ply )
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
	Rewind
---------------------------------------------------------*/

--The Rewind ability sends every living player back along the path they walked,
--to where they were three seconds ago. The buffer that makes that possible
--lives on the players themselves (metaplayer_rewind.lua); this is the hook that
--fills it and the playback that empties it.
--
--Combat only. An always-on sampler would be recording positions inside the buy
--rooms and behind spawn doors, and a stored history of those is one guard bug
--away from teleporting somebody through the map.

--{ start, cutoff, targets = { { ply, index }, ... } } while a rewind is
--playing back.
G_RewindPlayback = nil

local RewindNextSample = 0


/*---------------------------------------------------------
	What the map looked like
---------------------------------------------------------*/

--The buildings are world state rather than anybody's state, so they get their
--own ring rather than riding along in each player's. It is read once per
--rewind, not once per player.
--
--Recorded per entity: where it was, how hurt it was, and enough to build it
--again from nothing if it has since been destroyed.
local RewindWorld = {}
local RewindWorldHead = 0
local RewindWorldCount = 0


function TTG_RewindWorldReset()
	RewindWorld = {}
	RewindWorldHead = 0
	RewindWorldCount = 0
end


function TTG_RewindWorldSnapshot()
	local out = {}

	for _, ent in pairs( ents.GetAll() ) do
		if not IsValid( ent ) then continue end

		--ENT_TABLE is keyed by class, so this is the same question
		--CheckIfInEntTable answers but as one lookup rather than a scan of all
		--29 entries. It is asked of every entity on the map ten times a second,
		--which is the only part of the recording big enough to be worth caring
		--about - everything else in here runs once per snapshot.
		if ENT_TABLE[ ent:GetClass() ] == nil then continue end

		--an unbuilt one is a projectile still in the air, so it is carrying a
		--throw that has to come back with it
		local vel = nil
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then vel = phys:GetVelocity() end

		out[ ent:EntIndex() ] = {
			class = ent:GetClass(),
			pos = ent:GetPos(),
			ang = ent:GetAngles(),
			vel = vel,
			health = ent:Health(),
			built = ent:IsBuilt(),
			team = ent.TTG_Team,
			creator = ent.Creator,
			swep = ent.CreatorSwep,
			thrownangles = ent.TTG_Angles,
			createdat = ent:CreatedAt(),
			buildargs = ent.TTG_BuildArgs,
			buildcount = ent.TTG_BuildArgCount,
		}
	end

	return out
end


local function RewindWorldPush()
	local size = TTG_RewindBufferSize()
	local head = ( RewindWorldHead % size ) + 1

	RewindWorld[ head ] = {
		t = CurTime(),
		ents = TTG_RewindWorldSnapshot(),
		capture = TTG_CaptureProgress(),
	}
	RewindWorldHead = head

	if RewindWorldCount < size then
		RewindWorldCount = RewindWorldCount + 1
	end
end


--Same shape as the players' RewindSampleAt, and nil for the same reason: the
--buffer does not reach that far back yet.
local function RewindWorldAt( time )
	local size = TTG_RewindBufferSize()

	for step = 0, RewindWorldCount - 1 do
		local index = ( ( RewindWorldHead - step - 1 ) % size ) + 1
		local snap = RewindWorld[ index ]

		if snap != nil and snap.t <= time then return snap end
	end

	return nil
end


--Damage on these reads as the entity going darker, and that colour is only
--recomputed when damage lands - so healing one without this leaves a building
--at full health still looking wrecked.
local function PutEntBack( ent, was )
	ent:SetPos( was.pos )
	ent:SetAngles( was.ang )

	--the throw it was carrying, not a standstill. Zeroing it would leave
	--something that was mid-air three seconds ago hanging there and then
	--dropping straight down instead of finishing its arc.
	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetVelocity( was.vel or vector_origin )
	end

	if ent:Health() != was.health then
		ent:SetHealth( was.health )
		ent:InitializeColor()
	end
end


--Build one again from nothing, for something destroyed inside the window.
--
--Same order a thrown entity is created in, then the build is replayed through
--ObjToMachine with the arguments the original collision passed it. What is not
--reconstructed is whatever the entity was privately doing - a sentry's current
--target, a quickport's partner, a countdown part way through. It comes back
--built, where it was, as hurt as it was.
local function RebuildEnt( was )
	local ent = ents.Create( was.class )
	if not IsValid( ent ) then return end

	ent:SetPos( was.pos )
	ent:SetAngles( was.ang )

	ent.TTG_Team = was.team
	ent.Creator = was.creator
	ent.CreatorSwep = was.swep

	--it answers for the age of the thing it replaces, not its own, or the next
	--rewind would take it back off as something built since
	ent.TTG_RewoundCreation = was.createdat

	if IsValid( was.creator ) then ent:SetOwner( was.creator ) end

	ent:Spawn()
	ent:SetEntTeamForClient()

	--After Spawn, which is where every one of the fourteen creation sites puts
	--it. ent_barrier reads it inside ObjToMachine, so a rebuilt one without it
	--errors on its way to being built and lies there as a grenade for the rest
	--of the round - which is what this looked like in play.
	--
	--Falls back to the angles it was sitting at, so a snapshot without them
	--builds crooked rather than not at all.
	ent.TTG_Angles = was.thrownangles or was.ang

	if was.built == true then
		if was.buildargs != nil then
			ent:ObjToMachine( unpack( was.buildargs, 1, was.buildcount or 0 ) )
		else
			ent:ObjToMachine()
		end

		--ObjToMachine sets its own position, the same way BuildFromCollision
		--puts the impact point back afterwards
		ent:SetPos( was.pos )

	elseif was.vel != nil then
		--still a projectile at that point, so it goes back in the air carrying
		--the throw rather than being dropped on the spot
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then phys:SetVelocity( was.vel ) end
	end

	ent:SetHealth( was.health )
	ent:InitializeColor()
end


function TTG_RewindRestoreWorld( snapshot )
	if snapshot == nil then return end

	--How far along the point was. Without this the clock going back while the
	--capture stayed where it was would hand the defenders time and the
	--attackers nothing, which is the opposite of what a rewind is for.
	TTG_RestoreCaptureProgress( snapshot.capture )

	local standing = {}

	for _, ent in pairs( ents.GetAll() ) do
		if IsValid( ent ) and ENT_TABLE[ ent:GetClass() ] != nil then
			standing[ ent:EntIndex() ] = ent
		end
	end

	for index, was in pairs( snapshot.ents ) do
		local ent = standing[ index ]

		--The index alone is not enough: the engine reuses them, so something
		--else may be sitting on it by now.
		--
		--Nor is the class. Something that was still a projectile in the air
		--three seconds ago and has landed and built since cannot be patched
		--back into a projectile - there is no undoing ObjToMachine - so it is
		--taken down and thrown again from the snapshot. Otherwise a finished
		--building teleports back to a point in mid-air and stays built, which
		--is the one thing this can do that looks like a glitch rather than a
		--rewind.
		local matches = IsValid( ent )
			and ent:GetClass() == was.class
			and ent:IsBuilt() == ( was.built == true )

		if matches then
			PutEntBack( ent, was )
		else
			if IsValid( ent ) then ent:Remove() end

			RebuildEnt( was )
		end
	end
end


--One hook, two modes. Sampling has to stop while a playback runs or the rewind
--records itself as history, and a branch here is easier to keep honest than a
--second hook to add and remove in step with this one.
function RewindSampler()
	if G_RewindPlayback != nil then
		return StepRewindPlayback()
	end

	if CurTime() < RewindNextSample then return end
	RewindNextSample = CurTime() + TOOL_TABLE.tool_abil_rewind.sample_interval

	for _, ply in pairs( player.GetAll() ) do
		if ply:IsValidGamePlayer() then
			ply:RewindPush( ply:RewindSampleNow() )
		end
	end

	RewindWorldPush()
end


--Nothing to record for if nobody bought one.
--
--Asked server side, from the ability entities themselves, rather than through
--the networked view - this decides whether the recording runs at all, so it
--should not depend on anything having reached a client.
function TTG_AnybodyHasRewind()
	for _, ply in pairs( player.GetAll() ) do
		for _, abil in pairs( ply:GetAbilitySlots() ) do
			if IsValid( abil ) and abil:GetClass() == "tool_abil_rewind" then
				return true
			end
		end
	end

	return false
end


--Asked once here rather than every tick, because it cannot change underneath
--us: buying only happens in the buy phases, and those are over before Combat
--starts. The one thing that can change it mid-round is somebody dying and
--losing theirs, which is not worth tearing the recording down for while their
--team mates still hold one.
function Start_RewindSampler()
	RewindNextSample = 0
	TTG_RewindWorldReset()

	if not TTG_AnybodyHasRewind() then return end

	hook.Add( "Think", "TTG_RewindSampler", RewindSampler )
end


function End_RewindSampler()
	hook.Remove( "Think", "TTG_RewindSampler" )
	TTG_RewindWorldReset()

	--a playback in flight has everybody frozen. Dropping the hook without
	--unfreezing them leaves the whole server stuck mid-rewind.
	if G_RewindPlayback == nil then return end

	for _, target in pairs( G_RewindPlayback.targets ) do
		if IsValid( target.ply ) then target.ply:RewindAbandonPlayback() end
	end

	G_RewindPlayback = nil
end


--Where everybody is going, decided in one pass before anything moves.
--
--nil means refuse the whole ability rather than move some of them. Partial
--application produces states a rewind should never produce - B left standing
--inside where A used to be - and a rewind that covers 0.4 seconds one time and
--3 the next reads as broken rather than as a rule.
--
--In practice the only thing that returns nil is the first few seconds of
--Combat, uniformly for everyone: PUB_MODE is off and SetSpawnStuff is only
--called from NextRound, so nobody spawns alive mid-round and everybody's buffer
--is exactly as deep as the round is old. If mid-round joining is ever wired up,
--this is one of the places that assumes it cannot happen.
function TTG_RewindTargets()
	local cutoff = CurTime() - TOOL_TABLE.tool_abil_rewind.duration
	local targets = {}

	for _, ply in pairs( player.GetAll() ) do
		--Anybody killed inside the window comes back with everybody else. They
		--stopped being sampled the moment they died, so their buffer already
		--holds exactly the living state to put them back into.
		local revive = ply:RewindDiedWithin( cutoff )

		if ply:IsValidGamePlayer() or revive then
			local index, sample = ply:RewindSampleAt( cutoff )
			if index == nil then return nil end

			--walk back toward the present until the destination is somewhere
			--they actually fit. Terminates at the head, which is roughly where
			--they are standing now, so the worst case is that one player does
			--not move.
			while not ply:RewindCanFit( sample.pos ) do
				local newer_index, newer = ply:RewindSampleNewer( index )
				if newer == nil then break end

				index, sample = newer_index, newer
			end

			table.insert( targets, { ply = ply, index = index, revive = revive } )
		end
	end

	if #targets == 0 then return nil end

	return targets
end


--true if the rewind started. false is a refusal, and the ability charges no
--cooldown for one.
function TTG_RewindAllPlayers( instigator )
	--two playbacks at once would be lerping the same players toward different
	--destinations on the same Think
	if G_RewindPlayback != nil then return false end

	local targets = TTG_RewindTargets()
	if targets == nil then return false end

	for _, target in pairs( targets ) do
		--on their feet before the playback rather than at the end of it, so a
		--revived player gets up where they fell and walks the same path back as
		--everybody else instead of appearing at the destination
		if target.revive then
			target.ply:RewindRevive( target.ply.RewindBuffer[ target.index ] )
		end

		target.ply:RewindBeginPlayback( target.index )
	end

	--the cutoff is kept rather than recomputed at the end, so the buildings go
	--back to the same moment the players do rather than to 0.6 seconds later
	G_RewindPlayback = {
		start = CurTime(),
		cutoff = CurTime() - TOOL_TABLE.tool_abil_rewind.duration,
		targets = targets,
	}

	--the animation shows what happened, but only a chat line says who did it
	if IsValid( instigator ) then
		ChatPrintToAll( instigator:Name() .. " rewound time!" )
	end

	umsg.Start( "Sound_Rewind" )
	umsg.End()

	return true
end


function StepRewindPlayback()
	local playback = G_RewindPlayback
	local progress = ( CurTime() - playback.start ) / TOOL_TABLE.tool_abil_rewind.playback_time

	if progress >= 1 then
		return TTG_RewindFinish()
	end

	for _, target in pairs( playback.targets ) do
		if IsValid( target.ply ) then
			target.ply:RewindStepPlayback( progress )
		end
	end
end


function TTG_RewindFinish()
	local playback = G_RewindPlayback
	if playback == nil then return end

	G_RewindPlayback = nil

	for _, target in pairs( playback.targets ) do
		local ply = target.ply
		if not IsValid( ply ) then continue end

		--somebody shot them during the playback. They are not invulnerable
		--through it, deliberately - leave them where they fell rather than
		--teleporting and healing a corpse.
		if ply:IsValidGamePlayer() then
			ply:RewindFinishPlayback()
		else
			ply:RewindAbandonPlayback()
		end
	end

	--after the players, because their own un-throwing takes back what they
	--deployed since - anything older than that is what this puts back
	TTG_RewindRestoreWorld( RewindWorldAt( playback.cutoff ) )

	--The round gets its time back too, or a rewind hands everybody their
	--position and health back while quietly costing the attackers the seconds
	--of clock they need to use them in.
	--
	--The playback is included. It is the ability showing its work rather than
	--time anybody got to play in - everyone is frozen throughout it - so
	--charging the round for it would be charging for the animation.
	local ref = TOOL_TABLE.tool_abil_rewind
	TTG_RewindGameTime( ref.duration + ref.playback_time )

	--the zone tracks who is on it with StartTouch and EndTouch, and neither
	--fires reliably when a player is teleported. Left alone, a defender rewound
	--off the point keeps contesting it forever and the attackers can never cap.
	if IsValid( G_CurAttackZone ) then
		G_CurAttackZone:RebuildTouchList()
	end

	--Last, so an ability working out what it should be now is looking at a
	--world that has already been put back: its buff restored, its port either
	--still standing or taken off the map. Most have nothing to do here - it is
	--the ones holding a step or a flag of their own that a rewind can leave
	--pointing at something that is no longer there.
	for _, ply in pairs( player.GetAll() ) do
		for _, abil in pairs( ply:GetAbilitySlots() ) do
			if IsValid( abil ) then abil:RewindReset() end
		end
	end
end












/*---------------------------------------------------------
	Resetting stuff
---------------------------------------------------------*/

//reset the player's ability slots, so the ents are destroyed
function Reset_PlyAbilities( ply )
	//IsValid( ) rather than != nil - the ent may already be gone, and calling
	//:Remove() on a NULL entity errors. The slot gets cleared either way.
	//
	//Emptied rather than replaced with a fresh table, so anything holding a
	//reference to the slots table is looking at the same one afterwards.
	local slots = ply:GetAbilitySlots()

	for i, abil in pairs( slots ) do
		if IsValid( abil ) then
			abil:Remove()
		end
		slots[ i ] = nil
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

		//forget where they walked last round, so a Rewind early next round
		//cannot send anybody back to a position from before the reset
		v:RewindBufferReset()

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


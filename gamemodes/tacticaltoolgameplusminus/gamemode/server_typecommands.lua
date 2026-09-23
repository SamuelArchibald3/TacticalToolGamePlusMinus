/*---------------------------------------------------------
	commands players can type in chat to initiate votes
---------------------------------------------------------*/



util.AddNetworkString( "TTG_MapBallot" )



/*---------------------------------------------------------
	Vote Kick
---------------------------------------------------------*/

G_VoteInProgress = false
local VoteDirective = nil
local VoteSuccess = false
local VoteCancelled = false
local VotesMin = 0

--how long after a map vote is decided before the map changes, or its runoff
--starts: long enough to read the result in chat
MAP_VOTE_DELAY = 3



/*---------------------------------------------------------
	Map vote: most votes wins, a tie goes to a runoff
---------------------------------------------------------*/

--It used to take more than 60% of everybody on the server, checked every tick,
--and a vote that nobody's choice reached that "failed" at the timeout however
--clear the favourite was. Now the vote runs until everybody has voted or the
--time is up, and then the map with the most votes wins. A tie at the top goes
--to a runoff between the tied maps, and nothing else.

local MapBallot = {}            --what this vote offers, in the order it lists them
local MapRunoff = false


function TTG_MapBallot()
	return table.Copy( MapBallot )
end

function TTG_MapVoteIsRunoff()
	return MapRunoff
end

--Only what is on this ballot can be voted for. A runoff offers fewer maps than
--the vote before it, and a client can send any name it likes.
function TTG_OnMapBallot( name )
	return table.HasValue( MapBallot, name )
end


--Who a map vote waits for: the humans. A bot never votes, so counting them
--meant a server with bots on it always sat out the whole timer. With nobody but
--bots there is nobody to wait for, so they count then - which is what lets a
--test drive a vote at all.
function TTG_MapVoters()
	local humans = player.GetHumans()
	if #humans > 0 then return humans end
	return player.GetAll()
end


--How many of `choices` went to each map on `ballot`, and the maps with the most,
--in ballot order. A choice for anything not on the ballot counts for nothing.
function TTG_TallyMapVotes( ballot, choices )
	local counts = {}
	for _, name in ipairs( ballot ) do counts[ name ] = 0 end

	for _, choice in ipairs( choices ) do
		if counts[ choice ] != nil then counts[ choice ] = counts[ choice ] + 1 end
	end

	local most = 0
	for _, name in ipairs( ballot ) do most = math.max( most, counts[ name ] ) end

	local top = {}
	if most > 0 then
		for _, name in ipairs( ballot ) do
			if counts[ name ] == most then table.insert( top, name ) end
		end
	end

	return counts, top
end


--What the vote decided, given the maps it ended with the most votes for:
--  { change = name }                  one clear winner
--  { runoff = { names } }             a tie, and this was not a runoff yet
--  { change = name, random = true }   a tie in the runoff, settled at random
--  {}                                 nobody voted
--A tied runoff is settled at random rather than run again: two players split
--one each would otherwise go round forever.
function TTG_ResolveMapVote( top, runoff )
	if #top == 0 then return {} end
	if #top == 1 then return { change = top[ 1 ] } end
	if runoff then return { change = top[ math.random( #top ) ], random = true } end
	return { runoff = top }
end


--Change level. On its own so a test can stand in for it.
function TTG_ChangeMap( name )
	--Leave a note that this map change was asked for. Nothing in the
	--gamemode reads it. The dev tooling does, to tell a map somebody
	--voted for apart from a fresh server start.
	file.Write( "ttg_mapchange.txt", os.date() )
	RunConsoleCommand( "changelevel", name )
end


--Tell everybody what is on the ballot, which opens their vote panel. Not with
--nobody but bots to hear it: net.Broadcast with no human on the server leaves
--the message open, and the next net.Start anywhere complains about it.
local function SendBallot()
	if #player.GetHumans() == 0 then return end

	net.Start( "TTG_MapBallot" )
		net.WriteUInt( #MapBallot, 8 )
		for _, name in ipairs( MapBallot ) do net.WriteString( name ) end
		net.WriteBool( MapRunoff )
	net.Broadcast()
end


local function EveryoneVoted( voters )
	for _, v in pairs( voters ) do
		if v.Has_Voted != true then return false end
	end
	return true
end


local function FinishMapVote()
	local choices = {}
	for _, v in pairs( player.GetAll() ) do
		table.insert( choices, v:GetChangeMap() )
	end

	local counts, top = TTG_TallyMapVotes( MapBallot, choices )
	local outcome = TTG_ResolveMapVote( top, MapRunoff )

	EndVote()

	umsg.Start( "Sound_VotingEnd" )
	umsg.End()

	if outcome.change then
		if outcome.random then
			ChatPrintToAll( "Still tied between " .. table.concat( top, ", " ) .. " - picking one at random..." )
		end
		ChatPrintToAll( "Switching map to:  " .. outcome.change )

		timer.Simple( MAP_VOTE_DELAY, function()
			TTG_ChangeMap( outcome.change )
		end )

	elseif outcome.runoff then
		ChatPrintToAll( "Tied at " .. counts[ top[ 1 ] ] .. " vote(s) each: " .. table.concat( top, ", " ) .. ". Runoff between them..." )

		timer.Simple( MAP_VOTE_DELAY, function()
			--somebody may have started something else in the meantime
			if G_VoteInProgress then return end
			StartMapVote( outcome.runoff, true )
		end )

	else
		ChatPrintToAll( "Nobody voted for a map - staying on this one." )
	end
end




--checks if a vote has succeeded, then deploys the results
local function VoteSuccessCheck()
	local finish = false

	if VoteDirective == "kick" then
		for _, v in pairs(player.GetAll()) do
			if v:GetVotesInt() > VotesMin then
				finish = true
				ChatPrintToAll( "Kicking:  " .. v:Name() )
				timer.Simple( 3, function()
					v:Kick("Server Vote")
				end)
			end
		end


	elseif VoteDirective == "restart" then
		local truevotes = GetGlobalInt( "CL_BoolVotes_true" )
		local falsevotes = GetGlobalInt( "CL_BoolVotes_false" )

		if truevotes > VotesMin then
			finish = true
			ChatPrintToAll( "Restarting game..." )
			timer.Simple( 3, function()
				GameRestart()
			end)
		elseif falsevotes > VotesMin then
			finish = true
			ChatPrintToAll( "Voting conclusion: No..." )
		end


	elseif VoteDirective == "map" then
		--Nothing settles a map vote early but everybody having voted: the most
		--votes wins, and the count only means that when the vote closes.
		if EveryoneVoted( TTG_MapVoters() ) then
			FinishMapVote()
		end
		return
	end


	--if all players voted, then end the vote
	if EveryoneVoted( player.GetAll() ) then
		finish = true
		ChatPrintToAll( "Vote Finished" )
	end



	if finish == true then
		EndVote()

		--play a sound to everyone to signify the end of voting
		umsg.Start("Sound_VotingEnd")
		umsg.End()
	end
end


--the time is up: a map vote is decided by what it has, anything else failed
local function VoteTimedOut()
	if VoteSuccess == true then return end
	if VoteCancelled == true then return end

	if VoteDirective == "map" then
		FinishMapVote()
		return
	end

	ChatPrintToAll( "Vote failed..." )
	EndVote()
end


--ends all vote functions
function EndVote()


	G_VoteInProgress = false
	VoteDirective = nil
	VoteSuccess = false
	VoteCancelled = true
	VotesMin = 0

	MapBallot = {}
	MapRunoff = false

	umsg.Start("Vote_End")
	umsg.End()

	hook.Remove("Tick", "VoteSuccessCheck")

	--Named, so ending a vote takes its timeout with it. It was a timer.Simple
	--guarded by VoteCancelled - which the next vote sets back to false, so a
	--vote begun inside thirty seconds of the last one was ended by the last
	--one's timeout. A runoff begins three seconds after the vote before it.
	timer.Remove( "TTG_VoteTimeout" )
end


--the part of starting a vote every kind shares
local function BeginVote( str )
	--clear all players voting booleans that say if theyve voted or not
	for _, v in pairs(player.GetAll()) do
		v.Has_Voted = false
		v:SetChangeMap( 0 )	--reset the map they may have voted for in an earlier vote
	end

	SetGlobalInt( "CL_BoolVotes_true", 0 )
	SetGlobalInt( "CL_BoolVotes_false", 0 )

	--generate the minimum amount of votes to pass the current directive
	VotesMin = (table.Count( player.GetAll() ) * .6)

	VoteDirective = str
	G_VoteInProgress = true
	VoteSuccess = false
	VoteCancelled = false
	hook.Add("Tick", "VoteSuccessCheck", VoteSuccessCheck)

	--create a timer ent so the panel will display the countdown of time left
	CreateTimerEnt( VOTING_TIME, "CL_VoteTimerInt" )

	timer.Create( "TTG_VoteTimeout", VOTING_TIME, 1, VoteTimedOut )
end


--Put `ballot` to the vote: the whole list from data/ttg_map_vote.txt, or just
--the maps a vote tied on when `runoff` is set.
function StartMapVote( ballot, runoff )
	BeginVote( "map" )

	MapBallot = table.Copy( ballot )
	MapRunoff = runoff == true

	SendBallot()
end


--starts a serverwide vote for something, makes voting menus come up for all players
function StartVote( str, ply )
	if str == "map" then
		local ballot = TTG_MapVoteList()
		if #ballot == 0 then
			ply:ChatPrint( "There are no maps to vote for - the list is data/ttg_map_vote.txt on the server." )
			return
		end

		ChatPrintToAll( ply:Name() .. " initiated a vote to change maps..." )
		StartMapVote( ballot, false )
		return
	end

	if str == "kick" then
		umsg.Start("VoteInitialize_Kick")
		umsg.End()
		ChatPrintToAll( ply:Name() .. " initiated a votekick..." )
	elseif str == "restart" then
		umsg.Start("VoteInitialize_Restart")
		umsg.End()
		ChatPrintToAll( ply:Name() .. " initiated a voterestart..." )
	end

	BeginVote( str )
end




local function GetIfCanVote()
	if G_VoteInProgress == true then
		return false
	else
		return true
	end
end



function Vote_ServerSay( ply, text, public )
	local function TryToStart( str )
		if GetIfCanVote() == true then
			--dont allow changing maps during the game
			if str == "map" and G_CurrentPhase != "GameSetup" then
				ply:ChatPrint( "Cant change map during an active game..." )
				return
			end

			--dont allow vote kicking during game
			if str == "kick" and G_CurrentPhase != "GameSetup" then
				ply:ChatPrint( "Cant votekick during an active game..." )
				return
			end

			StartVote( str, ply )
		else
			ply:ChatPrint( "A vote is already ongoing..." )
		end
	end


    if (string.sub(text, 1, 9) == "!votekick") then
		TryToStart( "kick", ply )
	elseif (string.sub(text, 1, 12) == "!voterestart") then
		TryToStart( "restart", ply )
	elseif (string.sub(text, 1, 14) == "!votemap") then
		if VOTE_CHANGEMAP_ENABLED == true then
			TryToStart( "map", ply )
		end
    end
end
hook.Add( "PlayerSay", "Vote_ServerSay", Vote_ServerSay )

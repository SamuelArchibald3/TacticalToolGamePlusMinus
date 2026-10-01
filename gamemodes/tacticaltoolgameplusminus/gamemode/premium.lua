/*---------------------------------------------------------
	The Premium Monthly Subscription, and the Venmo it pays for
---------------------------------------------------------*/

--A joke. Players listed in data/ttg_subscribers.txt get SUBSCRIBER_TOKENS every
--round, whatever the round would have given them, and that is the only way
--anybody can afford the Venmo ability - it costs more than a round ever hands
--out. Pressing it writes down that the player is owed four dollars. Nothing is
--ever paid by any of this: the list of who is owed is for whoever runs the
--server to read.
--
--Server only.

local SUBSCRIBER_FILE = "ttg_subscribers.txt"

--Where the Venmo ability writes down who is owed. A global so a test can point
--it at a file of its own rather than adding to the real one.
VENMO_OWED_FILE = "ttg_venmo_owed.txt"

local SUBSCRIBER_HEADER = [[
# Premium Monthly Subscribers: one Steam ID per line. They get SUBSCRIBER_TOKENS
# tool tokens every round (20 as shipped), whatever the round would have given
# them - which is the only way anybody can afford the Venmo ability.
#
# Either form of ID works: 7656119xxxxxxxxxx (SteamID64) or STEAM_0:1:xxxxxx.
# status  in the server console shows everybody's. Anything after a # is
# ignored, so a name can go beside it:
#
#   76561198000000000   # somebody
#
# Read every round, so an edit applies from the next one.
]]


--The IDs in `text`, as a set. Comments and blank lines are not IDs.
function TTG_ParseSubscribers( text )
	local ids = {}

	for _, line in ipairs( string.Explode( "\n", text or "" ) ) do
		local id = string.Trim( string.Explode( "#", line )[ 1 ] or "" )
		if id != "" then ids[ id ] = true end
	end

	return ids
end


--Who is subscribed, read fresh every time. That is once per player per round,
--which is nothing, and means the file can be edited mid-game. Written with an
--explanation the first time, so there is something to find and fill in.
function TTG_Subscribers()
	if not file.Exists( SUBSCRIBER_FILE, "DATA" ) then
		file.Write( SUBSCRIBER_FILE, SUBSCRIBER_HEADER )
	end

	return TTG_ParseSubscribers( file.Read( SUBSCRIBER_FILE, "DATA" ) )
end


function TTG_IsSubscriber( ply )
	if not IsValid( ply ) then return false end

	local ids = TTG_Subscribers()

	return ids[ ply:SteamID64() or "" ] == true or ids[ ply:SteamID() ] == true
end


--Write down that `ply` is owed `amount` dollars: when, who, their Steam ID and
--how much, tab separated so it pastes straight into a spreadsheet.
function TTG_RecordVenmoOwed( ply, amount )
	local id = ply:SteamID64() or ply:SteamID()

	file.Append( VENMO_OWED_FILE, os.date( "%Y-%m-%d %H:%M:%S" ) .. "\t" .. ply:Nick() .. "\t" .. id .. "\t$" .. amount .. "\n" )

	print( "TTG: " .. ply:Nick() .. " is owed $" .. amount .. " on Venmo - written to data/" .. VENMO_OWED_FILE )
end

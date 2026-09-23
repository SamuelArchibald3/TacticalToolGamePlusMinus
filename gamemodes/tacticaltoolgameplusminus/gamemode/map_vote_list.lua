/*---------------------------------------------------------
	The maps !votemap offers
---------------------------------------------------------*/

--A text file rather than SERVER_MAPS in shared_settings.lua, so what is on the
--ballot, and in what order, is a server's choice rather than a code change.
--One map name per line, in the order the vote lists them. Blank lines are
--skipped and anything after a # is ignored. ttg_mapvote_reload picks up an edit
--without a map change.
--
--Two files, as with the shop blocklist. The one that gets read lives in data/,
--which is per install and survives updating the gamemode. The one that seeds it
--ships with the gamemode, so a fresh server starts from a list that explains
--itself.
--
--Server only: a client is sent what is on the ballot when a vote starts, which
--in a runoff is not the whole list anyway.

local LIST_FILE = "ttg_map_vote.txt"
local DEFAULT_FILE = "gamemodes/tacticaltoolgameplusminus/map_vote.txt"

local MapList = {}


--The names in `text`, in order, with comments, blank lines and repeats taken
--out. Also hands back the repeats, so they can be reported rather than quietly
--dropped.
function TTG_ParseMapList( text )
	local names, seen, repeats = {}, {}, {}

	for _, line in ipairs( string.Explode( "\n", text or "" ) ) do
		local name = string.Trim( string.Explode( "#", line )[ 1 ] or "" )

		if name != "" then
			if seen[ name ] then
				table.insert( repeats, name )
			else
				seen[ name ] = true
				table.insert( names, name )
			end
		end
	end

	return names, repeats
end


function TTG_MapExists( name )
	return file.Exists( "maps/" .. name .. ".bsp", "GAME" )
end


--The list `text` describes, less any map this server does not have: a vote
--that picks one of those changes level to nothing. Returns the list, the maps
--it left out, and the repeats.
function TTG_MapListFromText( text )
	local names, repeats = TTG_ParseMapList( text )
	local list, missing = {}, {}

	for _, name in ipairs( names ) do
		if TTG_MapExists( name ) then
			table.insert( list, name )
		else
			table.insert( missing, name )
		end
	end

	return list, missing, repeats
end


--What the next !votemap will offer, in order. A copy, so a vote cannot edit it.
function TTG_MapVoteList()
	return table.Copy( MapList )
end


--Read the list in. Returns how many maps it offers, and what it left out.
function TTG_LoadMapVoteList()
	--seeded from the gamemode's own copy the first time, and never again:
	--once it is there it belongs to whoever runs the server
	if not file.Exists( LIST_FILE, "DATA" ) then
		file.Write( LIST_FILE, file.Read( DEFAULT_FILE, "GAME" ) or "" )
	end

	local list, missing, repeats = TTG_MapListFromText( file.Read( LIST_FILE, "DATA" ) )
	MapList = list

	for _, name in ipairs( missing ) do
		print( "TTG map vote: " .. name .. " is not on this server, leaving it off the ballot" )
	end
	for _, name in ipairs( repeats ) do
		print( "TTG map vote: " .. name .. " is listed more than once, offering it once" )
	end

	return #list, missing, repeats
end


concommand.Add( "ttg_mapvote_reload", function( ply )
	local count, missing = TTG_LoadMapVoteList()

	local msg = "map vote: " .. count .. " map(s) on the ballot"
	if #missing > 0 then
		msg = msg .. ", " .. #missing .. " not on this server - see the console"
	end

	print( msg )
	if IsValid( ply ) then ply:ChatPrint( msg ) end
end )


TTG_LoadMapVoteList()

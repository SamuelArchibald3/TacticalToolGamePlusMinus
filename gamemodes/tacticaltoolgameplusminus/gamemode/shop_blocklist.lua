/*---------------------------------------------------------
	Purchases turned off by hand
---------------------------------------------------------*/

--A blocklist rather than an allowlist, so a tool is on sale the moment it is
--written rather than only once somebody remembers to add it to a list.
--
--One purchase name per line. Blank lines are skipped and anything after a # is
--ignored, so the file can say why something is off. ttg_shop_reload picks up
--an edit without a map change.
--
--A file rather than a convar because a convar holds one string, and twenty
--purchase names inside a single console command is not something anybody wants
--to edit. The cost is this loader and telling the client, which a convar would
--have needed anyway.
--
--Two files, and the split matters. The one that gets read lives in data/,
--which is per install and survives updating the gamemode - so a server's own
--choices are not thrown away by a git pull. The one that seeds it ships with
--the gamemode and is version controlled, so a fresh server starts from
--something that explains itself rather than from an empty file.

local BLOCKLIST_FILE = "ttg_shop_blocked.txt"

--Hardcoded rather than asked for: the folder name is fixed, and the gamemode
--is already halfway through loading when this runs.
local DEFAULT_FILE = "gamemodes/tacticaltoolgameplusminus/shop_blocked.txt"

--Kept as a set on both realms: the server reads the file, the client is told,
--because the buy menu has to leave these out and cannot read data/ itself.
local Blocked = {}


function TTG_ShopBlocked( purchasename )
	return Blocked[ purchasename ] == true
end


function TTG_ShopBlockedList()
	local out = {}

	for name in pairs( Blocked ) do table.insert( out, name ) end
	table.sort( out )

	return out
end


if SERVER then
	util.AddNetworkString( "TTG_ShopBlocked" )

	--Whether anybody can actually receive one of these.
	--
	--Bots cannot, and that is the whole point of asking. A net message that is
	--started and then not sent stays open, and the next net.Start anywhere in
	--the gamemode discards itself over the top of it and says so - which is
	--how this turned up: an unsent blocklist sitting open until the round
	--restart's own broadcast tripped over it.
	--
	--player.GetCount() was the first guess and it is the wrong question: it
	--counts bots, so on a server full of them net.Broadcast is handed a
	--message with nobody to give it to. GetHumans is who is really listening.
	local function CanReceive( to )
		if IsValid( to ) then return to:IsBot() != true end

		return #player.GetHumans() > 0
	end


	--`to` is who receives it; nil means everybody.
	local function Broadcast( to )
		if not CanReceive( to ) then return end

		local names = TTG_ShopBlockedList()

		net.Start( "TTG_ShopBlocked" )
			net.WriteUInt( #names, 8 )

			for _, name in ipairs( names ) do
				net.WriteString( name )
			end

		if IsValid( to ) then
			net.Send( to )
		else
			net.Broadcast()
		end
	end


	--Read the file in. Hands back how many names it took and how many it did
	--not recognise, so the console says something useful either way - a typo
	--in there is otherwise a tool that stays on sale for no visible reason.
	function TTG_LoadShopBlocklist()
		Blocked = {}

		--seeded from the gamemode's own copy the first time, and never again:
		--once it is there it belongs to whoever runs the server
		if not file.Exists( BLOCKLIST_FILE, "DATA" ) then
			file.Write( BLOCKLIST_FILE, file.Read( DEFAULT_FILE, "GAME" ) or "" )
		end

		local body = file.Read( BLOCKLIST_FILE, "DATA" ) or ""
		local taken, unknown = 0, 0

		for _, line in ipairs( string.Explode( "\n", body ) ) do
			local name = string.Trim( string.Explode( "#", line )[ 1 ] or "" )

			if name != "" then
				if CheckIfInShopTables( name ) then
					Blocked[ name ] = true
					taken = taken + 1
				else
					print( "TTG shop blocklist: there is no purchase called " .. name )
					unknown = unknown + 1
				end
			end
		end

		Broadcast()

		return taken, unknown
	end


	--Turn one off or on for this session only. The file is not rewritten, so a
	--reload or a map change puts it back to whatever is written down.
	function TTG_SetShopBlocked( purchasename, blocked )
		if not CheckIfInShopTables( purchasename ) then return false end

		Blocked[ purchasename ] = blocked == true or nil
		Broadcast()

		return true
	end


	--Somebody who joins later has missed the broadcast, and the list is only
	--read at map load. Deferred a second for the same reason
	--TTG_SendPlayerLists defers: a player in PlayerInitialSpawn is not ready to
	--be sent anything yet.
	hook.Add( "PlayerInitialSpawn", "TTG_SendShopBlocklist", function( ply )
		timer.Simple( 1, function()
			if IsValid( ply ) then Broadcast( ply ) end
		end )
	end )


	concommand.Add( "ttg_shop_reload", function( ply )
		local taken, unknown = TTG_LoadShopBlocklist()

		local msg = "shop blocklist: " .. taken .. " purchase(s) turned off"
		if unknown > 0 then
			msg = msg .. ", " .. unknown .. " name(s) not recognised - see the console"
		end

		print( msg )
		if IsValid( ply ) then ply:ChatPrint( msg ) end
	end )


	--At load, once the shop tables are there to check names against. init.lua
	--includes this after them for exactly that reason.
	TTG_LoadShopBlocklist()
end


if CLIENT then
	net.Receive( "TTG_ShopBlocked", function()
		Blocked = {}

		for i = 1, net.ReadUInt( 8 ) do
			Blocked[ net.ReadString() ] = true
		end
	end )
end

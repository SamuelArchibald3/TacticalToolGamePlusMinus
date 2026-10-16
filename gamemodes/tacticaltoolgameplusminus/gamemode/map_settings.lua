/*---------------------------------------------------------
	Settings for particular maps
---------------------------------------------------------*/

--What one map plays differently from the rest: whether all of its capture
--zones are live at once, and how long one takes to capture. See
--map_settings.txt in the gamemode folder for the format.
--
--A file rather than something written into each map, because most of the maps
--on the vote list are other people's - from the Workshop, with no source to
--put a setting in - and because trying a different capture time should not
--mean recompiling a map. The same two files as the shop blocklist, for the
--same reasons: the one in data/ belongs to whoever runs the server and
--survives a gamemode update, and the one that seeds it is version controlled.

local SETTINGS_FILE = "ttg_map_settings.txt"
local DEFAULT_FILE = "gamemodes/tacticaltoolgameplusminus/map_settings.txt"

--What each setting may be, and what a map gets when it says nothing.
local KNOWN = {
	zones = function( v ) return v == "random" or v == "all" end,

	--whole seconds, or a multiple of TIME_TO_CAPTURE written as 2x, 1.5x
	capture_time = function( v )
		local times = string.match( v, "^(%d*%.?%d+)x$" )
		if times then return tonumber( times ) > 0 end

		return tonumber( v ) != nil and tonumber( v ) > 0 and math.floor( tonumber( v ) ) == tonumber( v )
	end,
}

local DEFAULTS = {
	zones = "random",
}

--map name -> { setting = value }
local Settings = {}

--set for this session by TTG_SetMapSetting, over whatever the file says
local Overrides = {}


--This map's value for a setting, or the default.
function TTG_MapSetting( key )
	if Overrides[ key ] != nil then return Overrides[ key ] end

	local mine = Settings[ game.GetMap() ]
	if mine and mine[ key ] != nil then return mine[ key ] end

	return DEFAULTS[ key ]
end


--Set one for this map, for this session only. The file is not rewritten, so a
--reload or a map change puts it back to whatever is written down. nil clears
--it. Returns false for a setting or value that is not one of the known ones.
function TTG_SetMapSetting( key, value )
	if KNOWN[ key ] == nil then return false end
	if value != nil and not KNOWN[ key ]( tostring( value ) ) then return false end

	Overrides[ key ] = value != nil and tostring( value ) or nil
	return true
end


--How many seconds a zone takes to capture on this map.
function TTG_CaptureTimeFull()
	local v = TTG_MapSetting( "capture_time" )
	if v == nil then return TIME_TO_CAPTURE end

	local times = string.match( v, "^(%d*%.?%d+)x$" )
	if times then return math.max( 1, math.Round( TIME_TO_CAPTURE * tonumber( times ) ) ) end

	return tonumber( v )
end


--Read the file in. Hands back how many settings it took and how many it
--refused, so the console says something useful either way.
function TTG_LoadMapSettings()
	Settings = {}
	Overrides = {}

	--seeded from the gamemode's own copy the first time, and never again
	if not file.Exists( SETTINGS_FILE, "DATA" ) then
		file.Write( SETTINGS_FILE, file.Read( DEFAULT_FILE, "GAME" ) or "" )
	end

	local body = file.Read( SETTINGS_FILE, "DATA" ) or ""
	local taken, refused = 0, 0

	for _, line in ipairs( string.Explode( "\n", body ) ) do
		local words = string.Explode( "%s+", string.Trim( string.Explode( "#", line )[ 1 ] or "" ), true )
		local map = words[ 1 ]

		if map != nil and map != "" then
			for i = 2, #words do
				local key, value = string.match( words[ i ], "^([%w_]+)=(.+)$" )

				if key and KNOWN[ key ] and KNOWN[ key ]( value ) then
					Settings[ map ] = Settings[ map ] or {}
					Settings[ map ][ key ] = value
					taken = taken + 1
				else
					print( "TTG map settings: " .. map .. " - not a setting: " .. words[ i ] )
					refused = refused + 1
				end
			end
		end
	end

	return taken, refused
end


concommand.Add( "ttg_mapsettings_reload", function( ply )
	if IsValid( ply ) and not ply:IsAdmin() then return end

	local taken, refused = TTG_LoadMapSettings()

	local msg = "map settings: " .. taken .. " setting(s) read"
	if refused > 0 then
		msg = msg .. ", " .. refused .. " refused - see the console"
	end
	msg = msg .. ". This map: zones=" .. TTG_MapSetting( "zones" ) .. ", capture_time=" .. TTG_CaptureTimeFull() .. "s"

	print( msg )
	if IsValid( ply ) then ply:ChatPrint( msg ) end
end )


TTG_LoadMapSettings()

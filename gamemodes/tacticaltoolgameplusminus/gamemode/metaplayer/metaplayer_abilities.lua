/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


--What each player's two shop lists look like, as last told to us by the server.
--Keyed by UserID rather than by the player entity, so a message that arrives
--before the entity does is still usable.
--
--CLIENT only. The server reads the networked vars directly and never touches
--this.
local Lists = {}


--Name of one field of a numbered ability slot, eg Ability_2_name.
--
--The slots used to be named A, B and C, spelled out in the buy logic, the
--keybinds, the hud, the reset path and the drop slam hook. Numbering them puts
--the count in one constant and lets an ability move between slots.
local function AbilitySlotKey( index, field )
	return "Ability_" .. index .. "_" .. field
end


--The hard ceiling, as opposed to MAX_ABILITY_SLOTS which is the current setting.
--Resets clear up to here, so lowering the setting cannot strand a networked slot
--with a stale ability still showing on somebody's hud.
local function AbilitySlotLimit()
	return table.Count( ABILITY_KEYS )
end


--The ability names in a player's slots, read straight out of the networked
--vars. What GetAbilityNames used to be, before other people's copies had to
--come from somewhere else.
local function ReadAbilityNames( ply )
	local names = {}

	for i = 1, AbilitySlotLimit() do
		local name = ply:GetNW2String( AbilitySlotKey( i, "name" ), "none" )

		--"none" is what an empty slot is set to
		if name != "none" then
			table.insert( names, name )
		end
	end

	return names
end


--The player's ability slots, keyed 1 to MAX_ABILITY_SLOTS. Built on demand so
--no caller has to nil check it.
function TTGPlayer:GetAbilitySlots()
	if self.AbilitySlots == nil then
		self.AbilitySlots = {}
	end

	return self.AbilitySlots
end


//change this into ResetAllInfo, and make it reset ALL networked vars
//resets all the networked vars of a player's ability tools
function TTGPlayer:ResetAbilityInfo()
	--ability stuff
	for i = 1, AbilitySlotLimit() do
		self:ClearAbilityInfo( i )
	end

	--aim target stuff
	--NULL rather than nil. The typed NW2 setters expect a value of their type,
	--and this is the only nil-valued write in the file.
	self:SetNW2Entity("AimTarget", NULL)
	self:SetNW2Bool("IsAimTarget", false)

	self:SetNW2Int("AimTargetDist", 0)
end


--Networks one slot as empty
function TTGPlayer:ClearAbilityInfo( slot )
	local before = self:GetNW2String( AbilitySlotKey( slot, "name" ), "none" )

	self:SetNW2String( AbilitySlotKey( slot, "name" ), "none" )
	self:SetNW2Bool( AbilitySlotKey( slot, "cooldown" ), false )
	self:SetNW2Int( AbilitySlotKey( slot, "time" ), 0 )

	--only when the name actually moved, so clearing the empty slots at the top
	--of a round sends nothing
	if SERVER and before != "none" then TTG_SendPlayerLists( self ) end
end


--Networks what is in one slot. Called by the ability ent itself, so nothing
--outside this file has to know the networked var names.
function TTGPlayer:SetAbilityInfo( slot, name, cooldown, time )
	if slot == nil then return end

	local before = self:GetNW2String( AbilitySlotKey( slot, "name" ), "none" )

	self:SetNW2String( AbilitySlotKey( slot, "name" ), name )
	self:SetNW2Bool( AbilitySlotKey( slot, "cooldown" ), cooldown )
	self:SetNW2Int( AbilitySlotKey( slot, "time" ), time )

	--Name only. This is also the cooldown ticking, which runs every time an
	--ability is used and would put a broadcast on the wire for a number nobody
	--else's screen shows.
	if SERVER and before != name then TTG_SendPlayerLists( self ) end
end


//returns a table of networked info of a player's specific ability
//used to display the ability on the player's hud, with the time left on the cooldown
function TTGPlayer:GetAbilityInfo( slot )
	return {
		name     = self:GetNW2String( AbilitySlotKey( slot, "name" ), "none" ),
		cooldown = self:GetNW2Bool( AbilitySlotKey( slot, "cooldown" ), false ),
		time     = self:GetNW2Int( AbilitySlotKey( slot, "time" ), 0 ),
	}
end


--How many ability slots are in use. Reads the networked copy, so the buy menu
--can show it without asking the server.
function TTGPlayer:GetAbilityCount()
	local used = 0

	for i = 1, TTG_AbilitySlotCount() do
		if self:GetAbilityInfo( i ).name != "none" then
			used = used + 1
		end
	end

	return used
end


//returns a table of the names of the ability ents the player has
function TTGPlayer:GetAbilityNames()
	--Somebody else's abilities come from the broadcast, not from their
	--networked vars - see the note above TTG_SendPlayerLists. Your own still
	--come from the vars, which are always current for you.
	if CLIENT and self != LocalPlayer() then
		local cached = Lists[ self:UserID() ]

		return cached and cached.abilities or {}
	end

	return ReadAbilityNames( self )
end


--Re-networks a slot from whatever ent is in it now, and tells the ent where it
--lives. The pair of these is what makes moving an ability between slots work.
function TTGPlayer:RefreshAbilitySlot( slot )
	local abil = self:GetAbilitySlots()[ slot ]

	if not IsValid( abil ) then
		self:ClearAbilityInfo( slot )
		return
	end

	abil:SetAbilitySlot( slot )
	abil:RefreshNetworkedVars()
end


--Swaps what is in two ability slots, which is the same thing as swapping which
--key runs which ability. Returns false if either slot is not a real one.
function TTGPlayer:SwapAbilitySlots( a, b )
	if a == b then return false end
	if a == nil or b == nil then return false end
	if a < 1 or b < 1 then return false end
	if a > MAX_ABILITY_SLOTS or b > MAX_ABILITY_SLOTS then return false end

	local slots = self:GetAbilitySlots()
	slots[ a ], slots[ b ] = slots[ b ], slots[ a ]

	self:RefreshAbilitySlot( a )
	self:RefreshAbilitySlot( b )

	return true
end





//resets all the networked vars of a player's tool info
--Name of one field of a numbered tool slot, eg SwepTool_3_Ammo.
--
--The slots used to be named A, B and C, and a player who bought a fourth tool
--got it - it just never appeared in their list, because there was nowhere left
--to network it to. Numbering them means the count is one constant to change.
local function ToolSlotKey( index, field )
	return "SwepTool_" .. index .. "_" .. field
end


--The tools in a player's slots, read straight out of the networked vars.
local function ReadToolSlots( ply )
	local tools = {}

	for i = 1, MAX_TOOL_SLOTS do
		local name = ply:GetNW2String( ToolSlotKey( i, "Name" ), "none" )

		if name != "none" then
			table.insert( tools, {
				name = name,
				--fallbacks kept explicit: GetNetworkedInt defaulted to 0, and a
				--nil here reaches cl_purchasesmenu as ( name .. " x" .. ammo )
				ammo    = ply:GetNW2Int( ToolSlotKey( i, "Ammo" ), 0 ),
				numguns = ply:GetNW2Int( ToolSlotKey( i, "NumGuns" ), 0 ),
			} )
		end
	end

	return tools
end


--Getting a player's lists onto OTHER people's screens.
--
--A networked var only reaches a client while the entity carrying it is being
--transmitted to that client, and through a buy phase the two teams sit in
--separate rooms with nothing in each other's PVS. So the shop's list of what
--everyone owns was showing whatever each client last saw of the other side, and
--only caught up when that player came into view - which is why the delay
--varied from a moment to most of a round.
--
--Your own list was never late, because your own player is always transmitted to
--you. That difference is the whole diagnosis: the write was never slow, the
--delivery was conditional.
--
--The same problem was met and solved once here already - TTG_TeamRoles and
--TTG_GameState are net messages for this exact reason. This is that shape,
--applied to the two lists the shop draws.
--
--The networked vars stay as they are. They are still what the server reads and
--what your own client reads, and this is built from them rather than replacing
--them.
if SERVER then
	util.AddNetworkString( "TTG_PlayerLists" )

	--`to` is who receives it; nil means everybody.
	function TTG_SendPlayerLists( ply, to )
		if not IsValid( ply ) or not ply:IsPlayer() then return end

		local tools = ReadToolSlots( ply )
		local abils = ReadAbilityNames( ply )

		net.Start( "TTG_PlayerLists" )
			net.WriteUInt( ply:UserID(), 16 )

			net.WriteUInt( #tools, 8 )
			for _, tool in ipairs( tools ) do
				net.WriteString( tool.name )
				net.WriteUInt( math.Clamp( tool.ammo, 0, 65535 ), 16 )
				net.WriteUInt( math.Clamp( tool.numguns, 0, 255 ), 8 )
			end

			net.WriteUInt( #abils, 8 )
			for _, name in ipairs( abils ) do
				net.WriteString( name )
			end

		if IsValid( to ) then
			net.Send( to )
		else
			net.Broadcast()
		end
	end


	--Somebody who joins mid-game has missed every broadcast so far, and the
	--lists are only rebuilt at the top of a round. Deferred a second because a
	--player in PlayerInitialSpawn is not ready to be sent anything yet.
	hook.Add( "PlayerInitialSpawn", "TTG_SendAllPlayerLists", function( ply )
		timer.Simple( 1, function()
			if not IsValid( ply ) then return end

			for _, other in ipairs( player.GetAll() ) do
				TTG_SendPlayerLists( other, ply )
			end
		end )
	end )
end


if CLIENT then
	net.Receive( "TTG_PlayerLists", function()
		local userid = net.ReadUInt( 16 )

		local tools = {}
		for i = 1, net.ReadUInt( 8 ) do
			tools[ i ] = {
				name    = net.ReadString(),
				ammo    = net.ReadUInt( 16 ),
				numguns = net.ReadUInt( 8 ),
			}
		end

		local abils = {}
		for i = 1, net.ReadUInt( 8 ) do
			abils[ i ] = net.ReadString()
		end

		Lists[ userid ] = { tools = tools, abilities = abils }

		--A count, so a dev command can answer "is anything arriving at all"
		--without a second net.Receive - GMod keeps one receiver per message
		--name, and registering another elsewhere would silently replace this.
		TTG_PlayerListsReceived = ( TTG_PlayerListsReceived or 0 ) + 1
	end )


	--What this client currently believes everyone owns. Read by ttg_devlists.
	function TTG_DebugLists()
		return Lists
	end
end


function TTGPlayer:ResetSwepToolInfo()
	for i = 1, MAX_TOOL_SLOTS do
		self:SetNW2String( ToolSlotKey( i, "Name" ), "none" )
		self:SetNW2Int( ToolSlotKey( i, "Ammo" ), 0 )
		self:SetNW2Int( ToolSlotKey( i, "NumGuns" ), 0 )
	end

	--once, after the whole list is cleared, rather than ten times through it
	if SERVER then TTG_SendPlayerLists( self ) end
end






--returns a table of the player's networked swep ents
--used because GetWeapons is broken and bad
function TTGPlayer:GetSwepToolInfo()
	local sweptool_table

	--Somebody else's tools come from the broadcast; your own come from the
	--networked vars, which are always current for you. See the note above
	--TTG_SendPlayerLists.
	if CLIENT and self != LocalPlayer() then
		local cached = Lists[ self:UserID() ]
		sweptool_table = cached and cached.tools or {}
	else
		sweptool_table = ReadToolSlots( self )
	end

	--callers check for false rather than an empty table, so keep that contract
	if table.Count( sweptool_table ) > 0 then
		return sweptool_table
	else
		return false
	end
end



--Adds the swep to the networked swep tools
function TTGPlayer:SetSwepToolInfo( swepname, ammo, numguns )
	local firstfree = nil

	--One pass: a tool already in the list just has its numbers refreshed, and
	--the earliest empty slot is remembered in case it is not there yet. The
	--whole list has to be checked for a match before claiming a free slot, or
	--buying more of something you own would list it twice.
	for i = 1, MAX_TOOL_SLOTS do
		local slotname = self:GetNW2String( ToolSlotKey( i, "Name" ), "none" )

		if slotname == swepname then
			self:SetNW2Int( ToolSlotKey( i, "Ammo" ), ammo )
			self:SetNW2Int( ToolSlotKey( i, "NumGuns" ), numguns )

			if SERVER then TTG_SendPlayerLists( self ) end
			return
		end

		if firstfree == nil and slotname == "none" then
			firstfree = i
		end
	end

	--Only reachable if MAX_TOOL_SLOTS is lower than the tokens a player can
	--spend, since every tool costs one. The tool still works - it is the list
	--that cannot show it - so say so plainly rather than the old bare "Error".
	if firstfree == nil then
		print( "TTG: no free tool slot to display " .. tostring( swepname ) ..
			" - MAX_TOOL_SLOTS (" .. MAX_TOOL_SLOTS .. ") is below the tokens a player can spend" )
		return
	end

	self:SetNW2String( ToolSlotKey( firstfree, "Name" ), swepname )
	self:SetNW2Int( ToolSlotKey( firstfree, "Ammo" ), ammo )
	self:SetNW2Int( ToolSlotKey( firstfree, "NumGuns" ), numguns )

	if SERVER then TTG_SendPlayerLists( self ) end
end
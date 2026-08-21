/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


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
	self:SetNetworkedEntity("AimTarget", nil)
	self:SetNetworkedBool("IsAimTarget", false)

	self:SetNetworkedInt("AimTargetDist", 0)
end


--Networks one slot as empty
function TTGPlayer:ClearAbilityInfo( slot )
	self:SetNetworkedString( AbilitySlotKey( slot, "name" ), "none" )
	self:SetNetworkedBool( AbilitySlotKey( slot, "cooldown" ), false )
	self:SetNetworkedInt( AbilitySlotKey( slot, "time" ), 0 )
end


--Networks what is in one slot. Called by the ability ent itself, so nothing
--outside this file has to know the networked var names.
function TTGPlayer:SetAbilityInfo( slot, name, cooldown, time )
	if slot == nil then return end

	self:SetNetworkedString( AbilitySlotKey( slot, "name" ), name )
	self:SetNetworkedBool( AbilitySlotKey( slot, "cooldown" ), cooldown )
	self:SetNetworkedInt( AbilitySlotKey( slot, "time" ), time )
end


//returns a table of networked info of a player's specific ability
//used to display the ability on the player's hud, with the time left on the cooldown
function TTGPlayer:GetAbilityInfo( slot )
	return {
		name     = self:GetNetworkedString( AbilitySlotKey( slot, "name" ), "none" ),
		cooldown = self:GetNetworkedBool( AbilitySlotKey( slot, "cooldown" ), false ),
		time     = self:GetNetworkedInt( AbilitySlotKey( slot, "time" ), 0 ),
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
	local abil_table = {}

	for i = 1, AbilitySlotLimit() do
		local name = self:GetAbilityInfo( i ).name

		--"none" is what an empty slot is set to, and it was being returned as
		--though it were an ability. GetSwepToolInfo already filters the same way.
		if name != "none" then
			table.insert( abil_table, name )
		end
	end

	return abil_table
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


function TTGPlayer:ResetSwepToolInfo()
	for i = 1, MAX_TOOL_SLOTS do
		self:SetNetworkedString( ToolSlotKey( i, "Name" ), "none" )
		self:SetNetworkedInt( ToolSlotKey( i, "Ammo" ), 0 )
		self:SetNetworkedInt( ToolSlotKey( i, "NumGuns" ), 0 )
	end
end






--returns a table of the player's networked swep ents
--used because GetWeapons is broken and bad
function TTGPlayer:GetSwepToolInfo()
	local sweptool_table = {}

	for i = 1, MAX_TOOL_SLOTS do
		local slotname = self:GetNetworkedString( ToolSlotKey( i, "Name" ), "none" )

		if slotname != "none" then
			--was three globals named swep_a/b/c, which leaked into _G every call
			local swep_info =
			{
			name = slotname,
			ammo = self:GetNetworkedInt( ToolSlotKey( i, "Ammo" ) ),
			numguns = self:GetNetworkedInt( ToolSlotKey( i, "NumGuns" ) ),
			}
			table.insert( sweptool_table, swep_info )
		end
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
		local slotname = self:GetNetworkedString( ToolSlotKey( i, "Name" ), "none" )

		if slotname == swepname then
			self:SetNetworkedInt( ToolSlotKey( i, "Ammo" ), ammo )
			self:SetNetworkedInt( ToolSlotKey( i, "NumGuns" ), numguns )
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

	self:SetNetworkedString( ToolSlotKey( firstfree, "Name" ), swepname )
	self:SetNetworkedInt( ToolSlotKey( firstfree, "Ammo" ), ammo )
	self:SetNetworkedInt( ToolSlotKey( firstfree, "NumGuns" ), numguns )
end
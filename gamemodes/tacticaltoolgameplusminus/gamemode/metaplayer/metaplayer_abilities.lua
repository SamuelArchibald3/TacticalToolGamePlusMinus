/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


//change this into ResetAllInfo, and make it reset ALL networked vars
//resets all the networked vars of a player's ability tools
function TTGPlayer:ResetAbilityInfo()
		--ability stuff
		self:SetNetworkedString( "Ability_A_name", "none" )
		self:SetNetworkedBool( "Ability_A_cooldown", false )
		self:SetNetworkedInt( "Ability_A_time", 0 )
		
		self:SetNetworkedString( "Ability_B_name", "none" )
		self:SetNetworkedBool( "Ability_B_cooldown", false )
		self:SetNetworkedInt( "Ability_B_time", 0 )
		
		self:SetNetworkedString( "Ability_C_name", "none" )
		self:SetNetworkedBool( "Ability_C_cooldown", false )
		self:SetNetworkedInt( "Ability_C_time", 0 )
		
		--aim target stuff
		self:SetNetworkedEntity("AimTarget", nil)
		self:SetNetworkedBool("IsAimTarget", false)
		
		self:SetNetworkedInt("AimTargetDist", 0)
		
end



//returns a table of networked info of a player's specific ability
//used to display the ability on the player's hud, with the time left on the cooldown
function TTGPlayer:GetAbilityInfo(letter)
	if letter == "a" then
		name_recieve = self:GetNetworkedString( "Ability_A_name", "none" )
		cooldown_recieve = self:GetNetworkedBool( "Ability_A_cooldown", false )
		time_recieve = self:GetNetworkedInt( "Ability_A_time", 0 )
		
	elseif letter == "b" then
		name_recieve = self:GetNetworkedString( "Ability_B_name", "none" )
		cooldown_recieve = self:GetNetworkedBool( "Ability_B_cooldown", false )
		time_recieve = self:GetNetworkedInt( "Ability_B_time", 0 )
		
	elseif letter == "c" then
		name_recieve = self:GetNetworkedString( "Ability_C_name", "none" )
		cooldown_recieve = self:GetNetworkedBool( "Ability_C_cooldown", false )
		time_recieve = self:GetNetworkedInt( "Ability_C_time", 0 )
		
	end	
		
	return {name = name_recieve, cooldown = cooldown_recieve, time = time_recieve}
end


//returns a table of the names of the ability ents the player has
function TTGPlayer:GetAbilityNames()
	local a_name_recieve = self:GetNetworkedString( "Ability_A_name", nil )
	local b_name_recieve = self:GetNetworkedString( "Ability_B_name", nil )
	local c_name_recieve = self:GetNetworkedString( "Ability_C_name", nil )
	
	local abil_table = {}

	if a_name_recieve != nil then
		table.insert(abil_table, a_name_recieve)
	end

	if b_name_recieve != nil then
		table.insert(abil_table, b_name_recieve)
	end
	
	if c_name_recieve != nil then
		table.insert(abil_table, c_name_recieve)
	end

	return abil_table
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
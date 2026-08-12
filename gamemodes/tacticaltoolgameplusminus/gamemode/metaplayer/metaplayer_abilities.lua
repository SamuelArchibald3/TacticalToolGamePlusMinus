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
function TTGPlayer:ResetSwepToolInfo()
	self:SetNetworkedString( "SwepTool_A_Name", "none" )
	self:SetNetworkedInt( "SwepTool_A_Ammo", 0 )
	self:SetNetworkedInt( "SwepTool_A_NumGuns", 0 )
	
	self:SetNetworkedString( "SwepTool_B_Name", "none" )
	self:SetNetworkedInt( "SwepTool_B_Ammo", 0 )
	self:SetNetworkedInt( "SwepTool_B_NumGuns", 0 )
	
	self:SetNetworkedString( "SwepTool_C_Name", "none" )
	self:SetNetworkedInt( "SwepTool_C_Ammo", 0 )
	self:SetNetworkedInt( "SwepTool_C_NumGuns", 0 )
end






--returns a table of the player's networked swep ents
--used because GetWeapons is broken and bad
function TTGPlayer:GetSwepToolInfo()
	local a_recieve = self:GetNetworkedString( "SwepTool_A_Name",  "none"  )
	local b_recieve = self:GetNetworkedString( "SwepTool_B_Name",  "none"  )
	local c_recieve = self:GetNetworkedString( "SwepTool_C_Name",  "none"  )
	
	local sweptool_table = {}

	if a_recieve !=  "none"  then
		swep_a = 
		{ 
		name = self:GetNetworkedString( "SwepTool_A_Name" ), 
		ammo = self:GetNetworkedInt( "SwepTool_A_Ammo" ), 
		numguns = self:GetNetworkedInt( "SwepTool_A_NumGuns" ), 
		}
		table.insert(sweptool_table, swep_a)
	end

	if b_recieve !=  "none"  then
		swep_b = 
		{ 
		name = self:GetNetworkedString( "SwepTool_B_Name" ), 
		ammo = self:GetNetworkedInt( "SwepTool_B_Ammo" ), 
		numguns = self:GetNetworkedInt( "SwepTool_B_NumGuns" ), 
		}
		table.insert(sweptool_table, swep_b)
	end
	
	if c_recieve !=  "none"  then
		swep_c = 
		{ 
		name = self:GetNetworkedString( "SwepTool_C_Name" ), 
		ammo = self:GetNetworkedInt( "SwepTool_C_Ammo" ), 
		numguns = self:GetNetworkedInt( "SwepTool_C_NumGuns" ), 
		}
		table.insert(sweptool_table, swep_c)
	end

	if table.Count( sweptool_table ) > 0 then
		return sweptool_table
	else
		return false
	end
end



--Adds the swep to the networked swep tools
function TTGPlayer:SetSwepToolInfo( swepname, ammo, numguns )
	local a_recieve = self:GetNetworkedString( "SwepTool_A_Name", "none" )
	local b_recieve = self:GetNetworkedString( "SwepTool_B_Name", "none" )
	local c_recieve = self:GetNetworkedString( "SwepTool_C_Name", "none" )
	
	if swepname == a_recieve then
		self:SetNetworkedInt( "SwepTool_A_Ammo", ammo )
		self:SetNetworkedInt( "SwepTool_A_NumGuns", numguns )
		return
	elseif swepname == b_recieve then
		self:SetNetworkedInt( "SwepTool_B_Ammo", ammo )
		self:SetNetworkedInt( "SwepTool_B_NumGuns", numguns )
		return
	elseif swepname == c_recieve then
		self:SetNetworkedInt( "SwepTool_C_Ammo", ammo )
		self:SetNetworkedInt( "SwepTool_C_NumGuns", numguns )
		return
	else
		if a_recieve == "none" then
			self:SetNetworkedString( "SwepTool_A_Name", swepname )
			self:SetNetworkedInt( "SwepTool_A_Ammo", ammo )
			self:SetNetworkedInt( "SwepTool_A_NumGuns", numguns )
			return
		elseif b_recieve == "none" then
			self:SetNetworkedString( "SwepTool_B_Name", swepname )
			self:SetNetworkedInt( "SwepTool_B_Ammo", ammo )
			self:SetNetworkedInt( "SwepTool_B_NumGuns", numguns )
			return
		elseif c_recieve == "none" then
			self:SetNetworkedString( "SwepTool_C_Name", swepname )
			self:SetNetworkedInt( "SwepTool_C_Ammo", ammo )
			self:SetNetworkedInt( "SwepTool_C_NumGuns", numguns )
			return
		else
			print("Error adding swep tool networked var")
			return
		end
	end
end
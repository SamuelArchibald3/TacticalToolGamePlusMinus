/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")














/*---------------------------------------------------------
	Vote stuff
---------------------------------------------------------*/




--Votes AGAINST this player trying to kick him out
function TTGPlayer:SetVotesInt( int )
	self:SetNetworkedInt( "VotesInt", int )
end

function TTGPlayer:GetVotesInt()
	return self:GetNetworkedInt("VotesInt", 0)
end



--the map the player voted for in the current vote
function TTGPlayer:SetChangeMap( str )
	self:SetNetworkedString( "ChangeMap", str )
end

function TTGPlayer:GetChangeMap()
	return self:GetNetworkedString("ChangeMap", 0)
end








function TTGPlayer:SetIfTeamJoinMenuOpen( bool )
	self:SetNetworkedBool( "TeamJoinMenuOpen", bool )
end

function TTGPlayer:GetIfTeamJoinMenuOpen()
	return self:GetNetworkedBool("TeamJoinMenuOpen", false)
end







function TTGPlayer:SetJoiningTeam( theteam )
	if theteam == "none" then
		self:SetNetworkedInt( "JoiningTeam", 5 )
	else
		self:SetNetworkedInt( "JoiningTeam", theteam )
	end	
end

function TTGPlayer:GetJoiningTeam()
	local joiningteam = self:GetNetworkedInt( "JoiningTeam", 5 )
	
	if joiningteam == 5 or joiningteam == nil then 
		return false
	else
		return joiningteam
	end
end





function TTGPlayer:SetReady(bool)
	self:SetNetworkedBool( "Ready", bool )
end

function TTGPlayer:GetIfReady()
	return self:GetNetworkedBool( "Ready", false )
end



--used for checking if the player has a gun already if they try to buy another gun, so they cant have multiple types of guns
function TTGPlayer:SetIfHasGun( bool )
	self:SetNetworkedBool( "HasGun", bool )
end

function TTGPlayer:GetIfHasGun()
	return self:GetNetworkedBool("HasGun", false)
end




//returns a table of names of every single tool in a player's inventory
//good for clients to display this information
function TTGPlayer:GetAllToolNamesAndAmmo()
	local t_table = {}
	
	//print("this guys weps    " , table.ToString(self:GetWeapons( )))
	
	--[[
	for _, swep in pairs(self:GetWeapons( )) do
		if swep:GetClass() != "default_melee" then
			//print("heres a swep:", swep:GetClass())
			swep_info = {name = swep:GetClass(), ammo = swep:GetTTGAmmo(), numguns = swep:GetNumGuns() }
			table.insert(t_table, swep_info)
		end
	end
	]]--
	SwepToolInfoTable = self:GetSwepToolInfo()
	
	if SwepToolInfoTable != false then
		for _, swep in pairs(self:GetSwepToolInfo()) do
			if CheckIfInToolTable( swep.name ) then
				local swep_info = 
				{ 
				name = swep.name, 
				ammo = swep.ammo, 
				numguns = swep.numguns,
				}
				
				table.insert(t_table, swep_info)
			end
		end
	end
	
	local abil_name_table = self:GetAbilityNames()
	for _, abil in pairs(abil_name_table) do
		if CheckIfInToolTable(abil) == true then
			abil_info = {name = abil, ammo = 1, numguns = 1}
			table.insert(t_table, abil_info)
		end
	end
	
	//print("returning a table of tools and ammo")
	return t_table
end



//returns how many SWEPs the player has
function TTGPlayer:GetSwepCount()
	local wep_table = self:GetWeapons( )
	
	local count = table.Count(wep_table) - 1	//the minus 1 is to subtract the melee weapon
	return count
end





--[[

function TTGPlayer:TempSpeedBuff()
	if self.HasSpeed == true then 
		return false
	end
	
	if self.HasFreeze == true then
		return false
	end
	
	self:SetWalkSpeed( 450 )
	self:SetRunSpeed( 450 )
	self.HasSpeed = true
	
	if (SERVER) then
		umsg.Start("Buff_Start", self)
		umsg.End()
	end
	
	timer.Simple( 5, function()
		self:SetWalkSpeed( self:GetBaseSpeed() )
		self:SetRunSpeed( self:GetBaseSpeed() )	
		self.HasSpeed = false
	
		if (SERVER) then
			umsg.Start("Buff_End", self)
			umsg.End()
		end
	end)
	
	return true
end

]]--


--[[
--Makes a player slow, when a player reloads
function TTGPlayer:TTG_Slow(x)
	if self.HasFreeze == true then
		return
	end

	if x == true then
		self.HasSlow = true
		
		self:SetWalkSpeed( 100 )
		self:SetRunSpeed( 100 )	

	else
		self.HasSlow = false

		self:SetWalkSpeed( self:GetBaseSpeed() )
		self:SetRunSpeed( self:GetBaseSpeed() )	
	end
end
]]--



--[[

--Makes a player slowed by sniper rifle firing
function TTGPlayer:TTG_SniperSlow(x)

	if self.HasFreeze == true then
		return
	end

	if x == true then
		self.SniperSlow = true
		
		self:SetWalkSpeed( 60 )
		self:SetRunSpeed( 60 )	
		self:SetJumpPower( 1 )

	else
		self.SniperSlow = false

		self:SetWalkSpeed( self:GetBaseSpeed() )
		self:SetRunSpeed( self:GetBaseSpeed() )	
		self:SetJumpPower( 240 )
	end
end

]]--




function TTGPlayer:SetRoundSpawn(spawn)
	self.RoundSpawn = spawn
end

function TTGPlayer:GetRoundSpawn()
	local spawn = self.RoundSpawn
	return spawn
end






--sets the player's base speed for use by the ttg_slow turning itself off, so the player can be set back to their normal speed
--also actually sets their speed, they begin moving at that speed
--its a more permanent way of setting a players speed
function TTGPlayer:SetBaseSpeed( speed )
	self:SetNWInt( "BaseSpeed", speed ) 
	self:SetWalkSpeed( speed )
	self:SetRunSpeed ( speed ) 
end

function TTGPlayer:GetBaseSpeed()
	return self:GetNWInt( "BaseSpeed", PLAYER_BASE_SPEED ) 
end



--sets the player's base max health
--not yet used
function TTGPlayer:SetBaseHealth( health )
	self:SetNWInt( "BaseHealth", health ) 
	self:SetHealth( health )
	self:SetMaxHealth( health ) 
end

function TTGPlayer:GetBaseHealth()
	return self:GetNWInt( "BaseHealth", 100 ) 
end


--Heal this player by amount, up to their OWN maximum.
--
--Every player heal used to compare against a literal 100. PLAYER_BASE_MAXHEALTH
--is 100, but TTG_HandicapHealth adds to it for a short handed team - so the
--players able to go above 100 are exactly the ones the handicap exists to help,
--and none of them could be healed above it.
--
--First aid was the worst of it. It did not decline to heal someone above 100,
--it called SetHealth( 100 ) - so picking one up at 110 health COST you ten.
--
--Buildings already did this properly: base_ttgentity.lua clamps to ref.health,
--the entity's own maximum. This is that, for players.
function TTGPlayer:TTG_Heal( amount )
	if amount == nil or amount <= 0 then return end

	local newhealth = math.min( self:Health() + amount, self:GetMaxHealth() )

	--never downwards. Somebody already at or above their maximum has nothing to
	--gain here, and trimming them to it is the bug this replaces.
	if newhealth <= self:Health() then return end

	self:SetHealth( newhealth )
end




--sets the player to have the tank passive vars
--not yet used
function TTGPlayer:ActivateTankPassive( health )
	self.BaseSpeed = PLAYER_BASE_TANKSPEED
	self:SetBaseSpeed( self.BaseSpeed )
end














--redo this, put it in the ent itself
/*---------------------------------------------------------
	Meta Table for func_bomb_target only
---------------------------------------------------------*/

local TTGCaptureZone = FindMetaTable("Entity")

function TTGCaptureZone:SetIfActive(bool)
	self:SetNWBool("IsActive", bool) 
end

function TTGCaptureZone:GetIfActive()
	return self:GetNWBool("IsActive", false) 
end





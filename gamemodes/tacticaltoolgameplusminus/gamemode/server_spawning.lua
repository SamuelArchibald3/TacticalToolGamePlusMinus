/*---------------------------------------------------------
	all server files that have to do with players spawning
---------------------------------------------------------*/




--called when a player first enters the server
function GM:PlayerInitialSpawn( ply )

	if G_GameBegun != true then
		ply:SetTeam(TEAM_SPEC)
		ply:PrintMessage( HUD_PRINTTALK, "Welcome, " .. ply:Name() .. "!" )
		
		Open_TeamSetupMenu( ply )
		
		
	elseif G_GameBegun == true then
		ply:SetTeam(TEAM_SPEC)
		ply:PrintMessage( HUD_PRINTTALK, "Welcome, " .. ply:Name() .. "!" )
		
		--if its pub mode, we want to allow the player to join a team even though the game has begun already
		if PUB_MODE == true then
			Open_JoinMenu( ply )
			
		end
	end
end



--called whenever a player spawns
function GM:PlayerSpawn( ply )

	--make spectators fly around
	if (ply:Team() == TEAM_SPEC) then
		ply.DeathSpectate = false
		ply:Spectate( OBS_MODE_ROAMING )
	return end

	
	--have to disable alt key walking, because it breaks the player out of freeze
	ply:SetCanWalk( false )
	
end



--Sets default vars a player should spawn with
function SetSpawnStuff( ply )

	--set eye angles
	//local vec1 = Vector( 0,0,0 ) -- Where we're looking at
	//local vec2 = ply:GetShootPos() -- The player's eye pos
	//ply:SetEyeAngles( ( vec1 - vec2 ):Angle() ) -- Sets to the angle between the two vectors
	//ply:SetEyeAngles(bang)
	//print("setting ang to", bang)
	
	--set base material of the player, so stuff that changes this has it saved to change it back
	ply.TTG_OrigMat = ply:GetMaterial( )
	
	--set base speed, this can be overrriden by certain things, maybe the tank ability slows their speed more
	ply.BaseSpeed = PLAYER_BASE_SPEED
	
	--set base stats of the player
    ply:SetGravity  ( 1 )  
    ply:SetMaxHealth( PLAYER_BASE_MAXHEALTH, true )  
	ply:SetJumpPower( PLAYER_BASE_JUMPPOWER )
    ply:SetBaseSpeed( ply.BaseSpeed )
	ply:SetCrouchedWalkSpeed( PLAYER_BASE_CROUCHMULTIPLIER )
	
	--give the player his default melee weapon
	ply:Give("default_melee")
	
	--set the players model depending on what team theyre on
	if ply:Team() == TEAM_BLUE then
		ply:SetModel( "models/player/combine_soldier.mdl" )
		ply.BaseModel = "models/player/combine_soldier.mdl" 
	elseif  ply:Team() == TEAM_RED then
		ply:SetModel( "models/player/combine_super_soldier.mdl" )
		ply.BaseModel = "models/player/combine_super_soldier.mdl"
	end
	
end



function GM:PlayerSelectSpawn( ply )
	--this is used if the player falls into a trigger_hurt during setup time, he will teleport back to spawn
	if ply.CurRoundSpawn != nil then
		return ply.CurRoundSpawn
	end


	self.SpawnTable = {}
	
	--Set spawn for spectators
	if (ply:Team() == TEAM_SPEC) then
		self.SpawnTable  = ents.FindByClass( "info_player_start" )
	
	elseif (ply:Team() == TEAM_RED) or (ply:Team() == TEAM_BLUE) then
	
		--Allies and counterterrorists are defenders
		if GetTeamRole(ply:Team()) == "Defending" then
			self.SpawnTable = table.Copy( T_Spawns_Avail_Defending )

		--Axis and terrorists are attackers
		elseif GetTeamRole(ply:Team()) == "Attacking" then
		self.SpawnTable = table.Copy( T_Spawns_Avail_Attacking )
		end
	end
	

	
	--If there are no spawn points availible, add any old kind of spawn to the table
	local Count = table.Count( self.SpawnTable  )
	if ( Count == 0 ) then
		Msg("Error! Incorrect spawn points for:  ".. ConvertToTeamName(ply:Team()) .. "\n")
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_terrorist" ) )
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_start" ) )
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_allies" ) )
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_rebel" ) )
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_combine" ) )
		self.SpawnTable = table.Add( self.SpawnTable, ents.FindByClass( "info_player_deathmatch" ) )
	end
	
	local ChosenSpawnPoint = nil
	ChosenSpawnPoint = self.SpawnTable[ math.random( 1, Count ) ]
	
	//remove the spawn from the collective table of availible spawns, so no other player can spawn there
	if GetTeamRole(ply:Team()) == "Defending" then
		table.RemoveByValue( T_Spawns_Avail_Defending, ChosenSpawnPoint )
	elseif GetTeamRole(ply:Team()) == "Attacking" then
		table.RemoveByValue( T_Spawns_Avail_Attacking, ChosenSpawnPoint )
	end
	
	--[[
	//make sure the spawn point is suitable 
	if (ply:Team() != TEAM_SPEC) then
		if not(GAMEMODE:IsSpawnpointSuitable( ply, ChosenSpawnPoint, false)) then
		
			for _, spawn in pairs(self.SpawnTable) do
			
				if(GAMEMODE:IsSpawnpointSuitable( ply, ChosenSpawnPoint, false)) then
					Msg("Found a new suitable spawn")
					ChosenSpawnPoint = spawn
					return ChosenSpawnPoint
				end
			end
		end
	end
	]]--
	

	
	--this spawn will be the player's teleport point if they fall into a trigger_hurt during setup phase
	ply.CurRoundSpawn = ChosenSpawnPoint
	
	return ChosenSpawnPoint
	
end
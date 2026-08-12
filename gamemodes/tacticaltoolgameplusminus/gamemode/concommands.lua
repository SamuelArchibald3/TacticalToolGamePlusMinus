//most of these are used by the GUI client interface






/*---------------------------------------------------------
	Vote
---------------------------------------------------------*/

function fVote( ply, command, arguments )
	if ply.Has_Voted == true then 
		ply:ChatPrint( "You have already voted." )
		return
	else
		ply.Has_Voted = true
	end

	
	
	local function VoteSuccessfulSound()
		umsg.Start("Buy_Successful", player)
		umsg.End()
	end
	
	--returns true if the player should be able to vote right now, depending on if hes spec
	local function CanVoteCheck( guy )
		if G_CurrentPhase == "GameSetup" then
			--everyone can vote in gamesetup
			return true
		else
			if guy:Team() == TEAM_SPEC then
				--spectators can vote if atleast one of the teams has only 1 player
				if team.NumPlayers( TEAM_RED ) <= 1 or team.NumPlayers( TEAM_BLUE ) <= 1 then
					return true
				end
				guy:ChatPrint( "Cant vote as a spectator during the game (except in cases of minimal players) " )
				return false
			else
				return true
			end
		end
	end
	
	
	local dothis = arguments[1]
	local arg = arguments[2]
	
	
	
	
	
	
	if dothis == "kick" then
		if CanVoteCheck( ply ) != true then return end
	
		local v = player.GetByUniqueID( arg )
		v:SetVotesInt( v:GetVotesInt() + 1 )

		VoteSuccessfulSound()

	elseif dothis == "restart" then	
		if CanVoteCheck( ply ) != true then return end
	
		local votesfalse = GetGlobalInt( "CL_BoolVotes_false" )
		local votestrue = GetGlobalInt( "CL_BoolVotes_true" )
		
		if arg == "false" then
			SetGlobalInt( "CL_BoolVotes_false", votesfalse + 1 )
		elseif arg == "true" then
			SetGlobalInt( "CL_BoolVotes_true", votestrue + 1 )
		end

		VoteSuccessfulSound()
		
	elseif dothis == "map" then	
		if CanVoteCheck( ply ) != true then return end
	
		ply:SetChangeMap( arg )
		VoteSuccessfulSound()
	end
end
concommand.Add( "ttg_vote", fVote )








/*---------------------------------------------------------
	Restart Game
---------------------------------------------------------*/
--Command to restart the game completely, only admins can do it

function fRestart( player, command, arguments )
	if not player:IsAdmin() then return end

	GameRestart()

end
concommand.Add( "ttg_restart", fRestart )





/*---------------------------------------------------------
	Join Team
---------------------------------------------------------*/
--Command to join a team during the Team Setup

function fJoinTeam( player, command, arguments )

	if G_GameBegun == true then return end

	local theteam = nil
	if arguments[1] == "TEAM_RED" then
	theteam = TEAM_RED
	elseif arguments[1] == "TEAM_BLUE" then
	theteam = TEAM_BLUE
	elseif arguments[1] == "TEAM_SPEC" then
	theteam = TEAM_SPEC
	end
	
	if theteam != TEAM_SPEC then
	
		--dont allow the player to join if the team has enough players already
		if RESTRICT_PLAYERS_PER_TEAM == true then
			if team.NumPlayers(theteam) >= PLAYERS_PER_TEAM then
				return
			end
		end
	
	
	//if theteam != TEAM_SPEC then
		player:SetTeam(theteam)
	elseif theteam == TEAM_SPEC then
		player:SetTeam(theteam)
	end
end
concommand.Add( "gc_jointeam", fJoinTeam )





/*---------------------------------------------------------
	Ready Up Toggle
---------------------------------------------------------*/
--Command to ready up during the Team Setup
--Takes 3 commands: "false", "true", "togggle"

function fGCReady( player, command, arguments )

	if G_GameBegun == true then return end

	if arguments[1] == "false" then 
		player:SetReady(false)
		
	elseif arguments[1] == "true" then 
		player:SetReady(true)
		
	elseif arguments[1] == "toggle" then
		prev_ready = player:GetIfReady()
		if prev_ready == false then
			player:SetReady(true)
		elseif prev_ready == true then
			player:SetReady(false)
		end
	end
end
concommand.Add( "gc_readytoggle", fGCReady )









/*---------------------------------------------------------
	Give Tool
---------------------------------------------------------*/

--Command to buy a purchase
function fGiveTool( player, command, arguments )
	local purchase = arguments[1]
	
	//plays the buy failed buzz sound
	local function BuyFailedSound()
		umsg.Start("Buy_Failed", player)
		umsg.End()
	end
	
	//plays the buy success sound
	local function BuySuccessfulSound()
		umsg.Start("Buy_Successful", player)
		umsg.End()
	end
	
	
	
	
	/*---------------------------------------------------------
		Preliminary checks, making sure phase is valid and such
	---------------------------------------------------------*/
	
	//if the player is a spectator then return end
	if player:Team() == TEAM_SPEC then
		player:ChatPrint("Can't buy as spectator")
		BuyFailedSound()
		return 
	end
	
	
	//if the purchase isnt in the list, dont do anything further
	if not CheckIfInShopTables(purchase) then
		player:ChatPrint("invalid purchase")
		BuyFailedSound()
		return 
	end
	
	
	//if the player's team is not able to buy at the moment, return end
	if GetTeamRole(player:Team()) == "Attacking" then
		 if G_CurrentPhase != "AttackersBuy" then
		 player:ChatPrint("Cant buy, it's not your team's turn!")
		 BuyFailedSound()
		 return
		 end
	elseif GetTeamRole(player:Team()) == "Defending" then
		if G_CurrentPhase != "DefendersBuy" then
		 player:ChatPrint("Cant buy, it's not your team's turn!")
		 BuyFailedSound()
		 return
		 end
	end
	
	
	
	
	local purchaseref = Shop_Reference(purchase)
		local tool_class = purchaseref.class
		
	
	
	
	/*---------------------------------------------------------
		if it's a Gun
	---------------------------------------------------------*/
	if tool_class == "gun" then
		
		--[[
		//if the player already has a gun, he cannot be given this gun ( cannot have 2 types of guns at same time )
		if player:GetIfHasGun() and not player:HasWeapon(purchaseref.tool_name) then
			player:ChatPrint("You can only select 1 kind of Weapon Tool per round!")
			BuyFailedSound()
			return
		end
		]]--
		
		//try to subtract the cost, but if it fails, print to the player he does not have enough money, and cancel buy
		if not player:SubtractToolTokens(1) then
			player:ChatPrint("No tool slots left!")
			BuyFailedSound()
			return 
		end
		
		
		
		//if the player has the gun, then amplify the gun they aready have, increasing its clipsize and rate of fire speed
		if player:HasWeapon(purchaseref.tool_name) then
			
			local swep = player:GetWeapon( purchaseref.tool_name )
			local cur_amount = swep:GetNumGuns()
			
			swep:AddOneGun( )
			
			--Networks the sweps info
			player:SetSwepToolInfo( swep:GetClass(), swep:GetTTGAmmo(), swep:GetNumGuns() )
			
			//swep:SetTTGAmmo(swep:Clip1() + purchaseref.pack_amount)
			BuySuccessfulSound()
			return

			
		//if the player does not have this kind of gun already, give him one
		else
		
			player:SetIfHasGun( true )
			player:Give(purchaseref.tool_name)
			
			--Networks the sweps info
			local swep = player:GetWeapon( purchaseref.tool_name )
				player:SetSwepToolInfo( swep:GetClass(), swep:GetTTGAmmo(), swep:GetNumGuns() )
			
			BuySuccessfulSound()
			return
		end
		
		
		
	/*---------------------------------------------------------
		if it's an Item
	---------------------------------------------------------*/
	elseif tool_class == "item" then

		//try to subtract the cost, but if it fails, print to the player he does not have enough money
		if not player:SubtractToolTokens(1) then
			player:ChatPrint("No tool slots left!")
			BuyFailedSound()
			return 
		end
	
		//if the player already has this purchase, add the pack amount to the ammo it already has.
		if player:HasWeapon(purchaseref.tool_name) then

			local swep = player:GetWeapon(purchaseref.tool_name)
			
			swep:SetTTGAmmo(swep:Clip1() + purchaseref.pack_amount) --this is needed cause Clip1 is fucked up for clients reading it
			swep:SetClip1(swep:Clip1() + purchaseref.pack_amount)
			
			--Networks the sweps info
			player:SetSwepToolInfo( swep:GetClass(), swep:GetTTGAmmo(), swep:GetNumGuns() )
			
			BuySuccessfulSound()
			return
			
		else
		
			player:Give(purchaseref.tool_name)
			local swep = player:GetWeapon(purchaseref.tool_name)
			
			
			//set the ammo to be the pack amount
			swep:SetClip1(purchaseref.pack_amount)	--sets the ammo in the actual swep
			swep:SetTTGAmmo(purchaseref.pack_amount) --this is needed cause Clip1 is fucked up for clients reading it and displaying it

			--Networks the sweps info
			player:SetSwepToolInfo( swep:GetClass(), swep:GetTTGAmmo(), swep:GetNumGuns() )
			
			BuySuccessfulSound()
			return
		end
		
		
		
	/*---------------------------------------------------------
		if it's an Ability
	---------------------------------------------------------*/	
	elseif tool_class == "ability" then
	
	
		//try to subtract the cost, but if it fails, print to the player he does not have enough money
		if not player:SubtractToolTokens(1) then
			player:ChatPrint("No tool slots left!")
			BuyFailedSound()
			return 
		end
	
	
		//Give player the ability tool
		local abil = ents.Create(purchaseref.tool_name)
			abil:SetOwner(player)
			
		//set what slot this ability will be in
		//	A = Shift
		//	B = Z
		//	C = Alt
		if player.Ability_A == nil then
			player.Ability_A = abil
			abil.LetterSlot = "a"
		elseif player.Ability_B == nil then
			player.Ability_B = abil
			abil.LetterSlot = "b"
		elseif player.Ability_C == nil then
			player.Ability_C = abil
			abil.LetterSlot = "c"
		end
		
		abil:Spawn()
		BuySuccessfulSound()
		return
	end


	
end
concommand.Add( "ttg_givepurchase", fGiveTool )








/*---------------------------------------------------------
	Set Aim Target
---------------------------------------------------------*/
--sets the target the player is looking at currently to do an ability on
--works with things like the heal gun, tractor beam, etc
--auto aim basically


--[[
function fSetAimTarget( commander, command, arguments )

	local ply_aim_id = arguments[1]
	//print(ply_aim_id)
	local ply_aim = player.GetByUniqueID( ply_aim_id )
	
	//print( "setting aim target of " .. commander:GetName() .. " to " .. ply_aim:GetName() )
	commander:SetAimTarget( ply_aim )
	
end
concommand.Add( "ttg_setaimtarget", fSetAimTarget )

]]--










/*---------------------------------------------------------
	Join Team Next Round
---------------------------------------------------------*/
--Command to join a team if the game has already begun and the player is joining late
--also switches teams


--[[
function fJoinTeamNextRound( ply, command, arguments )
	//if we arent in pub mode, players cannot join while a game is already in progress
	if PUB_MODE != true then return end

	//if the game hasnt begun, this command does not work
	if G_GameBegun != true then return end

	
	/*---------------------------------------------------------
		local functions
	---------------------------------------------------------*/	
	
	//plays the buy failed buzz sound
	local function FailedSound()
		umsg.Start("Buy_Failed", ply)
		umsg.End()
	end
	
	//plays the buy success sound
	local function SuccessfulSound()
		umsg.Start("Buy_Successful", ply)
		umsg.End()
	end
	
	//returns the opposing team to the input
	local function OppTeam( theteam )
		if theteam == TEAM_RED then
			return TEAM_BLUE
		else
			return TEAM_RED
		end
	end
	
	
	local function TotalNumPlayers( theteam )
		local t = nil
		if theteam == TEAM_BLUE then
			t = T_BlueJoiners
		else
			t = T_RedJoiners
		end
		local Count = table.Count( t )
		
		return team.NumPlayers( theteam ) + Count
	end
	
	local function JoinSpec()
		//if theyre already on spec, dont do anything
		if ply:Team() == TEAM_SPEC then return end
	
		if ply:Team() == TEAM_RED or ply:Team() == TEAM_BLUE then
			ply:Kill()
			if G_CurrentPhase == "DefendersBuy" or G_CurrentPhase == "AttackersBuy" or G_CurrentPhase == "Planning" then
				Close_BuyingMenusForPly( ply )
			end
		end
	
		ply:SetTeam( TEAM_SPEC )
		ply:Freeze( false )
		ply:TTG_Freeze( false )
		ply:Spawn()
		ply:Spectate( OBS_MODE_ROAMING )
	end

	
	local function RemoveJoiningTableValues( ply )
		if table.HasValue( T_RedJoiners, ply ) then
			table.RemoveByValue( T_RedJoiners, ply )
		end
			
		if table.HasValue( T_BlueJoiners, ply ) then
			table.RemoveByValue( T_BlueJoiners, ply )
		end
	end
	
	
	
	/*---------------------------------------------------------
		do the command
	---------------------------------------------------------*/	
	
	local jointeam = math.floor( arguments[1] )
	
	
	if jointeam == TEAM_SPEC then
		RemoveJoiningTableValues( ply )
	
		ply:SetJoiningTeam( "none" )
	
		ply:ChatPrint("Joining Spectators...")
		SuccessfulSound()
		Close_JoinMenu( ply )
		
		JoinSpec( ply )
		
		
	elseif jointeam == TEAM_RED or jointeam == TEAM_BLUE then
		
		//if the player is trying to join the team theyre already on, do nothing and close out
		if jointeam == ply:Team() or jointeam == ply:GetJoiningTeam() then
			ply:ChatPrint("You're already on that team.")
			SuccessfulSound()
			Close_JoinMenu( ply )
			return
		end
		
		//if one team has too many players, and the players trying to join it, do nothing and scold the player
		if (TotalNumPlayers( jointeam ) - TotalNumPlayers( OppTeam( jointeam ))) >= 1 then
			ply:ChatPrint("That team has too many players.  You cannot join it!")
			FailedSound()
			return
		end
		
		//if the player is trying to join the team hes already on, do nothing
		if jointeam == ply:Team() then
			ply:ChatPrint("You're already on that team")
			FailedSound()
			return
		end
		
		
		//add the player to the joining table depending on which team they chose.
		if jointeam == TEAM_RED then
			RemoveJoiningTableValues( ply )
		
			table.insert( T_RedJoiners, ply )
			
			ply:SetJoiningTeam( TEAM_RED )
			
			ply:ChatPrint("Joining red team.  Will begin playing after the current round...")
			SuccessfulSound()
			Close_JoinMenu( ply )
			
			JoinSpec( ply )

			
		elseif jointeam == TEAM_BLUE then
			RemoveJoiningTableValues( ply )
			
			table.insert( T_BlueJoiners, ply )
			
			ply:SetJoiningTeam( TEAM_BLUE )
			
			ply:ChatPrint("Joining blue team.  Will begin playing after the current round...")
			SuccessfulSound()
			Close_JoinMenu( ply )
			
			JoinSpec( ply )

		end
		
		
	end
	
	
end
concommand.Add( "ttg_jointeamnextround", fJoinTeamNextRound )
]]--








/*---------------------------------------------------------
	Join Spec
---------------------------------------------------------*/

--[[
function fJoinSpec( ply, command, arguments )
	Close_JoinMenu( ply )
end
concommand.Add( "ttg_joinspec", fJoinSpec )
]]--
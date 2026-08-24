//called at the start of every new round, resets things, switches team roles
function NextRound()

	--Stop the last round's alive check BEFORE the flags are reset.
	--
	--It is a Think hook, and only WinningPhase ever ended it. A round decided by
	--the last player dying, or by a capture, awards its point and schedules this
	--function without going through WinningPhase at all, so the hook was still
	--running. Harmless while G_WinAlreadyTriggered is set - which is the very
	--thing the next line clears, with nobody respawned yet, leaving a live check
	--staring at a team with no living players. It scored the round a second time.
	End_TeamsAliveCheck()

	ResetVarsBetweenRounds()
	
	--[[
	//join all players who signed up to join last round, if pub mode is on
	if PUB_MODE == true then
		NextRoundJoinAllPlayers()
	end
	]]--
	
	--end the whole game if one team has no players at all
	if DEV_MODE != true then
		local redplys = team.NumPlayers( TEAM_RED )
		local blueplys = team.NumPlayers( TEAM_BLUE )
	
		if redplys == 0 then
			GameRestart()
			ChatPrintToAll( "All of red team's players have left, restarting!" )
			return
		end
		if blueplys == 0 then
			GameRestart()
			ChatPrintToAll( "All of blue team's players have left, restarting!" )
			return
		end
	end
	
	//set all spawns to be availible
	SetupRoundSpawnTables()
	
	--Remove all leftover TTG ents in the world.  (for example: barriers, invis reveal devices, etc) And Abilities as well
	RemoveAllGameEnts()
	
	
	--Never start a round for a game that is already decided.
	--
	--Checked BEFORE the round number moves. It used to increment and network the
	--new round first, so a decided game published a round one past the last one
	--and every client drew "TIE BREAKER" across the final score until the map
	--reset - GameEnd does not put the round back.
	--
	--The usual place this is caught is EndRound, right after the winning point is
	--awarded. This is the backstop for a score that got there some other way, and
	--it defers to TTG_TeamThatHasWon() so it can no longer disagree with that
	--check the way the old hardcoded "> 2" did.
	--
	--Ends through GameEnd() rather than ttg_restart, so the winner is announced and
	--the winning phase plays out instead of the map simply resetting, and returns
	--so the rest of NextRound does not set up a round that is about to be thrown
	--away.
	local gamewinner = TTG_TeamThatHasWon()
	if gamewinner then
		GameEnd( gamewinner )
		return
	end

	G_CurRound = G_CurRound + 1
	SetRound(G_CurRound)

	--if its not the first round, then flip around the teams roles
	if G_CurRound != 1 then
		if GetTeamRole(TEAM_RED) == "Attacking" then
			SetTeamRole(TEAM_RED, "Defending")
			SetTeamRole(TEAM_BLUE, "Attacking")
		elseif GetTeamRole(TEAM_RED) == "Defending" then
			SetTeamRole(TEAM_RED, "Attacking")
			SetTeamRole(TEAM_BLUE, "Defending")
		end
	end

	
	--Checks if this will be a tie breaker round, randomly gives roles out
	if TTG_IsTiebreakRound() then
		--Set the roles randomly for the first round
		local rand = math.random(2)
		
		if rand == 1 then
			SetTeamRole(TEAM_RED, "Defending")
			SetTeamRole(TEAM_BLUE, "Attacking")
		elseif rand == 2 then
			SetTeamRole(TEAM_RED, "Attacking")
			SetTeamRole(TEAM_BLUE, "Defending")
		end
	end




	//the roles for this round are settled above, so push them to every client
	BroadcastTeamRoles()

	//work out what uneven teams are worth this round, before anyone spawns or
	//any buy menu opens
	TTG_ApplyHandicaps()


	//set the zone the teams are vying for control over to be at one of the bomb sites of the de_ map
	ChooseAttackSite()

	//makes it constantly make sure atleast one person on each team is alive, otherwise end the round
	Start_TeamsAliveCheck()
	Start_TriggerHurtCheck()
	
	for k,v in pairs(player.GetAll()) do	
		if v:Team() != TEAM_SPEC then
			-- take away all the players tools from the previous round
			v:StripWeapons()
		
			--make sure they arent in specate mode like they are when theyre dead
			v:UnSpectate()
		
			--spawn all players, except specs
			v:Spawn()
		
			--sets the default stuff for the player, speed, model, default_melee, etc
			SetSpawnStuff( v )
		
			--lock all players so they cant move at all while the buying screen is open
			v:Freeze( true )
			
			--Set everyones tokens for the round. See TTG_RoundStartTokens() in
			--ingame_functions.lua - the tie breaker round can hand out none.
			v:SetToolTokens( TTG_RoundStartTokens( v ) )
			
			--Give attackers god mode so they cant be killed in setup phase later.
			--
			--The tie breaker has no setup phase to protect them through, so
			--there is nothing for it to do there but hand one side a few free
			--seconds of the fight.
			if GetTeamRole(v:Team()) == "Attacking" and not TTG_IsTiebreakRound() then
				v:TTG_Invuln( true )
				//v:TTG_Freeze( true )
			end
		end
	end
	
	
	DefendersBuyPhase()
	
	CloseAttackersDoors()
end



function DefendersBuyPhase()
	G_CurrentPhase = "DefendersBuy"
	Open_BuyingMenus()
	
	//runs on tick, checking if all of the currently buying team has bought 
	Start_CheckIfPlayersBought()

	//plays buying bell sound for defending players
	for k,v in pairs(player.GetAll()) do	
		if v:Team() != TEAM_SPEC then
			if GetTeamRole(v:Team()) == "Defending" then
				umsg.Start("Sound_TurnToBuy", v)
				umsg.End()
			end	
		end
	end
	
	//resend the roles at the start of the phase, so a client that somehow missed
	//the round-start push is corrected here rather than showing a stale role
	BroadcastTeamRoles()

	SetBuyingRole("Defending")

	SetGamePhase("DefendersBuy")
	
	SetGlobalBool("CL_PlayTimerCountSounds", false)
	InitializeGCTime(DEFENDERSBUYPHASE_TIME, AttackersBuyPhase)
end



function AttackersBuyPhase()
	G_CurrentPhase = "AttackersBuy"
	//Update_EnemyPurchasesVgui()

	//plays buying bell sound for attacking players
	for k,v in pairs(player.GetAll()) do	
		if v:Team() != TEAM_SPEC then
			if GetTeamRole(v:Team()) == "Attacking" then
				umsg.Start("Sound_TurnToBuy", v)
				umsg.End()
			end	
		end
	end
	
	//resend the roles at the start of the phase, same reasoning as above
	BroadcastTeamRoles()

	SetBuyingRole("Attacking")

	SetGamePhase("AttackersBuy")
	
	InitializeGCTime(ATTACKERSBUYPHASE_TIME, PlanningPhase)
end



function PlanningPhase()
	G_CurrentPhase = "Planning"
	//Update_EnemyPurchasesVgui()
	
	End_CheckIfPlayersBought()
	
	//plays the buying done sound
	umsg.Start("Sound_BuyingDone")
	umsg.End()
	
	SetBuyingRole("None")
	
	SetGamePhase("Planning")

	InitializeGCTime(PLANNINGPHASE_TIME, SetupPhase)
end




function SetupPhase()
	G_CurrentPhase = "Setup"

	Close_BuyingMenus()
	
	

	for k,v in pairs(player.GetAll()) do
		
		--unlock all players, attacking team will still be frozen and invulnerable
		v:Freeze( false )
		
		//print("this is his default crouch speed multiplier",v:GetCrouchedWalkSpeed())
		
		if GetTeamRole(v:Team()) == "Defending" then
			v:SetBaseSpeed( PLAYER_BASE_SPEED_SETUP )
			v:SetCrouchedWalkSpeed( PLAYER_BASE_CROUCHMULTIPLIER_SETUP )
		end
--check if any players are alive on one team and end the round if not
local CaptureTime = nil
--global var which says what mode the capture timer is in
G_CurCaptureMode = "none"
			--"capturing"
			--"reversing"
			--"stuck"

--global var which says if the capture time is moving at all
G_CaptureTimeMoving = false



/*---------------------------------------------------------
	Capture Zone Capturing
---------------------------------------------------------*/



function Start_CaptureCheck()
	hook.Add("Think", "ChangeCapture", ChangeCapture)
end

function End_CaptureCheck()
	hook.Remove("Think", "ChangeCapture")
	
	--turns off the capture hud thing if its still on for some reason
	umsg.Start( "IfCaptureOn" )
    umsg.Bool( false )
	umsg.End()
end



--runs on think
--this will need to be modified when i add roles for the teams, now it bases roles off colors
function ChangeCapture()
	if G_CurAttackZone == nil then return end
	local plylist = G_CurAttackZone.TouchingPlyList

	local attacker_touching = false
	local defender_touching = false
	for _, ply in pairs(plylist) do
		if ply:Team() != TEAM_SPEC then
			if GetTeamRole(ply:Team()) == "Attacking" then
				attacker_touching = true
			elseif GetTeamRole(ply:Team()) == "Defending" then
				defender_touching = true
			end
		end
	end
	
	if G_CurCaptureMode == "none" then
		if attacker_touching and not defender_touching then
			InitializeCapture()
		end
		
	elseif G_CurCaptureMode == "capturing" then
		if defender_touching and not attacker_touching then
			G_CurCaptureMode = "reversing"
		elseif defender_touching and attacker_touching then
			G_CurCaptureMode = "stuck"
		end
		
	elseif G_CurCaptureMode == "reversing" then
		if attacker_touching and not defender_touching then
			G_CurCaptureMode = "capturing"
		elseif defender_touching and attacker_touching then
			G_CurCaptureMode = "stuck"
		end
		
	elseif G_CurCaptureMode == "stuck" then
		if attacker_touching and not defender_touching then
			G_CurCaptureMode = "capturing"
		elseif defender_touching and not attacker_touching then
			G_CurCaptureMode = "reversing"
		end
		
	end
end





local FirstCheck = false
local CaptureTime = nil
local NextAddTime = nil


--called when an attacker touches the func_bomb_zone and begins the capture process
function InitializeCapture()
	--sets the time to be going down
	G_CurCaptureMode = "capturing" 
	
	G_CaptureTimeMoving = true
	
	--tells everyones hud to start drawing the capture graphic.
	umsg.Start( "IfCaptureOn" )
    umsg.Bool( G_CaptureTimeMoving )
	umsg.End()
	
	--announces to red team in voice that their zone is being captured
	for k,v in pairs(player.GetAll()) do
		if GetTeamRole(v:Team()) == "Defending" then
			umsg.Start("Announcer_Capture", v)
			umsg.End()
		end
	end
	
	--sets the time to be equal to the full amount right when it starts to count down
	CaptureTime = TIME_TO_CAPTURE
	
	NextAddTime = CurTime() + 1
	CaptureHUDUpdate()
end

function CaptureZoneTime()
	if G_CaptureTimeMoving == true then
		if (CurTime() >= NextAddTime) then
			NextAddTime = CurTime() + 1
			
			if G_CurCaptureMode == "capturing" then
				CaptureTime = CaptureTime - 1
			elseif G_CurCaptureMode == "reversing" then
				CaptureTime = CaptureTime + 1
				if CaptureTime >= TIME_TO_CAPTURE then --if the time is reversed all the way back up to its max
					TurnOffCapture()
				end
			elseif G_CurCaptureMode == "stuck" then
				CaptureTime = CaptureTime
			end
			
			CaptureHUDUpdate()
			
			--if it reaches 0 then the attackers have captured the zone, so they win
			if CaptureTime <= 0 then
				CapturedByAttackers()
			end
		end
	end
end
hook.Add("Think", "CaptureZoneTime", CaptureZoneTime)


function TurnOffCapture()
	G_CaptureTimeMoving = false
	G_CurCaptureMode = "none"
	
	umsg.Start( "IfCaptureOn" )
    umsg.Bool( G_CaptureTimeMoving )
	umsg.End()
	
	if G_Overtime == true then
		local defenders = nil
		if GetTeamRole(TEAM_RED) == "Defending" then
			defenders = TEAM_RED
		elseif GetTeamRole(TEAM_BLUE) == "Defending" then
			defenders = TEAM_BLUE
		end
	
		WinningPhase( defenders )
	end
end


function CapturedByAttackers()
	if G_WinAlreadyTriggered == true then return end

	G_CaptureTimeMoving = false
	G_CurCaptureMode = "none"
	End_CaptureCheck()

	local attackers = nil
	if GetTeamRole(TEAM_RED) == "Attacking" then
		attackers = TEAM_RED
	elseif GetTeamRole(TEAM_BLUE) == "Attacking" then
		attackers = TEAM_BLUE
	end

	--no attacking team means no capture happened, and passing nil to
	--WinningPhase would silently award the round to the defenders
	if attackers == nil then return end

	--how it was won, in chat. The centre of the screen belongs to the round
	--win message WinningPhase prints, so this does not fight it for the space.
	ChatPrintToAll( ConvertToTeamName( attackers ) .. " wins the round by capping!" )

	--Everything else is WinningPhase's job: the point, the game-win check, the
	--tie breaker check, disabling ents, the phase, the announcer and the next
	--round. This used to do a third of that by hand and skip the rest.
	WinningPhase( attackers )
end


function CaptureHUDUpdate()
	umsg.Start( "CaptureUpdate" )
    umsg.String( CaptureTime )
	umsg.End()
end

--A team being wiped out ends the round, same as the timer running out or the
--zone being capped. All three now go through WinningPhase.
--
--This branch used to award the point itself and schedule the next round, which
--meant skipping everything else WinningPhase does. Three things came out of
--that, beyond BUG-11:
--
--  * the phase was never set to "Winning", so clients still read COMBAT for the
--    three seconds between the last death and the next round
--  * the tie breaker check never ran, so a level game whose last round ended by
--    a wipe went to the next round instead of a decider
--  * the announcer block that belongs here was written at file scope below the
--    hook rather than inside it. It ran once, at load, with no players and
--    `winners` still nil - so a round won by a wipe played no sound at all
hook.Add( "PlayerDeath", "GlobalDeathMessage", function( victim, inflictor, attacker )
	if G_WinAlreadyTriggered == true then return end

	local deadteam = victim:Team()
	if deadteam != TEAM_RED and deadteam != TEAM_BLUE then return end

	--the round is only over if nobody on their side is still standing
	for _, v in pairs( team.GetPlayers( deadteam ) ) do
		if v:Alive() then return end
	end

	local winners = TEAM_BLUE
	if deadteam == TEAM_BLUE then
		winners = TEAM_RED
	end

	--WinningPhase ends the capture check itself, but not the zone display
	TurnOffCapture()

	WinningPhase( winners )
end)
hook.Add("PlayerDeath", "spectateOnDeath", function(victim, inflictor, attacker)
    if victim:IsValid() and victim:IsPlayer() then
        Reset_PlyAbilities(victim)
        hook.Add("KeyPress", "SpectatorKeyPress", function(ply, key)
            if ply == victim and key == IN_ATTACK then
 
                local players = player.GetAll()

                for k, v in pairs(players) do
                    if v == victim then table.remove(players, k) end
                end

                if #players > 0 then

                    local currentTarget = ply:GetObserverTarget()

                    if not IsValid(currentTarget) or not currentTarget:IsPlayer() or not table.HasValue(players, currentTarget) then
                        currentTarget = players[1]
                    else
                        for i, player in ipairs(players) do
                            if player == currentTarget then
                                currentTarget = players[i + 1] or players[1]
                                break
                            end
                        end
                    end

                    ply:Spectate(OBS_MODE_CHASE)
                    ply:SpectateEntity(currentTarget)
                end
            end
        end)
    end
end)

hook.Add("PlayerSpawn", "removeSpectatorKeyPress", function(ply)
    hook.Remove("KeyPress", "SpectatorKeyPress")
end)
-- hook.Add("PlayerDeath", "spectateOnDeath", function(victim, inflictor, attacker)

-- victim:SpectateEntity (attacker)
-- victim:Spectate(OBS_MODE_DEATHCAM)

-- timer.Simple(0.75, function()
-- if not IsValid(victim) or not IsValid(attacker) then return end
-- victim: SetObserverMode(OBS_MODE_FREEZECAM)

-- timer.Simple(1.25, function()
-- if not IsValid(victim) or not IsValid(attacker) then return end
-- victim: SetObserverMode(OBS_MODE_CHASE)
-- end)
-- end)
-- end)
	--A third copy of the round-setup player loop used to sit here, wrapped in
	--timer.Simple( 99999999, ... ) - about 3.17 years, so it never ran. It sat
	--among the commented-out spectateOnDeath experiments above, which is fairly
	--clearly what it was: abandoned work on respawning.
	--
	--Removed because a copy that looks live but is not is worse than no copy:
	--it was counted as one of the three round-setup blocks that had to be kept
	--in step, and edits were made to it that could never have had any effect.
end






	--The tie breaker skips the setup phase and goes straight to fighting.
	--
	--It skips the WAIT, not the work: everything above this still runs, which
	--is the point. Setup is where the buy menus are closed and where everyone
	--is unfrozen, and CombatPhase does neither - wiring planning directly to
	--combat would start the decider with everybody frozen and their buy menu
	--still open. Defenders get their setup speed set just above and CombatPhase
	--puts it straight back, which costs nothing and keeps one code path.
	if TTG_IsTiebreakRound() then
		CombatPhase()
		return
	end

	SetGamePhase("Setup")

	SetGlobalBool("CL_PlayTimerCountSounds", true)

	InitializeGCTime(SETUPPHASE_TIME, CombatPhase)
end


function CombatPhase()
	G_CurrentPhase = "Combat"

	--keys are settled once the fighting starts
	Close_AbilityKeysMenus()
	
	Start_CaptureCheck()
	
	OpenAttackersDoors()
	
	End_TriggerHurtCheck()

	//plays the sound of the announcer saying "fight!"
	umsg.Start("Announcer_Fight")
	umsg.End()
	
	for k,v in pairs(player.GetAll()) do
	
		--set the defending players movement speed back to default
		if GetTeamRole(v:Team()) == "Defending" then
			v:SetBaseSpeed( v.BaseSpeed )
			v:SetCrouchedWalkSpeed( PLAYER_BASE_CROUCHMULTIPLIER )
		end
	
		

		--unfreeze attackers and take away god mode after a few seconds
		if GetTeamRole(v:Team()) == "Attacking" then
			//v:TTG_Freeze( false )
			
			timer.Simple(BEGINNING_INVULN_TIME, function()
				v:TTG_Invuln( false )
			end)
		end

	end

	SetGamePhase("Combat")
	
	InitializeGCTime(COMBATPHASE_TIME, WinningPhase)
end



function WinningPhase(winners)
	//this makes sure the win isnt triggered twice
	if G_WinAlreadyTriggered == true then return end
	G_WinAlreadyTriggered = true

	//checks if it was buying phase when one of the teams won for some weird reason, and if so, closes the menus
	if G_CurrentPhase == "AttackersBuy" or G_CurrentPhase == "DefendersBuy" or G_CurrentPhase == "Planning" then
		Close_BuyingMenus()
	end
	
	//sets the phase to winning
	G_CurrentPhase = "Winning"
	
	
	End_CaptureCheck()
	End_TeamsAliveCheck()

	
	--if the win was triggered by time running out, then make it so defenders won the round
	if winners == nil then
		if GetTeamRole(TEAM_RED) == "Defending" then
			winners = TEAM_RED
		elseif GetTeamRole(TEAM_BLUE) == "Defending" then
			winners = TEAM_BLUE
		end
	end
	
	--give the winners of the round a point
	team.AddScore(winners, 1)
	
	
	--if a team has enough points to straight up win the game, then end the game with that team being the winner
	--( shared with the backstop in NextRound - see TTG_TeamThatHasWon in ingame_functions.lua )
	local gamewinner = TTG_TeamThatHasWon()
	if gamewinner then
		GameEnd( gamewinner )
		return
	end

	
	
	
	--if this was the last round and both teams have the same score then go to a tiebreaker round
	if G_CurRound == G_TotalRounds then
		if team.GetScore(TEAM_RED) == team.GetScore(TEAM_BLUE) then
			for k,v in pairs(player.GetAll()) do
				v:PrintMessage( HUD_PRINTCENTER, "There's gonna have to be a tie breaker round...")
			end
			
			--makes it so it wont play the announcer counting down sounds
			SetGlobalBool("CL_PlayTimerCountSounds", false)
			
			InitializeGCTime(3, NextRound)
			return
		end
	end
	
	
	
	--if it was a tiebreaker round then have the winners of the round win the whole game
	if TTG_IsTiebreakRound() then
		GameEnd(winners)
		return
	end
	
	--prints to all players telling them who won
	for k,v in pairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTCENTER, ConvertToTeamName(winners) .. " wins the round!")
		//print( "this is the winning teams number to debug:", winners )
		if GetTeamRole(winners) == "Defending" then
			if GetTeamRole(v:Team()) == "Defending" then
				umsg.Start("Announcer_Success", v); umsg.End()
			elseif GetTeamRole(v:Team()) == "Attacking" then
				umsg.Start("Announcer_Failure", v); umsg.End()
			end
			
		elseif GetTeamRole(winners) == "Attacking" then
			if GetTeamRole(v:Team()) == "Defending" then
				umsg.Start("Announcer_Failure", v); umsg.End()
			elseif GetTeamRole(v:Team()) == "Attacking" then
				umsg.Start("Announcer_Success", v); umsg.End()
			end
		end
	end
	

	--makes it so it wont play the announcer counting down sounds
	SetGlobalBool("CL_PlayTimerCountSounds", false)

	
	--disables stuff like the sentry gun, proximity mines, etc
	DisableAllEnts()
	
	SetGamePhase("Winning")
	
	InitializeGCTime(3, NextRound)
end




/*-------------------------------------------------------------------------------------------------------------------
	Game End
--------------------------------------------------------------------------------------------------------------------*/



function GameEnd(winners)
	local winners_name = ConvertToTeamName(winners)


	for k,v in pairs(player.GetAll()) do
		v:PrintMessage( HUD_PRINTCENTER, winners_name .. " won the whole game! Restarting in " .. WINNINGPHASE_TIME .. " seconds.")
	end

	--makes it so it wont play the announcer counting down sounds
	SetGlobalBool("CL_PlayTimerCountSounds", false)
	
	SetGamePhase("GameEnd")
	
	InitializeGCTime(5, GameRestart)


end

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
end)
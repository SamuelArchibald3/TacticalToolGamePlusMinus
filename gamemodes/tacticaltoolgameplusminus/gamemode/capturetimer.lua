/*---------------------------------------------------------
	Capture Zone Capturing
---------------------------------------------------------*/
--The only home for the capture system.
--
--It existed twice: here and in ingame.lua, both defining the same eight global
--functions and both registering the same Think hook at file scope. init.lua
--includes ingame.lua at line 88 and this file at line 91, so whichever came
--last silently won - and that was this file, holding the older copy.
--
--Three fixes written into ingame.lua's version were therefore never running:
--
--  * the G_WinAlreadyTriggered guard, so a capture could score a round that had
--    already been decided - BUG-11 by another route
--  * the nil-attackers guard, without which a capture with no attacking team
--    calls WinningPhase( nil ) and quietly hands the round to the defenders.
--    This is the "pre-existing point" win_paths.lua records as unexplained.
--  * the chat line saying how the round was won
--
--What follows is ingame.lua's version, which is the one that had them. Do not
--start a second copy anywhere: capture_zone.lua asserts that
--CapturedByAttackers is defined in this file, precisely so that a reappearing
--duplicate fails a test instead of quietly taking over at load.


--global var which says what mode the capture timer is in
G_CurCaptureMode = "none"
			--"capturing"
			--"reversing"
			--"stuck"

--global var which says if the capture time is moving at all
G_CaptureTimeMoving = false



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

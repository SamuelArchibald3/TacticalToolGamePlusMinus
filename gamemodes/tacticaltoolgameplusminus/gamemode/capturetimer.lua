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


--Every zone that counts this round. ChooseAttackSite fills it - one zone picked
--at random, or every zone on a map whose settings say zones=all (see
--map_settings.lua) - and ResetVarsBetweenRounds empties it.
G_LiveZones = {}

--Each live zone runs a capture of its own, kept on the zone as zone.Capture -
--see TTG_ZoneCapture. With several live, each has its own clock, and the
--first one to run out wins the round for the attackers.


--A zone's capture, made the first time it is asked for:
--  mode     "none", "capturing", "reversing" or "stuck"
--  time     seconds left; nil until a capture has started
--  moving   whether its clock is running at all
--  nextat   when its clock next moves
function TTG_ZoneCapture( zone )
	zone.Capture = zone.Capture or { mode = "none", time = nil, moving = false, nextat = nil }
	return zone.Capture
end


--Whether any zone's clock is moving. The round timer waits in overtime while
--one is, rather than ending the round under a capture.
function TTG_AnyCaptureMoving()
	for _, zone in ipairs( G_LiveZones ) do
		if zone.Capture and zone.Capture.moving then return true end
	end

	return false
end


--What a zone is called on the HUD and in chat: the targetname the map gave it,
--such as A or B. Empty for a zone with none, which on a one-zone map needs no
--name anyway.
function TTG_ZoneLabel( zone )
	if zone.GetName then return zone:GetName() or "" end
	return ""
end


util.AddNetworkString( "TTG_CaptureState" )

--Every live zone's capture, to everybody, for the HUD to draw a bar for each
--one whose clock is moving.
--
--Only with a human to receive it. A net message started and not sent stays
--open, and the next net.Start anywhere discards itself over the top of it -
--see shop_blocklist.lua, where that turned up with a server of bots.
function TTG_SendCaptureState()
	if #player.GetHumans() == 0 then return end

	net.Start( "TTG_CaptureState" )
		net.WriteUInt( #G_LiveZones, 4 )

		for _, zone in ipairs( G_LiveZones ) do
			local cap = TTG_ZoneCapture( zone )

			net.WriteString( TTG_ZoneLabel( zone ) )
			net.WriteUInt( math.Clamp( cap.time or 0, 0, 65535 ), 16 )
			net.WriteUInt( math.Clamp( TTG_CaptureTimeFull(), 1, 65535 ), 16 )
			net.WriteBool( cap.moving == true )
		end
	net.Broadcast()
end



function Start_CaptureCheck()
	hook.Add("Think", "ChangeCapture", ChangeCapture)
end

function End_CaptureCheck()
	hook.Remove("Think", "ChangeCapture")

	--takes the capture bars down if they are still up for some reason
	TTG_SendCaptureState()
end



--runs on think: every live zone's capture, each from who is standing in it
function ChangeCapture()
	for _, zone in ipairs( G_LiveZones ) do
		if zone.TouchingPlyList then
			ChangeZoneCapture( zone )
		end
	end
end


function ChangeZoneCapture( zone )
	local plylist = zone.TouchingPlyList
	local cap = TTG_ZoneCapture( zone )

	local attacker_touching = false
	local defender_touching = false
	for _, ply in pairs(plylist) do
		--IsValidGamePlayer rather than a bare TEAM_SPEC check: it also rules out
		--the dead.
		--
		--Nothing takes a dead player off this list. EndTouch fires when somebody
		--walks out, and disconnecting is handled in server_disconnect.lua, but
		--dying inside the zone leaves you on it - still on TEAM_RED or TEAM_BLUE,
		--because death does not change your team. So a corpse went on holding the
		--point, and a dead defender went on contesting one.
		--
		--IsValid first because the list can outlive an entity: it is only emptied
		--between rounds, and indexing a NULL would take the whole Think hook down.
		if IsValid( ply ) and ply:IsValidGamePlayer() then
			if GetTeamRole(ply:Team()) == "Attacking" then
				attacker_touching = true
			elseif GetTeamRole(ply:Team()) == "Defending" then
				defender_touching = true
			end
		end
	end

	if cap.mode == "none" then
		if attacker_touching and not defender_touching then
			InitializeCapture( zone )
		end

	elseif cap.mode == "capturing" then
		if defender_touching and not attacker_touching then
			cap.mode = "reversing"
		elseif defender_touching and attacker_touching then
			cap.mode = "stuck"
		end

	elseif cap.mode == "reversing" then
		if attacker_touching and not defender_touching then
			cap.mode = "capturing"
		elseif defender_touching and attacker_touching then
			cap.mode = "stuck"
		end

	elseif cap.mode == "stuck" then
		if attacker_touching and not defender_touching then
			cap.mode = "capturing"
		elseif defender_touching and not attacker_touching then
			cap.mode = "reversing"
		end

	end
end



--called when an attacker touches a zone and begins the capture process
function InitializeCapture( zone )
	if zone == nil then return end
	local cap = TTG_ZoneCapture( zone )

	--sets the time to be going down
	cap.mode = "capturing"
	cap.moving = true

	--announces to the defenders in voice that their zone is being captured
	for k,v in pairs(player.GetAll()) do
		if GetTeamRole(v:Team()) == "Defending" then
			umsg.Start("Announcer_Capture", v)
			umsg.End()
		end
	end

	--with several zones live, which one
	local label = TTG_ZoneLabel( zone )
	if #G_LiveZones > 1 and label != "" then
		ChatPrintToAll( label .. " is being captured!" )
	end

	--the full amount right when it starts to count down
	cap.time = TTG_CaptureTimeFull()

	cap.nextat = CurTime() + 1
	TTG_SendCaptureState()
end


--One zone's clock, a second at a time. Returns true if it ran out.
local function TickZone( zone )
	local cap = zone.Capture
	if cap == nil or not cap.moving or CurTime() < ( cap.nextat or 0 ) then return false end

	cap.nextat = CurTime() + 1

	if cap.mode == "capturing" then
		cap.time = cap.time - 1
	elseif cap.mode == "reversing" then
		cap.time = cap.time + 1
		if cap.time >= TTG_CaptureTimeFull() then --reversed all the way back up to its max
			TurnOffCapture( zone )
		end
	end

	return cap.time <= 0
end


function CaptureZoneTime()
	local changed, captured = false, nil

	for _, zone in ipairs( G_LiveZones ) do
		local before = zone.Capture and zone.Capture.time

		if TickZone( zone ) and captured == nil then captured = zone end
		if zone.Capture and zone.Capture.time != before then changed = true end
	end

	if changed then TTG_SendCaptureState() end

	--the first to reach 0 wins; a second reaching it on the same tick finds
	--the round already won
	if captured then CapturedByAttackers( captured ) end
end
hook.Add("Think", "CaptureZoneTime", CaptureZoneTime)


--Turns a zone's capture off, without deciding a winner - or every live zone's,
--given none.
--
--A successful overtime defense used to try to award the round to the
--defenders from here, gated on G_Overtime - a flag nothing ever set to true,
--so the branch never ran. It was not needed: the moment the last moving clock
--stops, the next Think re-enters GCTime's zero check in timer.lua, finds no
--capture moving, and falls through to ZeroEvent( WinningPhase ) - called with
--no winner, which WinningPhase already resolves to the defending team. That is
--the same rule every ordinary timeout uses, one Think tick later than the dead
--branch would have fired. DEBT-9, confirmed in play.
function TurnOffCapture( zone )
	local zones = zone and { zone } or G_LiveZones

	for _, z in ipairs( zones ) do
		local cap = TTG_ZoneCapture( z )
		cap.moving = false
		cap.mode = "none"
	end

	TTG_SendCaptureState()
end


--The attackers have filled `zone`'s clock - or, given none, a capture with no
--zone named, as the tests drive it.
function CapturedByAttackers( zone )
	if G_WinAlreadyTriggered == true then return end

	--every clock stops, not only the one that ran out
	for _, z in ipairs( G_LiveZones ) do
		local cap = TTG_ZoneCapture( z )
		cap.moving = false
		cap.mode = "none"
	end
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
	--With several zones live, which one they took.
	local label = zone and TTG_ZoneLabel( zone ) or ""
	if #G_LiveZones > 1 and label != "" then
		ChatPrintToAll( ConvertToTeamName( attackers ) .. " wins the round by capping " .. label .. "!" )
	else
		ChatPrintToAll( ConvertToTeamName( attackers ) .. " wins the round by capping!" )
	end

	--Everything else is WinningPhase's job: the point, the game-win check, the
	--tie breaker check, disabling ents, the phase, the announcer and the next
	--round. This used to do a third of that by hand and skip the rest.
	WinningPhase( attackers )
end


--How far along every live zone's capture is, for the Rewind ability to record
--and put back: a record per zone, keyed by the zone.
--
--The mode goes back with the clock. It was left out on the idea that
--ChangeCapture works it out again from who is on the point, but it does not:
--it only moves between capturing, reversing and stuck, and a capture only
--starts from "none", which only TurnOffCapture returns it to. So a rewind to
--before a capture began stopped the clock and left the mode on "capturing",
--and the point could not be taken again that round. The other way round, a
--clock put back running with the mode on "none" moved neither way and held
--the round in overtime. From the mode put back, ChangeCapture carries on as
--it would have from that moment.
function TTG_CaptureProgress()
	local out = {}

	for _, zone in ipairs( G_LiveZones ) do
		local cap = TTG_ZoneCapture( zone )
		out[ zone ] = { time = cap.time, moving = cap.moving == true, mode = cap.mode }
	end

	return out
end


function TTG_RestoreCaptureProgress( was )
	if was == nil then return end

	for _, zone in ipairs( G_LiveZones ) do
		local rec = was[ zone ]
		local cap = TTG_ZoneCapture( zone )

		--a zone with no record had no capture to put back
		cap.time = rec and rec.time
		cap.moving = rec != nil and rec.moving == true

		--a record with no mode in it gets the one that goes with its clock
		cap.mode = rec and rec.mode or ( cap.moving and "capturing" or "none" )

		--re-based rather than resumed part way through a second, so the
		--number that was just put back is not taken off again immediately
		cap.nextat = CurTime() + 1
	end

	TTG_SendCaptureState()
end

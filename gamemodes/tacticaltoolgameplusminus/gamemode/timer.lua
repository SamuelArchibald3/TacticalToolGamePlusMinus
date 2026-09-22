/*---------------------------------------------------------
	Game Time Stuff
---------------------------------------------------------*/

local GameTimeOn = false
local EventAtZero = nil


--Starts running the timer whatever amount is specified
--Sets what function will happen when the timer reaches zero
function InitializeGCTime(amount,eventatzero)
	GameTime = amount
	EventAtZero = eventatzero
	
	NextAddTime = CurTime() + 1
	GameTimeOn = true
	UpdateHUDTime()
end


--Called when the timer reaches zero
--Turns timer off
--does whatever function EventAtZero refers to 
--resets EventAtZero to nil
function ZeroEvent(func)
	//print("time up!  Beginning next phase!")
	GameTimeOn = false
	EventAtZero = nil
	return func()
end


function Start_CheckOvertime()
	hook.Add("Think", "CheckOvertime", CheckOvertime)
end

function End_CheckOvertime()
	hook.Remove("Think", "CheckOvertime")
end

--called on think when it becomes overtime, (when timer is at 0 but the capture time is still in flux)
function CheckOvertime()
	if G_CaptureTimeMoving == false then --end itself if the
		SetGlobalBool("CL_DrawOvertime", false)

		End_CheckOvertime()
	end
end

--Called every time the time changes seconds
function GCTime()
	if GameTimeOn == true then
		if (CurTime() >= NextAddTime) then
			NextAddTime = CurTime() + 1
			GameTime = GameTime - 1
			UpdateHUDTime()
		end
		
		if GameTime <= 0 then
		
			--if the capture timer thing is still active in the combat phase,
			--the game is not over so dont do a zero event.
			if G_CaptureTimeMoving == true and G_CurrentPhase == "Combat" then
				SetGlobalBool("CL_DrawOvertime", true)

				Start_CheckOvertime()

				--play overtime sound
				//umsg.Start("Announcer_Overtime", v)
				//umsg.End()

			return end
			ZeroEvent(EventAtZero)
		end
	end
end
hook.Add("Think", "GCTime", GCTime)


--Put seconds back on the round clock, for the Rewind ability.
--
--GameTime is the whole of the clock's state, so giving it back is the whole of
--rewinding it. Clamped to the phase's own length because the clock should
--never read more time than the round began with - which cannot happen today,
--since a rewind needs its whole window recorded before it will fire and so
--cannot run in the first ten seconds, but that is a fact about another file.
--
--Coming back out of overtime is deliberate. If the clock had already run out
--then it had not run out ten seconds ago, and an overtime banner sitting over
--a clock with time on it is exactly the sort of thing that gets reported as a
--bug. GCTime puts both back if it runs out again.
function TTG_RewindGameTime( seconds )
	if GameTimeOn != true then return end

	--rounded because the clock counts in whole seconds and the display formats
	--it as one: a fractional GameTime would show up as "01:50.6"
	GameTime = math.min( GameTime + math.Round( seconds ), COMBATPHASE_TIME )

	if GameTime > 0 and GetGlobalBool( "CL_DrawOvertime", false ) then
		SetGlobalBool( "CL_DrawOvertime", false )
		End_CheckOvertime()
	end

	UpdateHUDTime()
end


--Clears the timer, resetting it to zero, and turns it off
function Clear_Timer()
	GameTime = 0
	EventAtZero = nil
	GameTimeOn = false

	UpdateHUDTime()
end


--Converts seconds time variable to "minutes:seconds" in that format and returns it
function ConvertSecondsToDisplay(time)
	local mins = 0
	local secs = 0
	
	while time > 0 do
		if time >= 60 then 
			mins = mins + 1
			time = time - 60
		elseif time < 60 then
			secs = time
			time = 0
		end
	end
	
	if secs < 10 then
		secs = ("0" .. secs)
	end
	if mins < 10 then
		mins = ("0" .. mins)
	end
	
	local timestring = (mins .. ":" .. secs)
	return timestring
end

--Sends usermsg to the client to update the display of the current time on the clock
function UpdateHUDTime()
	local timestring = ConvertSecondsToDisplay(GameTime)
	
	umsg.Start( "TimerUpdate" )
	umsg.String( timestring )
	umsg.End()
	
	--[[
	
	for k,ply in pairs(player.GetAll()) do
		if ply:Team() != TEAM_SPEC then
			if G_CurrentPhase == "DefendersBuy" then
				umsg.Start( "ShopTimerUpdate", ply )
				umsg.String( timestring )
				umsg.End()
				
			elseif G_CurrentPhase == "AttackersBuy" then
				umsg.Start( "BuyingEndsTimerUpdate", ply  )
				umsg.String( timestring )
				umsg.End()
			
			elseif G_CurrentPhase == "Planning" then
				umsg.Start( "RoundStartingTimerUpdate", ply  )
				umsg.String( timestring )
				umsg.End()
			end
		end
	end
	]]--
end




--G_CurrentPhase:
	--"GameSetup"
	--"DefendersBuy"
	--"AttackersBuy"
	--"Planning"
	--"Setup"
	--"Combat"
	--"Winning"
	--"GameEnd"
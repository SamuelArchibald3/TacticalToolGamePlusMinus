/*---------------------------------------------------------
	Client Game Time Display
---------------------------------------------------------*/
local curgametime = "00:00"

local function TimeHud()

	local function  TimerUpdate(num)
		curgametime = num:ReadString()
		
	-- 	local dosounds = GetGlobalBool("CL_PlayTimerCountSounds")
	-- 	if dosounds != true then return end

	-- 	if curgametime == "00:05" then
	-- 		surface.PlaySound( "vo/announcer_begins_5sec.wav" )
	-- 	elseif curgametime == "00:04" then
	-- 		surface.PlaySound( "vo/announcer_begins_4sec.wav" )
	-- 	elseif curgametime == "00:03" then
	-- 		surface.PlaySound( "vo/announcer_begins_3sec.wav" )
	-- 	elseif curgametime == "00:02" then
	-- 		surface.PlaySound( "vo/announcer_begins_2sec.wav" )
	-- 	elseif curgametime == "00:01" then
	-- 		surface.PlaySound( "vo/announcer_begins_1sec.wav" )

	-- end
end
	usermessage.Hook("TimerUpdate", TimerUpdate)
	//draw.SimpleText(curgametime, "DermaLarge", 10, ScrH() - 100, Color(255,255,255,255))

	//the grey box behind the time display text
	draw.RoundedBox(16, ScrW()/2 - 50, 3, 100, 45, Color(50,50,50,255))	

	local game_time = {}
		game_time.pos = {}
		game_time.pos[1] = ScrW()/2 + 1 -- x pos
		game_time.pos[2] = 26 -- y pos
		game_time.color = Color(255,255,255,255)
		game_time.text =  curgametime
		game_time.font = "TheDefaultSettings4"
		game_time.xalign = TEXT_ALIGN_CENTER -- Horizontal Alignment
		game_time.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment
		draw.Text( game_time )

	
	--this should be fixed cause it spams overtime
	local overtime = GetGlobalBool("CL_DrawOvertime")
		if overtime == true then
			surface.PlaySound( "vo/announcer_overtime.wav" )
			//surface.PlaySound( "Weapon_Mortar.Single" )
			//surface.PlaySound( "Weapon_Shotgun.Single" )
			//surface.PlaySound( "vo/announcer_begins_2sec.wav" )
			//surface.PlaySound( "vo/announcer_begins_5sec.wav" )
			//surface.PlaySound( "Weapon_Pistol.Single" )
			
	
			draw.SimpleText("OVERTIME","TheDefaultSettings3",(ScrW()/2)+200, 140,Color(255,255,255,255))
		end
end
hook.Add("HUDPaint", "TimeHud", TimeHud)


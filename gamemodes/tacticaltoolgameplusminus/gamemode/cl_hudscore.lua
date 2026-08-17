--G_CurrentPhase:
	--"GameSetup"
	--"DefendersBuy"
	--"AttackersBuy"
	--"Planning"
	--"Setup"
	--"Combat"
	--"Winning"
	--"GameEnd


/*---------------------------------------------------------
	Client Score Displays
---------------------------------------------------------*/

local function ScoreHud()
	local health = LocalPlayer():Health()
	if health <= 0 then
		health = 0
	end
	local redscore = team.GetScore(TEAM_RED)
	draw.SimpleTextOutlined(redscore .. "    -", "TheDefaultSettings2", ScrW()/2 - 80, 25, Color(255, 190, 190, 255), 1, 1, 1, Color(0, 0, 0, 255))
	
	local bluescore = team.GetScore(TEAM_BLUE)
	draw.SimpleTextOutlined( "-    " .. bluescore, "TheDefaultSettings2", ScrW()/2 + 80, 25, Color(190, 190, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
	
	
	
	local phase = GetGamePhase()
	if phase == "GameSetup" then
		draw.SimpleTextOutlined("GAME SETUP", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "DefendersBuy" then
		draw.SimpleTextOutlined("DEFENDERS TURN TO BUY", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "AttackersBuy" then
		draw.SimpleTextOutlined("ATTACKERS TURN TO BUY", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "Planning" then
		draw.SimpleTextOutlined("GET READY!", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "Setup" then
		draw.SimpleTextOutlined("DEFENDERS SETUP", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "Combat" then
		draw.SimpleTextOutlined("COMBAT", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "Winning" then
		draw.SimpleTextOutlined("A TEAM WON", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	elseif phase == "GameEnd" then
		draw.SimpleTextOutlined("GAME OVER", "TheDefaultSettings5", ScrW()/2, 62, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	end
	
	
	
	
	local round = GetRound()
	local total_rounds = GetTotalRounds() + 1
	if total_rounds <= 1 then
		total_rounds = 0
	end
	draw.SimpleTextOutlined("ROUND: " .. round, "TheDefaultSettings2", ScrW()/2, 85, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))

	if round > GetTotalRounds() then
		draw.SimpleTextOutlined("TIE BREAKER", "TheDefaultSettings5", ScrW()/2 + 0.5, 108, Color(255, 255, 100, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
	end
	
	function fVote( ply, command, arguments )
	end

	--A "the game has ended" centre-print used to sit here, on the same hardcoded
	--"> 2" as the server did. Three separate problems, so it is gone rather than
	--corrected:
	--
	--  * this runs in HUDPaint, so it re-printed every single frame for as long as
	--    a team held 3 points
	--  * it looped every player calling PrintMessage on them from the client,
	--    which only ever affects the local player anyway
	--  * the threshold was wrong for any game longer than 5 rounds, so it fired
	--    while the game was still being played
	--
	--Nothing is lost: the phase readout above already prints GAME OVER from
	--CL_CurPhase, and GameEnd() announces the winner server-side.


end

	
	--help info
	draw.SimpleTextOutlined("Press F1 to open the tool library", "TargetID", ScrW()-150, 15, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))

hook.Add("HUDPaint", "ScoreHud", ScoreHud)
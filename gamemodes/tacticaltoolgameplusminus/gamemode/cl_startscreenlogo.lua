/*---------------------------------------------------------
	Displays logo if we're in game setup
---------------------------------------------------------*/

local drawlogo = true

local function StartScreenLogo()
	//print(GetGlobalString("CL_CurPhase"))
	if GetGlobalString("CL_CurPhase") == "GameSetup" or GetGlobalString("CL_CurPhase") == ""  then
		
		local function PauseLogo()
			drawlogo = false
		end
		hook.Add("ScoreboardShow", "Logo_pause", PauseLogo)
		
		
		local function ResumeLogo()
			drawlogo = true
		end
		hook.Add("ScoreboardHide", "Logo_resume", ResumeLogo)
		
		
		if drawlogo == true then
			draw.TexturedQuad
			{
			texture = surface.GetTextureID "ttg_logo",
			color = Color(32, 32, 32),
			x = ScrW()/2 - 257,
			y = 169,
			w = 512,
			h = 128,
			}
			draw.TexturedQuad
			{
			texture = surface.GetTextureID "ttg_logo",
			color = Color(255, 255, 255, 255),
			x = ScrW()/2 - 260,
			y = 166,
			w = 512,
			h = 128,
			}
		end
	end
end
hook.Add( "HUDPaint", "StartScreenLogo", StartScreenLogo )


/*---------------------------------------------------------
	Pre-game Team-Setup window
---------------------------------------------------------*/

function ShowTeamMenu()
	local ply = LocalPlayer()
	local panel_width = 600
	local panel_height = 400
 
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( (ScrW()/2)-panel_width/2, 300 )
	DermaPanel:SetSize( panel_width, panel_height )
	DermaPanel:SetTitle( "Set Up Teams" ) // Name of Fram
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false ) //Can the player drag the frame /True/False
	DermaPanel:ShowCloseButton( false ) //Show the X (Close button) /True/False
	DermaPanel:SetDeleteOnClose(true)
	//DermaPanel:MakePopup()


	
  
	local RedColumn = vgui.Create("DListView")
	RedColumn:SetParent(DermaPanel)
	RedColumn:SetPos(25, 125)
	RedColumn:SetSize((panel_width/3)-25, panel_height-200)
	RedColumn:SetMultiSelect(false)
	RedColumn:AddColumn("Red Team") -- Add column
	RedColumn:AddColumn("Ready?")
	
	local BlueColumn = vgui.Create("DListView")
	BlueColumn:SetParent(DermaPanel)
	BlueColumn:SetPos(panel_width-200, 125)
	BlueColumn:SetSize((panel_width/3)-25, panel_height-200)
	BlueColumn:SetMultiSelect(false)
	BlueColumn:AddColumn("Blue Team") -- Add column
	BlueColumn:AddColumn("Ready?")
	
	local SpecColumn = vgui.Create("DListView")
	SpecColumn:SetParent(DermaPanel)
	SpecColumn:SetPos((panel_width/3) + 25, 125)
	SpecColumn:SetSize((panel_width/3)-50, panel_height-200)
	SpecColumn:SetMultiSelect(false)
	SpecColumn:AddColumn("Spectators")
	//SpecColumn:AddColumn("Ready?")
	
	
	local SpecButton = vgui.Create( "DButton" )
	SpecButton:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	SpecButton:SetText( "Join Spectators" )
	SpecButton:SetPos( (panel_width/3) + 25, 50 )
	SpecButton:SetSize( 150, 50 )
	SpecButton.DoClick = function ()
		RunConsoleCommand( "gc_jointeam", "TEAM_SPEC" )
		RunConsoleCommand( "gc_readytoggle", "false" )
	end 

	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	DermaButton:SetText( "Join Red Team" )
	DermaButton:SetPos( 35, 50 )
	DermaButton:SetSize( 150, 50 )
	DermaButton.DoClick = function ()
		RunConsoleCommand( "gc_jointeam", "TEAM_RED" ) // What happens when you press the button
		RunConsoleCommand( "gc_readytoggle", "false" )
	end 
 
	local DermaButton2 = vgui.Create( "DButton" )
	DermaButton2:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	DermaButton2:SetText( "Join Blue Team" )
	DermaButton2:SetPos( (panel_width - 187), 50 )
	DermaButton2:SetSize( 150, 50 )
	DermaButton2.DoClick = function ()
		RunConsoleCommand( "gc_jointeam", "TEAM_BLUE" )
		RunConsoleCommand( "gc_readytoggle", "false" )
	end 
	
	local ReadyButton = vgui.Create( "DButton" )
	ReadyButton:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	ReadyButton:SetText( "Ready Toggle" )
	ReadyButton:SetPos( 25, (panel_height - 50) )
	ReadyButton:SetSize( 100, 25 )
	//ReadyButton:SetEnabled( true )
	//ReadyButton:SetDisabled( true )
	ReadyButton.DoClick = function ()
		RunConsoleCommand( "gc_readytoggle", "toggle" ) // What happens when you press the button
	end 

	local Customize = vgui.Create( "DButton" )
	Customize:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	Customize:SetText( "Customization" )
	Customize:SetPos( 475, (panel_height - 50) )
	Customize:SetSize( 100, 25 )
	Customize:SetEnabled( true )
	//ReadyButton:SetDisabled( true )
	Customize.DoClick = function ()
		RunConsoleCommand( "playermodel_selector") // What happens when you press the button
	end 
	local HelpButton = vgui.Create( "DButton" )
	HelpButton:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	HelpButton:SetText( "Help" )
	HelpButton:SetPos( 262, (panel_height - 50) )
	HelpButton:SetSize( 70, 25 )
	HelpButton:SetEnabled( true )
	HelpButton.DoClick = function ()
		gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=2858619284" )
	end

	local PlayerCountRed = vgui.Create("DLabel", DermaPanel)
	PlayerCountRed :SetPos(100, 100) // Position
	PlayerCountRed :SetColor(Color(255,150,150,255)) // Color
	PlayerCountRed :SetFont("TheDefaultSettings5")
	PlayerCountRed :SizeToContents() // make the control the same size as the text.
	
	local PlayerCountBlue = vgui.Create("DLabel", DermaPanel)
	PlayerCountBlue:SetPos(panel_width-125, 100) // Position
	PlayerCountBlue:SetColor(Color(150,150,255,255)) // Color
	PlayerCountBlue:SetFont("TheDefaultSettings5")
	PlayerCountBlue:SizeToContents() // make the control the same size as the text.
	
	local Explanation1 = vgui.Create("DLabel", DermaPanel)
	Explanation1:SetPos((panel_width / 2 - 230), (panel_height - 20)) // Position
	Explanation1:SetColor(Color(255,255,255,255)) // Color
	Explanation1:SetFont("Trebuchet18")
	Explanation1:SetText("Round will begin when both teams have enough players, and all players are ready")
	Explanation1:SizeToContents() // make the control the same size as the text.
	
	local StartingRound = vgui.Create("DLabel", DermaPanel)
	StartingRound:SetPos(167, (panel_height - 73)) // Position
	StartingRound:SetColor(Color(0,255,0,0)) // Color
	StartingRound:SetFont("TheDefaultSettings5")
	StartingRound:SetText("Starting game in " .. BEGINNING_COUNTDOWN .. " seconds...")
	StartingRound:SizeToContents() // make the control the same size as the text.
	
	local min = false
	
	local function Update()
		if min == false then
			gui.EnableScreenClicker(true)
		end
		PlayerCountBlue:SetText( team.NumPlayers(TEAM_BLUE) .. "/" .. PLAYERS_PER_TEAM )
		PlayerCountRed:SetText( team.NumPlayers(TEAM_RED) .. "/" .. PLAYERS_PER_TEAM )
		PlayerCountBlue:SetPos(472, 100)
		PlayerCountRed:SetPos(97, 100)
		PlayerCountBlue:SizeToContents() // make the control the same size as the text.
		PlayerCountRed :SizeToContents() // make the control the same size as the text.
	
		if LocalPlayer():Team() == TEAM_SPEC then
			ReadyButton:SetDisabled( true )
		else
			ReadyButton:SetDisabled( false )
		end
	
		RedColumn:Clear(true)
		BlueColumn:Clear(true)
		SpecColumn:Clear(true)
		for k,v in pairs(player.GetAll()) do
			//local ifready = tostring( v:GetIfReady() )
			local ifready = "No"
			if v:GetIfReady() == false then
				ifready = "         No"
			elseif v:GetIfReady() == true then
				ifready = "        Yes"
			end
		
			if v:Team() == TEAM_RED then
				RedColumn:AddLine(v:Nick(), ifready)
			elseif v:Team() == TEAM_BLUE then
				BlueColumn:AddLine(v:Nick(), ifready)
			elseif v:Team() == TEAM_SPEC then
				SpecColumn:AddLine(v:Nick())
			end
		end
	end
	hook.Add("Think", "UpdateTeamMenu", Update)
	
	
	
	local function Countdown()
		StartingRound:SetColor(Color(0,255,0,255))
	end
	usermessage.Hook( "GCTeamsPanel_startcount", Countdown )
	
	
	
	local function CountdownCancel()
		StartingRound:SetColor(Color(0,255,0,0))
	end
	usermessage.Hook( "GCTeamsPanel_cancelcount", CountdownCancel )
	
	
	local function Minimize()
		if not IsValid(DermaPanel) then return end
		
		min = true
		DermaPanel:SetVisible( false )
		gui.EnableScreenClicker(false)
	end
	hook.Add("ScoreboardShow", "GCTeamsPanel_minimize", Minimize)
	
	local function Maximize()
		if not IsValid(DermaPanel) then return end
		
		min = false
		DermaPanel:SetVisible( true )
		gui.EnableScreenClicker(true)
	end
	hook.Add("ScoreboardHide", "GCTeamsPanel_maximize", Maximize)
	
	local function Close()
		DermaPanel:Close()
		gui.EnableScreenClicker(false)
		hook.Remove( "Think", "UpdateTeamMenu" )
	end
	usermessage.Hook( "GCTeamsPanel_close", Close )
 

end
usermessage.Hook( "GCTeamsPanel_open", ShowTeamMenu )
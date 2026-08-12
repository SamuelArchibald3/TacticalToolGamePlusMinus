/*---------------------------------------------------------
	Pre-game Team-Setup window
---------------------------------------------------------*/

function ShowTeamJoinMenu()
	local ply = LocalPlayer()
	local panel_width = 600
	local panel_height = 200
 
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 50, 50 )
	DermaPanel:SetSize( panel_width, panel_height )
	DermaPanel:SetTitle( "Set your team" ) // Name of Frame
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false ) //Can the player drag the frame /True/False
	DermaPanel:ShowCloseButton( false ) //Show the X (Close button) /True/False
	DermaPanel:SetDeleteOnClose(true)
	//DermaPanel:MakePopup()
	
  
	local RedColumn = vgui.Create("DListView")
	RedColumn:SetParent(DermaPanel)
	RedColumn:SetPos(25, 60)
	RedColumn:SetSize((panel_width/3)-50, 125)
	RedColumn:SetMultiSelect(false)
	RedColumn:AddColumn("Red Team") -- Add column
	
	local BlueColumn = vgui.Create("DListView")
	BlueColumn:SetParent(DermaPanel)
	BlueColumn:SetPos(panel_width- 175, 60)
	BlueColumn:SetSize((panel_width/3)-50, 125)
	BlueColumn:SetMultiSelect(false)
	BlueColumn:AddColumn("Blue Team") -- Add column
	
	local SpecColumn = vgui.Create("DListView")
	SpecColumn:SetParent(DermaPanel)
	SpecColumn:SetPos((panel_width/3) + 25, 60)
	SpecColumn:SetSize((panel_width/3)-50, 125)
	SpecColumn:SetMultiSelect(false)
	SpecColumn:AddColumn("Spectators")
	
	
	local SpecButton = vgui.Create( "DButton" )
	SpecButton:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	SpecButton:SetText( "Join Spectators" )
	SpecButton:SetPos( (panel_width/3) + 25, 25 )
	SpecButton:SetSize( 150, 25 )
	SpecButton.DoClick = function ()
		RunConsoleCommand( "ttg_jointeamnextround", TEAM_SPEC )
	end 

	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	DermaButton:SetText( "Join Red Team" )
	DermaButton:SetPos( 45, 25 )
	DermaButton:SetSize( 150, 25 )
	DermaButton.DoClick = function ()
		RunConsoleCommand( "ttg_jointeamnextround", TEAM_RED ) // What happens when you press the button
	end 
 
	local DermaButton2 = vgui.Create( "DButton" )
	DermaButton2:SetParent( DermaPanel ) // Set parent to our "DermaPanel"
	DermaButton2:SetText( "Join Blue Team" )
	DermaButton2:SetPos( (panel_width - 175), 25 )
	DermaButton2:SetSize( 150, 25 )
	DermaButton2.DoClick = function ()
		RunConsoleCommand( "ttg_jointeamnextround", TEAM_BLUE )
	end 
	
	--[[
	
	local PlayerCountRed = vgui.Create("DLabel", DermaPanel)
	PlayerCountRed :SetPos(85, 100) // Position
	PlayerCountRed :SetColor(Color(255,75,75,255)) // Color
	PlayerCountRed :SetFont("DermaLarge")
	PlayerCountRed :SizeToContents() // make the control the same size as the text.
	
	local PlayerCountBlue = vgui.Create("DLabel", DermaPanel)
	PlayerCountBlue:SetPos(panel_width-135, 100) // Position
	PlayerCountBlue:SetColor(Color(75,75,255,255)) // Color
	PlayerCountBlue:SetFont("DermaLarge")
	PlayerCountBlue:SizeToContents() // make the control the same size as the text.
	
	]]--
	
	
	local Explanation1 = vgui.Create("DLabel", DermaPanel)
	Explanation1:SetPos(25, (panel_height - 15)) // Position
	Explanation1:SetColor(Color(255,255,255,255)) // Color
	Explanation1:SetFont("Default")
	Explanation1:SetText("You will begin playing after the current round ends.                                                     Press F2 to close.")
	Explanation1:SizeToContents() // make the control the same size as the text.
	

	
	
	local function Update()
		gui.EnableScreenClicker(true)
		
		//PlayerCountBlue:SetText( team.NumPlayers(TEAM_BLUE) )
		//PlayerCountRed:SetText( team.NumPlayers(TEAM_RED) ) 
	
		RedColumn:Clear(true)
		BlueColumn:Clear(true)
		SpecColumn:Clear(true)
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_RED then
				RedColumn:AddLine(v:Nick())
			elseif v:Team() == TEAM_BLUE then
				BlueColumn:AddLine(v:Nick())
			elseif v:Team() == TEAM_SPEC then
			
				//the person on spec team might not really be spec, if theyre set to join red or blue team next round
				local really_spec = true
				
				if v:GetJoiningTeam() == TEAM_BLUE then
					really_spec = false
				end
				
				if v:GetJoiningTeam() == TEAM_RED then
					really_spec = false
				end
			
				if really_spec == true then
					SpecColumn:AddLine(v:Nick())
				end
				
			end
		end
		
		//add all the people who arent yet on a team, but are joining it next round, to their respective list
		for k,v in pairs(player.GetAll()) do
			if v:GetJoiningTeam() == TEAM_BLUE then
				BlueColumn:AddLine(v:Nick())
			elseif v:GetJoiningTeam() == TEAM_RED then
				RedColumn:AddLine(v:Nick())
			end
		end
		
	end
	hook.Add("Think", "TeamJoinMenu_update", Update)
	
	
	
	
	
	local function Close()
		DermaPanel:Close()
		gui.EnableScreenClicker(false)
		hook.Remove( "Think", "TeamJoinMenu_update" )
		
	end
	usermessage.Hook( "TeamJoinPanel_close", Close )
 

end
usermessage.Hook( "TeamJoinPanel_open", ShowTeamJoinMenu )
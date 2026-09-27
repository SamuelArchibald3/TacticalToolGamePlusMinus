local Ply = LocalPlayer()

--vars many of these functions share with each other
local CheckClientSay = false
local CurVoteCommand = nil
local Voting_ArgTable = {}

--what the map vote on now offers, sent by the server as it starts: the whole
--list, or just the maps a vote tied on if this is the runoff
local MapBallot = {}
local MapRunoff = false


--Runs the console command sending a the players vote back to the server
local function VoteKey( num )
	--arg becomes whatever was put in the arg table with that key, a player, a map, a bool, etc..
	local arg = tostring( Voting_ArgTable[num] )
	RunConsoleCommand( "ttg_vote", CurVoteCommand, arg )
end


function Vote_ClientSay( ply, str, teamonly, isdead )
	if CheckClientSay != true then return end
	if ply != LocalPlayer() then return end
	
	--check if the number is valid, then do the votekey
	local tonum = tonumber(str)
	local choice = Voting_ArgTable[ tonum ]
	if choice != nil then
		VoteKey( tonum )
		CheckClientSay = false
	end
	
end
hook.Add("OnPlayerChat","Vote_ClientSay",Vote_ClientSay)


local function Vote_SetCurVoteCommand( cmd )
	CurVoteCommand = cmd
end






--How wide the widest of `lines` is in `font`.
local function TextWidth( lines, font )
	surface.SetFont( font )
	local widest = 0
	for _, line in ipairs( lines ) do
		widest = math.max( widest, ( surface.GetTextSize( line ) ) )
	end
	return widest
end


local function Vote_Panel( option, cmd )
	CheckClientSay = true
	Vote_SetCurVoteCommand( cmd )

	--Tall enough for every choice, and wide enough for the longest line. They
	--were a fixed 225 and 240: about six lines, and the vote count went off the
	--end of the longer map names. Every line is measured with the most votes it
	--could show, which is everybody.
	local rows = 3
	local lines = {}
	if option == "maps" then
		rows = #MapBallot + 1
		for k, map in ipairs( MapBallot ) do
			lines[k] = k .. ".  " .. map .. ":  " .. player.GetCount()
		end
	elseif option == "players" then
		rows = #player.GetAll() + 1
		for k, v in ipairs( player.GetAll() ) do
			lines[k] = k .. ".  " .. v:Name() .. ":   " .. player.GetCount()
		end
	end
	local tall = math.min( 60 + rows * 26, ScrH() - 160 )

	--the title counts down, so two digits is as wide as it gets
	local wide = math.max( TextWidth( { "Vote" .. cmd .. "? - 00", "Runoff - 00" }, "Trebuchet24" ), TextWidth( lines, "TargetID" ) )
	--the list starts 25 in, and leaves room on the right for its scrollbar
	wide = math.Clamp( wide + 50, 240, ScrW() - 50 )

	local Panel = vgui.Create( "DFrame" )
	Panel:SetPos( ScrW() - 25 - wide, ScrH() - 115 - tall )
	Panel:SetSize( wide, tall )
	//Panel:SetAlpha( 200 )
	Panel:SetTitle( "Enter number in chat to vote" ) 
	Panel:SetVisible( true )
	Panel:SetDraggable( false )
	Panel:ShowCloseButton( false )
	Panel:SetDeleteOnClose(true)

	
	local ChoiceList = vgui.Create( "DPanelList", Panel )
	ChoiceList:SetPos( 25,25 )
	ChoiceList:SetSize( wide - 30, tall - 30 )
	ChoiceList:SetSpacing( 5 )
	ChoiceList:EnableHorizontal( false )
	ChoiceList:EnableVerticalScrollbar( true )
	
	--play a sound alerting players of the vote
	surface.PlaySound( "buttons/button17.wav" )
	
	Voting_ArgTable = {}
	
	local function Update()
		ChoiceList:Clear()
	
		--timer
		local timeleft = GetGlobalInt( "CL_VoteTimerInt" )
		local InsertTitle = vgui.Create( "DLabel" )
		if option == "maps" and MapRunoff then
			InsertTitle:SetText( "Runoff - " .. timeleft )
		else
			InsertTitle:SetText( "Vote" .. cmd .. "? - " .. timeleft )
		end
		InsertTitle:SetColor( Color(255,255,255,255) )
		InsertTitle:SetFont( "Trebuchet24" )
		InsertTitle:SizeToContents()
		ChoiceList:AddItem( InsertTitle )
		
	
		local num = 1
		if option == "players" then
			for _, v in pairs(player.GetAll()) do
				Voting_ArgTable[num] = v:UniqueID()
				local votes = v:GetVotesInt()
				
				local Insert = vgui.Create( "DLabel" )
				Insert:SetText( num ..".  " .. v:Name() .. ":   " .. votes)
				Insert:SetColor( Color(255,255,255,255) )
				Insert:SetFont("TargetID")
				Insert:SizeToContents()
				ChoiceList:AddItem( Insert )
				
				num = num + 1
			end
			
		elseif option == "bool" then
			local var = true
			for i=1,2 do
				Voting_ArgTable[num] = var
				label = "No"
				if var == true then
					label = "Yes"
				end
				
				local votes = GetGlobalInt( "CL_BoolVotes_" .. tostring(var) )
				
				local Insert = vgui.Create( "DLabel" )
				Insert:SetText( num ..".  " .. label .. ":  " .. votes )
				Insert:SetColor( Color(255,255,255,255) )
				Insert:SetFont("TargetID")
				Insert:SizeToContents()
				ChoiceList:AddItem( Insert )
			
				var = false
				num = num + 1
			end
			
		elseif option == "maps" then
			for k, map in ipairs( MapBallot ) do
				Voting_ArgTable[num] = map
				
				local votes = 0
				for _, v in pairs(player.GetAll()) do
					if v:GetChangeMap() == map then
						votes = votes + 1
					end
				end
				
				local Insert = vgui.Create( "DLabel" )
				Insert:SetText( num ..".  " .. map .. ":  " .. votes )
				Insert:SetColor( Color(255,255,255,255) )
				Insert:SetFont("TargetID")
				Insert:SizeToContents()
				ChoiceList:AddItem( Insert )
				
				num = num + 1
			end
			
			
		end
	end
	Update()
	
	
	local StopTimer = false
	local function DoTimer()
		timer.Simple( .2, function()
			if StopTimer then return end
			Update()
			DoTimer()
		end)
	end
	DoTimer()
	

	
	local function Close()
		Panel:Close()
		StopTimer = true
		CheckClientSay = false
	end
	usermessage.Hook( "Vote_End", Close )
end





local function VoteInitialize_Kick()
	Vote_Panel( "players", "kick" )
end
usermessage.Hook( "VoteInitialize_Kick", VoteInitialize_Kick )


local function VoteInitialize_Restart()
	Vote_Panel( "bool", "restart" )
end
usermessage.Hook( "VoteInitialize_Restart", VoteInitialize_Restart )


--A map vote, or its runoff, starting. The ballot comes with it rather than out
--of a list the client keeps: the list is a file on the server now, and a runoff
--only offers the maps that tied.
net.Receive( "TTG_MapBallot", function()
	MapBallot = {}
	for i = 1, net.ReadUInt( 8 ) do
		table.insert( MapBallot, net.ReadString() )
	end
	MapRunoff = net.ReadBool()

	Vote_Panel( "maps", "map" )
end )



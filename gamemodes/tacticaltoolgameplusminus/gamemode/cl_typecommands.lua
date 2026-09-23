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






local function Vote_Panel( option, cmd )
	CheckClientSay = true
	Vote_SetCurVoteCommand( cmd )

	--Tall enough for every choice. It was a fixed 225, which is about six
	--lines, and the map list is longer than that now.
	local rows = 3
	if option == "maps" then rows = #MapBallot + 1
	elseif option == "players" then rows = #player.GetAll() + 1 end
	local tall = math.min( 60 + rows * 26, ScrH() - 160 )

	local Panel = vgui.Create( "DFrame" )
	Panel:SetPos( ScrW()-265, ScrH() - 115 - tall )
	Panel:SetSize( 240, tall )
	//Panel:SetAlpha( 200 )
	Panel:SetTitle( "Enter number in chat to vote" ) 
	Panel:SetVisible( true )
	Panel:SetDraggable( false )
	Panel:ShowCloseButton( false )
	Panel:SetDeleteOnClose(true)

	
	local ChoiceList = vgui.Create( "DPanelList", Panel )
	ChoiceList:SetPos( 25,25 )
	ChoiceList:SetSize( 210, tall - 30 )
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



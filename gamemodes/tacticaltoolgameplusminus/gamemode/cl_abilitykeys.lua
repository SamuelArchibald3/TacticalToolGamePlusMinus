/*---------------------------------------------------------
	Keys panel

	Which key runs which ability, and which number key selects which tool,
	used to be settled by the order you bought in, and there was no way to
	change either. ttg_swapabilities and ttg_swaptools can move them, but a
	console command is not something you reach for between rounds, so this is
	the way to them: open with F2, click two rows in the same list, done.
---------------------------------------------------------*/

--The key that selects tool key `k`: whatever "slot<k>" is bound to, named the
--way the player would know it, or the number when nothing is.
local function ToolKeyLabel( k )
	local bound = input.LookupBinding( "slot" .. k )
	if bound == nil or bound == "" then return tostring( k ) end

	return string.upper( bound )
end


local function ShowAbilityKeysMenu()

	local panel_width = 660
	local panel_height = 300
	local list_width = ( panel_width - 60 ) / 2

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( (ScrW()/2)-panel_width/2, 150 )
	DermaPanel:SetSize( panel_width, panel_height )
	DermaPanel:SetTitle( "Keys" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( false )
	DermaPanel:SetDeleteOnClose( true )
	DermaPanel:SetMouseInputEnabled( true )

	gui.EnableScreenClicker( true )


	local Explain = vgui.Create( "DLabel", DermaPanel )
	Explain:SetPos( 20, 35 )
	Explain:SetColor( Color(200,200,200,255) )
	Explain:SetFont( "Trebuchet18" )
	Explain:SetText( "Click one row, then another in the same list, to swap their keys." )
	Explain:SizeToContents()


	local ToolList = vgui.Create( "DListView", DermaPanel )
	ToolList:SetPos( 20, 65 )
	ToolList:SetSize( list_width, 160 )
	ToolList:SetMultiSelect( false )
	ToolList:AddColumn( "Key" )
	ToolList:AddColumn( "Tool" )


	local AbilityList = vgui.Create( "DListView", DermaPanel )
	AbilityList:SetPos( 40 + list_width, 65 )
	AbilityList:SetSize( list_width, 160 )
	AbilityList:SetMultiSelect( false )
	AbilityList:AddColumn( "Key" )
	AbilityList:AddColumn( "Ability" )


	local Status = vgui.Create( "DLabel", DermaPanel )
	Status:SetPos( 20, 232 )
	Status:SetColor( Color(255,255,255,255) )
	Status:SetFont( "Trebuchet18" )
	Status:SetText( "" )
	Status:SizeToContents()


	local CloseButton = vgui.Create( "DButton", DermaPanel )
	CloseButton:SetText( "Close  (F2)" )
	CloseButton:SetPos( 20, 258 )
	CloseButton:SetSize( 110, 25 )


	local function SetStatus( text )
		Status:SetText( text )
		Status:SizeToContents()
	end


	--the row a first click has picked out in each list, waiting for a second
	local pending = {}

	--what the lists were built from, so they are only rebuilt when something
	--changed. Rebuilding every frame like the other menus do would throw away
	--the first click before the second one ever arrived.
	local builtfrom = nil


	local function KeysSignature()
		local ply = LocalPlayer()
		if not IsValid( ply ) then return "" end

		local parts = {}
		for i = 1, TTG_AbilitySlotCount() do
			table.insert( parts, ply:GetAbilityInfo( i ).name )
		end

		local tools = ply:ToolKeys()
		for k = 1, TTG_ToolKeyCount() do
			table.insert( parts, IsValid( tools[ k ] ) and tools[ k ]:GetClass() or "-" )
		end

		return table.concat( parts, "|" )
	end


	local function Rebuild()
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		ToolList:Clear( true )
		AbilityList:Clear( true )

		--the picks are gone with the rows they referred to, so the prompt has
		--to go with them or it keeps asking about a row nobody chose
		pending = {}
		SetStatus( "" )

		--one row per key, empty ones included: moving a tool onto a free key
		--is half of what this is for
		local tools = ply:ToolKeys()
		for k = 1, TTG_ToolKeyCount() do
			local name = "( empty )"
			if IsValid( tools[ k ] ) then name = tools[ k ]:GetPrintName() end

			ToolList:AddLine( ToolKeyLabel( k ), name )
		end

		for i = 1, TTG_AbilitySlotCount() do
			local info = ply:GetAbilityInfo( i )

			--the key this player actually has, not the one the table names
			local label = TTG_AbilityKeyLabel( i )

			local name = "( empty )"
			if info.name != "none" then name = ConvertToPrintName( info.name ) end

			AbilityList:AddLine( label, name )
		end
	end


	--First click picks, a second click in the same list swaps. A row's index
	--is its tool key or ability slot, since the rows go in that order.
	local lists = { ToolList, AbilityList }

	local function PairClicks( list, command )
		list.OnRowSelected = function( self, index, row )
			if pending[ list ] == nil then
				--a pick in the other list is dropped: one question at a time
				for _, other in ipairs( lists ) do
					if other != list then
						pending[ other ] = nil
						other:ClearSelection()
					end
				end

				pending[ list ] = index
				SetStatus( "Swap " .. row:GetValue(1) .. " with...?" )
				return
			end

			if pending[ list ] != index then
				RunConsoleCommand( command, tostring( pending[ list ] ), tostring( index ) )
			end

			pending[ list ] = nil
			SetStatus( "" )
			self:ClearSelection()
		end
	end

	PairClicks( ToolList, "ttg_swaptools" )
	PairClicks( AbilityList, "ttg_swapabilities" )


	local function Update()
		--only rebuild when something actually changed, so a pending first click
		--survives long enough to be paired with a second
		local signature = KeysSignature()
		if signature != builtfrom then
			builtfrom = signature
			Rebuild()
		end
	end
	hook.Add( "Think", "Update_AbilityKeysVgui", Update )


	local function Close()
		if IsValid( DermaPanel ) then
			DermaPanel:Close()
		end

		hook.Remove( "Think", "Update_AbilityKeysVgui" )
		gui.EnableScreenClicker( false )
	end
	usermessage.Hook( "Close_AbilityKeysVgui", Close )

	CloseButton.DoClick = function()
		--go through the server so its idea of whether the panel is open stays
		--in step with reality, or F2 would need pressing twice to reopen
		RunConsoleCommand( "ttg_abilitykeys_close" )
	end

end
usermessage.Hook( "Open_AbilityKeysVgui", ShowAbilityKeysMenu )


/*---------------------------------------------------------
	Telling the server which key a bound action sits on
---------------------------------------------------------*/

--Some ability slots are triggered by a console command with no bit in the
--usercmd and no hook behind it - phys_swap, the Gravity Gun row in the options
--menu, is the one that made this necessary. The server cannot see that key at
--all, so the client looks up what the action is bound to and says so.
--
--Sent on spawn and then re-checked, because a player can rebind mid game and
--the server would otherwise keep watching the key they stopped using.

local reported = {}


local function ReportAbilityBindings()
	if not IsValid( LocalPlayer() ) then return end

	for slot, bind in ipairs( ABILITY_KEYS ) do
		if bind.trigger == "binding" then
			local key = input.LookupBinding( bind.command )

			--0 means nothing is bound to it, which the server takes as "stop
			--watching for this one"
			local code = 0
			if key != nil and key != "" then
				code = input.GetKeyCode( key ) or 0
			end

			if reported[ slot ] != code then
				reported[ slot ] = code

				net.Start( "TTG_AbilityBinding" )
					net.WriteUInt( slot, 4 )
					net.WriteUInt( code, 10 )
				net.SendToServer()
			end
		end
	end
end


hook.Add( "InitPostEntity", "TTG_ReportAbilityBindings", ReportAbilityBindings )

--Rebinding is rare, so this is cheap and never needs to be prompt. Only a
--change is actually sent - see `reported` above.
timer.Create( "TTG_ReportAbilityBindings", 5, 0, ReportAbilityBindings )

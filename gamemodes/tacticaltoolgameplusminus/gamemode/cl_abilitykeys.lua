/*---------------------------------------------------------
	Ability Keys panel

	Which key runs which ability used to be settled by the order you bought in,
	and there was no way to change it. ttg_swapabilities can move an ability
	between slots, but a console command is not something you reach for between
	rounds, so this is the way to it: open with F2, click two abilities, done.
---------------------------------------------------------*/

local function ShowAbilityKeysMenu()

	local panel_width = 380
	local panel_height = 300

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( (ScrW()/2)-panel_width/2, 150 )
	DermaPanel:SetSize( panel_width, panel_height )
	DermaPanel:SetTitle( "Ability Keys" )
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
	Explain:SetText( "Click one ability, then another, to swap their keys." )
	Explain:SizeToContents()


	local SlotList = vgui.Create( "DListView", DermaPanel )
	SlotList:SetPos( 20, 65 )
	SlotList:SetSize( panel_width - 40, 160 )
	SlotList:SetMultiSelect( false )
	SlotList:AddColumn( "Key" )
	SlotList:AddColumn( "Ability" )


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


	--the slot a first click has picked out, waiting for a second
	local pending = nil

	--what the list was built from, so it is only rebuilt when something changed.
	--Rebuilding every frame like the other menus do would throw away the first
	--click before the second one ever arrived.
	local builtfrom = nil


	local function SlotSignature()
		local ply = LocalPlayer()
		if not IsValid( ply ) then return "" end

		local parts = {}
		for i = 1, TTG_AbilitySlotCount() do
			table.insert( parts, ply:GetAbilityInfo( i ).name )
		end

		return table.concat( parts, "|" )
	end


	local function Rebuild()
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		SlotList:Clear( true )

		--the pick is gone with the rows it referred to, so the prompt has to go
		--with it or it keeps asking about a slot nobody chose
		pending = nil
		Status:SetText( "" )
		Status:SizeToContents()

		for i = 1, TTG_AbilitySlotCount() do
			local info = ply:GetAbilityInfo( i )

			--the key this player actually has, not the one the table names
			local label = TTG_AbilityKeyLabel( i )

			local name = "( empty )"
			if info.name != "none" then name = ConvertToPrintName( info.name ) end

			SlotList:AddLine( label, name )
		end
	end


	SlotList.OnRowSelected = function( self, index, row )
		--first click picks, second click swaps
		if pending == nil then
			pending = index
			Status:SetColor( Color(255,255,255,255) )
			Status:SetText( "Swap " .. row:GetValue(1) .. " with...?" )
			Status:SizeToContents()
			return
		end

		if pending == index then
			pending = nil
			Status:SetText( "" )
			Status:SizeToContents()
			self:ClearSelection()
			return
		end

		RunConsoleCommand( "ttg_swapabilities", tostring( pending ), tostring( index ) )

		pending = nil
		Status:SetText( "" )
		Status:SizeToContents()
		self:ClearSelection()
	end


	local function Update()
		--only rebuild when the abilities actually changed, so a pending first
		--click survives long enough to be paired with a second
		local signature = SlotSignature()
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

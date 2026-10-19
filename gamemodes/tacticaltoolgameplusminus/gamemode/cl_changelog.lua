/*---------------------------------------------------------
	Changelog Window
---------------------------------------------------------*/

--F3, opened and closed by the server the same way F1's tool library is
--(server_fkeypress.lua). What it lists is TTG_CHANGELOG, in changelog.lua.

local Panel


local function Close()
	if IsValid( Panel ) then Panel:Close() end
	Panel = nil
	gui.EnableScreenClicker( false )
end
usermessage.Hook( "Close_ChangelogVgui", Close )


function ShowChangelog()
	--a second open while one is up replaces it rather than stacking
	if IsValid( Panel ) then Panel:Close() end

	local panel_width = 560
	local panel_height = 480

	Panel = vgui.Create( "DFrame" )
	Panel:SetPos( ( ScrW() / 2 ) - panel_width / 2, 100 )
	Panel:SetSize( panel_width, panel_height )
	Panel:SetTitle( "Changelog" )
	Panel:SetDraggable( false )
	Panel:ShowCloseButton( false )
	Panel:SetDeleteOnClose( true )
	Panel:SetMouseInputEnabled( true )

	local hint = vgui.Create( "DLabel", Panel )
	hint:Dock( BOTTOM )
	hint:DockMargin( 10, 4, 10, 4 )
	hint:SetFont( "TheDefaultSettings7" )
	hint:SetColor( Color( 160, 160, 160, 255 ) )
	hint:SetText( "F3 to close" )
	hint:SetContentAlignment( 6 )

	local scroll = vgui.Create( "DScrollPanel", Panel )
	scroll:Dock( FILL )
	scroll:DockMargin( 10, 4, 10, 0 )

	for index, entry in ipairs( TTG_CHANGELOG or {} ) do
		local date = scroll:Add( "DLabel" )
		date:Dock( TOP )
		date:DockMargin( 0, index == 1 and 0 or 14, 0, 4 )
		date:SetFont( "TheDefaultSettings5" )
		date:SetColor( Color( 255, 255, 255, 255 ) )
		date:SetText( entry.date )
		date:SizeToContents()

		for _, note in ipairs( entry.notes or {} ) do
			local line = scroll:Add( "DLabel" )
			line:Dock( TOP )
			line:DockMargin( 12, 0, 0, 3 )
			line:SetFont( "TheDefaultSettings7" )
			line:SetColor( Color( 215, 215, 215, 255 ) )
			line:SetWrap( true )
			line:SetAutoStretchVertical( true )
			line:SetText( "- " .. note )
		end
	end

	--the cursor, for scrolling once the list is longer than the window
	gui.EnableScreenClicker( true )
end
usermessage.Hook( "Open_ChangelogVgui", ShowChangelog )

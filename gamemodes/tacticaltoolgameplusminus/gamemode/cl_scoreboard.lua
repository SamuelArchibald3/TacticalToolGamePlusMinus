


local function ReturnToolPurchaseDisplay( swepname, ammo, numguns )
	local convertedname = ConvertToPrintName(swepname)
	local toolref = ToolReference(swepname)
	
	if toolref == nil then 
	return "Error"
	end
	
	local namedisplay = nil
	
	--Abilities
	if toolref.class == "ability" then
		//namedisplay = ( "(ABILITY) " .. convertedname )
		namedisplay = ( convertedname )
		
	--Guns
	elseif toolref.class == "gun" then
	
		if numguns == 1 then
			//namedisplay = ( "(GUN) " .. convertedname )
			namedisplay = ( convertedname )
		elseif numguns == 2 then
			//namedisplay = ( "(GUN) " .. "Double " .. convertedname )
			namedisplay = ( "Double " .. convertedname )
		elseif numguns == 3 then
			//namedisplay = ( "(GUN) " .. "Triple " .. convertedname )
			namedisplay = ( "Triple " .. convertedname )
		end
		
		
	--Items
	elseif toolref.class == "item" then
		//namedisplay = ( "(ITEM) " .. convertedname .. " x" .. ammo)
		namedisplay = ( convertedname .. " x" .. ammo)
	end
	
	
	if namedisplay == nil then
		namedisplay = "Error"
	end
	
	return namedisplay
end








/*----------------------------------------------------------------------------------------------------------
	Scoreboard
	
	Shows what everyone on your team and the enemy team has bought
------------------------------------------------------------------------------------------------------------*/


function DermaScoreboard()
	local ply = LocalPlayer()
	local panel_width = 300
	local panel_height = 450
	
	--RED team for spectators
	local PanelFriendly = vgui.Create( "DFrame" )
	PanelFriendly:SetPos( 25, 100 )
	PanelFriendly:SetSize( panel_width, panel_height )
	if ply:Team() == TEAM_SPEC then
		PanelFriendly:SetTitle( "Red Team" ) 
	else
		PanelFriendly:SetTitle( "Your Team's Purchases" ) 
	end
	PanelFriendly:SetVisible( true )
	PanelFriendly:SetDraggable( false ) //Can the player drag the frame /True/False
	PanelFriendly:ShowCloseButton( false ) //Show the X (Close button) /True/False
	PanelFriendly:SetDeleteOnClose(true)
	

	local InventoryListFriendly = vgui.Create( "DPanelList", PanelFriendly )
	InventoryListFriendly:SetPos( 25,25 )
	InventoryListFriendly:SetSize( panel_width - 25, panel_height -25 )
	InventoryListFriendly:SetSpacing( 5 ) -- Spacing between items
	InventoryListFriendly:EnableHorizontal( false ) -- Only vertical items
	InventoryListFriendly:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
 
 
	--BLUE team for spectators
	local PanelEnemy = vgui.Create( "DFrame" )
	PanelEnemy:SetPos( ScrW()-panel_width-25, 100 )
	PanelEnemy:SetSize( panel_width, panel_height )
	if ply:Team() == TEAM_SPEC then
		PanelEnemy:SetTitle( "Blue Team" ) 
	else
		PanelEnemy:SetTitle( "Enemy Team's Purchases" ) 
	end	
	PanelEnemy:SetVisible( true )
	PanelEnemy:SetDraggable( false ) //Can the player drag the frame /True/False
	PanelEnemy:ShowCloseButton( false ) //Show the X (Close button) /True/False
	PanelEnemy:SetDeleteOnClose(true)
	

	local InventoryListEnemy = vgui.Create( "DPanelList", PanelEnemy )
	InventoryListEnemy:SetPos( 25,25 )
	InventoryListEnemy:SetSize( panel_width - 25, panel_height -25 )
	InventoryListEnemy:SetSpacing( 5 ) -- Spacing between items
	InventoryListEnemy:EnableHorizontal( false ) -- Only vertical items
	InventoryListEnemy:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
	
	
	
	if GetGlobalString("CL_CurPhase") == "GameSetup" or GetGlobalString("CL_CurPhase") == ""  then
		PanelFriendly:SetVisible( false )
		PanelEnemy:SetVisible( false )
	end
		
	local function Update()

		--Friendly Vars--------------------------------------------------
		local friendly_team = nil
		
		if ply:Team() == TEAM_SPEC then
			friendly_team = TEAM_RED
		else
			friendly_team = ply:Team()
		end
	
		local friendly_color = nil
		if friendly_team == TEAM_RED then
			friendly_color = Color(255,150,150,255)
			friendly_color_dead = Color(100,50,50,255)
		else
			friendly_color = Color(150,150,255,255)
			friendly_color_dead = Color(50,50,100,255)
		end
		----------------------------------------------------------------
		--Enemy Vars-----------------------------------------------------
		local enemy_team = nil
		if ply:Team() == TEAM_RED then
			enemy_team = TEAM_BLUE
		elseif ply:Team() == TEAM_BLUE then
			enemy_team = TEAM_RED
		elseif ply:Team() == TEAM_SPEC then
			enemy_team = TEAM_BLUE
		end
		
		
		
		local enemy_color = nil
		if enemy_team == TEAM_RED then
			enemy_color = Color(255,150,150,255)
			enemy_color_dead = Color(100,50,50,255)
		else
			enemy_color = Color(150,150,255,255)
			enemy_color_dead = Color(50,50,100,255)
		end
		-----------------------------------------------------------------
		
		//Clear both display lists
		InventoryListFriendly:Clear(true)
		InventoryListEnemy:Clear(true)
		

		local role_friendly = GetTeamRole( friendly_team )
		local RoleFriendly = vgui.Create( "DLabel" )
		RoleFriendly:SetText( "         ---- " .. role_friendly .. " ----", TEXT_ALIGN_CENTER)
		RoleFriendly:SetColor( Color(255,255,255,255) )
		RoleFriendly:SetFont( "TheDefaultSettings7" )
		InventoryListFriendly:AddItem( RoleFriendly )
		
		local role_enemy = GetTeamRole( enemy_team )
		local RoleEnemy = vgui.Create( "DLabel" )
		RoleEnemy:SetText( "         ---- " .. role_enemy .. " ----", TEXT_ALIGN_CENTER )
		RoleEnemy:SetColor( Color(255,255,255,255) )
		RoleEnemy:SetFont( "TheDefaultSettings7" )
		InventoryListEnemy:AddItem( RoleEnemy )
		
		
		for _,v in pairs(player.GetAll()) do
			if v:Team() != TEAM_SPEC then
				local dead = false
				if v:IsValidGamePlayer() then
					dead = false
				else
					dead = true
				end
				
			
				----Friends--------------------------------------------------------------------------------------------
				if v:Team() == friendly_team then				
					local PlayerInventoryFriendly = vgui.Create( "DLabel" )
					if dead == false then
						PlayerInventoryFriendly:SetText( v:Name() .. ":" )
						PlayerInventoryFriendly:SetColor( friendly_color )
					else
						PlayerInventoryFriendly:SetText( v:Name() .. ":    (DEAD)" )
						PlayerInventoryFriendly:SetColor( friendly_color_dead )
					end	
					PlayerInventoryFriendly:SetFont("TheDefaultSettings7")	
					PlayerInventoryFriendly:SizeToContents()
						InventoryListFriendly:AddItem( PlayerInventoryFriendly )
					
					local t_table = v:GetAllToolNamesAndAmmo()
					
					for _,swep in pairs(t_table) do
						local swepname = swep.name
						local ammo = swep.ammo
						local numguns = swep.numguns
						
						local namedisplay = ReturnToolPurchaseDisplay( swepname, ammo, numguns )
						
						
						local PlayerTool = vgui.Create( "DLabel" )
						PlayerTool:SetText( "     " .. namedisplay )
						PlayerTool:SetColor(Color(255,255,255,255))
						PlayerTool:SetFont("TheDefaultSettings7")
						PlayerTool:SizeToContents()
							InventoryListFriendly:AddItem( PlayerTool )
						
					end
					
					local DashLine = vgui.Create( "DLabel" )
						DashLine:SetText( "    " )
						DashLine:SetColor( friendly_color )
						DashLine:SetFont("DebugFixed")
						DashLine:SizeToContents()
							InventoryListFriendly:AddItem( DashLine )
				----Friends--------------------------------------------------------------------------------------------
				

				//print( enemy_team )
				----Enemies--------------------------------------------------------------------------------------------
				elseif v:Team() == enemy_team then
					//print("heres enemy on purhcases menu", v)
					local dead = false
					if v:IsValidGamePlayer() then
						dead = false
					else
						dead = true
					end
				
				
					local PlayerInventory = vgui.Create( "DLabel" )
					if dead == false then
						PlayerInventory:SetText( v:Name() .. ":" )
						PlayerInventory:SetColor( enemy_color )
					else
						PlayerInventory:SetText( v:Name() .. ":    (DEAD)" )
						PlayerInventory:SetColor( enemy_color_dead )
					end	
					PlayerInventory:SetFont("TheDefaultSettings7")
					PlayerInventory:SizeToContents()
						InventoryListEnemy:AddItem( PlayerInventory )
					
					
					local t_table = v:GetAllToolNamesAndAmmo()
					

					for _,swep in pairs(t_table) do

						local swepname = swep.name
						local ammo = swep.ammo
						local numguns = swep.numguns
							
						local namedisplay = ReturnToolPurchaseDisplay( swepname, ammo, numguns )
			
						local PlayerTool = vgui.Create( "DLabel" )
						PlayerTool:SetText( "     " .. namedisplay )
						PlayerTool:SetColor(Color(255,255,255,255))
						PlayerTool:SetFont("TheDefaultSettings7")
						PlayerTool:SizeToContents()
							InventoryListEnemy:AddItem( PlayerTool )
					end
					
					
					local DashLine = vgui.Create( "DLabel" )
						DashLine:SetText( "    " )
						DashLine:SetFont("DebugFixed")
						DashLine:SizeToContents()
						InventoryListEnemy:AddItem( DashLine )
				
				end	
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
	//hook.Add("Tick", "Update_ScoreboardVgui", Update)

	
	
	local function Close()
		PanelFriendly:SetVisible( false )
		PanelFriendly:Close()
		PanelEnemy:SetVisible( false )
		PanelEnemy:Close()
		StopTimer = true
		//hook.Remove( "Tick", "Update_ScoreboardVgui" )
	end
	hook.Add("ScoreboardHide", "Close_ScoreboardVgui", Close)
	
 
	
end
hook.Add("ScoreboardShow", "Open_ScoreboardVgui", DermaScoreboard)









surface.CreateFont( "ScoreboardDefault",
{
	font		= "Helvetica",
	size		= 22,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})


--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = 
{
	Init = function( self )

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )		

		self.Name		= self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:DockMargin( 8, 0, 0, 0 )

		self.Mute		= self:Add( "DImageButton" )
		self.Mute:SetSize( 32, 32 )
		self.Mute:Dock( RIGHT )

		self.Ping		= self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetContentAlignment( 5 )

		self.Deaths		= self:Add( "DLabel" )
		self.Deaths:Dock( RIGHT )
		self.Deaths:SetWidth( 50 )
		self.Deaths:SetFont( "ScoreboardDefault" )
		self.Deaths:SetContentAlignment( 5 )

		self.Kills		= self:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 50 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetContentAlignment( 5 )

		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 2, 0, 2, 2 )

	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		self.Name:SetText( pl:Nick() )

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end

		if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
			self.NumKills	=	self.Player:Frags()
			self.Kills:SetText( self.NumKills )
		end

		if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
			self.NumDeaths	=	self.Player:Deaths()
			self.Deaths:SetText( self.NumDeaths )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing	=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self.Mute:SetImage( "icon32/muted.png" )
			else
				self.Mute:SetImage( "icon32/unmuted.png" )
			end

			self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

		end

		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end

		--
		-- This is what sorts the list. The panels are docked in the z order, 
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos( (self.NumKills * -50) + self.NumDeaths )

	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		if ( self.Player:Team() == TEAM_CONNECTING ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 200 ) )
			return
		end
		
		if ( self.Player:Team() == TEAM_RED ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 250, 150, 150, 200 ) )
			return
		end
		
		if ( self.Player:Team() == TEAM_BLUE ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 150, 150, 250, 200 ) )
			return
		end

		draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230, 255 ) )

	end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );

--
-- Here we define a new panel table for the scoreboard. It basically consists 
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = 
{
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 100 )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "ScoreboardDefaultTitle" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( TOP )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )

		self.Scores = self:Add( "DScrollPanel" )
		self.Scores:Dock( FILL )

	end,

	PerformLayout = function( self )

		self:SetSize( 700, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 350, 100 )

	end,

	Paint = function( self, w, h )

		--draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

	end,

	Think = function( self, w, h )

		self.Name:SetText( GetHostName() )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )

			self.Scores:AddItem( pl.ScoreEntry )

		end		

	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );













function GM:ScoreboardShow()
	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		//g_Scoreboard:RequestFocus()
		//g_Scoreboard:MakePopup()
	end
end


function GM:ScoreboardHide()
	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end
end





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
	Purchases
	
	Shows what everyone on your team and the enemy team has bought
------------------------------------------------------------------------------------------------------------*/


function NewShowTeamPurchasesMenu()
	local ply = LocalPlayer()
	local panel_width = 300
	local panel_height = 450
	
	
	--quick and dirty fix for resolution problems, will fix it correctly later
	local override = false
	if ScrW() <= 1366 then
		override = true
	end
 
 
	//Panel for friendly team's purchases, updates as purchases are made
	local PanelFriendly = vgui.Create( "DFrame" )
	PanelFriendly:SetPos( 25, 100 )
	PanelFriendly:SetSize( panel_width, panel_height )
	if ply:Team() == TEAM_SPEC then
		PanelFriendly:SetTitle( "Red Team" ) 
	else
		PanelFriendly:SetTitle( "Your Team's Purchases" ) 
	end
	if override == false then
		PanelFriendly:SetVisible( true )
	else
		PanelFriendly:SetVisible( false )
	end
	PanelFriendly:SetDraggable( false ) //Can the player drag the frame /True/False
	PanelFriendly:ShowCloseButton( false ) //Show the X (Close button) /True/False
	PanelFriendly:SetDeleteOnClose(true)
	

	local InventoryListFriendly = vgui.Create( "DPanelList", PanelFriendly )
	InventoryListFriendly:SetPos( 25,25 )
	InventoryListFriendly:SetSize( panel_width - 25, panel_height -25 )
	InventoryListFriendly:SetSpacing( 5 ) -- Spacing between items
	InventoryListFriendly:EnableHorizontal( false ) -- Only vertical items
	InventoryListFriendly:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
 
 
	//Panel for enemy team's purchases, updates as purchases are made
	local PanelEnemy = vgui.Create( "DFrame" )
	PanelEnemy:SetPos( ScrW()-panel_width-25, 100 )
	PanelEnemy:SetSize( panel_width, panel_height )
	if ply:Team() == TEAM_SPEC then
		PanelEnemy:SetTitle( "Blue Team" ) 
	else
		PanelEnemy:SetTitle( "Enemy Team's Purchases" ) 
	end	
	if override == false then
		PanelEnemy:SetVisible( true )
	else
		PanelEnemy:SetVisible( false )
	end
	PanelEnemy:SetDraggable( false ) //Can the player drag the frame /True/False
	PanelEnemy:ShowCloseButton( false ) //Show the X (Close button) /True/False
	PanelEnemy:SetDeleteOnClose(true)
	

	local InventoryListEnemy = vgui.Create( "DPanelList", PanelEnemy )
	InventoryListEnemy:SetPos( 25,25 )
	InventoryListEnemy:SetSize( panel_width - 25, panel_height -25 )
	InventoryListEnemy:SetSpacing( 5 ) -- Spacing between items
	InventoryListEnemy:EnableHorizontal( false ) -- Only vertical items
	InventoryListEnemy:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
	
	
	
	
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
		RoleEnemy:SetText( "         ---- " .. role_enemy .. " ----", TEXT_ALIGN_CENTER)
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
	//hook.Add("Tick", "Update_TeamPurchasesVgui", Update)

	
	
	local function Close()
		PanelFriendly:Close()
		PanelEnemy:Close()
		StopTimer = true
		//hook.Remove( "Tick", "Update_TeamPurchasesVgui" )
	end
	usermessage.Hook( "Close_TeamPurchasesVgui", Close )
 

end
usermessage.Hook( "Open_TeamPurchasesVgui", NewShowTeamPurchasesMenu )



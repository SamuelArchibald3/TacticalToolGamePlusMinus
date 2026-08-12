
/*----------------------------------------------------------------------------------------------------------
	Attackers Purchases
	
	Shows what everyone on the attacking team has bought
------------------------------------------------------------------------------------------------------------*/

function ShowAttackersPurchasesMenu()
	local ply = LocalPlayer()
	local panel_width = 300
	local panel_height = 450
 
 
	//Panel for red team's purchases, updates as purchases are made
	local Panel = vgui.Create( "DFrame" )

	Panel:SetPos( ScrW()-panel_width-25, 100 )
	Panel:SetSize( panel_width, panel_height )
	Panel:SetTitle( "Attacking Team's Purchases" ) 
	Panel:SetVisible( true )
	Panel:SetDraggable( false ) //Can the player drag the frame /True/False
	Panel:ShowCloseButton( false ) //Show the X (Close button) /True/False
	Panel:SetDeleteOnClose(true)
	

	local InventoryList = vgui.Create( "DPanelList", Panel )
	InventoryList:SetPos( 25,25 )
	InventoryList:SetSize( panel_width - 25, panel_height -25 )
	InventoryList:SetSpacing( 5 ) -- Spacing between items
	InventoryList:EnableHorizontal( false ) -- Only vertical items
	InventoryList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
 


	local attacking_team = nil
	
	if GetTeamRole( TEAM_RED ) == "Defending" then
		attacking_team = TEAM_BLUE
	elseif GetTeamRole( TEAM_RED ) == "Attacking" then
		attacking_team = TEAM_RED
	end
	
	
	local attacking_color = nil
	if attacking_team == TEAM_RED then
		attacking_color = Color(255,150,150,255)
	else
		attacking_color = Color(150,150,255,255)
	end
	
	
	
	local function Update()

		InventoryList:Clear(true)

		for _,v in pairs(player.GetAll()) do
		
			if v:Team() == attacking_team then
				
				local PlayerInventory = vgui.Create( "DLabel" )
				PlayerInventory:SetText( v:Name() .. "'s Tools:"  )
				PlayerInventory:SetColor( attacking_color )
				PlayerInventory:SetFont("TheDefaultSettings7")
				PlayerInventory:SizeToContents()
					InventoryList:AddItem( PlayerInventory )
				
				
				local t_table = v:GetAllToolNamesAndAmmo()
				
				for _,swep in pairs(t_table) do
					local swepname = swep.name
					local ammo = swep.ammo
					local numguns = swep.numguns
					
					local convertedname = ConvertToPrintName(swepname)
					local toolref = ToolReference(swepname)
					
					
					local namedisplay = nil
					
					--Abilities
					if toolref.class == "ability" then
						namedisplay = convertedname
						
						
					--Guns
					elseif toolref.class == "gun" then
					
						if numguns == 1 then
							namedisplay = ( convertedname )
						elseif numguns == 2 then
							namedisplay = ( "Double " .. convertedname )
						elseif numguns == 3 then
							namedisplay = ( "Triple " .. convertedname )
						end
						
						
					--Items
					elseif toolref.class == "item" then
						namedisplay = (convertedname .. " x" .. ammo)
					end
					
					
					if namedisplay == nil then
						namedisplay = "Error"
					end
					
					local PlayerTool = vgui.Create( "DLabel" )
					PlayerTool:SetText( "     " .. namedisplay )
					PlayerTool:SetColor(Color(255,255,255,255))
					PlayerTool:SetFont("TheDefaultSettings7")
					PlayerTool:SizeToContents()
						InventoryList:AddItem( PlayerTool )
				end
				
				
				local DashLine = vgui.Create( "DLabel" )
					DashLine:SetText( "    " )
					DashLine:SetColor( friendly_color )
					DashLine:SetFont("DebugFixed")
					DashLine:SizeToContents()
					InventoryList:AddItem( DashLine )
				
			end	
		end
	end
	hook.Add("Think", "Update_SpecPurchasesVgui_Attackers", Update)

	
	
	
	
	local function Close()
		Panel:Close()
		hook.Remove( "Think", "Update_SpecPurchasesVgui_Attackers" )
	end
	usermessage.Hook( "Close_SpecPurchasesVgui_Attackers", Close )
 

end
usermessage.Hook( "Open_SpecPurchasesVgui_Attackers", ShowAttackersPurchasesMenu )















/*----------------------------------------------------------------------------------------------------------
	Teammate Purchases
	
	Shows what everyone on your team has bought
------------------------------------------------------------------------------------------------------------*/


function ShowDefendersPurchasesMenu()
	local ply = LocalPlayer()
	local panel_width = 300
	local panel_height = 450
 
 
	//Panel for red team's purchases, updates as purchases are made
	local Panel = vgui.Create( "DFrame" )

	Panel:SetPos( 25, 100 )
	Panel:SetSize( panel_width, panel_height )
	Panel:SetTitle( "Defending Team's Purchases" ) 
	Panel:SetVisible( true )
	Panel:SetDraggable( false ) //Can the player drag the frame /True/False
	Panel:ShowCloseButton( false ) //Show the X (Close button) /True/False
	Panel:SetDeleteOnClose(true)
	

	local InventoryList = vgui.Create( "DPanelList", Panel )
	InventoryList:SetPos( 25,25 )
	InventoryList:SetSize( panel_width - 25, panel_height -25 )
	InventoryList:SetSpacing( 5 ) -- Spacing between items
	InventoryList:EnableHorizontal( false ) -- Only vertical items
	InventoryList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
 

	
	local defending_team = nil
	
	if GetTeamRole( TEAM_RED ) == "Defending" then
		defending_team = TEAM_RED
	elseif GetTeamRole( TEAM_RED ) == "Attacking" then
		defending_team = TEAM_BLUE
	end
	
	
	local defending_color = nil
	if defending_team == TEAM_RED then
		defending_color = Color(255,150,150,255)
	else
		defending_color = Color(150,150,255,255)
	end
	
	
	
	local function Update()

		InventoryList:Clear(true)

		for _,v in pairs(player.GetAll()) do
		
			if v:Team() == defending_team then
				
				local PlayerInventory = vgui.Create( "DLabel" )
				PlayerInventory:SetText( v:Name() .. "'s Tools:"  )
				PlayerInventory:SetColor( defending_color )
				PlayerInventory:SetFont("TheDefaultSettings7")
				PlayerInventory:SizeToContents()
					InventoryList:AddItem( PlayerInventory )
				
				
				local t_table = v:GetAllToolNamesAndAmmo()
				
				for _,swep in pairs(t_table) do
					local swepname = swep.name
					local ammo = swep.ammo
					local numguns = swep.numguns
					
					local convertedname = ConvertToPrintName(swepname)
					local toolref = ToolReference(swepname)
					
					
					local namedisplay = nil
					
					--Abilities
					if toolref.class == "ability" then
						namedisplay = convertedname
						
						
					--Guns
					elseif toolref.class == "gun" then
					
						if numguns == 1 then
							namedisplay = ( convertedname )
						elseif numguns == 2 then
							namedisplay = ( "Double " .. convertedname )
						elseif numguns == 3 then
							namedisplay = ( "Triple " .. convertedname )
						end
						
						
					--Items
					elseif toolref.class == "item" then
						namedisplay = (convertedname .. " x" .. ammo)
					end
					
					
					if namedisplay == nil then
						namedisplay = "Error"
					end
					
					local PlayerTool = vgui.Create( "DLabel" )
					PlayerTool:SetText( "     " .. namedisplay )
					PlayerTool:SetColor(Color(255,255,255,255))
					PlayerTool:SetFont("TheDefaultSettings7")
					PlayerTool:SizeToContents()
						InventoryList:AddItem( PlayerTool )
				end
				
				
				local DashLine = vgui.Create( "DLabel" )
					DashLine:SetText( "    " )
					DashLine:SetColor( friendly_color )
					DashLine:SetFont("DebugFixed")
					DashLine:SizeToContents()
					InventoryList:AddItem( DashLine )
				
			end	
		end
	end
	hook.Add("Tick", "Update_SpecPurchasesVgui_Defenders", Update)

	
	
	
	
	local function Close()
		Panel:Close()
		hook.Remove( "Tick", "Update_SpecPurchasesVgui_Defenders" )
	end
	usermessage.Hook( "Close_SpecPurchasesVgui_Defenders", Close )
 

end
usermessage.Hook( "Open_SpecPurchasesVgui_Defenders", ShowDefendersPurchasesMenu )


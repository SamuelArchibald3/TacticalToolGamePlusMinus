/*---------------------------------------------------------
	Buying-Phase Store Window
---------------------------------------------------------*/


function ShowHelpMenu()

	/*------------------------------------------------------------------------------------------------
		Panel setup
	-----------------------------------------------------------------------------------------------*/
	
	local panel_width = 800
	local panel_height = 600
 
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( (ScrW()/2)-panel_width/2, 100 )
	DermaPanel:SetSize( panel_width, panel_height )
	DermaPanel:SetTitle( "Tool Library" ) // Name of Fram
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false ) //Can the player drag the frame /True/False
	DermaPanel:ShowCloseButton( false ) //Show the X (Close button) /True/False
	DermaPanel:SetDeleteOnClose(true)
	DermaPanel:SetMouseInputEnabled(true)
	
	
	
	
	//Item shop----------------------------------------------------
	
	local FirstShopText = vgui.Create("DLabel", DermaPanel)
	FirstShopText:SetPos(25, 25) // Position
	FirstShopText:SetColor(Color(255,255,255,255)) // Color
	FirstShopText:SetFont("TheDefaultSettings5")
	FirstShopText:SetText("Item Tools") // Text
	FirstShopText:SizeToContents()
	
	local FirstShopColumn = vgui.Create("DListView")
	FirstShopColumn:SetParent(DermaPanel)
	FirstShopColumn:SetPos(25, 50)
	FirstShopColumn:SetSize(225, 350)
	FirstShopColumn:SetMultiSelect(false)
	FirstShopColumn:AddColumn("Tool")
	FirstShopColumn:AddColumn("Pack Amount")
	FirstShopColumn:SetDirty( true )
	
	
	
	
	
	
	
	
	//Gun shop----------------------------------------------------
	
	local SecondShopText = vgui.Create("DLabel", DermaPanel)
	SecondShopText:SetPos(275, 25) // Position
	SecondShopText:SetColor(Color(255,255,255,255)) // Color
	SecondShopText:SetFont("TheDefaultSettings5")
	SecondShopText:SetText("Weapon Tools")
	SecondShopText:SizeToContents()

	local SecondShopColumn = vgui.Create("DListView")
	SecondShopColumn:SetParent(DermaPanel)
	SecondShopColumn:SetPos(275, 50)
	SecondShopColumn:SetSize(225, 350)
	SecondShopColumn:SetMultiSelect(false)
	SecondShopColumn:AddColumn("Tool")


	

	
	
	
	
	
	//Ability shop----------------------------------------------------
	
	local ThirdShopText = vgui.Create("DLabel", DermaPanel)
	ThirdShopText:SetPos(525, 25) // Position
	ThirdShopText:SetColor(Color(255,255,255,255)) // Color
	ThirdShopText:SetFont("TheDefaultSettings5")
	ThirdShopText:SetText("Ability Tools") // Text
	ThirdShopText:SizeToContents()

	local ThirdShopColumn = vgui.Create("DListView")
	ThirdShopColumn:SetParent(DermaPanel)
	ThirdShopColumn:SetPos(525, 50)
	ThirdShopColumn:SetSize(225, 350)
	ThirdShopColumn:SetMultiSelect(false)
	ThirdShopColumn:AddColumn("Tool")

	
	
	//add all purchases to the shops
	for _, purchase in pairs(FIRSTSHOP_TABLE) do
		if purchase.not_in_shop != true then
			FirstShopColumn:AddLine( purchase.print_name, purchase.pack_amount )  
		end
	end
	
	for _, purchase in pairs(SECONDSHOP_TABLE) do
		if purchase.not_in_shop != true then
			SecondShopColumn:AddLine( purchase.print_name )  
		end
	end	
	
	for _, purchase in pairs(THIRDSHOP_TABLE) do
		if purchase.not_in_shop != true then
			ThirdShopColumn:AddLine( purchase.print_name )  
		end
	end
	
	
	//Sort all the collumns, by name alphabetically
	FirstShopColumn:SortByColumn( 1 )
	SecondShopColumn:SortByColumn( 1 )
	ThirdShopColumn:SortByColumn( 1 )

	
	//the text that displays what tool is selected in the list
	local SelectedToolText = vgui.Create("DLabel", DermaPanel)
	SelectedToolText:SetPos(23, 420) // Position
	SelectedToolText:SetColor(Color(255,255,255,255)) // Color
	SelectedToolText:SetFont("TheDefaultSettings8")
	SelectedToolText:SetText("-") // Text
	
	//the text that displays what tool is selected in the list
	local DescriptionText = vgui.Create("DLabel", DermaPanel)
	DescriptionText:SetPos(25, 450) // Position
	DescriptionText:SetColor(Color(200,200,200,255)) // Color
	DescriptionText:SetFont("TheDefaultSettings7")
	DescriptionText:SetText("-") // Text

	
	local HowToBuy = vgui.Create("DLabel", DermaPanel)
	HowToBuy:SetPos(600, 565) // Position
	HowToBuy:SetColor(Color(255,255,255,255)) // Color
	HowToBuy:SetFont("TheDefaultSettings5")
	HowToBuy:SetText("(press F1 to close)") // Text
	HowToBuy:SizeToContents()
	
-- hook.Add( "PlayerDeath", "GlobalDeathMessage", function( victim, inflictor, attacker )
-- for k, v in pairs(player.GetAll()) do
-- 	if !v:Alive() then
		
-- 			local DermaButton = vgui.Create( "DButton", DermaPanel ) // Create the button and parent it to the frame
-- 			DermaButton:SetText( "Spectate" )					// Set the text on the button
-- 			DermaButton:SetPos( 25, 500 )					// Set the position on the frame
-- 			DermaButton:SetSize( 80, 30 )					// Set the size
-- 			function DermaButton:DoClick()	
-- 				concommand.Add("spectate", function(self, cmd, args)
-- 					if self:IsAdmin() == false then
					
-- 					if self:GetObserverMode() != 6 then
-- 						self:Flashlight(false)
-- 						self.handsmodel = nil
-- 						self:Spectate(6)
-- 						self:SetObserverMode(6)
-- 						self:SetColor(0, 0, 0, 255)
-- 						self:StripWeapons()
-- 						self:RemoveAllAmmo()
-- 						--self:SetTeam(TEAM_SPECTATOR)
-- 						self:SetNoDraw(true)
-- 						self:SetNoTarget(true)
-- 						self:AllowFlashlight(false)
-- 					RunConsoleCommand("spectate")
-- 					end
-- 					end
-- 				end)
-- 			end
		
-- 		end
-- 	end
	-- end)
	local Commands = vgui.Create("DLabel", DermaPanel)
	Commands:SetPos(25, 550) // Position
	Commands:SetColor(Color(255,255,255,255)) // Color
	Commands:SetFont("TheDefaultSettings5")
	if VOTE_CHANGEMAP_ENABLED == true then
		Commands:SetText("Chat commands: \n!votekick,   !voterestart,   !votemap") // Text
	else
		Commands:SetText("Chat commands: \n!votekick,   !voterestart") // Text
	end
	Commands:SizeToContents()
	
	
	--[[
	//the money you have
	local ToolTokens = vgui.Create("DLabel", DermaPanel)
	ToolTokens:SetPos(620, 490) // Position
	ToolTokens:SetColor(Color(100,255,100,255)) // Color
	ToolTokens:SetFont("CloseCaption_Bold")
	ToolTokens:SetText("-") // Text
	
	]]--

	
	--clears the selection of all other shops besides the input number, runs when something is selected in a shop
	local function ClearAllOtherShops(sel_shop)
		if sel_shop == 1 then
			SecondShopColumn:ClearSelection()
			ThirdShopColumn:ClearSelection()
		elseif sel_shop == 2 then
			FirstShopColumn:ClearSelection()
			ThirdShopColumn:ClearSelection()
		elseif sel_shop == 3 then
			FirstShopColumn:ClearSelection()
			SecondShopColumn:ClearSelection()
		end
	end
	
	

	
	
	
	
	function FirstShopColumn:OnRowSelected()
		ClearAllOtherShops(1)
	end
	
	function SecondShopColumn:OnRowSelected()
		ClearAllOtherShops(2)
	end
	
	function ThirdShopColumn:OnRowSelected()
		ClearAllOtherShops(3)
	end
	
	

	
	
	/*---------------------------------------------------------
	Update on think function
	---------------------------------------------------------*/
	local function Update()
		gui.EnableScreenClicker(true)
		

		local have_a_selection = false
		local purchaseref = nil
		
		if FirstShopColumn:GetSelectedLine( ) != nil then 
			have_a_selection = true

			local linenumber = FirstShopColumn:GetSelectedLine( ); local toolline = FirstShopColumn:GetLine(linenumber)
			local printname = toolline:GetValue(1)
			
			local purchasename = Shop_ConvertToName(printname, FIRSTSHOP_TABLE)
			purchaseref = Shop_Reference(purchasename, FIRSTSHOP_TABLE)
			
		elseif SecondShopColumn:GetSelectedLine( ) != nil then 
			have_a_selection = true
			
			local linenumber = SecondShopColumn:GetSelectedLine( ); local toolline = SecondShopColumn:GetLine(linenumber)
			local printname = toolline:GetValue(1)
			
			local purchasename = Shop_ConvertToName(printname, SECONDSHOP_TABLE)
			purchaseref = Shop_Reference(purchasename, SECONDSHOP_TABLE)
			
		elseif ThirdShopColumn:GetSelectedLine( ) != nil then 
			have_a_selection = true
			
			local linenumber = ThirdShopColumn:GetSelectedLine( ); local toolline = ThirdShopColumn:GetLine(linenumber)
			local printname = toolline:GetValue(1)
			
			local purchasename = Shop_ConvertToName(printname, THIRDSHOP_TABLE)
			purchaseref = Shop_Reference(purchasename, THIRDSHOP_TABLE)
			
		end
		

			
		if have_a_selection then
		
			SelectedToolText:SetText( purchaseref.print_name )
			SelectedToolText:SizeToContents()
			
			DescriptionText:SetText( purchaseref.description )
			DescriptionText:SizeToContents()
		else

			SelectedToolText:SetText("-")
			SelectedToolText:SizeToContents()
		end	
	end
	hook.Add("Think", "Update_HelpVgui", Update)

	
	
	
	/*---------------------------------------------------------
		Close
	---------------------------------------------------------*/
	local function Close()
		DermaPanel:Close()
		hook.Remove( "Think", "Update_HelpVgui" )
		gui.EnableScreenClicker(false)
	end
	usermessage.Hook( "Close_HelpVgui", Close )
 

end
usermessage.Hook( "Open_HelpVgui", ShowHelpMenu )
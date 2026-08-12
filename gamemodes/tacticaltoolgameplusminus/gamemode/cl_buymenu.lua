/*---------------------------------------------------------
	Buying-Phase Store Window
---------------------------------------------------------*/


function ShowBuyingMenu()

	local Ply = LocalPlayer()
	
	--Returns true if the local player is buying, false if otherwise
	local function LocalPlyIsBuying()
		local buying = false
		
		if GetTeamRole(Ply:Team()) == GetGlobalString("CL_CurBuyingRole") then
			buying = true
		end
		
		return buying
	end
	
	
	

	
	

	
	/*------------------------------------------------------------------------------------------------
		Panel setup
	-----------------------------------------------------------------------------------------------*/
	
	local panel_width = 800
	local panel_height = 575
 
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( (ScrW()/2)-panel_width/2, 100 )
	DermaPanel:SetSize( panel_width, panel_height )
	DermaPanel:SetTitle( "Select your tools!" ) // Name of Fram
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false ) //Can the player drag the frame /True/False
	DermaPanel:ShowCloseButton( false ) //Show the X (Close button) /True/False
	DermaPanel:SetDeleteOnClose(true)
	DermaPanel:SetMouseInputEnabled(true)
	
	
	
	
	//Item shop----------------------------------------------------
	
	local FirstShopText = vgui.Create("DLabel", DermaPanel)
	FirstShopText:SetPos(25, 25) // Position
	FirstShopText:SetColor(Color(255,255,255,255)) // Color
	FirstShopText:SetFont("CloseCaption_Bold")
	FirstShopText:SetText("Item Tools") // Text
	FirstShopText:SizeToContents()
	FirstShopText:SetFont("TheDefaultSettings5")
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
	SecondShopText:SetFont("CloseCaption_Bold")
	SecondShopText:SetText("Weapon Tools")
	SecondShopText:SizeToContents()
	SecondShopText:SetFont("TheDefaultSettings5")
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
	ThirdShopText:SetFont("CloseCaption_Bold")
	ThirdShopText:SetText("Ability Tools") // Text
	ThirdShopText:SizeToContents()
	ThirdShopText:SetFont("TheDefaultSettings5")
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
	SelectedToolText:SetPos(25, 410) // Position
	SelectedToolText:SetColor(Color(255,255,255,255)) // Color
	SelectedToolText:SetFont("TheDefaultSettings5")
	SelectedToolText:SetText("-") // Text
	
	//the text that displays what tool is selected in the list
	local DescriptionText = vgui.Create("DLabel", DermaPanel)
	DescriptionText:SetPos(25, 435) // Position
	DescriptionText:SetColor(Color(200,200,200,255)) // Color
	DescriptionText:SetFont("TheDefaultSettings7")
	DescriptionText:SetText("-") // Text

	

	//Buy tool button
	//local BuyButton = vgui.Create( "DButton", DermaPanel )
	//BuyButton:SetText( "Purchase" )
	//BuyButton:SetPos( 25, 470)
	//BuyButton:SetSize( 225, 75 )

	
	
	//the money you have
	local HowToBuy = vgui.Create("DLabel", DermaPanel)
	HowToBuy:SetPos(40, 537) // Position
	HowToBuy:SetColor(Color(255,255,255,255)) // Color
	HowToBuy:SetFont("TheDefaultSettings5")
	HowToBuy:SetText("(Right click tools to buy them)") // Text
	HowToBuy:SizeToContents()

	
	//the money you have
	local ToolTokens = vgui.Create("DLabel", DermaPanel)
	ToolTokens:SetPos(620, 490) // Position
	ToolTokens:SetColor(Color(100,255,100,255)) // Color
	ToolTokens:SetFont("CloseCaption_Bold")
	ToolTokens:SetText("-") // Text
	
	
	
	//local FirstShopTimeText = vgui.Create("DLabel", DermaPanel)
	///FirstShopTimeText:SetPos(panel_width/2, 500) // Position
	//FirstShopTimeText:SetColor(Color(255,255,255,255)) // Color
	//FirstShopTimeText:SetFont("CloseCaption_Bold")
	//FirstShopTimeText:SetText("") // Text
	//FirstShopTimeText:SizeToContents()
	
	
	--[[
	
	/*---------------------------------------------------------
		Buying-Phase local functions
	---------------------------------------------------------*/
	
	local timetext = nil
	

	local function  ShopTimerUpdate(num)
		timetext = num:ReadString()
		FirstShopTimeText:SetText(timetext .. " - Until Defender's turn is over.") 
		FirstShopTimeText:SizeToContents()
	end
	usermessage.Hook( "ShopTimerUpdate" , ShopTimerUpdate)
	
	
	local function  BuyingEndsTimerText(num)
		timetext = num:ReadString()
		FirstShopTimeText:SetText(timetext .. " - Until Attacker's turn is over.") 
		FirstShopTimeText:SizeToContents()
	end
	usermessage.Hook( "BuyingEndsTimerUpdate" , BuyingEndsTimerText)
	
	
	local function  RoundStartingTimerText(num)
		timetext = num:ReadString()
		FirstShopTimeText:SetText(timetext .. " - Until Round Starts.") 
		FirstShopTimeText:SizeToContents()
	end
	usermessage.Hook( "RoundStartingTimerUpdate" , RoundStartingTimerText)
 
	]]--
	//FirstShopColumn:SelectFirstItem( )
	
	
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
	
	

	
	
	
	
	local function BuyTool()
		//if LocalPlyIsBuying() == false then return end
		
		local purchase = nil	
		
		if FirstShopColumn:GetSelectedLine( ) != nil then 
			local linenumber = FirstShopColumn:GetSelectedLine( ); local purchaseline = FirstShopColumn:GetLine(linenumber)
			purchase = Shop_ConvertToName(purchaseline:GetValue(1), FIRSTSHOP_TABLE)
		elseif SecondShopColumn:GetSelectedLine( ) != nil then 
			local linenumber = SecondShopColumn:GetSelectedLine( ); local purchaseline = SecondShopColumn:GetLine(linenumber)
			purchase = Shop_ConvertToName(purchaseline:GetValue(1), SECONDSHOP_TABLE)
		elseif ThirdShopColumn:GetSelectedLine( ) != nil then 
			local linenumber = ThirdShopColumn:GetSelectedLine( ); local purchaseline = ThirdShopColumn:GetLine(linenumber)
			purchase = Shop_ConvertToName(purchaseline:GetValue(1), THIRDSHOP_TABLE)
		end

		if purchase == nil then return end
		
		

		//Bought_Slot is a global which the swep will reference when setting its slot for the player
		Bought_Slot_To_Add_Wep_To = nil
		
		local swepcount = Ply:GetSwepCount()
		
		//Bought_Slot is a clientside var which the swep will reference when setting its slot
		Bought_Slot_To_Add_Wep_To = swepcount + 1
		
		//run the console command which gives the tool to the player
		RunConsoleCommand( "ttg_givepurchase", purchase )
	end
	
	
	
	FirstShopColumn.OnRowRightClick = BuyTool
	SecondShopColumn.OnRowRightClick = BuyTool
	ThirdShopColumn.OnRowRightClick = BuyTool
	
	
	/*---------------------------------------------------------
	Update on think function
	---------------------------------------------------------*/
	local function Update()
		gui.EnableScreenClicker(true)
		
		local buying = LocalPlyIsBuying()
		
		//Sets the shops to be open if the player's team is buying right now
		if buying == true then
			FirstShopText:SetColor(Color(255,255,255,255))
			SecondShopText:SetColor(Color(255,255,255,255))
			ThirdShopText:SetColor(Color(255,255,255,255))
			

		elseif buying == false then
			//FirstShopColumn:ClearSelection()
			//SecondShopColumn:ClearSelection()
			//ThirdShopColumn:ClearSelection()
			
			FirstShopText:SetColor(Color(130,130,130,255))
			SecondShopText:SetColor(Color(130,130,130,255))
			ThirdShopText:SetColor(Color(130,130,130,255))
			
		end
		
	
		
		
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
			
		if Ply:GetToolTokens() >= 1 then
			ToolTokens:SetColor(Color(100,255,100,255))
		else
			ToolTokens:SetColor(Color(255,100,100,255))
		end
	
		ToolTokens:SetText("Tool Tokens:\n  " .. Ply:GetToolTokens() .. " left")
		ToolTokens:SetFont( "TheDefaultSettings5" )
		ToolTokens:SizeToContents()
	end
	hook.Add("Think", "UpdateBuyingVgui", Update)

	
	
	
	
	
	
	/*---------------------------------------------------------
		Close
	---------------------------------------------------------*/
	local function Close()
		DermaPanel:Close()
		hook.Remove( "Think", "UpdateBuyingVgui" )
		gui.EnableScreenClicker(false)
	end
	usermessage.Hook( "Close_BuyingVgui", Close )
 

end
usermessage.Hook( "Open_BuyingVgui", ShowBuyingMenu )
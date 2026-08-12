function ShowInventoryMenu()
	local ply = LocalPlayer()
	local panel_width = 200
	local panel_height = 75
 
	local firstpanelxpos = (ScrW()/4)
	local secondpanelxpos = (ScrW()/4) + (panel_width + 10)
	local thirdpanelxpos = (ScrW()/4) + (panel_width + 10)*2
	local fourthpanelxpos = (ScrW()/4) + (panel_width + 10)*3
 
	//slot 1 panel
	local FirstPanel = vgui.Create( "DFrame" )
	FirstPanel:SetPos( firstpanelxpos,(ScrH()-panel_height-10) )
	FirstPanel:SetSize( panel_width, panel_height )
	FirstPanel:SetTitle( "Slot 1" ) 
	FirstPanel:SetVisible( true )
	FirstPanel:SetDraggable( false ) 
	FirstPanel:ShowCloseButton( false )
	FirstPanel:SetDeleteOnClose(true)
	
	local FirstSlotColumn = vgui.Create("DListView")
	FirstSlotColumn:SetParent(FirstPanel)
	FirstSlotColumn:SetPos(10, 25)
	FirstSlotColumn:SetSize(180, 40)
	FirstSlotColumn:SetMultiSelect(false)
	FirstSlotColumn:AddColumn("Tool")
	FirstSlotColumn:AddColumn("Ammo")
	
	
	//slot 2 panel
	local SecondPanel = vgui.Create( "DFrame" )
	SecondPanel:SetPos( secondpanelxpos,(ScrH()-panel_height-10) )
	SecondPanel:SetSize( panel_width, panel_height )
	SecondPanel:SetTitle( "Slot 2" ) 
	SecondPanel:SetVisible( true )
	SecondPanel:SetDraggable( false ) 
	SecondPanel:ShowCloseButton( false )
	SecondPanel:SetDeleteOnClose(true)
	
	local SecondSlotColumn = vgui.Create("DListView")
	SecondSlotColumn:SetParent(SecondPanel)
	SecondSlotColumn:SetPos(10, 25)
	SecondSlotColumn:SetSize(180, 40)
	SecondSlotColumn:SetMultiSelect(false)
	SecondSlotColumn:AddColumn("Tool")
	SecondSlotColumn:AddColumn("Ammo")
	
	
	
	//slot 3 panel
	local ThirdPanel = vgui.Create( "DFrame" )
	ThirdPanel:SetPos( thirdpanelxpos,(ScrH()-panel_height-10) )
	ThirdPanel:SetSize( panel_width, panel_height )
	ThirdPanel:SetTitle( "Slot 3" ) 
	ThirdPanel:SetVisible( true )
	ThirdPanel:SetDraggable( false ) 
	ThirdPanel:ShowCloseButton( false )
	ThirdPanel:SetDeleteOnClose(true)
	
	local ThirdSlotColumn = vgui.Create("DListView")
	ThirdSlotColumn:SetParent(ThirdPanel)
	ThirdSlotColumn:SetPos(10, 25)
	ThirdSlotColumn:SetSize(180, 40)
	ThirdSlotColumn:SetMultiSelect(false)
	ThirdSlotColumn:AddColumn("Tool")
	ThirdSlotColumn:AddColumn("Ammo")
	
	
	
	//slot 4 panel
	local FourthPanel = vgui.Create( "DFrame" )
	FourthPanel:SetPos( fourthpanelxpos,(ScrH()-panel_height-10) )
	FourthPanel:SetSize( panel_width, panel_height )
	FourthPanel:SetTitle( "Slot 4" ) 
	FourthPanel:SetVisible( true )
	FourthPanel:SetDraggable( false ) 
	FourthPanel:ShowCloseButton( false )
	FourthPanel:SetDeleteOnClose(true)
	
	local FourthSlotColumn = vgui.Create("DListView")
	FourthSlotColumn:SetParent(FourthPanel)
	FourthSlotColumn:SetPos(10, 25)
	FourthSlotColumn:SetSize(180, 40)
	FourthSlotColumn:SetMultiSelect(false)
	FourthSlotColumn:AddColumn("Tool")
	FourthSlotColumn:AddColumn("Ammo")
	
	
	
	local function Update()
		FirstSlotColumn:Clear(true)
		SecondSlotColumn:Clear(true)
		ThirdSlotColumn:Clear(true)
		FourthSlotColumn:Clear(true)
		
	
		local weptable = ply:GetWeapons()
		
		local num = 1
		
		for _,swep in pairs(weptable) do
			local name = swep:GetPrintName()
			local ammo = swep:GetTTGAmmo()

			//dont count the melee everyone spawns with as taking up a slot
			if swep:GetClass() != "default_melee" then 
			
				if num == 1 then
					FirstSlotColumn:AddLine(name, ammo)
				end
				
				if num == 2 then
					SecondSlotColumn:AddLine(name, ammo)
				end
				
				if num == 3 then
					ThirdSlotColumn:AddLine(name, ammo)
				end
				
				if num == 4 then
					FourthSlotColumn:AddLine(name, ammo)
				end	
				
				num = num + 1
			end
			
		end
	end
	hook.Add("Think", "Update_InventoryVgui", Update)

	

	local function Close()
		FirstPanel:Close()
		SecondPanel:Close()
		ThirdPanel:Close()
		FourthPanel:Close()
		hook.Remove( "Think", "Update_InventoryVgui" )
	end
	usermessage.Hook( "Close_InventoryVgui", Close )
 

end
usermessage.Hook( "Open_InventoryVgui", ShowInventoryMenu )
/*---------------------------------------------------------
	Displays flashing text telling the local player it's their turn to buy
---------------------------------------------------------*/

local function YourTurnToBuyHud()
	local Ply = LocalPlayer()
	
	--Returns true if the local player is buying, false if otherwise
	local function LocalPlyIsBuying()
		local buying = false
		
		--if CL_CurBuyingRole doesnt have anything, the local player is not buying
		if not ( GetGlobalString("CL_CurBuyingRole") == "Attacking" or GetGlobalString("CL_CurBuyingRole") == "Defending" ) then
			return false
		end
		
		
		if GetTeamRole(Ply:Team()) == GetGlobalString("CL_CurBuyingRole") then
			buying = true
		end
		
		return buying
	end
	
	
	//dont do anything if the local player isnt buying
	if not LocalPlyIsBuying() then return end
	
	
	
	local plyteam = Ply:Team()
	local role = GetTeamRole(plyteam)

	draw.SimpleText("It's your team's turn to buy!", "TheDefaultSettings3", ScrW()/2, ScrH()-150, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	draw.SimpleText("( " .. role .. " )", "TheDefaultSettings4", ScrW()/2, ScrH()-75, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	
end
hook.Add( "HUDPaint", "YourTurnToBuyHud", YourTurnToBuyHud )


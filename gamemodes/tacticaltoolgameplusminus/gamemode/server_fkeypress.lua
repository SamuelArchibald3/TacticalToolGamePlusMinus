
--there is now no way to join a team once the game has already begun
--[[
--F2 Key press
function TeamJoin( ply )
	//if we arent in pub mode, players cannot join while a game is already in progress
	if PUB_MODE != true then return end

	//if the game hasnt begun, players will join teams through the team setup panel
	if G_GameBegun != true then return end

	//if the menu is already open then close out of it
	if ply:GetIfTeamJoinMenuOpen() then 
		Close_JoinMenu( ply )
		return 
	end
	
	//open the menu
	Open_JoinMenu( ply )
end
hook.Add("ShowTeam", "TeamJoin", TeamJoin)

]]--






--help screen (shows all tools and descriptions)

--F1 Key press
function HelpGUI( ply )
	if ply.HelpMenuIsOpen != true then
		umsg.Start("Open_HelpVgui", ply)
		umsg.End()
		
		ply.HelpMenuIsOpen = true
		
	elseif ply.HelpMenuIsOpen == true then
		umsg.Start("Close_HelpVgui", ply)
		umsg.End()
		
		ply.HelpMenuIsOpen = false
	end
end
hook.Add("ShowHelp", "HelpGUI", HelpGUI)




--ability keys panel (which key runs which ability)

--F2 Key press. Free since the mid-game team join above was retired.
function AbilityKeysGUI( ply )
	if ply.AbilityKeysMenuIsOpen != true then
		umsg.Start("Open_AbilityKeysVgui", ply)
		umsg.End()

		ply.AbilityKeysMenuIsOpen = true

	else
		umsg.Start("Close_AbilityKeysVgui", ply)
		umsg.End()

		ply.AbilityKeysMenuIsOpen = false
	end
end
hook.Add("ShowTeam", "AbilityKeysGUI", AbilityKeysGUI)


--The panel closes itself through here rather than locally, so the server's
--idea of whether it is open stays true. Otherwise F2 would need pressing
--twice to bring it back.
function fCloseAbilityKeys( ply, command, arguments )
	Close_AbilityKeysForPly( ply )
end
concommand.Add( "ttg_abilitykeys_close", fCloseAbilityKeys )
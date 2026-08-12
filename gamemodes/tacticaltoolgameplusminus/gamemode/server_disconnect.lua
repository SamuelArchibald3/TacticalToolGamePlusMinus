/*---------------------------------------------------------
	all server files that have to do with players disconnecting from the server
---------------------------------------------------------*/

function GM:PlayerDisconnected( ply )
	--Remove all the player's ability ents
	Reset_PlyAbilities( ply )
	
	
	--remove the player from the list of players set to join a team after the current round
	for _, v in pairs( T_BlueJoiners ) do
		if v == ply then
			table.RemoveByValue( T_BlueJoiners, v )
		end
	end
	
	for _, v in pairs( T_RedJoiners ) do
		if v == ply then
			table.RemoveByValue( T_RedJoiners, v )
		end
	end
	
	
	--remove the player from the list of players touching the capture zone
	if G_CurAttackZone != nil then
		for _, v in pairs( G_CurAttackZone.TouchingPlyList ) do
			if v == ply then
				table.RemoveByValue( G_CurAttackZone.TouchingPlyList, v )
			end
		end
	end
	
end
/*---------------------------------------------------------
	Stuff that happens to players after they die before the next round
---------------------------------------------------------*/


//makes it not play that annoying beep sound when people die
function GM:PlayerDeathSound( )
	return true
end




//run every tick when a player is dead
function DeathSpectateTick()
	for k,v in pairs(player.GetAll()) do	
		if v.DeathSpectate == true then
			//print("death spectating for:", v)
			
			local function ClickToDifTarget(ply, plyteamtable)
				//print("attemping to switch targets")
				
				local prevply = ply.CurSpectateTarget
				ply.CurSpectateTarget = table.FindNext( plyteamtable, prevply )
				
				ply:Spectate( OBS_MODE_CHASE )
				ply:SpectateEntity( ply.CurSpectateTarget )
			end
			
			
			RedSpectateTargets = {}
			BlueSpectateTargets = {}
			table.Empty( RedSpectateTargets )
			table.Empty( BlueSpectateTargets )
			
			for i,living_ply in pairs(player.GetAll()) do	
				if living_ply:Team() == TEAM_BLUE and living_ply:GetObserverMode( ) == OBS_MODE_NONE then
					table.insert( BlueSpectateTargets, living_ply )
				end
			end
			
			for i,living_ply in pairs(player.GetAll()) do	
				if living_ply:Team() == TEAM_RED and living_ply:GetObserverMode( ) == OBS_MODE_NONE then
					table.insert( RedSpectateTargets, living_ply )
				end
			end
			
			local plyteamtable = {}
			
			if v:Team() == TEAM_BLUE then
				plyteamtable = BlueSpectateTargets
			elseif v:Team() == TEAM_RED then
				plyteamtable = RedSpectateTargets
			end
			
			//print(table.ToString(plyteamtable, "Test") )
			
			if not IsValid(v.CurSpectateTarget) then 
				local Count = table.Count( plyteamtable  )
				if Count == 0 then
					//print("count 0")
					v.DeathSpectate = false
					v:Spawn()
					v:Spectate( OBS_MODE_ROAMING )
					return
				end
				
				
				v.CurSpectateTarget = plyteamtable[ math.random( 1, Count ) ]

				v:Spectate( OBS_MODE_CHASE )
				v:SpectateEntity( v.CurSpectateTarget )
			end
			
		
			if( v:KeyPressed( IN_ATTACK ) ) then
				//Msg( "Switching specate targets" )
				ClickToDifTarget(v, plyteamtable)
			end
		
		end
	end
end
hook.Add("Tick", "DeathSpectateTick", DeathSpectateTick)




function DeathSpectate( ply )
	ply.DeathSpectate = true
end




function GM:PlayerDeath( ply )
	if ply:IsValidGamePlayer() == false then return end
	
	
	ply:ChatPrint("You died, wait till the round ends!")
	
	--Remove all the player's ability ents and buffs
	Reset_PlyAbilities( ply )
	Reset_PlyBuffs( ply )
	
	--unfreeze the player just in case their still frozen by tool_barrage or something
	ply:Freeze( false )
	
	if (ply:Team() == TEAM_RED) or (ply:Team() == TEAM_BLUE) then
		//if G_CurrentPhase == "DefendersBuy" or G_CurrentPhase == "AttackersBuy" or G_CurrentPhase == "Planning" then
			//Close_BuyingMenusForPly( ply )
			//ply:Freeze( false )
		//end
		
		DeathSpectate(ply)
	end

end


//makes it so players who die cannot respawn by clicking
function GM:PlayerDeathThink( ply )
	if (ply:Team() != TEAM_SPEC) then
		return false
	end
end



function DeathAnnounce( Victim, Inflictor, Attacker )

	-- Don't spawn for at least 2 seconds
	//Victim.NextSpawnTime = CurTime() + 2
	//Victim.DeathTime = CurTime()
	
	if ( !IsValid( Inflictor ) && IsValid( Attacker ) ) then
		Inflictor = Attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a 
	-- pistol but kill you by hitting you with their arm.
	if ( Inflictor && Inflictor == Attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = Attacker end
	
	end
	
	if (Attacker == Victim) then
	
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( Victim )
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( Attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( Victim )
			umsg.String( Inflictor:GetClass() )
			umsg.Entity( Attacker )
		
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. Inflictor:GetClass() .. "\n" )
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( Victim )
		umsg.String( Inflictor:GetClass() )
		umsg.String( Attacker:GetClass() )

	umsg.End()
	
	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )
	
end

hook.Add( "PlayerDeath", "DeathAnnounce", DeathAnnounce )

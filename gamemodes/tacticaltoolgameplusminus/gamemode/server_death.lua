/*---------------------------------------------------------
	Stuff that happens to players after they die before the next round
---------------------------------------------------------*/


//makes it not play that annoying beep sound when people die
function GM:PlayerDeathSound( )
	return true
end




//Move a dead player onto the next of their living teammates.
local function ClickToDifTarget( ply, plyteamtable )
	local prevply = ply.CurSpectateTarget
	ply.CurSpectateTarget = table.FindNext( plyteamtable, prevply )

	ply:Spectate( OBS_MODE_CHASE )
	ply:SpectateEntity( ply.CurSpectateTarget )
end


//Who each side can currently be watched through: alive, and on that team.
//
//Built once per tick rather than once per dead player. It was the latter, inside
//the loop below, which also left RedSpectateTargets and BlueSpectateTargets as
//accidental globals.
local function LivingTargetsByTeam()
	local red, blue = {}, {}

	for _, ply in pairs( player.GetAll() ) do
		if ply:GetObserverMode( ) == OBS_MODE_NONE then
			if ply:Team() == TEAM_RED then
				table.insert( red, ply )
			elseif ply:Team() == TEAM_BLUE then
				table.insert( blue, ply )
			end
		end
	end

	return red, blue
end


//run every tick when a player is dead
//
//You watch your own team and nobody else. That is the whole point of splitting
//the targets by team, and a second copy of this in ingame.lua used to undo it by
//cycling every player on the server regardless of side.
function DeathSpectateTick()
	local redtargets, bluetargets = LivingTargetsByTeam()

	for k,v in pairs(player.GetAll()) do
		if v.DeathSpectate == true then

			local plyteamtable = {}

			if v:Team() == TEAM_BLUE then
				plyteamtable = bluetargets
			elseif v:Team() == TEAM_RED then
				plyteamtable = redtargets
			end

			if not IsValid(v.CurSpectateTarget) then
				local Count = table.Count( plyteamtable  )
				if Count == 0 then
					//nobody left on your side to watch, so stop spectating
					//
					//continue, not return. This used to return, which abandoned
					//every other dead player for that tick - so with two people
					//dead on a wiped team, only the first was dealt with and the
					//rest sat on a black screen until somebody respawned.
					v.DeathSpectate = false
					v:Spawn()
					v:Spectate( OBS_MODE_ROAMING )
				continue
				end


				v.CurSpectateTarget = plyteamtable[ math.random( 1, Count ) ]

				v:Spectate( OBS_MODE_CHASE )
				v:SpectateEntity( v.CurSpectateTarget )
			end


			if( v:KeyPressed( IN_ATTACK ) ) then
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

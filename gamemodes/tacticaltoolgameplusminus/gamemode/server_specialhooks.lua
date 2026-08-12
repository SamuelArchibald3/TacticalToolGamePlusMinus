/*---------------------------------------------------------
	Hooks which various ents use as filters and such, and for special global attributes the game has
---------------------------------------------------------*/



--disallow noclip if we're not in devmode
function GM:PlayerNoClip( pl )
	if CAN_NOCLIP == true then
		return true
	else
		return false
	end
end



--theres no fall damage in the game right now
function GM:GetFallDamage( ply, speed )
	return 0
end


--you cannot suicide as a spectator
function GM:CanPlayerSuicide( ply )
	if ply:Team() == TEAM_SPEC then 
		return false
	elseif ply:Team() == TEAM_RED or ply:Team() == TEAM_BLUE then
		if ply:IsValidGamePlayer() then
			return true
		end
	end
	
	return false
end







--[[

--theres no physics damage for players in the game
function DisablePhysDamage( ent, dmginfo )
	print("someones taking damage")
	if dmginfo:IsDamageType( DMG_CRUSH ) and ent:IsPlayer() then
		dmginfo:ScaleDamage( 0 )
	end
end
hook.Add("EntityTakeDamage", "DisablePhysDamage", DisablePhysDamage)
]]--






function GM:PlayerShouldTakeDamage( victim, attacker )
	//print( attacker )
	//print( victim )

	
	--Disable team damage
	if attacker:IsPlayer() then
		//if attacker:Team() == victim:Team() and attacker != victim then
		if attacker:Team() == victim:Team() then
			//print("taking away TEAM DAMAGE")
			return false 
		end
	end
	
	return true
end






function SetEntityDamage( ent, dmginfo )

	--[[
	--Disable team damage
	local attacker = dmginfo:GetAttacker()
	print( "attacker:", attacker )
	print( "taking damage ent:", ent )
	if attacker:IsPlayer() and ent:IsPlayer() then
		//if attacker:Team() == victim:Team() and attacker != victim then
		if attacker:Team() == ent:Team() then
			print("taking away TEAM DAMAGE")
			dmginfo:ScaleDamage( 0 )
			return 
		end
	end
	]]--

	--trigger hurts dont deal damage during the defender's setup, they just teleport players back to their spawn
	if G_CurrentPhase == "Setup" then
		if dmginfo:GetInflictor():GetClass() == "trigger_hurt" and ent:IsPlayer() then
			dmginfo:ScaleDamage( 0 )
			return
		end
	end
	
	
	--Disable physics damage
	if dmginfo:IsDamageType( DMG_CRUSH ) and ent:IsPlayer() then
		//print("taking away physics damage from player")
		dmginfo:ScaleDamage( 0 )
		return
	end

	
	--Explosion damage type modifier
	if dmginfo:IsDamageType( DMG_BLAST ) then
		local explosion = dmginfo:GetInflictor()
		if not IsValid(explosion) then return end
		if explosion:GetClass() != "env_explosion" then return end
			
		if explosion.DamagePlyOnly == true and CheckIfInEntTable( ent ) then
			//print("taking away explosion damage from building")
			dmginfo:ScaleDamage( 0 )
		elseif explosion.DamageBuildingOnly == true and ent:IsPlayer() then
			//print("taking away explosion damage from player")
			dmginfo:ScaleDamage( 0 )
		end
	end
	
end
hook.Add("EntityTakeDamage", "SetEntityDamage", SetEntityDamage)













--this disables the ear ringing effect that would normally play
function GM:OnDamagedByExplosion( ply, dmginfo )
	//ply:SetDSP( 35, false )
end


--this disables body part damage scaling
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
 
 --[[
	// More damage when we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
 
		dmginfo:ScaleDamage( 2 )
 
	 end
 
	// Less damage when we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM or
		 hitgroup == HITGROUP_RIGHTARM or 
		 hitgroup == HITGROUP_LEFTLEG or
		 hitgroup == HITGROUP_RIGHTLEG or
		 hitgroup == HITGROUP_GEAR ) then
 
		dmginfo:ScaleDamage( 0.50 )
 
	 end
 ]]--
 
end

/*---------------------------------------------------------
	AddCSLuaFile
---------------------------------------------------------*/

//all client side files
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_teammenu.lua" )
AddCSLuaFile( "cl_buymenu.lua" )
AddCSLuaFile( "cl_timedisplay.lua" )
AddCSLuaFile( "cl_purchasesmenu.lua" )
AddCSLuaFile( "cl_inventory.lua" )
AddCSLuaFile( "cl_capturedisplay.lua" )
AddCSLuaFile( "cl_announcer.lua" )
AddCSLuaFile( "cl_hudscore.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_teammenu_specjoin.lua" )
AddCSLuaFile( "cl_turntobuy.lua" )
AddCSLuaFile( "cl_purchasesmenu_spec.lua" )
AddCSLuaFile( "cl_hud_headbars.lua" )
AddCSLuaFile( "cl_startscreenlogo.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_typecommands.lua" )
AddCSLuaFile( "cl_helpmenu.lua" )


//all shared files
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "ttg_player.lua" )
AddCSLuaFile( "table_tool.lua" )
AddCSLuaFile( "table_ent.lua" )
AddCSLuaFile( "table_shop.lua" )
AddCSLuaFile( "table_buff.lua" )
AddCSLuaFile( "meta_ent.lua" )
AddCSLuaFile( "meta_swep.lua" )
AddCSLuaFile( "shared_settings.lua" )

--metaplayer
AddCSLuaFile( 'metaplayer/metaplayer_abilities.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_aimtarget.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_currency.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_freeze.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_invis.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_invuln.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_limbo.lua' )
AddCSLuaFile( 'metaplayer/metaplayer_buffs.lua' )


-- weapon selector
include("weaponselector/config.lua")
if SERVER then
    AddCSLuaFile("weaponselector/config.lua")
    AddCSLuaFile("weaponselector/client/hooks.lua")
elseif CLIENT then
    include("weaponselector/client/hooks.lua")
end



/*---------------------------------------------------------
	Include
---------------------------------------------------------*/

//all shared files
include( 'shared.lua' )
include( 'ttg_player.lua' )
include( "table_tool.lua" )
include( "table_ent.lua" )
include( "table_shop.lua" )
include( "table_buff.lua" )
include( "meta_ent.lua" )
include( "meta_swep.lua" )
include( "shared_settings.lua" )
--metaplayer
include( 'metaplayer/metaplayer_abilities.lua' )
include( 'metaplayer/metaplayer_aimtarget.lua' )
include( 'metaplayer/metaplayer_currency.lua' )
include( 'metaplayer/metaplayer_freeze.lua' )
include( 'metaplayer/metaplayer_invis.lua' )
include( 'metaplayer/metaplayer_invuln.lua' )
include( 'metaplayer/metaplayer_limbo.lua' )
include( 'metaplayer/metaplayer_buffs.lua' )



//all server files
include( "gamesetup.lua" )
include( "ingame.lua" )
include( "timer.lua" )
include( "concommands.lua" )
include( "capturetimer.lua" )
include( "ingame_functions.lua" )
include( "server_spawning.lua" )
include( "server_death.lua" )
include( "server_abilitybinds.lua" )
include( "server_fkeypress.lua" )
include( "server_disconnect.lua" )
include( "server_specialhooks.lua" )
include( "server_typecommands.lua" )
include("lf_playermodel_selector.lua")


/*---------------------------------------------------------
	Custom Content Needed To Download
---------------------------------------------------------*/
--materials
resource.AddFile("materials/ttg_logo.vmt")
resource.AddFile("materials/ttg_logo.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/barrier01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/barrier01.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/boulder01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/boulder01.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/box.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/box.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/lasso01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/lasso01.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/point01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/point01.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/point02.vmt")

resource.AddFile("materials/tacticaltoolgame_mats/smokecube01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/smokecube01.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/sphere01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/sphere01.vtf")

resource.AddFile("materials/tacticaltoolgame_mats/spikepanel01.vmt")
resource.AddFile("materials/tacticaltoolgame_mats/spikepanel01.vtf")



--models
resource.AddFile("models/tacticaltoolgame_models/box01.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/box01.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/box01.mdl")
resource.AddFile("models/tacticaltoolgame_models/box01.phy")
resource.AddFile("models/tacticaltoolgame_models/box01.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/box01.vvd")

resource.AddFile("models/tacticaltoolgame_models/box01_big.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/box01_big.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/box01_big.mdl")
resource.AddFile("models/tacticaltoolgame_models/box01_big.phy")
resource.AddFile("models/tacticaltoolgame_models/box01_big.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/box01_big.vvd")

resource.AddFile("models/tacticaltoolgame_models/barrier01.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/barrier01.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/barrier01.mdl")
resource.AddFile("models/tacticaltoolgame_models/barrier01.phy")
resource.AddFile("models/tacticaltoolgame_models/barrier01.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/barrier01.vvd")

resource.AddFile("models/tacticaltoolgame_models/boulder01.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01.mdl")
resource.AddFile("models/tacticaltoolgame_models/boulder01.phy")
resource.AddFile("models/tacticaltoolgame_models/boulder01.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01.vvd")

resource.AddFile("models/tacticaltoolgame_models/boulder01_small.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01_small.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01_small.mdl")
resource.AddFile("models/tacticaltoolgame_models/boulder01_small.phy")
resource.AddFile("models/tacticaltoolgame_models/boulder01_small.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01_small.vvd")

resource.AddFile("models/tacticaltoolgame_models/boulder01_medium.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01_medium.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01_medium.mdl")
resource.AddFile("models/tacticaltoolgame_models/boulder01_medium.phy")
resource.AddFile("models/tacticaltoolgame_models/boulder01_medium.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/boulder01_medium.vvd")

resource.AddFile("models/tacticaltoolgame_models/spikepanel01.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/spikepanel01.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/spikepanel01.mdl")
resource.AddFile("models/tacticaltoolgame_models/spikepanel01.phy")
resource.AddFile("models/tacticaltoolgame_models/spikepanel01.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/spikepanel01.vvd")

resource.AddFile("models/tacticaltoolgame_models/smokecube01_bullcollide.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/smokecube01_bullcollide.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/smokecube01_bullcollide.mdl")
resource.AddFile("models/tacticaltoolgame_models/smokecube01_bullcollide.phy")
resource.AddFile("models/tacticaltoolgame_models/smokecube01_bullcollide.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/smokecube01_bullcollide.vvd")

resource.AddFile("models/tacticaltoolgame_models/cloakmodel.dx80.vtx")
resource.AddFile("models/tacticaltoolgame_models/cloakmodel.dx90.vtx")
resource.AddFile("models/tacticaltoolgame_models/cloakmodel.mdl")
resource.AddFile("models/tacticaltoolgame_models/cloakmodel.phy")
resource.AddFile("models/tacticaltoolgame_models/cloakmodel.sw.vtx")
resource.AddFile("models/tacticaltoolgame_models/cloakmodel.vvd")

//resource.AddFile("models/tacticaltoolgame/barrier01.dx80")
//resource.AddFile("models/tacticaltoolgame/barrier01.dx90")
//resource.AddFile("models/tacticaltoolgame/barrier01.mdl")
//resource.AddFile("models/tacticaltoolgame/barrier01.sw.vtx")
//resource.AddFile("models/tacticaltoolgame/barrier01.vvd")




--global vars which do not reset until the map is changed, unlike other globals which all reset at the end of a match

--this var keeps track of how many games of ttg have taken place without switching from the current map
--gets added to at the end of a match, when one team wins the whole thing
P_MatchNum = 0 

--this var is for activating the "wait for players" timer, if we just switched maps, gets set to false after the first GameRestart()
P_JustSwitchedMaps = true



--Starts the whole game up
GameRestart()



--[[
--theres no team damage for most stuff
function DisableTeamDamage( ent, dmginfo )
	if not ent:IsPlayer() then return end
	
	local attacker = dmginfo:GetAttacker( )
	if ent:Team() == attacker:Team() and ent != attacker then
		dmginfo:ScaleDamage( 0 )
	end
	
end
hook.Add("EntityTakeDamage", "DisableTeamDamage", DisableTeamDamage)
]]--




--[[
function GM:EntityTakeDamage( ent, dmginfo )
	print( "entity taking damage called", ent, dmginfo:GetDamageType( ) )
end
]]--


--[[

--this only does stuff related to the limbo mechanic which I decided to remove
function GM:EntityTakeDamage( ent, dmginfo )
	if LIMBO_ENABLED == false then return end
	
	
	if ent:IsPlayer() then
		
 
		-- if its fall damage, then just kill the player, cause thats what map triggers do
		if dmginfo:IsFallDamage() then return end
		
		--if the player has invuln, then dont do any of this
		if ent.HasInvuln then return end
		
		
		if ent.InLimbo == true then
			//print("taking damage while in limbo so....")
		
			--if hit by a crowbar...
			if dmginfo:GetInflictor( ):GetClass() == "default_melee" then
			
				--if the person who crowbarred you is a friend, wake you out of limbo, if not, kill you
				if dmginfo:GetAttacker( ):Team() != ent:Team() then
					ent:Limbo(false)
					//print("KILLER:" , dmginfo:GetAttacker( ))
					
					--play universal sound for everyone in the game, of the guy dying
					umsg.Start("Sound_LimboKill")
					umsg.End()
					
					dmginfo:SetDamageForce( dmginfo:GetAttacker( ):GetForward() * 5000000 )
					
					dmginfo:ScaleDamage( 200 )
					return
					
				else
					ent:SetHealth(25)
					ent:Limbo(false)
					return
				end
			end
			
			--if not a crowbar then scale damage to 0
			dmginfo:ScaleDamage( 0 )
			return
		end
		
		
		//print("player taking damage", dmginfo:GetBaseDamage())
		
		--if the player is going to die from this damage, make it so their health is changed to 1 instead, and put them in limbo
		if ((ent:Health() - dmginfo:GetBaseDamage()) <= 0) then
			//print("going to limbo")
		
			dmginfo:ScaleDamage( 0 )
			ent:SetHealth(2)
			
			ent:Limbo(true)
		end
 
	end
end

]]--




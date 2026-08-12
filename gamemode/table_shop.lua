/*---------------------------------------------------------
	Shop Base Tables
---------------------------------------------------------*/
//this is meant to be used by the buying menu mostly, for when you buy tool SWEPs


---------------------------------------------------------*/
//Items	- SWEP Tools that come with limited packs of ammo
---------------------------------------------------------*/
FIRSTSHOP_TABLE = 
{

purchase_barrier =
{
name = "purchase_barrier",
print_name = "Barrier",
class = "item",
tool_name = "tool_barrier",
pack_amount = 2,
description = "Deploys a stationary barrier which blocks enemy players and enemy props. \nCan be toggled between active and inactive states.\nCan be deployed horizontally onto walls.",
bind_primary = "Deploy barrier",
bind_alt = "Toggle all barriers (barriers become invisible when inactive)",
}
,



purchase_healdispenser =
{
name = "purchase_healdispenser",
print_name = "Heal Dispenser",
class = "item",
tool_name = "tool_healdispenser",
pack_amount = 1,
description = "Deploys a dispenser which heals allied players within its radius at a rate of 5 hp per second",
bind_primary = "Deploy heal dispense",
}
,


purchase_stepbox =
{
name = "purchase_stepbox",
print_name = "Box",
class = "item",
tool_name = "tool_stepbox",
pack_amount = 10,
description = "Deploys tanky player-sized solid boxes which can be used as structures to build on. \nBoxes snap-align to each other when they are placed together. \nCan be placed on walls, floors, and ceilings. \nAlt fire uses 5 ammo to create a big box",
bind_primary = "Deploy box",
bind_alt = "Deploy BIG box (uses 5 ammo)",
}
,


purchase_proximitybomb =
{
name = "purchase_proximitybomb",
print_name = "Proximity-Bomb",
class = "item",
tool_name = "tool_proximitybomb",
pack_amount = 2,
description = "Deploys small moveable prop bombs which explode when enemy players come within their radius. \nThe bombs take 2 seconds to become active upon deployment.",
bind_primary = "Deploy proximity bomb",
}
,


purchase_sentrydefender =
{
name = "purchase_sentrydefender",
print_name = "Sentry",
class = "item",
tool_name = "tool_sentrydefender",
pack_amount = 1,
description = "Deploys a stationary sentry gun that shoots at enemies that come within its 600 radius. \nCan only shoots at players it can see.",
bind_primary = "Deploy sentry",
}
,

purchase_stuntrap =
{
name = "purchase_stuntrap",
print_name = "Stun Trap",
class = "item",
tool_name = "tool_stuntrap",
pack_amount = 2,
description = "Deploys an invisible trap which automatically stuns enemy players who walk into it for 5 seconds. \nStunned units become invulnerable for the duration. \n( invulnerable units can still be executed )",
bind_primary = "Deploy stun trap",
}
,

purchase_revealer =
{
name = "purchase_revealer",
print_name = "Radar",
class = "item",
tool_name = "tool_revealer",
pack_amount = 99,
description = "Deploys a device that, while active, reveals all enemy players within its 1024 radius. \nThe enemy units become marked on your team's HUD as small X's \nDoes not reveal invisible units. \nGoes through walls",
bind_primary = "Deploy radar building",
}
,

purchase_airblastmachine =
{
name = "purchase_airblastmachine",
print_name = "Blast-Trap",
class = "item",
tool_name = "tool_airblastmachine",
pack_amount = 1,
description = "Deploys a trap which blasts back enemies who walk into its radius.\nBlasts things in the direction the player was aiming when he placed it. \nCan be manually triggered. \nAlso effects props.",
bind_primary = "Deploy push trap",
bind_alt = "Manually trigger push trap",
}
,



purchase_spikepanel =
{
name = "purchase_spikepanel",
print_name = "Spike Panel",
class = "item",
tool_name = "tool_spikepanel",
pack_amount = 2,
description = "Deploys a panel which executes enemy players who touches it. \n(Executions go through invulnerability and shield)",
bind_primary = "Deploy spike panel",
}
,

--[[
purchase_suicide =
{
name = "purchase_suicide",
print_name = "SelfExplosion",
class = "item",
tool_name = "tool_suicide",
pack_amount = 1,
description = "Desrcription Not Availible",
}
,
]]--


purchase_boulder =
{
name = "purchase_boulder",
print_name = "Boulder",
class = "item",
tool_name = "tool_boulder",
pack_amount = 1,
description = "Deploys a large boulder prop which deals 200 damage to enemy players who touch it. \n(The boulders killing damage is not an execution, it does not go through invulnerability or shield.)",
bind_primary = "Deploy boulder (deploys at the position it impacts)",
}
,


purchase_smokecube =
{
name = "purchase_smokecube",
print_name = "SmokeCube",
class = "item",
tool_name = "tool_smokecube",
pack_amount = 1,
description = "Deploys an invulnerable large opaque cube of smoke that's unsolid to all props and players.\nAlt fire permanantly dispels the cube.",
bind_primary = "Deploy smoke cube",
bind_alt = "Dispel the smoke cube you're aiming at",
}
,


purchase_decoy =
{
name = "purchase_decoy",
print_name = "DecoyBarrel",
class = "item",
tool_name = "tool_decoy",
pack_amount = 5,
description = "Deploys barrels which can be used as decoys for yourself. \nAlt fire disguises you as a barrel.",
bind_primary = "Deploy prop barrel",
bind_alt = "Disguise yourself as a barrel",
}
,

purchase_deflector =
{
name = "purchase_deflector",
print_name = "Deflector",
class = "item",
tool_name = "tool_deflector",
pack_amount = 2,
description = "Deploys a device which returns 20 damage to enemy players who damage it. \nMelee attacks on deflectors only return 5 damage.",
bind_primary = "Deploy deflector",
}
,


purchase_c4 =
{
name = "purchase_c4",
print_name = "C4",
class = "item",
tool_name = "tool_c4",
pack_amount = 1,
description = "Deploys a stationary device which explodes after 20 seconds, unless it's destroyed beforehand. \nThe explosion ONLY damages enemy buildings. \nDeals 350 damage in a 512 AOE.",
bind_primary = "Deploy C4",
}
,


purchase_mine =
{
name = "purchase_mine",
print_name = "InvisibleMine",
class = "item",
tool_name = "tool_mine",
pack_amount = 0,
description = "Deploys stationary invisible mines which can be manually triggered to explode. \nThere is a 1 second delay when triggering the explosion during which the mine is revealed. \nOnly hurts players.",
bind_primary = "Deploy mines",
bind_alt = "Detonate all deployed mines",
}
,

purchase_jumppadgun =
{
name = "purchase_jumppadgun",
print_name = "Jump-Pad",
class = "item",
tool_name = "tool_jumppad",
pack_amount = 1,
description = "Deploys a pad on the ground. \nIf any allied player or prop comes within the pad's area, they are sent flying into the air.",
bind_primary = "Deploy jump pad",
}
,


}


---------------------------------------------------------*/
//Guns - SWEP Tools that come with infinite ammo
---------------------------------------------------------*/
SECONDSHOP_TABLE = 
{

purchase_defaultmelee =
{
name = "purchase_defaultmelee",
print_name = "Default Melee",
class = "gun",
tool_name = "default_melee",
bind_primary = "Charge attack",
bind_alt = "Zap building (hurts enemy, heals allied)",
not_in_shop = true,
}
,

purchase_buildingbomb =
{
name = "purchase_buildingbomb",
print_name = "Building Bomb",
class = "gun",
tool_name = "tool_buildingbomb",
description = "Shoots projectiles that explode dealing AOE damage to buildings near the point of impact. \nONLY hurts buildings. \nBuying multiple upgrades clipsize and rate of fire.",
bind_primary = "Shoot bomb",
bind_r = "Reload",
}
,

purchase_missile =
{
name = "purchase_whistlemissile",
print_name = "Slow Pellet",
class = "gun",
tool_name = "tool_whistlemissile",
description = "Shoots slow moving missile projectiles which hurt the target they hit. \nHurts both buildings and players. \nOnly hurts players if it has travelled at least 128 units. \nBuying multiple upgrades clipsize",
bind_primary = "Shoot pellet",
bind_r = "Reload",
}
,

purchase_pucknade =
{
name = "purchase_pucknade",
print_name = "Nade",
class = "gun",
tool_name = "tool_pucknade",
description = "Shoots doughnut shaped pucks which slide across the ground. \nThe nades automatically explode after 2.5 seconds. \nAlt fire freezes all active nades mid air until they explode. \nONLY hurts players. \nBuying multiple upgrades clipsize",
bind_primary = "Shoot puck nade",
bind_alt = "Freeze all active puck nades",
bind_r = "Reload",
}
,

purchase_slowthrow =
{
name = "purchase_slowthrow",
print_name = "Crippler",
class = "gun",
tool_name = "tool_slowthrow",
description = "Shoots projectiles that slow enemy players within the AOE of the point of impact for a few seconds. \nBuying multiple upgrades slow duration",
bind_primary = "Shoot crippler bomb",
bind_r = "Reload",
}
,

purchase_barrage =
{
name = "purchase_barrage",
print_name = "Barrage",
class = "gun",
tool_name = "tool_barrage",
description = "Following a 2.5 second chargeup, repidly fires a large spread of bombs for 1 second. \nDuring the charge up, you become unable to move your view or body.  \nONLY hurts players. \nBuying multiple upgrades duration",
bind_primary = "Begin charge up",
bind_r = "Reload",
}
,


purchase_bomb =
{
name = "purchase_bomb",
print_name = "Height Bomb",
class = "gun",
tool_name = "tool_bomb",
description = "Rapidly shoots projectiles that deal AOE damage to players at the point of impact. \nThe damage dealt is amplified by how far the bomb falls. \nONLY hurts players. \nBuying multiple upgrades clipsize",
bind_primary = "Shoot bomb",
bind_r = "Reload",
}
,

purchase_repairstick =
{
name = "purchase_repairstick",
print_name = "Repair Stick",
class = "gun",
tool_name = "tool_repairstick",
description = "Repairs the buildings you whack for 15 hp per hit.\nBuying multiple upgrades rate of fire.",
bind_primary = "Repair nearby building",
}
,

-- purchase_smg =
-- {
-- name = "purchase_smg",
-- print_name = "SMG",
-- class = "gun",
-- tool_name = "tool_smg",
-- description = "Rapidfire machinegun which knocks back and very lightly damages enemies.",
-- bind_primary = "Shoot",
-- bind_r = "Reload",
-- }
-- ,

--[[
purchase_chargeshot =
{
name = "purchase_chargeshot",
print_name = "Charge Shot",
class = "gun",
tool_name = "tool_chargeshot",
description = "Desrcription Not Availible",
}
,
]]--


--[[
purchase_jumppadgun =
{
name = "purchase_jumppadgun",
print_name = "Jump-Pad",
class = "gun",
tool_name = "tool_jumppad",
description = "Deploys a pad on the ground, if any prop or player comes within the pad's area, they are sent flying into the air. \nOnly one jump pad can be active at a time.  \n( Whenever a new pad is deployed, the old pad is destroyed. )",
bind_primary = "Deploy jump pad",
bind_alt = "Remove deployed jump pad",
bind_r = "Reload",
}
,


purchase_bomb =
{
name = "purchase_bomb",
print_name = "Impact Bomb",
class = "gun",
tool_name = "tool_bomb",
description = "Shoots projectiles that explode dealing AOE damage at the point of impact.",
bind_primary = "Shoot bomb",
bind_r = "Reload",
}
,

purchase_shotgun =
{
name = "purchase_shotgun",
print_name = "Shotgun",
class = "gun",
tool_name = "tool_shotgun",
description = "Shoots a scattershot of shrapnel causing high damage to enemies at close range.",
bind_primary = "Shoot",
bind_r = "Reload",
}
,




purchase_chargeshot =
{
name = "purchase_chargeshot",
print_name = "Charge Shot",
class = "gun",
tool_name = "tool_chargeshot",
description = "Desrcription Not Availible",
}
,




purchase_sniper =
{
name = "purchase_sniper",
print_name = "ChargeRifle",
class = "gun",
tool_name = "tool_sniper",
description = "Desrcription Not Availible",
}
,


purchase_pucknade =
{
name = "purchase_pucknade",
print_name = "Puck Nade",
class = "gun",
tool_name = "tool_pucknade",
description = "Shoots doughnut shaped pucks which slide across the ground and explode if near an enemy player. \nThe nades automatically explode after 2.5 seconds.",
bind_primary = "Shoot puck nade",
bind_r = "Reload",
}
,






purchase_slowstick =
{
name = "purchase_slowstick",
print_name = "SlowStick",
class = "gun",
tool_name = "tool_slowstick",
description = "Desrcription Not Availible",
}
,



purchase_revolver =
{
name = "purchase_revolver",
print_name = "Revolver",
class = "gun",
tool_name = "tool_revolver",
description = "Shoots high damage, high accuracy bullets.",
bind_primary = "Shoot",
bind_r = "Reload",
}
,



purchase_missile =
{
name = "purchase_missile",
print_name = "Missile",
class = "gun",
tool_name = "tool_missile",
description = "Rapidly shoots slow moving missile projectiles which hurt the target they hit. \nThe missiles do NOT cause AOE damage at the point of impact.",
bind_primary = "Shoot missiles",
bind_r = "Reload",
}
,
]]--

}


---------------------------------------------------------*/
//Abilities
---------------------------------------------------------*/
THIRDSHOP_TABLE = 
{



purchase_dash =
{
name = "purchase_dash",
print_name = "Dash",
class = "ability",
tool_name = "tool_abil_dash",
description = "Triggers a burst of velocity which flings your body forward. \n15 second cooldown",
}
,

purchase_airblast =
{
name = "purchase_airblast",
print_name = "Airblast",
class = "ability",
tool_name = "tool_abil_airblast",
description = "Blasts back all players and props within a 128 radius infront of you. \n15 second cooldown. \nDoes not affect allied players.",
}
,

purchase_shield =
{
name = "purchase_shield",
print_name = "Shield",
class = "ability",
tool_name = "tool_abil_shield",
description = "Reduces damage by 85% for 5 seconds. \n30 second cooldown.",
}
,

purchase_lasso =
{
name = "purchase_lasso",
print_name = "Lasso",
class = "ability",
tool_name = "tool_abil_lasso",
description = "Shoot a device which attaches to players and pulls them back towards you \n10 second cooldown",
}
,

purchase_firstaid =
{
name = "purchase_firstaid",
print_name = "FirstAid",
class = "ability",
tool_name = "tool_abil_firstaid",
description = "Deploys a prop which heals the player who picks it up for 15 hp. \nYou can pick it up as well. \n25 second cooldown",
}
,

purchase_quickport =
{
name = "purchase_quickport",
print_name = "QuickPort",
class = "ability",
tool_name = "tool_abil_quickport",
description = "Deploys an invisible device which you can teleport to from anywhere. \nOnce the device has been placed, when you trigger the ability again you instantly are teleported to its location.\nThe device is removed upon being teleported to. \n50 second cooldown",
}
,


purchase_rateoffire =
{
name = "purchase_rateoffire",
print_name = "FireAmp",
class = "ability",
tool_name = "tool_abil_rateoffire",
description = "Amplifies the rate of fire on your currently held weapon by 50% for 3 seconds. \n30 second cooldown.",
}
,


purchase_dropslam =
{
name = "purchase_dropslam",
print_name = "DropSlam",
class = "ability",
tool_name = "tool_abil_dropslam",
description = "Primes up an ability which damages and slows nearby enemy players when you hit the ground.\nThe damage it deals is based on your fall speed.  \n15 second cooldown.",
}
,

purchase_suicide =
{
name = "purchase_suicide",
print_name = "Explosion",
class = "ability",
tool_name = "tool_abil_suicide",
description = "Explode yourself the old fashioned way - maybe )",
}
,

purchase_hunker =
{
name = "purchase_hunker",
print_name = "Hunker",
class = "ability",
tool_name = "tool_abil_hunker",
description = "Increase your gravity and greatly reduce knockback effects for 8 seconds. \n30 second cooldown.",
}
,


purchase_avia =
{
name = "purchase_avia",
print_name = "Avia",
class = "ability",
tool_name = "tool_abil_avia",
description = "Decreases your gravity for 8 seconds. \n30 second cooldown.",
}
,
purchase_ensnare =
{
name = "purchase_ensnare",
print_name = "Snare",
class = "ability",
tool_name = "tool_abil_ensnare",
description = "Freeze all nearby enemy players for 3 seconds. \nFrozen enemies can still aim and use tools. \n200 AOE radius \n30 second cooldown.",
}
,


purchase_wallgrab =
{
name = "purchase_wallgrab",
print_name = "WallGrab",
class = "ability",
tool_name = "tool_abil_wallgrab",
description = "Attach yourself to wall.\nTo unstick yourself from a wall press ability button again",
}
,


purchase_fastzap =
{
name = "purchase_fastzap",
print_name = "FastZap",
class = "ability",
tool_name = "tool_abil_fastzap",
description = "Amplifies the rate of fire of your melee weapon's Zap attack by 100% for 10 seconds. \n30 second cooldown.",
}
,

}



---------------------------------------------------------*/

	//Shop Table Functions

---------------------------------------------------------*/

function CheckIfInShopTables(str)
	for _, value in pairs(FIRSTSHOP_TABLE) do		///check if the ent is one of the the games's objects
		if value.name == str then
			return true
		end
	end
	
	for _, value in pairs(SECONDSHOP_TABLE) do		///check if the ent is one of the the games's objects
		if value.name == str then
			return true
		end
	end
	
	for _, value in pairs(THIRDSHOP_TABLE) do		///check if the ent is one of the the games's objects
		if value.name == str then
			return true
		end
	end
	return false
end


--you enter a tool name and it finds out what number shop that tool is in and returns it
function GetToolShopNum(toolname)
	local shopnum = 0
	
	for _, purchase in pairs(FIRSTSHOP_TABLE) do
		if purchase.tool_name == toolname then
			shopnum = 1
			return shopnum
		end
	end
	
	for _, purchase in pairs(SECONDSHOP_TABLE) do
		if purchase.tool_name == toolname then
			shopnum = 2
			return shopnum
		end
	end
	
	for _, purchase in pairs(THIRDSHOP_TABLE) do
		if purchase.tool_name == toolname then
			shopnum = 3
			return shopnum
		end
	end
	
	return shopnum
end



//returns the the number of the shop that the purchase is in
function GetShopNum(purchasename)
	local shopnum = 0
	for _, purchase in pairs(FIRSTSHOP_TABLE) do
		if purchase.name == purchasename then
			shopnum = 1
			return shopnum
		end
	end
	
	for _, purchase in pairs(SECONDSHOP_TABLE) do
		if purchase.name == purchasename then
			shopnum = 2
			return shopnum
		end
	end
	
	for _, purchase in pairs(THIRDSHOP_TABLE) do
		if purchase.name == purchasename then
			shopnum = 3
			return shopnum
		end
	end
	return shopnum
end


//returns the table with all the vars of the purchase, checks all shop tables for the input purchase
function Shop_Reference(purchasename)
	local ref = nil
	for _, purchase in pairs(FIRSTSHOP_TABLE) do
		if purchase.name == purchasename then
			ref = purchase
		end
	end
	
	for _, purchase in pairs(SECONDSHOP_TABLE) do
		if purchase.name == purchasename then
			ref = purchase
		end
	end
	
	for _, purchase in pairs(THIRDSHOP_TABLE) do
		if purchase.name == purchasename then
			ref = purchase
		end
	end
	return ref
end

//returns the table with all the vars of the purchase, checks all shop tables for the input purchase
function Shop_ToolReference( toolname )
	local ref = nil
	for _, purchase in pairs(FIRSTSHOP_TABLE) do
		if purchase.tool_name == toolname then
			ref = purchase
		end
	end
	
	for _, purchase in pairs(SECONDSHOP_TABLE) do
		if purchase.tool_name == toolname then
			ref = purchase
		end
	end
	
	for _, purchase in pairs(THIRDSHOP_TABLE) do
		if purchase.tool_name == toolname then
			ref = purchase
		end
	end
	return ref
end



//returns the name of the tool that the inputted purchase buys
function Shop_ConvertToName(printname, shoptable)	//converts in reverse from printname to name
	local name = nil
	for _, purchase in pairs(shoptable) do
		if purchase.print_name == printname then
			name = purchase.name
			return name
		end
	end
	return "invalid tool purchase name"
end

/*---------------------------------------------------------
	Tool stats base table
---------------------------------------------------------*/
//any buyable tool thats meant to be an usable in the game must be in this table, all base stats derive from it
//this is meant to be used by the buying menu mostly, for when you buy tool SWEPs
//Tool = SWEP


TOOL_TABLE = 
{


//****** alternate settings ********
//rate_of_fire = 1.6,
//duration_speed = .4,
//duration_slow = 1.14,
//duration_snare = .2,

default_melee =
{
name = "default_melee",
print_name = "Melee",
//class = "gun",	
rate_of_fire = 1.7,
duration_speed = .5,
duration_slow = 1.3,
duration_snare = .2,
force_phys = 400,
force_ply_ground = 2000,
force_ply_air = 200,
damage = 20,	--40
rate_of_fire_secondary = 1,
heal_amount_building = 5,
hurt_amount_building = 25,	--25
heal_sound = Sound("weapons/stunstick/stunstick_impact1.wav"),
//damage_low = 15,
//damage_high = 25,
hit_distance = 80,
hit_distance_secondary = 130,
v_model = "models/weapons/v_crowbar.mdl",
w_model = "models/weapons/w_crowbar.mdl",
sound_swing = Sound( "npc/scanner/scanner_nearmiss1.wav" ),
sound_preswing = Sound("npc/scanner/scanner_nearmiss2.wav"),
//sound_hit_flesh = Sound( "npc/vort/foot_hit.wav" ),
//sound_hit_flesh = Sound( "Metal_SeafloorCar.BulletImpact" ),
//sound_hit_flesh = Sound( "MetalGrate.BulletImpact" ),
//sound_hit_flesh = Sound( "npc/dog/dog_footstep_run1.wav" ),
sound_hit_flesh = Sound( "npc/antlion_guard/shove1.wav" ),
//sound_hit_wall = Sound( "physics/concrete/concrete_block_impact_hard" .. math.random(1, 3) .. ".wav" ),
sound_hit_wall = Sound( "physics/metal/metal_canister_impact_hard" .. math.random(1, 3) .. ".wav" ),
sound_hit_tool = Sound("Metal_Box.BulletImpact"),
}
,




tool_barrier =
{
name = "tool_barrier",
print_name = "Barrier",
class = "item",
thrown_ent = "ent_barrier",
throw_force = 170000,
rate_of_fire = 1,
clip_size = -1,	---not used yet, may be if i add in reload system
automatic = false,
infinite = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
toggle_sound = Sound("ambient/machines/thumper_startup1.wav"),
sets_ent_team = true,
}
,

tool_stepbox =
{
name = "tool_stepbox",
print_name = "Box",
class = "item",
thrown_ent = "ent_stepbox",
thrown_ent_big = "ent_stepbox_big",
throw_force = 170000,
rate_of_fire = 1,
clip_size = -1,	---not used yet, may be if i add in reload system
automatic = true,
infinite = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_shotgun =
{
name = "tool_shotgun",
print_name = "Shotgun",
class = "gun",
rate_of_fire = .6,
clip_size = 4,	
reload_time = 5,	
anim_time = .28,	
holdtype = "shotgun",	
bullets_per_shot = 10,
bullet_damage = 5,
aim_cone = .16,
automatic = true,
infinite = true,
force_physics_blast = 250,
force_player_blast = 0,
v_model = "models/weapons/v_shotgun.mdl",
w_model = "models/weapons/w_shotgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Shotgun.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,


tool_speed =
{
name = "tool_speed",
print_name = "Speed Capsule",
class = "item",
thrown_ent = "ent_speed",
throw_force = 170000,
rate_of_fire = 1,
owner_give_buff = "speed",
clip_size = -1,	---not used yet, may be if i add in reload system
automatic = false,
infinite = false,
v_model = "models/weapons/v_crossbow.mdl",
w_model = "models/weapons/w_crossbow.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

--[[
tool_jumppad =
{
name = "tool_jumppad",
print_name = "Jump-Pad",
class = "gun",
thrown_ent = "ent_jumppad",
throw_force = 170000,
rate_of_fire = 1,
clip_size = 1,
reload_time = 5,	
anim_time = .28,	
automatic = false,
infinite = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,
]]--

--now an item
tool_jumppad =
{
name = "tool_jumppad",
print_name = "Jump-Pad",
class = "item",
thrown_ent = "ent_jumppad",
throw_force = 170000,
rate_of_fire = 1,
automatic = false,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,


--[[
tool_airblast =
{
name = "tool_airblast",
print_name = "Airblast Gun",
rate_of_fire = 1,
clip_size = 1,	
reload_time = 3,	
anim_time = .28,	
automatic = false,
infinite = true,
force_physics_blast = 2000,
force_player_blast = 700,
radius = 128,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,
]]--



tool_healdispenser =
{
name = "tool_healdispenser",
print_name = "Heal Dispenser",
class = "item",
thrown_ent = "ent_healdispenser",
throw_force = 170000,
rate_of_fire = 1,
automatic = false,
infinite = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
sets_ent_team = true,
}
,


tool_repairgun =
{
name = "tool_repairgun",
print_name = "Repair Gun",
class = "gun",
rate_of_fire = .1,
clip_size = 50,	
reload_time = 5,	
anim_time = .28,
automatic = true,
infinite = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
heal_amount = 1,
//heal_amount_aoe = 30,

}
,

tool_proximitybomb =
{
name = "tool_proximitybomb",
print_name = "Proximity-Bomb",
class = "item",
thrown_ent = "ent_proximitybomb",
throw_force = 50000,
rate_of_fire = 1,
automatic = true,
infinite = false,
sets_ent_team = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Pistol.Single"),
}
,


tool_inviscapsule =
{
name = "tool_inviscapsule",
print_name = "Invisibility Capsule",
class = "item",
thrown_ent = "ent_inviscapsule",
throw_force = 170000,
rate_of_fire = 1,
owner_give_buff = "invis",
clip_size = -1,	---not used yet, may be if i add in reload system
automatic = false,
infinite = false,
v_model = "models/weapons/v_crossbow.mdl",
w_model = "models/weapons/w_crossbow.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,


tool_revealer =
{
name = "tool_revealer",
print_name = "Radar",
class = "item",
thrown_ent = "ent_revealer",
throw_force = 170000,
rate_of_fire = 1,
clip_size = -1,	---not used yet, may be if i add in reload system
automatic = false,
infinite = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
sets_ent_team = true,
}
,


tool_abil_dash =
{
name = "tool_abil_dash",
print_name = "Dash",
class = "ability",
cooldown = 15,
force = 400,
shoot_sound = Sound("npc/zombie/claw_miss1.wav"),
}
,

tool_abil_airblast =
{
name = "tool_abil_airblast",
print_name = "Airblast",
class = "ability",
cooldown = 15,
force_physics_blast = 1200,	--1500
force_physics_blast_vert = 0, --500
force_player_blast = 550,		--600
force_player_blast_vert = 325, --300
radius = 128,
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_abil_shield =
{
name = "tool_abil_shield",
print_name = "Shield",
class = "ability",
cooldown = 30,
duration = 5,
sound_a = Sound( "weapons/buffed_on.wav" ),
sound_b = Sound( "weapons/buffed_off.wav" ),
}
,

tool_smg =
{
name = "tool_smg",
print_name = "SMG",
class = "gun",
rate_of_fire = 1.5,
clip_size = 4,	
reload_time = 5,	
anim_time = .28,
bullet_damage = 1,
aim_cone = .02,
bullets_per_shot = 5,
rate_of_fire_1shot = .07,
automatic = true,
force_physics_blast = 170,
force_player_blast = 600,
v_model = "models/weapons/v_smg1.mdl",
w_model = "models/weapons/w_smg1.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("weapons/smg1/smg1_fire1.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_healgun =
{
name = "tool_healgun",
print_name = "Heal Gun",
class = "gun",
rate_of_fire = .5,
clip_size = 30,	
reload_time = 5,	
anim_time = .28,
automatic = true,
infinite = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
heal_amount = 1,
distance = 256,
}
,


tool_sentrydefender =
{
name = "tool_sentrydefender",
print_name = "Sentry",
class = "item",
thrown_ent = "ent_sentrydefender",
throw_force = 170000,
rate_of_fire = 1,
automatic = false,
infinite = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
sets_ent_team = true,
}
,

tool_chargeshot =
{
name = "tool_chargeshot",
print_name = "Charge Shot",
class = "gun",
player_damage = 100,
building_damage = 40,
rate_of_fire = 1,
clip_size = 1,	
reload_time = 5,	
charge_time = 2,
anim_time = .28,
automatic = true,
infinite = true,
v_model = "models/weapons/v_smg1.mdl",
w_model = "models/weapons/w_smg1.mdl",
color_skin = Color(255,255,255,255),
charge_sound = Sound("npc/strider/charging.wav"),
shoot_sound = Sound("npc/strider/fire.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_stuntrap =
{
name = "tool_stuntrap",
print_name = "Stun Trap",
class = "item",
thrown_ent = "ent_stuntrap",
throw_force = 170000,
rate_of_fire = 1,
automatic = true,
infinite = false,
sets_ent_team = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Pistol.Single"),
}
,

tool_airblastmachine =
{
name = "tool_airblastmachine",
print_name = "Blast-Trap",
class = "item",
thrown_ent = "ent_airblastmachine",
throw_force = 170000,
rate_of_fire = 1,
clip_size = -1,
automatic = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
sets_ent_team = true,
}
,


tool_firstaid =
{
name = "tool_firstaid",
print_name = "First Aid",
class = "item",
thrown_ent = "ent_firstaid",
throw_force = 100000,
rate_of_fire = 1,
automatic = true,
//sets_ent_team = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Pistol.Single"),
}
,

tool_spikepanel =
{
name = "tool_spikepanel",
print_name = "Spike Panel",
class = "item",
thrown_ent = "ent_spikepanel",
throw_force = 170000,
rate_of_fire = 1,
automatic = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_quickport =
{
name = "tool_quickport",
print_name = "QuickPort",
class = "gun",
thrown_ent = "ent_quickport",
throw_force = 170000,
rate_of_fire = 1,
clip_size = 1,
reload_time = 4,	
anim_time = .28,	
automatic = true,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
sound_teleport = "npc/scanner/cbot_energyexplosion1.wav",
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_sniper =
{
name = "tool_sniper",
print_name = "ChargeRifle",
class = "gun",
rate_of_fire = 1,
clip_size = 1,	
reload_time = 4,	
anim_time = .28,
player_damage_scale = 1,
building_damage_scale = 1,
automatic = true,
force_physics_blast = 250,
force_player_blast = 1000,
v_model = "models/weapons/v_irifle.mdl",
w_model = "models/weapons/w_irifle.mdl",
color_skin = Color(255,255,255,255),
sound_charge = "ambient/machines/engine4.wav",
sound_alert = Sound("npc/attack_helicopter/aheli_damaged_alarm1.wav"),
shoot_sound = Sound("npc/strider/fire.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_pucknade =
{
name = "tool_pucknade",
print_name = "Nade",
class = "gun",
holdtype = "grenade",
uses_grenade_model = true,
thrown_ent = "ent_pucknade",
throw_force = 110000,
rate_of_fire = .3,
clip_size = 3,	
reload_time = 5,	
anim_time = .28,	
automatic = true,
infinite = true,
v_model = "models/weapons/v_grenade.mdl",
w_model = "models/weapons/w_grenade.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("npc/zombie/claw_miss1.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
upgrades_clipsize = true,
//upgrades_rateoffire = true,
}
,

tool_suicide =
{
name = "tool_suicide",
print_name = "SelfExplosion",
class = "item",
rate_of_fire = 1,
charge_time = 1.5,
imagnitude = "250",
iradiusoverride = "300",
automatic = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
sound_charge = Sound("npc/combine_gunship/see_enemy.wav"),
sound_explode = Sound("ambient/explosions/explode_7.wav"),
}
,

tool_repairstick =
{
name = "tool_repairstick",
print_name = "Repair Stick",
class = "gun",
rate_of_fire = 1.5,
automatic = true,
heal_amount_player = 3,
heal_amount_building = 15,
v_model = "models/weapons/v_stunbaton.mdl",
w_model = "models/weapons/w_stunbaton.mdl",
heal_sound = Sound("weapons/physcannon/energy_bounce1.wav"),
upgrades_hp = true,
}
,

tool_lasso =
{
name = "tool_lasso",
print_name = "Lasso",
class = "gun",
thrown_ent = "ent_lasso",
throw_force = 170000,
rate_of_fire = 1,
clip_size = 1,	
reload_time = 5,	
anim_time = .28,	
automatic = true,
v_model = "models/weapons/v_pistol.mdl",
w_model = "models/weapons/w_pistol.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Pistol.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_slowstick =
{
name = "tool_slowstick",
print_name = "SlowStick",
class = "gun",
rate_of_fire = 1,
automatic = true,
slow_amount = 90,
slow_duration = 5,
v_model = "models/weapons/v_stunbaton.mdl",
w_model = "models/weapons/w_stunbaton.mdl",
slow_sound = Sound("ambient/energy/whiteflash.wav"),
}
,

tool_boulder =
{
name = "tool_boulder",
print_name = "Boulder",
class = "item",
thrown_ent = "ent_boulder",
throw_force = 170000,
rate_of_fire = 1,
rate_of_fire_secondary = .2,
automatic = false,
force_phys = 125,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_smokecube =
{
name = "tool_smokecube",
print_name = "SmokeCube",
class = "item",
thrown_ent = "ent_smokecube",
throw_force = 170000,
rate_of_fire = 1,
automatic = false,
infinite = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_abil_lasso =
{
name = "tool_abil_lasso",
print_name = "Lasso",
class = "ability",
cooldown = 10,
thrown_ent = "ent_lasso",
throw_force = 190000,
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_abil_firstaid =
{
name = "tool_abil_firstaid",
print_name = "First Aid",
class = "ability",
cooldown = 25,
thrown_ent = "ent_firstaid",
throw_force = 100000,
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_abil_quickport =
{
name = "tool_abil_quickport",
print_name = "QuickPort",
class = "ability",
cooldown = 50,
thrown_ent = "ent_quickport",
throw_force = 170000,
sound_shoot = Sound("Weapon_Mortar.Single"),
sound_teleport = Sound("npc/scanner/cbot_energyexplosion1.wav"),
}
,


tool_decoy =
{
name = "tool_decoy",
print_name = "DecoyBarrel",
class = "item",
thrown_ent = "ent_decoy",
throw_force = 170000,
rate_of_fire = 1,
automatic = true,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
decoy_model = "models/props_c17/oildrum001.mdl",
time_to_hunker = 5,
}
,

tool_abil_cloak =
{
name = "tool_abil_cloak",
print_name = "Cloak",
class = "ability",
cooldown = 30,
duration = 3,
decoy_model = "models/tacticaltoolgame_models/cloakmodel.mdl",
}
,

tool_deflector =
{
name = "tool_deflector",
print_name = "Deflector",
class = "item",
thrown_ent = "ent_deflector",
throw_force = 170000,
rate_of_fire = 1,
automatic = true,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,



tool_abil_rateoffire =
{
name = "tool_abil_rateoffire",
print_name = "FireAmp",
class = "ability",
cooldown = 30,
duration = 3,
amp_amount = .5,
}
,

tool_abil_dropslam =
{
name = "tool_abil_dropslam",
print_name = "DropSlam",
class = "ability",
cooldown = 20,
damage = .07,	--.09
radius = 192,
slow_duration = 3,
sound_explosion = Sound("ambient/explosions/explode_1.wav"),
}
,

tool_c4 =
{
name = "tool_c4",
print_name = "C4",
class = "item",
thrown_ent = "ent_c4",
throw_force = 170000,
rate_of_fire = 1,
automatic = false,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,

tool_abil_suicide =
{
name = "tool_abil_suicide",
print_name = "Explosion",
class = "ability",
cooldown = 60,
charge_time = 1.5,
imagnitude = "250",
iradiusoverride = "300",
sound_charge = Sound("npc/combine_gunship/see_enemy.wav"),
sound_explode = Sound("ambient/explosions/explode_7.wav"),
sound_cancel = Sound("coast.combine_apc_shutdown"),
}
,

tool_abil_hunker =
{
name = "tool_abil_hunker",
print_name = "Hunker",
class = "ability",
cooldown = 0,			--no cooldown on hunker. Toggling it is the whole ability
toggle_cooldown = 1,	--seconds you must wait between toggles, so it cannot be spammed
gravity = 2,
duration = 8,
sound_on = Sound( "weapons/buffed_on.wav" ),	--CHANGE THIS TO SOMETHING NOT FROM TF2
sound_off = Sound( "weapons/buffed_off.wav" ),
}
,

tool_abil_avia =
{
name = "tool_abil_avia",
print_name = "Avia",
class = "ability",
cooldown = 30,
gravity = 0.3,
duration = 8,
sound_on = Sound( "weapons/buffed_on.wav" ),	--CHANGE THIS TO SOMETHING NOT FROM TF2
sound_off = Sound( "weapons/buffed_off.wav" ),
}
,

tool_abil_ensnare =
{
name = "tool_abil_ensnare",
print_name = "Snare",
class = "ability",
radius = 200,
cooldown = 30,
duration = 3,
sound_ensnare = Sound("ambient/energy/weld2.wav"),
}
,

tool_revolver =
{
name = "tool_revolver",
print_name = "Revolver",
class = "gun",
rate_of_fire = 1,
clip_size = 5,	
reload_time = 5,	
anim_time = .28,	
bullet_damage = 15,
aim_cone = .01,
automatic = true,
v_model = "models/weapons/v_357.mdl",
w_model = "models/weapons/w_357.mdl",
shoot_sound = Sound("weapons/357/357_fire2.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

--[[
tool_missile =
{
name = "tool_missile",
print_name = "Missile",
class = "gun",
thrown_ent = "ent_missile",
throw_force = 400000,
rate_of_fire = 2,
clip_size = 4,		
reload_time = 5,
anim_time = .28,	
automatic = true,
v_model = "models/weapons/v_crossbow.mdl",
w_model = "models/weapons/w_crossbow.mdl",
shoot_sound = Sound("weapons/ar2/npc_ar2_altfire.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,
]]--

tool_mine =
{
name = "tool_mine",
print_name = "InvisibleMine",
class = "item",
thrown_ent = "ent_mine",
throw_force = 170000,
rate_of_fire = 1,
automatic = true,
v_model = "models/weapons/c_toolgun.mdl",
w_model = "models/weapons/w_toolgun.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Weapon_Mortar.Single"),
}
,



tool_whistlemissile =
{
name = "tool_whistlemissile",
print_name = "Slow Pellet",
class = "gun",
thrown_ent = "ent_whistlemissile",
throw_force = 60000,
rate_of_fire = .7,
clip_size = 5,		
reload_time = 5,
anim_time = .28,	
automatic = true,
v_model = "models/weapons/v_crossbow.mdl",
w_model = "models/weapons/w_crossbow.mdl",
shoot_sound = Sound("weapons/ar2/npc_ar2_altfire.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
upgrades_clipsize = true,
clipsize_add_amount = 2,
}
,


tool_buildingbomb =
{
name = "tool_buildingbomb",
print_name = "Building Bomb",
class = "gun",
holdtype = "grenade",
uses_grenade_model = true,
thrown_ent = "ent_buildingbomb",
throw_force = 170000,
rate_of_fire = 1,
clip_size = 6,	
reload_time = 5,	
anim_time = .28,	
automatic = true,
infinite = true,
v_model = "models/weapons/v_grenade.mdl",
w_model = "models/weapons/w_grenade.mdl",
color_skin = Color(255,255,255,255),
//shoot_sound = Sound("Weapon_Pistol.Single"),
shoot_sound = Sound("npc/zombie/claw_miss1.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
upgrades_clipsize = true,
upgrades_rateoffire = true,
}
,

tool_slowthrow =
{
name = "tool_slowthrow",
print_name = "Crippler",
class = "gun",
holdtype = "grenade",
uses_grenade_model = true,
thrown_ent = "ent_slowthrow",
throw_force = 140000,
rate_of_fire = 1,
clip_size = 1,	
reload_time = 8,	
anim_time = .28,	
automatic = true,
infinite = true,
v_model = "models/weapons/v_grenade.mdl",
w_model = "models/weapons/w_grenade.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("npc/zombie/claw_miss1.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_abil_wallgrab =
{
name = "tool_abil_wallgrab",
print_name = "WallGrab",
class = "ability",
cooldown = 5,
force_jump = 400,
sound_grab = Sound("ambient/energy/weld2.wav"),
}
,

tool_barrage =
{
name = "tool_barrage",
print_name = "Barrage",
class = "gun",
thrown_ent = "ent_bomb_barrage",
throw_force = 140000,
rate_of_fire = 1,
clip_size = 1,	
reload_time = 5,	
time_charge = 2.5,
time_barrage_level1 = 1,
time_barrage_level2 = 2.5,
time_barrage_level3 = 400,
barrage_rate = .1,
anim_time = .28,
automatic = false,
v_model = "models/weapons/v_smg1.mdl",
w_model = "models/weapons/w_smg1.mdl",
color_skin = Color(255,255,255,255),
charge_sound = Sound("npc/strider/charging.wav"),
shoot_sound = Sound("npc/strider/strider_minigun.wav"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
}
,

tool_bomb =
{
name = "tool_bomb",
print_name = "Height Bomb",
class = "gun",
holdtype = "shotgun",
thrown_ent = "ent_bomb",
throw_force = 170000,
rate_of_fire = .5,
clip_size = 6,	
reload_time = 5,	
anim_time = .28,	
automatic = true,
v_model = "models/weapons/v_irifle.mdl",
w_model = "models/weapons/w_irifle.mdl",
color_skin = Color(255,255,255,255),
shoot_sound = Sound("Popcan.BulletImpact"),
//shoot_sound = Sound("Weapon_AR2.Single"),
reload_sound = Sound("weapons/smg_worldreload.wav")	,
upgrades_clipsize = true,
}
,

tool_abil_fastzap =
{
name = "tool_abil_fastzap",
print_name = "FastZap",
class = "ability",
cooldown = 30,
duration = 8,
}
,

}


function ToolReference(toolstring)		//returns the tool from the main table of stats for easy reference
	local ref = nil
	for _, tool in pairs(TOOL_TABLE) do
		if tool.name == toolstring then
			ref = tool
		end
	end
	return ref
end


function CheckIfInToolTable(str)
	for _, value in pairs(TOOL_TABLE) do		///check if the ent is one of the the games's objects
		if value.name == str then
			return true
		end
	end
	return false
end


function ConvertToPrintName(toolname)	//returns the print name of the input tool name
	local printname = nil
	for _, tool in pairs(TOOL_TABLE) do
		if tool.name == toolname then
			printname = tool.print_name
			return printname
		end
	end
	return "invalid tool name"
end

function ConvertToName(toolprintname)	//converts in reverse from printname to name
	local name = nil
	for _, tool in pairs(TOOL_TABLE) do
		if tool.print_name == toolprintname then
			name = tool.name
			return name
		end
	end
	return "invalid tool print name"
end


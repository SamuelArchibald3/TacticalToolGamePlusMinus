/*---------------------------------------------------------
	Ent base table
---------------------------------------------------------*/
//any ent that tools create is in this list
//used to clean up everything at the end of a round, like the buildable barriers and such.
//Ent = entity a tool created


ENT_TABLE = 
{



ent_barrier =
{
name = "ent_barrier",
print_name = "Barrier",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/tacticaltoolgame_models/barrier01.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_c = "vehicles/digger_grinder_stop1.wav",
sound_toggle = "ambient/machines/thumper_startup1.wav",
sound_build = "ambient/machines/engine4.wav",
sound_pass = "physics/wood/wood_box_impact_bullet4.wav",
takes_damage = true,
health_building = 75,
health = 250,
build_time = 5,
build_radius = 90,
toggle_time = .2,
time_disable_collision = .1,
special_mat = "models/debug/debugwhite",
}
,


ent_stepbox =
{
name = "ent_stepbox",
print_name = "Box",
model = "models/items/grenadeammo.mdl",
built_model = "models/tacticaltoolgame_models/box01.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_c = "vehicles/digger_grinder_stop1.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
health = 300,
build_time = .5,
build_radius = 64,
}
,

ent_stepbox_big =
{
name = "ent_stepbox_big",
print_name = "Box",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/tacticaltoolgame_models/box01_big.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_c = "vehicles/digger_grinder_stop1.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
health = 550,
build_time = 3,
build_radius = 256,
}
,

--[[

ent_speed =
{
name = "ent_speed",
print_name = "Speed Capsule",
model = "models/items/tf_gift.mdl",
built_model = "models/items/tf_gift.mdl",
sound_a = "weapons/jar_explode.wav",
takes_damage = false,
}
,
]]--


ent_jumppad =
{
name = "ent_jumppad",
print_name = "Jump-Pad",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_wasteland/wheel01.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
health = 100,
radius = 32,
build_time = 6,
}
,

ent_healdispenser =
{
name = "ent_healdispenser",
print_name = "Heal Dispenser",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_c17/canister_propane01a.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
health = 250,
build_time = 10,
build_radius = 40,
radius = 80,
heal_amount = 1,
heal_rate = .2,		--every x seconds heal
}
,

ent_proximitybomb =
{
name = "ent_proximitybomb",
print_name = "Proximity Bomb Item",
model = "models/props_c17/consolebox03a.mdl",
special_mat = "models/props_c17/frostedglass_01a",
imagnitude = "70",
iradiusoverride = "200",
sound_explode = "npc/vort/attack_shoot.wav",
takes_damage = false,
collides_with_barriers = true,
affected_by_lasso = true,
//health = 10,
radius = 80,
delay = 2,
}
,

--[[
ent_inviscapsule =
{
name = "ent_inviscapsule",
print_name = "Invisiblity Capsule",
model = "models/items/tf_gift.mdl",
built_model = "models/items/tf_gift.mdl",
sound_a = "weapons/jar_explode.wav",
takes_damage = false,
}
,
]]--

ent_revealer =
{
name = "ent_revealer",
print_name = "Radar",
model = "models/items/grenadeammo.mdl",
built_model = "models/combine_helicopter/helicopter_bomb01.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_beep = "hl1/fvox/beep.wav",
takes_damage = true,
health = 100,
build_time = 1,
radius = 900,
beep_delay = 2,
}
,

ent_sentrydefender =
{
name = "ent_sentrydefender",
print_name = "Sentry",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_c17/furnitureboiler001a.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/crane/crane_magnet_release.wav",
sound_c = "npc/stalker/go_alert2a.wav",
sound_d = "weapons/smg1/smg1_fire1.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
health = 125,
build_time = 24,
build_radius = 64,
radius = 600,
bullet_damage = 1,	--3
aim_cone = .02,
charge_time = .3,	//.2
aim_height = .7,	--where up the target to aim, as a fraction of their height. .5 is the waist, .7 is about the chest
sight_grace = .4,	--how long it keeps a target it cannot currently see, before giving up and searching again
}
,

ent_stuntrap =
{
name = "ent_stuntrap",
print_name = "Stun Trap",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_wasteland/chimneypipe02a.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/crane/crane_magnet_release.wav",
sound_c = "npc/roller/mine/rmine_explode_shock1.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
health = 60,
build_time = 5,
reveal_time = 1,
radius = 64,
stun_duration = 4,
think_rate = .1,
}
,

ent_airblastmachine =
{
name = "ent_airblastmachine",
print_name = "Blast-Trap",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/tacticaltoolgame_models/boulder01_small.mdl",
skin = 1,
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/crane/crane_magnet_release.wav",
sound_c = "Weapon_Mortar.Single",
takes_damage = true,
build_time = 8,
health = 125,
radius_effect = 192,
radius_activation = 96,
cooldown = 4,
snare_duration = 1.2,
force_physics_blast = 2000,
force_player_blast = 1000,
think_rate = .05,
}
,

ent_firstaid =
{
name = "ent_firstaid",
print_name = "First Aid",
model = "models/items/healthkit.mdl",
sound_heal = "items/smallmedkit1.wav",
heal_amount = 20,
takes_damage = false,
affected_by_lasso = true,
radius = 32,
}
,

ent_spikepanel =
{
name = "ent_spikepanel",
print_name = "Spike Panel",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
//built_model = "models/props_wasteland/prison_heavydoor001a.mdl",
//built_model = "models/props_junk/trashdumpster02b.mdl",
built_model = "models/tacticaltoolgame_models/spikepanel01.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_c = "vehicles/digger_grinder_stop1.wav",
sound_kill = "weapons/physcannon/energy_disintegrate4.wav",
sound_build = "ambient/machines/engine4.wav",
takes_damage = true,
//health_prebuild = 100,
health = 100,
build_time = 5,
build_radius = 64,
}
,

ent_quickport =
{
name = "ent_quickport",
print_name = "QPort",
//model = "models/props_junk/plasticbucket001a.mdl",
model = "models/tacticaltoolgame_models/boulder01_small.mdl",
built_model = "models/props_junk/trafficcone001a.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_build = "ambient/machines/engine4.wav",
sound_build_finish = "vehicles/digger_grinder_stop1.wav",
takes_damage = true,
health = 40,
radius = 32,
radius_die = 64,
build_time = 5,
}
,



ent_lasso =
{
name = "ent_lasso",
print_name = "Lasso",
model = "models/tacticaltoolgame_models/boulder01_small.mdl",
skin = 1,
takes_damage = false,
radius = 100,
force_physics_blast = 500,
force_player_blast = 700,
sit_time = .2,
think_rate = .1,
}
,

ent_boulder =
{
name = "ent_boulder",
print_name = "Boulder",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/tacticaltoolgame_models/boulder01.mdl",
sound_hit = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_builddone = "vehicles/crane/crane_magnet_release.wav",
sound_build = "ambient/machines/engine4.wav",
sound_kill = "weapons/physcannon/energy_disintegrate4.wav",
damage = 200,
takes_damage = true,
collides_with_barriers = true,
affected_by_lasso = true,
health = 50,
build_time = 5,
build_radius = 80,
time_break_control = 1,
}
,

ent_smokecube =
{
name = "ent_smokecube",
print_name = "Smoke Cube",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/tacticaltoolgame_models/smokecube01_bullcollide.mdl",
//built_model = "models/tacticaltoolgame_models/smokecube01_nocollision.mdl",
sound_hit = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_builddone = "vehicles/crane/crane_magnet_release.wav",
sound_build = "ambient/machines/engine4.wav",
sound_dispel = "npc/combine_gunship/attack_stop2.wav",
sound_kill = "weapons/physcannon/energy_disintegrate4.wav",
takes_damage = true,
//damage_color_override = true,
health = 50,
build_time = .5,
build_radius = 80,
}
,

ent_decoy =
{
name = "ent_decoy",
print_name = "DecoyBarrel",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_c17/oildrum001.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_build = "ambient/machines/engine4.wav",
sound_damage = "ambient/energy/zap1.wav",
takes_damage = true,
damage_color_override = true,
do_not_flash = true,
health = 300,
build_time = 2,
build_radius = 40,
damage_return_melee = 15,
}
,

ent_deflector =
{
name = "ent_deflector",
print_name = "Deflector",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_c17/lockers001a.mdl",
sound_a = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_b = "vehicles/tank_readyfire1.wav",
sound_build = "ambient/machines/engine4.wav",
sound_damage = "ambient/energy/zap1.wav",
takes_damage = true,
health = 125,
build_time = 5,
build_radius = 50,
damage_return = 15,
damage_return_melee = 5,
}
,

ent_c4 =
{
name = "ent_c4",
print_name = "C4",
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_c17/furniturewashingmachine001a.mdl",
sound_hit = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_build = "ambient/machines/engine4.wav",
sound_built = "vehicles/crane/crane_magnet_release.wav",
sound_beep = "hl1/fvox/beep.wav",
sound_explode = "ambient/explosions/explode_2.wav",
build_time = 1,
takes_damage = true,
damages_players = false,
health = 100,
//mass_override = 800,
damage = 450,
radius = 512,
force_radius = 256,
force_physics_blast = 3000,
fuse = 20,
beep_rate = 1,
beep_rate_amp = .026,
build_radius = 50,
}
,

--[[
ent_missile =
{
name = "ent_missile",
print_name = "Missile",
model = "models/props_junk/metal_paintcan001a.mdl",
sound_hitent = "physics/body/body_medium_impact_hard2.wav",
sound_hitworld = "physics/flesh/flesh_strider_impact_bullet1.wav",
damage_player = 25,
damage_ent = 20,
time_stick = 1,
takes_damage = false,
}
,
]]--

ent_mine =
{
name = "ent_mine",
print_name = "InvisibleMine",
takes_damage = true,
health = 75,
model = "models/items/grenadeammo.mdl",
transition_model = "models/props_junk/plasticbucket001a.mdl",
built_model = "models/props_c17/furniturewashingmachine001a.mdl",
sound_hit = "physics/metal/metal_box_break"..math.random(1,2)..".wav",
sound_builddone = "vehicles/crane/crane_magnet_release.wav",
sound_beep = "npc/strider/charging.wav",
sound_build = "ambient/machines/engine4.wav",
sound_explode = "npc/vort/attack_shoot.wav",
//sound_explode = "ambient/explosions/explode_2.wav",
imagnitude = "100",
iradiusoverride = "256",
build_time = 6,
fuse = 1,
//beep_rate = 1,
}
,



ent_buildingbomb =
{
name = "ent_buildingbomb",
print_name = "Building Bomb",
model = "models/props_junk/metal_paintcan001a.mdl",
sound_explode = "vehicles/airboat/pontoon_impact_hard1.wav",
imagnitude = 55,
iradiusoverride = 200,
takes_damage = false,
force_radius = 128,
force_physics_blast = 200,
force_player_blast = 500,
}
,


ent_whistlemissile =
{
name = "ent_whistlemissile",
print_name = "Pellet",
model = "models/props_junk/propanecanister001a.mdl",
sound_hitent = "physics/metal/metal_computer_impact_bullet1.wav",
sound_hitworld = "physics/flesh/flesh_strider_impact_bullet1.wav",
damage_player = 20,
damage_ent = 25,
time_stick = 1,
takes_damage = false,
distance_damage_player = 128,
}
,

ent_pucknade =
{
name = "ent_pucknade",
print_name = "Nade",
model = "models/props_vehicles/tire001c_car.mdl",
sound_explode = "npc/vort/attack_shoot.wav",
imagnitude = 45,
iradiusoverride = 250,
health = 45,
takes_damage = false,
force_radius = 200,
force_physics_blast = 0,
force_player_blast = 350,
force_player_blast_vert = 250,
fuse = 2.5,
friction = .01,
radius = 60,
think_rate = .1,
}
,

ent_slowthrow =
{
name = "ent_slowthrow",
print_name = "Crippler",
model = "models/props_junk/metal_paintcan001a.mdl",
sound_explode = "npc/scanner/scanner_explode_crash2.wav",
radius = 200,
duration_level1 = 5,
duration_level2 = 7,
duration_level3 = 9,
takes_damage = false,
}
,

ent_wallgrabber =
{
name = "ent_wallgrabber",
print_name = "WallGrabber",
model = "models/props_c17/oildrum001.mdl",
takes_damage = true,
health = 50,
}
,

ent_bomb_barrage =
{
name = "ent_bomb_barrage",
print_name = "Barrage Bomb",
model = "models/props_junk/metal_paintcan001a.mdl",
sound_explode = "npc/vort/attack_shoot.wav",
imagnitude = 35,	--40
iradiusoverride = 250,
takes_damage = false,
}
,

ent_bomb =
{
name = "ent_bomb",
print_name = "Height Bomb",
model = "models/props_junk/metal_paintcan001a.mdl",
damage_multiplier = .02,
damage_ground = 3,
radius = 128,
gravity_force = 45000,	--50000
think_rate = .1,
sound_explode = "npc/vort/attack_shoot.wav",
sound_hit = "Metal_Barrel.BulletImpact",
takes_damage = false,
}
,

dev_posmark =
{
name = "dev_posmark",
model = "models/props_junk/garbage_coffeemug001a.mdl",
}
,

}

--recieves an actual ent, not the string name of one
function CheckIfInEntTable(ent)
	for _, value in pairs(ENT_TABLE) do		///check if the ent is one of the the games's objects
		if value.name == ent:GetClass() then
			return true
		end
	end
	return false
end


function EntReference(entstring)		//returns the ent from the main table of stats for easy reference
	local ref = nil
	for _, ent in pairs(ENT_TABLE) do
		if ent.name == entstring then
			ref = ent
		end
	end
	return ref
end
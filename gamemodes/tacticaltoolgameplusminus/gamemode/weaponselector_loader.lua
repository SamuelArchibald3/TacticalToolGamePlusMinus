include("weaponselector/config.lua")
if SERVER then
    AddCSLuaFile("weaponselector/config.lua")
    AddCSLuaFile("weaponselector/client/hooks.lua")
elseif CLIENT then
    include("weaponselector/client/hooks.lua")
end
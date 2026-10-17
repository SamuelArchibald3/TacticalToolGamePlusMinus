AddCSLuaFile( "tool_evilboulder.lua" )

SWEP.Base = "tool_boulder"


--The Evil Boulder's tool: the Boulder's, deploying and steering alike. What
--its boulder does once built is ent_evilboulder's business.
--
--Right click steers your evil boulders and not your ordinary ones: the Boulder
--steers the boulders of its own thrown_ent (SWEP:OwnBoulders).

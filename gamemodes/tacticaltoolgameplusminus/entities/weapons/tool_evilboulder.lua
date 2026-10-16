AddCSLuaFile( "tool_evilboulder.lua" )

SWEP.Base = "tool_boulder"

DEFINE_BASECLASS( "tool_boulder" )


--The Evil Boulder's tool: the Boulder's, deploying and steering alike. What
--its boulder does once built is ent_evilboulder's business.
--
--The boulders it has thrown are kept per tool, made here. tool_boulder keeps
--them in SWEP.EntTable, one table on the class, which every Boulder anybody
--holds reads and writes; inheriting that would also have put these in with
--everybody's ordinary ones.
function SWEP:Initialize()
	self.EntTable = {}

	BaseClass.Initialize( self )
end

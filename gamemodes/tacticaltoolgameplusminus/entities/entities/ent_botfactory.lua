AddCSLuaFile( "ent_botfactory.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

DEFINE_BASECLASS( "base_ttgentity" )


--The Bot Factory. Thrown and built like the sentry; once built, and while a
--fight is on, it makes a Bot beside itself every bot_interval seconds, no
--more than bot_max of them at once.
--
--The Bots are ent_botminion, and everything about them is in this entity's
--ENT_TABLE entry: they are not buildings, so they have none of their own.
--They are this factory's, and go when it does.


//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth( self.Ref.health_building )

	self.Built = false
	self.CurTakeDamage = false
	self.HitSurface = false
	self.ReadyToFinishBuild = false

	self.Bots = {}
	self.NextBotAt = 0
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
end


--lands where the sentry does: on the floor, or on top of a built box
function ENT:PhysicsCollide( data, phys )
	if self.HitSurface == true then return end

	local normalang = data.HitNormal:Angle()
	if ( data.HitEntity:IsWorld() and data.HitNormal[3] < 0 )
	or ( data.HitEntity:GetClass() == "ent_stepbox" and data.HitEntity.Built == true and normalang.y == 0 )
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true and data.HitNormal[3] < 0 ) then

		self:EmitSound( self.Ref.sound_a )

		self:BuildFromCollision( data, data.HitPos, data.HitNormal )

		self.HitSurface = true
		self.HitPostion = data.HitPos
	end
end


function ENT:ObjToMachine( pos, wallnormal )
	self.CurTakeDamage = true

	self:SetAngles( Angle( 0, 0, 0 ) )

	self:SetOwner( nil )	--makes it so the owners bullets will collide with it, and the owner will as well

	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )

	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build )
	self.BuildingSound:Play()

	timer.Simple( self.Ref.build_time, function()
		if not IsValid( self ) then return end

		self.ReadyToFinishBuild = true
	end )
end


function ENT:FinishBuild()
	self.Built = true

	self:EmitSound( self.Ref.sound_b )

	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )

	--stood on the spot it landed on - the model's own bottom on it, wherever
	--its origin is - facing the way it was thrown
	self:SetPos( self.HitPostion - Vector( 0, 0, self:OBBMins().z ) )
	self:SetAngles( Angle( 0, self.TTG_Angles and self.TTG_Angles.y or 0, 0 ) )

	--from its building health up to its full one, as the Barrier does
	self:GrowToFullHealth()

	--the first Bot a whole wait after it is up, not the moment it is
	self.NextBotAt = CurTime() + self.Ref.bot_interval

	--stop the looping build sound
	self.BuildingSound:Stop()
end


function ENT:Think()
	--when ready to build before building, wait until there are no players in the way to do it
	if self.ReadyToFinishBuild and not self.Built then
		if not self:CheckIfPlayerInWay() then
			self:FinishBuild()
		else
			--make the building looping sound get lower pitched so show that someones in the way
			self.BuildingSound:ChangePitch( 50, .1 )
		end
	end

	if self.Built == true then
		self:MakeBots()
	end

	self:NextThink( CurTime() + .2 )
	return true
end


------------------------------------------------------------------------------------------------
--Bots
------------------------------------------------------------------------------------------------

--The Bots it has out now. Ones that have fizzled or been killed drop off.
function ENT:LiveBots()
	local live = {}

	for _, bot in ipairs( self.Bots ) do
		if IsValid( bot ) and not bot:IsMarkedForDeletion() then
			table.insert( live, bot )
		end
	end

	self.Bots = live
	return live
end


--Make a Bot if one is due.
function ENT:MakeBots()
	--Outside a fight the wait starts over, so the first one comes a whole
	--interval into Combat rather than the moment it begins.
	if not TTG_BotsFighting() then
		self.NextBotAt = CurTime() + self.Ref.bot_interval
		return
	end

	if CurTime() < self.NextBotAt then return end

	--at the limit it stays due, and comes as soon as one goes
	if #self:LiveBots() >= self.Ref.bot_max then return end

	--nowhere to put one - somebody standing all round it - so try again soon
	local spot = self:BotSpot()
	if spot == nil then return end

	self:MakeBot( spot )
	self.NextBotAt = CurTime() + self.Ref.bot_interval
end


--A bit of floor beside it that a Bot fits on, or nil.
local BOT_MINS, BOT_MAXS = Vector( -14, -14, 0 ), Vector( 14, 14, 66 )

function ENT:BotSpot()
	local floor = self.HitPostion or self:GetPos()
	local reach = self:BoundingRadius() * 0.75 + 24

	for i = 0, 7 do
		local dir = Angle( 0, self:GetAngles().y + i * 45, 0 ):Forward()
		local spot = floor + dir * reach

		local room = util.TraceHull( { start = spot + Vector( 0, 0, 6 ), endpos = spot + Vector( 0, 0, 6 ), mins = BOT_MINS, maxs = BOT_MAXS, mask = MASK_NPCSOLID } )
		local ground = util.TraceLine( { start = spot + Vector( 0, 0, 6 ), endpos = spot - Vector( 0, 0, 48 ), mask = MASK_NPCSOLID_BRUSHONLY } )

		--a hull that does not move says it is blocked through StartSolid
		if not room.StartSolid and not room.Hit and ground.Hit then
			return ground.HitPos
		end
	end

	return nil
end


function ENT:MakeBot( spot )
	local bot = ents.Create( "ent_botminion" )
	if not IsValid( bot ) then return end

	bot:SetPos( spot )
	bot:SetAngles( Angle( 0, ( spot - self:GetPos() ):Angle().y, 0 ) )

	--on the factory's side, and its thrower's: the Bot's hits are theirs
	bot.TTG_Team = self.TTG_Team
	bot.Creator = self.Creator
	bot.Factory = self

	bot:Spawn()

	table.insert( self.Bots, bot )
	self:EmitSound( self.Ref.sound_spawn )

	return bot
end


--Its Bots go when it does: broken, cleared away at the end of a round, or
--taken back by a Rewind.
function ENT:OnRemove()
	for _, bot in ipairs( self.Bots or {} ) do
		if IsValid( bot ) then bot:Fizzle() end
	end

	BaseClass.OnRemove( self )
end

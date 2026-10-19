AddCSLuaFile( "ent_botminion.lua" )

ENT.Base 			= "base_nextbot"
ENT.Type 			= "nextbot"
ENT.Spawnable 		= false


--A Bot Factory's Bot (ent_botfactory). It runs at the nearest enemy player it
--can see and hits them, and nothing else: not buildings, not other Bots.
--
--Straight at them. None of the maps have a navmesh, so a Bot cannot plan a way
--round a wall - it goes for whoever it can see, gives up on somebody it has
--lost sight of for a second, and does not last long enough to matter when it
--gets stuck. Everything about it is in the factory's ENT_TABLE entry, the
--bot_ fields: a Bot is not a building, so it has none of its own.
--
--It is hurt the way a player is. Bullets and blasts reach it by themselves;
--the weapons that only hurt players and buildings ask IsTTGBot (meta_ent.lua)
--as well.


if CLIENT then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


local function Ref()
	return ENT_TABLE.ent_botfactory
end


--tinted for its side, the way every building is
local function TeamTint( teamid )
	if teamid == TEAM_BLUE then return Color( 54, 224, 254, 255 ) end
	if teamid == TEAM_RED then return Color( 255, 118, 118, 255 ) end

	return Color( 255, 255, 255, 255 )
end


--The first of these activities the model has. A player model runs on
--ACT_HL2MP_RUN where an NPC model runs on ACT_RUN, so a Bot can wear either.
local function FirstAct( ent, acts )
	for _, act in ipairs( acts ) do
		if ent:SelectWeightedSequence( act ) >= 0 then return act end
	end
end


--What it looks like: { model, material, scale }. The factory's bot_ fields
--unless something says otherwise - ttg_devbotlooks, lining the choices up.
function ENT:ApplyLook( look )
	self:SetModel( look.model )
	self:SetMaterial( look.material or "" )
	self:SetModelScale( look.scale or 1, 0 )

	--A Bot's size whatever it wears: the factory's check for room to put one
	--down assumes it.
	self:SetCollisionBounds( Vector( -14, -14, 0 ), Vector( 14, 14, 66 ) )

	self.Acts = {
		run = FirstAct( self, { ACT_RUN, ACT_HL2MP_RUN, ACT_WALK, ACT_HL2MP_WALK } ) or ACT_RUN,
		idle = FirstAct( self, { ACT_IDLE, ACT_HL2MP_IDLE } ) or ACT_IDLE,
		hit = FirstAct( self, { ACT_MELEE_ATTACK_SWING_GESTURE, ACT_GESTURE_MELEE_ATTACK1, ACT_GMOD_GESTURE_RANGE_ZOMBIE, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST } ),
	}
end


function ENT:Initialize()
	local ref = Ref()

	self:ApplyLook( self.TTG_Look or { model = ref.bot_model, material = ref.bot_material, scale = ref.bot_scale } )
	self:SetColor( TeamTint( self.TTG_Team ) )

	self:SetHealth( ref.bot_health )
	self:SetMaxHealth( ref.bot_health )

	self.loco:SetDesiredSpeed( ref.bot_speed )
	self.loco:SetAcceleration( 1000 )
	self.loco:SetDeceleration( 1000 )
	self.loco:SetStepHeight( 18 )
	self.loco:SetJumpHeight( 58 )
	self.loco:SetMaxYawRate( 360 )

	self.DieAt = CurTime() + ref.bot_lifetime
	self.NextHit = 0
end


------------------------------------------------------------------------------------------------
--Who to go for
------------------------------------------------------------------------------------------------

--Other Bots are not in the way of seeing somebody: they get out of each
--other's way soon enough, and a pack that blinded itself would stand still.
local function NotABot( ent )
	return not ent:IsTTGBot()
end


--Whether it can see them: the sentry's look, from about head height to their
--chest, through grates as the sentry sees through them.
function ENT:CanSee( ply )
	local tr = util.TraceLine( {
		start = self:GetPos() + Vector( 0, 0, 56 ),
		endpos = TTG_AimPointFor( ply, .7 ),
		filter = NotABot,
		mask = MASK_SOLID - CONTENTS_GRATE,
	} )

	return tr.Entity == ply
end


--The nearest enemy player it can see within bot_range, or nil.
function ENT:FindTarget()
	local best, bestdist = nil, Ref().bot_range

	for _, ply in ipairs( player.GetAll() ) do
		if ply:IsValidGamePlayer() and ply:Team() != self.TTG_Team then
			local dist = ply:GetPos():Distance( self:GetPos() )

			if dist <= bestdist and self:CanSee( ply ) then
				best, bestdist = ply, dist
			end
		end
	end

	return best
end


------------------------------------------------------------------------------------------------
--Hitting
------------------------------------------------------------------------------------------------

--Hit them if they are in reach and it is ready to, and say whether it did.
--
--The hit is its thrower's, as everything a building does is: the kill and the
--kill feed are theirs, and the team-damage rule is the one players have.
function ENT:TryHit( target )
	local ref = Ref()

	if not TTG_BotsFighting() then return false end
	if CurTime() < self.NextHit then return false end

	local offset = target:GetPos() - self:GetPos()
	if offset:Length2D() > ref.bot_reach or math.abs( offset.z ) > 72 then return false end

	self.NextHit = CurTime() + ref.bot_hit_interval

	local dmginfo = DamageInfo()
		dmginfo:SetDamage( ref.bot_damage )
		dmginfo:SetDamageType( DMG_CLUB )
		dmginfo:SetDamageForce( offset:GetNormalized() * 2000 )
		dmginfo:SetInflictor( self )
		dmginfo:SetAttacker( IsValid( self.Creator ) and self.Creator or self )

	target:TakeDamageInfo( dmginfo )

	if self.Acts.hit then self:RestartGesture( self.Acts.hit ) end
	self:EmitSound( ref.bot_sound_hit )

	return true
end


------------------------------------------------------------------------------------------------
--Behaviour
------------------------------------------------------------------------------------------------

--Gone if its time is up. Says whether it went, so a loop knows to stop.
function ENT:Spent()
	if self.TTG_Showcase then return false end
	if CurTime() < self.DieAt then return false end

	self:Fizzle()
	return true
end


function ENT:RunBehaviour()
	while true do
		if self.TTG_Showcase then
			self:ShowOff()

		elseif not self:Spent() then
			local target = TTG_BotsFighting() and self:FindTarget() or nil

			if IsValid( target ) then
				self:Chase( target )
			else
				self:StartActivity( self.Acts.idle )
				coroutine.wait( .3 )
			end
		end

		coroutine.yield()
	end
end


--Straight at them, hitting when in reach, for as long as the fight is on and
--they are an enemy in play. Every quarter second it looks again: somebody
--nearer may have come into view, and somebody out of sight for a second is
--given up on.
function ENT:Chase( target )
	self:StartActivity( self.Acts.run )

	local nextlook, lostsince = 0, nil

	while TTG_BotsFighting() and IsValid( target ) and target:IsValidGamePlayer() and target:Team() != self.TTG_Team do
		if self:Spent() then return end

		if CurTime() >= nextlook then
			nextlook = CurTime() + .25

			local nearest = self:FindTarget()
			if IsValid( nearest ) then
				target, lostsince = nearest, nil
			else
				lostsince = lostsince or CurTime()
				if CurTime() - lostsince > 1 then break end
			end
		end

		self.loco:FaceTowards( target:GetPos() )

		--In reach, it stands and swings rather than walking into them on the
		--spot; a little inside reach, so a step back does not end it.
		if ( target:GetPos() - self:GetPos() ):Length2D() > Ref().bot_reach * .75 then
			if self:GetActivity() != self.Acts.run then self:StartActivity( self.Acts.run ) end
			self.loco:Approach( target:GetPos(), 1 )
		elseif self:GetActivity() != self.Acts.idle then
			self:StartActivity( self.Acts.idle )
		end

		self:TryHit( target )

		--a hop, for a lip it has walked into
		if self.loco:IsStuck() then
			self.loco:Jump()
			self.loco:ClearStuck()
		end

		coroutine.yield()
	end

	self:StartActivity( self.Acts.idle )
end


--For ttg_devbotlooks: stood still, running on the spot, then a swing.
function ENT:ShowOff()
	self:StartActivity( self.Acts.idle )
	coroutine.wait( 2 )

	self:StartActivity( self.Acts.run )
	coroutine.wait( 2 )

	self:StartActivity( self.Acts.idle )
	if self.Acts.hit then self:RestartGesture( self.Acts.hit ) end
	coroutine.wait( 1.5 )
end


--Running plays at the speed it is moving. One running on the spot for a
--showing has no speed to match, so it plays at its own rate.
function ENT:BodyUpdate()
	if not self.TTG_Showcase and self:GetActivity() == self.Acts.run then
		self:BodyMoveXY()
		return
	end

	self:FrameAdvance()
end


function ENT:Think()
	self:Spent()
end


------------------------------------------------------------------------------------------------
--Going
------------------------------------------------------------------------------------------------

--Gone in a puff: out of time, killed, its factory gone, or a Rewind landing.
function ENT:Fizzle()
	if self.Fizzled then return end
	self.Fizzled = true

	local fx = EffectData()
		fx:SetOrigin( self:WorldSpaceCenter() )
	util.Effect( "cball_explode", fx )

	self:EmitSound( Ref().bot_sound_die )

	self:Remove()
end


--Killed: a fizzle rather than a ragdoll, and no line in the kill feed.
function ENT:OnKilled( dmginfo )
	self:Fizzle()
end


--Its health running out is not enough to kill it: nothing called OnKilled
--when it did - measured, a Bot taken to 0 health, or to -10, stood there - so
--it is looked at once each hit is in.
hook.Add( "PostEntityTakeDamage", "TTG_BotDies", function( ent, dmginfo, took )
	if ent:IsTTGBot() and took and ent:Health() <= 0 then
		ent:Fizzle()
	end
end )


--No friendly fire on a Bot, as there is none on a player: its own side's hits
--do nothing.
hook.Add( "EntityTakeDamage", "TTG_BotFriendlyFire", function( ent, dmginfo )
	if not ent:IsTTGBot() then return end

	local attacker = dmginfo:GetAttacker()
	if IsValid( attacker ) and attacker:IsPlayer() and attacker:Team() == ent.TTG_Team then
		return true
	end
end )


--A Rewind takes them all away. Nothing records a Bot - it is not a building -
--so one left standing would be from a moment the players have just been taken
--back out of. The factories are rewound like any building, and start making
--them again once the playback is over.
hook.Add( "TTG_RewindStarted", "TTG_BotsGo", function()
	for _, bot in ipairs( ents.FindByClass( "ent_botminion" ) ) do
		if not bot.TTG_Showcase then bot:Fizzle() end
	end
end )

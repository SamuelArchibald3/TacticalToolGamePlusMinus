ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


--Claude, the ability: it works out what would help most right now and does
--that, then says what it chose. In order of need:
--
--  hurt          heals you, when you are at or under hurt_fraction of your max
--  in danger     a shield, when an enemy is close and can see you
--  waiting       takes cooldown_cut seconds off your other abilities' cooldowns
--  otherwise     a burst of speed
--
--It thinks for think_time first, so it answers the situation it is asked in a
--moment later rather than instantly. The shop says only "Ask Claude for help":
--finding out is the point.
function ENT:DoAbility()
	if self.Cooldown == true or self.Thinking == true then
		self:CooldownSound()
	return
	end

	if not self.Owner:IsValidGamePlayer() then
		self:CooldownSound()
	return
	end

	--the same guard Shield has: attackers are behind their door until Combat
	if GetTeamRole( self.Owner:Team() ) == "Attacking" and G_CurrentPhase != "Combat" then
		self:CooldownSound()
	return
	end

	self.Thinking = true

	--which question the timer below answers, so one cancelled by a rewind cannot
	--answer anyway
	self.ThinkToken = ( self.ThinkToken or 0 ) + 1
	local token = self.ThinkToken

	self.Owner:EmitSound( self.Ref.sound_think )

	timer.Simple( self.Ref.think_time, function()
		if not IsValid( self ) or self.ThinkToken != token then return end

		self:Answer()
	end )
end


--What would help most right now: "heal", "shield", "cooldowns" or "speed".
function ENT:Choose()
	local ply = self.Owner

	if ply:Health() <= ply:GetMaxHealth() * self.Ref.hurt_fraction then return "heal" end

	if ply:HowManyOfThisBuff( "Buff_Shield" ) == 0 and self:EnemyCanSeeYou() then return "shield" end

	if #self:OthersCoolingDown() > 0 then return "cooldowns" end

	return "speed"
end


--An enemy in play within danger_radius with nothing solid between your eyes
--and theirs.
function ENT:EnemyCanSeeYou()
	local ply = self.Owner

	for _, other in ipairs( player.GetAll() ) do
		if other != ply and other:IsValidGamePlayer() and other:Team() != ply:Team()
		and other:GetPos():Distance( ply:GetPos() ) <= self.Ref.danger_radius then
			local tr = util.TraceLine( {
				start = ply:EyePos(),
				endpos = other:EyePos(),
				mask = MASK_SOLID_BRUSHONLY,
			} )

			if not tr.Hit then return true end
		end
	end

	return false
end


--This player's other abilities that are cooling down.
function ENT:OthersCoolingDown()
	local out = {}

	for _, abil in pairs( self.Owner:GetAbilitySlots() ) do
		if IsValid( abil ) and abil != self and abil.Cooldown == true and ( abil.Time or 0 ) > 1 then
			table.insert( out, abil )
		end
	end

	return out
end


local LINES = {
	heal      = "You looked hurt, so I patched you up.",
	shield    = "Someone close can see you. Shield's up.",
	cooldowns = "Nothing urgent, so I've sped up your other abilities.",
	speed     = "All clear. Here's some speed to get you there.",
}


function ENT:Answer()
	self.Thinking = false

	local ply = self.Owner
	if not IsValid( ply ) or not ply:IsValidGamePlayer() then return end

	local choice = self:Choose()
	local ref = self.Ref

	if choice == "heal" then
		ply:TTG_Heal( ref.heal )
	elseif choice == "shield" then
		ply:AddBuff( "Buff_Shield", ref.shield_time )
	elseif choice == "cooldowns" then
		for _, abil in ipairs( self:OthersCoolingDown() ) do
			abil.Time = math.max( 1, abil.Time - ref.cooldown_cut )
			abil:UpdateNetworkedVars( true, abil.Time )
		end
	else
		ply:AddBuff( "Buff_Speed", ref.speed_time )
	end

	self.LastChoice = choice
	ply:ChatPrint( "Claude: " .. LINES[ choice ] )
	ply:EmitSound( ref.sound_answer )

	self:InitiateCooldown()
end


--A question still being thought about when a rewind lands is dropped: the
--situation it was asked about no longer exists, and it costs nothing.
function ENT:RewindReset()
	self.Thinking = false
	self.ThinkToken = ( self.ThinkToken or 0 ) + 1
end

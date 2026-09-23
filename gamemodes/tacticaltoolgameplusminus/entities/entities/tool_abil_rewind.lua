ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:DoAbility()
	if self.Cooldown == true then
		self:CooldownSound()
	return
	end

	--Every other tool_abil_* wraps its phase checks in
	--GetTeamRole( self.Owner:Team() ) == "Attacking", which means defenders are
	--not guarded at all and can fire during DefendersBuy, Planning and Setup.
	--Harmless for Shield. Here it would let a defender drag every attacker out
	--of their spawn while they are still frozen behind a closed door, so this
	--guard is unconditional. It covers "Winning" and the tiebreak round that
	--skips Setup entirely as a side effect.
	if G_CurrentPhase != "Combat" then
		self:CooldownSound()
	return
	end

	--Refused rather than half-applied - see TTG_RewindTargets. No cooldown
	--charged for a refusal, the same way quickport only charges once its second
	--step actually lands.
	if TTG_RewindAllPlayers( self.Owner ) != true then
		self:CooldownSound()
	return
	end

	self:InitiateCooldown()
end

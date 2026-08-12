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
	if GetTeamRole( self.Owner:Team() ) == "Attacking" then
		if G_CurrentPhase == "GameSetup" then
			return 
		elseif G_CurrentPhase == "DefendersBuy" then
			return 
		elseif G_CurrentPhase == "AttackersBuy" then
			return 
		elseif G_CurrentPhase == "Planning" then
			return 
		elseif G_CurrentPhase == "Setup" then
			return 
		end
	end
	
	--so they cant have multiple active at the same time
	//if self.Owner:HowManyOfThisBuff( "Buff_DropSlamPrime" ) > 0 then
		//self:CooldownSound()
	//return 
	//end
	
	//prime the player's drop slam for the next time they hit the ground
	//self.Owner:DropSlamPrime( true, self )
	
	--if this drop slam is already primed, then return end
	if self.Primed == true then 
		self:CooldownSound()
	return 
	end
	
	self.BuffSlot = self.Owner:AddBuff( "Buff_DropSlamPrime" )
	
	self.Primed = true
	
end


function ENT:DoEffect(  )
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() + Vector(0, 0, 10) )
		effectdata:SetStart( self.Owner:GetPos() + Vector(0, 0, 20) )
		effectdata:SetScale( 8 )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self )
	util.Effect( "HelicopterMegaBomb", effectdata )
end


function ENT:DropSlam( fallspeed )
	self.Owner:EmitSound( self.Ref.sound_explosion )
	
	local orgin_ents = ents.FindInSphere( self.Owner:GetPos(), self.Ref.radius )
	
	--damage ents in the radius
	for k, ent in pairs( orgin_ents ) do
		if ent:IsValidGamePlayer() and ent:Team() != self.Owner:Team() then
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( (fallspeed * self.Ref.damage) - 20 )
				dmginfo:SetInflictor( self )
				dmginfo:SetAttacker( self.Owner )

			ent:TakeDamageInfo( dmginfo )
			//print( "dropslam dealing this damage",fallspeed * self.Ref.damage )
			
			//ent:BuffForDuration_SpecialSlow( self.Ref.slow_duration )
			ent:AddBuff( "Buff_SlowHigh", self.Ref.slow_duration )
			
			self:DoEffect(  )
		end
	end
	
	self.Primed = false
	self.Owner:RemoveBuff_BySlot( self.BuffSlot )
	self:InitiateCooldown()
end
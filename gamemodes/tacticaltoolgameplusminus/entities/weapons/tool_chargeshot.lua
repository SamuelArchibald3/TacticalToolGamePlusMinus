AddCSLuaFile( "tool_chargeshot.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	self:Shoot( )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.Ref.charge_sound )
end



function SWEP:SecondaryAttack()
	return false
end




function SWEP:DoShootEffect( hitpos )
	if !SERVER then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )
end


function SWEP:Shoot()
	
	self.Owner:Freeze( true )
	self.Charging = true
	
	timer.Simple( self.Ref.charge_time, function()
		if not IsValid( self ) then return end
		
		if SERVER then
			self.Owner:EmitSound( self.Ref.shoot_sound )
		end
		
		self.Owner:Freeze( false )
		
		local tr = self.Owner:GetEyeTrace()
		self:DoShootEffect( tr.HitPos )
		if tr.Entity:IsPlayer() and tr.Entity:Team() != TEAM_SPEC and tr.Entity:Team() != self.Owner:Team() then
			local ent = tr.Entity
			
			if SERVER then
				local dmginfo = DamageInfo()
					dmginfo:SetDamage( self.Ref.player_damage )
					dmginfo:SetDamageForce( self.Owner:GetForward() * 500000 ) --makes ragdoll go flying
					dmginfo:SetInflictor( self )
					dmginfo:SetAttacker( self.Owner )

				ent:TakeDamageInfo( dmginfo )
			end
			
		elseif CheckIfInEntTable(tr.Entity) then
			local ent = tr.Entity
			local entref = EntReference(tr.Entity:GetClass())
			
			if SERVER then
				local dmginfo = DamageInfo()
					dmginfo:SetDamage( self.Ref.building_damage )
					dmginfo:SetInflictor( self )
					dmginfo:SetAttacker( self.Owner )

				ent:TakeDamageInfo( dmginfo )
			end
		end
		
		
		self.Charging = false
	end)
		

end


function SWEP:Holster( wep )
	--stuff unique to this gun
	--if youre charging up to shoot, you cannot switch from this gun
	if self.Charging == true then
		return false
	end

	
	
	
	--stuff copied from the base
	self:SetIfReloading(false)
	
	self.Owner:TTG_Slow(false)
	self.Reloading = false
	self:SetNextPrimaryFire(CurTime())
	self:SetNextSecondaryFire(CurTime())
	return true
end

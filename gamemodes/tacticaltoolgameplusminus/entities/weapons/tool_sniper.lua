AddCSLuaFile( "tool_sniper.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end


function SWEP:DoShootEffect( )
	if SERVER then
		local tr = self.Owner:GetEyeTrace()
		
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetStart( self.Owner:GetShootPos() )
			effectdata:SetAttachment( 1 )
			effectdata:SetEntity( self.Weapon )
		util.Effect( "ToolTracer", effectdata )
	end


	if CLIENT then
		if self.CL_EffectDone != true then
			local tr = self.Owner:GetEyeTrace()
			
			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetStart( self.Owner:GetShootPos() )
				effectdata:SetAttachment( 1 )
				effectdata:SetEntity( self.Weapon )
			util.Effect( "ToolTracer", effectdata )
			
			self.CL_EffectDone = true
		end
		
		timer.Simple( .3, function()
			if IsValid( self ) then
				self.CL_EffectDone = false
			end
		end)
	end
end





function SWEP:Think()
	if CLIENT then
		if self:GetNWBool("DoShootEffect") == true then 
			self:DoShootEffect( )
		end
	end


	if !SERVER then return end

	--Sniper stuff--
	if self.ChargeLevel == nil then
		self.ChargeLevel = 0
	end
	
	
	if( self.Owner:KeyDown( IN_ATTACK ) ) and self:CanPrimaryAttack() then
		--this runs when only the gun first starts charging
		if self.Charging == false then
			self.Owner:TTG_SniperSlow(true)
			
			self.ChargingSound = CreateSound( self.Owner, self.Ref.sound_charge );
			self.ChargingSound:Play();
		end
		
		self.Charging = true
	else
		self.Charging = false
	end
	
	if self.Charging == false and self.ChargeLevel > 0 then
		if ( self:CanPrimaryAttack() ) then
			self:SniperShoot( self.ChargeLevel )
		end
	end
	
	if self.Charging == false then
		self.ChargeLevel = 0
	end
	
	if self.Charging == true then
		self.ChargeLevel = self.ChargeLevel + 2
		
		--make the building looping sound get higher pitched depending on how charged the gun is
		self.ChargingSound:ChangePitch( (100 + (self.ChargeLevel*.1)), 1 )
		
		if self.ChargeLevel >= 900 and  self.ChargeLevel <= 910 then
			self.Owner:EmitSound( self.Ref.sound_alert )
		end
		
		if self.ChargeLevel >= 1000 then
			self:SniperShoot( self.ChargeLevel )
		end
	end
	

	
	
	--Reloading stuff taken from the base class--
	
	//if self.Ref.infinite == false then return end
	if not self.Ref.class == "gun" then return end
	
	if self.Reloading then
		self:SetNWBool("Zoomed", false) 
	
		if CurTime() >= self.ReloadFinishTime then
			self:SetClip1(self.Primary.ClipSize)
			self.Reloading = false
			self:SendWeaponAnim( ACT_VM_IDLE  )
			
			--this is for clients displaying, "reloading" over the player's head
			self:SetIfReloading(false)
			
			
			self.Owner:TTG_Slow(false)
			self.Owner:EmitSound( self.ReloadSound )
		end
	end
	
end




function SWEP:SecondaryAttack()
	if self:GetNWBool("Zoomed") == true then 
		self:SetNWBool("Zoomed", false) 
		
	elseif self:GetNWBool("Zoomed") == false then 
		self:SetNWBool("Zoomed", true) 
		
	end
end




function SWEP:SniperShoot( chargeamount )
	//print("damage:", ( self.Ref.player_damage_scale * chargeamount * .1 ))

	if self:Clip1() <= 0 then return end

	self:TakePrimaryAmmo(1)
	
	if self.ChargingSound != nil then
		self.ChargingSound:Stop()
	end

	self:ShootEffects()
	self.Owner:TTG_SniperSlow(false)
	
	
	local tr = self.Owner:GetEyeTrace()
		self:SetNWBool("DoShootEffect", true) 
		self:DoShootEffect()
		if tr.Entity:IsPlayer() and tr.Entity:Team() != TEAM_SPEC and tr.Entity:Team() != self.Owner:Team() then
			local ent = tr.Entity
			
			if SERVER then
				local dmginfo = DamageInfo()
					dmginfo:SetDamage( self.Ref.player_damage_scale * chargeamount * .1 )
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
					dmginfo:SetDamage( self.Ref.building_damage_scale * chargeamount * .1 )
					dmginfo:SetInflictor( self )
					dmginfo:SetAttacker( self.Owner )

				ent:TakeDamageInfo( dmginfo )
			end
		end
		
	timer.Simple( .1, function()
		if IsValid( self ) then
			self:SetNWBool("DoShootEffect", false) 
		end
	end)
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
end




function SWEP:Holster( wep )
	
	if not self.Ref.class == "gun" then 
		return true
	end
	
	
	if self.ChargingSound != nil then
		self.ChargingSound:Stop()
	end

	
	self:SetNWBool("Zoomed", false) 
	
	--this is for clients displaying, "reloading" over the player's head
	self:SetIfReloading(false)
	
	self.Owner:TTG_SniperSlow(false)
	self.Reloading = false
	self:SetNextPrimaryFire(CurTime())
	self:SetNextSecondaryFire(CurTime())
	return true
end




function SWEP:TranslateFOV(oldfov)
	if self:GetNWBool("Zoomed") then return  oldfov - 30 end
	
	return 90
end
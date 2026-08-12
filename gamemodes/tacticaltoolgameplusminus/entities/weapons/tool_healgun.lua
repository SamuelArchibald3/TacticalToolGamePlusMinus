AddCSLuaFile( "tool_healgun.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	if (SERVER) then
		self.Owner:EmitSound( self.ShootSound )
	end
		self:Heal()
end


function SWEP:SecondaryAttack()
	return false
end



function SWEP:DoShootEffect( hitpos )
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )
end



function SWEP:Heal()
	//if (!SERVER) then return end
	

	local function GetIfTooFar(other_ply)
		local max_dist = self.Owner:GetAimTargetMaxDist()
			ply_dist = self.Owner:GetPos():Distance(other_ply:GetPos())
		if ply_dist > max_dist then
			return true
		else
			return false
		end
	end
	
	local heal_target = self.Owner:GetAimTarget()
	
	if not IsValid(heal_target) then return end
	
	if not GetIfTooFar( heal_target ) then
		--draw the cool tracer effect
		self:DoShootEffect( heal_target:GetPos() )
	
		--heal the player
		local newhealth = heal_target:Health() + self.Ref.heal_amount
		
		if newhealth <= 100 then
			heal_target:SetHealth( newhealth )
		else
			heal_target:SetHealth( 100 )
		end
	end
	
end


function SWEP:Deploy()
	self.Owner:SetIfAimTarget(true)
	self.Owner:SetAimTargetMaxDist(self.Ref.distance)
	return true
end


function SWEP:Holster( wep )
	--stuff unique to this gun
	self.Owner:SetIfAimTarget(false)
	self.Owner:SetAimTargetMaxDist( 0 )


	--stuff copied from the base
	self:SetIfReloading(false)
	
	self.Owner:TTG_Slow(false)
	self.Reloading = false
	self:SetNextPrimaryFire(CurTime())
	self:SetNextSecondaryFire(CurTime())
	return true
end

 

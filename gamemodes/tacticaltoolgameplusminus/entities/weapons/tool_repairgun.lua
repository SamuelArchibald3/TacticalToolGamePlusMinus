AddCSLuaFile( "tool_repairgun.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	if (SERVER) then
		self.Owner:EmitSound( self.ShootSound )
	end
	
		self:Repair()
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


 function SWEP:Repair()
		
		local tr = self.Owner:GetEyeTrace()
		
		self:DoShootEffect( tr.HitPos )
		
		if CheckIfInEntTable(tr.Entity) then
			local ent = tr.Entity
			local entref = EntReference(tr.Entity:GetClass())
			
			if entref.takes_damage == true and ent.Built == true then
				local dmginfo = DamageInfo()
					dmginfo:SetDamage( -self.Ref.heal_amount )

				ent:TakeDamageInfo( dmginfo )
			end
		end
 end


 

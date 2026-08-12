AddCSLuaFile( "tool_smokecube.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowEnt()
	
end

function SWEP:SecondaryAttack()
	--if aimed at one of your teams smoke, then dispel it
	local tr = self.Owner:GetEyeTrace()
		
	if tr.Entity:GetClass() == "ent_smokecube" and tr.Entity.TTG_Team == self.Owner:Team() then
		tr.Entity:Dispel()
	end
end


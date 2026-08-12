AddCSLuaFile( "tool_airblast.lua" )

SWEP.Base = "base_ttgtool"


function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:Airblast( )
end


function SWEP:Airblast()
	local selfvector = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * self.Ref.radius)

	local orgin_ents = ents.FindInSphere( selfvector, self.Ref.radius );

	for k, ent in pairs( orgin_ents ) do
		
		--special var to give to stuff i dont want to be airblastable for some reason
		if ent.CanAirblast != false then
		
			--blast back a player
			if ent:IsPlayer() and ent != self.Owner then
				ent:SetVelocity( self.Owner:GetAimVector() * self.Ref.force_player_blast + Vector(0, 0, 500))
				
			--blast back physics ent
			elseif ent:GetPhysicsObject( ):IsValid() then
				//ent:SetAngles( self.Owner:EyeAngles() )
			
				local phys = ent:GetPhysicsObject()
				phys:SetVelocity(self.Owner:GetAimVector():GetNormalized() *  self.Ref.force_physics_blast)
				//phys:ApplyForceCenter( self.Owner:GetAimVector():GetNormalized() *  self.Ref.force_physics_blast )
			end
		end
		
	end
end


function SWEP:SecondaryAttack()
	return false
end





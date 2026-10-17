AddCSLuaFile( "tool_boulder.lua" )

SWEP.Base = "base_ttgtool"



SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowBoulder()
	
end


function SWEP:ThrowBoulder()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj.Creator = self.Owner
		obj.TTG_Angles = (self.Owner:EyeAngles())
		obj.TTG_Team = self.Owner:Team()

		obj.CreatorTool = self
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end



--The boulders right click steers: the ones its holder threw with this tool's
--kind of boulder, and nobody else's.
--
--Found by who threw them rather than kept in a list. The list was SWEP.EntTable,
--one table on the class that every Boulder anybody held read and wrote, so one
--player's right click steered every boulder on the map, the enemy's included.
--A list on each tool instead would forget them whenever the tool is handed
--back new, which a Rewind revive does.
function SWEP:OwnBoulders()
	local mine = {}

	for _, ent in ipairs( ents.FindByClass( self.ThrownEnt ) ) do
		if ent.Creator == self.Owner then table.insert( mine, ent ) end
	end

	return mine
end



--Steer your boulders toward where you are aiming.
function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then return end

	local mine = self:OwnBoulders()

	--aimed past the boulders themselves, at whatever is behind them
	local filter = { self.Owner }
	table.Add( filter, mine )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 16384,
		filter = filter
	} )

	for _, ent in ipairs( mine ) do
		local phys = ent:GetPhysicsObject()

		--A knockback takes control away for a moment (ENT:BreakControl), which
		--is also why this sets the velocity rather than using ENT:Knockback.
		if ent.CanControl != false and IsValid( phys ) then
			local move_ang = ( tr.HitPos - ent:GetPos() ):GetNormal()

			phys:SetVelocity( Vector( move_ang.x, move_ang.y, 0 ) * self.Ref.force_phys )
		end
	end

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Ref.rate_of_fire_secondary )
end





function SWEP:Think( )
	
end

AddCSLuaFile("default_melee.lua")

if CLIENT then
	function SWEP:DrawWorldModel()
		if self:GetIfInvis() == true then return end
		
		self:DrawModel()
	end
end


------------------------------------------------------------------------------------------------
--all shared from now on
------------------------------------------------------------------------------------------------
---

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.AnimPrefix		= "crowbar"
SWEP.HoldType		= "melee"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Melee"
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.DrawWeaponInfoBox	= false	
SWEP.BounceWeaponIcon   = false		

SWEP.Primary.Range			= 100
SWEP.Primary.Damage			= 20.0
SWEP.Primary.DamageType		= DMG_CLUB
SWEP.Primary.Force			= 2
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= .6
SWEP.BaseDelay				= .6
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "None"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true			// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"

//SWEP.HitDistance = 80

//SWEP.PlayerHeal = 2
//SWEP.BuildableHeal = 5


//local SwingSound = Sound( "Weapon_Crowbar.Single" )
//local HitSound = Sound( "physics/concrete/concrete_block_impact_hard" .. math.random(1, 3) .. ".wav" )
//local FleshSound = Sound( "Flesh.ImpactHard" )
//local BuildableHitSound = Sound("Metal_Box.BulletImpact")


function SWEP:SetBaseVars()
	self.Ref = self:GetRef()
	
	self.Primary.Delay = self.Ref.rate_of_fire
	self.BaseDelay = self.Ref.rate_of_fire
	
	self.Secondary.Delay = self.Ref.rate_of_fire_secondary
	self.BaseDelayAlt = self.Ref.rate_of_fire_secondary
	
	self.ViewModel = self.Ref.v_model
	self.WorldModel = self.Ref.w_model
	self.PrintName = self.Ref.print_name
end



function SWEP:Initialize()
	self:SetWeaponHoldType( "melee2" )
	
	self:SpecialInit()
	
	self:SetBaseVars()
	
	//self:SetMaterial("models/props_combine/com_shield001a")
	//self:SetColor(Color(0,255,244,255))
end


function SWEP:PrimaryAttack()
	if self.GroundHitCheck == true then return end
	//if self.OwnerStillSlowed == true then return end
	
	self.Weapon:SendWeaponAnim( ACT_VM_HOLSTER );
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay	 )
	if SERVER then
		self.Owner:EmitSound( self.Ref.sound_preswing )
		self.Owner:AddBuff( "Buff_Speed", self.Ref.duration_speed, false )
		self.MidSwing = true
	end
	
	
	timer.Simple( self.Ref.duration_speed, function()
		if not IsValid(self) then return end
		//self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
		//self:SwingMelee( )
		self.GroundHitCheck = true
	end )
end


function SWEP:DoShootEffect( hitpos )
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )
end



function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextPrimaryFire() then return end
	
	
	
	local function DoSecondaryEffects( ent )
		if ( IsValid( ent )) and CheckIfInEntTable(ent) then
			//self:DoShootEffect( tr_line.HitPos )
			
			if SERVER then
				--Heal the building
				local dmginfo = DamageInfo()
				
					--heak or hurt the building depending on if its allied or enemy
					if ent.TTG_Team != self.Owner:Team() then
						dmginfo:SetDamage( self.Ref.hurt_amount_building )
					else
						dmginfo:SetDamage( -self.Ref.heal_amount_building )
					end
					
				//print("healing ent",  tr_line.Entity )
				dmginfo:SetInflictor( self )
				dmginfo:SetAttacker( self.Owner )
				ent:TakeDamageInfo( dmginfo )
				
				
				--knockback the building if its a prop
				if ent:GetPhysicsObject():IsValid() then
					local aim = self.Owner:GetForward() 
					ent:Knockback( aim, self.Ref.force_phys * .7 )
				end
					
				self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay  )
				return
			end
		end
	end
	
	
	if SERVER then
		self.Owner:EmitSound( self.Ref.heal_sound ) 
	end

	local do_hull_trace = false
	
	local tr_straight = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Ref.hit_distance_secondary,
		filter = self.Owner, self
		} )
	
	if tr_straight.HitNonWorld == true then
		--zap effect
		//print("reg zap")
		self:DoShootEffect( tr_straight.HitPos )
		
		if SERVER then
			DoSecondaryEffects( tr_straight.Entity )
		end
	else
		do_hull_trace = true
	end

	
	if 	do_hull_trace == true then
		--old method
		local tr_hull = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Ref.hit_distance_secondary,
			filter = self.Owner,
			mins = self.Owner:OBBMins()*1.3,
			maxs = -(self.Owner:OBBMins()*1.3)
			} )
		
		if tr_hull.Hit == true then
			--zap effect
			//print("hull zap")
			if tr_hull.HitNonWorld then
				self:DoShootEffect( tr_hull.Entity:GetPos() )
			else
				self:DoShootEffect(tr_hull.HitPos)
			end
			
			if SERVER then
				DoSecondaryEffects( tr_hull.Entity )
			end
		end

		
	end
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay  )
end





function SWEP:Think( )
	if not self.GroundHitCheck == true then return end
	
	if self.Owner:OnGround() then
		self:SwingMelee( )
		self.Owner:SetVelocity( -self.Owner:GetVelocity() * .65 )
		
		self.MidSwing = false
		self.GroundHitCheck = false
	end
end


function SWEP:Holster( wep )
	if CLIENT then return false end
	if self.MidSwing == true then return false end
	self.GroundHitCheck = false
	return true
end

function SWEP:SwingMelee( )
	self.Owner:DoAttackEvent( )
	
	if SERVER then
		self.Owner:EmitSound( self.Ref.sound_swing )
		
		self.Owner:AddBuff( "Buff_SlowHigh", self.Ref.duration_slow, false )
	end
	
	
	
	self:SetNextPrimaryFire( CurTime() + self.Ref.duration_slow	 )
	
	//self.OwnerStillSlowed = true
	//timer.Simple( self.Ref.duration_slow, function()
		//if not IsValid(self) then return end
		//self.OwnerStillSlowed = false
	//end )
	
	
	--returns true if it hit something valid
	local function CheckTrace( tr )
		if ( tr.Hit ) then 
			self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
			//self.Owner:GetViewModel():SetPlaybackRate( .2 )
		else
			self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
			//self.Owner:GetViewModel():SetPlaybackRate( .2 )
		end
		
		local aim = self.Owner:GetForward()

		if ( IsValid( tr.Entity )) and tr.Entity:IsPlayer() then
			if SERVER then
				//local pitch = ((100 - tr.Entity:Health()) * 2)
				//print(pitch)
				self.Owner:EmitSound( self.Ref.sound_hit_flesh ) 
				//tr.Entity:Knockback( Vector(aim[1], aim[2], 0), 400, 300 )
				
				tr.Entity:AddBuff( "Buff_Snare", self.Ref.duration_snare, false )
				
				if tr.Entity:OnGround() then
					//tr.Entity:SetVelocity( Vector(aim[1], aim[2], 0) * 2000)
					//tr.Entity:Knockback( Vector(aim[1], aim[2], 0), self.Ref.force_ply_ground )
					tr.Entity:Knockback( Vector(aim[1], aim[2], 0) + Vector(0, 0, -50), self.Ref.force_ply_ground )
				else
					//tr.Entity:SetVelocity( Vector(aim[1], aim[2], 0) * 200)
					tr.Entity:Knockback( Vector(aim[1], aim[2], 0), self.Ref.force_ply_air )
				end
			
				if tr.Entity:Team() != self.Owner:Team() then
					local dmginfo = DamageInfo()
						//dmginfo:SetDamage( math.random( self.Ref.damage_low, self.Ref.damage_high ) )
						dmginfo:SetDamage( self.Ref.damage )
						dmginfo:SetDamageForce( self.Owner:GetForward() * 50000 )
						dmginfo:SetInflictor( self )
						dmginfo:SetAttacker( self.Owner )

					tr.Entity:TakeDamageInfo( dmginfo )
					
					
					--special code if the player it hit is disguised as a prop barrel
					if tr.Entity:HowManyOfThisBuff( "Buff_BarrelDisguise" ) > 0 then
						local ply = tr.Entity
						--remove disguise
						if ply:GetActiveWeapon():GetClass() == "tool_decoy" then
							local decoy_wep = ply:GetActiveWeapon()
							decoy_wep:EndDisguise()
							
							--make the player take damage next frame, because their shield needs to be turned off
							timer.Simple( 0, function()
								if not IsValid(self) then return end
								print("applying second damage")
								local dmginfo = DamageInfo()
									dmginfo:SetDamage( self.Ref.damage )
									dmginfo:SetDamageForce( self.Owner:GetForward() * 50000 )
									dmginfo:SetInflictor( self )
									dmginfo:SetAttacker( self.Owner )

								ply:TakeDamageInfo( dmginfo )
							end)
						end
					end
					
				end
				
				
				return true
			end
			
		
		elseif ( IsValid( tr.Entity )) and CheckIfInEntTable(tr.Entity) then
				if SERVER then
						self.Owner:EmitSound( self.Ref.sound_hit_tool ) 
					
					
					local dmginfo = DamageInfo()
						dmginfo:SetDamage( self.Ref.damage )
						dmginfo:SetInflictor( self )
						dmginfo:SetAttacker( self.Owner )

					tr.Entity:TakeDamageInfo( dmginfo )	
					
					--if the ent has a physics object, then knock it back
					if tr.Entity:GetPhysicsObject():IsValid() then
						tr.Entity:Knockback( aim, self.Ref.force_phys )
						//tr.Entity:SetVelocity( Vector(aim[1], aim[2], 0) * 2000)
					end
					
					return true
				end
				
		elseif tr.Entity:IsWorld() then
			if SERVER then
				self.Owner:EmitSound( self.Ref.sound_hit_wall ) 
			end
			
			--put a decal on the wall
			local trdecal = self.Owner:GetEyeTrace()
			local Pos1 = trdecal.HitPos + trdecal.HitNormal
			local Pos2 = trdecal.HitPos - trdecal.HitNormal
			util.Decal("Impact.Concrete", Pos1, Pos2)
			
			return true
		end	
		
		return false
	end

	

	---First check if it directly hit anything
	local tr_line = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Ref.hit_distance,
		filter = self.Owner,
		} )
	
	if CheckTrace( tr_line ) then
		return
	end
	

	--then check if the hull hit anything if it didnt directly
	local tr_hull = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Ref.hit_distance,
		filter = self.Owner,
		mins = self.Owner:OBBMins(),
		maxs = -(self.Owner:OBBMins())
		} )

	//CreatePosMark( (tr_hull.start + tr_hull.mins) )
	//CreatePosMark( (tr_hull.start + tr_hull.maxs) )	

	
	if CheckTrace( tr_hull ) then
		return
	end
	
	
	--new way of checking if hit a player, implement later maybe
	--[[
	local dist = self.Ref.hit_distance_secondary
		
	sphere_ents = ents.FindInSphere( self.Owner:GetShootPos() + self.Owner:GetAimVector()*60, 30 )
	//cone_ents = ents.FindInCone( self.Owner:GetShootPos(),self.Owner:GetAimVector(),300,243 )
	local hit_ent = nil
	for k, ent in pairs( sphere_ents ) do
		if hit_ent == nil then
			if CheckIfInEntTable( ent ) then
				if ent:GetClass() != "dev_posmark" then
					if SERVER then
						print( ent )
					end
					hit_ent = ent
				end
			end
		end
	end

	if SERVER then
		//CreatePosMark( self.Owner:GetShootPos() + self.Owner:GetAimVector()*60 )	
		//CreatePosMark( self.Owner:GetShootPos() + self.Owner:GetAimVector()*60 + Vector(0,0,30) )
		//CreatePosMark( self.Owner:GetShootPos() + self.Owner:GetAimVector()*60 - self.Owner:GetAimVector()*30 )	
		//CreatePosMark( self.Owner:GetShootPos() + self.Owner:GetAimVector()*60 + self.Owner:GetAimVector()*30 )	
	end
	
	if hit_ent != nil then
		--zap effect
		self:DoShootEffect( hit_ent:GetPos() )
		
		if SERVER then
			DoSecondaryEffects( hit_ent )
		end
	end
	]]--
end
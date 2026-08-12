if CLIENT then
	function SWEP:DrawWorldModel()
		if self:GetIfInvis() == true then return end
		
		self:DrawModel()
	end
end


------------------------------------------------------------------------------------------------
--all shared from now on
------------------------------------------------------------------------------------------------

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= ""			
SWEP.Slot				= 0
SWEP.SlotPos			= ""
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false

SWEP.DrawWeaponInfoBox	= false	
SWEP.BounceWeaponIcon   = false		


//makes it so it has a reference table of all its attributes, to be set within the swep code
function SWEP:SetBaseVars()
	self.Ref = self:GetRef()
	
	//official vars
	self.PrintName = self.Ref.print_name
	self.Primary.Automatic = self.Ref.automatic
	self.Primary.Delay = self.Ref.rate_of_fire
	self.Secondary.Delay = self.Ref.rate_of_fire_secondary
	self.BaseDelay = self.Ref.rate_of_fire
	self.ViewModel			= self.Ref.v_model
	self.WorldModel			= self.Ref.w_model
	
	self.Primary.ClipSize		= self.Ref.clip_size
	self.Primary.DefaultClip	= self.Ref.clip_size
	
	//custom vars
	self.ThrownEnt = self.Ref.thrown_ent
	self.ThrowForce = self.Ref.throw_force
	self.ColorSkin = self.Ref.color_skin
	self.ShootSound = self.Ref.shoot_sound
	self.ReloadSound = self.Ref.reload_sound
	self.ReloadTime = self.Ref.reload_time
	
	//custom vars if its a gun
	self.BulletsPerShot = self.Ref.bullets_per_shot
	self.BulletDamage = self.Ref.bullet_damage
	self.AimCone = self.Ref.aim_cone
	
	//if its not a limited ammo item, then set its default clip to be full
	if self.Ref.class == "gun" then
		self:SetClip1(self.Primary.ClipSize)
	end
	
	
	if self.Ref.holdtype != nil then
		self:SetWeaponHoldType( self.Ref.holdtype )
	end
	
	//if self.Ref.infinite == true then
		//self:SetClip1(self.Primary.ClipSize)
	//end
	
	//sets the slot of the weapon in the players inventory
	if !CLIENT then return end
		self.Slot = Bought_Slot_To_Add_Wep_To --sets this var in cl_buymenu, to go from client to client
end



function SWEP:Initialize()
	self:SetBaseVars()
	
	self:SpecialInit()
end



function SWEP:Reload()
	//if self.Ref.infinite == false then return end
	if self.Ref.class != "gun" then return end
	
	if self:Clip1() < self.Primary.ClipSize and self.Reloading != true then

		--try to figure out how to slow down player reload animation, then add this back
		--self.Owner:SetAnimation( PLAYER_RELOAD )
	
		--this is for clients displaying, "reloading" over the player's head
		//self:SetIfReloading(true)
	
		//self.Owner:TTG_Slow(true)
		//self.Owner:ReloadSlow(true)
		self.BuffSlot_Reload = self.Owner:AddBuff( "Buff_SlowReload" )
		
		//self.Owner:SetAnimation( PLAYER_LEAVE_AIMING )
		//self:SetWeaponHoldType( "fist" )
		//self.Owner:DoReloadEvent( )
		
		if self.Ref.uses_grenade_model == true then
			self:SendWeaponAnim( ACT_VM_PULLBACK_LOW  )
		else
			self:SendWeaponAnim( ACT_VM_RELOAD )
		end
		
		self.Owner:GetViewModel():SetPlaybackRate( self.Ref.anim_time )
		
		self.ReloadFinishTime = CurTime() + self.ReloadTime
		self.Reloading = true
		
		self:SetNextPrimaryFire( CurTime() + self.ReloadTime )
		self:SetNextSecondaryFire( CurTime() + self.ReloadTime )
	end
end

function SWEP:Think()
	if !SERVER then return end
	
	//local norm_aim = self.Owner:GetAimVector()
	//print(norm_aim)
	
	//if self.Ref.infinite == false then return end
	if not self.Ref.class == "gun" then return end
	
	if self.Reloading then
		if CurTime() >= self.ReloadFinishTime then
			self:SetClip1(self.Primary.ClipSize)
			self.Reloading = false
			self:SendWeaponAnim( ACT_VM_IDLE  )
			
			--this is for clients displaying, "reloading" over the player's head
			//self:SetIfReloading(false)
			
			//self.Owner:TTG_Slow(false)
			//self.Owner:ReloadSlow(false)
			self.Owner:RemoveBuff_BySlot( self.BuffSlot_Reload )
			
			self.Owner:EmitSound( self.ReloadSound )
		end
	end
	
end

function SWEP:Holster( wep )
	//if self.Ref.infinite == false then 
		//return true
	//end
	
	if not self.Ref.class == "gun" then 
		return true
	end
	
	
	--this is for clients displaying, "reloading" over the player's head
	//self:SetIfReloading(false)
	
	//self.Owner:TTG_Slow(false)
	//self.Owner:ReloadSlow(false)
	if self.Reloading then
		self.Owner:RemoveBuff_BySlot( self.BuffSlot_Reload )
	end
	
	self.Reloading = false
	self:SetNextPrimaryFire(CurTime())
	self:SetNextSecondaryFire(CurTime())
	return true
end


function SWEP:ShouldDropOnDie()
	return false
end






function SWEP:ThrowEnt()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.ThrownEnt)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		

		obj.TTG_Team = self.Owner:Team()
		obj.Creator = self.Owner
		obj.CreatorSwep = self
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj:SetEntTeamForClient()
		
		obj.TTG_Angles = (self.Owner:EyeAngles())
	
	//self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim( ACT_VM_THROW );
	timer.Simple( 0.4, function()
		if not IsValid(self) then return end
		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
	end )
	
	//self.Owner:DoAttackEvent( )
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  self.ThrowForce)
end


function SWEP:OwnerGiveBuff()
	if (!SERVER) then return end

	if self.Ref.owner_give_buff == "speed" then
	
		--if the speedbuff is successfully given to the player then take away 1 ammo of it
		if (self.Owner:TempSpeedBuff())== true then
			self:TakePrimaryAmmo(1)
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		elseif (self.Owner:TempSpeedBuff()) == false then
			self.Owner:PrintMessage( HUD_PRINTTALK, "Can't apply speed buff at this time")
		end
		
	elseif self.Ref.owner_give_buff == "invis" then
	
		--if the speedbuff is successfully given to the player then take away 1 ammo of it
		if (self.Owner:TempInvisBuff())== true then
			self:TakePrimaryAmmo(1)
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		elseif (self.Owner:TempInvisBuff()) == false then
			self.Owner:PrintMessage( HUD_PRINTTALK, "Can't apply invisibility at this time")
		end
		
	end
end


function SWEP:OnRemove( )
	if self.ChargingSound != nil then
		self.ChargingSound:Stop()
	end
end

	


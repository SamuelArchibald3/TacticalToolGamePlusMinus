AddCSLuaFile("tool_slowstick.lua")

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
SWEP.ViewModel		= "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel		= "models/weapons/w_stunbaton.mdl"
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
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "None"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true			// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"

SWEP.HitDistance = 80

SWEP.PlayerHeal = 2
SWEP.BuildableHeal = 5


local SwingSound = Sound( "Weapon_Crowbar.Single" )
local HitSound = Sound( "physics/concrete/concrete_block_impact_hard" .. math.random(1, 3) .. ".wav" )
local FleshSound = Sound( "Flesh.ImpactHard" )
local BuildableHitSound = Sound("Metal_Box.BulletImpact")





//makes it so it has a reference table of all its attributes, to be set within the swep code
function SWEP:SetBaseVars()
	self.Ref = self:GetRef()
	
	//official vars
	self.PrintName = self.Ref.print_name
	self.Primary.Automatic = self.Ref.automatic
	self.Primary.Delay = self.Ref.rate_of_fire
	self.ViewModel			= self.Ref.v_model
	self.WorldModel			= self.Ref.w_model
	
	//sets the slot of the weapon in the players inventory
	if !CLIENT then return end
		self.Slot = Bought_Slot_To_Add_Wep_To --sets this var in cl_buymenu, to go from client to client
end



function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	
	self:SetBaseVars()
	self:SpecialInit()
end


function SWEP:PrimaryAttack()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	
	if ( !SERVER ) then return end

	self.Owner:EmitSound( SwingSound )
	self:SwingMelee( )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay	 )
end



function SWEP:SecondaryAttack()
	return
end







function SWEP:SwingMelee( )
	if !SERVER then return end
	
	--returns true if it hit something valid, then heals the thing
	local function CheckTrace( tr )
		if ( tr.Hit ) then 
			self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		else
			self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
		end
		
		local aim = self.Owner:GetForward() 

		if ( IsValid( tr.Entity )) and tr.Entity:IsPlayer() then
			self.Owner:EmitSound( self.Ref.slow_sound ) 
			
			tr.Entity:BuffForDuration_SpecialSlow( self.Ref.slow_duration )
			return true
			
				
		elseif tr.Entity:IsWorld() then
			self.Owner:EmitSound( HitSound ) 
			return true
		end	
		
		return false
	end

	

	---First check if it directly hit anything
	local tr_line = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		} )
	
	if CheckTrace( tr_line ) then
		return
	end
	

	--then check if the hull hit anything if it didnt directly
	local tr_hull = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mins = self.Owner:OBBMins(),
		maxs = -(self.Owner:OBBMins())
		} )
	
	if CheckTrace( tr_hull ) then
		return
	end
end
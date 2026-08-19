AddCSLuaFile( "tool_decoy.lua" )

SWEP.Base = "base_ttgtool"

SWEP.PlayerIsDecoy = false

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end

	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootEffects( self )
	
	if (!SERVER) then return end
		self.Owner:EmitSound( self.ShootSound )
		self:ThrowEnt()
end


if not SERVER then return end


--disallow the player from switching from this weapon if he is disguised as a decoy
function SWEP:Holster( wep )
	if self.PlayerIsDecoy == false then
		return true
	else
		return false
	end
end



--[[
	Barrel disguise

	This used to be Owner:SetModel( barrel ), which cannot work properly. A player
	is drawn through the player animation system, and this gamemode overrides none
	of it - no CalcMainActivity, no UpdateAnimation anywhere - so a prop model with
	no player skeleton was posed as though it had one and came out wrong.

	So the player is hidden the way the invisibility buff already hides one, with
	RENDERMODE_NONE, and a real barrel prop is parented to them instead. A
	prop_dynamic holding a barrel model can only ever render as a barrel.

	The prop is unsolid on purpose: the player's own hull keeps doing collision
	and taking hits exactly as before, so the disguise is cosmetic and nothing
	about being shot changes.
--]]

function SWEP:StartBarrelDisguise()
	local ply = self.Owner
	if not IsValid( ply ) then return end

	--never leave a second prop behind if this is somehow called twice
	self:StopBarrelDisguise()

	ply:SetRenderMode( RENDERMODE_NONE )

	local barrel = ents.Create( "prop_dynamic" )
	if not IsValid( barrel ) then return end

	barrel:SetModel( self.Ref.decoy_model )
	barrel:SetPos( ply:GetPos() )

	--the one and only time its angle is set: facing where the player was when
	--they dropped into the disguise, and fixed there from then on
	barrel:SetAngles( Angle( 0, ply:EyeAngles().y, 0 ) )
	barrel:Spawn()

	--Deliberately NOT parented. Parenting drags the barrel through the player's
	--full orientation, so looking up and down tilted it over. Think drives the
	--position instead and takes only the yaw, keeping the barrel upright.
	barrel:SetSolid( SOLID_NONE )
	barrel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	barrel:SetRenderMode( RENDERMODE_TRANSCOLOR )
	barrel:SetColor( self.TeamColor )

	self.DisguiseProp = barrel

	--a floating toolgun beside a barrel gives the whole thing away. Holster is
	--blocked while disguised, so the active weapon stays this one, but capture it
	--rather than assume so the same entity is the one restored.
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) then
		wep:SetNoDraw( true )
		self.HiddenWeapon = wep
	end
end


function SWEP:StopBarrelDisguise()
	if IsValid( self.DisguiseProp ) then
		self.DisguiseProp:Remove()
	end
	self.DisguiseProp = nil

	if IsValid( self.HiddenWeapon ) then
		self.HiddenWeapon:SetNoDraw( false )
	end
	self.HiddenWeapon = nil

	local ply = self.Owner
	if IsValid( ply ) then
		ply:SetRenderMode( RENDERMODE_NORMAL )
		ply:SetColor( Color( 255, 255, 255, 255 ) )
	end
end


--the weapon going away must not leave someone invisible - this is the path that
--runs when tools are stripped at the start of every round
function SWEP:OnRemove()
	self:StopBarrelDisguise()

	if self.BaseClass and self.BaseClass.OnRemove then
		self.BaseClass.OnRemove( self )
	end
end


--The barrel is carried here rather than parented. Parenting passed on the
--player's whole orientation, so it tipped over when they looked up or down and
--turned with them when they looked around - neither of which a barrel does.
function SWEP:Think()
	if SERVER and IsValid( self.DisguiseProp ) and IsValid( self.Owner ) then
		--position only. The angle is set once when the disguise starts and left
		--alone: a barrel that swivels to follow whoever is looking at it gives
		--the disguise away immediately.
		self.DisguiseProp:SetPos( self.Owner:GetPos() )
	end

	--the base drives reloading and other per-tick tool work
	if self.BaseClass and self.BaseClass.Think then
		self.BaseClass.Think( self )
	end
end


function SWEP:EndDisguise()
	if self.PlayerIsDecoy == true then
		self:StopBarrelDisguise()

		self.Owner:RemoveBuff_BySlot( self.BuffSlot1 )
		self.Owner:RemoveBuff_BySlot( self.BuffSlot2 )
		
		if self.BuffSlot3 != nil then
			self.Owner:RemoveBuff_BySlot( self.BuffSlot3 )
		end
		
		if self.BuffSlot4 != nil then
			self.Owner:RemoveBuff_BySlot( self.BuffSlot4 )
		end
		
		self.PlayerIsDecoy = false
	
		self.EndedEarly = true
	end
end




function SWEP:SecondaryAttack()
	//print("triggered")
	if self.CanSecondaryFire == false then return end
	
	if self.Owner:Team() == TEAM_BLUE then
		self.TeamColor = Color( 54, 224, 254, 255 )
	elseif self.Owner:Team() == TEAM_RED then
		self.TeamColor = Color( 255, 118, 118, 255 )
	end
		
	if self.PlayerIsDecoy == false then
		self:StartBarrelDisguise()
		
		self.BuffSlot1 = self.Owner:AddBuff( "Buff_BarrelDisguise" )
		self.BuffSlot2 = self.Owner:AddBuff( "Buff_Snare" )
		self.BuffSlot3 = nil
		self.BuffSlot4 = nil
		
		self.PlayerIsDecoy = true
		self.CanSecondaryFire = false
		self.EndedEarly = false
		
		timer.Simple( self.Ref.time_to_hunker, function()
			if not IsValid(self) then return end
			if self.EndedEarly then return end
				self.CanSecondaryFire = true
				self.BuffSlot3 = self.Owner:AddBuff( "Buff_HunkerSuper" )
				self.BuffSlot4 = self.Owner:AddBuff( "Buff_ShieldSuper" )
		end)
		
		
	elseif self.PlayerIsDecoy == true then
		self:StopBarrelDisguise()
		
		self.Owner:RemoveBuff_BySlot( self.BuffSlot1 )
		self.Owner:RemoveBuff_BySlot( self.BuffSlot2 )
		
		if self.BuffSlot3 != nil then
			self.Owner:RemoveBuff_BySlot( self.BuffSlot3 )
		end
		
		if self.BuffSlot4 != nil then
			self.Owner:RemoveBuff_BySlot( self.BuffSlot4 )
		end
		
		self.PlayerIsDecoy = false
		
	end
end


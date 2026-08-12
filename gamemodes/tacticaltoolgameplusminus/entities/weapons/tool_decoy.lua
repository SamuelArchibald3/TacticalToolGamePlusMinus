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



function SWEP:EndDisguise()
	if self.PlayerIsDecoy == true then
		self.Owner:SetModel( self.Owner.BaseModel )	
		self.Owner:SetColor( Color( 255, 255, 255, 255 ) ) 

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
		self.Owner:SetModel( self.Ref.decoy_model )
		//self.Owner:TTG_Freeze( true )
		//self.Owner:Ensnare( true )
		
		self.Owner:SetColor( self.TeamColor ) 
		//self.Owner:BarrelDisguise( true )
		
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
		self.Owner:SetModel( self.Owner.BaseModel )
		//self.Owner:TTG_Freeze( false )
		//self.Owner:Ensnare( false )
		
		self.Owner:SetColor( Color( 255, 255, 255, 255 ) ) 
		//self.Owner:BarrelDisguise( false )
		
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


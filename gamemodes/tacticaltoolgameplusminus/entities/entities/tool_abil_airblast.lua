ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:DoAbility()
	if self.Cooldown == true then
		self:CooldownSound()
	return 
	end

	if GetTeamRole( self.Owner:Team() ) == "Attacking" then
		if G_CurrentPhase == "GameSetup" then
			return 
		elseif G_CurrentPhase == "DefendersBuy" then
			return 
		elseif G_CurrentPhase == "AttackersBuy" then
			return 
		elseif G_CurrentPhase == "Planning" then
			return 
		elseif G_CurrentPhase == "Setup" then
			return 
		end
	end
	//ability code
	------------------------------------------------------------------------------------------------
	
	self.Owner:EmitSound( self.Ref.shoot_sound )
	
	local selfvector = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * self.Ref.radius)

	local orgin_ents = ents.FindInSphere( selfvector, self.Ref.radius );

	
	local aim = self.Owner:GetForward()
	
	for k, ent in pairs( orgin_ents ) do
	
		--blast back a player
		if ent:IsValidGamePlayer() and ent != self.Owner then
			//ent:SetVelocity( self.Owner:GetAimVector() * self.Ref.force_player_blast + Vector(0, 0, 500))
			
			--if the player was recently airblasted ( within last 1 second ), then dont allow airblast
			if ent:HowManyOfThisBuff( "Buff_Airblasted" ) <= 0 then
				ent:Knockback( Vector(aim[1], aim[2], 0), self.Ref.force_player_blast, self.Ref.force_player_blast_vert )
				ent:AddBuff( "Buff_Airblasted", 1 )
			end
		--blast back physics ent
		elseif ent:GetPhysicsObject( ):IsValid() and ent != self.Owner then
		
			local phys = ent:GetPhysicsObject()
				phys:SetVelocity(self.Owner:GetAimVector():GetNormalized() *  self.Ref.force_physics_blast)
				--self.Ref.force_physics_blast
				
				--if going to use :knockback(), need to add a vertical force
				//ent:Knockback( self.Owner:GetAimVector(), self.Ref.force_physics_blast )
		end
	
	
	
		--[[
		--special var to give to stuff i dont want to be airblastable for some reason
		if ent.CanAirblast != false then
		
			--blast back a player
			if ent:IsPlayer() and ent != self.Owner then
				if ent:HowManyOfThisBuff( "Buff_Hunker" ) > 0 then
					ent:SetVelocity( self.Owner:GetAimVector() * (self.Ref.force_player_blast*.3) + Vector(0, 0, 150))
				else
					ent:SetVelocity( self.Owner:GetAimVector() * self.Ref.force_player_blast + Vector(0, 0, 500))
				end
			--blast back physics ent
			elseif ent:GetPhysicsObject( ):IsValid() and ent != self.Owner then
			
				local phys = ent:GetPhysicsObject()
					phys:SetVelocity(self.Owner:GetAimVector():GetNormalized() *  self.Ref.force_physics_blast)
			end
		end
		]]--
		
		
	end

	------------------------------------------------------------------------------------------------
	//ability code
	
	
	self:InitiateCooldown()
end
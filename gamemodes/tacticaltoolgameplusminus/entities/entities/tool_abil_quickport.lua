ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------



ENT.Step = 1



function ENT:DoAbility()
	if self.Cooldown == true then
		self:CooldownSound()
	return 
	end
	
	--the quick port cannot be used during setup by attackers, this is to fix people shooting it through the spawn exit door
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
	
	if self.Step == 1 then
	
		self.Owner:EmitSound( self.Ref.sound_shoot )
		self:ThrowEnt()
		self.Step = 2
		
		
	elseif self.Step == 2 then
		local step2successful = true
	
		--teleport to the quickport
		if IsValid( self.PreviousEnt ) then
			if self.PreviousEnt.Built != true then return end
		
			local portpos = self.PreviousEnt:GetPos()
				portpos:Add(Vector(0,0,32))
				
			self.Owner:SetPos( portpos )
			
			self.PreviousEnt:EmitSound( self.Ref.sound_teleport )
			
			self.PreviousEnt:Remove()
			
		--if the port was destroyed in the mean time then redo step 1
		else
			self.Owner:EmitSound( self.Ref.sound_shoot )
			self:ThrowEnt()
			self.Step = 2
			
			step2successful = false
		end
		
		
		if step2successful == true then
			self.Step = 1
			self:InitiateCooldown()
		end
	end
	
	--Remove old first aid
	
	------------------------------------------------------------------------------------------------
	//ability code
	
	
	
end



function ENT:ThrowEnt()
	if (!SERVER) then return end
	
	local obj = ents.Create(self.Ref.thrown_ent)

		local tr = self.Owner:GetEyeTrace();
		if ( tr.StartPos:Distance( tr.HitPos ) < 64 ) then 
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()))
		else
			obj:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 32))
		end
		

		obj.TTG_Team = self.Owner:Team()
		obj.Creator = self.Owner
		
		obj:SetOwner(self.Owner)
		obj:SetAngles( self.Owner:EyeAngles() )
		obj:Spawn()
		
		obj.TTG_Angles = (self.Owner:EyeAngles())
	
	//self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local phys = obj:GetPhysicsObject()
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() *  self.Ref.throw_force)
		
	self.PreviousEnt = obj
end
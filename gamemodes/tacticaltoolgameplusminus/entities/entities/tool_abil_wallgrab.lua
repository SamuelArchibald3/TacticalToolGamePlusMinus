ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

ENT.Step = 1



function ENT:DetachJump()
	if self.SnareSlot != nil then
		self.Owner:RemoveBuff_BySlot( self.SnareSlot )
	end
	
	if IsValid( self.CurAttachProp ) then
		self.CurAttachProp:Remove()
	end
	
	self.Owner:SetMoveType( MOVETYPE_WALK )
	
	local aimvec = self.Owner:GetAimVector()
	self.Owner:SetVelocity(   (Vector(aimvec[1], aimvec[2], 0)*200) + Vector(0,0,300)   )
	//self.Owner:SetVelocity(   Vector(0,0,300)   )
end




function ENT:DoAbility()
	

	local function NearWall( ply )
		local tr = self.Owner:GetEyeTrace()
		if ( tr.Hit ) then 
			if ( tr.StartPos:Distance( tr.HitPos ) < 45) and tr.Entity:IsWorld() then 
				return true
			end
		end
		return false
	end
	
	if self.Step == 1 then
		if self.Cooldown == true then
			self:CooldownSound()
			return 
		end
	
		if NearWall( self.Owner ) then
			self.Owner:EmitSound( self.Ref.sound_grab )

			--attach to wall
			self.CurAttachProp = ents.Create( "ent_wallgrabber" )
			local eyepos_lower = self.Owner:EyePos() - Vector(0,0,35)
			local aimvec = self.Owner:GetAimVector()
			self.CurAttachProp:SetPos( eyepos_lower + (Vector(aimvec[1], aimvec[2], 0)*30) )
			

			
				self.SnareSlot = self.Owner:AddBuff( "Buff_Snare" )
				//print( self.Owner:GetMoveType() )
				self.Owner:SetMoveType( MOVETYPE_NONE )
				self.Attached = true
			
			self:InitiateCooldown()
			
			self.Step = 2
		else
			self:CooldownSound()
		end
		
		
	elseif self.Step == 2 then
		self:DetachJump()
		self.Step = 1
	end

	
	
	
end




--[[
function ENT:Think()
	if self.Attached != true then return end
	
	
	
	self:NextThink( CurTime() + self.Ref.think_rate )
	return true
end
]]--
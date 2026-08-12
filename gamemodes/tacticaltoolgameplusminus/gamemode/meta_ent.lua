/*---------------------------------------------------------
	ENT Meta Table
---------------------------------------------------------*/

local TTGEnt = FindMetaTable("Entity")







function TTGEnt:GetRef()
	return EntReference(self:GetClass())
end

//abilities are in the tool table, since theyre more similar to sweps than ents
function TTGEnt:GetAbilityRef()
	return ToolReference(self:GetClass())
end

//returns true if the ent is in its built form
function TTGEnt:IsBuilt()
	if self.Built == true then
		return true
	else
		return false
	end
end







--methods so the client can know what team an ent is
function TTGEnt:SetEntTeamForClient()
	if self.TTG_Team != nil then
		self:SetNWInt( "Team", self.TTG_Team ) 
	end
end

function TTGEnt:GetEntTeamForClient()
	return self:GetNWBool( "Team", 5 ) 
end




--all tool ents will run this on startup, so i can easily add more stuff to them
function TTGEnt:SpecialEntInit()

	--set the team so the client hud can display stuff like markings depending on what team the ent is
	self:SetEntTeamForClient()
	
end





--Checks if the ent is a player whos alive playing the game currently
function TTGEnt:IsValidGamePlayer()
	if not self:IsPlayer() then return false end
	if not self:Alive() then return false end
	if self:GetObserverMode( ) != OBS_MODE_NONE then return false end
	if self:Team() == TEAM_SPEC then return false end
	
	return true
end


--Gets what team the ent is on, doesnt matter if its a player or entity
--SERVER only
function TTGEnt:GetTeam()
	if self:IsPlayer() then
		return self:Team()
	elseif CheckIfInEntTable( self ) then
		return self.TTG_Team
	end
	print("error, ent has no team")
end



--takes a direction, a horizontal force and an optional vertical force
--pushes the ent in that direction
function TTGEnt:Knockback( dir, horforce, vertforce )
	--this var can be applied to certain entities to disable kbockack effects for a time
	if self.CanKnockback == false then return end

	if vertforce == nil then
		vertforce = 0
	end

	if self:IsPlayer() then
		local hunker = 0
		if self:HowManyOfThisBuff( "Buff_Hunker" ) > 0 then
			hunker = 1
		elseif self:HowManyOfThisBuff( "Buff_HunkerSuper" ) > 0 then
			hunker = 2
		end
		
		if hunker == 1 then
			--lessen the knockback by a lot because they have hunker
			self:SetVelocity( Vector( dir.x, dir.y, 0 ) * (horforce*.2) + Vector( 0, 0, (vertforce*.2) ) )
			return 
		elseif hunker == 2 then
			--do nothing because they have super hunker
			return 
		end
		
		self:SetVelocity( Vector( dir.x, dir.y, 0 ) * horforce + Vector( 0, 0, vertforce ) )

			
	elseif self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():SetVelocity( Vector( dir.x, dir.y, 0 ) * horforce + Vector( 0, 0, vertforce ) )
		
	end
	
	
	--when the boulder is knocked back, it makes the player in control of it unable to control it for a short period
	if self:GetClass() == "ent_boulder" then
		self:BreakControl()
	end
end





--stuff used by revealer
function TTGEnt:SetIfInvisible(bool)
	self:SetNWBool("Invisible", bool) 
end

function TTGEnt:GetIfInvisible()
	return self:GetNWBool("Invisible", false) 
end


--[[
function TTGEnt:SetIfMarked(bool)
	:GetIfMarked()
	self:SetNWBool("Marked", bool) 
end

function TTGEnt:GetIfMarked()
	return self:GetNWBool("Marked", false) 
end
]]--


--Obsolete

function TTGEnt:Add_RevealerMarker()
	local prevnum = self:GetNWInt("RevealerMarkers", 0) 
	self:SetNWInt("RevealerMarkers", prevnum + 1) 
end

function TTGEnt:Remove_RevealerMarker()
	local prevnum = self:GetNWInt("RevealerMarkers", 0) 
	self:SetNWInt("RevealerMarkers", prevnum - 1)
end

function TTGEnt:ResetAll_RevealerMarker()
	self:SetNWInt("RevealerMarkers", 0) 
end

function TTGEnt:Get_RevealerMarkerNum()
	return self:GetNWInt("RevealerMarkers", 0) 
end





--Used by barrier
function TTGEnt:AddTeamBarrierNoCollide()
	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "ent_barrier" and self.TTG_Team == ent.TTG_Team then
			constraint.NoCollide( self, ent, 0, 0 )
		end
	end
end



function TTGEnt:AddSpawnDoorNoCollide()
	--if the creator is not on attacker, this will not run
	if GetTeamRole( self.Creator:Team() ) != "Attacking" then return end

	for k,ent in pairs(ents.GetAll()) do
		if ent:GetClass() == "func_brush" and ent:GetName() == BRUSH_DOOR_NAME then
			constraint.NoCollide( self, ent, 0, 0 )
		end
	end
end








--[[
//Add this later
//function TTGEnt:DisablePropCollisions( propteam )	
//end

if not SERVER then return end

local function ShouldPropCollideHook( ent1, ent2 )
	--Barrier collision
	if ent1:GetClass() == "ent_barrier" or ent2:GetClass() == "ent_barrier" then
		local barrier_ent = nil
		local collider_ent = nil
		if ent1:GetClass() == "ent_barrier" and ent1.Built == true then
			barrier_ent = ent1
			collider_ent = ent2
		elseif ent2:GetClass() == "ent_barrier" and ent2.Built == true then
			barrier_ent = ent2
			collider_ent = ent1
		end
		if barrier_ent:GetClass() == "ent_barrier" and collider_ent == "ent_barrier" then
			return true
		end
		
		if collider_ent:IsPlayer() then
			--dont collide if the player is on the barrier's team
			if barrier_ent.TTG_Team == collider_ent:Team() then
				return false
			end
		end
	end
	
	return true
end
hook.Add( "ShouldCollide", "ShouldPropCollideHook", ShouldPropCollideHook )

]]--
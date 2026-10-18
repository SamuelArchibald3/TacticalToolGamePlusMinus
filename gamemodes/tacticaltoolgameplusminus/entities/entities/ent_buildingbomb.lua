AddCSLuaFile("ent_buildingbomb.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------




local angle = Angle( 0, 0, 0 )


//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	
	self.Model = self.Ref.model
	self.IMagnitude = self.Ref.imagnitude
	self.IRadiusOverride = self.Ref.iradiusoverride
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()
	
	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_NONE )
	
	--this ent comes from a weapon tool so it does not collide with spawn doors
	self:AddSpawnDoorNoCollide()
end


function ENT:PhysicsCollide(data, phys)
	--Where the bomb is now, which is its physics body. self:GetPos() is still
	--where it was a tick ago - the entity catches up with its body after the
	--step this collision came out of - and at a throw's 850 or so a second that
	--is 12 units back along its flight, which set the blast off 12 units short
	--of what it hit.
	local pos = phys:GetPos()
	local hitent = data.HitEntity

	--this makes it so physics damage wont be taken
	phys:EnableMotion(false)

	self:StartEffect( pos )

	--It used to clear its owner here, after StartEffect. Its owner is the
	--explosion now, which is what keeps it out of its own blast - see there.
end


function ENT:KnockBackStuff()

	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.force_radius );

	for k, ent in pairs( orgin_ents ) do
	
		--special var to give to stuff i dont want to be knockbackable for some reason
		if ent.CanAirblast != false then
		
			//local self_vec = self:GetPos()
			//local target_vec = ent:GetPos()
			
			local knock_ang = ( ent:GetPos() - self:GetPos() ):GetNormal()
			local rot = Angle(0, 0, 0)
			knock_ang:Rotate( rot )
		
			--blast back a player
			if ent:IsPlayer() and ent != self:GetOwner() then
				
				--player knockback turned off for now
				--[[
				if ent:OnGround() then
					ent:SetVelocity( knock_ang * self.Ref.force_player_blast + Vector(0, 0, 400))
				else
					ent:SetVelocity( knock_ang * self.Ref.force_player_blast )
				end
				]]--
				break
				
			--blast back physics ent
			elseif ent:GetPhysicsObject( ):IsValid() then
			
				//local phys = ent:GetPhysicsObject()
					//phys:SetVelocity( knock_ang *  self.Ref.force_physics_blast )
					//self.Ref.force_physics_blast
				ent:Knockback( knock_ang, self.Ref.force_physics_blast )
				
			end
		end
	end
end

//does the affect at the pos position
--
--Once, whatever happens.
--
--PhysicsCollide called this and then self:Remove(), but Remove does not take
--effect until the end of the tick, and phys:EnableMotion( false ) inside a
--physics callback is not guaranteed to stop the bomb there and then - that is
--what BUG-9 is about. So a bomb that touched two things before it was really
--gone arrived here twice and put two explosions on the same spot.
--
--A player is the case that made it happen: a wall is one contact, a player is a
--body you clip and carry on past into the floor behind them. Which is why a
--building took close to double damage from a bomb that hit somebody on the way
--in. Measured at two explosions from two collisions before this guard, one
--after - see explode_once.lua.
--
--The hitply argument this used to take was never read.
function ENT:StartEffect( pos )
	if self.Exploded == true then return end
	self.Exploded = true

	local explosion = ents.Create( "env_explosion" )		///create an explosion and delete the prop
		explosion:SetPos( pos )
		explosion:SetOwner( self.Creator )
		explosion:Spawn()
		explosion:SetKeyValue( "iRadiusOverride", self.IRadiusOverride )
		explosion:SetKeyValue( "iMagnitude", self.IMagnitude )
		explosion:SetKeyValue("spawnflags","64")
		explosion:Fire( "Explode", 0, 0 )
		explosion.DamageBuildingOnly = true
		
	self:EmitSound(self.Ref.sound_explode)
	self:KnockBackStuff()

	--Out of its own blast. The bomb is still here when the explosion goes off -
	--Remove waits for the end of the tick - and the engine's RadiusDamage looks
	--for a clear line from the blast to each building's middle. That line ran
	--through the bomb, which counted as something in the way: the damage was
	--measured to the building's middle instead of its surface, then cut by
	--the bomb's mass over 350, 200 of it. A direct hit on a box did 18 where it
	--should do 52, on a boulder 14.
	--
	--The line skips whatever is owned by the explosion (PassServerEntityFilter,
	--"don't clip against own missiles"). After KnockBackStuff, which reads the
	--owner as the thrower to leave out.
	self:SetOwner( explosion )

	self:Remove()
end


--[[

function ENT.DisablePlyDamage( ent, dmginfo )
	if dmginfo:GetInflictor() == self and ent:IsPlayer() then
		dmginfo:ScaleDamage( 0 )
	end
end
hook.Add("EntityTakeDamage", "DisablePlyDamage", ENT.DisablePlyDamage)

]]--
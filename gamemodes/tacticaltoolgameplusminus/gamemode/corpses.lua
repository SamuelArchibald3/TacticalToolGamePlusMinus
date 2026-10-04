/*---------------------------------------------------------
	Corpses
---------------------------------------------------------*/

--A body the server owns, where everybody sees it.
--
--The engine's own death ragdoll is simulated by each client for itself. The
--server only ever had a point where the player fell, and every screen threw
--the body around on its own - so the same corpse could lie in different places
--for different players, and Cannibalism, which can only ask the server, said a
--body somebody was standing on was too far away. Here the server makes the
--body as a prop_ragdoll, posed as they fell and moving as they were, and
--simulates it. Clients just draw it.
--
--Players walk through it, like the old one: COLLISION_GROUP_DEBRIS collides
--with the world and not with player movement. A plain trace does still hit it,
--so a shot can land on a body.
--
--It goes when they spawn again - a new round, a revive by Rewind - when they
--leave, and when somebody eats it.
--
--A player model with no ragdoll gets the engine's body instead (see
--CreateCorpse), which the server only knows the landing point of.
--
--This is one of two corpse styles - ttg_var_corpses, CORPSE_STYLE - and not
--the default. "gravestone" leaves the engine's body as it always was and marks
--where to eat it with a gravestone where the player last stood
--(gravestones.lua). This is "body". Cannibalism eats whichever is there, so a
--switch mid-round strands nothing.

local TTGPlayer = FindMetaTable( "Player" )


--Where a corpse is: its pelvis, which is what the root physics object is,
--rather than the entity's origin, which only catches up after a physics step.
function TTG_CorpsePos( corpse )
	local phys = corpse:GetPhysicsObject()
	if IsValid( phys ) then return phys:GetPos() end

	return corpse:GetPos()
end


if CLIENT then
	--The PlayerColor material proxy asks the entity it is drawing for
	--GetPlayerColor, and a prop_ragdoll has never heard of a player. Models
	--that tint by it would come out grey without this.
	hook.Add( "OnEntityCreated", "TTG_CorpsePlayerColor", function( ent )
		if ent:GetClass() != "prop_ragdoll" then return end

		ent.GetPlayerColor = function( self )
			return self:GetNW2Vector( "TTG_PlayerColor", Vector( 1, 1, 1 ) )
		end
	end )

	return
end


--What the base gamemode's DoPlayerDeath does, with the corpse style choosing
--the body: the server's own, or the engine's as it always was - with a
--gravestone, which gravestones.lua puts down from a DoPlayerDeath hook.
function GM:DoPlayerDeath( ply, attacker, dmginfo )
	if not dmginfo:IsDamageType( DMG_REMOVENORAGDOLL ) then
		if TTG_CorpseStyle() == "body" then
			ply:CreateCorpse( dmginfo )
		else
			ply:CreateRagdoll()
		end
	end

	ply:AddDeaths( 1 )

	if IsValid( attacker ) and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end
	end
end


function TTGPlayer:CreateCorpse( dmginfo )
	self:RemoveCorpse()

	--A model with no ragdoll in it - a custom player model can be like that -
	--would come out as a statue with no physics at all. The engine's own body
	--is better than that, and its server half still sits where they fell, so
	--it can still be eaten from there.
	if not util.IsValidRagdoll( self:GetModel() ) then
		self:CreateRagdoll()
		self.TTG_Corpse = self:GetRagdollEntity()

		return self.TTG_Corpse
	end

	local corpse = ents.Create( "prop_ragdoll" )
	if not IsValid( corpse ) then return end

	corpse:SetPos( self:GetPos() )
	corpse:SetAngles( self:GetAngles() )
	corpse:SetModel( self:GetModel() )
	corpse:SetSkin( self:GetSkin() )

	for _, group in pairs( self:GetBodyGroups() ) do
		corpse:SetBodygroup( group.id, self:GetBodygroup( group.id ) )
	end

	corpse:SetNW2Vector( "TTG_PlayerColor", self:GetPlayerColor() )

	corpse:Spawn()
	corpse:Activate()
	corpse:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

	--Posed bone by bone as they fell, moving as they were, and carrying the
	--hit. The knockback is spread over the whole body by mass: the sniper and
	--the charge shot hit hard precisely so bodies go flying, and pushing one
	--bone with all of it would tear the ragdoll about instead.
	local count = corpse:GetPhysicsObjectCount()

	local mass = 0
	for i = 0, count - 1 do
		local phys = corpse:GetPhysicsObjectNum( i )
		if IsValid( phys ) then mass = mass + phys:GetMass() end
	end

	local vel = self:GetVelocity()
	if dmginfo != nil and mass > 0 then
		vel = vel + dmginfo:GetDamageForce() / mass
	end

	for i = 0, count - 1 do
		local phys = corpse:GetPhysicsObjectNum( i )

		if IsValid( phys ) then
			local pos, ang = self:GetBonePosition( corpse:TranslatePhysBoneToBone( i ) )
			if pos and ang then
				phys:SetPos( pos )
				phys:SetAngles( ang )
			end

			phys:SetVelocity( vel )
		end
	end

	corpse.TTG_CorpseOf = self
	self.TTG_Corpse = corpse

	return corpse
end


function TTGPlayer:RemoveCorpse()
	if IsValid( self.TTG_Corpse ) then self.TTG_Corpse:Remove() end
	self.TTG_Corpse = nil
end


--The nearest body the server owns within `reach` of this player, and how far,
--or nil.
--
--Only the body of somebody who is dead right now - alive again means their
--body went with the spawn anyway. Measured to whichever part of it is closest,
--so standing over the legs counts as much as over the chest.
function TTGPlayer:NearestBody( reach )
	local here = self:GetPos()
	local best, bestdist = nil, reach

	for _, other in ipairs( player.GetAll() ) do
		local corpse = other.TTG_Corpse

		if other != self and not other:Alive() and IsValid( corpse ) then
			local dist = TTG_CorpsePos( corpse ):Distance( here )

			for i = 0, corpse:GetPhysicsObjectCount() - 1 do
				local phys = corpse:GetPhysicsObjectNum( i )
				if IsValid( phys ) then
					dist = math.min( dist, phys:GetPos():Distance( here ) )
				end
			end

			if dist <= bestdist then best, bestdist = corpse, dist end
		end
	end

	return best, bestdist
end


--Which corpse style a death gets: "body" for the server's own, and anything
--else the default, "gravestone". Read at each death, so a change applies from
--the next one.
function TTG_CorpseStyle()
	if CORPSE_STYLE == "body" then return "body" end

	return "gravestone"
end


--The corpse within `reach` to eat, nearest first: a body, or a gravestone
--standing in for one. Both kinds are looked for whatever the style is now, so
--corpses left from before a switch can still be eaten.
function TTGPlayer:NearestCorpse( reach )
	local body, bodydist = self:NearestBody( reach )
	local stone, stonedist = self:NearestGravestone( reach )

	if body != nil and ( stone == nil or bodydist <= stonedist ) then return body end

	return stone
end


--Where a corpse is eaten from: the spot under a gravestone, or the body itself.
function TTG_CorpseSpot( corpse )
	return corpse.TTG_Ground or TTG_CorpsePos( corpse )
end


--Eaten: a gravestone takes its body with it, and a body just goes.
function TTG_ConsumeCorpse( corpse )
	if IsValid( corpse.TTG_GraveOf ) then
		corpse.TTG_GraveOf:RemoveRemains()
	else
		corpse:Remove()
	end
end

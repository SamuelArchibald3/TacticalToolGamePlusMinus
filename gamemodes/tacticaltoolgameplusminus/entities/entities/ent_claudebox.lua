AddCSLuaFile("ent_claudebox.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


--Claude, deployed: a monitor left on the floor that keeps watch. Once built,
--any enemy who comes within radius of it is reported to its team in chat - who,
--how far off and whether above or below - with a beep only that team hears. The
--same enemy is not reported again for repeat_after seconds, so somebody
--loitering does not flood the chat. Shoot it and it stops.


local angle = Angle( 0, 0, 0 )


function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth( self.Ref.health )

	self.Built = false
	self.CurTakeDamage = false
	self.HitSurface = false
	self.ReadyToFinishBuild = false

	--enemy -> CurTime() they were last reported
	self.Reported = {}
end

function ENT:Initialize()
	self:SetBaseVars()

	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
end


--Builds where it lands on a floor, the same as the Heal Dispenser.
function ENT:PhysicsCollide( data, phys )
	if self.HitSurface == true then return end

	if data.HitEntity:IsWorld() and data.HitNormal[3] < 0 then
		self:EmitSound( self.Ref.sound_a )
		self:BuildFromCollision( data, data.HitPos, data.HitNormal )

		self.HitSurface = true
	end
end


function ENT:ObjToMachine( pos, wallnormal )
	self.CurTakeDamage = true

	self:SetAngles( angle )

	--the owner's bullets collide with it from here on, and so do they
	self:SetOwner( nil )

	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )

	self.BuildingSound = CreateSound( self, self.Ref.sound_build )
	self.BuildingSound:Play()

	timer.Simple( self.Ref.build_time, function()
		if not IsValid( self ) then return end

		self.ReadyToFinishBuild = true
	end )
end


function ENT:FinishBuild()
	self.Built = true

	self:EmitSound( self.Ref.sound_b )
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )

	if self.BuildingSound then self.BuildingSound:Stop() end

	if IsValid( self.Creator ) then
		self.Creator:ChatPrint( "Claude: All set up. I'll tell your team if anyone comes near me." )
	end
end


--Where an enemy is from here, as a sentence.
function ENT:Describe( enemy )
	local here = self:GetPos()
	local there = enemy:GetPos()
	local dist = math.Round( there:Distance( here ) / 10 ) * 10

	local level = "level with me"
	if there.z - here.z > 64 then
		level = "above me"
	elseif here.z - there.z > 64 then
		level = "below me"
	end

	return enemy:Nick() .. " is " .. dist .. " away, " .. level .. "."
end


--Tell this side, and only this side.
function ENT:Report( enemy )
	local line = "Claude: " .. self:Describe( enemy )

	for _, ply in ipairs( team.GetPlayers( self.TTG_Team ) ) do
		ply:ChatPrint( line )
		ply:SendLua( "surface.PlaySound( \"" .. self.Ref.sound_ping .. "\" )" )
	end

	self.Reported[ enemy ] = CurTime()
end


--The enemies within reach who have not been reported lately.
function ENT:Newcomers()
	local out = {}
	local here = self:GetPos()

	for _, ply in ipairs( player.GetAll() ) do
		if ply:IsValidGamePlayer() and ply:Team() != self.TTG_Team
		and ply:GetPos():Distance( here ) <= self.Ref.radius then
			local last = self.Reported[ ply ]
			if last == nil or CurTime() - last >= self.Ref.repeat_after then
				table.insert( out, ply )
			end
		end
	end

	return out
end


function ENT:Think()
	--when ready to build before building, wait until there are no players in the way to do it
	if self.ReadyToFinishBuild and not self.Built then
		if not self:CheckIfPlayerInWay() then
			self:FinishBuild()
		elseif self.BuildingSound then
			self.BuildingSound:ChangePitch( 50, .1 )
		end
	end

	if self.Built != true then return end

	for _, enemy in ipairs( self:Newcomers() ) do
		self:Report( enemy )
	end

	self:NextThink( CurTime() + self.Ref.scan_rate )
	return true
end

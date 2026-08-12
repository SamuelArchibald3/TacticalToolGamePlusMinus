
AddCSLuaFile( "base_ttgentity.lua" )

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false




function ENT:InitializeColor()
	//print("adding color")

	if self.TTG_Team != nil then
		if self.TTG_Team== TEAM_BLUE then
			//print("setting color blue")
			self.BaseColor = Color( 54, 224, 254, 255 )
		elseif self.TTG_Team == TEAM_RED then
			//print("setting color red")
			self.BaseColor = Color( 255, 118, 118, 255 )
		end
	else
		self.BaseColor = Color( 255, 255, 255, 255 )
	end
	
	//print( self.BaseColor )
	
	local alpha = 255
	if self.AlphaAmount != nil then
		alpha = self.AlphaAmount
	end
	
	--also update the color based on how much health it has currently here
	local ref = self:GetRef()
	
	if ref.takes_damage == true and ref.damage_color_override != true then
		local health = self:Health() 
		local basehealth = ref.health
		if ref.health_building != nil then
			basehealth = ref.health_building
		end
		
		local colordeci = (health/basehealth)
		local color = Color( self.BaseColor.r * colordeci, self.BaseColor.g * colordeci, self.BaseColor.b * colordeci, alpha )
		self:SetColor( color ) 
	else
		local color = Color( self.BaseColor.r, self.BaseColor.g, self.BaseColor.b, alpha )
		self:SetColor( self.BaseColor ) 
	end
end



--changes the ents model, initilizing physics stuff as well
--		model: the model you want it to change to
--		collision: the kind of collision you want it to have
function ENT:ChangeStaticModel( model, collision )
	self:InitializeColor()
	
	self:SetModel( model )
	self:SetCollisionGroup( collision )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	local phys = self:GetPhysicsObject()
		phys:EnableMotion(false)	
		
	//if self.HitPostion != nil then
		//self:SetPos( self.HitPostion )
	//end
end



--changes the ents model, initilizing physics stuff as well
--		model: the model you want it to change to
--		collision: the kind of collision you want it to have
function ENT:ChangePhysicsModel( model, collision )
	self:InitializeColor()
	
	self:SetModel( model )
	self:SetCollisionGroup( collision )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS  )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
		phys:Wake()
	
	if phys:IsValid() then
		if self.Ref.mass_override != nil then
			phys:SetMass( self.Ref.mass_override )
		else
			phys:SetMass( 200 )
		end
		
	end
	
	--make so this ent will not collide with the player's team's barriers
	local ref = self:GetRef()
	if ref.collides_with_barriers != true then
		//print("adding nocollide")
		self:AddTeamBarrierNoCollide()
	end
	//self:AddSpawnDoorNoCollide()
end

--returns true if a player is in the way within the build radius of the tool
function ENT:CheckIfPlayerInWay()
	local orgin_ents = ents.FindInSphere( self:GetPos(), self.Ref.build_radius )//self.Ref.build_radius )

	for k, ent in pairs( orgin_ents ) do
		if ent:IsPlayer() then
			if ent:Team() != TEAM_SPEC and ent:Alive() and ent:GetObserverMode( ) == OBS_MODE_NONE then
				return true
			end
		end
	end
	return false
end


//Handle damage
function ENT:OnTakeDamage( damageinfo )
	local amount = damageinfo:GetDamage()
	local health = self:Health() 
	local ref = self:GetRef()
	
	local healing = false
	
	if amount < 0 then
		healing = true
	end
	
	//print("taking damage")
	
	//if this kind of ent doesnt ever take damage, do not take damage
	if ref.takes_damage != true then return end		
		
	//if the ent has damage turned off at this moment for some reason, do not take damage
	if self.CurTakeDamage == false then return end
	
	//if the tool ent is not in its built form, dont take damage
	//if not self:IsBuilt() then return end
	
	local newhealth = nil
	
	//if healing, then make sure health doesnt go over max amount, then change the health
	if healing == true then
		if (health - amount) >= ref.health then
			newhealth = ref.health
			self:SetHealth( newhealth )
		else
			newhealth = health - amount
			self:SetHealth(newhealth)
		end
	elseif healing == false then
		newhealth = health - amount
		self:SetHealth(newhealth)
	end
	
	--do different things depending on if it lost health or gained health
	if newhealth < health then
		if ref.do_not_flash != true then
			self:FlashWhite(.02)
		end
	elseif newhealth > health then
		self.Entity:EmitSound("buttons/button19.wav")
	end
	
	//makes it greener depending on how damaged it is
	//local basehealth = ref.health
	//local colornum = ((255/basehealth)*newhealth)
	//local color = Color( colornum, 255, colornum, 255 )
	//self:SetColor( color ) 
	
	local alpha = 255
	if self.AlphaAmount != nil then
		alpha = self.AlphaAmount
	end
	
	//makes it blacker depending on how damaged it is
	if ref.damage_color_override != true then
		local basehealth = ref.health
		local colordeci = (newhealth/basehealth)
		local color = Color( self.BaseColor.r * colordeci, self.BaseColor.g * colordeci, self.BaseColor.b * colordeci, alpha )
		self:SetColor( color ) 
	end
	
	//if its below or at 0 health it must die
	if self:Health() <= 0 then
		self:DestroyMachine()
	end
	
end


//Explodes machine and shows breaking effects
function ENT:DestroyMachine()
	self:Remove()
	self.Entity:EmitSound("physics/glass/glass_largesheet_break1.wav")
end

function ENT:FlashWhite(time)
	self:SetMaterial("models/debug/debugwhite")
	
	timer.Simple( time, function()
		if self != NULL then 
		self:SetMaterial(self.OrigMat)
		end
	end)
	
end


function ENT:OnRemove( )
	--stop the looping build sound if its building
	if self.BuildingSound != nil then
		self.BuildingSound:Stop()
	end
end



/*---------------------------------------------------------
	Invisiblity stuff
---------------------------------------------------------*/

function ENT:Invisibility_Start( seeing_team )
	//print("starting invis")

	self:SetEntRenderTeam( seeing_team )
	
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	self.AlphaAmount = 70
	
	//makes it have transparency
	local ref = self:GetRef()
	if ref.damage_color_override != true then
		local basehealth = ref.health
		local colordeci = (self:Health()/basehealth)
		local color = Color( self.BaseColor.r * colordeci, self.BaseColor.g * colordeci, self.BaseColor.b * colordeci, self.AlphaAmount )
		self:SetColor( color ) 
		//print("setting color")
	end
end

function ENT:Invisibility_End(  )
	self:SetEntVisibleForAll()

	//self:DrawShadow( true )
	self:SetRenderMode( RENDERMODE_NORMAL )	
	
	self.AlphaAmount = 255

	
	
	//makes it have transparency
	local ref = self:GetRef()
	if ref.damage_color_override != true then
		local basehealth = ref.health
		local colordeci = (self:Health()/basehealth)
		local color = Color( self.BaseColor.r * colordeci, self.BaseColor.g * colordeci, self.BaseColor.b * colordeci, self.AlphaAmount )
		self:SetColor( color ) 
	end
end




--make it so the ent will only render for players of one team
function ENT:SetEntRenderTeam(teamnum)
	self:SetIfInvisible( true )
	self:SetNWInt("RenderTeam", teamnum) 
end

--make it so the ent will render for all players
function ENT:SetEntVisibleForAll()
	self:SetIfInvisible( false )
	self:SetNWInt("RenderTeam", 10) 
end

function ENT:GetEntRenderTeam()
	return self:GetNWInt("RenderTeam", 10) 
end



function ENT:Draw()
	--if it hasnt had its render team set, then just render it normally
	if self:GetEntRenderTeam() != TEAM_BLUE and self:GetEntRenderTeam() != TEAM_RED then 
		self:DrawModel()
		return
	end
	
	//draw the model if the player's team is the render team, or the player is a spectator
	if LocalPlayer():Team() == self:GetEntRenderTeam() or LocalPlayer():Team() == TEAM_SPEC then
		self:DrawModel()
	else
		return
	end
end
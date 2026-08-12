AddCSLuaFile("ent_deflector.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_ttgentity"

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------





//makes it so it has a reference table of all its attributes, to be set within the ent code
function ENT:SetBaseVars()
	self.Ref = self:GetRef()
	self:SetHealth(self.Ref.health)
	//self:SetMaterial("models/debug/debugwhite")
	
	
	self.Built = false
	self.CurTakeDamage = false
	self.HitSurface = false
	self.ReadyToFinishBuild = false
end

function ENT:Initialize()
	self:SetBaseVars()
	
	self:SpecialEntInit()

	self:ChangePhysicsModel( self.Ref.model, COLLISION_GROUP_WEAPON )
end


function ENT:PhysicsCollide(data, phys)
	if self.HitSurface == true then return end

	local normalang = data.HitNormal:Angle() 
	if ( data.HitEntity:IsWorld() and data.HitNormal[3] < 0 ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox" and data.HitEntity.Built == true and normalang.y == 0  ) 
	or ( data.HitEntity:GetClass() == "ent_stepbox_big" and data.HitEntity.Built == true and data.HitNormal[3] < 0  ) then
		local pos = data.HitPos
		local world = data.HitEntity
		self:EmitSound(self.Ref.sound_a)
		
		local wallnormal = data.HitNormal
		self:ObjToMachine(pos, wallnormal)
		
		self.HitSurface = true
		self.HitPostion = data.HitPos
	end
	
end


function ENT:ObjToMachine( pos, wallnormal )
	self.CurTakeDamage = true
	
	self:SetAngles(Angle( 0, self.TTG_Angles.y, 0 ))
	
	self:SetOwner(nil)	--makes it so the owners bullets will collide with it, and the owner will as well
	
	//self.TTG_Team = TEAM_BLUE
	self:ChangeStaticModel( self.Ref.transition_model, COLLISION_GROUP_WEAPON )
	
	--start the looping build sound
	self.BuildingSound = CreateSound( self, self.Ref.sound_build )
	self.BuildingSound:Play()
	
	
	timer.Simple( self.Ref.build_time, function()
		if not IsValid(self) then return end
		
		self.ReadyToFinishBuild = true
		
	end)
		
end




function ENT:FinishBuild()
	self.Built = true

	--change the pos of the model, since its changing
	local vec = self.HitPostion
		vec:Add(Vector(0,0,33))
		self:SetPos(vec)
	
	self:EmitSound(self.Ref.sound_b)
	
	self:ChangeStaticModel( self.Ref.built_model, COLLISION_GROUP_NONE )
	
	--stop the looping build sound
	self.BuildingSound:Stop()
end


--make it so any enemy who hurts this ent will take damage
function ENT:OnTakeDamage( damageinfo )
	local damager = damageinfo:GetAttacker( )
	local inflictor = damageinfo:GetInflictor( )
	
	if not IsValid( damager ) then return end
	if not damager:IsPlayer() then return end
	//if not IsValid( self.Creator ) then return end
	
	if damager:Team() != self.TTG_Team and damageinfo:GetDamage() > 0 then
		//print("returning damage")
		
		--return less damage if its the melee attack
		if inflictor:GetClass() == "default_melee" then
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( self.Ref.damage_return_melee )
				dmginfo:SetInflictor( self )
				dmginfo:SetAttacker( self.Creator )
			damager:TakeDamageInfo( dmginfo )
			
			//print("melee damage")
		else
			local dmginfo = DamageInfo()
				dmginfo:SetDamage( self.Ref.damage_return )
				dmginfo:SetInflictor( self )
				dmginfo:SetAttacker( self.Creator )
			damager:TakeDamageInfo( dmginfo )
			
			//print("building damage")
		end
		
		self:EmitSound( self.Ref.sound_damage )
		
	end
	
	
	
	
	--Stuff copy pasted from the base entity---------------------------
	
	local amount = damageinfo:GetDamage()
	local health = self:Health() 
	local ref = self:GetRef()
	
	local healing = false
	
	if amount < 0 then
		healing = true
	end
	

	//if this kind of ent doesnt ever take damage, do not take damage
	if ref.takes_damage != true then return end		
		
	//if the ent has damage turned off at this moment for some reason, do not take damage
	if self.CurTakeDamage == false then return end
	
	
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
		self:FlashWhite(.02)
	elseif newhealth > health then
		self.Entity:EmitSound("buttons/button19.wav")
	end
	

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




function ENT:Think()
	--when ready to build before building, wait until there are no players in the way to do it
	if self.ReadyToFinishBuild and not self.Built then
		if not self:CheckIfPlayerInWay() then
			self:FinishBuild()
		else
			--make the building looping sound get lower pitched so show that someones in the way
			self.BuildingSound:ChangePitch( 50, .1 )
		end
	end
end

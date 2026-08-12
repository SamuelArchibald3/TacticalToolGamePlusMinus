/*---------------------------------------------------------
	This table controls what the buffs do
---------------------------------------------------------*/


BUFF_TABLE = 
{

Buff_Shield =
{
name = "Buff_Shield",
display = "Shield ACTIVE!",
display_head = "Shield",
is_nerf = false,
color = Color(135, 177, 246, 255),
amount = .15,
sound_on = Sound( "weapons/physcannon/energy_sing_flyby1.wav" ),
sound_off = Sound( "weapons/physcannon/energy_sing_flyby2.wav" ),
}
,

Buff_RateOfFire =
{
name = "Buff_RateOfFire",
display = "Fire Amplificated!",
display_head = "FireAmp'd",
is_nerf = false,
color = Color(255, 130, 47),
amount = .5,
}
,

Buff_DropSlamPrime =
{
name = "Buff_DropSlamPrime",
display = "Drop Slam Primed!",
display_head = "Drop Slam Primed",
is_nerf = false,
color = Color(189, 255, 73, 255),
}
,

Buff_BarrelDisguise =
{
name = "Buff_BarrelDisguise",
display = "Barrel Disguise ACTIVE!",
is_nerf = false,
color = Color(189, 97, 73, 255),
}
,

Buff_Hunker =
{
name = "Buff_Hunker",
display = "Hunkering!",
display_head = "Hunkering",
is_nerf = false,
color = Color(124, 81, 50, 255),
gravity = 2,
}
,

Buff_HunkerSuper =
{
name = "Buff_HunkerSuper",
display = "Super Hunkering!",
display_head = "Super Hunker",
is_nerf = false,
color = Color(124, 81, 50, 255),
}
,

Buff_Avia =
{
name = "Buff_Avia",
display = "Aviating!",
display_head = "Aviaiting",
is_nerf = false,
color = Color(50, 61, 160),
gravity = 0.16,
}
,

Buff_Stun =
{
name = "Buff_Stun",
display = "Stunned!",
display_head = "Stunned",
is_nerf = true,
color = Color(168, 0, 255, 255),
}
,

Buff_SlowReload =
{
name = "Buff_SlowReload",
display = "Reloading!",
display_head = "Reloading",
is_nerf = true,
amount = 90,
color = Color(172, 74, 150, 255),
}
,

Buff_SlowHigh =
{
name = "Buff_SlowHigh",
display = "Super Slowed!",
is_nerf = true,
color = Color(209, 58, 175, 255),
amount = 120,
}
,

Buff_SlowLow =
{
name = "Buff_SlowLow",
display = "Slightly Slowed!",
is_nerf = true,
color = Color(137, 82, 125, 255),
amount = 50,
}
,

Buff_Snare =
{
name = "Buff_Snare",
display = "Snared!",
display_head = "Snared",
is_nerf = true,
color = Color(255, 0, 198, 255),
}
,

Buff_Speed =
{
name = "Buff_Speed",
display = "Speed Buffed!",
is_nerf = true,
color = Color(175, 207, 88, 255),
amount = 200,
}
,

Buff_Cripple =
{
name = "Buff_Cripple",
display = "Crippled!",
display_head = "Crippled",
is_nerf = true,
color = Color(209, 58, 175, 255),
amount = 100,
}
,

Buff_ShieldSuper =
{
name = "Buff_ShieldSuper",
display = "Super Shield ACTIVE!",
display_head = "Super Shield",
is_nerf = false,
color = Color(135, 177, 246, 255),
}
,

Buff_FastZap =
{
name = "Buff_FastZap",
display = "Fast Zap!",
display_head = "Fast Zap",
is_nerf = false,
color = Color(255, 208, 107, 255),
amount = .5,
}
,

Buff_Barrage =
{
name = "Buff_Barrage",
display = "Barrage Charging!",
display_head = "Barrage",
is_nerf = true,
color = Color(100, 100, 100, 255),
}
,

Buff_Airblasted =
{
name = "Buff_Airblasted",
display = "Airblasted!",
//display_head = "Airblasted",
is_nerf = true,
color = Color(100, 100, 100, 255),
}
,

Buff_Lassod =
{
name = "Buff_Lassod",
display = "Lasso'd!",
//display_head = "Lasso'd",
is_nerf = true,
color = Color(100, 100, 100, 255),
}
,

}



function Buff_Reference( buffname )
	local ref = nil
	for _, buff in pairs(BUFF_TABLE) do
		if buff.name == buffname then
			ref = buff
		end
	end
	return ref
end









/*---------------------------------------------------------------------------------------------------
	Buff Effect Methods
-----------------------------------------------------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")




/*---------------------------------------------------------
	Fast Zap
---------------------------------------------------------*/
function TTGPlayer:BuffEffect_FastZap( x, amount )
	local ref = Buff_Reference( "Buff_FastZap" )

	if x == true then
		for k, swep in pairs( self:GetWeapons() ) do
			if swep:GetClass() == "default_melee" then
				swep.Secondary.Delay  = swep.Secondary.Delay * ref.amount
			end
		end
		
	else
		for k, swep in pairs( self:GetWeapons() ) do
			if swep:GetClass() == "default_melee" then
				swep.Secondary.Delay  = swep.BaseDelayAlt
			end
		end
		
	end
end







/*---------------------------------------------------------
	Rate Of Fire
---------------------------------------------------------*/
function TTGPlayer:BuffEffect_RateOfFire( x, amount )
	local ref = Buff_Reference( "Buff_RateOfFire" )

	if x == true then
		for k, swep in pairs( self:GetWeapons() ) do
			swep.Primary.Delay = swep.Primary.Delay * ref.amount
		end
		
	else
		for k, swep in pairs( self:GetWeapons() ) do
			if swep.BaseDelay != nil then
				swep.Primary.Delay = swep.BaseDelay
			end
		end
		
	end
end



/*---------------------------------------------------------
	Shield
---------------------------------------------------------*/
function TTGPlayer:BuffEffect_Shield(x)
	local ref = Buff_Reference( "Buff_Shield" )

	if x == true then
		//self:SetMaterial("models/props_combine/com_shield001a")
		self:EmitSound( ref.sound_on )
	else
		//self:SetMaterial(self.TTG_OrigMat)
		self:EmitSound( ref.sound_off )
	end
end

if SERVER then
	function ShieldScaleDamage( ent, dmginfo )
		if not ent:IsPlayer() then return end
	
		// Lessen incoming damage if the shield is up
		if ent:HowManyOfThisBuff( "Buff_Shield" ) > 0 or ent:HowManyOfThisBuff( "Buff_ShieldSuper" ) > 0 then
			if ent:HowManyOfThisBuff( "Buff_ShieldSuper" ) > 0 then
				dmginfo:ScaleDamage( 0 )
			else
				dmginfo:ScaleDamage( 0.15 )
			end
		else
			dmginfo:ScaleDamage( 1 )
		end
	 
		return dmginfo
	 
	end
	hook.Add("EntityTakeDamage", "ShieldScaleDamage", ShieldScaleDamage)
end


/*---------------------------------------------------------
	Drop Slam
---------------------------------------------------------*/
function TTGPlayer:ActivateDropSlams( fallspeed )
	if self.Ability_A != nil then
		if self.Ability_A:GetClass() == "tool_abil_dropslam" and self.Ability_A.Primed == true then
			self.Ability_A:DropSlam( fallspeed )
		end
	end
	
	if self.Ability_B != nil then
		if self.Ability_B:GetClass() == "tool_abil_dropslam" and self.Ability_B.Primed == true then
			self.Ability_B:DropSlam( fallspeed )
		end
	end
	
	if self.Ability_C != nil then
		if self.Ability_C:GetClass() == "tool_abil_dropslam" and self.Ability_C.Primed == true then
			self.Ability_C:DropSlam( fallspeed )
		end
	end
end

--Makes a player's drop slam be primed, so the next time they hit the ground it will do its effects in an aoe
if SERVER then
	function DropSlamHitGround( ply, inwater, onfloater, fallspeed )
		// Makes the player's drop slam activate if they have it on when they hit the ground
		if ply:HowManyOfThisBuff( "Buff_DropSlamPrime" ) > 0 then
			ply:ActivateDropSlams( fallspeed )
		end
	end
	hook.Add("OnPlayerHitGround", "DropSlamHitGround", DropSlamHitGround)
end


/*---------------------------------------------------------
	Hunker
---------------------------------------------------------*/
function TTGPlayer:BuffEffect_Hunker( x )
	local ref = Buff_Reference( "Buff_Hunker" )

	if x == true then
		self:SetGravity( ref.gravity )
	else
		self:SetGravity( 1 )
	end
end
/*---------------------------------------------------------
	Avia
---------------------------------------------------------*/
function TTGPlayer:BuffEffect_Avia( x )
	local ref = Buff_Reference( "Buff_Avia" )

	if x == true then
		self:SetGravity( ref.gravity )
	else
		self:SetGravity( 1 )
	end
end




/*---------------------------------------------------------
	Snare
---------------------------------------------------------*/
--Makes a player become stuck in place, unable to move or jump but still able to look around and shoot
function TTGPlayer:BuffEffect_Snare( x )
	if x == true then
		self:SetJumpPower( 1 )
	else
		self:SetJumpPower( PLAYER_BASE_JUMPPOWER )
	end
end




/*---------------------------------------------------------
	Stun
---------------------------------------------------------*/

--Stun a player
function TTGPlayer:BuffEffect_Stun( x )
	if x == true then
		--freeze the player in place and make them invulnerable
		self:Freeze( true )
		self:TTG_Invuln( true )
	else
		self:Freeze( false )
		self:TTG_Invuln( false )
	end
end



/*---------------------------------------------------------
	Barrage
---------------------------------------------------------*/

--Stun a player
function TTGPlayer:BuffEffect_Barrage( x )
	if x == true then
		--freeze the player in place
		self:Freeze( true )
	else
		self:Freeze( false )
	end
end





/*---------------------------------------------------------
	All buffs which Slow or Root, they all come together
---------------------------------------------------------*/
if SERVER then
	function SlowJunction( )
		local ref_SlowReload = Buff_Reference( "Buff_SlowReload" )
		local ref_SlowHigh = Buff_Reference( "Buff_SlowHigh" )
		local ref_SlowLow = Buff_Reference( "Buff_SlowLow" )
		local ref_Cripple = Buff_Reference( "Buff_Cripple" )
		local ref_Snare = Buff_Reference( "Buff_Snare" )
		local ref_Speed = Buff_Reference( "Buff_Speed" )
	
		
		for k,ply in pairs(player.GetAll()) do
			if ply:IsValidGamePlayer() then
				
				
				local reload_slow = 0
				if ply:HowManyOfThisBuff( "Buff_SlowReload" ) > 0 then 
					reload_slow = ref_SlowReload.amount
				end
				
				local high_slow = 0
				if ply:HowManyOfThisBuff( "Buff_SlowHigh" ) > 0 then 
					high_slow = ref_SlowHigh.amount
				end
				
				local cripple_slow = 0
				if ply:HowManyOfThisBuff( "Buff_Cripple" ) > 0 then 
					cripple_slow = ref_Cripple.amount
				end
				
				local low_slow = 0
				if ply:HowManyOfThisBuff( "Buff_SlowLow" ) > 0 then 
					low_slow = ref_SlowLow.amount
				end
				
				local speedup = 0
				if ply:HowManyOfThisBuff( "Buff_Speed" ) > 0 then 
					speedup = ref_Speed.amount
				end
				
				local slow_total = ( ply:GetBaseSpeed() + speedup - reload_slow - high_slow - low_slow - cripple_slow )
				
				//if slow_total <= 0 then
					//slow_total = 1
				//end
				
				if slow_total < 20 then
					slow_total = 20
				end
				
				--things which override the whole slow total to just make the player frozen
				if ply:HowManyOfThisBuff( "Buff_Snare" ) > 0 then 
					slow_total = 1
				end
				
				
				ply:SetWalkSpeed( slow_total )
				ply:SetRunSpeed( slow_total )	
			end
		end
		
		
	end
	hook.Add("Tick", "SlowJunction", SlowJunction)
end

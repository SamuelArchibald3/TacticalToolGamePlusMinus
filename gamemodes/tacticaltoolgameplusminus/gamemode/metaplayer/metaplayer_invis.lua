/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")



function TTGPlayer:TempInvisBuff()
	if self.HasInvis == true then 
		return false
	end
	
	//cant give this buff if youre an attacker frozen at the start of the round
	if self.HasFreeze == true then
		return false
	end
	
	//make player invisible
	self:SetRenderMode( RENDERMODE_NONE )
	for _,swep in pairs(self:GetWeapons()) do
		swep:SetIfInvis(true)
	end
	
	
	
	self.HasInvis = true
	self:SetInvisInfo(true)
	timer.Simple( 1, function()
		self.HasInvis_Check = true
	end)
	
	if (SERVER) then
		umsg.Start("Buff_Start", self)
		umsg.End()
	end
	
	//ends the invis after a certain number of seconds
	timer.Simple( 15, function()
		self:TempInvisBuff_End()
	end)
	
	return true
end


//ends the invis
function TTGPlayer:TempInvisBuff_End()
	if self.HasInvis != true then return end

	for _,swep in pairs(self:GetWeapons()) do
		swep:SetIfInvis(false)
	end
	
	self:SetRenderMode( RENDERMODE_NORMAL )
	self.HasInvis = false
	self.HasInvis_Check = false
	self:SetInvisInfo(false)
	
	if (SERVER) then
		--plays buff end sound, replace this later
		umsg.Start("Buff_End", self)
		umsg.End()
	end
end


--for client displaying 'INVISIBLE' text, sets whether or not it shows, also makes their name and health not show
function TTGPlayer:SetInvisInfo(bool)
	self:SetNetworkedBool("Invis", bool)
end

--for client displaying 'INVISIBLE' text, returns true if they are.
function TTGPlayer:GetInvisInfo()
	return (self:GetNetworkedBool("Invis", false))
end



//this checks for invisible players who press their attack key, ends the invis if so
function InvisAttackCheck()
	//print("invischecking")
	
	if not (SERVER) then return end
	
	for _, ply in ipairs( player.GetAll() ) do
		if ply.HasInvis_Check == true then
		
			if( ply:KeyPressed( IN_ATTACK ) ) or ( ply:KeyPressed( IN_ATTACK2 ) ) then
			  ply:TempInvisBuff_End()
			end
		end
	end
end
hook.Add( "Tick","InvisAttackCheck", InvisAttackCheck )


--sets a player to being revealed or not at this time
function TTGPlayer:RevealPlayer(bool)
	self.Revealed = bool
	self:SetRevealInfo(bool)
end

--for client displaying 'INVISIBLE' text, sets whether or not it shows, also makes their name and health not show
function TTGPlayer:SetRevealInfo(bool)
	self:SetNetworkedBool("Reveal", bool)
end

--for client displaying 'INVISIBLE' text, returns true if they are.
function TTGPlayer:GetRevealInfo()
	return (self:GetNetworkedBool("Reveal", false))
end


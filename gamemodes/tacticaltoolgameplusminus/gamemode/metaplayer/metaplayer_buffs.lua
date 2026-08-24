/*---------------------------------------------------------
	Player Meta Tables - Buff Stuff
---------------------------------------------------------*/

local TTGPlayer = FindMetaTable("Player")


//in tool_abil_shield:
//self.Owner:AddBuff( "Buff_Shield", "Shield ACTIVE!", false, 5 )

--(duration is optional)
--Also, returns the slot the buff was in if it does not receive a duration, this is so the buff can be manually removed
--by whatever triggered it.

--     buff - what buff to add
-- duration - how long for the buff to last
-- showtime - should it show the time left for this buff on the hud when its displayed for the player?, true or false

--Which occupant of a buff slot is the current one.
--
--Buff slots get reused, and the duration timers below capture a slot NAME. So a
--timer armed for one buff would happily fire against whatever was sitting in
--that slot later: end its countdown, overwrite its time left, and remove it. All
--it takes is one timed buff being cleared early - which Holster does to
--Buff_SlowReload every time you switch weapon - and the next buff into that slot
--inherits a stranger's expiry.
--
--So every write to a slot bumps a counter, and a timer that finds the counter
--moved on knows it is talking about a buff that is already gone.
function TTGPlayer:BumpBuffSlot( buff_slot )
	self.BuffSlotTokens = self.BuffSlotTokens or {}

	local next_token = ( self.BuffSlotTokens[ buff_slot ] or 0 ) + 1
	self.BuffSlotTokens[ buff_slot ] = next_token

	return next_token
end

function TTGPlayer:BuffSlotToken( buff_slot )
	if not self.BuffSlotTokens then return 0 end
	return self.BuffSlotTokens[ buff_slot ] or 0
end


function TTGPlayer:AddBuff( buff, duration, showtime )
	local buff_slot = nil
	local buff_token = nil
	local duration_networked = nil
	
	
	if showtime == nil then
		showtime = true
	end
	
	
	if duration == nil then
		duration_networked = 0
	else
		duration_networked = duration
	end
	
	local function NetworkBuffToThisSlot( thisslot )
		buff_slot = thisslot
		buff_token = self:BumpBuffSlot( thisslot )
		self:SetNetworkedString( thisslot, buff )
		self:SetNetworkedInt( thisslot .. "_timeleft", duration_networked )
		self:SetNetworkedBool( thisslot .. "_showtime", showtime )
	end
	
	if self:GetNetworkedString("Buff_A", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_A" )
		
	elseif self:GetNetworkedString("Buff_B", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_B" )
		
	elseif self:GetNetworkedString("Buff_C", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_C" )
		
	elseif self:GetNetworkedString("Buff_D", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_D" )
		
	elseif self:GetNetworkedString("Buff_E", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_E" )
		
	elseif self:GetNetworkedString("Buff_F", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_F" )
		
	elseif self:GetNetworkedString("Buff_G", "none") == "none" then
		NetworkBuffToThisSlot( "Buff_G" )
		
	else
		print("cant add buff, that player's buff slots are full")
		return
	end

	
	
	if duration == nil then 
		return buff_slot
	end
	
	
	
	---------Duration Stuff----------
	
	//End the buff when the duration is up
	timer.Simple( duration, function()
		if not IsValid(self) then return end

		//somebody else is in this slot now, and their buff is not ours to end
		if self:BuffSlotToken( buff_slot ) != buff_token then return end

		self:RemoveBuff_BySlot( buff_slot )
	end)
	
	local clock = duration
	
	//Change timeleft every second until it reaches 0
	local function CountDownTimeLeft()
		timer.Simple( 1, function()
			if not IsValid(self) then return end

			//same guard: stop counting down a slot we no longer own, rather than
			//writing our leftover seconds over whatever is in there now
			if self:BuffSlotToken( buff_slot ) != buff_token then return end

			clock = clock - 1
			self:SetNetworkedInt( buff_slot .. "_timeleft", clock )

			if clock > 0 then
				CountDownTimeLeft()
			end
		end)
	end
	CountDownTimeLeft()
end




function TTGPlayer:RemoveBuff_BySlot( buff_slot )
	//bumped so any timer still holding this slot stands down
	self:BumpBuffSlot( buff_slot )

	self:SetNetworkedString( buff_slot, "none")
	self:SetNetworkedInt( buff_slot .. "_timeleft", 0 )
end




--Takes off every instance of one buff, wherever it is sitting.
--
--Buffs live in seven named slots, and until something needed to end a buff
--early there was only RemoveBuff_BySlot - which means knowing which slot it
--landed in. Hunker being a toggle is the first thing that needs this.
function TTGPlayer:RemoveBuff_ByName( buff_name )
	for _, slot in ipairs( { "Buff_A", "Buff_B", "Buff_C", "Buff_D", "Buff_E", "Buff_F", "Buff_G" } ) do
		if self:GetNetworkedString( slot, "none" ) == buff_name then
			self:RemoveBuff_BySlot( slot )
		end
	end
end




function TTGPlayer:RemoveAllBuffs(  )
	local function Remove_NetworkBuff( thisslot )
		self:BumpBuffSlot( thisslot )

		self:SetNetworkedString( thisslot, "none" )
		self:SetNetworkedInt( thisslot .. "_timeleft", 0 )
	end
	
	Remove_NetworkBuff( "Buff_A" )
	Remove_NetworkBuff( "Buff_B" )
	Remove_NetworkBuff( "Buff_C" )
	Remove_NetworkBuff( "Buff_D" )
	Remove_NetworkBuff( "Buff_E" )
	Remove_NetworkBuff( "Buff_F" )
	Remove_NetworkBuff( "Buff_G" )
end







if SERVER then
	function BuffEffectJunction( )
		for k,ply in pairs(player.GetAll()) do
			if ply:IsValidGamePlayer() then

				local function CompareToPrevTable( curbuff )
					for _, prevbuff in pairs( ply.BuffAmountsTable_Prev) do
						if prevbuff.name == curbuff.name then
						
							--if the amount of this buff just went up from 0, then turn ON the effects
							if curbuff.amount > 0 and prevbuff.amount == 0 then
								ply:BuffEffect_SetIfOn( curbuff.name, true )
								//print("turning on buff")
								
							--if the amount of this buff just went down to 0, then turn OFF the effects
							elseif curbuff.amount <= 0 and prevbuff.amount > 0 then
								ply:BuffEffect_SetIfOn( curbuff.name, false )
								//print("turning off buff")
								
							end
							
							return
						end
					end
				end
				
			
				ply.BuffAmountsTable_Cur = ply:BuffAmountsTable()
				
				if ply.BuffAmountsTable_Prev == nil then
					ply.BuffAmountsTable_Prev = ply:BuffAmountsTable_Empty()
				end
				
				
				for _, curbuff in pairs( ply.BuffAmountsTable_Cur ) do
					CompareToPrevTable( curbuff )
				end
				
				
				--the current table becomes the previous table for the next tick
				ply.BuffAmountsTable_Prev = ply.BuffAmountsTable_Cur
			end
		end
	end
	hook.Add("Tick", "BuffEffectJunction", BuffEffectJunction)
end







--returns how many instances of a certain buff the player has
--also returns a table of the ability ents which created the buffs
function TTGPlayer:HowManyOfThisBuff( buff_name )
	local num = 0
	
	if self:GetNetworkedString("Buff_A", "none") == buff_name then
		num = num + 1
	end
	if self:GetNetworkedString("Buff_B", "none") == buff_name then
		num = num + 1
	end
	if self:GetNetworkedString("Buff_C", "none") == buff_name then
		num = num + 1
	end
	if self:GetNetworkedString("Buff_D", "none") == buff_name then
		num = num + 1
	end
	if self:GetNetworkedString("Buff_E", "none") == buff_name then
		num = num + 1
	end
	if self:GetNetworkedString("Buff_F", "none") == buff_name then
		num = num + 1
	end
	if self:GetNetworkedString("Buff_G", "none") == buff_name then
		num = num + 1
	end
	
	return num
end


function TTGPlayer:BuffAmountsTable()
	local return_table = {}
	for _, buff in pairs( BUFF_TABLE ) do
		local num = self:HowManyOfThisBuff( buff.name )
		return_table[buff.name] = { name = buff.name, amount = num }
	end
	return return_table
end

--Creates an empty version of rhe other table
function TTGPlayer:BuffAmountsTable_Empty()
	local return_table = {}
	for _, buff in pairs( BUFF_TABLE ) do
		local num = 0
		return_table[buff.name] = { name = buff.name, amount = num }
	end
	return return_table
end



function TTGPlayer:GetBuffInfoTable(  )
	local buff_table = 
	{
	buff_a = 
	{ 
	name = self:GetNetworkedString("Buff_A", "none"), 
	timeleft = self:GetNetworkedInt("Buff_A_timeleft", 0), 
	showtime = self:GetNetworkedBool("Buff_A_showtime", true), 
	}
	,

	buff_b = 
	{ 
	name = self:GetNetworkedString("Buff_B", "none"), 
	timeleft = self:GetNetworkedInt("Buff_B_timeleft", 0), 
	showtime = self:GetNetworkedBool("Buff_B_showtime", true), 
	}
	,
	
	buff_c = 
	{ 
	name = self:GetNetworkedString("Buff_C", "none"), 
	timeleft = self:GetNetworkedInt("Buff_C_timeleft", 0), 
	showtime = self:GetNetworkedBool("Buff_C_showtime", true), 
	}
	,

	buff_d = 
	{ 
	name = self:GetNetworkedString("Buff_D", "none"), 
	timeleft = self:GetNetworkedInt("Buff_D_timeleft", 0), 
	showtime = self:GetNetworkedBool("Buff_D_showtime", true), 
	}
	,
	
	buff_e = 
	{ 
	name = self:GetNetworkedString("Buff_E", "none"), 
	timeleft = self:GetNetworkedInt("Buff_E_timeleft", 0),
	showtime = self:GetNetworkedBool("Buff_E_showtime", true), 
	}
	,
	
	buff_f = 
	{ 
	name = self:GetNetworkedString("Buff_F", "none"), 
	timeleft = self:GetNetworkedInt("Buff_F_timeleft", 0),
	showtime = self:GetNetworkedBool("Buff_F_showtime", true), 	
	}
	,
	
	buff_g = 
	{ 
	name = self:GetNetworkedString("Buff_G", "none"), 
	timeleft = self:GetNetworkedInt("Buff_G_timeleft", 0), 
	showtime = self:GetNetworkedBool("Buff_G_showtime", true), 
	}
	,

	}

	return buff_table
end




function TTGPlayer:BuffEffect_SetIfOn( bufftype, x )
	if bufftype == "Buff_RateOfFire" then
		self:BuffEffect_RateOfFire( x )
	
	elseif bufftype == "Buff_FastZap" then
		self:BuffEffect_FastZap( x )
	
	elseif bufftype == "Buff_Shield" then
		self:BuffEffect_Shield( x )
	
	elseif bufftype == "Buff_DropSlamPrime" then
		--this one doesnt do anything
	
	elseif bufftype == "Buff_Airblasted" then
		--this one doesnt do anything
		
	elseif bufftype == "Buff_Lassod" then
		--this one doesnt do anything
		
	elseif bufftype == "Buff_Hunker" then
		self:BuffEffect_Hunker( x )

	elseif bufftype == "Buff_Avia" then
		self:BuffEffect_Avia( x )
		
	elseif bufftype == "Buff_Snare" then
		self:BuffEffect_Snare( x )
		
	elseif bufftype == "Buff_Stun" then
		self:BuffEffect_Stun( x )
		
	elseif bufftype == "Buff_Barrage" then
		self:BuffEffect_Barrage( x )
	
	end
end



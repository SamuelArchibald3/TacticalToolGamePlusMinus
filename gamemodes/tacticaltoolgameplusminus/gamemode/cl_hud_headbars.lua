



/*---------------------------------------------------------
	functions for drawing the white bar when a player's health just recently dropped
---------------------------------------------------------*/

function ThinkHealthDrop(p)
	if p.HealthDropping == true then
		p.prevhealth_alt = p.prevhealth_alt - .6
	end
end
 
 
 
local function CheckIfHealthShouldDrop()
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			if v:Team() != TEAM_SPEC then
				local newhealth = v:Health()
			
				if newhealth != v.prevhealth_alt and v.prevhealth_alt != nil and v.HealthDropping != true then
					v.HealthDropping = true
					
				elseif v.HealthDropping == true and v.prevhealth_alt <= newhealth then
					v.HealthDropping = false
				end

				
				if not (v.HealthDropping) then
					v.prevhealth_alt = newhealth
				end
				
				ThinkHealthDrop(v)
			end
		end
	end
 end
 hook.Add("Tick", "CheckIfHealthShouldDrop", CheckIfHealthShouldDrop)
 

 
 
 
local function HealthDrop(v)
	v.prevhealth = v.prevhealth - .5
end








/*---------------------------------------------------------
	Names above heads
---------------------------------------------------------*/

local function HeadBars()
	local Ply = LocalPlayer()

	
	
	--returns true if the trace hit, traces from local player to the input player
	local function CanTraceToPlayer( inputply )
		local Trace = {}
			Trace.start = Ply:EyePos()
			Trace.endpos = inputply:GetPos() + Vector(0, 0, 40)
			Trace.filter = {Ply, inputply:GetWeapons( )}
			Trace.mask = MASK_SOLID - CONTENTS_GRATE
			Trace = util.TraceLine(Trace) 
			
		if (Trace.Entity) == inputply then
			return true
		else
			return false
		end
	end
	
	
	
	
	
	
	--Draws all the name stuff above the inputted players head
	local function DrawPlayerHeadBar( v )
		local Pos = v:GetPos() + Vector(0, 0,80)
		local PosScr = Pos:ToScreen()

		
		--Set up colors
		local white = Color(255,255, 255, 255)
		local teamcolor = Color(200, 200, 200, 255)
		if v:Team() == TEAM_RED then
			teamcolor = Color(255, 140, 140, 255)
		elseif v:Team() == TEAM_BLUE then
			teamcolor = Color(140, 140, 255, 255)
		end

		
		--raise the info up higher depending on how far way the player is
		local distance = Ply:EyePos():Distance( v:GetPos() )
			//PosScr.y = (PosScr.y - (distance * .023))
			PosScr.y = (PosScr.y - ( math.log(distance)*4))
			-- log(distance) * .023
			-- math.log10(distance)
			
		-- Player's name
		draw.SimpleTextOutlined(v:Name(), "default", PosScr.x, PosScr.y, white, 1, 1, 1, Color(0, 0, 0, 255))	--player name
			
		-- Healthbar stuff
		local health = v:Health()

		draw.RoundedBox(8, PosScr.x-40, PosScr.y+10, 80, 10, Color(50,50,50,255))			--background box
		if v.prevhealth_alt != nil then
			draw.RoundedBox(8, PosScr.x-38, PosScr.y+12,v.prevhealth_alt*.76, 6, white)		--white dropping health
		end
		draw.RoundedBox(8, PosScr.x-38, PosScr.y+12, health*.76, 6, teamcolor)			--health box
		

		
		--info on the tool they have out currently
		local tool = v:GetActiveWeapon( )

		
		if IsValid( tool ) then
			local NumGuns = tool:GetNumGuns()
			local Amount = ""
			if NumGuns == 1 then
				Amount = ""
			elseif NumGuns == 2 then
				Amount = "Double "
			elseif NumGuns == 3 then
				Amount = "Triple "
			end
		
			if tool.PrintName != nil then
				draw.SimpleTextOutlined("( ".. Amount .. " " .. tool.PrintName .. " )", "default", PosScr.x, PosScr.y+27, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
			end
		end
		

		--Buff info
		local t_buffs = v:GetBuffInfoTable(  )
		local t_display = {}
		
		for _, buff in pairs( t_buffs ) do
			if buff.name != "none" then
				//print("this is the buff name", buff.name)
				local ref = Buff_Reference( buff.name )
				
				if ref.display_head != nil then
					
					--if it doesnt have this display_head var in the table, nothing will show for the buff over the head
					if ref.display_head != nil then
						//print("found buff", ref.name)
						t_display[ref.name] = { name = ref.name, display = ref.display_head, color = ref.color,  }
					end
				end
			end
		end
		
		local y_amount = 37
		
		for _, dbuff in pairs( t_display ) do
			//print(dbuff)
			draw.SimpleTextOutlined( dbuff.display, "default", PosScr.x, PosScr.y + y_amount, dbuff.color, 1, 1, 1, Color(0, 0, 0, 255))
			y_amount = y_amount + 12
		end
	end

	
	
	
	
	
	
	for k,v in pairs(player.GetAll()) do
		if v:IsValidGamePlayer() and v != Ply then
			local hit = false
		
			--if the local player is on team spec, draw the other player's name no matter what, through walls
			if Ply:Team() == TEAM_SPEC then
				hit = true
				
			elseif Ply:Team() == TEAM_RED or Ply:Team() == TEAM_BLUE then
				
				--if the local player is on a different team than the player, trace to see if the name can be drawn
				if Ply:Team() != v:Team() then
					if CanTraceToPlayer( v ) then
						local showname = true
						
						if not v:Alive() then
							showname = false
						end
						
						
						--makes enemy players who are disguised as a barrel have their names not draw
						if v:Team() != Ply:Team() then
							if v:HowManyOfThisBuff( "Buff_BarrelDisguise" ) > 0 then
								showname = false
							end
						end
						
						
						if showname == true then
							hit = true
						end
					end
					
					
				--if the local player is on the same team as the player, draw the name through walls
				elseif Ply:Team() == v:Team() then
					hit = true
				end
			end			
		
			
			
			
			--if hit, then draw the name above that player's head
			if hit then
				DrawPlayerHeadBar( v )
			end
		end
	end
	
	
	
	
	
end
hook.Add("HUDPaint", "HeadBars", HeadBars)
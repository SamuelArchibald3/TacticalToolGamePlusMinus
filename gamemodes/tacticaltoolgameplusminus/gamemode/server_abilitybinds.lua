/*---------------------------------------------------------
	Stuff that has to do with toggling abilities
---------------------------------------------------------*/



function KeyPressed (Ply, key)
	//print(Ply:Name() .. " pressed ".. key)

	//dont do abilities if the player is frozen
	if Ply.HasFreeze == true then return end
	
	//Which slot this key belongs to. ABILITY_KEYS in shared_settings.lua is the
	//only place the mapping lives, so a key can be changed there without
	//touching the buy logic or the hud.
	for slot, bind in ipairs( ABILITY_KEYS ) do
		if bind.key == key then

			//a key past the current slot count has nothing behind it
			if slot > MAX_ABILITY_SLOTS then return end

			//IsValid( ) rather than != nil - a removed ability ent is not nil,
			//and calling :DoAbility() on it would error
			local abil = Ply:GetAbilitySlots()[ slot ]
			if IsValid( abil ) then
				abil:DoAbility()
			end

			return
		end
	end
end
 
hook.Add( "KeyPress", "KeyPressedHook", KeyPressed )
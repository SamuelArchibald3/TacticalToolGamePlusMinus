/*---------------------------------------------------------
	Stuff that has to do with toggling abilities
---------------------------------------------------------*/



function KeyPressed (Ply, key)
	//print(Ply:Name() .. " pressed ".. key)

	//dont do abilities if the player is frozen
	if Ply.HasFreeze == true then return end
	
	if key == IN_SPEED then
		if Ply.Ability_A != nil then
			Ply.Ability_A:DoAbility()
		end
	elseif key == IN_USE then
		if Ply.Ability_B != nil then
			Ply.Ability_B:DoAbility()
		end
	elseif key == IN_WALK then
		if Ply.Ability_C != nil then
			Ply.Ability_C:DoAbility()
		end
	end
end
 
hook.Add( "KeyPress", "KeyPressedHook", KeyPressed )
/*---------------------------------------------------------
	Stuff that has to do with toggling abilities
---------------------------------------------------------*/



function KeyPressed (Ply, key)
	//print(Ply:Name() .. " pressed ".. key)

	//dont do abilities if the player is frozen
	if Ply.HasFreeze == true then return end
	
	//IsValid( ) rather than != nil - a removed ability ent is not nil, and
	//calling :DoAbility() on it would error
	if key == IN_SPEED then
		if IsValid( Ply.Ability_A ) then
			Ply.Ability_A:DoAbility()
		end
	elseif key == IN_USE then
		if IsValid( Ply.Ability_B ) then
			Ply.Ability_B:DoAbility()
		end
	elseif key == IN_WALK then
		if IsValid( Ply.Ability_C ) then
			Ply.Ability_C:DoAbility()
		end
	end
end
 
hook.Add( "KeyPress", "KeyPressedHook", KeyPressed )
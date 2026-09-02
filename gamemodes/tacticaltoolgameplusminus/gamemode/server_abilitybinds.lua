/*---------------------------------------------------------
	Stuff that has to do with toggling abilities
---------------------------------------------------------*/

--Three ways in, one way out.
--
--Slots used to be triggered one way: a bit in the usercmd, read by the KeyPress
--hook. That capped the game at three abilities, because the free bits left are
--ones the player already uses for something.
--
--The three actions added for slots 4 to 6 are all in the options menu, which is
--the point - nobody types a bind - but they are not all the same kind of thing.
--Suit Zoom is a usercmd bit. Flashlight is impulse 100, which has no bit but
--does have a hook. Gravity Gun is phys_swap, which has neither, so the client
--reports which key it sits on and the server watches for that key.
--
--ABILITY_KEYS names the route per slot in its `trigger` field, so a seventh key
--is a row in that table plus - if it needs one - a route here.


util.AddNetworkString( "TTG_AbilityBinding" )


--Fire the ability in a slot, whichever route asked for it.
--
--Returns whether anything actually happened, which is what lets the flashlight
--route decide between swallowing the key press and letting the torch work.
function TTG_FireAbilitySlot( ply, slot )
	if not IsValid( ply ) or not ply:IsPlayer() then return false end

	--frozen players do not get to use abilities
	if ply.HasFreeze == true then return false end

	--a key past the current slot count has nothing behind it
	if slot == nil or slot < 1 or slot > MAX_ABILITY_SLOTS then return false end

	--IsValid( ) rather than != nil - a removed ability ent is not nil, and
	--calling :DoAbility() on it would error
	local abil = ply:GetAbilitySlots()[ slot ]
	if not IsValid( abil ) then return false end

	abil:DoAbility()
	return true
end


--Which slot, if any, a given trigger and value belong to.
local function SlotFor( trigger, value )
	for slot, bind in ipairs( ABILITY_KEYS ) do
		if bind.trigger == trigger and ( value == nil or bind.key == value ) then
			return slot
		end
	end
end


/*---------------------------------------------------------
	Route 1: usercmd buttons
---------------------------------------------------------*/

function KeyPressed( Ply, key )
	local slot = SlotFor( "button", key )
	if slot == nil then return end

	TTG_FireAbilitySlot( Ply, slot )
end
hook.Add( "KeyPress", "KeyPressedHook", KeyPressed )


/*---------------------------------------------------------
	Route 2: the flashlight
---------------------------------------------------------*/

--impulse 100 has no bit in the usercmd, so this is where the server hears it.
--
--Returning false swallows the key press, which is what stops the torch coming
--on at the same time as the ability. When the slot is empty there is nothing to
--swallow it for, so the flashlight is left to work normally rather than the key
--becoming dead weight for anybody who has not bought that ability.
hook.Add( "PlayerSwitchFlashlight", "TTG_FlashlightAbility", function( ply, on )
	local slot = SlotFor( "flashlight" )
	if slot == nil then return end

	if TTG_FireAbilitySlot( ply, slot ) then return false end
end )


/*---------------------------------------------------------
	Route 3: a key the client reported
---------------------------------------------------------*/

--phys_swap has no bit and no hook, so the only thing that knows which key it is
--on is the client. It looks the binding up and sends the key code here; this
--stores it and matches raw key presses against it.
--
--Keyed by slot, so this covers any future action that has to work the same way.
net.Receive( "TTG_AbilityBinding", function( len, ply )
	if not IsValid( ply ) then return end

	local slot = net.ReadUInt( 4 )
	local code = net.ReadUInt( 10 )

	if ABILITY_KEYS[ slot ] == nil then return end
	if ABILITY_KEYS[ slot ].trigger != "binding" then return end

	ply.TTG_BoundAbilityKeys = ply.TTG_BoundAbilityKeys or {}

	--0 is how the client says "nothing is bound to it any more"
	if code == 0 then
		ply.TTG_BoundAbilityKeys[ slot ] = nil
		return
	end

	ply.TTG_BoundAbilityKeys[ slot ] = code
end )


hook.Add( "PlayerButtonDown", "TTG_BoundAbilityKey", function( ply, button )
	if not IsValid( ply ) then return end

	local bound = ply.TTG_BoundAbilityKeys
	if bound == nil then return end

	--PlayerButtonDown fires for every key including the ones going into chat
	if ply:IsTyping() then return end

	for slot, code in pairs( bound ) do
		if code == button then
			TTG_FireAbilitySlot( ply, slot )
			return
		end
	end
end )

/*---------------------------------------------------------
	Shop descriptions, with their numbers filled in from the tables
---------------------------------------------------------*/

--Every number a description quotes used to be typed into the prose by hand, and
--the tables that drive the game moved on without it. Six of them were wrong at
--the time this was written - avia promised a 30 second cooldown while the table
--said 120, hunker promised 8 seconds of an ability that no longer has a
--duration, the stun trap oversold itself by a second, and so on.
--
--So a description names a field instead of a number, and this fills it in once
--at load. The buy menu and the help menu still read a plain string and did not
--have to change.
--
--Four namespaces, and nothing else:
--
--    {tool.FIELD}        the purchase's own TOOL_TABLE entry
--    {ent.FIELD}         the ENT_TABLE entry that entry's thrown_ent names
--    {buff.NAME.FIELD}   a named BUFF_TABLE entry
--    {calc.NAME}         a derived value, defined in CALC below
--
--This is its own file rather than the bottom of table_shop.lua because of load
--order. init.lua includes tool, ent, shop, then BUFF - so while table_shop.lua
--is being read, BUFF_TABLE does not exist yet and the shield description could
--not be resolved. This is included last, when all four exist.


--Derived values: the ones a reader cannot check against a table at a glance,
--so each says where its number comes from.
--
--Each is called with the purchase and its resolved tool and ent entries, and
--returns a string - including any unit, since that is part of the derivation.
local CALC = {

	--Buff_Shield.amount is the fraction of damage that still gets through
	--(.15), and the sentence talks about what it takes away.
	shield_reduction = function()
		return math.Round( ( 1 - BUFF_TABLE.Buff_Shield.amount ) * 100 ) .. "%"
	end,

	--amp_amount is a fraction added on top, so .5 is "by 50%"
	rateoffire_amp = function( purchase, tool )
		return math.Round( tool.amp_amount * 100 ) .. "%"
	end,

	--the fast zap amount lives on the buff rather than the tool
	fastzap_amp = function()
		return math.Round( BUFF_TABLE.Buff_FastZap.amount * 100 ) .. "%"
	end,

	--heal_amount every heal_rate seconds, which the description says as a rate
	dispenser_heal_per_second = function( purchase, tool, ent )
		return tostring( ent.heal_amount / ent.heal_rate )
	end,
}


--2.5 has to stay 2.5, and 4 must not become 4.0.
local function FormatNumber( value )
	if type( value ) != "number" then return tostring( value ) end

	if value == math.floor( value ) then
		return string.format( "%d", value )
	end

	return tostring( value )
end


--Loud, and leaves the placeholder where it was.
--
--A description that quietly loses a number is worse than one with a stale
--number in it: the stale one is at least visibly wrong to whoever reads it,
--while a blank reads as finished. So a bad field stays on screen as {ent.foo}
--and says so in the console.
local function Unresolved( purchasename, token, why )
	print( "TTG shop description: " .. purchasename .. " wants {" .. token ..
		"} - " .. why )

	return "{" .. token .. "}"
end


local function ResolveToken( purchase, tool, ent, token )
	local namespace, rest = string.match( token, "^(%a+)%.(.+)$" )

	if namespace == nil then
		return Unresolved( purchase.name, token, "not namespaced, expected tool/ent/buff/calc" )
	end

	if namespace == "tool" then
		if tool == nil then
			return Unresolved( purchase.name, token, "no tool_name, or it is not in TOOL_TABLE" )
		end
		if tool[ rest ] == nil then
			return Unresolved( purchase.name, token, tool.name .. " has no " .. rest )
		end

		return FormatNumber( tool[ rest ] )
	end

	if namespace == "ent" then
		if ent == nil then
			return Unresolved( purchase.name, token, "its tool has no thrown_ent in ENT_TABLE" )
		end
		if ent[ rest ] == nil then
			return Unresolved( purchase.name, token, ent.name .. " has no " .. rest )
		end

		return FormatNumber( ent[ rest ] )
	end

	if namespace == "buff" then
		local buffname, field = string.match( rest, "^([%w_]+)%.([%w_]+)$" )

		if buffname == nil or BUFF_TABLE[ buffname ] == nil then
			return Unresolved( purchase.name, token, "no such buff" )
		end
		if BUFF_TABLE[ buffname ][ field ] == nil then
			return Unresolved( purchase.name, token, buffname .. " has no " .. field )
		end

		return FormatNumber( BUFF_TABLE[ buffname ][ field ] )
	end

	if namespace == "calc" then
		if CALC[ rest ] == nil then
			return Unresolved( purchase.name, token, "no such derived value" )
		end

		return CALC[ rest ]( purchase, tool, ent )
	end

	return Unresolved( purchase.name, token, "unknown namespace " .. namespace )
end


--Fills in one purchase's description. Safe to call twice: the second call sees
--the flag and leaves the already-resolved text alone, so a stray number in the
--prose is never re-scanned.
function TTG_ResolveShopDescription( purchase )
	if purchase.description == nil then return end
	if purchase.description_resolved == true then return end

	local tool = purchase.tool_name and TOOL_TABLE[ purchase.tool_name ] or nil
	local ent  = tool and tool.thrown_ent and ENT_TABLE[ tool.thrown_ent ] or nil

	purchase.description = string.gsub( purchase.description, "{([%w_%.]+)}",
		function( token )
			return ResolveToken( purchase, tool, ent, token )
		end )

	purchase.description_resolved = true
end


--Every purchase in every shop, once, at load.
function TTG_ResolveShopDescriptions()
	for _, shop in pairs( { FIRSTSHOP_TABLE, SECONDSHOP_TABLE, THIRDSHOP_TABLE } ) do
		for _, purchase in pairs( shop ) do
			TTG_ResolveShopDescription( purchase )
		end
	end
end


--Exposed for the test suite, which checks the formatting rules directly rather
--than inferring them from a finished sentence.
TTG_FormatShopNumber = FormatNumber
TTG_ShopDescriptionCalcs = CALC


TTG_ResolveShopDescriptions()

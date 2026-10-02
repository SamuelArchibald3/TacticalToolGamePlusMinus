/*---------------------------------------------------------
	Player Meta Tables - Tool Keys
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


--Which number key each carried weapon answers to: the melee and every bought
--tool, from 1 to TTG_ToolKeyCount().
--
--It used to be worked out on the client alone, from the order you bought in:
--the buy menu left a global behind for the weapon to read as it arrived. So
--nothing could move a tool to another key, the server never knew which key
--anything was on, and a weapon that arrived any other way - handed back by a
--rewind - read whatever that global last said. Now the server gives each one a
--key as it is handed out and keeps it on the weapon, networked, where the
--weapon selector reads it.
--
--A key here is a slot bind: key 1 is whatever "slot1" is bound to. The F2
--panel names the real keys; this side only ever deals in the numbers.


--How many keys there are to put things on: the melee's and one per different
--tool, and never past 9, the last slot bind the selector can tell apart.
function TTG_ToolKeyCount()
	return math.min( TTG_DifferentToolCount() + 1, 9 )
end


--The key a weapon is on, or 0 if it has not been given one.
function TTG_ToolKeyOf( wep )
	if not IsValid( wep ) then return 0 end

	return wep:GetNW2Int( "TTG_ToolKey", 0 )
end


--What is on each key, as key -> weapon. Empty keys are simply missing.
function TTGPlayer:ToolKeys()
	local keys = {}

	for _, wep in pairs( self:GetWeapons() ) do
		local key = TTG_ToolKeyOf( wep )
		if key > 0 then keys[ key ] = wep end
	end

	return keys
end


if !SERVER then return end


--Put `wep` on `key`, or with no key given, on the first one nothing is on yet:
--key 1 for the melee at spawn, then each new tool after it in the order it was
--bought - the order keys always came in. More of a tool already carried is the
--same weapon, so it keeps the key it has.
function TTGPlayer:AssignToolKey( wep, key )
	if not IsValid( wep ) then return end

	if key == nil then
		local taken = self:ToolKeys()

		for k = 1, TTG_ToolKeyCount() do
			if not IsValid( taken[ k ] ) then
				key = k
				break
			end
		end
	end

	wep:SetNW2Int( "TTG_ToolKey", key or 0 )
end


--Swap whatever is on two keys, or move a weapon onto an empty one. False, and
--nothing changed, for a key out of range, the same key twice, or two keys with
--nothing on either.
function TTGPlayer:SwapToolKeys( a, b )
	local count = TTG_ToolKeyCount()

	if a == b or a < 1 or b < 1 or a > count or b > count then return false end

	local keys = self:ToolKeys()
	local onA, onB = keys[ a ], keys[ b ]

	if not IsValid( onA ) and not IsValid( onB ) then return false end

	if IsValid( onA ) then onA:SetNW2Int( "TTG_ToolKey", b ) end
	if IsValid( onB ) then onB:SetNW2Int( "TTG_ToolKey", a ) end

	return true
end

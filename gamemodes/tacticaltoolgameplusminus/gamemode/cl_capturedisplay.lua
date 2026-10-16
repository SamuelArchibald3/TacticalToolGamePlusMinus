--The capture bars: one for each live zone whose clock is moving, stacked down
--from the top of the screen. capturetimer.lua sends every live zone's state
--whenever one changes - its name, seconds left, the full time and whether it
--is moving - so a map with A and B both live shows a bar for each one being
--taken, labelled.

local Bars = {}

net.Receive( "TTG_CaptureState", function()
	Bars = {}

	for i = 1, net.ReadUInt( 4 ) do
		Bars[ i ] = {
			label  = net.ReadString(),
			time   = net.ReadUInt( 16 ),
			full   = net.ReadUInt( 16 ),
			moving = net.ReadBool(),
		}
	end
end )


local white = Color( 255, 255, 255, 255 )
local black = Color( 0, 0, 0, 255 )

local function CaptureTimeHud()
	local y = 165

	for _, bar in ipairs( Bars ) do
		if bar.moving then
			local barwidth = 200 - ( ( bar.time / math.max( bar.full, 1 ) ) * 200 )

			//dark grey background box
			draw.RoundedBox( 8, ScrW()/2 - 110, y, 220, 65, Color( 50, 50, 50, 255 ) )

			//the grey box behind the capture time display
			draw.RoundedBox( 8, ScrW()/2 - 100, y + 10, 200, 45, Color( 70, 70, 70, 255 ) )

			//moving bar representing how much time is left
			draw.RoundedBox( 8, ScrW()/2 - 100, y + 10, barwidth, 45, white )

			//which zone, when there is more than one
			if bar.label != "" and #Bars > 1 then
				draw.SimpleTextOutlined( bar.label, "DermaLarge", ScrW()/2, y + 32, white, 1, 1, 2, black )
			end

			y = y + 75
		end
	end
end
hook.Add( "HUDPaint", "CaptureTimeHud", CaptureTimeHud )

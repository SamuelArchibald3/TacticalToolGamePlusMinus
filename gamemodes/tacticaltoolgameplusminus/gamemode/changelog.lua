/*---------------------------------------------------------
	Changelog
---------------------------------------------------------*/

--What changed, for the F3 panel (cl_changelog.lua). Newest first. One short
--line per change, about what a player would notice rather than how it was
--done. Add an entry at the top.

TTG_CHANGELOG = {
	{
		date = "Oct 18",
		notes = {
			"Building Bomb: no longer blocks its own blast. 25 damage per direct hit",
			"Boulder: 550 health (50 while building)",
			"Rewind: two of the same ability both come back, each with its own cooldown",
		},
	},
	{
		date = "Oct 17",
		notes = {
			"New item: Evil Boulder. Comes in twos, hurts everyone, you included",
			"Boulders can be destroyed",
			"Alt fire on Boulders, Mines, Barriers, Blast-Traps and Nades works on all of yours, even after a Rewind",
			"Rewind: rebuilt buildings now finish building",
			"Every death leaves a gravestone; Cannibalism eats from it",
			"New maps in the vote: Gate, Dust2",
		},
	},
	{
		date = "Oct 16",
		notes = {
			"Both capture zones are live at once, each on its own timer",
		},
	},
}

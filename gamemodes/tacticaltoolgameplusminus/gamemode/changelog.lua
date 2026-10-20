/*---------------------------------------------------------
	Changelog
---------------------------------------------------------*/

--What changed, for the F3 panel (cl_changelog.lua). Newest first. One short
--line per change, about what a player would notice rather than how it was
--done. Add an entry at the top.

TTG_CHANGELOG = {
	{
		date = "Oct 19",
		notes = {
			"New item: Bot Factory. Builds, then makes Bots that run at the nearest enemy and hit them",
			"Sentry: 1.5x range (900), and each hit slows you for a second",
		},
	},
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
		},
	}
}
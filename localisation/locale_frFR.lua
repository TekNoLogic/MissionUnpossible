if ( GetLocale() ~= "frFR" ) then
	return;
end
local ns = select( 2, ... );
ns.L = {
	CONFIG_AUTO_PLACE_SIMPLE = "Automatic place followers", -- Requires localization
	CONFIG_AUTO_PLACE_SIMPLE_EXPLAIN = "This will place a follower automatic into party, if you have only 1 available who can counter a trait it dont put them if you have several who can do it", -- Requires localization
	CONFIG_BASIC = "Basic Options", -- Requires localization
	CONFIG_COUNTER_TRAIT = "Show the traits of a mission and if it can be countered", -- Requires localization
	CONFIG_FAST_ASSIGN = "Enable right click to assign/unassign a follower to the mission", -- Requires localization
	CONFIG_FAST_ASSIGN_EXPLAIN = "This deactivates the default right click which shows a context menu, but only on the mission detail page and follower who are available or in party otherwise the right click will behave like usual", -- Requires localization
	CONFIG_FOLLOWER_REQUIRED = "Shows how many followers a mission a require", -- Requires localization
	CONFIG_GLOBAL_SAVE = "Global Configuration", -- Requires localization
	CONFIG_GLOBAL_SAVE_EXPLAIN = "If checked this character uses the global configuration, uncheck to use different options for this character", -- Requires localization
	CONFIG_ON_MISSION = "Show time passed since you have a mission", -- Requires localization
	CONFIG_SHOW_TIME_LEFT = "Show the time left until a follower is done with a mission", -- Requires localization
	FOLLOWER_REQUIRED = "Follower required", -- Requires localization
	MISSION_AVAILABLE = "Mission available", -- Requires localization
}



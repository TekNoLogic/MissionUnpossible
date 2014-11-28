if ( GetLocale() ~= "deDE" ) then
	return;
end
local ns = select( 2, ... );
ns.L = {
	CONFIG_AUTO_PLACE_SIMPLE = "Setzt Anhänger automatisch ein.", -- Needs review
	CONFIG_AUTO_PLACE_SIMPLE_EXPLAIN = "Kontert nur ein vorhandener Anhänger eine Missionseigenschaft, wird er automatisch eingesetzt - bei mehreren möglichen Kontern bleibt der Slot frei und muss manuell besetzt werden..", -- Needs review
	CONFIG_BASIC = "Grundeinstellungen", -- Needs review
	CONFIG_COUNTER_TRAIT = "Zeigt die Eigenschaften einer Mission an und ob ein Anhänger sie kontern kann.", -- Needs review
	CONFIG_FAST_ASSIGN = "Enable right click to assign/unassign a follower to the mission", -- Requires localization
	CONFIG_FAST_ASSIGN_EXPLAIN = "This deactivates the default right click which shows a context menu, but only on the mission detail page and follower who are available or in party otherwise the right click will behave like usual", -- Requires localization
	CONFIG_FOLLOWER_REQUIRED = "Shows how many followers a mission a require", -- Requires localization
	CONFIG_GLOBAL_SAVE = "Globale Einstellungen", -- Needs review
	CONFIG_GLOBAL_SAVE_EXPLAIN = "Bei gesetztem Häkchen gelten die Einstellungen für alle Charaktere. Entferne das Häkchen, wenn für diesen Charakter individuelle Einstellungen gelten sollen.", -- Needs review
	CONFIG_ON_MISSION = "Zeigt an, wieviel Zeit seit dem erstmaligen Erscheinen der Mission vergangen ist.", -- Needs review
	CONFIG_SHOW_TIME_LEFT = "Zeigt an, wie lange ein Anhänger noch auf einer Mission ist.", -- Needs review
	FOLLOWER_REQUIRED = "Follower required", -- Requires localization
	MISSION_AVAILABLE = "Mission available", -- Requires localization
}



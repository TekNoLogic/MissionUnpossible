if ( GetLocale() ~= "zhTW" ) then
	return;
end
local ns = select( 2, ... );
ns.L = {
	CONFIG_AUTO_PLACE_SIMPLE = "自動配置追隨者", -- Needs review
	CONFIG_AUTO_PLACE_SIMPLE_EXPLAIN = "若你只有一個追隨者可以應對任務需要的特性則會自動配置到隊伍中,否則不會自動配置追隨者", -- Needs review
	CONFIG_BASIC = "基本設定", -- Needs review
	CONFIG_COUNTER_TRAIT = "顯示任務需要的特性以及是否可被應對", -- Needs review
	CONFIG_FAST_ASSIGN = "Enable right click to assign/unassign a follower to the mission", -- Requires localization
	CONFIG_FAST_ASSIGN_EXPLAIN = "This deactivates the default right click which shows a context menu, but only on the mission detail page and follower who are available or in party otherwise the right click will behave like usual", -- Requires localization
	CONFIG_FOLLOWER_REQUIRED = "Shows how many followers a mission a require", -- Requires localization
	CONFIG_GLOBAL_SAVE = "一般設定", -- Needs review
	CONFIG_GLOBAL_SAVE_EXPLAIN = "勾選則套用一般設定,否則套用角色個別設定", -- Needs review
	CONFIG_ON_MISSION = "顯示接獲任務已經過時間", -- Needs review
	CONFIG_SHOW_TIME_LEFT = "顯示追隨者完成任務剩餘時間", -- Needs review
	FOLLOWER_REQUIRED = "Follower required", -- Requires localization
	MISSION_AVAILABLE = "Mission available", -- Requires localization
}



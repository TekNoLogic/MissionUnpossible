local config = CreateFrame("Frame");
local config2 = CreateFrame("Frame");
GarrionMissonEnhanceConfig = config;
local defaultconf = {["GlobalConf"]=true,["TimeOnMission"]=true,["CounterTraits"]=true,["AutoPlace"]=true,["ShowTimeLeft"]=true,["FollowerRequired"]=true,["QuickAssign"]=true};
local ns = select( 2, ... )
local L = ns.L;
ns.config = {};




function config:Init()
	config2.name = "Garrison Mission Enhanced";
	config2:SetScript("OnShow",function () InterfaceOptionsFrame_OpenToCategory(config); end);
	InterfaceOptions_AddCategory(config2);

	config.name = L.CONFIG_BASIC;
	config.parent="Garrison Mission Enhanced";



	 local GlobalConf = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_GlobalConf", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.GlobalConf = GlobalConf;
	 GlobalConf.id = "GlobalConf";
	 GlobalConf:SetPoint( "TOPLEFT", 16, -16 );
	 GlobalConf:SetScript("onClick",config.ChangeState);
	 _G[ GlobalConf:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_GLOBAL_SAVE );

  local GlobalConfExplain = config:CreateFontString( nil, "OVERLAY", "GameFontHighlight" );
	config.GlobalConfExplain = GlobalConfExplain;
	GlobalConfExplain:SetPoint("TOPLEFT", GlobalConf,"TOPLEFT", 0, -16)
	GlobalConfExplain:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
	GlobalConf:SetHeight(GlobalConfExplain:GetHeight() + 15);
	GlobalConfExplain:SetJustifyH("LEFT");
	GlobalConfExplain:SetText( L.CONFIG_GLOBAL_SAVE_EXPLAIN);


	local TimeOnMission = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_TimeOnMission", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.TimeOnMission = TimeOnMission;
	 TimeOnMission.id = "TimeOnMission";
	 TimeOnMission:SetPoint( "TOPLEFT", GlobalConfExplain, "BOTTOMLEFT", 0, -16);
	 TimeOnMission:SetScript("onClick",config.ChangeState);
	 _G[ TimeOnMission:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_ON_MISSION );


	 local CounterTraits = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_CounterTraits", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.CounterTraits = CounterTraits;
	 CounterTraits.id = "CounterTraits";
	 CounterTraits:SetPoint( "TOPLEFT", TimeOnMission, "BOTTOMLEFT", 0, -16);
	 CounterTraits:SetScript("onClick",config.ChangeState);
	 _G[ CounterTraits:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_COUNTER_TRAIT );


	local AutoPlaceSimple = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_AutoPlace", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.AutoPlaceSimple = AutoPlaceSimple;
	 AutoPlaceSimple.id = "AutoPlace";
	 AutoPlaceSimple:SetPoint( "TOPLEFT", CounterTraits, "BOTTOMLEFT", 0, -16);
	 AutoPlaceSimple:SetScript("onClick",config.ChangeState);
	 _G[ AutoPlaceSimple:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_AUTO_PLACE_SIMPLE );

	local AutoPlaceSimpleExplain = config:CreateFontString( nil, "OVERLAY", "GameFontHighlight" );
	config.AutoPlaceSimpleExplain = AutoPlaceSimpleExplain;
	AutoPlaceSimpleExplain:SetPoint("TOPLEFT", AutoPlaceSimple,"TOPLEFT", 0, -16)
	AutoPlaceSimpleExplain:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
	AutoPlaceSimple:SetHeight(AutoPlaceSimpleExplain:GetHeight() + 15);
	AutoPlaceSimpleExplain:SetJustifyH("LEFT");
	AutoPlaceSimpleExplain:SetText( L.CONFIG_AUTO_PLACE_SIMPLE_EXPLAIN);

	local ShowTimeLeft = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_ShowTimeLeft", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.ShowTimeLeft = ShowTimeLeft;
	 ShowTimeLeft.id = "ShowTimeLeft";
	 ShowTimeLeft:SetPoint( "TOPLEFT", AutoPlaceSimpleExplain, "BOTTOMLEFT", 0, -16);
	 ShowTimeLeft:SetScript("onClick",config.ChangeState);
	 _G[ ShowTimeLeft:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_SHOW_TIME_LEFT );

	 local FollowerRequired = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_FollowerRequired", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.FollowerRequired = FollowerRequired;
	 FollowerRequired.id = "FollowerRequired";
	 FollowerRequired:SetPoint( "TOPLEFT", ShowTimeLeft, "BOTTOMLEFT", 0, -16);
	 FollowerRequired:SetScript("onClick",config.ChangeState);
	 _G[FollowerRequired:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_FOLLOWER_REQUIRED );


	local QuickAssign = CreateFrame( "CheckButton", "GarrisonMissionEnhanced_QuickAssign", config, "InterfaceOptionsCheckButtonTemplate" );
	 config.QuickAssign = QuickAssign;
	 QuickAssign.id = "QuickAssign";
	 QuickAssign:SetPoint( "TOPLEFT", FollowerRequired, "BOTTOMLEFT", 0, -16);
	 QuickAssign:SetScript("onClick",config.ChangeState);
	 _G[ QuickAssign:GetName().."Text" ]:SetText( "|c00dfb802"..L.CONFIG_FAST_ASSIGN );

	local QuickAssignExplain = config:CreateFontString( nil, "OVERLAY", "GameFontHighlight" );
	config.QuickAssignExplain = QuickAssignExplain;
	QuickAssignExplain:SetPoint("TOPLEFT", QuickAssign,"TOPLEFT", 0, -16)
	QuickAssignExplain:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
	AutoPlaceSimple:SetHeight(QuickAssignExplain:GetHeight() + 15);
	QuickAssignExplain:SetJustifyH("LEFT");
	QuickAssignExplain:SetText( L.CONFIG_FAST_ASSIGN_EXPLAIN);



	InterfaceOptions_AddCategory(config);



	if not(GarrisonMissonEnhancedGlobalConfig) then
		GarrisonMissonEnhancedGlobalConfig =  defaultconf;
		GarrisonMissonEnhancedLocalConfig = defaultconf;
	end
	if not(GarrisonMissonEnhancedLocalConfig) then
		GarrisonMissonEnhancedLocalConfig = defaultconf;
	end
	--todo add proper handling for new config values

	if(ns.main.version==1 and GarrisonMissonEnhancedGlobalConfig["FollowerRequired"]==nil) then
		GarrisonMissonEnhancedGlobalConfig["FollowerRequired"] = true;

	end
	if(ns.main.version==1 and GarrisonMissonEnhancedLocalConfig["FollowerRequired"]==nil) then
		GarrisonMissonEnhancedLocalConfig["FollowerRequired"] = true;

	end

	if(ns.main.version==1 and GarrisonMissonEnhancedGlobalConfig["QuickAssign"]==nil) then
		GarrisonMissonEnhancedGlobalConfig["QuickAssign"] = true;

	end
	if(ns.main.version==1 and GarrisonMissonEnhancedLocalConfig["QuickAssign"]==nil) then
		GarrisonMissonEnhancedLocalConfig["QuickAssign"] = true;

	end

	if(GarrisonMissonEnhancedLocalConfig.GlobalConf==true) then
		ns.config = GarrisonMissonEnhancedGlobalConfig;
	else
		ns.config = GarrisonMissonEnhancedLocalConfig;
	end
	config:SetCurrentConfig();
end

function config:hookhandler(enabled)
	if(ns.main.rightclickhook == true and enabled==false) then
		ns.main:DeactivateFollowerHook();
	elseif(ns.main.rightclickhook == false and enabled == true) then
		if (IsAddOnLoaded("Blizzard_GarrisonUI")) then
			ns.main:ActivateFollowerHook();
		end
	end
end

function config:SetCurrentConfig()
	for key, val in pairs(ns.config) do
		_G["GarrisonMissionEnhanced_"..key]:SetChecked(val);
		if(key == "QuickAssign") then
			config:hookhandler(val);
		end
	end
end

function config:ChangeState()
	if(self.id=="GlobalConf") then
		GarrisonMissonEnhancedLocalConfig["GlobalConf"] = self:GetChecked();
		if(self:GetChecked()==true) then
			ns.config = GarrisonMissonEnhancedGlobalConfig;
		else
			if not(GarrisonMissonEnhancedLocalConfig) then
				GarrisonMissonEnhancedLocalConfig = GarrisonMissonEnhancedGlobalConfig;


			end
			ns.config = GarrisonMissonEnhancedLocalConfig;
		end
		config:SetCurrentConfig();
	else
		ns.config[self.id] = self:GetChecked();
		if(self.id=="QuickAssign") then
			config:hookhandler(self:GetChecked());
		end
	end
end

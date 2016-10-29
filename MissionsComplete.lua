
local myname, ns = ...


local bf = GarrisonMissionFrameMissions.CompleteDialog.BorderFrame
local TURNIN_DELAY = 0.1
local rolling = false
local mission
local function CompleteMissions()
	rolling = true

	local missions = C_Garrison.GetCompleteMissions(LE_FOLLOWER_TYPE_GARRISON_6_0)
	mission = missions[1]
	if not mission then
		rolling = false
		return
	end

	local _, _, _, chance = C_Garrison.GetPartyMissionInfo(mission.missionID)
	mission.successchance = chance

	GarrisonMissionFrame.MissionComplete:OnSkipKeyPressed("SPACE")
end


local function BeginCompletion()
	rolling = true

	local missions = C_Garrison.GetCompleteMissions(LE_FOLLOWER_TYPE_GARRISON_6_0)
	mission = missions[1]
	assert(mission, "No missions available to complete")

	local _, _, _, chance = C_Garrison.GetPartyMissionInfo(mission.missionID)
	mission.successchance = chance

	bf.ViewButton:Click()
end


local butt = CreateFrame("Button", nil, bf, "UIPanelButtonTemplate")
butt:SetWidth(209)
butt:SetText("Complete All")
butt:SetPoint("TOP", bf.ViewButton, "BOTTOM", 0, -10)
butt:SetScript("OnClick", BeginCompletion)


local function CacheDatas()
	ns.Debug("Caching mission data")
	local missions = C_Garrison.GetCompleteMissions(LE_FOLLOWER_TYPE_GARRISON_6_0)
	for i,mission in pairs(missions) do
		for id,reward in pairs(mission.rewards) do
			if reward.itemID then
				if not GetItemInfo(reward.itemID) then
					GameTooltip:SetHyperlink("item:"..reward.itemID)
					GameTooltip:Hide()
				end
			end
		end
	end
end


ns.InitGarrison.MissionsComplete = CacheDatas
butt:SetScript("OnShow", CacheDatas)


local SUCCESS = ITEM_QUALITY_COLORS[2].hex.. "successful|r"
local FAIL    = RED_FONT_COLOR_CODE.. "failed|r"
function ns.GARRISON_MISSION_COMPLETE_RESPONSE(event, missionID, canComplete, succeeded)
	if not rolling then return end

	assert(mission, "No mission table cached")
	assert(mission.missionID == missionID, "Mission IDs do not match")

	ns.Debug(event, missionID, canComplete, succeeded)

	local chance = mission.successchance or "??"
	local outcome = succeeded and SUCCESS or FAIL

	ns.Printf("Mission %q %s (%s%% chance)", mission.name, outcome, chance)

	C_Timer.After(TURNIN_DELAY, CompleteMissions)
end
ns.RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")


function ns.GARRISON_FOLLOWER_XP_CHANGED(event, followerTypeID, followerID, xpAward, oldXP, oldLevel, oldQuality)
	ns.Debug(event, followerTypeID, followerID, xpAward, oldXP, oldLevel, oldQuality)
	ns.Debug("C_Garrison.GetFollowerMissionCompleteInfo", C_Garrison.GetFollowerMissionCompleteInfo(followerID))

	local name = C_Garrison.GetFollowerName(followerID)
	local level = C_Garrison.GetFollowerLevel(followerID)
	local quality = C_Garrison.GetFollowerQuality(followerID)

	local color = ITEM_QUALITY_COLORS[quality].hex
	if xpAward > 0 then
		ns.ChatFramePrint("CHAT_MSG_COMBAT_XP_GAIN", name, color.. "["..level.."]|r", "gained", BreakUpLargeNumbers(xpAward), "experience")
	end
	if oldLevel ~= level then
		ns.ChatFramePrint("PLAYER_LEVEL_UP", name, "is now level", level)
	end
	if oldQuality ~= quality then
		ns.ChatFramePrint("PLAYER_LEVEL_UP", name, "upgraded quality to", color.. level)
	end
end
ns.RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")


function ns.GARRISON_MISSION_BONUS_ROLL_COMPLETE(event, missionID, succeeded)
	if not rolling then return end

	assert(mission, "No mission table cached")
	assert(mission.missionID == missionID, "Mission IDs do not match")

	ns.Debug(event, missionID, succeeded)

	for id,reward in pairs(mission.rewards) do
		if not reward.itemID then
			if reward.currencyID and reward.quantity then
				if reward.currencyID == 0 then
					ns.ChatFramePrint("CHAT_MSG_MONEY", "Received gold:", ns.GS(reward.quantity))
				elseif reward.currencyID ~= GARRISON_CURRENCY then
					local currencyName = GetCurrencyInfo(reward.currencyID)
					local quantity = reward.quantity
					ns.ChatFramePrintf("CHAT_MSG_CURRENCY", CURRENCY_GAINED_MULTIPLE, currencyName, quantity)
				end
			elseif reward.title then
				if reward.quality then
					ns.Print(ITEM_QUALITY_COLORS[reward.quality + 1].hex.. reward.title)
				elseif not reward.followerXP then
					ns.Print(reward.title)
				end
			end
		end
	end
	C_Timer.After(TURNIN_DELAY, CompleteMissions)
end
ns.RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")

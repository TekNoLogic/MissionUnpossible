
local myname, ns = ...


local TURNIN_DELAY = 0.8
local rolling = false
local mission
local function CompleteMissions()
	rolling = true

	local missions = C_Garrison.GetCompleteMissions()
	mission = missions[1]
	if not mission then
		GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide()
		GarrisonMissionFrame.MissionComplete.currentIndex = 1
		GarrisonMissionFrame.MissionComplete.completeMissions = {}
		GarrisonMissionComplete_Initialize(GarrisonMissionFrame.MissionComplete.completeMissions, 1)
		GarrisonMissionFrame.MissionComplete.NextMissionButton.returnToOverview = false

		rolling = false
		return
	end

	local _, _, _, chance = C_Garrison.GetPartyMissionInfo(mission.missionID)
	mission.successchance = chance

	if mission.state == -1 then
		ns.Debug("Marking mission complete", mission.missionID)
		C_Garrison.MarkMissionComplete(mission.missionID)
	else
		ns.Debug("Mission success, rolling", mission.missionID)
		C_Garrison.MissionBonusRoll(mission.missionID)
	end
end


local bf = GarrisonMissionFrameMissions.CompleteDialog.BorderFrame
local butt = CreateFrame("Button", nil, bf, "UIPanelButtonTemplate")
butt:SetWidth(209)
butt:SetText("Complete All")
butt:SetPoint("TOP", bf.ViewButton, "BOTTOM", 0, -10)
butt:SetScript("OnClick", CompleteMissions)


local function CacheDatas()
	ns.Debug("Caching mission data")
	local missions = C_Garrison.GetCompleteMissions()
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
ns.OnLoad = CacheDatas


function ns.GARRISON_MISSION_NPC_OPENED(...)
	ns.Debug(...)
	CacheDatas()
end
ns.RegisterEvent("GARRISON_MISSION_NPC_OPENED")


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

	if succeeded then
		C_Garrison.MissionBonusRoll(missionID)
	else
		C_Timer.After(TURNIN_DELAY, CompleteMissions)
	end
end
ns.RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")


function ns.GARRISON_FOLLOWER_XP_CHANGED(event, followerID, xpAward, oldXP, oldLevel, oldQuality)
	ns.Debug(event, followerID, xpAward, oldXP, oldLevel, oldQuality)
	ns.Debug("C_Garrison.GetFollowerMissionCompleteInfo", C_Garrison.GetFollowerMissionCompleteInfo(followerID))

	local name, displayID, level, quality, currXP, maxXP =
		C_Garrison.GetFollowerMissionCompleteInfo(followerID)

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
		if reward.itemID then
			if reward.itemID ~= 120205 then
				-- [XP] is communicated as an item here (Item #120205)
				-- It sends the standard chat log exp gain though
				ns.Debug("reward.itemID", reward.itemID, GetItemInfo(reward.itemID))

				local _, link = GetItemInfo(reward.itemID)
				if reward.quantity > 1 then
					ns.ChatFramePrintf("CHAT_MSG_LOOT", LOOT_ITEM_PUSHED_SELF_MULTIPLE, link, reward.quantity)
				else
					ns.ChatFramePrintf("CHAT_MSG_LOOT", LOOT_ITEM_PUSHED_SELF, link or "[Unknown item #".. reward.itemID.. "]")
				end
			end
		else
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

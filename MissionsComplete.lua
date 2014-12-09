
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


function ns.GARRISON_MISSION_COMPLETE_RESPONSE(event, missionID, canComplete, succeeded)
	if not rolling then return end

	assert(mission, "No mission table cached")
	assert(mission.missionID == missionID, "Mission IDs do not match")

	TEKKLASTMISSION = mission
	ns.Debug(event, missionID, canComplete, succeeded)
	ns.Debug(C_Garrison.GetPartyMissionInfo(missionID))

	local _, _, _, successChance, _, _, bonusXP =
		C_Garrison.GetPartyMissionInfo(missionID)
	local _, xp = C_Garrison.GetMissionInfo(missionID)
	local outcome = succeeded and "successful" or "failed"

	ns.Printf("Mission %q %s (%s%% chance)", mission.name, outcome, successChance or "??")
	if bonusXP then
		ns.Print(xp + bonusXP, "follower XP earned (".. bonusXP.. " bonus)")
	else
		ns.Print(xp, "follower XP earned")
	end

	if succeeded then
		C_Garrison.MissionBonusRoll(missionID)
	else
		C_Timer.After(TURNIN_DELAY, CompleteMissions)
	end
end
ns.RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")


function ns.GARRISON_FOLLOWER_XP_CHANGED(event, followerID, xpAward, oldXP, oldLevel, oldQuality)
	ns.Debug(event, followerID, xpAward, oldXP, oldLevel, oldQuality)
	ns.Debug(C_Garrison.GetFollowerMissionCompleteInfo(followerID))

	local name, displayID, level, quality, currXP, maxXP =
		C_Garrison.GetFollowerMissionCompleteInfo(followerID)

	if xpAward > 0 then ns.Print(name, "["..level.."]", "gained", xpAward, "experience") end
	if oldLevel ~= level then ns.Print(name, "is now level", level) end
	if oldQuality ~= quality then ns.Print(name, "is now", ITEM_QUALITY_COLORS[quality].. level) end
end
ns.RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")


function ns.GARRISON_MISSION_BONUS_ROLL_COMPLETE(event, missionID, succeeded)
	if not rolling then return end

	assert(mission, "No mission table cached")
	assert(mission.missionID == missionID, "Mission IDs do not match")

	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier = C_Garrison.GetPartyMissionInfo(missionID)
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionID)

	ns.Debug(event, missionID, succeeded)
	ns.Debug(C_Garrison.GetMissionInfo(missionID))

	for id,reward in pairs(mission.rewards) do
		if reward.itemID then
			-- [XP] is communicated as an item here
			-- It sends the standard chat log exp gain though
			ns.Debug("reward.itemID", reward.itemID)
			local _, link = GetItemInfo(reward.itemID)
			if reward.quantity > 1 then
				ns.Printf(LOOT_ITEM_PUSHED_SELF_MULTIPLE, link, reward.quantity)
			else
				ns.Printf(LOOT_ITEM_PUSHED_SELF, link)
			end
		else
			if reward.currencyID and reward.quantity then
				if reward.currencyID == 0 then
					ns.Print("Received gold:", ns.GS(reward.quantity))
				else
					local currencyName = GetCurrencyInfo(reward.currencyID)
					local quantity = reward.quantity
					if reward.currencyID == GARRISON_CURRENCY then
						quantity = floor(quantity * mission.materialMultiplier)
					end
					ns.Printf(CURRENCY_GAINED_MULTIPLE, currencyName, quantity)
				end
			elseif reward.title then
				if reward.quality then
					ns.Print(ITEM_QUALITY_COLORS[reward.quality + 1].hex.. reward.title)
				elseif reward.followerXP then
					ns.Print(BreakUpLargeNumbers(reward.followerXP), "bonus follower XP")
				else
					ns.Print(reward.title)
				end
			end
		end
	end
	C_Timer.After(TURNIN_DELAY, CompleteMissions)
end
ns.RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")

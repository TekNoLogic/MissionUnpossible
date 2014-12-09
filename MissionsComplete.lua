
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
		print("Marking mission complete", mission.missionID)
		C_Garrison.MarkMissionComplete(mission.missionID)
	else
		print("Mission success, rolling", mission.missionID)
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

	local _, _, _, successChance = C_Garrison.GetPartyMissionInfo(missionID)
	if succeeded then
		print("Mission '".. mission.name.. "' successful (".. successChance.. "% chance)")
		C_Garrison.MissionBonusRoll(missionID)
	else
		print("Mission '".. mission.name.. "' failed (".. successChance.. "% chance)")
		C_Timer.After(TURNIN_DELAY, CompleteMissions)
	end
end
ns.RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")


function ns.GARRISON_MISSION_BONUS_ROLL_COMPLETE(event, missionID, succeeded)
	if not rolling then return end

	assert(mission, "No mission table cached")
	assert(mission.missionID == missionID, "Mission IDs do not match")

	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier = C_Garrison.GetPartyMissionInfo(missionID)
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionID)

	print("Roll complete", missionID, succeeded)
	print(C_Garrison.GetPartyMissionInfo(missionID))
	print(C_Garrison.GetMissionInfo(missionID))

	for id,reward in pairs(mission.rewards) do
		if reward.itemID then
			local _, link = GetItemInfo(reward.itemID)
			if reward.quantity > 1 then
				print(link.. " x".. reward.quantity)
			else
				print(link)
			end
		else
			if reward.currencyID and reward.quantity then
				if reward.currencyID == 0 then
					print(ns.GS(reward.quantity))
				elseif reward.currencyID == GARRISON_CURRENCY then
					local currencyName = GetCurrencyInfo(reward.currencyID)
					local quantity = floor(reward.quantity * mission.materialMultiplier)
					print(currencyName.. " x".. quantity)
				else
					local currencyName = GetCurrencyInfo(reward.currencyID)
					print(currencyName.. " x".. reward.quantity)
				end
			elseif reward.title then
				if reward.quality then
					print(ITEM_QUALITY_COLORS[reward.quality + 1].hex.. reward.title)
				elseif reward.followerXP then
					print(BreakUpLargeNumbers(reward.followerXP).. " follower XP")
				else
					print(reward.title)
				end
			end
		end
	end
	C_Timer.After(TURNIN_DELAY, CompleteMissions)
end
ns.RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")


local myname, ns = ...


local rolling = false
local function CompleteMissions()
	rolling = true

	local missions = C_Garrison.GetCompleteMissions()
	local mission = missions[1]
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

	print("Mission success, rolling", missionID, canComplete, succeeded)
	C_Garrison.MissionBonusRoll(missionID)
	C_Timer.After(0.5, CompleteMissions)
end
ns.RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")


function ns.GARRISON_MISSION_BONUS_ROLL_COMPLETE(event, missionID, succeeded)
	if not rolling then return end

	print("Roll complete", missionID, succeeded)
	C_Timer.After(0.5, CompleteMissions)
end
ns.RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE", print)

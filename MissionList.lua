
local myname, ns = ...


ns.inactive_statii = {
	[GARRISON_FOLLOWER_ON_MISSION] = true,
	[GARRISON_FOLLOWER_INACTIVE] = true,
	[GARRISON_FOLLOWER_WORKING] = true,
}
local function GetCounterText(trait, missionid)
	local available, total = 0, 0

	local buffed = C_Garrison.GetBuffedFollowersForMission(missionid)
	for guid,buffs in pairs(buffed) do
		for i,buff in pairs(buffs) do
			if buff.name == trait then
				total = total + 1

				local status = C_Garrison.GetFollowerStatus(guid)
				if not ns.inactive_statii[status] then
					available = available + 1
				end
			end
		end
	end

	if total == 0 then
		return "|cff9d9d9d--"
	elseif available == 0 then
		return "|cff9d9d9d".. available.. "/".. total
	else
		return available.. "/".. total
	end
end


local function UpdateMission(frame)
	local mission = frame.info
	local missionID = mission.missionID

	if not frame.extraEnhancedText then
		frame.extraEnhancedText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		frame.extraEnhancedText:SetPoint("BOTTOMLEFT", 165, 5)
	end

	frame.extraEnhancedText:Show()
	local extratext = mission.numFollowers.. " followers"
	frame.extraEnhancedText:SetText(extratext)

	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(missionID)
	local anchor = frame.Rewards[mission.numRewards]
	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local mech = ns.GetBossMechanicFrame()

			mech.label:SetText(GetCounterText(mechanic.name, missionID))
			mech.Icon:SetTexture(mechanic.icon)

			mech:SetParent(frame)
			mech:SetPoint("LEFT", anchor, "LEFT", -40, 0)
			mech:Show()

			anchor = mech
		end
	end
end


local MissionList = GarrisonMissionFrame.MissionTab.MissionList
local function GarrisonMissionList_Update()
	ns.HideBossMechanicFrames()

	if MissionList.showInProgress then return end

	for i,button in pairs(MissionList.listScroll.buttons) do
		UpdateMission(button)
	end
end


hooksecurefunc("GarrisonMissionList_Update", GarrisonMissionList_Update)
hooksecurefunc(GarrisonMissionFrame.MissionTab.MissionList.listScroll, "update", GarrisonMissionList_Update)

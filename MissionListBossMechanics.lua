
local myname, ns = ...


ns.inactive_statii = {
	[GARRISON_FOLLOWER_ON_MISSION] = true,
	[GARRISON_FOLLOWER_INACTIVE] = true,
	[GARRISON_FOLLOWER_WORKING] = true,
}
function ns.IsFollowerAvailable(guid, excludeparty)
	local status = C_Garrison.GetFollowerStatus(guid)
	if ns.inactive_statii[status] then return false end
	if excludeparty and status == GARRISON_FOLLOWER_IN_PARTY then return false end
	return true
end


local usedbuffs = setmetatable({}, {__index = function(t,i) return 0 end})
local function GetCounterText(trait, mission)
	local available, total, levelmatch, overlevel = 0, 0, false, false
	local missionid = mission.missionID
	local missionlevel = mission.level

	local buffed = C_Garrison.GetBuffedFollowersForMission(mission.missionID, false)
	for guid,buffs in pairs(buffed) do
		for i,buff in pairs(buffs) do
			if buff.name == trait then
				total = total + 1

				if ns.IsFollowerAvailable(guid) then
					available = available + 1

					local level = C_Garrison.GetFollowerLevel(guid)
					local quality = C_Garrison.GetFollowerQuality(guid)

					if level == 100 and mission.level == 100 then
						local ilvl = C_Garrison.GetFollowerItemLevelAverage(guid)
						if ilvl >= mission.iLevel then
							if quality == 4 then
								overlevel = true
							else
								levelmatch = true
							end
						end
					else
						if level == mission.level then levelmatch = true end
						if level > mission.level then overlevel = true end
					end
				end
			end
		end
	end

	if total == 0 then
		return GRAY_FONT_COLOR_CODE.. "--"
	else
		local color = ORANGE_FONT_COLOR_CODE
		if available <= usedbuffs[trait] then
			color = GRAY_FONT_COLOR_CODE
		elseif levelmatch then
			color = HIGHLIGHT_FONT_COLOR_CODE
		elseif overlevel then
			color = BATTLENET_FONT_COLOR_CODE
		end

		return color.. available.. "/".. total
	end
end


local function UpdateMission(frame)
	local mission = frame.info
	if not mission then return end
	local missionID = mission.missionID
	wipe(usedbuffs)

	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(missionID)
	if not missionbosses then return end

	local anchor = frame.Rewards[#mission.rewards]
	local lastframe
	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local mech = ns.GetBossMechanicFrame()

			mech.info = mechanic
			mech.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_6_0

			mech.Icon:SetTexture(mechanic.icon)
			mech.label:SetText(GetCounterText(mechanic.name, mission))
			usedbuffs[mechanic.name] = usedbuffs[mechanic.name] + 1

			mech:SetParent(frame)
			mech:SetPoint("RIGHT", anchor, "LEFT", -12, 0)
			mech:Show()

			if lastframe then
				lastframe:SetPoint("RIGHT", mech, "LEFT", -12, 0)
			end

			lastframe = mech
		end
	end
end


local MissionList = GarrisonMissionFrame.MissionTab.MissionList
local function MissionList_Update(self)
	ns.HideBossMechanicFrames()

	if not MissionList.showInProgress then
		for i,button in pairs(MissionList.listScroll.buttons) do
			UpdateMission(button)
		end
	end
end


hooksecurefunc(GarrisonMission, "OnShowMainFrame", MissionList_Update)
hooksecurefunc(GarrisonMissionFrame.MissionTab.MissionList.listScroll, "update", MissionList_Update)

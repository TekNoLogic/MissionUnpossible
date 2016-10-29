
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


local mission_frames = {}
local SHOW_ABILITY = {}
for i,options in pairs(GarrisonFollowerOptions) do
	SHOW_ABILITY[i] = options.displayCounterAbilityInPlaceOfMechanic
end
local function GetCounterAbility(self, mechanicID, mechanic)
	local followerTypeID = self.info.followerTypeID
	if not SHOW_ABILITY[followerTypeID] then return end

	local abilities = mission_frames[self].abilityCountersForMechanicTypes
	return abilities and abilities[mechanicID]
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
		for mechanicID,mechanic in pairs(boss.mechanics) do
			local mech = ns.GetBossMechanicFrame()

			mech.info = mechanic
			mech.followerTypeID = mission.followerTypeID
			mech.showAbility = SHOW_ABILITY[mech.followerTypeID]
			mech.counterAbility = GetCounterAbility(frame, mechanicID, mechanic)

			mech.Icon:SetTexture((mech.counterAbility or mechanic).icon)
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


local mission_lists = {}
local function MissionList_Update(self)
	local list = mission_lists[self]
	ns.HideBossMechanicFrames()

	if not list.showInProgress then
		for i,button in pairs(list.listScroll.buttons) do
			UpdateMission(button)
		end
	end
end


local function Hook(frame)
	local list = frame.MissionTab.MissionList
	mission_lists[list] = list
	mission_lists[list.listScroll] = list

	for i,butt in pairs(list.listScroll.buttons) do
		mission_frames[butt] = frame
	end

	local f = CreateFrame("Frame", nil, list)
	f:SetScript("OnShow", MissionList_Update)
	mission_lists[f] = list

	hooksecurefunc(list, "Update", MissionList_Update)

	MissionList_Update(list)
end


function ns.InitGarrison.MissionListBossMechanic()
	Hook(GarrisonMissionFrame)
end


function ns.InitOrderHall.MissionListBossMechanic()
	Hook(OrderHallMissionFrame)
end

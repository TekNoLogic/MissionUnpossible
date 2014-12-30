
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


local function OnlyFollowerXP(mission)
	for id,reward in pairs(mission.rewards) do
		if not reward.followerXP then return false end
	end
	return true
end

local usedbuffs = setmetatable({}, {__index = function(t,i) return 0 end})
local function GetCounterText(trait, mission)
	local available, total, levelmatch, overlevel = 0, 0, false, false
	local missionid = mission.missionID
	local missionlevel = mission.level
	local onlyxp = OnlyFollowerXP(mission)

	local buffed = C_Garrison.GetBuffedFollowersForMission(mission.missionID)
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
							if onlyxp and quality == 4 then
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


local function SetReward(frame, rewards)
	local info
	for id,reward in pairs(rewards) do
		if reward.itemID == frame.itemID or reward.title == frame.title then
			info = reward
		end
	end

	if not info then return end

	local text
	if info.followerXP then
		text = info.followerXP
	elseif info.itemID == 120205 then
		text = "3.5%"
	elseif info.itemID and info.quantity == 1 then
		local _, _, qual, ilvl = GetItemInfo(info.itemID)
		if (ilvl or 0) > 500 then text = ilvl end
	elseif info.currencyID == 0 then
		text = (info.quantity / 10000).. "g"
	end

	if text then
		frame.Quantity:SetText(text)
		frame.Quantity:Show()
	end

	frame.Quantity:SetPoint("BOTTOMRIGHT", frame.Icon, -4, 4)
end


local function UpdateMission(frame)
	local mission = frame.info
	if not mission then return end
	local missionID = mission.missionID
	wipe(usedbuffs)

	frame.Level:SetText(mission.level.. "\nx".. mission.numFollowers)

	for i,rewardframe in pairs(frame.Rewards) do
		SetReward(rewardframe, mission.rewards)
	end

	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(missionID)
	if not missionbosses then return end

	local anchor = frame.Rewards[mission.numRewards]
	local lastframe
	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local mech = ns.GetBossMechanicFrame()

			mech.info = mechanic

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
local function GarrisonMissionList_Update()
	ns.HideBossMechanicFrames()

	if MissionList.showInProgress then return end

	for i,button in pairs(MissionList.listScroll.buttons) do
		UpdateMission(button)
	end
end


hooksecurefunc("GarrisonMissionList_Update", GarrisonMissionList_Update)
hooksecurefunc(GarrisonMissionFrame.MissionTab.MissionList.listScroll, "update", GarrisonMissionList_Update)


for _,butt in pairs(MissionList.listScroll.buttons) do
	butt:SetScript("OnEnter", nil)
end

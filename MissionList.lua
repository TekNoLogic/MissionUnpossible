
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


local function GetReward(frame, rewards)
	for id,reward in pairs(rewards) do
		if frame.currencyID then
			if reward.currencyID == frame.currencyID then return reward end
		elseif frame.itemID then
			if reward.itemID == frame.itemID then return reward end
		elseif reward.title == frame.title then
			return reward
		end
	end
end


local function SetReward(frame, rewards)
	frame.Quantity:SetPoint("BOTTOMRIGHT", frame.Icon, -4, 4)


	local reward = GetReward(frame, rewards)
	if not reward then return end


	local text
	if reward.itemID == 120205 then
		text = "3.5%"
	elseif reward.itemID and reward.quantity == 1 then
		local _, _, qual, ilvl = GetItemInfo(reward.itemID)
		if (ilvl or 0) > 500 then text = ilvl end
	end

	if text then
		frame.Quantity:SetText(text)
		frame.Quantity:Show()
	end
end


local follower_counters = setmetatable({}, {
	__index = function(t,i)
		local butt = CreateFrame("Frame", nil, i)
		butt:SetSize(28, 28)
		butt:SetPoint("RIGHT", i.Title, "LEFT", -10, 0)

		local icon = butt:CreateTexture(nil, "BORDER")
		icon:SetAllPoints()
		icon:SetTexture("Interface\\Icons\\achievement_guildperk_everybodysfriend")
		butt.icon = icon

		t[i] = butt
		return butt
	end
})


local expire_strings = setmetatable({}, {
	__index = function(t,i)
		local fs = i:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		fs:SetPoint("LEFT", i.Title)
		fs:SetPoint("BOTTOM", 0, 15)
		fs:SetTextColor(.7, .7, .7, 1)
		t[i] = fs
		return fs
	end
})


local ICONS = {
	"Interface\\Icons\\sha_spell_warlock_demonsoul",
 	"Interface\\Icons\\Racechange",
	"Interface\\Icons\\achievement_guildperk_everybodysfriend",
}
local function UpdateMission(frame)
	local mission = frame.info
	if not mission then return end
	local missionID = mission.missionID
	wipe(usedbuffs)

	local butt = follower_counters[frame]
	butt.icon:SetTexture(ICONS[mission.numFollowers])
	butt:Show()

	frame.Title:SetPoint("LEFT", 165 + 30, 0)

	frame.Title:SetPoint("TOP", 0, -15)
	frame.Title:SetText(mission.name:gsub("Exploration: ", ""))

	local exp = expire_strings[frame]
	exp:SetText(GARRISON_MISSION_AVAILABILITY.. ": ".. mission.offerTimeRemaining)

	for i,rewardframe in pairs(frame.Rewards) do
		SetReward(rewardframe, mission.rewards)
	end

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
local function GarrisonMissionList_Update()
	ns.HideBossMechanicFrames()

	if MissionList.showInProgress then
		for i,butt in pairs(follower_counters) do butt:Hide() end
	else
		for i,button in pairs(MissionList.listScroll.buttons) do
			UpdateMission(button)
		end
	end
end


hooksecurefunc(GarrisonMission, "OnShowMainFrame", GarrisonMissionList_Update)
hooksecurefunc(GarrisonMissionFrame.MissionTab.MissionList.listScroll, "update", GarrisonMissionList_Update)


local function HideTooltip(self, button)
	if not self.info.inProgress then GameTooltip:Hide() end
end

hooksecurefunc("GarrisonMissionButton_OnEnter", HideTooltip)
for _,butt in pairs(MissionList.listScroll.buttons) do
	butt:HookScript("OnEnter", HideTooltip)
end

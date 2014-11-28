
local myname, ns = ...

local L = ns.L;
local f  = CreateFrame("frame")
local old_scroll;
local traiticons = {};
local counters = {};
local addfollower = {};
local oldfollowerrightclick


function f:HideAllTraits()
	for _,v in pairs(traiticons) do
		for _,v2 in pairs(v) do
			v2:Hide();
		end
	end
end

function f:CreateCounter(missionid)
	counters = {};
	addfollower[missionid] = {};
	local mission_counter = C_Garrison.GetBuffedFollowersForMission(missionid);
	for k,v in pairs(mission_counter) do
		for _,v2 in pairs(v) do
			if not counters[v2["name"]] then
				counters[v2["name"]] = {}
			end
			if(C_Garrison.GetFollowerStatus(k)==GARRISON_FOLLOWER_ON_MISSION or C_Garrison.GetFollowerStatus(k)==GARRISON_FOLLOWER_INACTIVE) then
				counters[v2["name"]][k] = true;
			else
				counters[v2["name"]][k] = false;
			end
		end
	end
end

local function checkemptyavail(tabl)
	for _,v in pairs(tabl) do
		if v == false then
			return true
		end
	end
end

function f:CheckCounter(trait,missionid)
	if not counters[trait] or not next(counters[trait]) then
		return 0
	else
		local lastfollower = "";

		for k,v in pairs(counters[trait]) do
			--if not on mission directly return otherwise check if there is one not on mission
			if(v==false) then
				counters[trait][k] = nil;
				addfollower[missionid][trait] = k;
				return 2;
			else
				lastfollower = k;
			end

		end
		counters[trait][lastfollower] = nil;
		return 1;
	end
	return 0;
end


local inactive_statii = {
	[GARRISON_FOLLOWER_ON_MISSION] = true,
	[GARRISON_FOLLOWER_INACTIVE] = true,
}
local function GetCounterText(trait, missionid)
	if not counters[trait] or not next(counters[trait]) then
		return "|cff9d9d9d--"
	else
		local available, total = 0, 0

		local buffed = C_Garrison.GetBuffedFollowersForMission(missionid);
		for guid,buffs in pairs(buffed) do
			for i,buff in pairs(buffs) do
				if buff.name == trait then
					total = total + 1

					local status = C_Garrison.GetFollowerStatus(guid)
					if not inactive_statii[status] then
						available = available + 1
					end
				end
			end
		end

		if available == 0 then
			return "|cff9d9d9d".. available.. "/".. total
		else
			return available.. "/".. total
		end
	end
end

--C_Garrison.AddFollowerToMission

local function CheckMoreThanOneCounter(missionid)
	for k,v in pairs(addfollower[missionid]) do
		if checkemptyavail(counters[k]) then
			addfollower[missionid][k] = nil
		end
	end
end

local function CreateTraitFrame(parent)
	local f = CreateFrame("Frame", nil, parent, "GarrisonMissionEnemyLargeMechanicTemplate")

	local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	label:SetPoint("BOTTOM", 0, -16)
	f.label = label

	return f
end

local function UpdateMission(frame, mission)
	local missionID = mission.missionID

	if not frame.extraEnhancedText then
		frame.extraEnhancedText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		frame.extraEnhancedText:SetPoint("BOTTOMLEFT", 165, 5)
	end

	frame.extraEnhancedText:Show()
	local extratext = mission.numFollowers.. " followers"
	frame.extraEnhancedText:SetText(extratext)

	f:CreateCounter(missionID)
	if not traiticons[missionID] then
		traiticons[missionID] = {}
	end

	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(missionID)
	local missiontraits = traiticons[missionID]
	local buttoncount = 1
	local anchor = frame.Rewards[mission.numRewards]
	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local trait = missiontraits[buttoncount] or CreateTraitFrame(frame)

			local cancounter = f:CheckCounter(mechanic.name, missionID)

			trait.label:SetText(GetCounterText(mechanic.name, missionID))
			trait.Icon:SetTexture(mechanic.icon)

			trait:SetParent(frame)
			trait:SetPoint("LEFT", anchor, "LEFT", -40, 0)
			trait:Show()

			anchor = trait
			buttoncount = buttoncount + 1
		end
	end

	CheckMoreThanOneCounter(missionID)
end

function f:GarrisonMissionList_Update()
	local self = GarrisonMissionFrame.MissionTab.MissionList
	f:HideAllTraits()

	if self.showInProgress then return end

	local missions = self.availableMissions
	local scrollFrame = self.listScroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	for i,button in pairs(scrollFrame.buttons) do
		local index = offset + i
		if missions[index] then UpdateMission(button, missions[index]) end
	end
end

function f:doscroll(...)
	old_scroll(...)
	f:GarrisonMissionList_Update()
end

local function UpdateFollowerTimeLeft(self)
	local followers = self.FollowerList.followers
	local followersList = self.FollowerList.followersList

	local inprogress = C_Garrison.GetInProgressMissions()

	local scrollFrame = self.FollowerList.listScroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	for i,button in pairs(scrollFrame.buttons) do
		local index = offset + i
		if index <= #followersList then
			local follower = followers[followersList[index]]
			if (follower.status == GARRISON_FOLLOWER_ON_MISSION) then
				local timeLeft = ns.GetFollowerTimeLeft(follower.followerID)
				button.Status:SetText(follower.status.. " (".. timeLeft.. ")")
			end
		end
	end
end

local function ShowMission(mission)
	local i = 1
	for _,k in pairs(addfollower[mission['missionID']]) do
		local followerFrame = GarrisonMissionFrame.MissionTab.MissionPage.Followers[i];
		local followerInfo = C_Garrison.GetFollowerInfo(k);
		GarrisonMissionPage_SetFollower(followerFrame, followerInfo);
		i=i+1;
		--C_Garrison.AddFollowerToMission(mission['missionID'],k);
	end
end

--local function MissionComplete()
	--GarrisonMissionFrame.MissionComplete.NextMissionButton:Enable();
--end

local function FollowerRightClick (...)
	local MISSION_PAGE_FRAME = GarrisonMissionFrame.MissionTab.MissionPage;
	local self,button = ...;
	if MISSION_PAGE_FRAME:IsVisible() and MISSION_PAGE_FRAME.missionInfo and button == "RightButton" then
		if not self.info.status then
			GarrisonMissionPage_AddFollower(self.id)
		elseif self.info.status == GARRISON_FOLLOWER_IN_PARTY then
			for i = 1, #MISSION_PAGE_FRAME.Followers do
				local followerFrame = MISSION_PAGE_FRAME.Followers[i]
				if followerFrame.info then

					if followerFrame.info.followerID == self.id then
						GarrisonMissionPage_ClearFollower(followerFrame,true)
						break
					end
				end
			end
		else
			return oldfollowerrightclick(...)
		end
	else
		return oldfollowerrightclick(...)
	end
end


function ns.OnLoad()
	f:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	f:RegisterEvent("GARRISON_MISSION_STARTED")
	f:RegisterEvent("PLAYER_LOGOUT")

	old_scroll = GarrisonMissionFrame.MissionTab.MissionList.listScroll.update
	GarrisonMissionFrame.MissionTab.MissionList.listScroll.update = f.doscroll
	hooksecurefunc("GarrisonMissionList_Update", f.GarrisonMissionList_Update)
	hooksecurefunc("GarrisonFollowerList_Update", UpdateFollowerTimeLeft)
	hooksecurefunc("GarrisonMissionPage_ShowMission", ShowMission)

	oldfollowerrightclick = GarrisonFollowerListButton_OnClick
	GarrisonFollowerListButton_OnClick = FollowerRightClick
end


-- ns.RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
-- function ns.GARRISON_MISSION_LIST_UPDATE()
-- end


-- ns.RegisterEvent("GARRISON_MISSION_STARTED")
-- function ns.GARRISON_MISSION_STARTED(event, missionID)
-- end

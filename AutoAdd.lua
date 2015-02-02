
local myname, ns = ...


local counters = setmetatable({}, {__index = function(t,i) return 0 end})
local buffed
local function GetFollowerWithBuff(mechanic, level)
	local follower
	local counter = counters[mechanic]
	counters[mechanic] = counters[mechanic] - 1

	for guid,buffs in pairs(buffed) do
		if level == 100 or C_Garrison.GetFollowerLevel(guid) == level then
			for i,buff in pairs(buffs) do
				if buff.name == mechanic then
					if ns.IsFollowerAvailable(guid, true) then
						if counter == 0 then return end
						counter = counter - 1
						follower = guid
					end
				end
			end
		end
	end

	-- Remove buffs that a double-matched follower covers so we don't add
	-- another follower that is not needed
	if follower then
		for i,buff in pairs(buffed[follower]) do
			if buff.name ~= mechanic then
				counters[buff.name] = counters[buff.name] - 1
			end
		end
	end

	return follower
end


local function EligibleFollower(follower, mission_level)
	if not follower.isCollected then return false end
	if follower.status then return false end
	return follower.level < 100 and follower.level >= mission_level
end


local followers
local function NumPotentialFollowers(mission_level)
	local count = 0
	for _,follower in pairs(followers) do
		if EligibleFollower(follower, mission_level) then count = count + 1 end
	end
	return count
end


local dirty = false
hooksecurefunc("GarrisonMissionPage_ShowMission", function() dirty = true end)
hooksecurefunc("GarrisonFollowerList_UpdateFollowers", function()
	if not dirty then return end
	dirty = false

	local mission = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo

	wipe(counters)

	local needed = mission.numFollowers
	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(mission.missionID)
	buffed = C_Garrison.GetBuffedFollowersForMission(mission.missionID)

	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			counters[mechanic.name] = counters[mechanic.name] + 1
		end
	end

	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local guid = GetFollowerWithBuff(mechanic.name, mission.level)
			if guid then
				needed = needed - 1
				GarrisonMissionPage_AddFollower(guid)
			end
		end
	end

	if needed == 0 or mission.level == 100 then return end

	followers = C_Garrison.GetFollowers()
	if NumPotentialFollowers(mission.level) > needed then return end

	for _,follower in pairs(followers) do
		if EligibleFollower(follower, mission.level) then
			GarrisonMissionPage_AddFollower(follower.followerID)
		end
	end
end)

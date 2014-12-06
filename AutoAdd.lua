
local myname, ns = ...


local counters = setmetatable({}, {__index = function(t,i) return 0 end})
local buffed
local function GetFollowerWithBuff(mechanic)
	local follower
	local counter = counters[mechanic]
	counters[mechanic] = counters[mechanic] - 1

	for guid,buffs in pairs(buffed) do
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

	return follower
end


hooksecurefunc("GarrisonMissionPage_ShowMission", function(mission)
	wipe(counters)

	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(mission.missionID)
	buffed = C_Garrison.GetBuffedFollowersForMission(mission.missionID)

	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			counters[mechanic.name] = counters[mechanic.name] + 1
		end
	end

	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local guid = GetFollowerWithBuff(mechanic.name)
			if guid then GarrisonMissionPage_AddFollower(guid) end
		end
	end

end)


local myname, ns = ...


local function GetFollowerWithBuff(buffed, ability)
	local follower

	for guid,buffs in pairs(buffed) do
		for i,buff in pairs(buffs) do
			if buff.name == ability then
				local status = C_Garrison.GetFollowerStatus(guid)
				if not ns.inactive_statii[status] then
					if follower then return end
					follower = guid
				end
			end
		end
	end

	return follower
end


hooksecurefunc("GarrisonMissionPage_ShowMission", function(mission)
	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(mission.missionID)
	local buffed = C_Garrison.GetBuffedFollowersForMission(mission.missionID)
	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local guid = GetFollowerWithBuff(buffed, mechanic.name)
			if guid then GarrisonMissionPage_AddFollower(guid) end
		end
	end

end)

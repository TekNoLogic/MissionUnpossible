
local myname, ns = ...


local inprogress = {}
function ns.RefreshInProgress(type)
	inprogress[type] = C_Garrison.GetInProgressMissions(type)
end


function ns.GetFollowerTimeLeft(follower)
	local id = follower.followerID
	local dataset = inprogress[follower.followerTypeID]
	if not dataset then return end

	for i,mission in pairs(dataset) do
		for j,guid in pairs(mission.followers) do
			if guid == id then
				return mission.timeLeft
			end
		end
	end
end

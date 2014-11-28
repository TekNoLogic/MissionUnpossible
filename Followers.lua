
local myname, ns = ...

function ns.GetFollowerTimeLeft(followerID)
	local inprogress = C_Garrison.GetInProgressMissions()
	for i,mission in pairs(inprogress) do
		for j,guid in pairs(mission.followers) do
			if guid == followerID then
				return mission.timeLeft
			end
		end
	end
end

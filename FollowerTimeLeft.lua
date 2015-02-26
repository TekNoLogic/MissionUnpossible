
local myname, ns = ...

local inprogress
function ns.RefreshInProgress()
	inprogress = C_Garrison.GetInProgressMissions()
end


function ns.GetFollowerTimeLeft(followerID)
	for i,mission in pairs(inprogress) do
		for j,guid in pairs(mission.followers) do
			if guid == followerID then
				return mission.timeLeft
			end
		end
	end
end

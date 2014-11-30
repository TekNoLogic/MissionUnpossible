
local myname, ns = ...


local function GetFollowerTimeLeft(followerID, inprogress)
	for i,mission in pairs(inprogress) do
		for j,guid in pairs(mission.followers) do
			if guid == followerID then
				return mission.timeLeft
			end
		end
	end
end


hooksecurefunc("GarrisonFollowerList_Update", function(self)
	local inprogress = C_Garrison.GetInProgressMissions()

	local followers = self.FollowerList.followers
	local followersList = self.FollowerList.followersList

	local scrollFrame = self.FollowerList.listScroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i,button in pairs(scrollFrame.buttons) do
		local index = offset + i
		if index <= #followersList then
			local follower = followers[followersList[index]]
			if follower.status == GARRISON_FOLLOWER_ON_MISSION then
				local timeLeft = GetFollowerTimeLeft(follower.followerID, inprogress)
				if timeLeft then
					button.Status:SetText(follower.status.. " (".. timeLeft.. ")")
				end
			end
		end
	end
end)

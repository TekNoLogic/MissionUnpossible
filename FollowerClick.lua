
local myname, ns = ...


local function RemoveFollower(followerID)
	for i,frame in pairs(GarrisonMissionFrame.MissionTab.MissionPage.Followers) do
		if frame.info and frame.info.followerID == followerID then
			return GarrisonMissionPage_ClearFollower(frame, true)
		end
	end
end


local orig = GarrisonFollowerListButton_OnClick
local MissionPage = GarrisonMissionFrame.MissionTab.MissionPage
function GarrisonFollowerListButton_OnClick(self, button, ...)
	if MissionPage:IsVisible() and MissionPage.missionInfo and button == "RightButton" then
		if not self.info.status then
			return GarrisonMissionPage_AddFollower(self.id)
		elseif self.info.status == GARRISON_FOLLOWER_IN_PARTY then
			return RemoveFollower(self.id)
		end
	end

	return orig(self, button, ...)
end

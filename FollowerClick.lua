
local myname, ns = ...


local function Hook(missionpage)
	local function RemoveFollower(followerID)
		local missionframe = missionpage:GetParent():GetParent()
		for i,frame in pairs(missionpage.Followers) do
			if frame.info and frame.info.followerID == followerID then
				return missionframe:RemoveFollowerFromMission(frame, true)
			end
		end
	end


	local orig = GarrisonFollowerListButton_OnClick
	function GarrisonFollowerListButton_OnClick(self, button, ...)
		if missionpage:IsVisible() and missionpage.missionInfo and button == "RightButton" then
			if not self.info.status then
				return missionpage:AddFollower(self.id)
			elseif self.info.status == GARRISON_FOLLOWER_IN_PARTY then
				return RemoveFollower(self.id)
			end
		end

		return orig(self, button, ...)
	end
end


function ns.InitGarrison.FollowerClick()
	Hook(GarrisonMissionFrame.MissionTab.MissionPage)
end


function ns.InitOrderHall.FollowerClick()
	Hook(OrderHallMissionFrame.MissionTab.MissionPage)
end

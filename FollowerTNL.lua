
local myname, ns = ...


hooksecurefunc(GarrisonMissionFrame.FollowerList, "UpdateData", function(self)
	local followers = self.followers
	local followersList = self.followersList

	local scrollFrame = self.listScroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i,button in pairs(scrollFrame.buttons) do
		local index = offset + i
		if index <= #followersList then
			local follower = followers[followersList[index]]
			if ns.IsFollowerLeveling(follower) and not follower.status then
				button.Follower.Name:SetPoint("LEFT", button.Follower.PortraitFrame, "LEFT", 66, 8)

				local tnl = follower.levelXP - follower.xp
				button.Follower.Status:SetText(GARRISON_FOLLOWER_TOOLTIP_XP:format(tnl))

				button.Follower.XPBar:SetTexture(94/256, 50/256, 119/256)
			end
		end
	end
end)

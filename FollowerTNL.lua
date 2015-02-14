
local myname, ns = ...


hooksecurefunc("GarrisonFollowerList_Update", function(self)
	local followers = self.FollowerList.followers
	local followersList = self.FollowerList.followersList

	local scrollFrame = self.FollowerList.listScroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i,button in pairs(scrollFrame.buttons) do
		local index = offset + i
		if index <= #followersList then
			local follower = followers[followersList[index]]
			if ns.IsFollowerLeveling(follower) and not follower.status then
				button.Name:SetPoint("LEFT", button.PortraitFrame, "LEFT", 66, 8)

				local tnl = follower.levelXP - follower.xp
				button.Status:SetText(GARRISON_FOLLOWER_TOOLTIP_XP:format(tnl))

				button.XPBar:SetTexture(94/256, 50/256, 119/256)
			end
		end
	end
end)

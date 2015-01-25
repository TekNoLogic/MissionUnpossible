
local myname, ns = ...


local function IsFollowerLeveling(follower)
	if not follower.isCollected then return false end
	if follower.quality < 4 then return true end
	if follower.level < 100 then return true end
end


local list = GarrisonMissionFrame.MissionTab.MissionList
list.MaterialFrame:SetWidth(250)

local butt = CreateFrame("Frame", nil, list)
butt:SetSize(28, 28)
butt:SetPoint("RIGHT", list.MaterialFrame, "LEFT", -15, 0)

local icon = butt:CreateTexture(nil, "BORDER")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\achievement_guildperk_fasttrack_rank2")

butt:SetScript("OnLeave", GameTooltip_Hide)
butt:SetScript("OnEnter", function(self)
	local followers = C_Garrison.GetFollowers()
	ns.RefreshInProgress()

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddLine("Followers currently leveling")

	for i,follower in pairs(followers) do
		if IsFollowerLeveling(follower) then
			GameTooltip:AddLine(ns.FollowerToString(follower))
		end
	end

	GameTooltip:Show()
end)

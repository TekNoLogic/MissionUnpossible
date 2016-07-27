
local myname, ns = ...


function ns.IsFollowerLeveling(follower)
	if not follower.isCollected then return false end
	if follower.quality < 4 then return true end
	if follower.level < 100 then return true end
end


local list = GarrisonMissionFrame.MissionTab.MissionList
list.MaterialFrame:SetWidth(250)

local butt = CreateFrame("Frame", nil, list)
butt:SetSize(32, 32)
butt:SetPoint("RIGHT", list.MaterialFrame, "LEFT", -15, 0)

local icon = butt:CreateTexture(nil, "BORDER")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\Garr_currencyicon-xp")
icon:SetTexCoord(1/64, 63/64, 1/64, 63/64)

butt:SetScript("OnLeave", GameTooltip_Hide)
butt:SetScript("OnEnter", function(self)
	local followers = C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_GARRISON_6_0)
	ns.RefreshInProgress()

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddLine("Followers currently leveling")

	for i,follower in pairs(followers) do
		if ns.IsFollowerLeveling(follower) then
			local name, status = ns.FollowerToString(follower)
			GameTooltip:AddDoubleLine(name, status, nil,nil,nil, 1,1,1)
		end
	end

	GameTooltip:Show()
end)

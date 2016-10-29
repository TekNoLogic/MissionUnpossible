
local myname, ns = ...


local function SortFollowers(a, b)
	if not a then return false end
	if not b then return true end

	if a.isMaxLevel and b.isMaxLevel then
		return a.iLevel > b.iLevel
	else
		return a.level > b.level
	end
end


local followers
local function RefreshFollowers()
	followers = C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_GARRISON_6_0)
	table.sort(followers, SortFollowers)
end


local function FollowerCanCounter(follower, mechanic)
	if not follower.isCollected then return false end

	local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
	for i,ability in pairs(abilities) do
		for counterID,counterInfo in pairs(ability.counters) do
			if counterInfo.name == mechanic then return true end
		end
	end

	return false
end


local hider = CreateFrame("Frame")
hider:SetScript("OnHide", GameTooltip_Hide)


local tip = GarrisonMissionMechanicTooltip
function tip.Show()
	local _, anchor = tip:GetPoint(1)
	local mechanic = tip.Name:GetText()
	local desc = tip.Description:GetText()

	ns.ShowMechanicTooltip(anchor)
end


function ns.ShowMechanicTooltip(self)
	local mechanic = self.info.name
	local desc = self.info.description
	RefreshFollowers()
	ns.RefreshInProgress(LE_FOLLOWER_TYPE_GARRISON_6_0)

	hider:SetParent(self)
	self:SetScript("OnLeave", GameTooltip_Hide)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddLine(mechanic, 1,1,1)
	if desc then GameTooltip:AddLine(desc, nil,nil,nil, true) end
	GameTooltip:AddLine(" ")

	for i,follower in pairs(followers) do
		if FollowerCanCounter(follower, mechanic) then
			local name, status = ns.FollowerToString(follower)
			GameTooltip:AddDoubleLine(name, status, nil,nil,nil, 1,1,1)
		end
	end

	GameTooltip:Show()
end

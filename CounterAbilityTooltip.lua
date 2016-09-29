
local myname, ns = ...


local hider = CreateFrame("Frame")
hider:SetScript("OnHide", GameTooltip_Hide)


function ns.ShowAbilityTooltip(self)
	local mechanic = self.info
	local followerTypeID = self.followerTypeID
	local ability = self.counterAbility

	ns.RefreshFollowers(followerTypeID)
	ns.RefreshInProgress(followerTypeID)

	hider:SetParent(self)
	self:SetScript("OnLeave", GameTooltip_Hide)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddLine(ability.name, 1,1,1)
	GameTooltip:AddLine(ability.description, nil,nil,nil, true)
	GameTooltip:AddLine(" ")

	for i,follower in pairs(ns.Followers(followerTypeID)) do
		if ns.FollowerHasAbilityID(follower, ability.id) then
			local name, status = ns.FollowerToString(follower)
			GameTooltip:AddDoubleLine(name, status, nil,nil,nil, 1,1,1)
		end
	end

	GameTooltip:Show()
end

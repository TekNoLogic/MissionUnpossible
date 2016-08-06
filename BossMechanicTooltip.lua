
local myname, ns = ...


local function SortFollowers(a, b)
	if not a then return false end
	if not b then return true end

	if a.level == 100 and b.level == 100 then
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


local function FollowerHasAbilityID(follower, abilityID)
	if not follower.isCollected then return false end

	local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
	for i,ability in pairs(abilities) do
		if ability.id == abilityID then return true end
	end

	return false
end


local function FollowerHasScavenger(follower)
	return FollowerHasAbilityID(follower, 79)
end


local function FollowerHasTreasureHunter(follower)
	return FollowerHasAbilityID(follower, 256)
end


local function FollowerHasExtraTraining(follower)
	return FollowerHasAbilityID(follower, 80)
end


local function FollowerHasEpicMount(follower)
	return FollowerHasAbilityID(follower, 221)
end


local qualities = {"C", "U", "R", "E", "L"}
function ns.FollowerToString(follower)
	local level = ITEM_QUALITY_COLORS[follower.quality].hex.. follower.level
	if follower.level == 100 then
		level = ITEM_QUALITY_COLORS[follower.quality].hex.. follower.iLevel
	end

	local colorblind = GetCVarBool("colorblindMode")
	if colorblind then level = level.. "-".. qualities[follower.quality] end

	local name = follower.name
	if FollowerHasScavenger(follower) then name = name.. " [££]" end
	if FollowerHasTreasureHunter(follower) then name = name.. " [$$]" end
	if FollowerHasExtraTraining(follower) then name = name.. " [++]" end
	if FollowerHasEpicMount(follower) then name = name.. " [>>]" end

	if ns.IsFollowerAvailable(follower.followerID) then
		return level.. "|cffffffff - ".. name.. "|r"
	else
		local namestr = level.. ITEM_QUALITY_COLORS[0].hex.. " - ".. name.. "|r"
		local status = C_Garrison.GetFollowerStatus(follower.followerID)

		if status == GARRISON_FOLLOWER_ON_MISSION then
			local timeleft = ns.GetFollowerTimeLeft(follower.followerID)
			if timeleft then
				return namestr, timeleft
			end
		end

		return namestr, ITEM_QUALITY_COLORS[0].hex..status.."|r"
	end
end


local f = CreateFrame("Frame")
f:SetScript("OnHide", GameTooltip_Hide)


local tip = GarrisonMissionMechanicTooltip
function tip.Show()
	RefreshFollowers()
	ns.RefreshInProgress()

	local _, anchor = tip:GetPoint(1)
	local mechanic = tip.Name:GetText()
	local desc = tip.Description:GetText()

	f:SetParent(anchor)
	anchor:SetScript("OnLeave", GameTooltip_Hide)

	GameTooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddLine(mechanic, 1,1,1)
	GameTooltip:AddLine(desc, nil,nil,nil, true)
	GameTooltip:AddLine(" ")

	for i,follower in pairs(followers) do
		if FollowerCanCounter(follower, mechanic) then
			local name, status = ns.FollowerToString(follower)
			GameTooltip:AddDoubleLine(name, status, nil,nil,nil, 1,1,1)
		end
	end

	GameTooltip:Show()
end

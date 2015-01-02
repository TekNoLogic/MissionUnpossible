
local myname, ns = ...


local tip = GarrisonMissionMechanicTooltip
local f = CreateFrame("Frame", nil, tip)


local function ResizeTooltip()
	local height = tip.Icon:GetHeight() + 28
	height = height + tip.Description:GetHeight()
	tip:SetHeight(height)
end


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
	followers = C_Garrison.GetFollowers()
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


local function FollowerHasExtraTraining(follower)
	return FollowerHasAbilityID(follower, 80)
end


local function FollowerToString(follower)
	local level = ITEM_QUALITY_COLORS[follower.quality].hex.. follower.level
	if follower.level == 100 then
		level = ITEM_QUALITY_COLORS[follower.quality].hex.. follower.iLevel
	end

	local name = follower.name
	if FollowerHasScavenger(follower) then name = name.. " [$$]" end
	if FollowerHasExtraTraining(follower) then name = name.. " [++]" end

	if ns.IsFollowerAvailable(follower.followerID) then
		return level.. "|cffffffff - ".. name
	else
		local namestr = level.. ITEM_QUALITY_COLORS[0].hex.. " - ".. name
		local status = C_Garrison.GetFollowerStatus(follower.followerID)

		if status == GARRISON_FOLLOWER_ON_MISSION then
			local timeleft = ns.GetFollowerTimeLeft(follower.followerID)
			if timeleft then
				return namestr.. " (".. timeleft.. ")|r"
			end
		end

		return namestr.. " (".. status.. ")|r"
	end
end


local function GetFollowerListForMechanic(mechanic)
	local str = ""
	for i,follower in pairs(followers) do
		if FollowerCanCounter(follower, mechanic) then
			str = str.. "\n".. FollowerToString(follower)
		end
	end
	return str
end


f:SetScript("OnShow", function(self)
	RefreshFollowers()
	ns.RefreshInProgress()

	local mechanic = tip.Name:GetText()


	local desc = tip.Description:GetText()
	desc = desc.. "|cffffffff\n".. GetFollowerListForMechanic(mechanic)
	tip.Description:SetText(desc)

	ResizeTooltip()
end)

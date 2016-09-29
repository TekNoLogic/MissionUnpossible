
local myname, ns = ...


local GREY = ITEM_QUALITY_COLORS[0].hex
local QUALITIES = {"C", "U", "R", "E", "L"}
local TAGS = {
	[79]  = " [££]", -- Scavenger
	[80]  = " [++]", -- Extra Training
	[221] = " [>>]", -- Epic Mount
	[256] = " [$$]", -- Treasure Hunter
}


local function FollowerHasAbilityID(follower, abilityID)
	if not follower.isCollected then return false end

	local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
	for i,ability in pairs(abilities) do
		if ability.id == abilityID then return true end
	end

	return false
end


function ns.FollowerToString(follower)
	local level = follower.isMaxLevel and follower.iLevel or folower.level
	level = ITEM_QUALITY_COLORS[follower.quality].hex.. level

	local colorblind = GetCVarBool("colorblindMode")
	if colorblind then level = level.. "-".. QUALITIES[follower.quality] end

	local name = follower.name
	for id,tag in pairs(TAGS) do
		if FollowerHasAbilityID(follower, id) then name = name.. tag end
	end

	if ns.IsFollowerAvailable(follower.followerID) then
		return level.. "|cffffffff - ".. name.. "|r"
	else
		local namestr = level.. GREY.. " - ".. name.. "|r"
		local status = C_Garrison.GetFollowerStatus(follower.followerID)

		if status == GARRISON_FOLLOWER_ON_MISSION then
			local timeleft = ns.GetFollowerTimeLeft(follower)
			if timeleft then
				return namestr, timeleft
			end
		end

		return namestr, GREY..status.."|r"
	end
end

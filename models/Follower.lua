
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


local followers = {}
function ns.Followers(type)
	return followers[type]
end


function ns.RefreshFollowers(type)
	followers[type] = C_Garrison.GetFollowers(type)
	table.sort(followers[type], SortFollowers)
end


function ns.FollowerHasAbilityID(follower, abilityID)
	if not follower.isCollected then return false end

	local abilities = C_Garrison.GetFollowerAbilities(follower.followerID)
	for i,ability in pairs(abilities) do
		if ability.id == abilityID then return true end
	end

	return false
end

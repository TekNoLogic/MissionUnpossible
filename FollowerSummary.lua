
local myname, ns = ...
if ns.is_six_one then return end


local tab = GarrisonMissionFrame.FollowerTab
local anchor1 = CreateFrame("Frame", nil, tab)
anchor1:SetPoint("LEFT", tab.NumFollowers, "RIGHT", 11, 7)
anchor1:SetSize(1,1)


local anchor2 = CreateFrame("Frame", nil, GarrisonLandingPage.FollowerList)
anchor2:SetPoint("LEFT", GarrisonLandingPage.HeaderBar, "LEFT", 170, 7)
anchor2:SetSize(1,1)


local container = CreateFrame("Frame", nil, anchor1)
container:SetAllPoints()


local function GetSearchBox()
	if GarrisonMissionFrameFollowers.SearchBox:IsVisible() then
	  return GarrisonMissionFrameFollowers.SearchBox
	elseif GarrisonLandingPage.FollowerList.SearchBox:IsVisible() then
		return GarrisonLandingPage.FollowerList.SearchBox
	end
end


local function OnClick(self)
	if not self.name then return end

	local searchbox = GetSearchBox()
	if searchbox then
		searchbox:SetText(self.name)
		searchbox.clearText = self.name
	end
end


local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(self.name)
	GameTooltip:AddLine("Click to filter followers", 1,1,1)
	GameTooltip:Show()
end


local lastframe
local function CreateMechanicButton()
	local f = CreateFrame("Button", nil, container, "GarrisonAbilityCounterTemplate")
	if lastframe then
		f:SetPoint("LEFT", lastframe, "RIGHT", 5, 0)
	else
		f:SetPoint("LEFT")
	end

	f:SetNormalFontObject(GameFontHighlightOutline)
	f:SetText("0")
	local fs = f:GetFontString()
	fs:ClearAllPoints()
	fs:SetPoint("TOP", f, "BOTTOM", 0, -2)

	f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	f.Border:Hide()

	f:SetScript("OnClick", OnClick)
	f:SetScript("OnEnter", OnEnter)
	f:SetScript("OnLeave", GameTooltip_Hide)

	lastframe = f
	return f
end


local frames = setmetatable({}, {__index = function(self, k)
	local f = CreateMechanicButton()
	self[k] = f
	return f
end})


local function EligibleFollower(follower)
	if not follower.isCollected then return false end
	if follower.status == GARRISON_FOLLOWER_INACTIVE then return false end
	if follower.status == GARRISON_FOLLOWER_WORKING then return false end
	return true
end


local GetAbility = C_Garrison.GetFollowerAbilityAtIndex
local GetMechanic = C_Garrison.GetFollowerAbilityCounterMechanicInfo
local counters = setmetatable({}, {__index = function(t,i) return 0 end})
local names, textures = {}, {}
local function Refresh()
	wipe(counters)

	local followers = C_Garrison.GetFollowers()
	for _,follower in pairs(followers) do
		if EligibleFollower(follower) then
			for i=1,4 do
				local abilityID = GetAbility(follower.followerID, i)
				if abilityID and abilityID > 0 then
					local mechanicID, name, tex = GetMechanic(abilityID)
					if mechanicID then
						counters[mechanicID] = counters[mechanicID] + 1
						names[mechanicID] = name
						textures[mechanicID] = tex
					end
				end
			end
		end
	end

	for i=1,10 do
		if names[i] then
			local frame = frames[i]
			frame:SetText(counters[i])
			frame.Icon:SetTexture(textures[i])
			frame.name = names[i]
		end
	end
end


local function OnShow(self)
	container:SetParent(self)
	container:SetAllPoints()
	Refresh()
end
anchor1:SetScript("OnShow", OnShow)
anchor2:SetScript("OnShow", OnShow)

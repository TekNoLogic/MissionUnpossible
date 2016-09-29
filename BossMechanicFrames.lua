
local myname, ns = ...


local ShowAbilityTooltip = ShowGarrisonFollowerMissionAbilityTooltip
local function OnEnter(self)
	if self.counterAbility then
		return ShowAbilityTooltip(self, self.counterAbility.id, self.followerTypeID)
	end

	return GarrisonMissionMechanic_OnEnter(self)
end


local frames = {}
local function CreateBossMechanicFrame()
	local parent = GarrisonMissionFrame.MissionTab.MissionList
	local template = "GarrisonMissionLargeMechanicTemplate"
	local frame = CreateFrame("Frame", nil, parent, template)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	label:SetPoint("BOTTOM", 0, -16)
	frame.label = label

	frame:SetScript("OnEnter", OnEnter)

	table.insert(frames, frame)

	return frame
end


function ns.GetBossMechanicFrame()
	for i,frame in pairs(frames) do
		if not frame:IsShown() then return frame end
	end

	return CreateBossMechanicFrame()
end


function ns.HideBossMechanicFrames()
	for i,frame in pairs(frames) do frame:Hide() end
end

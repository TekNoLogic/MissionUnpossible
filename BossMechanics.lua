
local myname, ns = ...


local frames = {}
local function CreateBossMechanicFrame()
	local parent = GarrisonMissionFrame.MissionTab.MissionList
	local template = "GarrisonMissionEnemyLargeMechanicTemplate"
	local f = CreateFrame("Frame", nil, parent, template)

	local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	label:SetPoint("BOTTOM", 0, -16)
	f.label = label

	table.insert(frames, f)

	return f
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

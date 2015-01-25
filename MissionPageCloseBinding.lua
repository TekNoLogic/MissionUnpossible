
local myname, ns = ...
if ns.is_six_one then return end


local mission = GarrisonMissionFrame.MissionTab.MissionPage

local frame = CreateFrame("Button", "MissionUnpossibleCloseBinder", mission)
frame:SetScript("OnClick", GarrisonMissionPage_Close)
frame:SetScript("OnHide", ClearOverrideBindings)
frame:SetScript("OnShow", function()
	SetOverrideBindingClick(frame, true, "ESCAPE", "MissionUnpossibleCloseBinder")
end)

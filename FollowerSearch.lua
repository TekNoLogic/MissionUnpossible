
local myname, ns = ...


local search = GarrisonMissionFrame.FollowerList.SearchBox
local f = CreateFrame("Frame", nil, search)
f:SetScript("OnShow", function()
	search.clearButton:Click()
end)

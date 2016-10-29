
local myname, ns = ...


ns.InitGarrison = {}
ns.InitOrderHall = {}


function ns.OnLoad()
	-- We know the Garrison UI has been loaded for sure
	for _,func in pairs(ns.InitGarrison) do func() end
	ns.InitGarrison = nil
end


function ns.ADDON_LOADED(event, addon)
	-- Blizzard_OrderHallUI will be loaded when we enter the order hall zone
	if addon ~= "Blizzard_OrderHallUI" then return end

	for _,func in pairs(ns.InitOrderHall) do func() end
	ns.UnregisterEvent("ADDON_LOADED")
	ns.InitOrderHall = nil
	ns.ADDON_LOADED = nil
end
ns.RegisterEvent("ADDON_LOADED")

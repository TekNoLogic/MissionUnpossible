
local myname, ns = ...


ns.InitGarrison = {}
ns.InitOrderHall = {}


function ns.OnLoad()
	-- We know the Garrison UI has been loaded for sure
	for _,func in pairs(ns.InitGarrison) do func() end
	ns.InitGarrison = nil
end


-- The OrderHall UI is bit more complicated...
function ns.GARRISON_MISSION_NPC_OPENED(event, garrison_type)
	if garrison_type == LE_FOLLOWER_TYPE_GARRISON_7_0 then
		for _,func in pairs(ns.InitOrderHall) do func() end
		ns.UnregisterEvent("GARRISON_MISSION_NPC_OPENED")
		ns.InitOrderHall = nil
	end
end
ns.RegisterEvent("GARRISON_MISSION_NPC_OPENED")


local myname, ns = ...


local name, _, _, enabled = GetAddOnInfo("tekDebug")
local player = UnitName("player")
local enabled = GetAddOnEnableState(player, "tekDebug") == 2
if enabled and not IsAddOnLoaded("tekDebug") then
	local succ, err = LoadAddOn(name)
end


local debugf = tekDebug and tekDebug:GetFrame(myname)
function ns.Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

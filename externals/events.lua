
local myname, ns = ...


local frame = CreateFrame("Frame")


function ns.RegisterEvent(event, func)
  frame:RegisterEvent(event)
  if func then
    if type(ns[event]) == "table" then
      table.insert(ns[event], func)
    elseif type(ns[event]) == "function" then
      ns[event] = {ns[event], func}
    else
      ns[event] = func
    end
  end
end


function ns.UnregisterEvent(event)
  frame:UnregisterEvent(event)
end


function ns.UnregisterAllEvents()
	frame:UnregisterAllEvents()
end


-- Handles special OnLogin code for when the PLAYER_LOGIN event is fired.
-- If our addon is loaded after that event is fired, then we call it immediately
-- after the OnLoad handler is processed.
local function ProcessOnLogin()
  if ns.OnLogin then
    ns.OnLogin()
    ns.OnLogin = nil
  end

  ProcessOnLogin = nil
  if not ns.PLAYER_LOGIN then frame:UnregisterEvent("PLAYER_LOGIN") end
end


-- Handle special OnLoad code when our addon has loaded, if present
-- Also initializes the savedvar for us, if ns.dbname or ns.dbpcname is set
-- If ns.ADDON_LOADED is defined, the ADDON_LOADED event is not unregistered
local function ProcessOnLoad(arg1)
  if arg1 ~= myname then return end

  if ns.dbname then
    local defaults = ns.dbdefaults or {}
    _G[ns.dbname] = setmetatable(_G[ns.dbname] or {}, {__index = defaults})
    ns.db = _G[ns.dbname]
  end

  if ns.dbpcname then
    local defaults = ns.dbpcdefaults or {}
    _G[ns.dbpcname] = setmetatable(_G[ns.dbpcname] or {}, {__index = defaults})
    ns.dbpc = _G[ns.dbpcname]
  end

  if type(ns.OnLoad) == "table" then
    for _,func in pairs(ns.OnLoad) do func() end
  elseif type(ns.OnLoad) == "function" then
    ns.OnLoad()
  end
  ns.OnLoad = nil

  ProcessOnLoad = nil
  if not ns.ADDON_LOADED then frame:UnregisterEvent("ADDON_LOADED") end

  if ns.dbdefaults or ns.dbpcdefaults then ns.RegisterEvent("PLAYER_LOGOUT") end

  if IsLoggedIn() then ProcessOnLogin()
  else frame:RegisterEvent("PLAYER_LOGIN") end
end


-- Removes the default values from the db and dbpc as we're logging out
local function ProcessLogout()
  if ns.dbdefaults then
    for i,v in pairs(ns.dbdefaults) do
      if ns.db[i] == v then ns.db[i] = nil end
    end
  end

  if ns.dbpcdefaults then
    for i,v in pairs(ns.dbpcdefaults) do
      if ns.dbpc[i] == v then ns.dbpc[i] = nil end
    end
  end
end


frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1, ...)
  if ProcessOnLoad and event == "ADDON_LOADED" then ProcessOnLoad(arg1) end
  if ProcessOnLogin and event == "PLAYER_LOGIN" then ProcessOnLogin() end

  if event == "PLAYER_LOGOUT" then ProcessLogout() end

  if type(ns[event]) == "table" then
    for _,func in pairs(ns[event]) do func(event, arg1, ...) end
  elseif type(ns[event]) == "function" then
    ns[event](event, arg1, ...)
  end
end)

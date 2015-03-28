
local myname, ns = ...


local mission = GarrisonMissionFrame.MissionTab.MissionPage
local search = GarrisonMissionFrame.FollowerList.SearchBox
local butt = CreateFrame("Frame", nil, search)
butt:SetSize(24, 24)
butt:SetPoint("LEFT", search, "RIGHT", 15, 5)

local icon = butt:CreateTexture(nil, "BORDER")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\garrison_building_barracks")

local tip = ns.NewTooltip(12)



local function IsMaxLevel(follower)
  if not follower.isCollected then return false end
  if follower.quality < 4 then return false end
  if follower.level < 100 then return false end
  return true
end


local GetAbility = C_Garrison.GetFollowerAbilityAtIndex
local GetMechanic = C_Garrison.GetFollowerAbilityCounterMechanicInfo
local function CanCounter(follower, mechanic)
  for i=1,4 do
    local abilityID = GetAbility(follower.followerID, i)
    if abilityID and abilityID > 0 then
      local mechanicID, name, tex = GetMechanic(abilityID)
      if mechanicID == mechanic then return tex end
    end
  end
end


local missiondetails
local GetUncounteredMechanics = C_Garrison.GetMissionUncounteredMechanics
local function IsShown(follower, mission)
  if not IsMaxLevel(follower) then return false end
  if not mission or mission.iLevel < 645 then return true end

  if not missiondetails then
    local mechs = GetUncounteredMechanics(mission.missionID)
    missiondetails = {}
    for _,mechIDs in pairs(mechs) do
      for _,mechID in pairs(mechIDs) do
        missiondetails[mechID] = true
      end
    end
  end

  for id in pairs(missiondetails) do
    if CanCounter(follower, id) then return true end
  end

  return false
end


local function CounterText(follower, mechanic)
  local tex = CanCounter(follower, mechanic)
  if tex then return "|T".. tex.. ":16|t"end
  return " "
end


local function FirstAbility(follower)
  if not IsMaxLevel(follower) then return 999 end

  for i=1,10 do
    if i ~= 5 and CanCounter(follower, i) then return i end
  end
end


local function LastAbility(follower)
  if not IsMaxLevel(follower) then return 999 end

  for i=10,1,-1 do
    if i ~= 5 and CanCounter(follower, i) then return i end
  end
end


local RACIALS = {}
for i=63,75 do RACIALS[i] = true end -- Core races
for i=252,255 do RACIALS[i] = true end -- Other races
local function RacialText(follower)
  local str = ""
  for i=1,6 do
    local traitID = C_Garrison.GetFollowerTraitAtIndex(follower.followerID, i)
    if RACIALS[traitID] then
      local icon = C_Garrison.GetFollowerAbilityIcon(traitID)
      if icon then str = str.. "|T".. icon.. ":16|t" end
    end
  end
  return str
end


local FIVEPERC = {[201] = true} -- Combat experience
for i=36,43 do FIVEPERC[i] = true end -- Slayers
for i=44,49 do FIVEPERC[i] = true end -- Environs
for i=7,9 do FIVEPERC[i] = true end
for i=76,77 do FIVEPERC[i] = true end
local function BonusText(follower)
  local str = ""
  for i=1,6 do
    local traitID = C_Garrison.GetFollowerTraitAtIndex(follower.followerID, i)
    if FIVEPERC[traitID] then
      local icon = C_Garrison.GetFollowerAbilityIcon(traitID)
      if icon then str = str.. "|T".. icon.. ":16|t" end
    end
  end
  return str
end


local function sorter(a,b)
  local fa = FirstAbility(a)
  local fb = FirstAbility(b)
  if fa == fb then
    return LastAbility(a) > LastAbility(b)
  else
    return fa < fb
  end
end

butt:SetScript("OnLeave", function() tip:Hide() end)
butt:SetScript("OnEnter", function(self)
  local mission = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
  missiondetails = nil

  local followers = C_Garrison.GetFollowers()
  table.sort(followers, sorter)

  -- tip:AnchorTo(self)
  tip:Clear()
  tip:ClearAllPoints()
  tip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")

  tip:AddLine("Follower abilities")
  tip:AddLine(" ")

  for i,follower in pairs(followers) do
    if IsShown(follower, mission) then
      local wag = CounterText(follower, 1)  -- Wild Aggression
      local mst = CounterText(follower, 2)  -- Massive Strike
      local gda = CounterText(follower, 3)  -- Group Damage
      local mde = CounterText(follower, 4)  -- Magic Debuff
      local dzo = CounterText(follower, 6)  -- Danger Zones
      local msw = CounterText(follower, 7)  -- Minion Swarms
      local psp = CounterText(follower, 8)  -- Powerful Spell
      local dmi = CounterText(follower, 9)  -- Deadly Minions
      local tba = CounterText(follower, 10) -- Timed Battle

      local racial = RacialText(follower)
      local bonus = BonusText(follower)

      tip:AddMultiLine(follower.name,
                       wag, mst, gda, mde, dzo, msw, psp, dmi, tba,
                       racial, bonus,
                       1,1,1)
    end
  end

  tip:Show()
end)

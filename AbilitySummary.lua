
local myname, ns = ...


local mechanics = {}


local function IsMaxLevel(follower)
  if not follower.isCollected then return false end
  if not follower.isMaxLevel then return false end
  if follower.quality < 4 then return false end
  return true
end


local GetAbility = C_Garrison.GetFollowerAbilityAtIndex
local GetMechanic = C_Garrison.GetFollowerAbilityCounterMechanicInfo
local GetSpec = C_Garrison.GetFollowerSpecializationAtIndex
local function CanCounter(follower, mechanic)
  for i=0,4 do
    local abilityID = i == 0 and GetSpec(follower.followerID, 1) or GetAbility(follower.followerID, i)
    if abilityID and abilityID > 0 then
      local mechanicID, name, tex = GetMechanic(abilityID)
      if mechanicID == mechanic then
        return GarrisonFollowerOptions[follower.followerTypeID].displayCounterAbilityInPlaceOfMechanic and C_Garrison.GetFollowerAbilityIcon(abilityID) or tex
      end
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
  if tex then return "|T".. tex.. ":16|t" end
  return " "
end


local function FirstAbility(follower)
  if not IsMaxLevel(follower) then return 999 end

  for i=1,#mechanics[follower.followerTypeID] do
    if CanCounter(follower, mechanics[follower.followerTypeID][i].id) then return i end
  end
  return 999
end


local function LastAbility(follower)
  if not IsMaxLevel(follower) then return 999 end

  for i=#mechanics[follower.followerTypeID], 1, -1 do
    if CanCounter(follower, mechanics[follower.followerTypeID][i].id) then return i end
  end
  return 999
end


local RACIALS = {}
for i=63,75 do RACIALS[i] = true end -- Core races
for i=252,255 do RACIALS[i] = true end -- Other races
for i=698,745 do RACIALS[i] = true end -- Order hall companions
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


local FIVEPERC = {
  [201] = true, -- Combat experience
  [663] = true, -- Order hall
  [688] = true,
  [691] = true,
  [748] = true,
}
for i=36,43 do FIVEPERC[i] = true end -- Slayers
for i=44,49 do FIVEPERC[i] = true end -- Environs
for i=7,9 do FIVEPERC[i] = true end
for i=76,77 do FIVEPERC[i] = true end
for i=683,685 do FIVEPERC[i] = true end -- Order hall
for i=694,697 do FIVEPERC[i] = true end
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

local function mechanicsorter(a,b)
  return a.id < b.id
end

local line = {}
local function enter(self)
  local mission = self.frame.MissionTab.MissionPage.missionInfo
  missiondetails = nil

  local followers = C_Garrison.GetFollowers(self.followertype)
  table.sort(followers, sorter)

  local tip = self.tip
  -- tip:AnchorTo(self)
  tip:Clear()
  tip:ClearAllPoints()
  tip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")

  tip:AddLine("Follower abilities")
  tip:AddLine(" ")

  for i,follower in pairs(followers) do
    if IsShown(follower, mission) then
      wipe(line)
      for _, mechanic in ipairs(self.mechanics) do
        table.insert(line, CounterText(follower, mechanic.id))
      end
      table.insert(line, RacialText(follower))
      table.insert(line, BonusText(follower))

      tip:AddMultiLine(follower.name, unpack(line))
    end
  end

  tip:Show()
end

local function Init(frame, followertype)
  local list = frame.MissionTab.MissionList
  local mission = frame.MissionTab.MissionPage
  local search = frame.FollowerList.SearchBox

  local butt = CreateFrame("Frame", nil, search)
  butt:SetSize(24, 24)
  butt:SetPoint("LEFT", search, "RIGHT", 15, 5)

  local icon = butt:CreateTexture(nil, "BORDER")
  icon:SetAllPoints()
  icon:SetTexture("Interface\\Icons\\garrison_building_barracks")

  butt:SetScript("OnLeave", function(self) self.tip:Hide() end)
  butt:SetScript("OnEnter", enter)

  butt.frame = frame
  butt.followertype = followertype
  butt.mechanics = {}
  for i, mechanic in ipairs(C_Garrison.GetAllEncounterThreats(followertype)) do
    if followertype ~= LE_FOLLOWER_TYPE_GARRISON_7_0 or mechanic.id > 10 then
      table.insert(butt.mechanics, mechanic)
    end
  end
  if followertype == LE_FOLLOWER_TYPE_GARRISON_6_0 then
    table.sort(butt.mechanics, mechanicsorter)
  end
  mechanics[followertype] = butt.mechanics

  butt.tip = ns.NewTooltip(#butt.mechanics + 3)
end

function ns.InitGarrison.AbilitySummary()
  Init(GarrisonMissionFrame, LE_FOLLOWER_TYPE_GARRISON_6_0)
end

function ns.InitOrderHall.AbilitySummary()
  Init(OrderHallMissionFrame, LE_FOLLOWER_TYPE_GARRISON_7_0)
end


local myname, ns = ...


local mission = GarrisonMissionFrame.MissionTab.MissionPage
local search = GarrisonMissionFrame.FollowerList.SearchBox
local butt = CreateFrame("Frame", nil, mission)
butt:SetSize(24, 24)
butt:SetPoint("LEFT", search, "RIGHT", 15, 5)

local icon = butt:CreateTexture(nil, "BORDER")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\garrison_building_barracks")

local tip = ns.NewTooltip(10)



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
      if mechanicID == mechanic then
        return "|T".. tex.. ":16|t"
      end
    end
  end

  return " "
end


butt:SetScript("OnLeave", function() tip:Hide() end)
butt:SetScript("OnEnter", function(self)
  local followers = C_Garrison.GetFollowers()

  -- tip:AnchorTo(self)
  tip:Clear()
  tip:ClearAllPoints()
  tip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")

  tip:AddLine("Follower abilities")
  tip:AddLine(" ")

  for i,follower in pairs(followers) do
    if IsMaxLevel(follower) then
      local wag = CanCounter(follower, 1)  -- Wild Aggression
      local mst = CanCounter(follower, 2)  -- Massive Strike
      local gda = CanCounter(follower, 3)  -- Group Damage
      local mde = CanCounter(follower, 4)  -- Magic Debuff
      local dzo = CanCounter(follower, 6)  -- Danger Zones
      local msw = CanCounter(follower, 7)  -- Minion Swarms
      local psp = CanCounter(follower, 8)  -- Powerful Spell
      local dmi = CanCounter(follower, 9)  -- Deadly Minions
      local tba = CanCounter(follower, 10) -- Timed Battle

      tip:AddMultiLine(follower.name,
                       wag, mst, gda, mde, dzo, msw, psp, dmi, tba,
                       1,1,1)
    end
  end

  tip:Show()
end)

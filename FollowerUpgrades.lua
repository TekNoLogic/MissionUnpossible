
local myname, ns = ...


local butts = {}
local function Update()
	local id = GarrisonMissionFrame.FollowerTab.followerID
	if not id then return end
	local wid, wlvl, aid, alvl = C_Garrison.GetFollowerItems(id)
	if not wlvl or not alvl then return end

	for id,butt in pairs(butts) do
		local count = GetItemCount(id)
		local hide = count == 0
		if id == 114622 and wlvl >= 645 then hide = true
		elseif id == 114081 and wlvl >= 630 then hide = true
		elseif id == 114616 and wlvl >= 615 then hide = true
		elseif id == 114746 and alvl >= 645 then hide = true
		elseif id == 114806 and alvl >= 630 then hide = true
		elseif id == 114807 and alvl >= 615 then hide = true
		end

		if hide then
			butt:Disable()
			butt:SetAlpha(0.25)
		else
			butt:Enable()
			butt:SetAlpha(1)
		end
	end
end
ns.RegisterEvent("BAG_UPDATE_DELAYED", Update)
hooksecurefunc(GarrisonMissionFrame.FollowerTab, "ShowFollower", Update)


local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:SetHyperlink("item:"..self.id)
	GameTooltip:Show()
end


local function MakeButt(id)
	local butt = CreateFrame("Button", nil, GarrisonMissionFrame.FollowerTab.ItemWeapon, "SecureActionButtonTemplate")
	butt:SetSize(19, 19)

	local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(id)
	local icon = butt:CreateTexture(nil, "BORDER")
	icon:SetAllPoints()
	icon:SetTexture(texture)

	butt.id = id

	butt:SetAttribute("type", "macro")
	butt:SetAttribute("macrotext",
		"/use item:" .. id.. "\n"..
		"/run C_Garrison.CastSpellOnFollower(GarrisonMissionFrame.FollowerTab.followerID)"
	)

	butt:SetScript("OnEnter", OnEnter)
	butt:SetScript("OnLeave", GameTooltip_Hide)

	butts[id] = butt

	return butt
end


local weapon615 = MakeButt(114616)
local weapon630 = MakeButt(114081)
local weapon645 = MakeButt(114622)
local weapon3 = MakeButt(114128)
local weapon6 = MakeButt(114129)
local weapon9 = MakeButt(114131)
local armor615 = MakeButt(114807)
local armor630 = MakeButt(114806)
local armor645 = MakeButt(114746)
local armor3 = MakeButt(114745)
local armor6 = MakeButt(114808)
local armor9 = MakeButt(114822)
weapon645:SetPoint("TOPRIGHT", GarrisonMissionFrame.FollowerTab.ItemWeapon, -2, -2)
weapon630:SetPoint("TOPRIGHT", weapon645, "TOPLEFT")
weapon615:SetPoint("TOPRIGHT", weapon630, "TOPLEFT")
weapon9:SetPoint("TOPRIGHT", weapon645, "BOTTOMRIGHT")
weapon6:SetPoint("TOPRIGHT", weapon9, "TOPLEFT")
weapon3:SetPoint("TOPRIGHT", weapon6, "TOPLEFT")
armor645:SetPoint("TOPRIGHT", GarrisonMissionFrame.FollowerTab.ItemArmor, -2, -2)
armor630:SetPoint("TOPRIGHT", armor645, "TOPLEFT")
armor615:SetPoint("TOPRIGHT", armor630, "TOPLEFT")
armor9:SetPoint("TOPRIGHT", armor645, "BOTTOMRIGHT")
armor6:SetPoint("TOPRIGHT", armor9, "TOPLEFT")
armor3:SetPoint("TOPRIGHT", armor6, "TOPLEFT")

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local SafeTranslate = LANG.TryTranslation

ENT.ShopChats = {
	"Joe.Shop.1",
	"Joe.Shop.2"
}

ENT.ShopErrors = {
	Credits = false,
	Limited = false,
	Owned = {},
	Sandbox = false
}

local fieldstbl = {"name", "type", "desc"}

local color_darkened = Color(255,255,255, 80)
local color_bad = Color(220, 60, 60, 255)
local color_good = Color(0, 200, 0, 255)
local color_slot  = Color(180, 50, 40, 255)

-- Creates tabel of labels showing the status of ordering prerequisites
function ENT:PreqLabels(parent, x, y)
	local errCheck = vgui.Create("DLabel", parent)
	errCheck:SetTooltip(GetTranslation("equip_help_cost"))
	errCheck:SetPos(x, y)
	errCheck:SetText("")
	errCheck.Check = function(s, sel)
		local ply = LocalPlayer()

		local credits = ply:GetCredits()
		if credits <= 0 then
			return false, !self.ShopErrors.Credits, GetPTranslation("equip_cost", {num = credits})
		end

		local isWeapon = isstring(sel.id)
		if isWeapon and ply:HasWeapon(sel.id) then
			return false, !self.ShopErrors.Owned[sel.id], GetPTranslation("equip_carry_slot", {slot = sel.slot})
		elseif !isWeapon and LocalPlayer().HasEquipmentItem and LocalPlayer():HasEquipmentItem(sel.id) then
			return false, !self.ShopErrors.Owned[sel.id], GetTranslation("equip_carry_own")
		end

		return true, true, GetPTranslation("equip_cost", {num = credits})
	end

	errCheck:SetFont("TabLarge")

	return function(selected)
		local result, check, text = errCheck:Check(selected)
		errCheck:SetTextColor(result and color_good or color_bad)
		errCheck:SetText(text)
		errCheck:SizeToContents()

		return check
	end
end

function ENT:ShowShopScreen(chatOverride)
	local ply = LocalPlayer()
	if !IsValid(ply) then return end

	local credits = ply.GetCredits and ply:GetCredits() or 0
	local can_order = !self.ShopErrors.Credits or credits > 0

	local dframe = vgui.Create("DFrame")
	local w, h = 570, 412
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle(GetTranslation("equip_title"))
	dframe:SetVisible(true)
	dframe:ShowCloseButton(true)
	dframe:SetMouseInputEnabled(true)
	dframe:SetDeleteOnClose(true)

	local m = 5

	local dsheet = vgui.Create("DPropertySheet", dframe)

	-- Add a callback when switching tabs
	local oldfunc = dsheet.SetActiveTab
	dsheet.SetActiveTab = function(s, new)
		if s.m_pActiveTab != new and s.OnTabChanged then
			s:OnTabChanged(s.m_pActiveTab, new)
		end
		oldfunc(s, new)
	end

	dsheet:SetPos(0,0)
	dsheet:StretchToParent(m,m + 25,m,m)
	local padding = dsheet:GetPadding()

	local dequip = vgui.Create("DPanel", dsheet)
	dequip:SetPaintBackground(false)
	dequip:StretchToParent(padding,padding,padding,padding)

	-- Determine if we already have equipment
	local owned_ids = {}
	for _, wep in ipairs(ply:GetWeapons()) do
		if IsValid(wep) and wep.IsEquipment and wep:IsEquipment() then
			table.insert(owned_ids, wep:GetClass())
		end
	end

	--- Construct icon listing
	local dlist = vgui.Create("EquipSelect", dequip)
	dlist:SetPos(0,0)
	dlist:SetSize(216, h - 75)
	dlist:EnableVerticalScrollbar()
	dlist:EnableHorizontal(true)
	dlist:SetPadding(4)


	local items = self.EquipmentItems

	for k, item in pairs(items) do
		local ic = nil
		local isWeapon = isstring(item.id)

		-- Create icon panel
		if item.material then
			if !isWeapon then
				ic = vgui.Create("SimpleIcon", dlist)
			else
				ic = vgui.Create("LayeredIcon", dlist)
			end

			-- Slot marker icon
			if isWeapon then
				local slot = vgui.Create("SimpleIconLabelled")
				slot:SetIcon("mall_member/figardo/slotcap")
				slot:SetIconColor(--[[color_slot[ply:GetRole()] or]] color_slot)
				slot:SetIconSize(16)

				slot:SetIconText(item.slot)

				slot:SetIconProperties(COLOR_WHITE,
									"DefaultBold",
									{opacity = 220, offset = 1},
									{10, 8})

				ic:AddLayer(slot)
				ic:EnableMousePassthrough(slot)
			end

			ic:SetIconSize(64)
			ic:SetIcon(item.material)
		else
			ErrorNoHalt("Equipment item does not have model or material specified: " .. tostring(item) .. "\n")
		end

		ic.item = item
		ic.idx = k

		local tip = SafeTranslate(item.name) .. " (" .. SafeTranslate(item.type) .. ")"
		ic:SetTooltip(tip)

		-- If we cannot order this item, darken it
		if !can_order or
			-- already owned
			(self.ShopErrors.Owned[item.id] and
			(tonumber(item.id) and ply:HasEquipmentItem(tonumber(item.id)) or table.HasValue(owned_ids, item.id))) then
		-- 	-- already carrying a weapon for this slot
		-- 	(self.ShopErrors.Slot and isWeapon and !CanCarryWeapon(item)) then

			ic:SetIconColor(color_darkened)
		end

		dlist:AddPanel(ic)
	end

	local dlistw = 216

	local bw, bh = 100, 25

	local dih = h - bh - m * 5
	local diw = w - dlistw - m * 6 - 2
	local dinfobg = vgui.Create("DPanel", dequip)
	dinfobg:SetPaintBackground(false)
	dinfobg:SetSize(diw, dih)
	dinfobg:SetPos(dlistw + m, 0)

	local dinfo = vgui.Create("ColoredBox", dinfobg)
	dinfo:SetColor(Color(90, 90, 95))
	dinfo:SetPos(0,0)
	dinfo:StretchToParent(0, 0, 0, dih - 135)

	local dfields = {}
	for _, k in ipairs(fieldstbl) do
		dfields[k] = vgui.Create("DLabel", dinfo)
		dfields[k]:SetTooltip(GetTranslation("equip_spec_" .. k))
		dfields[k]:SetPos(m * 3, m * 2)
		dfields[k]:SetText("")
	end

	dfields.name:SetFont("TabLarge")

	dfields.type:SetFont("DermaDefault")
	dfields.type:MoveBelow(dfields.name)

	dfields.desc:SetFont("DermaDefaultBold")
	dfields.desc:SetContentAlignment(7)
	dfields.desc:MoveBelow(dfields.type, 1)

	local dhelp = vgui.Create("ColoredBox", dinfobg)
	dhelp:SetColor(Color(90, 90, 95))
	dhelp:SetSize(diw, dih - 325)
	dhelp:MoveBelow(dinfo, m)

	local update_preqs = self:PreqLabels(dhelp, m * 3, m * 2)

	dhelp:SizeToContents()

	local dchat = vgui.Create("ColoredBox", dinfobg)
	dchat:SetColor(Color(50, 50, 50))
	dchat:SetSize(diw, dih - 290)
	dchat:MoveBelow(dhelp, m)

	local dface = vgui.Create("DTJFace", dchat)
	dface:SetPos(m, m)
	dface:SetSize(64, 64)

	dface:SetFace(self.FaceFolder, "smile")
	for _, ent in ipairs(self:GetChildren()) do
		if ent:GetClass() != "tj_hat" then continue end

		dface.Hat = self.HatTexture
		break
	end

	local dtext = vgui.Create("RichText", dchat)
	dtext:SetBGColor(255, 0, 0, 255)
	dtext:SetSize(diw - 64 - (m * 4), 128)
	dtext:MoveRightOf(dface, m * 2)
	dtext:AlignTop(m)
	dtext:SetVerticalScrollbarEnabled(false)

	local text = self:ChatToString(chatOverride or self:GetShopChat())
	dtext:SetText(text)

	function dtext:PerformLayout()
		self:SetFontInternal("TabLarge")
	end

	dchat:SizeToContents()

	local dconfirm = vgui.Create("DButton", dinfobg)
	dconfirm:SetPos(0, dih - bh * 2)
	dconfirm:SetSize(bw, bh)
	dconfirm:SetDisabled(true)
	dconfirm:SetText(GetTranslation("equip_confirm"))


	dsheet:AddSheet(GetTranslation("equip_tabtitle"), dequip, "icon16/bomb.png", false, false, GetTranslation("equip_tooltip_main"))


	-- couple panelselect with info
	dlist.OnActivePanelChanged = function(s, _, new)
		for k,v in pairs(new.item) do
			if dfields[k] then
				dfields[k]:SetText(SafeTranslate(v))
				dfields[k]:SizeToContents()
			end
		end

		-- Trying to force everything to update to
		-- the right size is a giant pain, so just
		-- force a good size.
		dfields.desc:SetTall(70)

		can_order = update_preqs(new.item)

		if new.item.chat then
			dtext:SetText(self:ChatToString(new.item.chat.text))
			dface:SetFace(self.FaceFolder, new.item.chat.face)
		end

		dconfirm:SetDisabled(!can_order)
	end

	-- select first
	-- dlist:SelectPanel(dlist:GetItems()[1])

	-- prep confirm action
	dconfirm.DoClick = function()
		local pnl = dlist.SelectedPanel
		if !pnl or !pnl.item then return end

		dframe:Close()

		if ply:GetCredits() == 0 then
			self.ShopErrors.Credits = true

			if engine.ActiveGamemode() == "terrortown" then
				return self:ShowChatScreen({face = "neutral", text = "Joe.Shop.NoCredits.1"})
			else
				return self:ShowChatScreen({face = "smirk", text = "Joe.Shop.GMCredits.1"})
			end
		end

		local id = pnl.item.id
		if tonumber(id) then
			if ply:HasEquipmentItem(id) then
				self.ShopErrors.Owned[id] = true
				self.TwoDisguisers = id == 4 -- EQUIP_DISGUISE

				return self:ShowChatScreen({face = "smile", text = "Joe.Shop.HasPassive.1"})
			end
		elseif ply:HasWeapon(id) then
			self.ShopErrors.Owned[id] = true
			return self:ShowChatScreen({face = "grin", text = "Joe.Shop.NoSpace.1"})
		end

		local choice = pnl.idx
		net.Start("TraitorJoe_BuyItem")
			net.WriteUInt(choice, 5)
		net.SendToServer()

		if engine.ActiveGamemode() != "terrortown" and !self.ShopErrors.Sandbox then
			self.ShopErrors.Sandbox = true
			return self:ShowChatScreen({face = "grin", text = "Joe.Shop.Sandbox.1"})
		end

		self:ShowShopScreen("Joe.Shop.Thanks")
	end

	-- update some basic info, may have changed in another tab
	-- specifically the number of credits in the preq list
	dsheet.OnTabChanged = function(s, old, new)
		if !IsValid(new) then return end

		if new:GetPanel() == dequip then
			can_order = update_preqs(dlist.SelectedPanel.item)
			dconfirm:SetDisabled(!can_order)
		end
	end

	local dcancel = vgui.Create("DButton", dframe)
	dcancel:SetPos(w - 13 - bw, h - bh - 16)
	dcancel:SetSize(bw, bh)
	dcancel:SetDisabled(false)
	dcancel:SetText(GetTranslation("close"))
	dcancel.DoClick = function() dframe:Close() end

	dframe:MakePopup()
	dframe:SetKeyboardInputEnabled(false)

	return dframe
end

function ENT:GetShopChat()
	return self.ShopChats[math.random(#self.ShopChats)]
end
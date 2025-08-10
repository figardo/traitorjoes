if game.GetMap() != "mall_store_size" then return end

if !TRAITORJOE then
	TRAITORJOE = {
		Annoyances = {},
		BoughtItems = {},
		Joe = {
			Annoyances = {
				Queue = {},
				Done = {}
			},
			Members = {},
			ItemsBought = SERVER and {} or 0,
			Jail = {}
		},
		Tony = {
			Annoyances = {
				Queue = {},
				Done = {}
			}
		},
		BKU = {},
		Base = {}
	}
end

-- anything copied directly from ttt which we'll let the gamemode handle
if engine.ActiveGamemode() != "terrortown" then
	COLOR_WHITE  = Color(255, 255, 255, 255)
	COLOR_BLACK  = Color(0, 0, 0, 255)
	COLOR_GREEN  = Color(0, 255, 0, 255)
	COLOR_DGREEN = Color(0, 100, 0, 255)
	COLOR_RED    = Color(255, 0, 0, 255)
	COLOR_YELLOW = Color(200, 200, 0, 255)
	COLOR_LGRAY  = Color(200, 200, 200, 255)
	COLOR_BLUE   = Color(0, 0, 255, 255)
	COLOR_NAVY   = Color(0, 0, 100, 255)
	COLOR_PINK   = Color(255, 0, 255, 255)
	COLOR_ORANGE = Color(250, 100, 0, 255)
	COLOR_OLIVE  = Color(100, 100, 0, 255)

	LANG = {}

	if CLIENT then
		surface.CreateFont("TargetIDSmall2", {font = "TargetID", size = 16, weight = 1000})
		surface.CreateFont("DefaultBold", {font = "Tahoma", size = 13, weight = 1000})
		surface.CreateFont("TabLarge", {font = "Tahoma", size = 13, weight = 700, shadow = true, antialias = false})
		surface.CreateFont("TimeLeft", {font = "Trebuchet24", size = 24, weight = 800})
		surface.CreateFont("HealthAmmo", {font = "Trebuchet24", size = 24, weight = 750})
		-- surface.CreateFont("Trebuchet22", {font = "Trebuchet MS", size = 22, weight = 900})

		local PANEL = {}

		AccessorFunc( PANEL, "m_bBorder", "Border" )
		AccessorFunc( PANEL, "m_Color", "Color" )

		function PANEL:Init()
			self:SetBorder( true )
			self:SetColor( Color( 0, 255, 0, 255 ) )
		end

		function PANEL:Paint()
			surface.SetDrawColor( self.m_Color.r, self.m_Color.g, self.m_Color.b, 255 )
			self:DrawFilledRect()
		end

		function PANEL:PaintOver()
			if !self.m_bBorder then return end

			surface.SetDrawColor( 0, 0, 0, 255 )
			self:DrawOutlinedRect()
		end
		derma.DefineControl( "ColoredBox", "", PANEL, "DPanel" )

		PANEL = {}

		function PANEL:Init()
			self.Label = vgui.Create("DLabel", self)
			self.Label:SetPos(0, 0)

			self.Scroll = vgui.Create("DVScrollBar", self)
		end

		function PANEL:GetLabel() return self.Label end

		function PANEL:OnMouseWheeled(dlta)
			if !self.Scroll then return end

			self.Scroll:AddScroll(dlta * -2)

			self:InvalidateLayout()
		end

		function PANEL:SetScrollEnabled(st) self.Scroll:SetEnabled(st) end

		-- enable/disable scrollbar depending on content size
		function PANEL:UpdateScrollState()
			if !self.Scroll then return end

			self.Scroll:SetScroll(0)
			self:SetScrollEnabled(false)

			self.Label:SetSize(self:GetWide(), self:GetTall())

			self.Label:SizeToContentsY()

			self:SetScrollEnabled(self.Label:GetTall() > self:GetTall())

			self.Label:InvalidateLayout(true)
			self:InvalidateLayout(true)
		end

		function PANEL:SetText(txt)
			if !self.Label then return end

			self.Label:SetText(txt)
			self:UpdateScrollState()

			-- I give up. VGUI, you have won. Here is your ugly hack to make the label
			-- resize to the proper height, after you have completely mangled it the
			-- first time I call SizeToContents. I don't know how or what happens to the
			-- Label's internal state that makes it work when resizing a second time a
			-- tick later (it certainly isn't any variant of PerformLayout I can find),
			-- but it does.
			local pnl = self.Panel
			timer.Simple(0, function()
				if IsValid(pnl) then
					pnl:UpdateScrollState()
				end
			end)
		end

		function PANEL:PerformLayout()
			if !self.Scroll then return end

			self.Label:SetVisible(self:IsVisible())

			self.Scroll:SetPos(self:GetWide() - 16, 0)
			self.Scroll:SetSize(16, self:GetTall())

			local was_on = self.Scroll.Enabled
			self.Scroll:SetUp(self:GetTall(), self.Label:GetTall())
			self.Scroll:SetEnabled(was_on) -- setup mangles enabled state

			self.Label:SetPos( 0, self.Scroll:GetOffset() )
			self.Label:SetSize( self:GetWide() - (self.Scroll.Enabled and 16 or 0), self.Label:GetTall() )
		end

		vgui.Register("ScrollLabel", PANEL, "Panel")

		local matHover = Material( "vgui/spawnmenu/hover" )

		PANEL = {}

		AccessorFunc( PANEL, "m_iIconSize",         "IconSize" )

		function PANEL:Init()
			self.Icon = vgui.Create( "DImage", self )
			self.Icon:SetMouseInputEnabled( false )
			self.Icon:SetKeyboardInputEnabled( false )

			self.animPress = Derma_Anim( "Press", self, self.PressedAnim )

			self:SetIconSize(64)
		end

		function PANEL:OnMousePressed( mcode )
			if mcode == MOUSE_LEFT then
				self:DoClick()
				self.animPress:Start(0.1)
			end
		end

		function PANEL:OnMouseReleased()
		end

		function PANEL:DoClick()
		end

		function PANEL:OpenMenu()
		end

		function PANEL:ApplySchemeSettings()
		end

		function PANEL:OnCursorEntered()
			self.PaintOverOld = self.PaintOver
			self.PaintOver = self.PaintOverHovered
		end

		function PANEL:OnCursorExited()
			if self.PaintOver == self.PaintOverHovered then
				self.PaintOver = self.PaintOverOld
			end
		end

		function PANEL:PaintOverHovered()
			if self.animPress:Active() then return end

			surface.SetDrawColor( 255, 255, 255, 80 )
			surface.SetMaterial( matHover )
			self:DrawTexturedRect()
		end

		function PANEL:PerformLayout()
			if self.animPress:Active() then return end
			self:SetSize( self.m_iIconSize, self.m_iIconSize )
			self.Icon:StretchToParent( 0, 0, 0, 0 )
		end

		function PANEL:SetIcon( icon )
			self.Icon:SetImage(icon)
		end

		function PANEL:GetIcon()
			return self.Icon:GetImage()
		end

		function PANEL:SetIconColor(clr)
			self.Icon:SetImageColor(clr)
		end

		function PANEL:Think()
			self.animPress:Run()
		end

		function PANEL:PressedAnim( anim, delta, data )
			if anim.Started then
				return
			end

			if anim.Finished then
				self.Icon:StretchToParent( 0, 0, 0, 0 )
				return
			end

			local border = math.sin( delta * math.pi ) * (self.m_iIconSize * 0.05 )
			self.Icon:StretchToParent( border, border, border, border )
		end

		vgui.Register( "SimpleIcon", PANEL, "Panel" )

		PANEL = {}

		function PANEL:Init()
			self.Layers = {}
		end

		-- Add a panel to this icon. Most recent addition will be the top layer.
		function PANEL:AddLayer(pnl)
			if !IsValid(pnl) then return end

			pnl:SetParent(self)

			pnl:SetMouseInputEnabled(false)
			pnl:SetKeyboardInputEnabled(false)

			table.insert(self.Layers, pnl)
		end

		function PANEL:PerformLayout()
			if self.animPress:Active() then return end
			self:SetSize( self.m_iIconSize, self.m_iIconSize )
			self.Icon:StretchToParent( 0, 0, 0, 0 )

			for _, p in ipairs(self.Layers) do
				p:SetPos(0, 0)
				p:InvalidateLayout()
			end
		end

		function PANEL:EnableMousePassthrough(pnl)
			for _, p in pairs(self.Layers) do
				if p == pnl then
					p.OnMousePressed  = function(s, mc) s:GetParent():OnMousePressed(mc) end
					p.OnCursorEntered = function(s) s:GetParent():OnCursorEntered() end
					p.OnCursorExited  = function(s) s:GetParent():OnCursorExited() end

					p:SetMouseInputEnabled(true)
				end
			end
		end

		vgui.Register("LayeredIcon", PANEL, "SimpleIcon")

		PANEL = {}

		AccessorFunc(PANEL, "IconText", "IconText")
		AccessorFunc(PANEL, "IconTextColor", "IconTextColor")
		AccessorFunc(PANEL, "IconFont", "IconFont")
		AccessorFunc(PANEL, "IconTextShadow", "IconTextShadow")
		AccessorFunc(PANEL, "IconTextPos", "IconTextPos")

		function PANEL:Init()
			self:SetIconText("")
			self:SetIconTextColor(Color(255, 200, 0))
			self:SetIconFont("TargetID")
			self:SetIconTextShadow({opacity = 255, offset = 2})
			self:SetIconTextPos({32, 32})

			-- DPanelSelect loves to overwrite its children's PaintOver hooks and such,
			-- so have to use a dummy panel to do some custom painting.
			self.FakeLabel = vgui.Create("Panel", self)
			self.FakeLabel.PerformLayout = function(s) s:StretchToParent(0,0,0,0) end

			self:AddLayer(self.FakeLabel)

			return self.BaseClass.Init(self)
		end

		function PANEL:PerformLayout()
			self:SetLabelText(self:GetIconText(), self:GetIconTextColor(), self:GetIconFont(), self:GetIconTextPos())

			return self.BaseClass.PerformLayout(self)
		end

		function PANEL:SetIconProperties(color, font, shadow, pos)
			self:SetIconTextColor( color  or self:GetIconTextColor())
			self:SetIconFont(      font   or self:GetIconFont())
			self:SetIconTextShadow(shadow or self:GetIconShadow())
			self:SetIconTextPos(   pos or self:GetIconTextPos())
		end

		function PANEL:SetLabelText(text, color, font, pos)
			if self.FakeLabel then
				local spec = {pos = pos, color = color, text = text, font = font, xalign = TEXT_ALIGN_CENTER, yalign = TEXT_ALIGN_CENTER}

				local shadow = self:GetIconTextShadow()
				local opacity = shadow and shadow.opacity or 0
				local offset = shadow and shadow.offset or 0

				local drawfn = shadow and draw.TextShadow or draw.Text

				self.FakeLabel.Paint = function()
											drawfn(spec, offset, opacity)
										end
			end
		end

		vgui.Register("SimpleIconLabelled", PANEL, "LayeredIcon")

		-- quick, very basic override of DPanelSelect
		PANEL = {}
		local function DrawSelectedEquipment(pnl)
			surface.SetDrawColor(255, 200, 0, 255)
			surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
		end

		function PANEL:SelectPanel(pnl)
			self.BaseClass.SelectPanel(self, pnl)
			if pnl then
				pnl.PaintOver = DrawSelectedEquipment
			end
		end
		vgui.Register("EquipSelect", PANEL, "DPanelSelect")

		-- Translation
		LANG.Strings = {}
		local cached_active
		function LANG.CreateLanguage(name)
			if !LANG.Strings[name] then
				LANG.Strings[name] = {}
			end

			cached_active = LANG.Strings[name]

			return LANG.Strings[name]
		end

		function LANG.GetTranslation(name)
			return cached_active[name]
		end

		function LANG.GetParamTranslation(name, params)
			return cached_active[name]:gsub("{(%w+)}", params)
		end

		function LANG.TryTranslation(name)
			return cached_active[name] or name
		end

		local gmod_language = GetConVar("gmod_language")
		local gmodToTTT = {
			["en"] = "english",
			["pt-br"] = "brazilian_portuguese",
			["fr"] = "french",
			["de"] = "german",
			["it"] = "italian",
			["ja"] = "japanese",
			["ru"] = "russian",
			["zh-cn"] = "simpchinese",
			["es"] = "spanish",
			["sv-se"] = "swedish",
			["zh-tw"] = "tradchinese",
			["tr"] = "turkish",
			["uk"] = "ukrainian",
		}
		local function CreateTTTLocalization()
			local lang = gmod_language:GetString():lower()
			lang = gmodToTTT[lang] or "english"

			if LANG.Strings[lang] then
				cached_active = LANG.Strings[lang]
			else
				RunString(file.Read("gamemodes/terrortown/gamemode/lang/" .. lang .. ".lua", "MOD"))
			end
		end

		CreateTTTLocalization()
		cvars.AddChangeCallback("gmod_language", CreateTTTLocalization)

		net.Receive("TraitorJoe_LangMsg", function()
			chat.AddText(LANG.GetTranslation(net.ReadString()))
		end)

		net.Receive("TraitorJoe_BuyItem", function()
			TRAITORJOE.Joe.ItemsBought = net.ReadUInt(3)
		end)

		hook.Add("HUDDrawTargetID", "TraitorJoesDisguiserFunction", function()
			local tr = util.GetPlayerTrace(LocalPlayer())
			local trace = util.TraceLine(tr)
			if !trace.Hit or !trace.HitNonWorld then return end

			local ent = trace.Entity
			if !ent:IsPlayer() then return end

			if ent:GetNWBool("disguised", false) then return false end
		end)
	else
		util.AddNetworkString("TraitorJoe_LangMsg")

		function LANG.Msg(ply, msg)
			net.Start("TraitorJoe_LangMsg")
				net.WriteString(msg)
			net.Send(ply)
		end

		hook.Add("ScalePlayerDamage", "TraitorJoesBodyArmor", function(ply, hitgroup, dmginfo)
			if dmginfo:IsBulletDamage() and ply:HasEquipmentItem(EQUIP_ARMOR) then
				-- Body armor nets you a damage reduction.
				dmginfo:ScaleDamage(0.7)
			end
		end)

		local function SetDisguise(ply, state)
			if !IsValid(ply) then return end

			if ply:HasEquipmentItem(EQUIP_DISGUISE) then
				if hook.Run("TTTToggleDisguiser", ply, state) then return end

				ply:SetNWBool("disguised", state)
				LANG.Msg(ply, state and "disg_turned_on" or "disg_turned_off")
			end
		end
		concommand.Add("ttt_set_disguise", SetDisguise)

		hook.Add("PlayerButtonUp", "TraitorJoesDisguiserToggle", function(ply, btn)
			if btn == KEY_PAD_ENTER and IsValid(ply) and ply:Alive() then
				SetDisguise(ply, !ply:GetNWBool("disguised", false))
			end
		end)

		hook.Add("PlayerCanPickupWeapon", "TraitorJoesWeaponCheck", function(ply, wep)
			if !IsValid(wep) or !IsValid(ply) then return end
			if ply:Team() == TEAM_SPECTATOR then return false end
			if !wep.Base or !wep.Base:StartsWith("weapon_tttbase") then return end

			if ply:HasWeapon(wep:GetClass()) or (wep.Kind and wep.Kind >= WEAPON_EQUIP and wep.IsDropped and !ply:KeyDown(IN_USE)) then
				return false
			end

			local tr = util.TraceEntity({start = wep:GetPos(), endpos = ply:GetShootPos(), mask = MASK_SOLID}, wep)
			if tr.Fraction == 1.0 or tr.Entity == ply then
				wep:SetPos(ply:GetShootPos())
			end

			return true
		end)
	end
end

if CLIENT then
	local PANEL = {}

	function PANEL:Init()
		self.imgAvatar = vgui.Create( "DImage", self )
		self.imgAvatar:SetMouseInputEnabled( false )
		self.imgAvatar:SetKeyboardInputEnabled( false )
		self.imgAvatar.PerformLayout = function(s) s:Center() end

		self:SetAvatarSize(32)

		self:AddLayer(self.imgAvatar)

		--return self.BaseClass.Init(self)
	end

	function PANEL:SetAvatarSize(s)
		self.imgAvatar:SetSize(s, s)
	end

	function PANEL:SetAvatar(icon)
		self.imgAvatar:SetImage(icon)
	end

	vgui.Register( "SimpleIconFakeAvatar", PANEL, "LayeredIcon" )

	PANEL = {}
	local facepadding = 6
	local template = Material("mall_member/figardo/icon_template")
	function PANEL:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(template)
		surface.DrawTexturedRect(0, 0, w, h)

		local facew = w * 0.625
		local x, y = (w / 2) - (facew / 2) + facepadding, facepadding
		self:PaintAt(x, y, facew - (facepadding * 2), h - (facepadding * 2))
	end

	function PANEL:PaintOver(w, h)
		if self.Hat then
			local facew = self.HatWidthOverride or 0.625
			facew = facew * w

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.Hat)
			surface.DrawTexturedRect((w / 2) - (facew / 2), -facepadding, facew, h * 0.425)
		end
	end

	function PANEL:SetFace(folder, face)
		if !folder or !face then
			print("folder =", folder)
			print("face =", face)
			error("PANEL:SetFace called with nil parameters!")
		end

		self:SetImage("mall_member/figardo/faces/" .. folder .. "/" .. face)
	end
	vgui.Register("DTJFace", PANEL, "DImage")
end

-- Annoyances

ANNOY_MAX = -1
local function RegisterAnnoyance(data)
	ANNOY_MAX = ANNOY_MAX + 1
	TRAITORJOE.Annoyances[ANNOY_MAX] = data

	return ANNOY_MAX
end

-- Shared
ANNOY_HAT = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.HatShot.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.HatShot.1"}
})
ANNOY_PHYSGUN = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.Physgun.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Physgun.1"}
})
ANNOY_RADIO = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.RadioShot.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.RadioShot.1"}
})
ANNOY_DAMAGE = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "neutral", text = "Joe.Shot.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Shot.1"}
})
ANNOY_TOOLGUN = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.Toolgun.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Toolgun.1"}
})
ANNOY_FIRE = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "lookside", text = "Joe.Fire.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Fire.1"}
})

-- Joe
ANNOY_NOCLIP = RegisterAnnoyance({["tj_npc_joe"] = {face = "annoyed", text = "Joe.ReadTheSign"}})
ANNOY_BACKROOM = RegisterAnnoyance({["tj_npc_joe"] = {face = "neutral", text = "Joe.BackRoom.1"}})
ANNOY_SMASH = RegisterAnnoyance({["tj_npc_joe"] = {face = "annoyed", text = "Joe.Ammo.1"}})
ANNOY_REMOVED = RegisterAnnoyance({
	["tj_npc_joe"] = function(self)
		return self:GetAnnoyanceCount() > 1 and {face = "grin", text = "Joe.Removed.Annoy"} or {face = "smile", text = "Joe.Removed.1"}
	end
})
ANNOY_DISPLAY = RegisterAnnoyance({["tj_npc_joe"] = {face = "neutral", text = "Joe.Display.1"}})
ANNOY_MOVED = RegisterAnnoyance({["tj_npc_joe"] = {face = "smile", text = "Joe.Moved.1"}})
ANNOY_FINAL = RegisterAnnoyance({
	["tj_npc_joe"] = function(self)
		return self:GetAnnoyanceCount() > 1 and {face = "annoyed", text = "Joe.Final.1"} or {face = "smirk", text = "Joe.Final.Good.1"}
	end
})

-- Skeleton

local skeleSearch = {
	nick = {img = "mall_member/figardo/icon_id", av = "mall_member/figardo/icon_bku", text = "This is the body of Bad King Urgrain.", p = 1},
	role = {img = "mall_member/figardo/icon_traitor", text = "This person was a Traitor Joe's employee!", p = 2},
	dtime = {img = "mall_member/figardo/icon_time", text = "They died roughly " .. tonumber(os.date("%Y")) - 2012 .. " years before you conducted the search.", text_icon = "99:99", p = 8},
	words = {img = "mall_member/figardo/icon_halp", text = "Something tells you some of this person's last words were: 'Man I'm hungry'", p = 10},
	dmg = {img = "mall_member/figardo/icon_skull", text = "It seems they starved to death.", p = 12},
}

local function SearchInfoController(search, dactive, dtext)
	return function(s, pold, pnew)
		local t = pnew.info_type
		local data = search[t]
		if !data then
			ErrorNoHalt("Search: data not found", t, data,"\n")
			return
		end

		-- If wrapping is on, the Label's SizeToContentsY misbehaves for
		-- text that does not need wrapping. I long ago stopped wondering
		-- "why" when it comes to VGUI. Apply hack, move on.
		dtext:GetLabel():SetWrap(#data.text > 50)

		dtext:SetText(data.text)
		dactive:SetImage(data.img)
	end
end

local function ShowSearchScreen()
	local client = LocalPlayer()
	if !IsValid(client) then return end

	local m = 8
	local bw, bh = 100, 25
	local bw_large = 125
	local w, h = 425, 260

	local rw, rh = (w - m * 2), (h - 25 - m * 2)
	local rx, ry = 0, 0

	local rows = 1
	local listw, listh = rw, (64 * rows + 6)
	local listx, listy = rx, ry

	ry = ry + listh + m * 2
	rx = m

	local descw, desch = rw - m * 2, 80
	local descx, descy = rx, ry

	ry = ry + desch + m

	local dframe = vgui.Create("DFrame")
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle("Body Search Results - Bad King Urgrain")
	dframe:SetVisible(true)
	dframe:ShowCloseButton(true)
	dframe:SetMouseInputEnabled(true)
	dframe:SetKeyboardInputEnabled(true)
	dframe:SetDeleteOnClose(true)

	dframe.OnKeyCodePressed = util.BasicKeyHandler

	-- contents wrapper
	local dcont = vgui.Create("DPanel", dframe)
	dcont:SetPaintBackground(false)
	dcont:SetSize(rw, rh)
	dcont:SetPos(m, 25 + m)

	-- icon list
	local dlist = vgui.Create("DPanelSelect", dcont)
	dlist:SetPos(listx, listy)
	dlist:SetSize(listw, listh)
	dlist:EnableHorizontal(true)
	dlist:SetSpacing(1)
	dlist:SetPadding(2)

	if dlist.VBar then
		dlist.VBar:Remove()
		dlist.VBar = nil
	end

	-- description area
	local dscroll = vgui.Create("DHorizontalScroller", dlist)
	dscroll:StretchToParent(3,3,3,3)

	local ddesc = vgui.Create("ColoredBox", dcont)
	ddesc:SetColor(Color(50, 50, 50))
	ddesc:SetName("Information")
	ddesc:SetPos(descx, descy)
	ddesc:SetSize(descw, desch)

	local dactive = vgui.Create("DImage", ddesc)
	dactive:SetImage("vgui/ttt/icon_id")
	dactive:SetPos(m, m)
	dactive:SetSize(64, 64)

	local dtext = vgui.Create("ScrollLabel", ddesc)
	dtext:SetSize(descw - 120, desch - m * 2)
	dtext:MoveRightOf(dactive, m * 2)
	dtext:AlignTop(m)
	dtext:SetText("...")

	-- buttons
	local by = rh - bh - (m / 2)

	local doThat = "Please don't do that."
	local selfReport = function(s)
		s:SetText(doThat)
		doThat = "Or that. - TJ"

		s:SetDisabled(true)
	end

	local dident = vgui.Create("DButton", dcont)
	dident:SetPos(m, by)
	dident:SetSize(bw_large, bh)
	dident:SetText("Confirm Death")
	dident.DoClick = selfReport

	local dcall = vgui.Create("DButton", dcont)
	dcall:SetPos(m * 2 + bw_large, by)
	dcall:SetSize(bw_large, bh)
	dcall:SetText("Call Detective")
	dcall.DoClick = selfReport

	local dconfirm = vgui.Create("DButton", dcont)
	dconfirm:SetPos(rw - m - bw, by)
	dconfirm:SetSize(bw, bh)
	dconfirm:SetText("Close")
	dconfirm.DoClick = function() dframe:Close() end

	-- Install info controller that will link up the icons to the text etc
	dlist.OnActivePanelChanged = SearchInfoController(skeleSearch, dactive, dtext)

	-- Create table of SimpleIcons, each standing for a piece of search
	-- information.
	local start_icon = nil
	for t, info in SortedPairsByMemberValue(skeleSearch, "p") do
		local textIcon = info.text_icon
		local ic = nil

		if textIcon then
			ic = vgui.Create("SimpleIconLabelled", dlist)
			ic:SetIconText(info.text_icon)
		elseif t == "nick" then
			ic = vgui.Create("SimpleIconFakeAvatar", dlist)
			ic:SetAvatar(info.av)
			start_icon = ic
		else
			ic = vgui.Create("SimpleIcon", dlist)
		end

		ic:SetIconSize(64)
		ic:SetIcon(info.img)

		ic.info_type = t

		dlist:AddPanel(ic)
		dscroll:AddPanel(ic)
	end

	dlist:SelectPanel(start_icon)

	dframe:MakePopup()
end

local tjOverlay
local useEnts = {
	["tj_shitleton"] = ShowSearchScreen,
	["tj_shitphone"] = function()
		if IsValid(tjOverlay) then
			return
		end

		tjOverlay = vgui.Create("DImage")
		tjOverlay:SetSize(ScrW(), ScrH())
		tjOverlay:SetImage("mall_member/figardo/phonemsg")

		hook.Add("PlayerBindPress", "TraitorJoeClosePhoneMsg", function(ply, bind, pressed)
			if IsValid(tjOverlay) then
				tjOverlay:Remove()
			end

			hook.Remove("PlayerBindPress", "TraitorJoeClosePhoneMsg")
		end)
	end,
	["tj_final_computer"] = function()
		if IsValid(tjOverlay) then
			return
		end

		tjOverlay = vgui.Create("DImage")
		tjOverlay:SetSize(ScrW(), ScrH())
		tjOverlay:SetImage("mall_member/figardo/phonemsg")

		hook.Add("PlayerBindPress", "TraitorJoeClosePhoneMsg", function(ply, bind, pressed)
			if IsValid(tjOverlay) then
				tjOverlay:Remove()
			end

			hook.Remove("PlayerBindPress", "TraitorJoeClosePhoneMsg")
		end)
	end
}

if SERVER then
	util.AddNetworkString("TraitorJoe_Annoyed")

	function TRAITORJOE.SendAnnoyance(annoyance, ply, class)
		if !ply or !IsValid(ply) or !ply:IsPlayer() then
			ply = Entity(1)
		end

		local ent
		for _, e in ents.Iterator() do
			if e:GetClass() != class then continue end

			ent = e
			break
		end

		if !IsValid(ent) then
			error("Trying to annoy invalid classname!")
		end

		ent:Annoy(annoyance, ply)
	end

	function TRAITORJOE:OnEnterOrLeave(left, noAnnoy)
		if left then
			if IsValid(self.Joe.Entity) then
				if !IsValid(self.Joe.Entity.hat) then
					self.Joe.Entity:SpawnHat()
				end
			else
				for _, ent in ents.Iterator() do
					if ent:GetName() != "tj_traitorjoe_spawn" then continue end

					local npc = ents.Create("tj_npc_joe")
					npc:SetPos(ent:GetPos())
					npc:SetAngles(ent:GetAngles())
					npc:Spawn()

					if !noAnnoy then
						npc:Annoy(ANNOY_REMOVED)
					end

					self.Joe.Entity = npc

					break
				end
			end

			if IsMounted("treason") and !IsValid(self.Tony.Entity) then
				for _, ent in ents.Iterator() do
					if ent:GetName() != "tj_traitortony_spawn" then continue end

					local npc = ents.Create("tj_npc_tony")
					npc:SetPos(ent:GetPos())
					npc:SetAngles(ent:GetAngles())
					npc:Spawn()

					self.Tony.Entity = npc

					break
				end
			end

			if IsValid(self.Radio) then
				net.Start("TraitorJoe_Radio")
					net.WriteBool(false)
				net.Broadcast()
			else
				for _, ent in ents.Iterator() do
					if ent:GetName() != "tj_radio_spawn" then continue end

					local radio = ents.Create("tj_radio")
					radio:SetPos(ent:GetPos())
					radio:SetAngles(ent:GetAngles())
					radio:Spawn()

					self.Radio = radio

					break
				end
			end
		else
			net.Start("TraitorJoe_Radio")
				net.WriteBool(true)
			net.Broadcast()
		end
	end

	local hatModel = Model("models/mall_member/figardo/vending_hat.mdl")
	hook.Add("PostCleanupMap", "TraitorJoesCleanupPrevention", function()
		TRAITORJOE:OnEnterOrLeave(true, engine.ActiveGamemode() == "terrortown")

		for _, ent in ents.Iterator() do
			local name = ent:GetName()
			if useEnts[name] then
				ent:SetNW2String("gmall_figardo", name)
				continue
			end

			if ent:GetName() == "tj_hat_spawn" then
				local hat = ents.Create("tj_hat")
				if !IsValid(hat) then return end

				hat:SetModel(hatModel)
				hat.ShouldBoneMerge = false

				hat:SetPos(ent:GetPos())
				hat:SetAngles(ent:GetAngles())

				hat:Spawn()

				hat:SetBeingWorn(false)

				hat:SetMoveType(MOVETYPE_VPHYSICS)
				local phys = hat:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
				end
			end
		end
	end)

	hook.Add("InitPostEntity", "TraitorJoesEntityInitialization", function()
		for _, ent in ents.Iterator() do
			local name = ent:GetName()
			if useEnts[name] then
				ent:SetNW2String("gmall_figardo", name) -- fucking stupid
				continue
			end

			if name == "tj_hat_spawn" then
				local hat = ents.Create("tj_hat")
				if !IsValid(hat) then return end

				hat:SetModel(hatModel)
				hat.ShouldBoneMerge = false

				hat:SetPos(ent:GetPos())
				hat:SetAngles(ent:GetAngles())

				hat:Spawn()

				hat:SetBeingWorn(false)

				hat:SetMoveType(MOVETYPE_VPHYSICS)
				local phys = hat:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
				end

				continue
			end

			if name == "tj_radio_spawn" then
				local radio = ents.Create("tj_radio")
				radio:SetPos(ent:GetPos())
				radio:SetAngles(ent:GetAngles())
				radio:Spawn()

				TRAITORJOE.Radio = radio

				continue
			end

			if name == "tj_traitorjoe_spawn" then
				local npc = ents.Create("tj_npc_joe")
				npc:SetPos(ent:GetPos())
				npc:SetAngles(ent:GetAngles())
				npc:Spawn()

				TRAITORJOE.Joe.Entity = npc

				-- this is a terrible approach! but i don't care :)
				TRAITORJOE.Joe.Jail.Origin = ent:GetPos()
				TRAITORJOE.Joe.Jail.Min = ent:GetPos() + Vector(-218, 126, 0)
				TRAITORJOE.Joe.Jail.Max = ent:GetPos() + Vector(218, -18, 120)

				continue
			end

			if name == "tj_traitortony_spawn" then
				TRAITORJOE.DefibSpawn = ent

				if IsMounted("treason") then
					local npc = ents.Create("tj_npc_tony")
					npc:SetPos(ent:GetPos())
					npc:SetAngles(ent:GetAngles())
					npc:Spawn()

					TRAITORJOE.Tony.Entity = npc
				end
			end
		end
	end)

	if engine.ActiveGamemode() != "terrortown" then
		hook.Add("KeyRelease", "TraitorJoesCopiedUseKey", function(ply, key)
			if key != IN_USE or !IsValid(ply) or !ply:Alive() then return end

			local tr = util.TraceLine({
				start  = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 84,
				filter = ply,
				mask   = MASK_SHOT
			});

			local ent = tr.Entity
			if !tr.Hit or !IsValid(ent) then return end

			if ent.CanUseKey and ent.UseOverride then
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) and !phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
					ent:UseOverride(ply)
					return true
				else
					-- do nothing, can't +use held objects
					return true
				end
			elseif ent.player_ragdoll then
				CORPSE.ShowSearch(ply, ent, ply:KeyDown(IN_WALK) or ply:KeyDownLast(IN_WALK))
				return true
			end
		end)
	end

	net.Receive("TraitorJoe_ApplyForMembership", function(_, ply)
		TRAITORJOE.Joe.Members[ply:SteamID64()] = true
	end)

	net.Receive("TraitorJoe_SpawnDefib", function(_, ply)
		if ply:HasWeapon("weapon_ttt_tj_defib") then return end

		if IsMounted("treason") then
			error("Player " .. ply:Nick() .. " tried to rudely intrude upon Tony's personal space.")
		end

		for _, ent in ents.Iterator() do
			if ent:GetClass() != "weapon_ttt_tj_defib" then continue end

			if !IsValid(ent:GetOwner()) then return end -- if there's already a defib on the floor then don't bother spawning another
		end

		local spawn = TRAITORJOE.DefibSpawn
		local ent = ents.Create("weapon_ttt_tj_defib")
		ent:SetPos(spawn:GetPos())
		ent:SetAngles(spawn:GetAngles())
		ent:Spawn()
	end)

	net.Receive("TraitorJoe_TonyDefib", function(_, ply)
		if !IsMounted("treason") then
			error("Player " .. ply:Nick() .. " tried to abuse Tony's good will when Treason isn't mounted.")
		end

		if ply:HasWeapon("weapon_ttt_tj_defib") then return end

		ply:Give("weapon_ttt_tj_defib")
	end)

	net.Receive("TraitorJoe_BKUCredits", function(_, ply)
		local bku
		for _, ent in ents.Iterator() do
			if ent:GetClass() == "tj_npc_bku" then
				bku = ent
				break
			end
		end

		if !IsValid(bku) then return end

		if ply:GetCredits() > 0 then return end

		ply:AddCredits(5)
	end)
else
	local function bitsRequired(num)
		local bits, max = 0, 1
		while max <= num do
			bits = bits + 1
			max = max + max
		end
		return bits
	end

	net.Receive("TraitorJoe_Annoyed", function()
		local annoyance = net.ReadUInt(bitsRequired(ANNOY_MAX))
		local ent = net.ReadEntity()
		if !IsValid(ent) or !ent.Annoy then return end

		ent:Annoy(annoyance)
	end)

	hook.Add("PlayerBindPress", "TraitorJoesMagicUseKey", function(ply, bind, pressed)
		if bind != "+use" then return end

		local tr = util.TraceLine({
			start  = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * 84,
			filter = ply,
			mask   = MASK_SHOT
		})
		if !tr.Hit then return end

		local ent = tr.Entity
		if !ent then return end

		local func = useEnts[ent:GetNW2String("gmall_figardo")]
		if !func then
			if ent.UseOverride then
				ent:UseOverride()
			end

			return
		end

		func()
	end)

	local rag_color = Color(200,200,200,255)

	local unidedName = "Unidentified body"
	local corpseName = "Corpse"
	local corpseHint = "Press E to search covertly."

	local targetIDEnts = {
		["tj_shitleton"] = function()
			local text = unidedName

			local x_orig = ScrW() / 2.0
			local x = x_orig
			local y = (ScrH() / 2.0) + 30

			local font = "TargetID"
			surface.SetFont( font )

			local w, h = surface.GetTextSize( text ) -- text width/height, reused several times

			x = x - w / 2

			draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
			draw.SimpleText( text, font, x, y, COLOR_YELLOW )

			y = y + h + 4

			text = corpseName
			font = "TargetIDSmall2"

			surface.SetFont( font )
			w, h = surface.GetTextSize( text )
			x = x_orig - w / 2

			draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
			draw.SimpleText( text, font, x, y, rag_color )

			text = corpseHint

			font = "TargetIDSmall"
			surface.SetFont( font )

			w, h = surface.GetTextSize(text)
			x = x_orig - w / 2
			y = y + h + 5
			draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
			draw.SimpleText( text, font, x, y, COLOR_LGRAY )
		end,
		["tj_shitphone"] = function()
			local text = "Press E to check phone(?)"

			local font = "TargetIDSmall"
			surface.SetFont( font )

			local w = surface.GetTextSize(text)
			local x_orig = ScrW() / 2.0
			local x = x_orig - w / 2
			local y = (ScrH() / 2.0) + 30
			draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
			draw.SimpleText( text, font, x, y, COLOR_LGRAY )
		end,
		["tj_final_computer"] = function()
			local text = "Press E to use computer"

			local font = "TargetIDSmall"
			surface.SetFont( font )

			local w = surface.GetTextSize(text)
			local x_orig = ScrW() / 2.0
			local x = x_orig - w / 2
			local y = (ScrH() / 2.0) + 30
			draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
			draw.SimpleText( text, font, x, y, COLOR_LGRAY )
		end
	}

	local MAX_TRACE_LENGTH = math.sqrt(3) * 2 * 16384

	hook.Add("HUDDrawTargetID", "TraitorJoesTargetID", function()
		local client = LocalPlayer()

		local startpos = client:EyePos()
		local endpos = client:GetAimVector()
		endpos:Mul(MAX_TRACE_LENGTH)
		endpos:Add(startpos)

		local tr = util.TraceLine({
			start = startpos,
			endpos = endpos,
			mask = MASK_SHOT,
			filter = client
		})

		if !tr.Hit then return end

		local ent = tr.Entity
		if !ent then return end

		local func = targetIDEnts[ent:GetNW2String("gmall_figardo")]
		if !func then
			if ent.TraitorJoeTargetID then
				ent:TraitorJoeTargetID()
			end

			return
		end

		func()
	end)
end
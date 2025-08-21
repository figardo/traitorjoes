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
		Base = {},
		Bounds = {}
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
ANNOY_BONES = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.Bones.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Bones.1"}
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
ANNOY_SPRAY = RegisterAnnoyance({["tj_npc_joe"] = {face = "annoyed", text = "Joe.Spray.1"}})
ANNOY_SPAWN = RegisterAnnoyance({["tj_npc_joe"] = {face = "neutral", text = "Joe.Spawn.1"}})
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

-- Email/Phone

local grad = Material("gui/gradient_up")

local emailUnread = Material("icon16/email.png")
local emailSent = Material("icon16/email_go.png")
local emailRead = Material("icon16/email_open.png")
local emailDraft = Material("icon16/email_edit.png")
local emailSpam = Material("icon16/email_error.png")
local emailBox = Material("icon16/box.png")

local emailSound = Material("icon16/sound_none.png")
local emailSoundPlaying = Material("icon16/sound.png")

local emailData = {
	{
		inbox = "Inbox",
		icon = emailUnread,
		emails = {
			{name = "FunnyStarRunner", email = "funnystarrunner@gmall.net", subject = "#TraitorJoes.GMall.Subject", text = "TraitorJoes.GMall.Text"},
			{name = "The Shareholders", email = "theshareholders@traitorjoes.nl", subject = "#TraitorJoes.TradeSecrets.Subject", text = "TraitorJoes.TradeSecrets.Text"}
		}
	},
	{
		inbox = "Outbox",
		icon = emailRead,
		send = true,
		emails = {
		}
	},
	{
		inbox = "Drafts",
		icon = emailDraft,
		send = true,
		emails = {
			{name = "Garry Newman", email = "garry@facepunch.com", subject = "#TraitorJoes.Garry.Subject", text = "TraitorJoes.Garry.Text"}
		}
	},
	{
		inbox = "Sent Items",
		icon = emailSent,
		send = true,
		emails = {
			{name = "Bad King Urgrain", email = "bku@badking.net", subject = "#TraitorJoes.RadioStation.Subject", text = "TraitorJoes.RadioStation.Text"},
			{name = "Bad King Urgrain", email = "bku@badking.net", subject = "#TraitorJoes.NewLocation.Subject", text = "TraitorJoes.NewLocation.Text"}
		}
	},
	{
		inbox = "Junk E-mail",
		icon = emailSpam,
		emails = {
			{name = "dogshit.gg", email = "gambamarketing@dogshit.gg", subject = "#TraitorJoes.Inventory.Subject", text = "TraitorJoes.Inventory.Text"},
			{name = "", email = "@", subject = "", text = "TraitorJoes.Amstr.Text", att = "mall_member/figardo/amstr.wav"}
		}
	}
}

local function ShowEmailScreen(self)
	if CLIENT then
		TRAITORJOE.Computer = self
	end

	if IsValid(TRAITORJOE.Overlay) then
		return
	end

	local w, h = math.min(ScrW(), ScrH() * (4 / 3)), ScrH()

	local tjOverlay = vgui.Create("DFrame")
	TRAITORJOE.Overlay = tjOverlay

	tjOverlay:SetSize(w, h)
	tjOverlay:SetX((ScrW() / 2) - (w / 2))
	tjOverlay.Paint = nil

	tjOverlay:SetDraggable(false)
	tjOverlay:SetVisible(true)
	tjOverlay:ShowCloseButton(true)
	tjOverlay:SetDeleteOnClose(true)

	local desktopBackground = vgui.Create("DImage", tjOverlay)
	desktopBackground:SetSize(w, h)
	desktopBackground:SetImage("mall_member/figardo/desktop")
	desktopBackground:SetMouseInputEnabled(true)

	local ew, eh = w * 0.5125, h * 0.45

	local outlook = vgui.Create("DPanel", desktopBackground)
	outlook:SetSize(ew, eh)
	outlook:SetPos(w * 0.4485, h * 0.301)
	outlook:DockPadding(5, 5, 5, 5)
	outlook.Paint = nil

	local inboxParent = vgui.Create("DPanel", outlook)
	inboxParent:Dock(LEFT)
	inboxParent:SetWide(ew / 4)
	inboxParent:DockMargin(0, 0, 0, eh * 0.3)

	local inboxes = vgui.Create("DListLayout", inboxParent)
	inboxes:SetWide(ew / 4)

	local sidePadding = ScreenScaleH(2)
	local headerHeight = ScreenScaleH(12)
	local iconSize = math.ceil(ScreenScaleH(8))

	local inboxHeader = vgui.Create("DPanel")
	inboxHeader:SetSize(inboxes:GetWide(), headerHeight + sidePadding + iconSize)
	inboxHeader.Paint = function(s, sw, sh)
		surface.SetDrawColor(74, 121, 177)
		surface.DrawRect(0, 0, sw, headerHeight)

		surface.SetDrawColor(18, 60, 134)
		surface.SetMaterial(grad)
		surface.DrawTexturedRect(0, 0, sw, headerHeight)

		surface.SetTextColor(255, 255, 255)
		surface.SetFont("EmailHead")
		surface.SetTextPos(sidePadding, headerHeight * 0.1)
		surface.DrawText("Mail")

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(emailBox)
		surface.DrawTexturedRect(sidePadding, headerHeight, iconSize + 1, iconSize)

		surface.SetTextColor(40, 40, 40)
		surface.SetFont("EmailBold")
		surface.SetTextPos((sidePadding * 2) + iconSize, headerHeight + 2)
		surface.DrawText("Mailbox - Traitor Joe")
	end
	inboxes:Add(inboxHeader)

	local activeInbox, activeEmail

	for i = 1, #emailData do
		local data = emailData[i]
		local text = data.inbox
		local icon = data.icon
		local emails = data.emails

		local inboxButton = vgui.Create("DButton")
		inboxButton:SetSize(inboxes:GetWide(), sidePadding + iconSize)
		inboxButton:SetText("")
		inboxButton:SetCursor("arrow")

		inboxButton.Paint = function(s, sw, sh)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect((sidePadding * 2) + iconSize, 0, iconSize + 1, iconSize)

			surface.SetFont("EmailBold")
			local inboxText = text .. " (" .. #emails .. ")"
			local tx = surface.GetTextSize(inboxText)

			local textx = (sidePadding * 3) + (iconSize * 2)

			if data.active then
				surface.SetDrawColor(209, 205, 184)
				surface.DrawRect(textx, 0, tx, sh)
			end

			surface.SetTextColor(40, 40, 40)
			surface.SetTextPos(textx, 2)
			surface.DrawText(inboxText)
		end
		inboxButton.DoClick = function()
			if activeInbox then
				activeInbox.active = false
				if IsValid(activeInbox.pnl) then
					activeInbox.pnl:Hide()
				end
			end

			if activeEmail then
				activeEmail.active = false

				if IsValid(activeEmail.pnl) then
					activeEmail.pnl:Hide()
				end
			end

			activeInbox = data
			data.active = true
			data.pnl:Show()
		end

		inboxes:Add(inboxButton)

		local emailspnl = vgui.Create("DListLayout", outlook)
		emailspnl:SetPaintBackground(true)
		emailspnl:SetBackgroundColor(Color(255, 255, 255))
		emailspnl:SetSize(ew / 4, eh)
		emailspnl:Dock(LEFT)
		emailspnl:DockMargin(5, 0, 0, 0)

		local emailsHeader = vgui.Create("DPanel")
		emailsHeader:SetSize(emailspnl:GetWide(), headerHeight)
		emailsHeader.Paint = function(s, sw, sh)
			surface.SetDrawColor(74, 121, 177)
			surface.DrawRect(0, 0, sw, headerHeight)

			surface.SetDrawColor(18, 60, 134)
			surface.SetMaterial(grad)
			surface.DrawTexturedRect(0, 0, sw, headerHeight)

			surface.SetTextColor(255, 255, 255)
			surface.SetFont("EmailHead")
			surface.SetTextPos(sidePadding, headerHeight * 0.1)
			surface.DrawText(text)

			-- surface.SetDrawColor(255, 255, 255)
			-- surface.SetMaterial(emailBox)
			-- surface.DrawTexturedRect(6, 35, 20, 20)

			-- surface.SetTextColor(40, 40, 40)
			-- surface.SetFont("EmailBold")
			-- surface.SetTextPos(31, 37)
			-- surface.DrawText("Mailbox - Traitor Joe")
		end
		emailspnl:Add(emailsHeader)

		for j = 1, #emails do
			local edata = emails[j]
			local ename = edata.name
			local eemail = edata.email
			local esubject = edata.subject
			local etext = edata.text

			local emailButton = vgui.Create("DButton")
			emailButton:SetSize(emailspnl:GetWide(), (sidePadding * 2) + (iconSize * 2))
			emailButton:SetText("")
			emailButton:SetCursor("arrow")

			local param = data.send and "TraitorJoes.Email.To" or "TraitorJoes.Email.From"
			param = language.GetPhrase(param)

			emailButton.Paint = function(s, sw, sh)
				if edata.active then
					surface.SetDrawColor(209, 205, 184)
					surface.DrawRect(0, 0, sw, sh)
				end

				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(edata.read and emailRead or emailUnread)
				surface.DrawTexturedRect(sidePadding, sidePadding, iconSize, iconSize)

				local textx = (sidePadding * 2) + iconSize

				surface.SetTextColor(40, 40, 40)
				surface.SetFont("EmailBold")
				surface.SetTextPos(textx, sidePadding)
				surface.DrawText(ename)

				surface.SetTextColor(40, 40, 40)
				surface.SetFont("EmailNormal")
				surface.SetTextPos(textx + 1, iconSize + (sidePadding / 2))
				surface.DrawText(esubject)
			end

			emailButton.DoClick = function()
				if !edata.read then
					edata.read = true
				end

				if activeEmail then
					activeEmail.active = false

					if IsValid(activeEmail.pnl) then
						activeEmail.pnl:Hide()
					end
				end

				if !IsValid(edata.pnl) then
					local pnl = vgui.Create("DPanel", outlook)
					pnl:Dock(FILL)
					pnl:DockMargin(5, 0, 0, 0)
					pnl:SetBackgroundColor(Color(174, 184, 213))
					pnl:InvalidateParent(true)

					local wide = pnl:GetWide()
					local padding = wide * 0.02

					surface.SetFont("EmailHead")
					local _, th = surface.GetTextSize(esubject)
					local _, th2 = surface.GetTextSize(ename)
					local lineY = padding + th + th2 + (sidePadding * 2)

					local textpnl = vgui.Create("RichText", pnl)
					textpnl:SetPos(padding + sidePadding, padding + lineY + sidePadding)
					textpnl:SetPaintedManually(true)
					textpnl:SetText(language.GetPhrase(etext))
					textpnl:SetSize(wide - (padding * 2) - sidePadding, pnl:GetTall() - (padding * 2) - lineY - sidePadding)
					textpnl:SetTextSelectionColors(COLOR_BLACK, Color(174, 184, 213, 200))

					function textpnl:PerformLayout()
						self:SetFontInternal("EmailNormal")

						self:SetFGColor(40, 40, 40, 255)
					end

					local sndpnl

					pnl.PaintOver = function(s, sw, sh)
						surface.SetDrawColor(255, 255, 255)
						surface.DrawRect(padding, padding, sw - (padding * 2), sh - (padding * 2))

						surface.SetTextColor(40, 40, 40)
						surface.SetFont("EmailHead")
						surface.SetTextPos(padding + sidePadding, padding)
						surface.DrawText(esubject)

						surface.SetFont("EmailHeadThin")
						surface.SetTextPos(padding + sidePadding, padding + th + sidePadding)
						surface.DrawText(string.format(param, eemail))

						surface.SetDrawColor(40, 40, 40)
						surface.DrawLine(padding + sidePadding, lineY, sw - sidePadding - padding, lineY)

						textpnl:PaintManual()

						if sndpnl then
							sndpnl:PaintManual()
						end
					end

					edata.pnl = pnl

					if edata.att then
						TRAITORJOE.Base.Att = true

						sndpnl = vgui.Create("DButton", textpnl)
						sndpnl:SetPos(0, (th * 3) + sidePadding)
						sndpnl:SetSize(wide * 0.35, pnl:GetTall() * 0.03)
						sndpnl:SetPaintedManually(true)
						sndpnl:SetText("")
						sndpnl.Paint = function(s)
							local sndPlaying = edata.snd and edata.snd:IsPlaying()

							surface.SetDrawColor(255, 255, 255, 255)
							surface.SetMaterial(sndPlaying and emailSoundPlaying or emailSound)
							surface.DrawTexturedRect(0, 0, iconSize, iconSize)

							surface.SetTextColor(40, 40, 40)
							surface.SetTextPos(iconSize + sidePadding, 0)
							surface.SetFont("EmailNormal")
							surface.DrawText("#TraitorJoes.Attachment")
						end

						sndpnl.DoClick = function(s)
							if !edata.snd or !edata.snd:IsPlaying() then
								local snd = CreateSound(TRAITORJOE.Computer, edata.att)
								snd:Play()
								snd:ChangeVolume(0.1)

								edata.snd = snd
							else
								edata.snd:Stop()

								edata.snd = nil
							end
						end
					end
				end

				activeEmail = edata
				edata.active = true
				edata.pnl:Show()
			end

			emailspnl:Add(emailButton)

			edata.active = false
		end

		if i == 1 then
			data.active = true
			activeInbox = data
		else
			data.active = false
			emailspnl:Hide()
		end

		data.pnl = emailspnl
	end

	tjOverlay:MakePopup()
end

hook.Add("OnPauseMenuShow", "TraitorJoeCloseComputer", function(ply, bind, pressed)
	if IsValid(TRAITORJOE.Overlay) then
		TRAITORJOE.Overlay:Remove()
		return false
	end
end)

local useEnts = {
	["tj_shitleton"] = ShowSearchScreen,
	["tj_shitphone"] = function()
		if IsValid(TRAITORJOE.Overlay) then
			return
		end

		local tjOverlay = vgui.Create("DImage")
		tjOverlay:SetSize(ScrW(), ScrH())
		tjOverlay:SetImage("mall_member/figardo/phonemsg")

		hook.Add("PlayerBindPress", "TraitorJoeClosePhoneMsg", function(ply, bind, pressed)
			if IsValid(tjOverlay) then
				tjOverlay:Remove()
			end

			hook.Remove("PlayerBindPress", "TraitorJoeClosePhoneMsg")
		end)
	end,
	["tj_final_computer"] = ShowEmailScreen
}

-- Misc

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

	local function SpawnOnTarget(class, target, noSpawn)
		local ent = ents.Create(class)
		ent:SetPos(target:GetPos())
		ent:SetAngles(target:GetAngles())

		if !noSpawn then
			ent:Spawn()
		end

		return ent
	end

	local vec0 = Vector(0, 0, 0)
	local vec1 = Vector(1, 1, 1)
	local angle0 = Angle(0, 0, 0)
	local function ResetBoneManips(ent)
		for i = 0, ent:GetBoneCount() - 1 do
			if ent:GetManipulateBoneAngles(i) != angle0 then
				ent:ManipulateBoneAngles(i, angle0)
			end

			if ent:GetManipulateBoneJiggle(i) != 0 then
				ent:ManipulateBoneJiggle(i, 0)
			end

			if ent:GetManipulateBonePosition(i) != vec0 then
				ent:ManipulateBonePosition(i, vec0)
			end

			if ent:GetManipulateBoneScale(i) != vec1 then
				ent:ManipulateBoneScale(i, vec1)
			end
		end
	end

	function TRAITORJOE:OnEnterOrLeave(left, noAnnoy)
		if left then
			local joe = self.Joe.Entity
			if IsValid(joe) then
				if !IsValid(joe.hat) then
					joe:SpawnHat()
				end

				if joe:HasBoneManipulations() then
					ResetBoneManips(joe)
				end
			else
				for _, ent in ents.Iterator() do
					if ent:GetName() != "tj_traitorjoe_spawn" then continue end

					local npc = SpawnOnTarget("tj_npc_joe", ent)

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

					local npc = SpawnOnTarget("tj_npc_tony", ent)

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

					local radio = SpawnOnTarget("tj_radio", ent)

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

	hook.Add("PlayerSpray", "TraitorJoesSprayDetector", function(ply)
		local trace = util.GetPlayerTrace(ply, ply:EyeAngles():Forward())
		trace.mask = MASK_SOLID_BRUSHONLY
		trace = util.TraceLine(trace)

		local pos = trace.HitPos
		local min, max = TRAITORJOE.Bounds.Min, TRAITORJOE.Bounds.Max

		if pos.x >= min.x and pos.x <= max.x
		and pos.y >= min.y and pos.y <= max.y
		and pos.z >= min.z and pos.z <= max.z then
			TRAITORJOE.Joe.Entity:Annoy(ANNOY_SPRAY)
		end
	end)

	local function SpawnedSomething(ply, ent)
		local pos = ent:GetPos()
		local min, max = TRAITORJOE.Bounds.Min, TRAITORJOE.Bounds.Max

		if pos.x >= min.x and pos.x <= max.x
		and pos.y >= min.y and pos.y <= max.y
		and pos.z >= min.z and pos.z <= max.z then
			TRAITORJOE.Joe.Entity:Annoy(ANNOY_SPAWN)
		end
	end
	hook.Add("PlayerSpawnedEffect", "TraitorJoesSpawnCheck", function(ply, model, ent) SpawnedSomething(ply, ent) end)
	hook.Add("PlayerSpawnedNPC", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)
	hook.Add("PlayerSpawnedProp", "TraitorJoesSpawnCheck", function(ply, model, ent) SpawnedSomething(ply, ent) end)
	hook.Add("PlayerSpawnedRagdoll", "TraitorJoesSpawnCheck", function(ply, model, ent) SpawnedSomething(ply, ent) end)
	hook.Add("PlayerSpawnedSENT", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)
	hook.Add("PlayerSpawnedSWEP", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)
	hook.Add("PlayerSpawnedVehicle", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)

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
				local hat = SpawnOnTarget("tj_hat", ent, true)

				hat:SetModel(hatModel)
				hat.ShouldBoneMerge = false

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
				local hat = SpawnOnTarget("tj_hat", ent, true)

				hat:SetModel(hatModel)
				hat.ShouldBoneMerge = false

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
				local radio = SpawnOnTarget("tj_radio", ent)

				TRAITORJOE.Radio = radio

				continue
			end

			if name == "tj_traitorjoe_spawn" then
				local npc = SpawnOnTarget("tj_npc_joe", ent)

				TRAITORJOE.Joe.Entity = npc

				-- this is a terrible approach! but i don't care :)
				local boundsMin = ent:GetPos() + Vector(-218, 254, 0)
				local boundsMax = ent:GetPos() + Vector(218, -562, 120)

				TRAITORJOE.Bounds.Min = Vector(math.min(boundsMin.x, boundsMax.x), math.min(boundsMin.y, boundsMax.y), math.min(boundsMin.z, boundsMax.z))
				TRAITORJOE.Bounds.Max = Vector(math.max(boundsMin.x, boundsMax.x), math.max(boundsMin.y, boundsMax.y), math.max(boundsMin.z, boundsMax.z))

				local jailMin = ent:GetPos() + Vector(-218, 126, 0)
				local jailMax = ent:GetPos() + Vector(218, -18, 120)

				TRAITORJOE.Joe.Jail.Min = Vector(math.min(jailMin.x, jailMax.x), math.min(jailMin.y, jailMax.y), math.min(jailMin.z, jailMax.z))
				TRAITORJOE.Joe.Jail.Max = Vector(math.max(jailMin.x, jailMax.x), math.max(jailMin.y, jailMax.y), math.max(jailMin.z, jailMax.z))

				continue
			end

			if name == "tj_traitortony_spawn" then
				TRAITORJOE.DefibSpawn = ent

				if IsMounted("treason") then
					local npc = SpawnOnTarget("tj_npc_tony", ent)

					TRAITORJOE.Tony.Entity = npc
				end

				continue
			end

			if name == "tj_bin_spawn" then
				TRAITORJOE.BinSpawn = ent

				continue
			end
		end
	end)

	hook.Add("PostGamemodeLoaded", "TraitorJoesTTT2Workaround", function()
		if engine.ActiveGamemode() != "terrortown" or TTT2 then -- ttt2 is a deeply unserious fork
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
	end)

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

		SpawnOnTarget("weapon_ttt_tj_defib", TRAITORJOE.DefibSpawn)
	end)

	net.Receive("TraitorJoe_SpawnBin", function(_, ply)
		for _, ent in ents.Iterator() do
			if ent:GetClass() == "tj_bin" then return end -- if there's already a bin then don't bother spawning another
		end

		SpawnOnTarget("tj_bin", TRAITORJOE.BinSpawn)
	end)

	net.Receive("TraitorJoe_HatTransfer", function(_, ply)
		local hat = ply.hat
		if !IsValid(hat) or hat:GetParent() != ply then return end

		hat:Drop()

		local joe = TRAITORJOE.Joe.Entity
		if joe.hat then return end

		hat:UseOverride(joe)
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
	local function CreateEmailFonts()
		surface.CreateFont("EmailBold", {font = "Tahoma", size = ScreenScaleH(7), weight = 1000})
		surface.CreateFont("EmailNormal", {font = "Tahoma", size = ScreenScaleH(7), weight = 500})
		surface.CreateFont("EmailHead", {font = "Arial", size = ScreenScaleH(10), weight = 1000})
		surface.CreateFont("EmailHeadThin", {font = "Arial", size = ScreenScaleH(10), weight = 500})
	end
	CreateEmailFonts()
	hook.Add("OnScreenSizeChanged", "TraitorJoesFontRefresh", CreateEmailFonts)

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

	net.Receive("TraitorJoe_BuyItem", function()
		TRAITORJOE.Joe.ItemsBought = net.ReadUInt(3)
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

		func(ent)
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
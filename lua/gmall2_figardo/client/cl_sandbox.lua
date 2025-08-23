-- Fonts

surface.CreateFont("TargetIDSmall2", {font = "TargetID", size = 16, weight = 1000})
surface.CreateFont("DefaultBold", {font = "Tahoma", size = 13, weight = 1000})
surface.CreateFont("TabLarge", {font = "Tahoma", size = 13, weight = 700, shadow = true, antialias = false})
surface.CreateFont("TimeLeft", {font = "Trebuchet24", size = 24, weight = 800})
surface.CreateFont("HealthAmmo", {font = "Trebuchet24", size = 24, weight = 750})
-- surface.CreateFont("Trebuchet22", {font = "Trebuchet MS", size = 22, weight = 900})

-- Panels

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

-- LANG.Msg

net.Receive("TraitorJoe_LangMsg", function()
	chat.AddText(LANG.GetTranslation(net.ReadString()))
end)

-- Radar

RADAR = {}
RADAR.targets = {}
RADAR.enable = false
RADAR.duration = 30
RADAR.endtime = 0
RADAR.bombs = {}
RADAR.bombs_count = 0
RADAR.repeating = true
RADAR.samples = {}
RADAR.samples_count = 0

function RADAR:EndScan()
	self.enable = false
	self.endtime = CurTime()
end

function RADAR:Clear()
	self:EndScan()
	self.bombs = {}
	self.samples = {}

	self.bombs_count = 0
	self.samples_count = 0
end

function RADAR:Timeout()
	self:EndScan()

	if self.repeating and LocalPlayer() and LocalPlayer():IsActiveSpecial() and LocalPlayer():HasEquipmentItem(EQUIP_RADAR) then
		RunConsoleCommand("ttt_radar_scan")
	end
end

local function ReceiveRadarScan()
	local num_targets = net.ReadUInt(8)

	RADAR.targets = {}
	for i = 1, num_targets do
		local r = net.ReadUInt(2)

		local pos = Vector()
		pos.x = net.ReadInt(15)
		pos.y = net.ReadInt(15)
		pos.z = net.ReadInt(15)

		table.insert(RADAR.targets, {role = r, pos = pos})
	end

	RADAR.enable = true
	RADAR.endtime = CurTime() + RADAR.duration

	timer.Create("radartimeout", RADAR.duration + 1, 1,
					function() RADAR:Timeout() end)
end
net.Receive("TTT_Radar", ReceiveRadarScan)

-- Is screenpos on screen?
local function IsOffScreen(scrpos)
	return !scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
end

local function DrawTarget(tgt, size, offset, no_shrink)
	local scrpos = tgt.pos:ToScreen() -- sweet
	local sz = (IsOffScreen(scrpos) and !no_shrink) and size / 2 or size

	scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
	scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)

	if IsOffScreen(scrpos) then return end

	surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

	-- Drawing full size?
	if sz == size then
		local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.pos))
		local w, h = surface.GetTextSize(text)

		-- Show range to target
		surface.SetTextPos(scrpos.x - w / 2, scrpos.y + (offset * sz) - h / 2)
		surface.DrawText(text)

		if tgt.t then
			-- Show time
			text = util.SimpleTime(tgt.t - CurTime(), "%02i:%02i")
			w, h = surface.GetTextSize(text)

			surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
			surface.DrawText(text)
		elseif tgt.nick then
			-- Show nickname
			text = tgt.nick
			w, h = surface.GetTextSize(text)

			surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
			surface.DrawText(text)
		end
	end
end

local indicator   = surface.GetTextureID("effects/select_ring")
local c4warn      = surface.GetTextureID("mall_member/figardo/icon_c4warn")
local sample_scan = surface.GetTextureID("mall_member/figardo/sample_scan")
-- local det_beacon  = surface.GetTextureID("mall_member/figardo/det_beacon")

local FormatTime = util.SimpleTime
local near_cursor_dist = 180

function RADAR:Draw()
	local client = LocalPlayer()
	if !client then return end

	surface.SetFont("HudSelectionText")

	-- C4 warnings
	if self.bombs_count != 0 and client:IsActiveTraitor() then
		surface.SetTexture(c4warn)
		surface.SetTextColor(200, 55, 55, 220)
		surface.SetDrawColor(255, 255, 255, 200)

		for k, bomb in pairs(self.bombs) do
			DrawTarget(bomb, 24, 0, true)
		end
	end

	-- Samples
	if self.samples_count != 0 then
		surface.SetTexture(sample_scan)
		surface.SetTextColor(200, 50, 50, 255)
		surface.SetDrawColor(255, 255, 255, 240)

		for k, sample in pairs(self.samples) do
			DrawTarget(sample, 16, 0.5, true)
		end
	end

	-- Player radar
	if !client:HasEquipmentItem(EQUIP_RADAR) then return end

	surface.SetTexture(indicator)

	local remaining = math.max(0, RADAR.endtime - CurTime())
	local alpha_base = 50 + 180 * (remaining / RADAR.duration)

	local mpos = Vector(ScrW() / 2, ScrH() / 2, 0)

	local role, alpha, scrpos, md
	for k, tgt in pairs(RADAR.targets) do
		alpha = alpha_base

		scrpos = tgt.pos:ToScreen()
		if !scrpos.visible then
			continue
		end
		md = mpos:Distance(Vector(scrpos.x, scrpos.y, 0))
		if md < near_cursor_dist then
			alpha = math.Clamp(alpha * (md / near_cursor_dist), 40, 230)
		end

		role = tgt.role or ROLE_INNOCENT
		if role == ROLE_TRAITOR then
			surface.SetDrawColor(255, 0, 0, alpha)
			surface.SetTextColor(255, 0, 0, alpha)

		elseif role == ROLE_DETECTIVE then
			surface.SetDrawColor(0, 0, 255, alpha)
			surface.SetTextColor(0, 0, 255, alpha)

		elseif role == 3 then -- decoys
			surface.SetDrawColor(150, 150, 150, alpha)
			surface.SetTextColor(150, 150, 150, alpha)

		else
			surface.SetDrawColor(0, 255, 0, alpha)
			surface.SetTextColor(0, 255, 0, alpha)
		end

		DrawTarget(tgt, 24, 0)
	end

	-- Time until next scan
	surface.SetFont("TabLarge")
	surface.SetTextColor(255, 0, 0, 230)

	local text = LANG.GetParamTranslation("radar_hud", {time = FormatTime(remaining, "%02i:%02i")})
	local _, h = surface.GetTextSize(text)

	surface.SetTextPos(36, ScrH() - 140 - h)
	surface.DrawText(text)
end

hook.Add("HUDPaint", "TraitorJoesRadarFunction", function()
	RADAR:Draw()
end)

-- Disguiser

hook.Add("HUDDrawTargetID", "TraitorJoesDisguiserFunction", function()
	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if !trace.Hit or !trace.HitNonWorld then return end

	local ent = trace.Entity
	if !ent:IsPlayer() then return end

	if ent:GetNWBool("disguised", false) then return false end
end)

-- SWEP Helpers

local function ReceiveCredits()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end

	ply.equipment_credits = net.ReadUInt(8)
end
net.Receive("TTT_Credits", ReceiveCredits)

local function ReceiveEquipment()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end

	ply.equipment_items = net.ReadUInt(3)
end
net.Receive("TTT_Equipment", ReceiveEquipment)
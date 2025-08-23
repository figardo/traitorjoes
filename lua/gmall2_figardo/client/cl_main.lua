include("cl_corpse.lua")
include("cl_email.lua")

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

TRAITORJOE.UseEnts["tj_shitphone"] = function()
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
end

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

	local func = TRAITORJOE.UseEnts[ent:GetNW2String("gmall_figardo")]
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

hook.Add("OnPauseMenuShow", "TraitorJoeCloseComputer", function(ply, bind, pressed)
	if IsValid(TRAITORJOE.Overlay) then
		TRAITORJOE.Overlay:Remove()
		return false
	end
end)
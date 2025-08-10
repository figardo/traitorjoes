if game.GetMap() != "mall_store_size" then return end

include("shared.lua")

ENT.PrintName = "base"

local spawnList = {
	"weapon_ttt_beacon",
	"weapon_ttt_binoculars",
	"weapon_ttt_c4",
	"weapon_ttt_carbine",
	"weapon_ttt_confgrenade",
	"weapon_ttt_cse",
	"weapon_ttt_decoy",
	"weapon_ttt_defuser",
	"weapon_ttt_flaregun",
	"weapon_ttt_glock",
	"weapon_ttt_health_station",
	"weapon_ttt_knife",
	"weapon_ttt_m16",
	"weapon_ttt_phammer",
	"weapon_ttt_push",
	"weapon_ttt_radio",
	"weapon_ttt_sipistol",
	"weapon_ttt_smokegrenade",
	"weapon_ttt_stungun",
	"weapon_ttt_teleport",
	"weapon_ttt_unarmed",
	"weapon_ttt_wtester",
	"weapon_zm_carry",
	"weapon_zm_improvised",
	"weapon_zm_mac10",
	"weapon_zm_molotov",
	"weapon_zm_pistol",
	"weapon_zm_revolver",
	"weapon_zm_rifle",
	"weapon_zm_shotgun",
	"weapon_zm_sledge"
}

local function baseTalk(self)
	local tbl = {}

	tbl["Base.WhoAreYou"] = {
		{text = "Base.WhoAreYou.1"},
		{text = "Base.WhoAreYou.2"},
		{text = "Base.WhoAreYou.3"},
		{text = "Base.WhoAreYou.4"},
		{text = "Base.WhoAreYou.5"},
		{text = "Base.WhoAreYou.6"}
	}

	tbl["Base.Give"] = {
		{text = "Base.Give.1"},
		{text = "Base.Give.2"},
		{text = "Base.Give.3", param = spawnList[math.random(#spawnList)]},
		{text = "Base.Give.4"}
	}

	return tbl
end

ENT.ChatLayout = {
	-- this chat system is poop and you probably shouldn't use it anywhere
	-- but here's a cheat sheet just in case
	-- when we reach initial.chat, follow up with this continual text
	-- ["initial.chat"] = {{face = "smile", text = "dialogue.1"}, {face = "smirk", "dialogue.2"}, {face = "annoyed", "dialogue.3"}},
	-- ["dialogue.3"] = { -- when we reach dialogue.3, offer these choices
	-- 		["choice.1"] = {text = "series", text = "of", text = "dialogue"},
	--		["choice.2"] = {text = "other", text = "dialogue", text = "option"}
	-- }
	["Error.1"] = {"Error.2", "Error.3"},

	["Base.Intro.1"] = {
		{text = "Base.Intro.2"},
		{text = "Base.Intro.3"},
	},
	["Base.Intro.3"] = baseTalk,
	["Base.Main"] = baseTalk,
	["Base.WhoAreYou.6"] = baseTalk,
	["Base.Give.4"] = baseTalk
}

ENT.ChatHooks = {}

ENT.TJGlobalName = "Base"

ENT.FaceFolder = "base"
ENT.HatTexture = Material("mall_member/figardo/faces/joe/hat")

ENT.AnnoyMessages = {}

-- CHAT

function ENT:UseOverride()
	self:ShowChatScreen()
end

local dcont, dface, dtext
function ENT:SetFace(face)
	if !IsValid(dface) then
		error("ENT:SetFace called with invalid face panel!")
	end

	dface:SetFace(self.FaceFolder, face)
end

function ENT:ChatToString(str)
	if !str then
		ErrorNoHaltWithStack("Chat string is nil.")
		return language.GetPhrase("TraitorJoes.Error.1")
	end

	return language.GetPhrase("TraitorJoes." .. str)
end

function ENT:ShowChatScreen(chatOverride)
	local client = LocalPlayer()
	if !IsValid(client) then return end

	if IsValid(self.ChatPanel) then return end

	local m = 8
	local w, h = 460, 325

	local rw, rh = (w - m * 2), (h - 25 - m * 2)
	local rx, ry = 8, 16

	local descw, desch = rw - m * 2, h / 3
	local descx, descy = rx, ry

	ry = ry + desch + m

	local dframe = vgui.Create("DFrame")
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle("Chat - " .. self.PrintName)
	dframe:SetVisible(true)
	dframe:ShowCloseButton(true)
	dframe:SetMouseInputEnabled(true)
	dframe:SetKeyboardInputEnabled(true)
	dframe:SetDeleteOnClose(true)

	dframe.OnKeyCodePressed = util.BasicKeyHandler
	self.ChatPanel = dframe

	function dframe:OnRemove()
		self.ChatResponse = nil
	end

	-- contents wrapper
	dcont = vgui.Create("DPanel", dframe)
	dcont:SetPaintBackground(false)
	dcont:SetSize(rw, rh)
	dcont:SetPos(m, 25 + m)

	-- description area
	local dchatbox = vgui.Create("ColoredBox", dcont)
	dchatbox:SetColor(Color(50, 50, 50))
	dchatbox:SetName("Information")
	dchatbox:SetPos(descx, descy)
	dchatbox:SetSize(descw, desch)

	dface = vgui.Create("DTJFace", dchatbox)
	dface:SetPos(m, m)

	local facesize = desch - (m * 2)
	dface:SetSize(facesize, facesize)

	for _, ent in ipairs(self:GetChildren()) do
		if ent:GetClass() != "tj_hat" then continue end

		dface.Hat = self.HatTexture
		dface.HatWidthOverride = self.HatWidthOverride
		break
	end

	local data = chatOverride or self:GetInitialChat()
	if isfunction(data) then data = data(self) end

	local str = self:ChatToString(data.text)

	dtext = vgui.Create("RichText", dchatbox)
	dtext:SetSize(descw - 120, desch - m * 2)
	dtext:MoveRightOf(dface, m * 2)
	dtext:AlignTop(m)
	dtext:SetText(str)
	dtext:SetVerticalScrollbarEnabled(false)
	function dtext:PerformLayout()
		self:SetFontInternal("TabLarge")
	end

	self:CreateChatOptions(data.text, data.face)

	dframe:MakePopup()

	TRAITORJOE[self.TJGlobalName].Met = true -- cleanup bypass
	self.Met = true
end

function ENT:GetInitialChat()
	if TRAITORJOE.Base.Met then
		return {face = "neutral", text = "Base.Main"}
	end

	return {face = "neutral", text = "Base.Intro.1"}
end

function ENT:CreateChatOptions(key, face, idx)
	idx = idx or 0

	if face then
		self:SetFace(face)
	end

	local ogoptions = self.ChatLayout[key]
	local options = isfunction(ogoptions) and ogoptions(self) or ogoptions

	local response = self.ChatResponse
	if response then
		local respOptions = options[response]
		if respOptions then
			ogoptions = respOptions
			options = isfunction(ogoptions) and ogoptions(self) or ogoptions
		else
			self.ChatResponse = nil
		end
	end

	if options and istable(options) and options[1] then -- rambling handler
		if #options <= idx then -- we've reached the end of the rambling
			key = options[#options]
			if isfunction(key) then key = key(self) end
			key = key.text

			ogoptions = self.ChatLayout[key]
			options = isfunction(ogoptions) and ogoptions(self) or ogoptions

			idx = 0

			if options[1] then -- is there more rambling from this new key?
				self.ChatResponse = key
				options = {["Ellipses"] = {options[idx + 1]}}
			else
				self.ChatResponse = nil
			end
		else -- set up ellipses button that'll show the next ramble
			options = {["Ellipses"] = {options[idx + 1]}}
		end
	end

	local func = self.ChatHooks[key]
	if func and func(self) then -- if hook returns true then recalculate options
		options = ogoptions(self)
	end

	if !options then return end

	local optList = {}

	local i = 1
	for k, v in pairs(options) do -- add our choices
		local doption = vgui.Create("DButton", dcont)
		doption:SetPos(8, dtext:GetY() + dtext:GetTall() + (32 * i))
		doption:SetSize(427, 25)
		doption:SetText(self:ChatToString(k))
		doption.DoClick = function()
			for j = 1, #optList do
				local pnl = optList[j]
				if IsValid(pnl) then
					pnl:Remove()
				end
			end

			if isfunction(v) then
				v = v(self)
			end

			local data = v[1]
			if isfunction(data) then
				data = data(self)

				local ispnl = ispanel(data)
				if ispnl or isbool(data) then
					self.ChatPanel:Close()

					if ispnl then
						self.ChatPanel = data
					end

					return
				end
			end

			local str = self:ChatToString(data.text)
			if data.param then
				str = string.format(str, data.param)
			end

			dtext:SetText(str)

			func = self.ChatHooks[data.text]
			if func then func(self) end

			if !self.ChatResponse then
				self.ChatResponse = k
			end

			self:CreateChatOptions(key, data.face, idx + 1)
		end

		optList[i] = doption
		i = i + 1
	end
end

-- TARGETID

local COLOR_BLACK = Color(0, 0, 0, 255)
local COLOR_GREEN = Color(0, 255, 0, 255)
local COLOR_LGRAY = Color(200, 200, 200, 255)

function ENT:TraitorJoeTargetID()
	if self:GetNoDraw() then return end

	local text = self.PrintName

	local x_orig = ScrW() / 2.0
	local x = x_orig
	local y = (ScrH() / 2.0) + 30

	local font = "TargetID"
	surface.SetFont( font )

	local w, h = surface.GetTextSize( text )

	x = x - w / 2

	draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
	draw.SimpleText( text, font, x, y, COLOR_WHITE )

	y = y + h + 4

	text = "Healthy"
	font = "TargetIDSmall2"

	surface.SetFont( font )
	w, h = surface.GetTextSize( text )
	x = x_orig - w / 2

	draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
	draw.SimpleText( text, font, x, y, COLOR_GREEN )

	text = "Press E to talk."

	font = "TargetIDSmall"
	surface.SetFont( font )

	w, h = surface.GetTextSize(text)
	x = x_orig - w / 2
	y = y + h + 5
	draw.SimpleText( text, font, x + 1, y + 1, COLOR_BLACK )
	draw.SimpleText( text, font, x, y, COLOR_LGRAY )
end

-- ANNOY

function ENT:Annoy(annoyance)
	local messages = self.AnnoyMessages[annoyance]
	if messages then
		LocalPlayer():ChatPrint(messages[math.random(#messages)])
	end

	local annoyData = TRAITORJOE.Annoyances[annoyance][self:GetClass()]
	if !annoyData or self:GetAnnoyed(annoyance) then return end

	TRAITORJOE[self.TJGlobalName].Annoyances.Queue[annoyance] = CurTime()
end

function ENT:SetAnnoyed(annoyance)
	TRAITORJOE[self.TJGlobalName].Annoyances.Done[annoyance] = true
end

function ENT:GetAnnoyed(annoyance)
	return TRAITORJOE[self.TJGlobalName].Annoyances.Done[annoyance]
end

function ENT:GetAnnoyanceCount()
	return table.Count(TRAITORJOE[self.TJGlobalName].Annoyances.Done)
end

function ENT:AnnoyedCheck()
	-- you've PISSED ME OFF and i need to tell you about it first thing
	local annoyanceQueue = TRAITORJOE[self.TJGlobalName].Annoyances.Queue
	if annoyanceQueue and table.Count(annoyanceQueue) > 0 then
		local annoyance
		local latest = 0
		for k, v in pairs(annoyanceQueue) do
			if v < latest or self:GetAnnoyed(v) then continue end

			annoyance = k
			latest = v
		end

		if annoyance then
			self:SetAnnoyed(annoyance)
			TRAITORJOE[self.TJGlobalName].Annoyances.Queue = {}

			return TRAITORJOE.Annoyances[annoyance][self:GetClass()]
		end
	end
end
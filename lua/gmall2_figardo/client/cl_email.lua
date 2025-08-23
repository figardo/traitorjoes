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
	TRAITORJOE.Computer = self

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

TRAITORJOE.UseEnts["tj_final_computer"] = ShowEmailScreen
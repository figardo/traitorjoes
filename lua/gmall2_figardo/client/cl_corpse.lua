-- Skeleton

local skeleSearch = {
	nick = {
		img = "mall_member/figardo/icon_id",
		av = "mall_member/figardo/icon_bku",
		text = "This is the body of Bad King Urgrain.",
		p = 1
	},
	role = {
		img = "mall_member/figardo/icon_traitor",
		text = "This person was a Traitor Joe's employee!",
		p = 2
	},
	dtime = {
		img = "mall_member/figardo/icon_time",
		text = "They died roughly " .. tonumber(os.date("%Y")) - 2012 .. " years before you conducted the search.",
		text_icon = "99:99",
		p = 8
	},
	words = {
		img = "mall_member/figardo/icon_halp",
		text = "Something tells you some of this person's last words were: 'Man I'm hungry'",
		p = 10
	},
	dmg = {
		img = "mall_member/figardo/icon_skull",
		text = "It seems they starved to death.",
		p = 12
	},
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

TRAITORJOE.UseEnts["tj_shitleton"] = ShowSearchScreen
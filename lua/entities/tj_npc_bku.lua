AddCSLuaFile()
DEFINE_BASECLASS( "tj_npc_base" )

ENT.Base = "tj_npc_base"

if game.GetMap() != "mall_store_size" and game.GetMap() != "gm_gmall_2" then return end

if SERVER then
	util.AddNetworkString("TraitorJoe_BKUCredits")
end

ENT.PrintName = "Bad King Urgrain"
ENT.Model = Model("models/player/skeleton.mdl")
ENT.Anim = "idle_all_01"
ENT.FaceFolder = "bku"
ENT.TJGlobalName = "BKU"

local mainChat = {
	["BKU.WhoAreYou"] = {
		{text = "BKU.WhoAreYou.1"},
		{text = "BKU.WhoAreYou.2"}
	},
	["BKU.WhyThere"] = {
		{text = "BKU.WhyThere.1"},
		{text = "BKU.WhyThere.2"},
		{text = "BKU.WhyThere.3"},
		{text = "BKU.WhyThere.4"},
		{text = "BKU.WhyThere.5"}
	},
	["BKU.Credits"] = function()
		local creds = LocalPlayer():GetCredits()
		if creds >= 5 then
			return {
				{text = "BKU.Credits.No.1"},
				{text = "BKU.Credits.No.2"},
				{text = "BKU.Main"}
			}
		end

		local tbl = creds > 0 and {{text = "BKU.Credits.Refill"}} or {{text = "BKU.Credits.1"}}
		table.Add(tbl, {
			{text = "BKU.Credits.2"},
			{text = "BKU.Main"}
		})

		return tbl
	end
}

ENT.ChatLayout = {
	["BKU.Intro.1"] = {
		{text = "BKU.Intro.2"},
		{text = "BKU.Intro.3"},
		{text = "BKU.Intro.4"},
		{text = "BKU.Main"}
	},
	["BKU.Main"] = mainChat,
	["BKU.WhoAreYou.2"] = mainChat,
	["BKU.WhyThere.5"] = mainChat
}

local function credits()
	net.Start("TraitorJoe_BKUCredits")
	net.SendToServer()

	surface.PlaySound("mall_member/figardo/bloop.wav")
end

ENT.ChatHooks = {
	["BKU.Credits.1"] = credits,
	["BKU.Credits.Refill"] = credits
}

ENT.ChatPriority = {
	["BKU.WhoAreYou"] = 1,
	["BKU.WhyThere"] = 2,
	["BKU.Credits"] = 3
}

function ENT:GetInitialChat()
	if TRAITORJOE.BKU.Met then
		return {face = "neutral", text = "BKU.Main"}
	end

	return {face = "neutral", text = "BKU.Intro.1"}
end
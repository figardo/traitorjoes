if game.GetMap() != "mall_store_size" then return end

AddCSLuaFile()
DEFINE_BASECLASS( "tj_npc_base" )

ENT.Base = "tj_npc_base"

ENT.PrintName = "Bad King Urgrain"
ENT.Model = Model("models/player/skeleton.mdl")
ENT.Anim = "idle_all_01"
ENT.FaceFolder = "bku"
ENT.TJGlobalName = "BKU"

ENT.ChatLayout = {
	["BKU.Intro.1"] = {
		{text = "BKU.Intro.2"},
		{text = "BKU.Intro.3"},
		{text = "BKU.Intro.4"},
		{text = "BKU.Main"}
	},
	["BKU.Main"] = {
		["BKU.Credits"] = {
			{text = "BKU.Credits.1"},
			{text = "BKU.Credits.2"},
			{text = "BKU.Main"}
		}
	}
}

function ENT:GetInitialChat()
	return {face = "neutral", text = "BKU.Intro.1"}
end
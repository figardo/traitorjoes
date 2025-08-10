if game.GetMap() != "mall_store_size" then return end

if SERVER then
	util.AddNetworkString("TraitorJoe_TonyDefib")
end

AddCSLuaFile()
DEFINE_BASECLASS( "tj_npc_base" )

ENT.Base = "tj_npc_base"

ENT.AutomaticFrameAdvance = true

ENT.Model = Model("models/player/mafia_medium.mdl")
ENT.Anim = "idle_lower"
ENT.HatModel = Model("models/player/mafia_hat_medium.mdl")
ENT.HatShouldBoneMerge = false

ENT.HatTexture = Material("mall_member/figardo/faces/tony/hat")
ENT.FaceFolder = "tony"
ENT.HatWidthOverride = 0.7
ENT.TJGlobalName = "Tony"

ENT.Names = {
	"Charlie",
	"Tony",
	"Paulie",
	"Richard",
	"Mikey",
	"Junior",
	"Bobby",
	"Stanley",
	"Luigi",
	"Jackie",
	"Silvio",
	"Larry",
	"Mario",
	"Vito",
	"Sammy",
	"Furio",
	"Johnny",
	"Lopez",
	"Vinny",
	"George"
}

local mainChat = function(self)
	local tbl = {}

	tbl["WhoAreYou"] = {
		{text = "Tony.WhoAreYou.1", param = self.PrintName},
		{text = "Tony.WhoAreYou.2"},
		{text = "Tony.WhoAreYou.3"},
		{text = "Tony.WhoAreYou.4"}
	}

	tbl["Tony.Defib"] = {
		{text = "Tony.Defib.1"},
		{text = "Tony.Defib.2"},
		{text = "Tony.Defib.3"},
		{text = "Tony.Defib.4"},
		{text = "Tony.Defib.5"}
	}

	local oldName = TRAITORJOE.Tony.OldName
	if oldName and oldName != self.PrintName then
		tbl["Tony.NameChange"] = {{text = "Tony.NameChange.1"}}

		if table.HasValue(self.Names, oldName) then
			table.Add(tbl["Tony.NameChange"], {
				{text = "Tony.NameChange.2", param = oldName},
				{text = "Tony.NameChange.3"},
				{text = "Tony.NameChange.4"},
				{text = "Tony.NameChange.5"}
			})
		else
			table.Add(tbl["Tony.NameChange"], {
				{text = "Tony.NameChange.Fail.1", param = oldName},
				{text = "Tony.NameChange.Fail.2"},
				{text = "Tony.NameChange.Fail.3"}
			})
		end
	end

	return tbl
end

ENT.ChatLayout = {
	["Tony.Intro.1"] = {
		{text = "Tony.Intro.2"},
		{text = "Tony.Intro.3"},
		{text = "Tony.Intro.4"},
		{text = "Tony.Main"}
	},
	["Tony.Main"] = mainChat,
	["Tony.Anyway"] = mainChat,
	["Tony.WhoAreYou.4"] = mainChat,
	["Tony.Defib.5"] = mainChat,
	["Tony.NameChange.5"] = mainChat,
	["Tony.NameChange.Fail.3"] = mainChat,

	-- Annoyances
	["Tony.HatShot.1"] = {
		{text = "Tony.HatShot.2"},
		{text = "Tony.Anyway"}
	},
	["Tony.Physgun.1"] = {
		{text = "Tony.Physgun.2"},
		{text = "Tony.Physgun.3"},
		{text = "Tony.Anyway"}
	},
	["Tony.RadioShot.1"] = {
		{text = "Tony.RadioShot.2"},
		{text = "Tony.Anyway"}
	},
	["Tony.Shot.1"] = {
		{text = "Tony.Shot.2"},
		{text = "Tony.Anyway"}
	},
	["Tony.Toolgun.1"] = {
		{text = "Tony.Toolgun.2"},
		{text = "Tony.Anyway"}
	},
	["Tony.Fire.1"] = {
		{text = "Tony.Fire.2"},
		{text = "Tony.Anyway"}
	},
	["Ellipses"] = {
		function() return true end
	}
}

local function WriteOldName(self)
	if self.WrittenOldName then return end

	file.Write("traitorjoes_treasonname.txt", self.PrintName)
	self.WrittenOldName = true
end

ENT.ChatHooks = {
	["Tony.Defib.5"] = function()
		net.Start("TraitorJoe_TonyDefib")
		net.SendToServer()
	end,
	["Tony.Main"] = WriteOldName,
	["Tony.Anyway"] = WriteOldName
}

function ENT:Initialize()
	BaseClass.Initialize(self)

	-- disable hat bodygroup so we can make our own shootable hat
	self:SetBodygroup(1, 1)

	local rand = math.floor(util.SharedRandom(tostring(CurTime()), 1, #self.Names + 0.99))
	self:SetSkin(rand - 1)

	if CLIENT then
		self.PrintName = self.Names[rand]

		if file.Exists("traitorjoes_treasonname.txt", "DATA") then
			TRAITORJOE.Tony.OldName = file.Read("traitorjoes_treasonname.txt", "DATA")
		end
	elseif SERVER then
		self.hat:SetSkin(rand - 1)

		self.LayerID = self:AddGestureSequence(self:LookupSequence("Idle_Upper_revolver_low"), false)
		self:SetLayerLooping(self.LayerID, true)
	end
end

function ENT:GetInitialChat()
	if LocalPlayer():GetObserverMode() != OBS_MODE_NONE then
		return {face = "neutral", text = "Ellipses"}
	end

	local annoyed = self:AnnoyedCheck()
	if annoyed then return annoyed end

	if self.Met then
		return {face = "neutral", text = "Tony.Main"}
	end

	return {face = "neutral", text = "Tony.Intro.1"}
end
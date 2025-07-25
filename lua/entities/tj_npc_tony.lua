if game.GetMap() != "mall_store_size" then return end

AddCSLuaFile()
DEFINE_BASECLASS( "tj_npc_base" )

ENT.Base = "tj_npc_base"

ENT.AutomaticFrameAdvance = true

ENT.Model = Model("models/player/mafia_medium.mdl")
ENT.Anim = "idle_lower"
ENT.HatModel = Model("models/player/mafia_hat_medium.mdl")
ENT.HatShouldBoneMerge = false
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

function ENT:Initialize()
	BaseClass.Initialize(self)

	-- disable hat bodygroup so we can make our own shootable hat
	self:SetBodygroup(1, 1)

	local rand = math.floor(util.SharedRandom(tostring(CurTime()), 1, #self.Names + 0.99))
	self:SetSkin(rand - 1)

	if CLIENT then
		self.PrintName = self.Names[rand]
	elseif SERVER then
		self.hat:SetSkin(rand - 1)

		self.LayerID = self:AddGestureSequence(self:LookupSequence("Idle_Upper_revolver_low"), false)
		self:SetLayerLooping(self.LayerID, true)
	end
end

function ENT:GetInitialChat()
	local annoyed = self:AnnoyedCheck()
	if annoyed then return annoyed end

	return "Error.1"
end
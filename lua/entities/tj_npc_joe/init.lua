if game.GetMap() != "mall_store_size" then return end

DEFINE_BASECLASS("tj_npc_base")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_shop.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/player/phoenix.mdl")
ENT.Anim = "idle_all_01"
ENT.HatModel = Model("models/mall_member/figardo/deerstalker.mdl")
ENT.HatShouldBoneMerge = true

util.AddNetworkString("TraitorJoe_BuyItem")
util.AddNetworkString("TraitorJoe_ApplyForMembership")
util.AddNetworkString("TraitorJoe_Redeem")
util.AddNetworkString("TraitorJoe_SpawnTrash")
util.AddNetworkString("TraitorJoe_SpawnDefib")
util.AddNetworkString("TraitorJoe_HatTransfer")

function ENT:Think()
	BaseClass.Think(self)

	local pos = self:GetPos()
	local min, max = TRAITORJOE.Joe.Jail.Min, TRAITORJOE.Joe.Jail.Max

	if pos.x >= min.x and pos.x <= max.x
	and pos.y >= min.y and pos.y <= max.y
	and pos.z >= min.z and pos.z <= max.z then
		return
	end

	for _, ent in ents.Iterator() do
		if ent:GetName() == "tj_traitorjoe_spawn" then
			self:SetPos(ent:GetPos())
			self:SetAngles(ent:GetAngles())
			self:Annoy(ANNOY_MOVED)

			break
		end
	end
end

local prizeThreshold = 5
function ENT:BuyItem(ply, id)
	local item = self.EquipmentItems[id]

	if !item.free and ply:GetCredits() <= 0 then return end

	if isnumber(item.id) then
		if !ply:GiveEquipmentItem(item.id) then return end
	else
		if ply:HasWeapon(item.id) then return end

		ply:Give(item.id)
	end

	if !item.free then
		ply:SubtractCredits(1)
	end

	local sid = ply:SteamID64()
	if TRAITORJOE.Joe.Members[sid] then
		if !TRAITORJOE.Joe.ItemsBought[sid] then
			TRAITORJOE.Joe.ItemsBought[sid] = 0
		end

		TRAITORJOE.Joe.ItemsBought[sid] = math.min(TRAITORJOE.Joe.ItemsBought[sid] + 1, prizeThreshold)

		net.Start("TraitorJoe_BuyItem")
			net.WriteUInt(TRAITORJOE.Joe.ItemsBought[sid], 3)
		net.Send(ply)
	end
end
net.Receive("TraitorJoe_BuyItem", function(_, ply)
	local joe = TRAITORJOE.Joe.Entity
	if !IsValid(joe) then return end

	joe:BuyItem(ply, net.ReadUInt(5))
end)

local delay_beamup = 1
local delay_beamdown = 1
local zap = Sound("ambient/levels/labs/electric_explosion4.wav")

function ENT:Vanish(bool)
	if bool then
		timer.Simple(delay_beamup, function()
			if !IsValid(self) then return end

			self:SetInvisible(true)
			sound.Play(zap, self:GetPos(), 65, 100)
		end)

		local ang = self:GetAngles()

		local edata_up = EffectData()
		edata_up:SetOrigin(self:GetPos())
		ang = Angle(0, ang.y, ang.r) -- deep copy
		edata_up:SetAngles(ang)
		edata_up:SetEntity(self)
		edata_up:SetMagnitude(delay_beamup)
		edata_up:SetRadius(delay_beamdown)

		util.Effect("teleport_beamup", edata_up)
	else
		self:SetInvisible(false)
	end
end

function ENT:SetInvisible(bool)
	self:SetNoDraw(bool)
	self:SetSolid(bool and SOLID_NONE or SOLID_BBOX)

	if self.hat then
		self.hat:SetNoDraw(bool)
		self.hat:SetSolid(bool and SOLID_NONE or SOLID_BBOX)
	end
end

net.Receive("TraitorJoe_Redeem", function(_, ply)
	local tj = TRAITORJOE.Joe
	local sid = ply:SteamID64()
	if !tj.Members[sid] or !tj.ItemsBought[sid] or tj.ItemsBought[sid] < 5 then return end

	local joe = tj.Entity
	if !IsValid(joe) then return end

	joe:Vanish(true)

	local entCount = 3
	for _, ent in ents.Iterator() do
		if entCount == 0 then
			break
		end

		local name = ent:GetName()
		if name == "tj_backroom_tp" then
			ent:Remove()
			entCount = entCount - 1
			continue
		elseif name == "tj_backroom_final" then
			ent:Fire("Enable")
			entCount = entCount - 1
		end
	end
end)
if game.GetMap() != "mall_store_size" then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("TraitorJoe_Physgunned")

ENT.Model = Model("models/player.mdl")
ENT.Anim = "idle_all_01"
ENT.HatModel = false
ENT.HatShouldBoneMerge = true

ENT.AnnoyingDamage = 25

function ENT:Initialize()
	self:SetModel(self.Model)
	self:ResetSequence(self.Anim)

	if !self:PhysicsInit(SOLID_BBOX) then
		self:PhysicsInitBox(Vector(-16, -16, 0), Vector(16, 16, 72))
	end

	self:SetMoveType(MOVETYPE_NONE)

	if self.HatModel then
		self:SpawnHat()
	end
end

function ENT:SpawnHat()
	local hat = ents.Create("tj_hat")
	if !IsValid(hat) then return end

	hat:SetModel(self.HatModel)

	hat.ShouldBoneMerge = self.HatShouldBoneMerge
	hat.Offset = self.HatOffset

	hat:SetPos(self:GetPos() + Vector(0,0,70))
	hat:SetAngles(self:GetAngles())

	hat:SetParent(self)

	self.hat = hat

	hat:Spawn()
end

function ENT:Think()
	if self:IsOnFire() then
		if !self.FireCheck then
			self:Annoy(ANNOY_FIRE)

			self.FireCheck = true
		end
	else
		self.FireCheck = false
	end

	-- Make sure the animation is smooth
	self:NextThink(CurTime())
	return true
end

local dmgTaken = 0
function ENT:OnTakeDamage(dmginfo)
	if !dmginfo:IsBulletDamage() or dmgTaken >= self.AnnoyingDamage then return end

	dmgTaken = dmgTaken + dmginfo:GetDamage()

	if dmgTaken < self.AnnoyingDamage then return end

	local att = dmginfo:GetAttacker()
	if !IsValid(att) then att = Entity(1) end

	self:Annoy(ANNOY_DAMAGE, att)
end

local function bitsRequired(num)
	local bits, max = 0, 1
	while max <= num do
		bits = bits + 1
		max = max + max
	end
	return bits
end

function ENT:Annoy(annoyance, ply)
	net.Start("TraitorJoe_Annoyed")
		net.WriteUInt(annoyance, bitsRequired(ANNOY_MAX))
		net.WriteEntity(self)

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local npcBase = "tj_npc_base"
hook.Add("OnPhysgunPickup", "TraitorJoeNPCPhysgun", function(ply, ent)
	if ent.Base != npcBase then return end

	ent:Annoy(ANNOY_PHYSGUN, ply)
end)

hook.Add("PhysgunDrop", "TraitorJoeNPCPhysgun", function(ply, ent)
	if ent.Base != npcBase and ent:GetClass() != npcBase then return end

	local pos = ent:GetPos() + Vector(0, 0, 64) -- just so we can't poke his foot through the floor and teleport him under
	local tr = util.TraceLine({
		start = pos,
		endpos = pos + (Vector(0, 0, -1024)),
		filter = ent,
		mask = MASK_SHOT
	})

	if tr.Hit then
		ent:SetPos(tr.HitPos)
		ent:SetAngles(Angle(0, ent:GetAngles().y, 0))
	end
end)

function ENT:CanTool(ply)
	self:Annoy(ANNOY_TOOLGUN, ply)

	return true
end
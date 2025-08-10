AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("TraitorJoe_Radio")

function ENT:Initialize()
	self:SetModel("models/props/cs_office/radio.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()

	self:PrecacheGibs()
end

function ENT:OnTakeDamage(dmginfo)
	self:GibBreakServer(dmginfo:GetDamageForce())

	TRAITORJOE.SendAnnoyance(ANNOY_RADIO, nil, "tj_npc_joe")

	self:Remove()
end
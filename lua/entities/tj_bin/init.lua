AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/props_trainstation/trashcan_indoor001b.mdl")
ENT.CanUseKey = true

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
end

function ENT:UseOverride(ply)
	ply:Give("weapon_ttt_carbine")
	ply:Give("weapon_ttt_beacon")
end
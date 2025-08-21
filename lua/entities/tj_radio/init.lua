AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CanUseKey = true

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

function ENT:UseOverride()
	self:EmitSound("buttons/lightswitch2.wav")

	if self.Sound and self.Sound:IsPlaying() then
		self.Sound:Stop()
	else
		self:PlayRadio()
	end
end

local tjr = Sound("mall_member/figardo/tjr.ogg")
function ENT:PlayRadio()
	self:StopRadio()

	self.Sound = CreateSound(self, tjr)
	self.Sound:Play()
end

function ENT:StopRadio()
	if self.Sound then
		self.Sound:Stop()
	end
end

function ENT:OnRemove()
	self:StopRadio()
end
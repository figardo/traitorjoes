AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

if game.GetMap() != "mall_store_size" then return end

ENT.ModelOffsets = {
	["models/player/mafia_hat_medium.mdl"] = {pos = Vector(6.5, 0, 0), ang = Angle(0, 270, 270)},
	["models/mall_member/figardo/vending_hat.mdl"] = {pos = Vector(6.5, 1.5, 0), ang = Angle(270, 180, 0)}
}

function ENT:SetupDataTables()
	self:NetworkVar("Bool", "BeingWorn")
end

function ENT:Initialize()
	self:SetBeingWorn(true)

	self:DrawShadow(false)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)

	if SERVER and self.ShouldBoneMerge then
		self.Wearer = self:GetParent()
		self:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
	end
end

local vector0 = Vector(0, 0, 0)
local defaultOffset = {pos = Vector(0, 0, 0), ang = Angle(0, 0, 0)}

function ENT:Think()
	if self:IsEffectActive(EF_BONEMERGE) then return end

	local parent = self:GetParent()
	if !IsValid(parent) then return end

	local boneindex = parent:LookupBone("ValveBiped.Bip01_Head1")
	if !boneindex then return end

	local apos, aang = parent:GetBonePosition(boneindex)

	local moffset = vector0

	local offset = self.ModelOffsets[self:GetModel()] or defaultOffset
	local offsetPos = offset.pos
	local offsetAng = offset.ang

	apos = apos + aang:Forward() * offsetPos.x
	apos = apos + aang:Right() * offsetPos.y
	apos = apos + aang:Up() * offsetPos.z

	aang:RotateAroundAxis(aang:Right(), offsetAng.p)
	aang:RotateAroundAxis(aang:Up(), offsetAng.y)
	aang:RotateAroundAxis(aang:Forward(), offsetAng.r)

	apos = apos + aang:Forward() * moffset.x
	apos = apos + aang:Right() * moffset.y
	apos = apos + aang:Up() * moffset.z

	self:SetPos(apos)
	self:SetAngles(aang)
end
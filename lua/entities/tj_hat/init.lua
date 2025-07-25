if game.GetMap() != "mall_store_size" then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CanUseKey = true

function ENT:OnRemove()
	self:SetBeingWorn(false)
end

function ENT:DoAnnoy(ply)
	local parent = self:GetParent()
	if !IsValid(parent) or !parent.Annoy then return end

	if !IsValid(ply) then
		ply = Entity(1)
	end

	parent:Annoy(ANNOY_HAT, ply)
end

function ENT:OnTakeDamage(dmginfo)
	self:DoAnnoy(dmginfo:GetAttacker())

	self:Drop()
end

function ENT:OnRemove()
	self:DoAnnoy()
end

function ENT:Drop(dir)
	local ply = self:GetParent()

	ply.hat = nil
	self:SetParent(nil)

	self:SetBeingWorn(false)
	self:SetUseType(SIMPLE_USE)

	-- only now physics this entity
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	-- position at head
	if IsValid(ply) then
		local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
		if bone then
			local pos, ang = ply:GetBonePosition(bone)
			self:SetPos(pos)
			self:SetAngles(ang)
		else
			local pos = ply:GetPos()
			pos.z = pos.z + 68

			self:SetPos(pos)
		end
	end

	-- physics push
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)

		if IsValid(ply) then
			phys:SetVelocityInstantaneous(ply:GetVelocity())
		end

		if !dir then
			phys:ApplyForceCenter(Vector(0, 0, 1200))
		else
			phys:ApplyForceCenter(Vector(0, 0, 700) + dir * 500)
		end

		phys:AddAngleVelocity(VectorRand() * 200)

		phys:Wake()
	end
end

function ENT:UseOverride(ply)
	if !IsValid(ply) or self:GetBeingWorn() then return end

	if IsValid(ply.hat) then
		ply.hat:Drop()
	end

	sound.Play("weapon.ImpactSoft", self:GetPos(), 75, 100, 1)

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	self:SetParent(ply)
	self.Wearer = ply

	ply.hat = self

	self:SetBeingWorn(true)
end
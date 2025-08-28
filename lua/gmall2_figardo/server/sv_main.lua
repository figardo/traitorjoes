AddCSLuaFile("gmall2_figardo/client/cl_corpse.lua")
AddCSLuaFile("gmall2_figardo/client/cl_email.lua")

-- server just needs to know that these ents can be used
TRAITORJOE.UseEnts = {
	["tj_shitleton"] = true,
	["tj_shitphone"] = true,
	["tj_final_computer"] = true
}

util.AddNetworkString("TraitorJoe_Annoyed")

function TRAITORJOE.SendAnnoyance(annoyance, ply, class)
	if !ply or !IsValid(ply) or !ply:IsPlayer() then
		ply = Entity(1)
	end

	local ent
	for _, e in ents.Iterator() do
		if e:GetClass() != class then continue end

		ent = e
		break
	end

	if !IsValid(ent) then
		error("Trying to annoy invalid classname!")
	end

	ent:Annoy(annoyance, ply)
end

local function SpawnOnTarget(class, target, noSpawn)
	local ent = ents.Create(class)
	ent:SetPos(target:GetPos())
	ent:SetAngles(target:GetAngles())

	if !noSpawn then
		ent:Spawn()
	end

	return ent
end

local vec0 = Vector(0, 0, 0)
local vec1 = Vector(1, 1, 1)
local angle0 = Angle(0, 0, 0)
local function ResetBoneManips(ent)
	for i = 0, ent:GetBoneCount() - 1 do
		if ent:GetManipulateBoneAngles(i) != angle0 then
			ent:ManipulateBoneAngles(i, angle0)
		end

		if ent:GetManipulateBoneJiggle(i) != 0 then
			ent:ManipulateBoneJiggle(i, 0)
		end

		if ent:GetManipulateBonePosition(i) != vec0 then
			ent:ManipulateBonePosition(i, vec0)
		end

		if ent:GetManipulateBoneScale(i) != vec1 then
			ent:ManipulateBoneScale(i, vec1)
		end
	end
end

function TRAITORJOE:OnEnterOrLeave(left, noAnnoy)
	if left then
		local joe = self.Joe.Entity
		if IsValid(joe) then
			if !IsValid(joe.hat) then
				joe:SpawnHat()
			end

			if joe:HasBoneManipulations() then
				ResetBoneManips(joe)
			end
		else
			for _, ent in ents.Iterator() do
				if ent:GetName() != "tj_traitorjoe_spawn" then continue end

				local npc = SpawnOnTarget("tj_npc_joe", ent)

				if !noAnnoy then
					npc:Annoy(ANNOY_REMOVED)
				end

				self.Joe.Entity = npc

				break
			end
		end

		if IsMounted("treason") and !IsValid(self.Tony.Entity) then
			for _, ent in ents.Iterator() do
				if ent:GetName() != "tj_traitortony_spawn" then continue end

				local npc = SpawnOnTarget("tj_npc_tony", ent)

				self.Tony.Entity = npc

				break
			end
		end

		if IsValid(self.Radio) then
			self.Radio:StopRadio()
		else
			for _, ent in ents.Iterator() do
				if ent:GetName() != "tj_radio_spawn" then continue end

				local radio = SpawnOnTarget("tj_radio", ent)

				self.Radio = radio

				break
			end
		end
	elseif IsValid(self.Radio) then
		self.Radio:PlayRadio()
	end
end

hook.Add("PlayerSpray", "TraitorJoesSprayDetector", function(ply)
	local trace = util.GetPlayerTrace(ply, ply:EyeAngles():Forward())
	trace.mask = MASK_SOLID_BRUSHONLY
	trace = util.TraceLine(trace)

	local pos = trace.HitPos
	local min, max = TRAITORJOE.Bounds.Min, TRAITORJOE.Bounds.Max

	if pos.x >= min.x and pos.x <= max.x
	and pos.y >= min.y and pos.y <= max.y
	and pos.z >= min.z and pos.z <= max.z then
		TRAITORJOE.Joe.Entity:Annoy(ANNOY_SPRAY)
	end
end)

local function SpawnedSomething(ply, ent)
	local pos = ent:GetPos()
	local min, max = TRAITORJOE.Bounds.Min, TRAITORJOE.Bounds.Max

	if pos.x >= min.x and pos.x <= max.x
	and pos.y >= min.y and pos.y <= max.y
	and pos.z >= min.z and pos.z <= max.z then
		TRAITORJOE.Joe.Entity:Annoy(ANNOY_SPAWN)
	end
end
hook.Add("PlayerSpawnedEffect", "TraitorJoesSpawnCheck", function(ply, model, ent) SpawnedSomething(ply, ent) end)
hook.Add("PlayerSpawnedNPC", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)
hook.Add("PlayerSpawnedProp", "TraitorJoesSpawnCheck", function(ply, model, ent) SpawnedSomething(ply, ent) end)
hook.Add("PlayerSpawnedRagdoll", "TraitorJoesSpawnCheck", function(ply, model, ent) SpawnedSomething(ply, ent) end)
hook.Add("PlayerSpawnedSENT", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)
hook.Add("PlayerSpawnedSWEP", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)
hook.Add("PlayerSpawnedVehicle", "TraitorJoesSpawnCheck", function(ply, ent) SpawnedSomething(ply, ent) end)

local hatModel = Model("models/mall_member/figardo/vending_hat.mdl")
hook.Add("PostCleanupMap", "TraitorJoesCleanupPrevention", function()
	TRAITORJOE:OnEnterOrLeave(true, engine.ActiveGamemode() == "terrortown")

	for _, ent in ents.Iterator() do
		local name = ent:GetName()
		if TRAITORJOE.UseEnts[name] then
			ent:SetNW2String("gmall_figardo", name)
			continue
		end

		if ent:GetName() == "tj_hat_spawn" then
			local hat = SpawnOnTarget("tj_hat", ent, true)

			hat:SetModel(hatModel)
			hat.ShouldBoneMerge = false

			hat:Spawn()

			hat:SetBeingWorn(false)

			hat:SetMoveType(MOVETYPE_VPHYSICS)
			local phys = hat:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
			end
		end
	end
end)

hook.Add("InitPostEntity", "TraitorJoesEntityInitialization", function()
	for _, ent in ents.Iterator() do
		local name = ent:GetName()
		if TRAITORJOE.UseEnts[name] then
			ent:SetNW2String("gmall_figardo", name) -- fucking stupid
			continue
		end

		if name == "tj_hat_spawn" then
			local hat = SpawnOnTarget("tj_hat", ent, true)

			hat:SetModel(hatModel)
			hat.ShouldBoneMerge = false

			hat:Spawn()

			hat:SetBeingWorn(false)

			hat:SetMoveType(MOVETYPE_VPHYSICS)
			local phys = hat:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
			end

			continue
		end

		if name == "tj_radio_spawn" then
			local radio = SpawnOnTarget("tj_radio", ent)

			TRAITORJOE.Radio = radio

			continue
		end

		if name == "tj_traitorjoe_spawn" then
			local npc = SpawnOnTarget("tj_npc_joe", ent)

			TRAITORJOE.Joe.Entity = npc

			-- this is a terrible approach! but i don't care :)
			local boundsMin = ent:GetPos() + Vector(-218, 254, 0)
			local boundsMax = ent:GetPos() + Vector(218, -562, 120)

			-- the store as a whole (spawning/spraying checks)
			TRAITORJOE.Bounds.Min = Vector(math.min(boundsMin.x, boundsMax.x), math.min(boundsMin.y, boundsMax.y), math.min(boundsMin.z, boundsMax.z))
			TRAITORJOE.Bounds.Max = Vector(math.max(boundsMin.x, boundsMax.x), math.max(boundsMin.y, boundsMax.y), math.max(boundsMin.z, boundsMax.z))

			local jailMin = ent:GetPos() + Vector(-218, 126, 0)
			local jailMax = ent:GetPos() + Vector(218, -18, 120)

			-- behind the counter (moved check)
			TRAITORJOE.Joe.Jail.Min = Vector(math.min(jailMin.x, jailMax.x), math.min(jailMin.y, jailMax.y), math.min(jailMin.z, jailMax.z))
			TRAITORJOE.Joe.Jail.Max = Vector(math.max(jailMin.x, jailMax.x), math.max(jailMin.y, jailMax.y), math.max(jailMin.z, jailMax.z))

			continue
		end

		if name == "tj_traitortony_spawn" then
			TRAITORJOE.DefibSpawn = ent

			if IsMounted("treason") then
				local npc = SpawnOnTarget("tj_npc_tony", ent)

				TRAITORJOE.Tony.Entity = npc
			end

			continue
		end

		if name == "tj_bin_spawn" then
			TRAITORJOE.BinSpawn = ent

			continue
		end
	end
end)

hook.Add("PostGamemodeLoaded", "TraitorJoesTTT2Workaround", function()
	if engine.ActiveGamemode() != "terrortown" or TTT2 then -- ttt2 is a deeply unserious fork
		hook.Add("KeyRelease", "TraitorJoesCopiedUseKey", function(ply, key)
			if key != IN_USE or !IsValid(ply) or !ply:Alive() then return end

			local tr = util.TraceLine({
				start  = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 84,
				filter = ply,
				mask   = MASK_SHOT
			});

			local ent = tr.Entity
			if !tr.Hit or !IsValid(ent) then return end

			if ent.CanUseKey and ent.UseOverride then
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) and !phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
					ent:UseOverride(ply)
					return true
				else
					-- do nothing, can't +use held objects
					return true
				end
			elseif ent.player_ragdoll then
				CORPSE.ShowSearch(ply, ent, ply:KeyDown(IN_WALK) or ply:KeyDownLast(IN_WALK))
				return true
			end
		end)
	end
end)

net.Receive("TraitorJoe_ApplyForMembership", function(_, ply)
	TRAITORJOE.Joe.Members[ply:SteamID64()] = true
end)

net.Receive("TraitorJoe_SpawnDefib", function(_, ply)
	if ply:HasWeapon("weapon_ttt_tj_defib") then return end

	if IsMounted("treason") then
		error("Player " .. ply:Nick() .. " tried to rudely intrude upon Tony's personal space.")
	end

	for _, ent in ents.Iterator() do
		if ent:GetClass() != "weapon_ttt_tj_defib" then continue end

		if !IsValid(ent:GetOwner()) then return end -- if there's already a defib on the floor then don't bother spawning another
	end

	local spawn = TRAITORJOE.DefibSpawn
	spawn:EmitSound("physics/glass/glass_largesheet_break3.wav")

	SpawnOnTarget("weapon_ttt_tj_defib", spawn)
end)

net.Receive("TraitorJoe_SpawnBin", function(_, ply)
	for _, ent in ents.Iterator() do
		if ent:GetClass() == "tj_bin" then return end -- if there's already a bin then don't bother spawning another
	end

	SpawnOnTarget("tj_bin", TRAITORJOE.BinSpawn)
end)

net.Receive("TraitorJoe_HatTransfer", function(_, ply)
	local hat = ply.hat
	if !IsValid(hat) or hat:GetParent() != ply then return end

	hat:Drop()

	local joe = TRAITORJOE.Joe.Entity
	if joe.hat then return end

	hat:UseOverride(joe)
end)

net.Receive("TraitorJoe_TonyDefib", function(_, ply)
	if !IsMounted("treason") then
		error("Player " .. ply:Nick() .. " tried to abuse Tony's good will when Treason isn't mounted.")
	end

	if ply:HasWeapon("weapon_ttt_tj_defib") then return end

	ply:Give("weapon_ttt_tj_defib")
end)

net.Receive("TraitorJoe_BKUCredits", function(_, ply)
	local bku
	for _, ent in ents.Iterator() do
		if ent:GetClass() == "tj_npc_bku" then
			bku = ent
			break
		end
	end

	if !IsValid(bku) then return end

	if ply:GetCredits() > 0 then return end

	ply:AddCredits(5)
end)
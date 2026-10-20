-- SWEP Registration

local toRegister = {
	["weapons"] = {
		"weapon_tttbase",
		"weapon_tttbasegrenade",
		"weapon_ttt_beacon",
		"weapon_ttt_binoculars",
		"weapon_ttt_c4",
		"weapon_ttt_confgrenade",
		"weapon_ttt_cse",
		"weapon_ttt_decoy",
		"weapon_ttt_defuser",
		"weapon_ttt_flaregun",
		"weapon_ttt_glock",
		"weapon_ttt_health_station",
		"weapon_ttt_knife",
		"weapon_ttt_m16",
		"weapon_ttt_phammer",
		"weapon_ttt_push",
		"weapon_ttt_radio",
		"weapon_ttt_sipistol",
		"weapon_ttt_smokegrenade",
		"weapon_ttt_stungun",
		"weapon_ttt_teleport",
		"weapon_ttt_unarmed",
		"weapon_ttt_wtester",
		"weapon_zm_carry",
		"weapon_zm_improvised",
		"weapon_zm_mac10",
		"weapon_zm_molotov",
		"weapon_zm_pistol",
		"weapon_zm_revolver",
		"weapon_zm_rifle",
		"weapon_zm_shotgun",
		"weapon_zm_sledge"
	},
	["entities"] = {
		"base_ammo_ttt",
		"item_ammo_revolver_ttt",
		"ttt_basegrenade_proj",
		"ttt_beacon",
		"ttt_confgrenade_proj",
		"ttt_cse_proj",
		"ttt_decoy",
		"ttt_firegrenade_proj",
		"ttt_flame",
		"ttt_health_station",
		"ttt_knife_proj",
		"ttt_physhammer",
		"ttt_radio",
		"ttt_smokegrenade_proj"
	}
}

if CLIENT then
	toRegister["effects"] = {
		"crimescene_dummy",
		"crimescene_shot",
		"pulse_sphere",
		"teleport_beamdown",
		"teleport_beamup"
	}
else
	util.AddNetworkString("TTT_C4Warn")

	table.insert(toRegister["entities"], "ttt_c4/shared")
end

local globals = {
	["weapons"] = {name = "SWEP", struct = {Primary = {}, Secondary = {}}},
	["entities"] = {name = "ENT", struct = {}},
	["effects"] = {name = "EFFECT", struct = {}}
}

local registerFuncs = {
	["weapons"] = function(class)
		if SWEP.Slot and SWEP.Slot >= 6 then
			SWEP.Slot = 5
		end

		if CLIENT then
			SWEP.PrintName = LANG.TryTranslation(SWEP.PrintName)
		end

		weapons.Register(SWEP, class)
	end,
	["entities"] = function(class)
		scripted_ents.Register(ENT, class)
	end,
	["effects"] = function(class)
		effects.Register(EFFECT, class)
	end
}

local removePatterns = {
	"AddCSLuaFile%([^)]*%)",
	"include%([^)]*%)"
}

local function RegisterTTTEntity(folder, class, global)
	local str
	if istable(class) then
		str = ""

		for j = 1, #class do
			str = str .. file.Read("gamemodes/terrortown/entities/" .. folder .. "/" .. class[j] .. ".lua", "MOD") .. " "
		end

		class = class[1]
	else
		str = file.Read("gamemodes/terrortown/entities/" .. folder .. "/" .. class .. ".lua", "MOD")
	end

	if !str then return end

	-- remove any instance of AddCSLuaFile() and include()
	for j = 1, #removePatterns do
		local pattern = removePatterns[j]

		local patstart, patend = str:find(pattern)
		while patstart and patend do
			local sub = str:sub(patstart, patend + 1)
			str = str:Replace(sub, "")
			patstart, patend = str:find(pattern)
		end
	end

	_G[global.name] = table.Copy(global.struct)

	RunString(str, class)

	_G[global.name].Spawnable = false

	local slash = class:find("/")
	if slash then
		class = class:Left(slash - 1)
	end

	local register = registerFuncs[folder]
	if register then register(class) end

	_G[global.name] = nil
end

for folder, tbl in pairs(toRegister) do
	local global = globals[folder]

	for i = 1, #tbl do
		RegisterTTTEntity(folder, tbl[i], global)
	end
end

hook.Add("PostGamemodeLoaded", "TraitorJoesWeaponHacks", function()
	local tbl

	if CLIENT then
		-- c4's cl_init.lua depends on DButton being loaded which happens post gamemode
		-- however, registering ents here breaks DEFINE_BASECLASS
		RegisterTTTEntity("entities", {"ttt_c4/shared", "ttt_c4/cl_init"}, globals.entities)
	else
		-- spheredamage checks for ply:Team() == TEAM_TERROR and i would rather not fuck with teams in sandbox
		tbl = scripted_ents.GetStored("ttt_c4").t
		function tbl:SphereDamage(dmgowner, center, radius)
			local r = radius ^ 2

			local d = 0.0
			local dmg = 0
			for _, ent in player.Iterator() do
				if !IsValid(ent) or !ent:IsTerror() then continue end

				d = center:DistToSqr(ent:GetPos())

				if d >= r then continue end

				d = math.max(0, math.sqrt(d) - 490)
				dmg = -0.01 * (d^2) + 125

				local dmginfo = DamageInfo()
				dmginfo:SetDamage(dmg)
				dmginfo:SetAttacker(dmgowner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_BLAST)
				dmginfo:SetDamageForce(center - ent:GetPos())
				dmginfo:SetDamagePosition(ent:GetPos())

				ent:TakeDamageInfo(dmginfo)
			end
		end
	end

	-- ply:GetEyeTrace does not work with the map placed prop_ragdoll
	tbl = weapons.GetStored("weapon_ttt_binoculars")
	function tbl:IsTargetingCorpse()
		local ply = self:GetOwner()
		local tr = util.TraceLine({
			start  = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * (4096 * 8),
			filter = ply,
			mask   = MASK_SHOT
		})

		local ent = tr.Entity

		return IsValid(ent) and ent:GetClass() == "prop_ragdoll" and ent:GetNW2String("gmall_figardo") == "tj_shitleton"
	end

	local confirm = Sound("npc/turret_floor/click1.wav")
	function tbl:IdentifyCorpse()
		if CLIENT and IsFirstTimePredicted() then
			local ply = self:GetOwner()
			ply:EmitSound(confirm)

			local tr = util.TraceLine({
				start  = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * (4096 * 8),
				filter = ply,
				mask   = MASK_SHOT
			})

			if IsValid(tr.Entity) and tr.Entity:GetNW2String("gmall_figardo") == "tj_shitleton" then
				TRAITORJOE.UseEnts["tj_shitleton"](tr.Entity)
			end
		end
	end
end)

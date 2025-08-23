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

if CLIENT then
	-- c4's cl_init.lua depends on DButton being loaded which happens post gamemode
	-- however, registering ents here breaks DEFINE_BASECLASS
	hook.Add("PostGamemodeLoaded", "TraitorJoesC4Hack", function()
		RegisterTTTEntity("entities", {"ttt_c4/shared", "ttt_c4/cl_init"}, globals.entities)
	end)
end
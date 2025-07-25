if game.GetMap() != "mall_store_size" then return end

if engine.ActiveGamemode() != "terrortown" then
	WEAPON_NONE   = 0
	WEAPON_MELEE  = 1
	WEAPON_PISTOL = 2
	WEAPON_HEAVY  = 3
	WEAPON_NADE   = 4
	WEAPON_CARRY  = 5
	WEAPON_EQUIP1 = 6
	WEAPON_EQUIP2 = 7
	WEAPON_ROLE   = 8

	WEAPON_EQUIP = WEAPON_EQUIP1
	WEAPON_UNARMED = -1


	EQUIP_NONE     = 0
	EQUIP_ARMOR    = 1
	EQUIP_RADAR    = 2
	EQUIP_DISGUISE = 4

	EQUIP_MAX      = 4

	local plymeta = FindMetaTable("Player")
	plymeta.IsTerror = plymeta.Alive
	plymeta.IsActive = plymeta.Alive
	function plymeta:IsTraitor() return false end
	function plymeta:IsDetective() return false end
	function plymeta:IsActiveDetective() return false end
	function plymeta:IsActiveTraitor() return false end

	if SERVER then
		util.AddNetworkString("TTT_Credits")
		util.AddNetworkString("TTT_C4Config")
		util.AddNetworkString("TTT_C4DisarmResult")

		--- Equipment credits
		function plymeta:SetCredits(amt)
			self.equipment_credits = amt
			self:SendCredits()
		end

		function plymeta:AddCredits(amt)
			self:SetCredits(self:GetCredits() + amt)
		end
		function plymeta:SubtractCredits(amt) self:AddCredits(-amt) end

		function plymeta:SendCredits()
			net.Start("TTT_Credits")
				net.WriteUInt(self:GetCredits(), 8)
			net.Send(self)
		end

		util.AddNetworkString("TTT_Equipment")

		function plymeta:AddEquipmentItem(id)
			if !self.equipment_items then
				self.equipment_items = EQUIP_NONE
			end

			id = tonumber(id)
			if id then
				self.equipment_items = bit.bor(self.equipment_items, id)
				self:SendEquipment()
			end
		end

		function plymeta:GiveEquipmentItem(id)
			if self:HasEquipmentItem(id) then
				return false
			elseif id and id > EQUIP_NONE then
				self:AddEquipmentItem(id)
				return true
			end
		end

		-- We do this instead of an NW var in order to limit the info to just this ply
		function plymeta:SendEquipment()
			net.Start("TTT_Equipment")
				net.WriteUInt(self.equipment_items, 3)
			net.Send(self)
		end

		function plymeta:ResetEquipment()
			self.equipment_items = EQUIP_NONE
			self:SendEquipment()
		end

		function plymeta:CanCarryType() return true end

		local entmeta = FindMetaTable("Entity")
		function entmeta:BroadcastSound(snd, lvl, pitch, vol, channel, flags, dsp)
			lvl = lvl or 75

			local rf = RecipientFilter()

			if lvl == 0 then
				rf:AddAllPlayers()
			else
				local pos = self:GetPos()

				local attenuation = lvl > 50 and 20.0 / (lvl - 50) or 4.0
				local maxAudible = math.min(2500, 2000 / attenuation)

				for _, ply in player.Iterator() do
					if (ply:EyePos() - pos):Length() > maxAudible then continue end

					rf:AddPlayer(ply)
				end
			end

			self:EmitSound(snd, lvl, pitch, vol, channel, flags, dsp, rf)
		end

		function GetPlayerFilter() return select(2, player.Iterator()) end -- don't worry, player/role filters are normally read only
		GetTraitorFilter = GetPlayerFilter
		GetDetectiveFilter = GetPlayerFilter
		GetInnocentFilter = GetPlayerFilter
		GetRoleFilter = GetPlayerFilter

		SCORE = {}
		function SCORE:HandleC4Explosion() end
		function SCORE:HandleC4Disarm() end
	else
		local function ReceiveCredits()
			local ply = LocalPlayer()
			if !IsValid(ply) then return end

			ply.equipment_credits = net.ReadUInt(8)
		end
		net.Receive("TTT_Credits", ReceiveCredits)

		local function ReceiveEquipment()
			local ply = LocalPlayer()
			if !IsValid(ply) then return end

			ply.equipment_items = net.ReadUInt(3)
		end
		net.Receive("TTT_Equipment", ReceiveEquipment)
	end

	function plymeta:GetCredits() return self.equipment_credits or 0 end

	function plymeta:GetEquipmentItems() return self.equipment_items or EQUIP_NONE end

	-- Given an equipment id, returns if player owns this. Given nil, returns if
	-- player has any equipment item.
	function plymeta:HasEquipmentItem(id)
		if !id then
			return self:GetEquipmentItems() != EQUIP_NONE
		else
			return bit.band(self:GetEquipmentItems(), id) == id
		end
	end

	function GetRoundState() return 3 end -- ROUND_ACTIVE

	function Key(binding, default)
		local b = input.LookupBinding(binding)
		if !b then return default end

		return b:upper()
	end

	function AccessorFuncDT(tbl, varname, name)
		tbl["Get" .. name] = function(s) return s.dt and s.dt[varname] end
		tbl["Set" .. name] = function(s, v) if s.dt then s.dt[varname] = v end end
	end

	function util.PaintDown(start, effname, ignore)
		local btr = util.TraceLine({start = start, endpos = start + Vector(0,0,-256), filter = ignore, mask = MASK_SOLID})

		util.Decal(effname, btr.HitPos + btr.HitNormal, btr.HitPos - btr.HitNormal, ignore)
	end

	function util.WeaponForClass(cls)
		local wep = weapons.GetStored(cls)

		if !wep then
			wep = scripted_ents.GetStored(cls)
			if wep then
				-- don't like to rely on this, but the alternative is
				-- scripted_ents.Get which does a full table copy, so only do
				-- that as last resort
				wep = wep.t or scripted_ents.Get(cls)
			end
		end

		return wep
	end

	function util.SimpleTime(seconds, fmt)
		if !seconds then seconds = 0 end

		local ms = (seconds - math.floor(seconds)) * 100
		seconds = math.floor(seconds)
		local s = seconds % 60
		seconds = (seconds - s) / 60
		local m = seconds % 60

		return string.format(fmt, m, s, ms)
	end

	WEPS = {}
	function WEPS.GetClass(wep)
		if istable(wep) then
			return wep.ClassName or wep.Classname
		elseif IsValid(wep) then
			return wep:GetClass()
		end
	end

	function WEPS.IsEquipment(wep)
		return wep.Kind and wep.Kind >= WEAPON_EQUIP
	end

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
end

local tbl = weapons.Get("weapon_ttt_m16")

tbl.PrintName			= "Carbine"

tbl.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
tbl.WorldModel			= "models/weapons/w_rif_m4a1.mdl"
tbl.ViewModelFOV		= 82
tbl.ViewModelFlip 		= true

tbl.IronSightsPos 		= Vector( 6, 0, 1 )
tbl.IronSightsAng 		= Vector( 2.6, 1.37, 3.5 )

tbl.Primary.Delay			= 1.1
tbl.Primary.Recoil			= 8
tbl.Primary.Automatic = false
tbl.Primary.Ammo = "357"
tbl.Primary.Damage = 70
tbl.Primary.Cone = 0.005
tbl.Primary.ClipSize = 10
tbl.Primary.ClipMax = 20
tbl.Primary.DefaultClip = 10

weapons.Register(tbl, "weapon_ttt_carbine")

tbl = weapons.Get("weapon_ttt_defuser")

tbl.PrintName			= "Defibrillator"

tbl.PrimaryAttack = function(self)
	if CLIENT then return end

	local ply = self:GetOwner()

	local tr = util.TraceLine({
		start  = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 84,
		filter = ply,
		mask   = MASK_SHOT
	})
	if !tr.Hit then return end

	local ent = tr.Entity
	if !ent then return end

	if ent:GetName() != "tj_shitleton" then return end

	local spawn
	for _, e in ents.Iterator() do
		if e:GetName() != "tj_bku_spawn" then continue end

		spawn = e
		break
	end

	if !IsValid(spawn) then return end

	ent:Remove()

	local npc = ents.Create("tj_npc_bku")
	npc:SetPos(spawn:GetPos())
	npc:SetAngles(spawn:GetAngles())
	npc:Spawn()
end

weapons.Register(tbl, "weapon_ttt_tj_defib")
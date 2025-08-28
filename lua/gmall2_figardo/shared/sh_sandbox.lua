COLOR_WHITE  = Color(255, 255, 255, 255)
COLOR_BLACK  = Color(0, 0, 0, 255)
COLOR_GREEN  = Color(0, 255, 0, 255)
COLOR_DGREEN = Color(0, 100, 0, 255)
COLOR_RED    = Color(255, 0, 0, 255)
COLOR_YELLOW = Color(200, 200, 0, 255)
COLOR_LGRAY  = Color(200, 200, 200, 255)
COLOR_BLUE   = Color(0, 0, 255, 255)
COLOR_NAVY   = Color(0, 0, 100, 255)
COLOR_PINK   = Color(255, 0, 255, 255)
COLOR_ORANGE = Color(250, 100, 0, 255)
COLOR_OLIVE  = Color(100, 100, 0, 255)

ROLE_INNOCENT  = 0
ROLE_TRAITOR   = 1
ROLE_DETECTIVE = 2
ROLE_NONE = ROLE_INNOCENT

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

LANG = {}

-- SWEP helpers

local plymeta = FindMetaTable("Player")
plymeta.IsTerror = plymeta.Alive
plymeta.IsActive = plymeta.Alive
function plymeta:IsTraitor() return false end
function plymeta:IsDetective() return false end
function plymeta:IsActiveDetective() return false end
function plymeta:IsActiveTraitor() return false end
function plymeta:IsActiveSpecial() return true end

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

function IsPlayer(ent)
	return ent and ent:IsValid() and ent:IsPlayer()
end

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
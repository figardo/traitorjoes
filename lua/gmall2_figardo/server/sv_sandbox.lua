util.AddNetworkString("TraitorJoe_LangMsg")
util.AddNetworkString("TTT_Radar")

-- LANG.Msg

function LANG.Msg(ply, msg)
	net.Start("TraitorJoe_LangMsg")
		net.WriteString(msg)
	net.Send(ply)
end

-- Body Armour

hook.Add("ScalePlayerDamage", "TraitorJoesBodyArmor", function(ply, hitgroup, dmginfo)
	if dmginfo:IsBulletDamage() and ply:HasEquipmentItem(EQUIP_ARMOR) then
		-- Body armor nets you a damage reduction.
		dmginfo:ScaleDamage(0.7)
	end
end)

-- Radar

local chargetime = 30
local function RadarScan(ply, cmd, args)
	if !IsValid(ply) or !ply:IsTerror() then return end

	if !ply:HasEquipmentItem(EQUIP_RADAR) then
		LANG.Msg(ply, "radar_not_owned")
		return
	end

	if !ply.radar_charge then ply.radar_charge = 0 end
	if ply.radar_charge > CurTime() then
		LANG.Msg(ply, "radar_charging")
		return
	end

	ply.radar_charge =  CurTime() + chargetime

	local scan_ents = player.GetAll()
	table.Add(scan_ents, ents.FindByClass("ttt_decoy"))

	local targets = {}
	for k, p in ipairs(scan_ents) do
		if ply == p or !IsValid(p) then continue end

		if p:IsPlayer() then
			if !p:IsTerror() then continue end
			if p:GetNWBool("disguised", false) and !ply:IsTraitor() then continue end
		end

		local pos = p:LocalToWorld(p:OBBCenter())

		-- Round off, easier to send and inaccuracy does not matter
		pos.x = math.Round(pos.x)
		pos.y = math.Round(pos.y)
		pos.z = math.Round(pos.z)

		local role = ROLE_INNOCENT

		table.insert(targets, {role = role, pos = pos})
	end

	net.Start("TTT_Radar")
		net.WriteUInt(#targets, 8)
		for k, tgt in ipairs(targets) do
			net.WriteUInt(tgt.role, 2)

			net.WriteInt(tgt.pos.x, 15)
			net.WriteInt(tgt.pos.y, 15)
			net.WriteInt(tgt.pos.z, 15)
		end
	net.Send(ply)
end
concommand.Add("ttt_radar_scan", RadarScan)

-- Disguiser

local function SetDisguise(ply, state)
	if !IsValid(ply) then return end

	if ply:HasEquipmentItem(EQUIP_DISGUISE) then
		if hook.Run("TTTToggleDisguiser", ply, state) then return end

		ply:SetNWBool("disguised", state)
		LANG.Msg(ply, state and "disg_turned_on" or "disg_turned_off")
	end
end
concommand.Add("ttt_set_disguise", SetDisguise)

hook.Add("PlayerButtonUp", "TraitorJoesDisguiserToggle", function(ply, btn)
	if btn == KEY_PAD_ENTER and IsValid(ply) and ply:Alive() then
		SetDisguise(ply, !ply:GetNWBool("disguised", false))
	end
end)

-- SWEP Helpers

hook.Add("PlayerCanPickupWeapon", "TraitorJoesWeaponCheck", function(ply, wep)
	if !IsValid(wep) or !IsValid(ply) then return end
	if ply:Team() == TEAM_SPECTATOR then return false end
	if !wep.Base or !wep.Base:StartsWith("weapon_tttbase") then return end

	if ply:HasWeapon(wep:GetClass()) or (wep.Kind and wep.Kind >= WEAPON_EQUIP and wep.IsDropped and !ply:KeyDown(IN_USE)) then
		return false
	end

	local tr = util.TraceEntity({start = wep:GetPos(), endpos = ply:GetShootPos(), mask = MASK_SOLID}, wep)
	if tr.Fraction == 1.0 or tr.Entity == ply then
		wep:SetPos(ply:GetShootPos())
	end

	return true
end)

util.AddNetworkString("TTT_Credits")
util.AddNetworkString("TTT_C4Config")
util.AddNetworkString("TTT_C4DisarmResult")

local plymeta = FindMetaTable("Player")

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
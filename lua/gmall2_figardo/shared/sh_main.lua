if !TRAITORJOE then
	TRAITORJOE = {
		Annoyances = {},
		BoughtItems = {},
		Joe = {
			Annoyances = {
				Queue = {},
				Done = {}
			},
			Members = {},
			ItemsBought = SERVER and {} or 0,
			Jail = {}
		},
		Tony = {
			Annoyances = {
				Queue = {},
				Done = {}
			}
		},
		BKU = {},
		Base = {},
		Bounds = {},
		UseEnts = {}
	}
end

-- Annoyances

ANNOY_MAX = -1
local function RegisterAnnoyance(data)
	ANNOY_MAX = ANNOY_MAX + 1
	TRAITORJOE.Annoyances[ANNOY_MAX] = data

	return ANNOY_MAX
end

-- Shared
ANNOY_HAT = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.HatShot.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.HatShot.1"}
})
ANNOY_PHYSGUN = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.Physgun.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Physgun.1"}
})
ANNOY_RADIO = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.RadioShot.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.RadioShot.1"}
})
ANNOY_DAMAGE = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "neutral", text = "Joe.Shot.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Shot.1"}
})
ANNOY_TOOLGUN = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.Toolgun.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Toolgun.1"}
})
ANNOY_FIRE = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "lookside", text = "Joe.Fire.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Fire.1"}
})
ANNOY_BONES = RegisterAnnoyance({
	["tj_npc_joe"] = {face = "annoyed", text = "Joe.Bones.1"},
	["tj_npc_tony"] = {face = "neutral", text = "Tony.Bones.1"}
})

-- Joe
ANNOY_NOCLIP = RegisterAnnoyance({["tj_npc_joe"] = {face = "annoyed", text = "Joe.ReadTheSign"}})
ANNOY_BACKROOM = RegisterAnnoyance({["tj_npc_joe"] = {face = "neutral", text = "Joe.BackRoom.1"}})
ANNOY_SMASH = RegisterAnnoyance({["tj_npc_joe"] = {face = "annoyed", text = "Joe.Ammo.1"}})
ANNOY_REMOVED = RegisterAnnoyance({
	["tj_npc_joe"] = function(self)
		return self:GetAnnoyanceCount() > 1 and {face = "grin", text = "Joe.Removed.Annoy"} or {face = "smile", text = "Joe.Removed.1"}
	end
})
ANNOY_DISPLAY = RegisterAnnoyance({["tj_npc_joe"] = {face = "neutral", text = "Joe.Display.1"}})
ANNOY_MOVED = RegisterAnnoyance({["tj_npc_joe"] = {face = "smile", text = "Joe.Moved.1"}})
ANNOY_SPRAY = RegisterAnnoyance({["tj_npc_joe"] = {face = "annoyed", text = "Joe.Spray.1"}})
ANNOY_SPAWN = RegisterAnnoyance({["tj_npc_joe"] = {face = "neutral", text = "Joe.Spawn.1"}})
ANNOY_FINAL = RegisterAnnoyance({
	["tj_npc_joe"] = function(self)
		return self:GetAnnoyanceCount() > 1 and {face = "annoyed", text = "Joe.Final.1"} or {face = "smirk", text = "Joe.Final.Good.1"}
	end
})

-- Extra SWEP Registration

hook.Add("PostGamemodeLoaded", "TraitorJoesExtraWeapons", function()
	local tbl = weapons.Get("weapon_ttt_m16")

	tbl.Spawnable			= false
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
			endpos = ply:GetShootPos() + ply:GetAimVector() * 128,
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

		self:EmitSound("ambient/energy/zap7.wav")
	end

	if CLIENT then
		function tbl:Initialize()
			self:AddHUDHelp("Press MOUSE1 to revive a corpse.", nil, false)

			return self.BaseClass.Initialize(self)
		end
	end

	weapons.Register(tbl, "weapon_ttt_tj_defib")
end)
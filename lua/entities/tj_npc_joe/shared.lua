if game.GetMap() != "mall_store_size" then return end

ENT.Base = "tj_npc_base"
ENT.TJGlobalName = "Joe"

ENT.EquipmentItems = {
	{
		name = "item_armor",
		id = 1, -- EQUIP_ARMOR
		desc = "item_armor_desc",
		material = "mall_member/figardo/icon_armor",
		type = "item_passive",
		chat = {face = "grin", text = "Joe.Shop.Item.Armor"}
	},
	{
		name = "item_radar",
		id = 2, -- EQUIP_RADAR
		desc = "item_radar_desc",
		material = "mall_member/figardo/icon_radar",
		type = "item_active",
		chat = {face = "lookside", text = "Joe.Shop.Item.Radar"}
	},
	{
		name = "item_disg",
		id = 4, -- EQUIP_DISGUISE
		desc = "item_disg_desc",
		material = "mall_member/figardo/icon_disguise",
		type = "item_active",
		chat = {face = "grin", text = "Joe.Shop.Item.Disguiser"}
	},
	{
		name = "flare_name",
		id = "weapon_ttt_flaregun",
		desc = "flare_desc",
		material = "mall_member/figardo/icon_flare",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "grin", text = "Joe.Shop.Item.Flare"}
	},
	{
		name = "knife_name",
		id = "weapon_ttt_knife",
		desc = "knife_desc",
		material = "mall_member/figardo/icon_knife",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "neutral", text = "Joe.Shop.Item.Knife"}
	},
	{
		name = "tele_name",
		id = "weapon_ttt_teleport",
		desc = "tele_desc",
		material = "mall_member/figardo/icon_tport",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Teleporter"}
	},
	{
		name = "radio_name",
		id = "weapon_ttt_radio",
		desc = "radio_desc",
		material = "mall_member/figardo/icon_radio",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "smile", text = "Joe.Shop.Item.Radio"}
	},
	{
		name = "newton_name",
		id = "weapon_ttt_push",
		desc = "newton_desc",
		material = "mall_member/figardo/icon_launch",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Newton"}
	},
	{
		name = "polter_name",
		id = "weapon_ttt_phammer",
		desc = "polter_desc",
		material = "mall_member/figardo/icon_polter",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Poltergeist"}
	},
	{
		name = "sipistol_name",
		id = "weapon_ttt_sipistol",
		desc = "sipistol_desc",
		material = "mall_member/figardo/icon_silenced",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "smile", text = "Joe.Shop.Item.Silenced"}
	},
	{
		name = "decoy_name",
		id = "weapon_ttt_decoy",
		desc = "decoy_desc",
		material = "mall_member/figardo/icon_beacon",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "grin", text = "Joe.Shop.Item.Decoy"}
	},
	{
		name = "C4",
		id = "weapon_ttt_c4",
		desc = "c4_desc",
		material = "mall_member/figardo/icon_c4",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.C4"}
	},
	{
		name = "vis_name",
		id = "weapon_ttt_cse",
		desc = "vis_desc",
		material = "mall_member/figardo/icon_cse",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "grin", text = "Joe.Shop.Item.Visualizer"}
	},
	{
		name = "defuser_name",
		id = "weapon_ttt_defuser",
		desc = "defuser_desc",
		material = "mall_member/figardo/icon_defuser",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "annoyed", text = "Joe.Shop.Item.Defuser"}
	},
	{
		name = "binoc_name",
		id = "weapon_ttt_binoculars",
		desc = "binoc_desc",
		material = "mall_member/figardo/icon_binoc",
		type = "item_weapon",
		slot = 8,
		kind = 7,
		limited = true,
		chat = {face = "grin", text = "Joe.Shop.Item.Binoculars"}
	},
	{
		name = "stungun_name",
		id = "weapon_ttt_stungun",
		desc = "ump_desc",
		material = "mall_member/figardo/icon_ump",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.UMP"}
	},
	{
		name = "hstation_name",
		id = "weapon_ttt_health_station",
		desc = "hstation_desc",
		material = "mall_member/figardo/icon_health",
		type = "item_weapon",
		slot = 7,
		kind = 6,
		limited = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.HStation"}
	},

	-- Weapons
	{
		name = "MAC10",
		id = "weapon_zm_mac10",
		desc = "#TraitorJoes.Shop.MAC10",
		material = "mall_member/figardo/icon_mac",
		type = "item_weapon",
		slot = 3,
		kind = 3,
		free = true,
		chat = {face = "lookside", text = "Joe.Shop.Item.MAC10"}
	},
	{
		name = "M16",
		id = "weapon_ttt_m16",
		desc = "#TraitorJoes.Shop.M16",
		material = "mall_member/figardo/icon_m16",
		type = "item_weapon",
		slot = 3,
		kind = 3,
		free = true,
		chat = {face = "grin", text = "Joe.Shop.Item.M16"}
	},
	{
		name = "rifle_name",
		id = "weapon_zm_rifle",
		desc = "#TraitorJoes.Shop.Rifle",
		material = "mall_member/figardo/icon_scout",
		type = "item_weapon",
		slot = 3,
		kind = 3,
		free = true,
		chat = {face = "smile", text = "Joe.Shop.Item.Rifle"}
	},
	{
		name = "shotgun_name",
		id = "weapon_zm_shotgun",
		desc = "#TraitorJoes.Shop.Shotgun",
		material = "mall_member/figardo/icon_shotgun",
		type = "item_weapon",
		slot = 3,
		kind = 3,
		free = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Shotgun"}
	},
	{
		name = "H.U.G.E-249",
		id = "weapon_zm_sledge",
		desc = "#TraitorJoes.Shop.HUGE",
		material = "mall_member/figardo/icon_m249",
		type = "item_weapon",
		slot = 3,
		kind = 3,
		free = true,
		chat = {face = "lookside", text = "Joe.Shop.Item.HUGE"}
	},
	{
		name = "pistol_name",
		id = "weapon_zm_pistol",
		desc = "#TraitorJoes.Shop.Pistol",
		material = "mall_member/figardo/icon_pistol",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "annoyed", text = "Joe.Shop.Item.Pistol"}
	},
	{
		name = "Deagle",
		id = "weapon_zm_revolver",
		desc = "#TraitorJoes.Shop.Deagle",
		material = "mall_member/figardo/icon_deagle",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "neutral", text = "Joe.Shop.Item.Deagle"}
	},
	{
		name = "Glock",
		id = "weapon_ttt_glock",
		desc = "#TraitorJoes.Shop.Glock",
		material = "mall_member/figardo/icon_glock",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Glock"}
	},
	{
		name = "grenade_fire",
		id = "weapon_zm_molotov",
		desc = "#TraitorJoes.Shop.Incendiary",
		material = "mall_member/figardo/icon_incendiary",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Incendiary"}
	},
	{
		name = "confgrenade_name",
		id = "weapon_ttt_confgrenade",
		desc = "#TraitorJoes.Shop.Discomb",
		material = "mall_member/figardo/icon_discomb",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Discomb"}
	},
	{
		name = "grenade_smoke",
		id = "weapon_ttt_smokegrenade",
		desc = "#TraitorJoes.Shop.Smoke",
		material = "mall_member/figardo/icon_smoke",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Smoke"}
	},
	{
		name = "crowbar_name",
		id = "weapon_zm_improvised",
		desc = "#TraitorJoes.Shop.Crowbar",
		material = "mall_member/figardo/icon_cbar",
		type = "item_weapon",
		slot = 1,
		kind = 1,
		free = true,
		chat = {face = "smirk", text = "Joe.Shop.Item.Crowbar"}
	},
	{
		name = "magnet_name",
		id = "weapon_zm_carry",
		desc = "#TraitorJoes.Shop.Magneto",
		material = "mall_member/figardo/icon_magneto",
		type = "item_weapon",
		slot = 2,
		kind = 2,
		free = true,
		chat = {face = "annoyed", text = "Joe.Shop.Item.Magneto"}
	},
	{
		name = "unarmed_name",
		id = "weapon_ttt_unarmed",
		desc = "#TraitorJoes.Shop.Unarmed",
		material = "mall_member/figardo/icon_unarmed",
		type = "item_weapon",
		slot = 6,
		kind = -1,
		free = true,
		chat = {face = "neutral", text = "Joe.Shop.Item.Unarmed"}
	}
}
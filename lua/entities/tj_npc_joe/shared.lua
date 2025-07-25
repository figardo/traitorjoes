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
	}
}
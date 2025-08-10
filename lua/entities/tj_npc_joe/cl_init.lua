if game.GetMap() != "mall_store_size" then return end

include("cl_shop.lua")
include("shared.lua")

ENT.PrintName = "Traitor Joe"
ENT.FaceFolder = "joe"

local initialMenu = {
	["Shop"] = {function(self) return self:ShowShopScreen() end},
	["Talk"] = function(self)
		return self.Talked and {{face = "smile", text = "Joe.Talk.Short"}} or {{face = "smirk", text = "Joe.Talk.1"}, {face = "smile", text = "Joe.Talk.2"}}
	end
}

local talkMenu = function()
	local tbl = {}

	tbl["WhoAreYou"] = {
		{face = "smirk", text = "Joe.WhoAreYou.1"},
		{face = "smile", text = "Joe.WhoAreYou.2"},
		{face = "grin", text = "Joe.WhoAreYou.3"},
		{face = "lookside", text = "Joe.WhoAreYou.4"},
		{face = "smile", text = "Joe.WhoAreYou.5"},
		{face = "smirk", text = "Joe.WhoAreYou.6"}
	}

	tbl["Joe.HowsBusiness"] = {
		{face = "neutral", text = "Joe.HowsBusiness.1"},
		{face = "smile", text = "Joe.HowsBusiness.2"},
		{face = "grin", text = "Joe.HowsBusiness.3"},
		{face = "smile", text = "Joe.HowsBusiness.4"},
		{face = "neutral", text = "Joe.HowsBusiness.5"},
		{face = "lookside", text = "Joe.HowsBusiness.6"},
		{face = "smirk", text = "Joe.HowsBusiness.7"},
		{face = "neutral", text = "Joe.HowsBusiness.8"},
		{face = "lookside", text = "Joe.HowsBusiness.9"},
		{face = "annoyed", text = "Joe.HowsBusiness.10"},
		{face = "lookside", text = "Joe.HowsBusiness.11"},
		{face = "smirk", text = "Joe.HowsBusiness.12"},
		{face = "grin", text = "Joe.HowsBusiness.13"},
		{face = "smile", text = "Joe.HowsBusiness.14"}
	}

	if LocalPlayer():IsListenServerHost() and !IsMounted("treason") then
		table.Add(tbl["Joe.HowsBusiness"], {
			{face = "neutral", text = "Joe.HowsBusiness.NoTony.1"},
			{face = "lookside", text = "Joe.HowsBusiness.NoTony.2"},
			{face = "smirk", text = "Joe.HowsBusiness.NoTony.3"}
		})
	else
		table.insert(tbl["Joe.HowsBusiness"], {face = "smirk", text = "Joe.HowsBusiness.Tony"})
	end

	tbl["Joe.Detective"] = {
		function(self) return self:GetAnnoyed(ANNOY_HAT) and {face = "annoyed", text = "Joe.Detective.Shot.1"} or {face = "neutral", text = "Joe.Detective.1"} end
	}

	if !TRAITORJOE.Joe.Membership then
		tbl["Joe.MemberCard"] = {
			{face = "neutral", text = "Joe.MemberCard.1"},
			{face = "smile", text = "Joe.MemberCard.2"},
			{face = "lookside", text = "Joe.MemberCard.3"},
			{face = "smile", text = "Joe.MemberCard.4"},
			{face = "smirk", text = "Joe.MemberCard.5"}
		}
	elseif !TRAITORJOE.Joe.Redeemed and TRAITORJOE.Joe.ItemsBought >= 5 then
		tbl["Joe.Redeem"] = {
			{face = "grin", text = "Joe.Redeem.1"},
			{face = "smile", text = "Joe.Redeem.2"},
			{face = "neutral", text = "Joe.Redeem.3"},
			{face = "lookside", text = "Joe.Redeem.4"},
			{face = "grin", text = "Joe.Redeem.5"},
			{face = "smile", text = "Joe.Redeem.6"},
			{face = "neutral", text = "Joe.Redeem.7"},
			function(self)
				TRAITORJOE.Joe.Redeemed = true

				net.Start("TraitorJoe_Redeem")
				net.SendToServer()

				return true
			end
		}
	end

	return tbl
end

ENT.ChatLayout = {
	-- Welcome
	["Joe.Welcome.1"] = {
		{face = "smile", text = "Joe.Welcome.2"},
		{face = "smirk", text = "Joe.Welcome.3"},
		{face = "smile", text = "Joe.Welcome.4"},
		{face = "grin", text = "Joe.Welcome.5"}
	},
	["Joe.Welcome.5"] = initialMenu,
	["Joe.WelcomeBack"] = initialMenu,
	["Joe.Anyway"] = initialMenu,

	-- Talk
	["Joe.Talk.2"] = talkMenu,
	["Joe.Talk.Short"] = talkMenu,
	["Joe.WhoAreYou.6"] = talkMenu,
	["Joe.HowsBusiness.Tony"] = talkMenu,
	["Joe.HowsBusiness.NoTony.3"] = talkMenu,
	["Joe.Detective.Shot.1"] = {
		{face = "lookside", text = "Joe.Detective.Shot.2"},
		{face = "neutral", text = "Joe.Detective.1"}
	},
	["Joe.Detective.1"] = {
		{face = "lookside", text = "Joe.Detective.2"},
		{face = "smirk", text = "Joe.Detective.3"}
	},
	["Joe.Detective.3"] = talkMenu,
	["Joe.MemberCard.5"] = talkMenu,

	-- Endings
	["Joe.Final.1"] = {
		{face = "neutral", text = "Joe.Final.2"},
		{face = "smirk", text = "Joe.Final.3"},
		{face = "lookside", text = "Joe.Final.4"},
		{face = "neutral", text = "Joe.Final.5"},
		{face = "smirk", text = "Joe.Final.6"},
		{face = "annoyed", text = "Joe.Final.7"},
		{face = "neutral", text = "Joe.Final.8"},
		{face = "smile", text = "Joe.Final.9"},
		{face = "smirk", text = "Joe.Final.10"},
		{face = "neutral", text = "Joe.Final.11"},
		{face = "smile", text = "Joe.Final.12"},
		function(self) return true end -- close chat
	},

	["Joe.Final.Good.1"] = {
		{face = "smile", text = "Joe.Final.Good.2"},
		{face = "smirk", text = "Joe.Final.Good.3"},
		{face = "lookside", text = "Joe.Final.Good.4"},
		{face = "neutral", text = "Joe.Final.Good.5"},
		{face = "grin", text = "Joe.Final.Good.6"},
		function(self) return true end -- close chat
	},

	-- Shop
	["Joe.Shop.GMCredits.1"] = {
		{face = "neutral", text = "Joe.Shop.GMCredits.2"},
		{face = "smile", text = "Joe.Shop.GMCredits.3"},
		function(self) return self:ShowShopScreen("Joe.Shop.More") end
	},
	["Joe.Shop.NoCredits.1"] = {
		{face = "smirk", text = "Joe.Shop.NoCredits.2"},
		{face = "lookside", text = "Joe.Shop.NoCredits.3"},
		function(self) return self:ShowShopScreen("Joe.Shop.More") end
	},
	["Joe.Shop.NoSpace.1"] = {
		{face = "neutral", text = "Joe.Shop.NoSpace.2"},
		{face = "smirk", text = "Joe.Shop.NoSpace.3"},
		function(self) return self:ShowShopScreen("Joe.Shop.More") end
	},
	["Joe.Shop.HasPassive.1"] = {
		{face = "neutral", text = "Joe.Shop.HasPassive.2"},
		function(self) return self.TwoDisguisers and {face = "smirk", text = "Joe.Shop.HasPassive.Disguiser"} or {face = "smirk", text = "Joe.Shop.HasPassive.3"} end,
		function(self) return self:ShowShopScreen("Joe.Shop.More") end
	},
	["Joe.Shop.Sandbox.1"] = {
		{face = "neutral", text = "Joe.Shop.Sandbox.2"},
		{face = "annoyed", text = "Joe.Shop.Sandbox.3"},
		{face = "smirk", text = "Joe.Shop.Sandbox.4"},
		function(self) return self:ShowShopScreen("Joe.Shop.More") end
	},

	-- Annoyances
	["Joe.ReadTheSign"] = {
		["Joe.ReadTheSign.Yes"] = {
			{face = "angry", text = "Joe.ReadTheSign.Yes1"},
			{face = "annoyed", text = "Joe.ReadTheSign.Yes2"}
		},
		["Joe.ReadTheSign.No"] = {
			{face = "angry", text = "Joe.ReadTheSign.No1"},
			{face = "angry", text = "Joe.ReadTheSign.No2"}
		}
	},
	["Joe.ReadTheSign.Yes2"] = {
		["Joe.ReadTheSign.Sorry"] = {{face = "smile", text = "Joe.Anyway"}}
	},
	["Joe.ReadTheSign.No2"] = {
		["Joe.ReadTheSign.Sorry"] = {{face = "smile", text = "Joe.Anyway"}},
		["Joe.ReadTheSign.WasntThere"] = {
			{face = "annoyed", text = "Joe.ReadTheSign.WasntThere1"},
			{face = "annoyed", text = "Joe.ReadTheSign.WasntThere2"},
			{face = "smirk", text = "Joe.ReadTheSign.WasntThere3"},
			{face = "smile", text = "Joe.Anyway"}
		}
	},
	["Joe.HatShot.1"] = {
		{face = "angry", text = "Joe.HatShot.2"},
		{face = "annoyed", text = "Joe.HatShot.3"},
		{face = "smirk", text = "Joe.HatShot.4"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.RadioShot.1"] = {
		{face = "smile", text = "Joe.RadioShot.2"},
		{face = "neutral", text = "Joe.RadioShot.3"},
		{face = "annoyed", text = "Joe.RadioShot.4"},
		{face = "smirk", text = "Joe.RadioShot.5"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.BackRoom.1"] = {
		{face = "lookside", text = "Joe.BackRoom.2"},
		{face = "smirk", text = "Joe.BackRoom.3"},
		{face = "annoyed", text = "Joe.BackRoom.4"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Physgun.1"] = {
		{face = "annoyed", text = "Joe.Physgun.2"},
		{face = "neutral", text = "Joe.Physgun.3"},
		{face = "neutral", text = "Joe.Physgun.4"},
		{face = "angry", text = "Joe.Physgun.5"},
		{face = "annoyed", text = "Joe.Anyway"}
	},
	["Joe.Shot.1"] = {
		{face = "smile", text = "Joe.Shot.2"},
		{face = "smirk", text = "Joe.Shot.3"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Toolgun.1"] = {
		{face = "neutral", text = "Joe.Toolgun.2"},
		{face = "angry", text = "Joe.Toolgun.3"},
		{face = "lookside", text = "Joe.Toolgun.4"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Ammo.1"] = {
		{face = "lookside", text = "Joe.Ammo.2"},
		{face = "smirk", text = "Joe.Ammo.3"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Fire.1"] = {
		{face = "smirk", text = "Joe.Fire.2"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Removed.Annoy"] = {
		{face = "smile", text = "Joe.Removed.1"}
	},
	["Joe.Removed.1"] = {
		{face = "smirk", text = "Joe.Removed.2"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Display.1"] = {
		{face = "smirk", text = "Joe.Display.2"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Moved.1"] = {
		{face = "neutral", text = "Joe.Moved.2"},
		{face = "lookside", text = "Joe.Moved.3"},
		{face = "smirk", text = "Joe.Moved.4"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.Spec.1"] = {
		{face = "lookside", text = "Joe.Spec.2"},
		{face = "smirk", text = "Joe.Spec.3"},
		function(self) return true end -- close chat
	},

	-- Forks
	["Joe.CR.1"] = {
		{face = "annoyed", text = "Joe.CR.2"},
		{face = "smirk", text = "Joe.CR.3"},
		{face = "neutral", text = "Joe.CR.4"},
		{face = "smirk", text = "Joe.CR.5"},
		{face = "smile", text = "Joe.Anyway"}
	},
	["Joe.TTT2.1"] = {
		{face = "annoyed", text = "Joe.TTT2.2"},
		{face = "lookside", text = "Joe.TTT2.3"},
		{face = "smile", text = "Joe.TTT2.4"},
		{face = "neutral", text = "Joe.TTT2.5"},
		{face = "smile", text = "Joe.Anyway"}
	}
}

ENT.ChatHooks = {
	["Joe.Talk.2"] = function(self) self.Talked = true end,
	["Joe.MemberCard.5"] = function(self)
		TRAITORJOE.Joe.Membership = true

		net.Start("TraitorJoe_ApplyForMembership")
		net.SendToServer()

		return true
	end,
	["Joe.HowsBusiness.NoTony.3"] = function(self)
		net.Start("TraitorJoe_SpawnDefib")
		net.SendToServer()
	end,
	["Joe.Final.Good.1"] = function(self)
		net.Start("TraitorJoe_SpawnTrash")
		net.SendToServer()
	end
}

ENT.AnnoyMessages = {
	[ANNOY_PHYSGUN] = {
		"Put me down!",
		"Cut it out!",
		"Quit messin' around!"
	}
}

function ENT:GetInitialChat()
	if LocalPlayer():GetObserverMode() != OBS_MODE_NONE then
		return {face = "annoyed", text = "Joe.Spec.1"}
	end

	local annoyed = self:AnnoyedCheck()
	if annoyed then return annoyed end

	if TRAITORJOE.Joe.Met then
		return {face = "smile", text = "Joe.WelcomeBack"}
	end

	if TTT2 or CR_VERSION then
		if !TTT2 then
			return {face = "grin", text = "Joe.CR.1"}
		end

		if !CR_VERSION then
			return {face = "grin", text = "Joe.TTT2.1"}
		end

		-- you have both enabled you muppet
		ErrorNoHaltWithStack("You have TTT2 and Custom Roles for TTT enabled at the same time! Please disable one of them.")
		return {face = "annoyed", text = "Error.1"}
	end

	return {face = "grin", text = "Joe.Welcome.1"}
end
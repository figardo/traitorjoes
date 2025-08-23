if game.GetMap() != "mall_store_size" then return end

include("gmall2_figardo/shared/sh_main.lua")

-- anything copied directly from ttt will be in these files
if engine.ActiveGamemode() != "terrortown" then
	include("gmall2_figardo/shared/sh_sandbox.lua")

	if CLIENT then
		include("gmall2_figardo/client/cl_sandbox.lua")
	else
		AddCSLuaFile("gmall2_figardo/shared/sh_sandbox.lua")
		AddCSLuaFile("gmall2_figardo/shared/sh_sandbox_sweps.lua")
		AddCSLuaFile("gmall2_figardo/client/cl_sandbox.lua")
		include("gmall2_figardo/server/sv_sandbox.lua")
	end

	include("gmall2_figardo/shared/sh_sandbox_sweps.lua")
end

if CLIENT then
	include("gmall2_figardo/client/cl_main.lua")
else
	AddCSLuaFile("gmall2_figardo/shared/sh_main.lua")
	AddCSLuaFile("gmall2_figardo/client/cl_main.lua")
	include("gmall2_figardo/server/sv_main.lua")
end
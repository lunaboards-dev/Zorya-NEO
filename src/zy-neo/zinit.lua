local lzss_decompress = ...
--Zorya NEO itself.
_BIOS = "Zorya NEO"
_ZVSTR = "2.0"
_ZVER = 2.0
_ZPAT = 0
_ZGIT = "$[[git rev-parse --short HEAD]]"
--#include "ksrc/kinit.lua"
local thd = krequire("thd")
local util = krequire("util")
local sys = krequire("sys")
local component = component
local computer = computer
local booted = false
local zcfg = {}
function log(...)
	component.proxy(component.list("ocemu")() or component.list("sandbox")()).log(...)
end
local th_i = 0
local function th_a(func)
	thd.add("zyneo$"..th_i, func)
	th_i = th_i + 1
end

local function load_lua(src, ...)
	if (src:sub(1, 4) == "\27ZLSS") then
		src = lzss_decompress(src:sub(5))
	end
	return load(src, ...)
end

local builtins = {}
--#include "src/zy-neo/utils.lua"

sys.add_lib("zorya", (function()

	local mod_search = {}

	local zy = {}
	--function zy.get_bootlist()

	--end

	--function zy.boot(i)
	--	th_a(zcfg[i][2](zcfg[i][3]))
	--	booted = true
	--end

	local loaded_mods = {}

	function zy.loadmod(mod)
		if (loaded_mods[mod]) then return loaded_mods[mod] end
		for i=1, #mod_search do
			log(i, #mod_search, mod)
			local r = mod_search[i](mod)
			if r then loaded_mods[mod] = r return r end
		end
	end

	function zy.loader_run(func, env)
		func(env)
	end

	function zy.add_mod_search(func)
		mod_search[#mod_search+1] = func
		log(#mod_search)
	end

	function zy.lkthdn()
		return #thd.getthreads()
	end

	function zy.lkthdi(i)
		return thd.getthreads()[i][1]
	end
	return zy
end)())

--#include "src/zy-neo/init.lua"

-- Zorya's handler thread.
th_a(function()
	local er
	xpcall(function()
		local zy = krequire("zorya")
		zy.add_mod_search(function(mod)
			if (bfs.exists(".zy2/mods/"..mod..".zy2m")) then
				return load_lua(bfs.getfile(".zy2/mods/"..mod..".zy2m"), "=.zy2/mods/"..mod..".zy2m")()
			elseif (bfs.exists(".zy2/mods/"..mod.."/init.zy2m")) then
				return load_lua(bfs.getfile(".zy2/mods/"..mod.."/init.zy2m"), "=.zy2/mods/"..mod.."/init.zy2m")()
			end
		end)
		sys.add_search(function(mod)
			if (builtins[mod]) then
				return builtins[mod]
			end
		end)
		sys.add_search(function(mod)
			if (bfs.exists(".zy2/lib/"..mod..".zy2l")) then
				return load_lua(bfs.getfile(".zy2/lib/"..mod..".zy2l"), "=.zy2/lib/"..mod..".zy2l")
			elseif (bfs.exists(".zy2/lib/"..mod.."/init..zy2l")) then
				return load_lua(bfs.getfile(".zy2/lib/"..mod.."/init.zy2l"), "=.zy2/lib/"..mod.."/init.zy2l")
			end
		end)
		local zycfg = bfs.getfile(".zy2/cfg.lua")
		-- Config loaded, now we can do our shit.
		local env = {
			zorya = zy,
			loadmod = zy.loadmod,
			loadfile = bfs.getfile,
			_BOOTADDR = bfs.addr
		}
		for k, v in pairs(_G) do
			env[k] = v
		end
		env._G = env
		env._ENV = env
		return assert(load(zycfg, "=zycfg", "t", env))()
	end, function(e)
		er = e..": "..debug.traceback()
	end)
	if er then error(er) end
end)

sys.start()
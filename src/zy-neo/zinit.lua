local lzss_decompress = ...
--Zorya NEO itself.
_BIOS = "Zorya NEO"
_ZVSTR = "2.0-rc5"
_ZVER = 2.0
_ZPAT = 0
_ZGIT = "$[[git rev-parse --short HEAD]]"
--#include "ksrc/kinit.lua"
local thd = krequire("thd")
local sys = krequire("sys")
local component = component
local computer = computer
local cinvoke = component.invoke
local clist = component.list
local cproxy = component.proxy
local th_i = 0
local function th_a(func)
	thd.add("zyneo$"..th_i, func)
	th_i = th_i + 1
end

local function load_lua(src, ...)
	if (src:sub(1, 4) == "\27ZLS") then
		src = lzss_decompress(src:sub(5))
	end
	return load(src, ...)
end

--#include "src/zy-neo/builtins/util_tsar.lua"

local builtins = {}
--#include "src/zy-neo/utils.lua"
local log = utils.debug_log

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

	function zy.add_mod_search(func)
		mod_search[#mod_search+1] = func
		log(#mod_search)
	end

	function zy.lkthdn()
		return #thd.get_threads()
	end

	function zy.lkthdi(i)
		return thd.get_threads()[i]
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
			if (bfs.exists(".zy2/mods/"..mod..".velx")) then
				--utils.debug_log(mod, ".zy2m")
				--return load_lua(bfs.getfile(".zy2/mods/"..mod..".zy2m"), "=.zy2/mods/"..mod..".zy2m")()
				local r,s,c = bfs.getstream(".zy2/mods/"..mod..".velx")
				return assert(utils.load_velx(r,s,c,".zy2/mods/"..mod..".velx"))()
			end
		end)
		sys.add_search(function(mod)
			if (builtins[mod]) then
				return builtins[mod]
			end
		end)
		sys.add_search(function(mod)
			if (bfs.exists(".zy2/lib/"..mod..".velx")) then
				local r,s,c = bfs.getstream(".zy2/lib/"..mod..".velx")
				return utils.load_velx(r,s,c,".zy2/lib/"..mod..".velx")
				--return load_lua(bfs.getfile(".zy2/lib/"..mod..".velx"), "=.zy2/lib/"..mod..".zy2l")
			end
		end)
		local zycfg = bfs.getcfg()
		-- Config loaded, now we can do our shit.
		local env = utils.make_env()
		env.zorya = zy
		env.loadmod = zy.loadmod
		env.loadfile = bfs.getfile
		env._BOOTADDR = bfs.addr

		local c, e = load(zycfg, "=zycfg", "t", env)
		if c then
			return c()
		else
			utils.console_panic(e)
		end
	end, function(e)
		er = e..": "..debug.traceback()
		if(not utils.console_panic(er)) then
			er = er .. "\n(Lua console failed to start)"
		end
	end)
	if er then error(er) end
end)

sys.start()
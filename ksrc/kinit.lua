-- lkern is the light kernel used by Zorya NEO to simplify development.
@[[local lfs = require("lfs")]]
--#include "ksrc/require.lua"
@[[function lib_include(name)]]
krlib["@[{name}]"] = (function()
	@[[call_directive("kinit.lua:10","include","ksrc/libs/"..name..".lua")]]
end)()
@[[end]]

@[[for ent in lfs.dir("ksrc/libs") do
	if (ent:match("%.lua$")) then
		lib_include(ent:sub(1, #ent-4))
	end
end]]

local ps = computer.pullSignal
local thd = krequire("thd")
local last_sig = {}
krlib["system"] = (function()
	local sys = {}
	function sys.start()
		while thd.run() do end
	end
	local prun_i = 0
	function sys.protected_run(code, name)
		name = name or "lkprc$"..prun_i
		--Spin up a new thread
		local env = {}
		for k, v in pairs(_G) do
			env[k] = v
		end
		env._ENV = env
		env._G = env
		env.krequire = nil
		thd.add(name, assert(load(code, "="..name, "t", env)))
	end
	function sys.add_lib(lib, tbl)
		krlib[lib] = tbl
	end
	function sys.add_search(search)
		krfind[#krfind+1] = search
	end
	return sys
end)()
krlib["sys"] = krlib["system"]
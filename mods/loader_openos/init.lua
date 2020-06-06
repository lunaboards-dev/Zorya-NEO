local zy = krequire("zorya")
--zy.loadmod("vdev_biosdev")
local utils = krequire("utils")
local thd = krequire("thd")
--local vdev = krequire("zorya").loadmod("util_vdev")
local vdev = krequire("util_vcomponent")
local function proxytable(t)
	return setmetatable({}, {__index=function(self, i)
		if (type(t[i]) == "table") then
			self[i] = proxytable(t[i])
			return rawget(self, i)
		else
			return t[i]
		end
	end})
end
local openos_count = 0
return function(addr)
	local fs = component.proxy(addr)
	--vdev.overwrite(_G)
	--[[function computer.getBootAddress()
		return addr
	end
	function computer.setBootAddress()end
	local env = utils.deepcopy(_G)
	env._ENV = env
	env._G = env
	env.krequire = nil]]
	--vdev.install(env)
	--log(env, env.computer, env.computer.getBootAddress, env.computer.getBootAddress())
--	local env = proxytable(_G)
	thd.add("openos$"..openos_count, function()
		local env = utils.make_env()
		function env.computer.getBootAddress()
			return addr
		end
		function env.computer.setBootAddress()end
		local old_dl = utils.debug_log
		load(utils.readfile(fs.address, fs.open("init.lua")), "=init.lua", "t", env)()
		computer.pushSignal("openos_dead")
	end)
	while true do
		if computer.pullSignal() == "openos_dead" then
			utils.debug_log("Got signal.")
			break
		end
	end
end
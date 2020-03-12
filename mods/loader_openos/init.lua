local zy = krequire("zorya")
--zy.loadmod("vdev_biosdev")
local utils = krequire("utils")
--local vdev = krequire("zorya").loadmod("util_vdev")
local vdev = krequire("util_vcomponent")
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
	function computer.getBootAddress()
		return addr
	end
	function computer.setBootAddress()end
	local old_dl = utils.debug_log
	load(utils.readfile(fs.address, fs.open("init.lua")), "=init.lua", "t", env)()
end
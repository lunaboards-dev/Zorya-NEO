local zy = krequire("zorya")
--zy.loadmod("vdev_biosdev")
local utils = krequire("utils")
--local vdev = krequire("zorya").loadmod("util_vdev")
return function(addr)
	local fs = component.proxy(addr)
	local kr = krequire
	krequire = nil
	--vdev.overwrite(_G)
	function computer.getBootAddress()
		return addr
	end
	function computer.setBootAddress()end
	--log(env, env.computer, env.computer.getBootAddress, env.computer.getBootAddress())
	load(utils.readfile(fs.address, fs.open("init.lua")), "=init.lua", "t")()
	krequire = kr
end
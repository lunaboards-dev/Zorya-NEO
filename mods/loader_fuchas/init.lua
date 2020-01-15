local zy = krequire("zorya")
--zy.loadmod("vdev_biosdev")
local utils = krequire("utils")
local thd = krequire("thd")
--local vdev = krequire("zorya").loadmod("util_vdev")
local oefi = zy.loadmod("util_oefiv2")
-- No low-level loading yet.
return function(addr, args)
	--oefi.getExtensions().ZyNeo_ExecOEFIApp(addr, ".efi/fuchas.efi2", ...)
	--We don't do that here.
	local env = oefi.getExtensions().ZyNeo_GetOEFIEnv(addr)
	env.computer.supportsOEFI = function()
		return true
	end
	env.os_arguments = args
	env.loadfile = env.oefi.loadfile
	thd.add("fuchas", function()
		env.loadfile("Fuchas/Kernel/boot.lua")() --This is how we do.
		computer.pushSignal("fuchas_dead")
	end)
	while true do if computer.pullSignal() == "fuchas_dead" then break end end
end
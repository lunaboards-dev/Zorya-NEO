local zy = krequire("zorya")
--zy.loadmod("vdev_biosdev")
local utils = krequire("utils")
local thd = krequire("thd")
--local vdev = krequire("zorya").loadmod("util_vdev")
local oefi = zy.loadmod("util_oefiv2")
local fuchas = {}

function fuchas:karg(key, value)
	self.args[key] = value
end

function fuchas:boot()
	thd.add("fuchas", function()
		self.env.loadfile("Fuchas/Kernel/boot.lua")() --This is how we do.
		computer.pushSignal("fuchas_dead")
	end)
	while true do if computer.pullSignal() == "fuchas_dead" then break end end
end

return function(addr)
	--oefi.getExtensions().ZyNeo_ExecOEFIApp(addr, ".efi/fuchas.efi2", ...)
	--We don't do that here.
	local fuch = {}
	fuch.args = {}
	fuch.env = oefi.getExtensions().ZyNeo_GetOEFIEnv(addr)
	fuch.env.computer.supportsOEFI = function()
		return true
	end
	fuch.env.os_arguments = fuch.args
	fuch.env.loadfile = fuch.env.oefi.loadfile
	return setmetatable(fuch, {__index=fuchas})
end

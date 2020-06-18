local cfgadd = ...
local comp = require("component")
local fs = require("filesystem")
for fs in comp.list("filesystem") do
	if comp.invoke(fs, "exists", "OS.lua") then
		print("MineOS discovered on "..fs)
				cfgadd(string.format([[
menu.add("MineOS on %s", function()
	local thd = krequire("thd")
	local utils = krequire("utils")
	thd.add("mineos", function()
		local fsaddr = "%s"
		local env = utils.make_env()
		function env.computer.getBootAddress()
			return fsaddr
		end
		function env.computer.setBootAddress()end
		load(utils.readfile(fsaddr, component.invoke(fsaddr, "open", "OS.lua")), "=OS.lua", "t", env)()
		computer.pushSignal("mineos_dead")
	end)
	while true do
		if computer.pullSignal() == "mineos_dead" then
			utils.debug_log("Got signal.")
			break
		end
	end
end)
]], fs:sub(1, 3), fs))
	end
end
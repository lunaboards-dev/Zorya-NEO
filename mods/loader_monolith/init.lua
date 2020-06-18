-- monolith loader --
local zy = krequire("zorya")
local utils = krequire("utils")
local thd = krequire("thd")
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
local monolith_count = 0
return function(addr)
	local fs = component.proxy(addr)
	thd.add("monolith$"..monolith_count, function()
		local env = utils.make_env()
		function env.computer.getBootAddress()
			return addr
		end
		function env.computer.setBootAddress()end
		local old_dl = utils.debug_log
		load(utils.readfile(fs.address, fs.open("/boot/kernel/loader")), "=/boot/kernel/loader", "t", env)()
		computer.pushSignal("monolith_dead")
	end)
	while true do
		if computer.pullSignal() == "monolith_dead" then
			utils.debug_log("Got signal.")
			break
		end
	end
end

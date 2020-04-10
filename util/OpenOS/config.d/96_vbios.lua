local cfgadd = ...
--local addr = require("component").eeprom.getData()
local fs = require("filesystem")
cfgadd([[
do
	local function add_bios(drive, path)
		local h = component.invoke(drive, "open", path.."/label.txt")
		local name = component.invoke(drive, "read", h, math.huge)
		component.invoke(drive, "close", h)
		menu.add(name .. " (vBIOS)", function()
			local vb = loadmod("vdev_vbios")(drive, path)
			vb()
		end)
	end
]])
for ent in fs.list("/etc/zorya-neo/vbios/") do
	local prox, path = fs.get("/etc/zorya-neo/vbios/"..ent)
	local rpath = ("/etc/zorya-neo/vbios/"..ent):sub(#path+1)
	cfgadd(string.format([[	add_bios("%s",  "%s")]].."\n", prox.address, rpath:sub(1, #rpath-1)))
end
cfgadd[[
end
]]
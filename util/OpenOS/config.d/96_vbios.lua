local cfgadd = ...
local addr = require("component").eeprom.getData()
local fs = require("filesystem")
if not fs.exists("/.zy2/vbios/") then
	return
end
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
for ent in fs.list("/.zy2/vbios") do
	cfgadd(string.format([[	add_bios("%s",  ".zy2/vbios/%s")]].."\n", addr, ent:sub(1, #ent-1)))
end
cfgadd[[
end
]]
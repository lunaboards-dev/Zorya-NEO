local cfgadd = ...
local fs = require("filesystem")
if not fs.exists("/etc/zorya-neo/custom.lua") then
	return
end
local f = io.open("/etc/zorya-neo/custom.lua")
cfgadd(f:read("*a"))
f:close()
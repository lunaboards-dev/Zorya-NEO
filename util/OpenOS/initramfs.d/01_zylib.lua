local arc = ...
arc.dir(".zy2/lib")
local fs = require("filesystem")
local function readfile(path)
	local f = io.open(path)
	local dat = f:read("*a")
	f:close()
	return dat
end
for ent in fs.list("/etc/zorya-neo/lib") do
	arc.file(".zy2/lib/"..ent, "r-xr-xr-x", readfile("/etc/zorya-neo/lib/"..ent))
end

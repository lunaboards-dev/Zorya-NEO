local arc = ...
arc.dir(".zy2")
arc.dir(".zy2/mods")
local fs = require("filesystem")
local function readfile(path)
	local f = io.open(path)
	local dat = f:read("*a")
	f:close()
	return dat
end
for ent in fs.list("/etc/zorya-neo/mods") do
	arc.file(".zy2/mods/"..ent, "r-xr-xr-x", readfile("/etc/zorya-neo/mods/"..ent))
end
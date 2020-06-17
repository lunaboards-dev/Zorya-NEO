local arc = ...
local function readfile(path)
	local f = io.open(path)
	local dat = f:read("*a")
	f:close()
	return dat
end
arc.file("bootstrap.bin", "r-xr-xr-x", readfile("/etc/zorya-neo/bootstrap.bin"))
local cfgadd = ...
local fs = require("filesystem")
if not fs.exists("/etc/zorya-neo/entries/") then
	return
end
local function readfile(path)
	local f = io.open(path)
	local dat = f:read("*a")
	f:close()
	return dat
end
for ent in fs.list("/etc/zorya-neo/entries/") do
	local label = readfile("/etc/zorya-neo/entries/"..ent.."/label.txt")
	local code = readfile("/etc/zorya-neo/entries/"..ent.."/code.lua")
	cfgadd(string.format([[
menu.add("%s", function())
%s
end)]], label, code))
end
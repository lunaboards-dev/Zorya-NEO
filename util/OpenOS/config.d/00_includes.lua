local cfgadd = ...
local addr = require("component").eeprom.getData()
print("Zorya NEO is installed at "..addr)
cfgadd([[
local menu = loadmod("menu_classic")
]])
if (_ZLOADER == "managed") then
	cfgadd(string.format([[
do
	local sp = loadmod("util_searchpaths")
	sp.add_mod_path("%s", ".zy2/mods")
	sp.add_lib_path("%s", ".zy2/lib")
end
]], addr, addr))
end
local cfgadd = ...
cfgadd([[
menu.add("Lua Console", function()
	loadmod("util_luaconsole")()
end)
menu.draw()
]])
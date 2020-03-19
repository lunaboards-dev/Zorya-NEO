local cfgadd = ...
local comp = require("component")
for fs in comp.list("filesystem") do
	if comp.invoke(fs, "getLabel") == "OpenOS" and comp.invoke(fs, "exists", "init.lua") then
		print("OpenOS discovered on "..fs)
		cfgadd(string.format([[
menu.add("OpenOS on %s", function()
	return loadmod("loader_openos")("%s")
end)
]], fs:sub(1, 3), fs))
	end
end
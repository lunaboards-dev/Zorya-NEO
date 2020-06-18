local cfgadd = ...
local comp = require("component")
for fs in comp.list("filesystem") do
	if comp.invoke(fs, "exists", ".efi/fuchas.efi2") then
		print("Fuchas discovered on "..fs)
		cfgadd(string.format([[
menu.add("Fuchas on %s", function()
	local baddr = "%s"
	local ldr = loadmod("loader_fuchas")(baddr)
	ldr:karg("--boot-address", baddr)
	ldr:karg("--bios-compat", "zy-neo")
	ldr:boot()
end)
]], fs:sub(1, 3), fs))
	end
end
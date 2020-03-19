local fs = require("filesystem")
print("Regenerating Zorya NEO configuration...")
fs.copy("/.zy2/cfg.lua", "/.zy2/cfg.lua.old")
local f = io.open("/.zy2/cfg.lua", "wb")
local lst = {}
for ent in fs.list("/etc/zorya-neo/config.d") do
	if ent:sub(#ent) ~= "/" then
		lst[#lst+1] = ent
	end
end
table.sort(lst)
for i=1, #lst do
	print("> "..lst[i])
	assert(loadfile("/etc/zorya-neo/config.d/"..lst[i]))(function(code)
		f:write(code)
	end)
end
f:close()
print("Generated new configuration.")
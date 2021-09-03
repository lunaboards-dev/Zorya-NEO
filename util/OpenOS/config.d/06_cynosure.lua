local cfgadd = ...
local component = require("component")
for fs in component.list("filesystem") do
  if component.invoke(fs, "exists", "/boot/cynosure.lua") then
    print("Cynosure kernel discovered on " .. fs)
    cfgadd(string.format([[
menu.add("Cynosure kernel on %s", function()
  return loadmod("loader_cynosure")("%s")
end)
    ]], fs:sub(1,3), fs))
  end
end

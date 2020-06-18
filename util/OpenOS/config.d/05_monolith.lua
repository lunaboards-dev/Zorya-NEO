local cfgadd = ...
local component = require("component")
for fs in component.list("filesystem") do
  if (component.invoke(fs, "getLabel") == "Monolith" or component.invoke(fs, "exists", "/boot/monolith")) and component.invoke(fs, "exists", "init.lua") then
    print("Monolith discovered on " .. fs)
    cfgadd(string.format([[
menu.add("Monolith on %s", function()
  return loadmod("loader_monolith")("%s")
end)
    ]], fs:sub(1,3), fs))
  end
end

local component = component

local function loadfile(addr, file)
	local handle = assert(component.invoke(addr, "open", file))
	local buffer = ""
	repeat
		local data = component.invoke(addr, "read", handle, math.huge)
		buffer = buffer .. (data or "")
	until not data
	component.invoke(addr, "close", handle)
	local global = {}
	for k, v in pairs(_G) do
		global[k] = v
	end
	for k, v in pairs(OSEXPORT) do
		global[k] = v
	end
	return load(buffer, "=" .. file, "bt", global)
end
EXPORT.loadfile = loadfile
MODULE.loadfile = loadfile
OSEXPORT.zorya = OSEXPORT.zorya or {}
OSEXPORT.zorya.loadfile = loadfile --For legacy purposes.
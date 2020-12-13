local cfg = {}
local function b2a(data)
	return string.format(string.format("%s-%s%s",string.rep("%.2x", 4),string.rep("%.2x%.2x-",3),string.rep("%.2x",6)),string.byte(data, 1,#data))
end
local function a2b(addr)
  addr=addr:gsub("%-", "")
  local baddr = ""
  for i=1, #addr, 2 do
    baddr = baddr .. string.char(tonumber(addr:sub(i, i+1), 16))
  end
  return baddr
end
do
	-- Get EEPROM config data.
	local eep = component.proxy(component.list("eeprom")())
	local dat = eep.getData():sub(37)
end
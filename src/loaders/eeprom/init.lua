zorya = {}
_ZVER = 2.0
_ZPAT = 0
_BIOS = "Zorya NEO BIOS"
local component = component
local cproxy = component.proxy
local clist = component.list
local eeprom = cproxy(clist("ee")())
-- Decode our EEPROM. Note that this is OEFIv2 compliant.
local cdat = eeprom.getData()
if cdat:byte(1) ~= 2 then
	error("Invalid configuration.")
end
if (cdat:sub(18, 38) ~= "Zorya NEO BIOS      ") then
	error("Invalid configuration.")
end
--Now we can get our boot FS
function binToHex(id)
	local f, r = string.format, string.rep
	return f(f("%s-%s%s", r("%.2x", 4), r("%.2x%.2x-", 3), r("%.2x", 6)), id:byte(1, 16))
end
local fs = binToHex(cdat:sub(39, 55))
fs = component.proxy(fs)

local function loadfile(file)
	local handle = assert(fs.open(file))
	local buffer = ""
	repeat
		local data = fs.read(handle, math.huge)
		buffer = buffer .. (data or "")
	until not data
	fs.close(handle)
	return load(buffer, "=" .. file, "bt", _G)
end

loadfile(".zv2/boot.urt")(loadfile, fs.address)
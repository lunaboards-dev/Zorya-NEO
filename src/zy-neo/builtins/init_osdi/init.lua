local osdi = {}

local function int(str)
	local t=0
	for i=1, #str do
		t = t | (str:byte(i) << ((i-1)*8))
	end
	return t
end

local function get_part_info(meta, part)
	local info = meta:sub((part*32)+1, ((part+1)*32))
	local start = int(info:sub(1, 4))
	local size = int(info:sub(5, 8))
	local ptype = info:sub(9, 16)
	local flags = int(info:sub(17, 19))
	local label = info:sub(20):gsub("\0", "")
	return {start = start,
		size = size,
		ptype = ptype,
		flags = flags,
		label = label
	}
end

local function pad(str, len)
	return str .. string.rep(" ", len-#str)
end

function osdi.get_table(volume)
	local t = {}
	local meta = component.invoke(volume, "readSector", 1)
	for i=2, 16 do
		t[i-1] = get_part_info(meta, i)
	end
end

return osdi
local component = component
local osdi = {}

local function decode_entry(ent)
	local start, size, ptype, flags, name = string.unpack("<i4i4c8i3c13", ent)
	return {
		start = start,
		size = size,
		type = ptype,
		flags = flags,
		name = name:sub(1, name:match("\0")-1)
	}
end

local function encode_entry(ent)
	ent.name = ent.name:sub(1, 12)
	ent.name = ent.name .. string.rep("\0", 13-#ent.name)
	ent.type = ent.type:sub(1, 8)
	ent.type = ent.type .. string.rep("\0", 8-#ent.type)
	return string.pack("<i4i4c8i3c13", ent.start, ent.size, ent.type, ent.flags, ent.name)
end

function osdi.read_table(addr)
	local sec = component.invoke(addr, "readSector", 1)
	local tbl = {}
	for i=0, 15 do
		tbl[i+1] = decode_entry(sec:sub((i*32)+1, (i+1)*32))
	end
	return tbl
end

function osdi.write_entry(addr, i, tbl)
	i = i - 1
	local sec = component.invoke(addr, "readSector", 1)
	local dat1, dat2 = sec:sub(1, (i*32)), sec:sub(((i+1)*32)+1)
	component.invoke(addr, "writeSector", 1, dat1..encode_entry(tbl)..dat2)
	return true
end

return osdi
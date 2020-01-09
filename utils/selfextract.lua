local arg = arg or {...}
local string, table = string, table

local POS_BITS = 12
local LEN_BITS = 16 - POS_BITS
local POS_SIZE = 1 << POS_BITS
local LEN_SIZE = 1 << LEN_BITS
local LEN_MIN = 3

function lzss_decompress(input)
	local offset, output = 1, {}
	local window = ''

	while offset <= #input do
		local flags = string.byte(input, offset)
		offset = offset + 1

		for i = 1, 8 do
			local str = nil
			if (flags & 1) ~= 0 then
				if offset <= #input then
					str = string.sub(input, offset, offset)
					offset = offset + 1
				end
			else
				if offset + 1 <= #input then
					local tmp = string.unpack('>I2', input, offset)
					offset = offset + 2
					local pos = (tmp >> LEN_BITS) + 1
					local len = (tmp & (LEN_SIZE - 1)) + LEN_MIN
					str = string.sub(window, pos, pos + len - 1)
				end
			end
			flags = flags >> 1
			if str then
				output[#output + 1] = str
				window = string.sub(window .. str, -POS_SIZE)
			end
		end
	end

	return table.concat(output)
end
print("Decompressing CPIO...")
local code = lzss_decompress(@[{io.stdin:read("*a")}])
local dat = code
local tbl = {}

local pos = 1
local function read(n)
	local d = dat:sub(pos, pos+n)
	pos = pos + n
	return d
end

local function readint(amt, rev)
	local tmp = 0
	for i=(rev and amt) or 1, (rev and 1) or amt, (rev and -1) or 1 do
		tmp = tmp | (read(1):byte() << ((i-1)*8))
	end
	return tmp
end

while true do
	local dent = {}
	dent.magic = readint(2)
	local rev = false
	if (dent.magic ~= tonumber("070707", 8)) then rev = true end
	dent.dev = readint(2)
	dent.ino = readint(2)
	dent.mode = readint(2)
	dent.uid = readint(2)
	dent.gid = readint(2)
	dent.nlink = readint(2)
	dent.rdev = readint(2)
	dent.mtime = (readint(2) << 16) | readint(2)
	dent.namesize = readint(2)
	dent.filesize = (readint(2) << 16) | readint(2)
	local name = read(dent.namesize):sub(1, dent.namesize-1)
	if (name == "TRAILER!!!") then break end
	--for k, v in pairs(dent) do
	--	print(k, v)
	--end
	dent.name = name
	if (dent.namesize % 2 ~= 0) then
		pos = pos + 1
	end
	if (dent.mode & 32768 ~= 0) then
		--fwrite()
	end
	dent.pos = pos
	pos = pos + dent.filesize
	if (dent.filesize % 2 ~= 0) then
		pos = pos + 1
	end
	tbl[#tbl+1] = dent
end

local unpack = unpack or table.unpack

for i=1, #tbl do
	if (tbl[i].name == "init.lua") then
		load(dat:sub(tbl[i].pos, tbl[i].pos+tbl[i].filesize-1))(tbl, dat, unpack(arg))
	end
end
-- P A I N

local flag_crit = 1 << 6
local flag_required = 1 << 7
local flag_ext = 1 << 8

local function read_ali(fs, h)
	local tmp = 0
	local ctr = 0
	while true do
		local b = fs.read(h, 1):byte()
		tmp = tmp | ((b & 0x7F) << (ctr*7))
		if (b & 0x80 > 0) then
			break
		end
	end
	return tmp
end

local function read_entrydat(fs, h)
	local etype = fs.read(h, 1):byte()
end
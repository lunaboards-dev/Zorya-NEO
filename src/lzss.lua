local s, t = string, table
local ss = s.sub

--------------------------------------------------------------------------------
local POS_BITS = 12
local LEN_BITS = 16 - POS_BITS
local POS_SIZE = 1 << POS_BITS
local LEN_SIZE = 1 << LEN_BITS
local LEN_MIN = 3

local function lzss_decompress(input)
	local offset, output = 1, {}
	local window = ''

	while offset <= #input do
		local flags = s.byte(input, offset)
		offset = offset + 1

		for i = 1, 8 do
			local str = nil
			if (flags & 1) ~= 0 and offset <= #input then
				str = ss(input, offset, offset)
				offset = offset + 1
			elseif offset + 1 <= #input then
				local tmp = s.unpack('>I2', input, offset)
				offset = offset + 2
				local pos = (tmp >> LEN_BITS) + 1
				local len = (tmp & (LEN_SIZE - 1)) + LEN_MIN
				str = ss(window, pos, pos + len - 1)
			end
			flags = flags >> 1
			if str then
				output[#output + 1] = str
				window = ss(window .. str, -POS_SIZE)
			end
		end
	end

	return t.concat(output)
end
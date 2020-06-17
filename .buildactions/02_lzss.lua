local M = {}
local string, table = string, table

--------------------------------------------------------------------------------
local POS_BITS = 12
local LEN_BITS = 16 - POS_BITS
local POS_SIZE = 1 << POS_BITS
local LEN_SIZE = 1 << LEN_BITS
local LEN_MIN = 3

--------------------------------------------------------------------------------
function M.compress(input)
	local offset, output = 1, {}
	local window = ''

	local function search()
		for i = LEN_SIZE + LEN_MIN - 1, LEN_MIN, -1 do
			local str = string.sub(input, offset, offset + i - 1)
			local pos = string.find(window, str, 1, true)
			if pos then
				return pos, str
			end
		end
	end

	while offset <= #input do
		local flags, buffer = 0, {}

		for i = 0, 7 do
			if offset <= #input then
				local pos, str = search()
				if pos and #str >= LEN_MIN then
					local tmp = ((pos - 1) << LEN_BITS) | (#str - LEN_MIN)
					buffer[#buffer + 1] = string.pack('>I2', tmp)
				else
					flags = flags | (1 << i)
					str = string.sub(input, offset, offset)
					buffer[#buffer + 1] = str
				end
				window = string.sub(window .. str, -POS_SIZE)
				offset = offset + #str
			else
				break
			end
		end

		if #buffer > 0 then
			output[#output + 1] = string.char(flags)
			output[#output + 1] = table.concat(buffer)
		end
	end

	return table.concat(output)
end

--------------------------------------------------------------------------------
function M.decompress(input)
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

local lzss = M
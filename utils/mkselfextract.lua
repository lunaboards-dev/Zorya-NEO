local f = io.stdin:read("*a")

local function mkstr(d)
	local dat = "\""
	for i=1, #f do
		if (d:byte(i) == 0) then
			dat = dat .. "\0"
		elseif (d:sub(i,i) == "\\") then
			dat = dat .. ("\\\\")
		elseif (d:sub(i,i) == "\"") then
			dat = dat .. ("\\\"")
		elseif (d:sub(i,i) == "\n") then
			dat = dat .. ("\\n")
		elseif (d:sub(i,i) == "\r") then
			dat = dat .. ("\\r")
		else
			dat = dat .. (d:sub(i,i))
		end
	end
	dat = dat .. ("\"")
	return dat
end

local M = {}
local string, table = string, table

--------------------------------------------------------------------------------
local POS_BITS = 12
local LEN_BITS = 16 - POS_BITS
local POS_SIZE = 1 << POS_BITS
local LEN_SIZE = 1 << LEN_BITS
local LEN_MIN = 3

--------------------------------------------------------------------------------
function lzss_compress(input)
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

local tmp = os.tmpname()
local h = io.popen("luacomp ../utils/selfextract.lua -O"..tmp, "w")
h:write(mkstr(lzss_compress(f)))
h:close()
local f = io.open(tmp, "rb")
io.stdout:write(f:read("*a"))
f:close()
os.remove(tmp)
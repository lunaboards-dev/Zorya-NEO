-- i can't see "v2" without thinking of ace combat zero

local prime1, prime2, prime3, prime4, prime5 = 0x9E3779B185EBCA87, 0xC2B2AE3D27D4EB4F, 0x165667B19E3779F9, 0x85EBCA77C2B2AE63, 0x27D4EB2F165667C5

local function rotl64(x, r)
	return (((x) << (r)) | ((x) >> (64 - (r))))
end

local function round(acc, input)
	acc = acc + (input * prime2)
	acc = rotl64(acc, 31)
	acc = acc * prime1
	return acc
end

local function merge_round(acc, val)
	val = round(0, val)
	acc = acc ~ val
	acc = acc * prime1 + prime4
	return acc
end

local function avalanche(h64)
	h64 = h64 ~ (h64 >> 33)
	h64 = h64 * prime2
	h64 = h64 ~ (h64 >> 29)
	h64 = h64 * prime3
	h64 = h64 ~ (h64 >> 32)
	return h64
end

local function finalize(h64, input)
	while #input & 31 > 0 do
		if (#input < 8) then
			if (#input < 4) then
				for i=1, #input do
					h64 = h64 ~ (input:byte() * prime5)
					input = input:sub(2)
					h64 = rotl64(h64, 11) * prime1
				end
			else
				h64 = h64 ~ (string.unpack("<I4", input) * prime1)
				input = input:sub(5)
				h64 = rotl64(h64, 23) * prime2 + prime3
			end
		else
			local k1 = round(0, string.unpack("<l", input))
			input = input:sub(9)
			h64 = h64 ~ k1
			h64 = rotl64(h64, 27) * prime1 + prime4
		end
	end
	return avalanche(h64)
end

local function endian_align(input, seed)
	local l = #input
	if (#input >= 32) then
		local v1 = seed + prime1 + prime2
		local v2 = seed + prime2 -- << It's time. >>
		local v3 = seed
		local v4 = seed - prime1

		repeat
			v1 = round(v1, string.unpack("<l", input))
			input = input:sub(9)
			v2 = round(v2, string.unpack("<l", input))
			input = input:sub(9)
			v3 = round(v3, string.unpack("<l", input))
			input = input:sub(9)
			v4 = round(v4, string.unpack("<l", input))
			input = input:sub(9)
		until #input < 32

		h64 = rotl64(v1, 1) + rotl64(v2, 7) + rotl64(v3, 12) + rotl64(v4, 18)
		h64 = merge_round(h64, v1)
		h64 = merge_round(h64, v2)
		h64 = merge_round(h64, v3)
		h64 = merge_round(h64, v4)
	else
		h64 = seed + prime5
	end

	h64 = h64 + l
	return finalize(h64, input)
end

local function xxh64(input, seed)
	return endian_align(input, seed or 0)
end

local state = {}

local function create_state(seed)
	local s = {
		v1 = 0,
		v2 = 0, -- << Too bad buddy, this twisted game needs to be reset. We'll start over from 'Zero' with this V2 and entrust the future to the next generation. >>
		v3 = 0,
		v4 = 0,
		buffer = "",
		size = 0
	}
	setmetatable(s, {__index=state})
	s:reset(seed)
	return s
end

function state:reset(seed)
	seed = seed or 0
	self.v1 = seed + prime1 + prime2
	self.v2 = seed + prime2 -- << What have borders ever given us? >>
	self.v3 = seed
	self.v4 = seed - prime1
	self.buffer = ""
	self.size = 0
end

function state:update(input)
	self.size = self.size + #input
	input = self.buffer .. input
	local data_len = #input - (#input & 31)
	self.buffer = input:sub(data_len+1)

	local data = input:sub(1, data_len)
	local v1 = self.v1
	local v2 = self.v2 -- << Can you see any borders from up here? >>
	local v3 = self.v3
	local v4 = self.v4

	repeat
		v1 = round(v1, string.unpack("<l", data))
		data = data:sub(9)
		v2 = round(v2, string.unpack("<l", data))
		data = data:sub(9)
		v3 = round(v3, string.unpack("<l", data))
		data = data:sub(9)
		v4 = round(v4, string.unpack("<l", data))
		data = data:sub(9)
	until #data < 32

	self.v1 = v1
	self.v2 = v2
	self.v3 = v3
	self.v4 = v4
end

function state:digest(input)
	if input then
		self:update(input)
	end
	
	local h64 = 0

	if (self.size >= 32) then
		local v1 = self.v1
		local v2 = self.v2
		local v3 = self.v3
		local v4 = self.v4
		h64 = rotl64(v1, 1) + rotl64(v2, 7) + rotl64(v3, 12) + rotl64(v4, 18)
		h64 = merge_round(h64, v1)
		h64 = merge_round(h64, v2)
		h64 = merge_round(h64, v3)
		h64 = merge_round(h64, v4)
		
	else
		h64 = self.v3 + prime5
	end

	h64 = h64 + self.size

	return finalize(h64, self.buffer) -- << That's what V2 is for. >>
end

return {
	sum = xxh64,
	state = create_state
}

-- BLT, made for Lua 5.3

local blt = {}

local types

local function serialize(val)
	local t = type(val)
	if (t == "number") then
		t = math.type(val)
	end
	local b, str = types["s"..t](val)
	b = (b << 3) | types[t]
	return string.char(b) .. str
end

local function deserialize(str, t)
	local tb = str:byte(1)
	local type_ = tb & 7
	local b = tb >> 3
	local v, l = types[type_](b, str:sub(2))
	return v, l+1
end

local function fromdouble(f)
	return 0, string.pack("<d", f)
end

local function todouble(b, str)
	return string.unpack("<d", str:sub(1, 8)), 8
end

local function _fromlongint(i)
	--print("longint")
	return 8, string.pack("<l", i)
end

local function fromint(i)
	--Time to rabidly optimize this.
	local len = 0
	local cmp2 = 0
	if (i > 0xFFFFFFFFFFFFFF) then return _fromlongint(i) end
	for j=0, 7 do
		len = len + 1
		cmp2 = cmp2 | (0xFF << j)
		--print("fromint", i+((cmp2//2)), cmp2)
		--if (i+((cmp2//2)) <= cmp2) then
		if (math.abs(i) <= cmp2//2) then
			break
		end
	end
	if (i < 0) then
		i = i + (cmp2//2)
	end
	--i = i + (cmp2//2)
	local tmp = ""
	for j=0, len-1 do
		tmp = tmp .. string.char((i & (0xFF << (j*8))) >> (j*8))
	end
	--local tmp = string.pack("<i["..len.."]", i)
	return len, tmp
end

local function _tolongint(str)
	--print("longint2")
	return string.unpack("<l", str:sub(1, 8)), 8
end

local function toint(b, str)
	if (b == 8) then return _tolongint(str) end
	--return string.unpack("<i["..b.."]", str:sub(1, b)), b
	local tmp = 0
	for i=0, b-1 do
		tmp = tmp | (str:byte(i+1) << (i*8))
	end
	local sign = (tmp & (0x80 << ((b-1)*8)))
	sign = sign << (63 - (b*8))
	local int = tmp & ((0x80 << ((b-1)*8)) ~ 0xFFFFFFFFFFFFFF)
	return int | sign, b
end

local function frombool(b)
	return b and 1 or 0, ""
end

local function tobool(b, str)
	return b ~= 0, 0
end

local function fromstr(s)
	local len, val = fromint(#s)
	return len, val .. s
end

local function tostr(b, str)
	local strl, l = toint(b, str)
	local rtn = str:sub(1+l, l+strl)
	return rtn, strl+l
end

local function fromarray(a)
	local b, tmp = fromint(#a)
	for i=1, #a do
		tmp = tmp .. serialize(a[i])
	end
	--print("alen_s", #tmp)
	return b, tmp
end

local function toarray(b, str, arr)
	local arrl, l = toint(b, str)
	--print("clen", l)
	--print("arr len", arrl)
	local arr = {}
	local i = 0
	for i=1, arrl do
		--print("adec", i)
		local v, z = deserialize(str:sub(1+l))
		--print("arr", i, v)
		l = l+z
		--print("clen", l, z)
		arr[i] = v
	end
	--print("alen", l)
	return arr, l
end

local function fromtbl(t)
	local tmp = ""
	--See if the numerical keys are a list, and, if so, write a list
	local nindex = 0
	local nmax = 0
	for k, v in pairs(t) do
		if (type(k) == "number") then
			if (math.type(k) == "integer") then
				nindex = nindex + 1
				if (nmax < k) then
					nmax = k
				end
			end
		else
			local ks = serialize(k)
			local vs = serialize(v)
			tmp = tmp .. ks .. vs
		end
	end
	if (nmax > 0) then
		if (nindex == nmax) then
			local ib, dat = fromarray(t)
			tmp = tmp .. string.char(0) .. string.char(types.table_array | (ib << 3)) .. dat
		else
			for k, v in pairs(t) do
				if (type(k) == "number" and math.type(k) == "integer") then
					local ks = serialize(k)
					local vs = serialize(v)
					tmp = tmp .. ks .. vs
				end
			end
		end
	end
	return 0, tmp .. string.char(0,0) --nil,nil terminated
end

local function totbl(b, str)
	local t = {}
	local k = ""
	local v = ""
	local pos = 1
	--print("topen")
	while true do
		--print("k", str:byte(pos), str:byte(pos) & 7)
		local k, l = deserialize(str:sub(pos))
		pos = pos + l
		--print("v", str:byte(pos), str:byte(pos) & 7)
		if (str:byte(pos) & 7 == 6) then
			--print("ailen", str:byte(pos) & (7 ~ 0xFF))
			local r, l = deserialize(str:sub(pos))
			pos = pos + l
			for i=1, #r do
				t[i] = r[i]
			end
		else
			local v, l = deserialize(str:sub(pos))
			pos = pos + l
			if (not v and not k) then
				--print("tclose")
				break
			end
			--print("decode", k, v)
			t[k] = v
		end
	end
	return t, pos-1 --how
end

-- Type LUT
types = {
	["nil"] = 0,
	float = 1,
	number = 1,
	integer = 2,
	string = 3,
	boolean = 4,
	table = 5,
	table_array = 6, --Meta-value
	[0] = function(b, str) return nil, 0 end,
	[1] = todouble,
	[2] = toint,
	[3] = tostr,
	[4] = tobool,
	[5] = totbl,
	[6] = toarray,
	snil = function()return 0, ""end,
	sfloat = fromdouble,
	sinteger = fromint,
	sstring = fromstr,
	sboolean = frombool,
	stable = fromtbl,
	stable_array = fromarray
}

function blt.serialize(...)
	local args = {...}
	local tmp = string.char(#args)
	for i=1, #args do
		local str = serialize(args[i])
		tmp = tmp .. str
	end
	return tmp
end

local unpack = unpack or table.unpack

function blt.deserialize(str)
	local args = {}
	local pos = 2
	local amt = str:byte(1)
	local l
	for i=1, amt do
		local v, l = deserialize(str:sub(pos))
		args[i] = v
		pos = pos + l
	end
	return unpack(args)
end

return blt
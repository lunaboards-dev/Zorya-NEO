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

local function read_int(fs, h, count)
	local tmp = 0
	for i=0, count-1 do
		tmp = tmp | (fs.read(h, 1):byte() << (count*8))
	end
	return tmp
end

local function read_string(fs, h)
	local len = read_ali(fs, h)
	return fs.read(h, len)
end

local xdec = {
	["NAME"] = function(fs, h)
		return read_string(fs, h)
	end,
	["PERM"] = function(fs, h)
		return read_int(fs, h, 2)
	end,
	["W32P"] = function(fs, h)
		return fs.read(h, 1):byte()
	end,
	["OTIM"] = function(fs, h)
		return read_int(fs, h, 8)
	end,
	["MTIM"] = function(fs, h)
		return read_int(fs, h, 8)
	end,
	["CTIM"] = function(fs, h)
		return read_int(fs, h, 8)
	end,
	["ATIM"] = function(fs, h)
		return read_int(fs, h, 8)
	end,,
	["SCOS"] = function(fs, h)
		return read_string(fs, h)
	end
}

local decode = {
	["X"] = function(fs, h, size)
		local oid = read_ali(fs, h)
		local xtype = fs.read(h, 4)
		return {
			type = "meta",
			id = oid,
			key = xtype,
			value = xdec[xtype](fs, h)
		}
	end,
	["F"] = function(fs, h, size)
		return {
			type="file",
			name = read_string(fs, h),
			offset = read_ali(fs, h),
			size = read_ali(fs, h),
			id = read_ali(fs, h),
			pid = read_ali(fs, h)
		}
	end,
	["D"] = function(fs, h, size)
		return {
			type="dir",
			name = read_string(fs, h),
			id = read_ali(fs, h),
			pid = read_ali(fs, h)
		}
	end,
	["Z"] = function(fs, h, size)
		return {
			type="eoh"
			size = read_ali(fs, h)
		}
	end
}

local function read_entrydat(fs, h)
	local etype = fs.read(h, 1)
	local ebyte = etype:byte()
	local size = read_ali(fs, h)
	if (ebyte & flag_crit > 0 and not decode[etype]) then error("Unknown critical entry.") end
	if (ebyte & flag_required == 0) then error("Required flag not set.") end
	if (decode[etype]) then
		return decode[etype](fs, h, size)
	end
	return {type="unknown"}
end

local function get_offset(fs, h)
	fs.seek(h, "set", 9)
	local ent = {}
	while ent.type ~= "eoh" do
		ent = read_entrydat(fs, h)
	end
	return fs.seek(h, "cur", 0), ent.size
end

local function path_part_iter(path)
	path = path:gsub("/+", "/"):gsub("^/", ""):gsub("/$", "")
	local lpos = 1
	return function()
		if not lpos then return nil end
		local s, e = path:find("(.-)/", lpos)
		if not s then
			local lp = lpos
			lpos = nil
			return path:sub(lp)
		end
		local rtn = path:sub(s, e-1)
		lpos = e+1
		return rtn
	end
end

local unpack = unpack or table.unpack

local function sfpcall(a, func, ...)
	local ptr = a.fs.seek(a.h, "cur", 0)
	local rv = {func(...)}
	a.fs.seek(a.h, "set", ptr)
	return unpack(rv)
end

local function cache_obj(a, objdat)
	a.cache = a.cache or {}
	a.cache[#a.cache+1] = objdat
end

local function get_obj_prop(a, obj, name)
	name = name:upper()
	if (a.cache) then
		for i=1, #a.cache do
			if (a.cache[i].type=="meta" and a.cache[i].id==obj and a.cache[i].key == name) then return a.cache[i].value end
		end
	end
	fs.seek(h, "set", 9)
	local ent = {}
	while ent.type ~= "eoh" do
		ent = read_entrydat(fs, h)
		if (ent.type=="meta" and ent.id==obj and ent.key == name) then
			cache_obj(a, ent)
			return ent.value
		end
	end
end

local function path_to_obj(a, path)
	if (path == "/" or path == "") then
		return {
			type = "dir",
			name = "/root\\",
			id = 0,
			pid = 0
		}
	end
	local tbl = {}
	for p in path_part_iter(path) do
		tbl[#tbl+1] = p
	end
	local part = 1
	local pid = 0
	--search cache
	if (a.cache) then
		local i = 0
		while i < #a.cache do
			i = i+1
			if (a.cache[i].type == "file" or a.cache[i].type == "dir") then
				if (a.cache[i].pid == pid and (a.cache[i].name == tbl[part] or get_obj_prop(a, a.cache[i].id, "NAME") == tbl[part])) then
					part = part+1
					pid = a.cache[i].id
					i=0
					if (part == #tbl) then
						return a.cache[i], pid
					end
				end
			end
		end
	end
	-- Now we search the hard way, then cache along the way.
	fs.seek(h, "set", 9)
	local ent = {}
	while ent.type ~= "eoh" do
		ent = read_entrydat(fs, h)
		if (ent.type == "file" or ent.type=="dir") then
			if (ent.name == tbl[part] or sfpcall(get_obj_prop, a, ent.id, "NAME") == tbl[part]) then
				pid = ent.id
				cache_obj(a, ent)
				part = part + 1
			end
			if (part == #tbl) then
				break
			end
		end
	end
	return ent, pid
end

local function get_by_id(a, id)
	if (a.cache) then
		for i=1, #a.cache do
			if ((a.cache[i].type=="file" or a.cache[i].type=="dir") and a.cache[i].id==id) then return a.cache[i] end
		end
	end
	fs.seek(h, "set", 9)
	local ent = {}
	while ent.type ~= "eoh" do
		ent = read_entrydat(fs, h)
		if ((ent.type=="file" or ent.type=="dir") and ent.id==id) then
			cache_obj(a, ent)
			return ent
		end
	end
end

local function id_to_path(a, id)
	local ne = get_by_id(a, id)
	if not ne then return nil, "not found" end
	local path = get_obj_prop(a, id, "NAME") or ne.name
	path = "/" .. path
	while ne and ne.pid > 0 do
		ne = get_by_id(a, ne.pid)
		if not ne then return nil, "not found" end
		path = "/" .. (get_obj_prop(a, ne.id, "NAME") or ne.name) .. path
	end
	return path
end

local urf = {}
function urf.open(drive, path)
	local fs = component.proxy(drive)
	local hand = fs.open(path)
	if fs.read(hand, 8) ~= "URF\x11\1\1\x12\0" then return nil, "bad signature" end
	local e, z = get_offset(fs, hand)
	return setmetatable({
		fs = fs,
		h = hand,
		cache = {},
		epos = e,
		bsize = z
	}, {__index=arc})
end

local arc = {}
function arc:fetch(path)
	local obj = path_to_obj(self, path)
	if (obj.type ~= "file") then return nil, "not a file" end
	self.fs.seek(self.h, "set", self.epos+obj.offset)
	return self.fs.read(self.h, obj.size)
end

function arc:close()
	self.cache = nil
	self.fs.close(self.h)
	self.fs = nil
end

function arc:list_dir(path)
	local obj = path_to_obj(self, path)
	if (obj.type ~= "dir") then return nil, "not a dir" end
	local objects = {}
	for i=1, self.cache do
		if (self.cache[i].pid == obj.id) then
			objects[#objects+1] = (get_obj_prop(self, self.cache[i].id, "NAME") or self.cache[i].name)
		end
	end

	self.fs.seek(self.h, "set", 9)
	local ent = {}
	while ent.type ~= "eoh" do
		ent = read_entrydat(self.fs, self.h)
		if ((ent.type=="file" or ent.type=="dir") and ent.pid==obj.id) then
			cache_obj(self, ent)
			objects[#objects+1] = sfpcall(get_obj_prop, self, ent.id, "NAME") or ent.name
		end
	end
	return objects
end

return urf
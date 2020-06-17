local romfs = {}
local arc = {}

local function readint(r, n)
	local str = assert(r(n), "Unexpected EOF!")
	return string.unpack("<i"..n, str)
end

function romfs.read(read, seek, close)
	local sig = read(7)
	assert(sig, "Read error!")
	if sig ~= "romfs\1\0" then error(string.format("Invalid romfs (%.14x != %.14x)", sunpack("i7", sig), sunpack("i7", "romfs\1\0"))) end
	local tbl = {}
	local lname
	while lname ~= "TRAILER!!!" do
		local nz = read(1):byte()
		local name = read(nz)
		local fsize = readint(read, 2)
		local exec = read(1)
		tbl[#tbl+1] = {name = name, size = fsize, exec = exec == "x", pos = seek(0)}
		utils.debug_log(nz, name, fsize, exec)
		seek(fsize)
		lname = name
	end
	tbl[#tbl] = nil
	return setmetatable({tbl=tbl, read=read,seek=seek, close=close}, {__index=arc})
end

function arc:fetch(path)
	for i=1, #self.tbl do
		if self.tbl[i].name == path then
			self.seek(self.tbl[i].pos-self.seek(0))
			return self.read(self.tbl[i].size)
		end
	end
	return nil, "file not found"
end

function arc:exists(path)
	for i=1, #self.tbl do
		if (self.tbl[i].name == path) then
			return true
		end
	end
	return false
end

function arc:close()
	self.close()
	self.tbl = nil
	self.read = nil
	self.seek= nil
	self.close = nil
end

function arc:list_dir(path)
	if path:sub(#path) ~= "/" then path = path .. "/" end
	local ent = {}
	for i=1, #self.tbl do
		if (self.tbl[i].name:sub(1, #path) == path and not self.tbl[i].name:find("/", #path+1, false)) then
			ent[#ent+1] = self.tbl[i].name
		end
	end
	return ent
end
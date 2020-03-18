local magic = 0x5f7d
local magic_rev = 0x7d5f
local header_fmt = "I2I2I2I2I2I6I6"
local en = string.unpack("=I2", string.char(0x7d, 0x5f)) == magic -- true = LE, false = BE
local function get_end(e)
	return (e and "<") or ">"
end
local function read_header(dat)
	local e = get_end(en)
	local m = string.unpack(e.."I2", dat)
	if m ~= magic and m ~= magic_rev then return nil, "bad magic" end
	if m ~= magic then
		e = get_end(not en)
	end
	local ent = {}
	ent.magic, ent.namesize, ent.mode, ent.uid, ent.gid, ent.filesize, ent.mtime = string.unpack(e..header_fmt, dat)
	return ent
end

local arc = {}

function arc:fetch(path)
	for i=1, #self.tbl do
		if (self.tbl[i].name == path and self.tbl[i].mode & 32768 > 0) then
			self.seek(self.tbl[i].pos-self.seek(0))
			return self.read(self.tbl[i].filesize), self.tbl[i]
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

function arc:list(path)
	if path:sub(#path) ~= "/" then path = path .. "/" end
	local ent = {}
	for i=1, #self.tbl do
		if (self.tbl[i].name:sub(1, #path) == path and not self.tbl[i].name:find("/", #path+1, false)) then
			ent[#ent+1] = self.tbl[i].name
		end
	end
	return ent
end

function arc:close()
	self.close()
end

local tsar = {
	read = function(read, seek, close)
		local tbl = {}
		local lname = ""
		while lname ~= "TRAILER!!!" do
			local dat = read(22)
			local e = read_header(dat)
			e.name = read(e.namesize)
			e.pos = seek(e.namesize & 1)
			seek(e.filesize + (e.filesize & 1))
			lname = e.name
			if lname ~= "TRAILER!!!" then
				tbl[#tbl+1] = e
			end
		end
		return setmetatable({tbl = tbl, read = read, seek = seek, close = close}, {__index=tsar})
	end
}
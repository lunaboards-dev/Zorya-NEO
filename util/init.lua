local args = {...}
local tbl = args[1]
local dat = args[2]
table.remove(args, 1)
table.remove(args, 1)

local function getfile(path)
	for i=1, #tbl do
		if (tbl[i].name == path) then
			return dat:sub(tbl[i].pos, tbl[i].pos+tbl[i].filesize-1)
		end
	end
end

local function writefile(p2, dat)
	local f = io.open(p2, "wb")
	f:write(dat)
	f:close()
end

if (debug.debug) then
	print("This software cannot be run on a normal computer. This is only for OpenOS.")
	os.exit(1)
end

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
		return setmetatable({tbl = tbl, read = read, seek = seek, close = close}, {__index=arc})
	end
}

local fs = require("filesystem")
print("Installing Zorya NEO utils.")
fs.makeDirectory("/etc/zorya-neo")
fs.makeDirectory("/etc/zorya-neo/mods")
fs.makeDirectory("/etc/zorya-neo/lib")
fs.makeDirectory("/etc/zorya-neo/config.d")
fs.makeDirectory("/etc/zorya-neo/initramfs.d")
fs.makeDirectory("/etc/zorya-neo/vbios")
print("Installing utils to /usr")
fs.makeDirectory("/usr/bin")
writefile("/usr/bin/zyneo-gencfg.lua", getfile("OpenOS/zyneo-gencfg.lua"))
writefile("/usr/bin/zyvbios-new.lua", getfile("OpenOS/zyvbios-new.lua"))
writefile("/usr/bin/zyneo-geninitramfs.lua", getfile("OpenOS/zyneo-geninitramfs.lua"))
writefile("/usr/bin/zyneo-update.lua", getfile("OpenOS/zyneo-update.lua"))
print("Installing scripts...")
for i=1, #tbl do
	if tbl[i].name:sub(1, 16) == "OpenOS/config.d/" then
		writefile("/etc/zorya-neo/config.d/"..tbl[i].name:sub(17), getfile(tbl[i].name))
	elseif tbl[i].name:sub(1, 19) == "OpenOS/initramfs.d/" then
		writefile("/etc/zorya-neo/initramfs.d/"..tbl[i].name:sub(20), getfile(tbl[i].name))
	end
end
print("Extracting image.tsar...")
local t = io.open("/.zy2/image.tsar", "rb")
local arc = tsar.read(function(a)
	return t:read(a)
end, function(a)
	return t:seek("cur", a)
end, function()
	return t:close()
end)
local lst = arc:list(".zy2/mods")
for i=1, #lst do
	print(lst[i])
	writefile("/etc/zorya-neo/mods/"..lst[i]:sub(10), arc:fetch(lst[i]))
end
local lst = arc:list(".zy2/lib")
for i=1, #lst do
	print(lst[i])
	writefile("/etc/zorya-neo/lib/"..lst[i]:sub(9), arc:fetch(lst[i]))
end
arc:close()
print("Installation complete.")
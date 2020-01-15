local comp = component
local cpio = {}
local arc = {}

local function read(f, h, n)
	local d = f.read(h, n)
	return d
end

local function readint(f, h, amt, rev)
	local tmp = 0
	for i=(rev and amt) or 1, (rev and 1) or amt, (rev and -1) or 1 do
		tmp = tmp | (read(f, h, 1):byte() << ((i-1)*8))
	end
	return tmp
end

function cpio.read(drive, path)
	local f = comp.proxy(drive)
	local h = f.open(path)
	local tbl = {}
	while true do
		local dent = {}
		dent.magic = readint(f, h, 2)
		local rev = false
		if (dent.magic ~= tonumber("070707", 8)) then rev = true end
		dent.dev = readint(f, h, 2)
		dent.ino = readint(f, h, 2)
		dent.mode = readint(f, h, 2)
		dent.uid = readint(f, h, 2)
		dent.gid = readint(f, h, 2)
		dent.nlink = readint(f, h, 2)
		dent.rdev = readint(f, h, 2)
		dent.mtime = (readint(f, h, 2) << 16) | readint(f, h, 2)
		dent.namesize = readint(f, h, 2)
		dent.filesize = (readint(f, h, 2) << 16) | readint(f, h, 2)
		local name = read(f, h, dent.namesize):sub(1, dent.namesize-1)
		if (name == "TRAILER!!!") then break end
		--for k, v in pairs(dent) do
		--	print(k, v)
		--end
		dent.name = name
		if (dent.namesize % 2 ~= 0) then
			f.seek(h, "cur", 1)
		end
		if (dent.mode & 32768 ~= 0) then
			--fwrite()
		end
		dent.pos = f.seek(h, "cur", 0)
		f.seek(h, "cur", dent.filesize)
		if (dent.filesize % 2 ~= 0) then
			f.seek(h, "cur", 1)
		end
		tbl[#tbl+1] = dent
	end
	return setmetatable({
		tbl = tbl,
		fs = f,
		handle = h
	}, {__index=arc})
end

function arc:fetch(path)
	for i=1, #self.tbl do
		if (self.tbl[i].name == path and self.tbl[i].mode &32768 > 0) then
			self.fs.seek(self.handle, "set", self.tbl[i].pos)
			return self.fs.read(self.handle, self.tbl[i].filesize)
		end
	end
	return nil, "file not found"
end

function arc:close()
	self.fs.close(self.handle)
	self.tbl = {}
end

function arc:list_dir(path)
	--soon:tm:
end

return cpio
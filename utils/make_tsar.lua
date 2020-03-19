--Makes a TSAR file
local lfs = require("lfs")
local files = {}
for l in io.stdin:lines() do
	files[#files+1] = l
end
local attr = {}
local modes = {
	["fifo"] = 1,
	["char device"] = 2,
	["directory"] = 4,
	["block device"] = 6,
	["file"] = 8,
	["link"] = 0xA,
	["socket"] = 0xC
}
local function getperm()
	local md = 0
	for i=1, 9 do
		if (attr.permissions:sub(10-i,10-i) ~= "-") then
			md = md | (1 << (i-1))
		end
	end
	return md | (modes[attr.mode] << 12)
end
local size = 0
for i=1, #files do
	lfs.attributes(files[i], attr)
	local ent = {
		magic = 0x5f7d,
		namesize = #files[i],
		name = files[i],
		mode = getperm(),
		uid = attr.uid,
		gid = attr.gid,
		filesize = attr.size,
		mtime = attr.modification
	}
	if attr.mode ~= "file" then
		ent.filesize = 0
	end
	io.stdout:write(string.pack("=I2I2I2I2I2I6I6", ent.magic, ent.namesize, ent.mode, ent.uid, ent.gid, ent.filesize, ent.mtime))
	size = size+22
	io.stdout:write(ent.name)
	size = size + ent.namesize
	if ent.namesize & 1 > 0 then
		io.stdout:write("\0")
		size = size+1
	end
	if attr.mode == "file" then
		local h = io.open(files[i], "rb")
		io.stdout:write(h:read("*a"))
		h:close()
		size = size+ent.filesize
		if ent.filesize & 1 > 0 then
			io.stdout:write("\0")
			size = size+1
		end
	end
end
do
	local ent = {
		magic = 0x5f7d,
		namesize = 10,
		name = "TRAILER!!!",
		mode = 0,
		uid = 0,
		gid = 0,
		filesize = 0,
		mtime = 0
	}
	io.stdout:write(string.pack("=I2I2I2I2I2I6I6", ent.magic, ent.namesize, ent.mode, ent.uid, ent.gid, ent.filesize, ent.mtime))
	io.stdout:write(ent.name)
	size = size + 32
end
io.stderr:write((size//512).." blocks.\n")
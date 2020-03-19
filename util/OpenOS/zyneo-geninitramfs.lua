local fs = require("filesystem")
print("Regenerating Zorya NEO initramfs...")
fs.copy("/.zy2/boot.tsar", "/.zy2/boot.tsar.old")
local f = io.open("/.zy2/boot.tsar", "wb")
local lst = {}
for ent in fs.list("/etc/zorya-neo/initramfs.d") do
	if ent:sub(#ent) ~= "/" then
		lst[#lst+1] = ent
	end
end
table.sort(lst)
local modes = {
	["fifo"] = 1,
	["char device"] = 2,
	["directory"] = 4,
	["block device"] = 6,
	["file"] = 8,
	["link"] = 0xA,
	["socket"] = 0xC
}
local function getperm(perm, mode)
	local md = 0
	for i=1, 9 do
		if (perm:sub(10-i,10-i) ~= "-") then
			md = md | (1 << (i-1))
		end
	end
	return md | (modes[mode] << 12)
end
local function create_node(attr)
	local ent = {
		magic = 0x5f7d,
		namesize = #attr.name,
		name = attr.name,
		mode = getperm(attr.permissions, attr.mode),
		uid = attr.uid,
		gid = attr.gid,
		filesize = attr.filesize,
		mtime = attr.mtime
	}
	if attr.mode ~= "file" then
		ent.filesize = 0
	end
	f:write(string.pack("=I2I2I2I2I2I6I6", ent.magic, ent.namesize, ent.mode, ent.uid, ent.gid, ent.filesize, ent.mtime))
	f:write(attr.data or "")
end
local arc = {}
function arc.file(path, perm, data)
	create_node({
		data = data,
		filesize = #data,
		uid = 0,
		gid = 0,
		mtime = os.time(),
		name = path,
		permissions = perm or "rw-r--r--",
		mode = "file"
	})
end

function arc.dir(path, perm)
	create_node({
		uid = 0,
		filesize = 0,
		gid = 0,
		mtime = os.time(),
		name = path,
		permissions = perm or "rwxr-xr-x",
		mode = "directory"
	})
end

for i=1, #lst do
	print("> "..lst[i])
	loadfile("/etc/zorya-neo/initramfs.d/"..lst[i])(arc)
end
local zy_dat = [[{os="Zorya NEO", version={2,0,0}, generator="OpenOS"}]]
create_node({
	data = zy_dat,
	filesize = #zy_dat,
	uid = 0,
	gid = 0,
	mtime = os.time(),
	name = "TRAILER!!!",
	permissions = "---------",
	mode = "file"
})
f:close()
print("Generated new initramfs.")
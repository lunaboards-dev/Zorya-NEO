local inet = component.list("internet")()
if not inet then
	tty.setcolor(0x4)
	print("internet card not found.")
	return 1
end

inet = component.proxy(inet)

print("connecting...")
local hand, res = inet.request("https://git.shadowkat.net/sam/OC-PsychOS2/raw/branch/master/psychos.tsar")
if not hand then
	tty.setcolor(0x4)
	print(res)
	return 1
end
local fs = component.proxy(computer.tmpAddress())
_DRIVE = computer.tmpAddress()

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
	if m ~= magic and m ~= magic_rev then return nil, string.format("bad magic (%.4x)", m) end
	if m ~= magic then
		e = get_end(not en)
	end
	local ent = {}
	ent.magic, ent.namesize, ent.mode, ent.uid, ent.gid, ent.filesize, ent.mtime = string.unpack(e..header_fmt, dat)
	return ent
end

local spin = {"|", "/", "-", "\\"}

local spinv = 0

local function getspin()
	local c = spin[spinv + 1]
	spinv = (spinv + 1) & 3
	return c
end

tty.write("downloading psychos.tsar... "..getspin())
local x, y = tty.getcursor()
tty.setcursor(x-1, y)
local buf = ""
local lc = ""

while true do
	tty.setcursor(x-1, y)
	tty.write(getspin())
	lc, res = hand.read()
	if not lc and res then
		tty.setcolor(0x4)
		print(res)
		return 1
	end
	buf = buf .. (lc or "")
	if not lc then
		break
	elseif (lc == "") then
		computer.pullSignal(0)
	end
end
hand.close()

print("")
print(#buf)
print("unpacking... "..getspin())
x, y = tty.getcursor()
tty.setcursor(x-1, y)
local pos = 1
local function read(a)
	local dat = buf:sub(pos, pos+a-1)
	pos = pos + a
	return dat
end
local function seek(a)
	pos = pos + a
	return pos
end
while true do
	tty.setcursor(x-1, y)
	tty.write(getspin())
	local header = read_header(read(string.packsize(header_fmt)))
	local fn = read(header.namesize)
	seek(header.namesize & 1)
	if (fn == "TRAILER!!!") then break end
	if (header.mode & 32768 > 0) then
		local path = fn:match("^(.+)/.+%..+$")
		if path then fs.makeDirectory(path) end
		local h = fs.open(fn, "w")
		fs.write(h, read(header.filesize))
		fs.close(h)
		seek(header.filesize & 1)
	end
end
tty.setcolor(0x6)
print("run $boot to start the recovery enviroment")
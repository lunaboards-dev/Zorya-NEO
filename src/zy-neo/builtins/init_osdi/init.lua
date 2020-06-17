local bfs = {}

local cfg = cproxy(clist("eeprom")()).getData()

local baddr, part = cfg:sub(1, 36)
local bootfs = cproxy(baddr)

--find active partition
local bs, p, t, ss = bootfs.readSector(1), "I4I4c8I3c13", {}
for i=1, 15 do
	t = {sunpack(p, bs:sub((i*32)+1, (i+1)*32))}
	if (t[4] & 0x200 and t[4] & 0x40) then
		ss = t[1]
	end
end

local h = 1
local romfs_dev = tsar.read(function(a)
	local sz, c, st, p, d = math.ceil(a/512), "", (h//512), (h & 511)+1
	for i=1, sz do
		c = c .. bootfs.readSector(ss+i+st)
	end
	d = c:sub(p, p+a-1)
	h = h+a
	return d
end, function(a)
	h = h + a
	return h
end, function()
	
end)

function bfs.getfile(path)
	return romfs_dev:fetch(path)
end

function bfs.exists(path)
	return romfs_dev:exists(path)
end

function bfs.getstream(path)
	return romfs_dev:stream(path)
end

function bfs.getcfg()
	return romfs_dev:fetch(".zy2/cfg.lua")
end
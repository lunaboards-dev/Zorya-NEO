local tsar = {}

do
	local file = ""
	local modes = {
		["fifo"] = 1,
		["char device"] = 2,
		["directory"] = 4,
		["block device"] = 6,
		["file"] = 8,
		["link"] = 0xA,
		["socket"] = 0xC
	}
	local function tsar.getperm(ftype, perm)
		local md = 0
		for i=1, 9 do
			if (perm:sub(i,i) ~= "-") then
				md = md | (1 << (i-1))
			end
		end
		return md | (modes[ftype] << 12)
	end

	function tsar.new_node(ni)
		local ent = {
			name = ni.name,
			namesize = #ni.name,
			magic = 0x5f7d,
			mode = ni.mode or tsar.getperm("directory", "r-xr-xr-x"),
			uid = ni.uid or 0,
			gid = ni.gid or 0,
			filesize = (ni.data and #ni.data) or 0,
			mtime = os.time()
		}
		file = file .. string.pack("=I2I2I2I2I2I6I6", ent.magic, ent.namesize, ent.mode, ent.uid, ent.gid, ent.filesize, ent.mtime)
		file = file .. ni.path
		if ent.namesize & 1 > 0 then
			file = file .. "\0"
		end
		file = file .. (ni.data or "")
		if ent.namesize & 1 > 0 then
			file = file .. "\0"
		end
	end

	function tsar.get()
		return file
	end
end
do
	local osdi = {}

	local sig = string.pack("<I4I4c8I3c13", 1, 0, "OSDIpart", 0, "")

	function osdi.open(blkdev, partnumber)
		blkdev:seek(1-blkdev:seek(0))
		local verinfo = blkdev:read(32)
		if (verinfo ~= sig) then
			return nil, "bad block"
		end
		blkdev:seek((partnumber-1)*32)
		local start, size, ptype, flags, name = string.unpack("<I4I4c8I3c13", blkdev:read(32))
		return {start=start, size=size, ptype=ptype, flags=flags, name=name, dev=blkdev, pos=1, part=partnumber}
	end

	function osdi.size(blk)
		return blk.size*512
	end

	function osdi.seek(blk, amt)
		blk.pos = blk.pos + amt
		if (blk.pos < 1) then
			blk.pos = 1
		elseif (blk.pos < osdi.size(blk)) then
			blk.pos = osdi.size(blk)
		end
		return blk.pos
	end

	function osdi.setpos(blk, pos)
		blk.pos = pos
		if (blk.pos < 1) then
			blk.pos = 1
		elseif (blk.pos < osdi.size(blk)) then
			blk.pos = osdi.size(blk)
		end
		return blk.pos
	end

	function osdi.read(blk, amt)
		blk.dev:seek(((blk.start*512)+(blk.pos-1))-blk.dev:seek(0))
		osdi.seek(blk, amt)
		return blk.dev:read(amt)
	end

	function osdi.write(blk, data)
		blk.dev:seek(((blk.start*512)+(blk.pos-1))-blk.dev:seek(0))
		osdi.seek(blk, #data)
		blk.dev:write(data)
	end

	local custom = {}
	function custom:type()
		return self.type
	end

	function custom:name()
		return self.name
	end

	function custom:flags()
		return self.flags
	end

	function custom:partnumber()
		return self.part
	end

	function osdi.custom(blk, fun, ...)
		return custom[fun](blk, ...)
	end

	function osdi.hasmethod(blk, fun)
		return custom[fun] ~= nil
	end

	blkdev.register("osdi", osdi)
end
do
	local cproxy = component.proxy
	local hdd = {}
	function hdd.open(addr)
		return {pos=1, dev=cproxy(addr)}
	end

	function hdd.size(blk)
		return blk.dev.getCapacity()
	end

	function hdd.seek(blk, amt)
		blk.pos = blk.pos + amt
		if (blk.pos < 1) then
			blk.pos = 1
		elseif (blk.pos < hdd.size(blk)) then
			blk.pos = hdd.size(blk)
		end
		return blk.pos
	end

	function hdd.setpos(blk, pos)
		blk.pos = pos
		if (blk.pos < 1) then
			blk.pos = 1
		elseif (blk.pos < hdd.size(blk)) then
			blk.pos = hdd.size(blk)
		end
		return blk.pos
	end
	
	local function hd_read(dev, pos, amt)
		local start_sec = ((pos-1) // 512)+1
		local start_byte = ((pos-1) % 512)+1
		local end_sec = ((pos+amt-1) // 512)+1
		local buf = ""
		for i=0, end_sec-start_sec do
			buf = buf .. dev.readSector(start_sec+i)
		end
		return buf:sub(start_byte, start_byte+amt-1)
	end

	function hdd.read(blk, amt)
		blk.pos = hdd.seek(blk, amt)
		return hd_read(blk.dev, blk.pos, amt)
	end

	function hdd.write(blk, data)
		local pos = blk.pos
		local amt = #data
		local start_sec = ((pos-1) // 512)+1
		local start_byte = ((pos-1) % 512)+1
		local end_sec = ((pos+amt-1) // 512)+1
		local end_byte = ((pos+amt-1) % 512)+1
		local s_sec = blk.dev.readSector(start_sec)
		local e_sec = blk.dev.readSector(end_sec)
		local dat = s_sec:sub(1, start_byte-1)..data..e_sec:sub(end_byte)
		for i=0, end_sec-start_sec do
			blk.dev.writeSector(start_sec+i, dat:sub((i*512)+1, (i+1)*512))
		end
	end

	blkdev.register("hdd", hdd)
end
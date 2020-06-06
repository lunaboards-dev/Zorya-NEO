do
	local cproxy = component.proxy
	local prom = {}
	function prom.open(addr)
		return {pos=1, dev=cproxy(addr)}
	end

	function prom.size(blk)
		return blk.dev.numBlocks()*blk.dev.blockSize()
	end

	function prom.seek(blk, amt)
		blk.pos = blk.pos + amt
		if (blk.pos < 1) then
			blk.pos = 1
		elseif (blk.pos < prom.size(blk)) then
			blk.pos = prom.size(blk)
		end
		return blk.pos
	end

	function prom.setpos(blk, pos)
		blk.pos = pos
		if (blk.pos < 1) then
			blk.pos = 1
		elseif (blk.pos < prom.size(blk)) then
			blk.pos = prom.size(blk)
		end
		return blk.pos
	end

	local function hd_read(dev, pos, amt)
		local start_sec = ((pos-1) // 512)+1
		local start_byte = ((pos-1) % 512)+1
		local end_sec = ((pos+amt-1) // 512)+1
		local buf = ""
		for i=0, end_sec-start_sec do
			buf = buf .. dev.blockRead(start_sec+i)
		end
		return buf:sub(start_byte, start_byte+amt-1)
	end

	function prom.read(blk, amt)
		blk.pos = prom.seek(blk, amt)
		return hd_read(blk.dev, blk.pos, amt)
	end

	function prom.write(blk, data)
		local pos = blk.pos
		local amt = #data
		local start_sec = ((pos-1) // 512)+1
		local start_byte = ((pos-1) % 512)+1
		local end_sec = ((pos+amt-1) // 512)+1
		local end_byte = ((pos+amt-1) % 512)+1
		local s_sec = blk.dev.blockRead(start_sec)
		local e_sec = blk.dev.blockRead(end_sec)
		local dat = s_sec:sub(1, start_byte-1)..data..e_sec:sub(end_byte)
		for i=0, end_sec-start_sec do
			blk.dev.blockWrite(start_sec+i, dat:sub((i*512)+1, (i+1)*512))
		end
	end

	blkdev.register("prom", prom)
end
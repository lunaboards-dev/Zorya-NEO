-- Super basic TTY driver. Supports unicode if enabled with tty.utf.
tty = {}
do
	local gpu = component.proxy(component.list("gpu")())
	if not gpu.getScreen() then
		local saddr = component.list("screen")()
		gpu.bind(saddr)
	end
	local gfg = -1
	local gbg = -1

	local ttyc = 12
	local ttyx, ttyy = 1, 1

	local w, h = gpu.maxResolution()

	local depth = gpu.maxDepth()

	gpu.setResolution(w, h)
	gpu.setDepth(depth)

	if (depth == 4) then --pregen color
		for i=0, 15 do
			local hi = i >> 3
			local r = (i >> 2) & 1
			local g = (i >> 1) & 1
			local b = i & 1
			local fr = (r * 0x7F) | (hi << 7)
			local fg = (g * 0x7F) | (hi << 7)
			local fb = (b * 0x7F) | (hi << 7)
			gpu.setPaletteColor(i, (fr << 16) | (fg << 8) | fb)
		end
	end

	function colors(i)
		if (i < 0) then i = 0 elseif (i > 15) then i = 15 end
		if (depth == 1) then
			return ((i > 0) and 0xFFFFFF) or 0
		elseif (depth == 4) then
			return i, true
		else -- e x p a n d
			local hi = i >> 3
			local r = (i >> 2) & 1
			local g = (i >> 1) & 1
			local b = i & 1
			local fr = (r * 0x7F) | (hi << 7)
			local fg = (g * 0x7F) | (hi << 7)
			local fb = (b * 0x7F) | (hi << 7)
			return (fr << 16) | (fg << 8) | fb
		end
	end

	local buffer = string.char(0xF, 32):rep(w*h)

	local cwidth = 1

	local function get_segments(spos, max)
		spos = spos or 1
		if spos < 1 then spos = 1 end
		max = max or #buffer//(1+cwidth)
		local cur_color = -1
		local segments = {}
		local _buffer = ""
		local cpos = spos-1 --((spos-1)*(1+cwidth))
		local start_pos = cpos
		for i=((spos-1)*(1+cwidth))+1, max*(1+cwidth), 1+cwidth do
			local c, code = string.unpack("BI"..cwidth, buffer:sub(i, i+cwidth)) -- buffer:sub(i,i), buffer:sub(i+1, i+cwidth)
			if (c ~= cur_color or cpos%w == 0) then
				if (buffer ~= "") then
					segments[#segments+1] = {(start_pos//w)+1, (start_pos%w)+1, cur_color, _buffer}
				end
				cur_color = c
				start_pos = cpos
				_buffer = ""
			end
			cpos = cpos + 1
			_buffer = _buffer .. utf8.char(code)
		end
		if (buffer ~= "") then
			segments[#segments+1] = {((start_pos)//w)+1, ((start_pos)%w)+1, cur_color, _buffer}
		end
		return segments
	end

	local function draw_segments(segs)
		for i=1, #segs do
			local fg, bg = segs[i][3] & 0xF, segs[i][3] >> 4
			if (fg ~= gfg) then
				gpu.setForeground(colors(fg))
			end
			if (bg ~= gbg) then
				gpu.setBackground(colors(bg))
			end
			gpu.set(segs[i][2], segs[i][1], segs[i][4])
		end
	end

	function tty.setcolor(c)
		ttyc = c
	end

	function tty.utf() -- Cannot be undone cleanly!
		if cwidth == 3 then return end
		local newbuf = ""
		for i=1, #buffer, 2 do
			local a, b = string.unpack("BB", buffer:sub(i, i+1))
			newbuf = newbuf .. string.pack("BI3", a, b)
		end
		buffer = newbuf
		cwidth = 3
	end

	function tty.moveup()
		gpu.copy(1, 2, w, h-1, 0, -1)
		buffer = buffer:sub((w*(1+cwidth))+1)..(string.rep(string.pack("BI"..cwidth, 0xF, 32), w))
		gpu.fill(1, h, w, 1, " ")
	end

	function tty.clear()
		x = 1
		y = 1
		buffer = string.rep("\x0F"..string.pack("I"..cwidth, 32), w*h)
	end

	function tty.setcursor(x, y)
		ttyx = x or 1
		ttyy = y or 1
	end

	function tty.getcursor()
		return ttyx, ttyy
	end

	function tty.write(s)
		-- Convert to color/codepoint
		local charmask = string.unpack("I"..cwidth, string.rep("\xFF", cwidth))
		local _buffer = ""
		for i=1, utf8.len(s) do
			_buffer = _buffer .. string.pack("BI"..cwidth, ttyc, utf8.codepoint(s, i) & charmask)
		end
		local bpos = (((ttyx-1)+((ttyy-1)*w))*(1+cwidth))+1
		local b1, b2 = buffer:sub(1, bpos-1), buffer:sub(bpos+#_buffer)
		buffer = b1 .. _buffer .. b2
		local mod = 0
		if (#buffer > w*h*(1+cwidth)) then
			-- Scroll smoothly
			buffer = buffer .. string.rep("\x0F"..string.pack("I"..cwidth, 32), w-((#buffer/(1+cwidth)) % w))
			buffer = buffer:sub(#buffer-(w*h*(1+cwidth))+1)
			tty.update()
			mod = -w
		else
			-- Update what changed here.
			draw_segments(get_segments((ttyx-1)+((ttyy-1)*w)+1, ((ttyx-1)+((ttyy-1)*w))+utf8.len(s)))
		end
		local pz = (((ttyx-1)+((ttyy-1)*w)) + utf8.len(s)) + mod
		ttyx = (pz % w)+1
		ttyy = (pz // w)+1
	end

	function tty.print(...)
		local args = {...}
		for i=1, #args do
			args[i] = tostring(args[i])
		end
		local str = table.concat(args, "   ").."\n" -- ugly hack
		for m in str:gmatch("(.-)\n") do
			tty.write(m)
			local x, y = tty.getcursor()
			if (x ~= 1) then
				ttyy = y + 1
				ttyx = 1
				if (ttyy > h) then
					tty.moveup()
					ttyy = h
				end
			end
		end
	end

	function tty.update()
		draw_segments(get_segments())
	end
end
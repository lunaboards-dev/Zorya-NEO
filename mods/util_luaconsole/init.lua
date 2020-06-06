local utils = krequire("utils")
--#include "tty.lua"
--#include "velx.lua"
--#include "load.lua"

function _runcmd(cmd)
	local rcmd = cmd:sub(1, (cmd:find(" ") or (#cmd+1))-1)
	local script = _ARCHIVE:fetch("bin/"..rcmd..".lua")
	load(script, "=bin/"..rcmd..".lua", "t", _G)(cmd:sub(#rcmd+1):gsub("^%s+", ""))
end

return function(autorun)
	local keys = {
		lcontrol        = 0x1D,
		back            = 0x0E, -- backspace
		delete          = 0xD3,
		down            = 0xD0,
		enter           = 0x1C,
		home            = 0xC7,
		left            = 0xCB,
		lshift          = 0x2A,
		pageDown        = 0xD1,
		rcontrol        = 0x9D,
		right           = 0xCD,
		rmenu           = 0xB8, -- right Alt
		rshift          = 0x36,
		space           = 0x39,
		tab             = 0x0F,
		up              = 0xC8,
		["end"]         = 0xCF,
		tab             = 0x0F,
		numpadenter     = 0x9C,
	}
	tty.clear()
	tty.utf()
	tty.setcursor(1, 1)
	tty.update()
	tty.setcolor(0xF)
	tty.print("Zorya NEO Lua Terminal")
	tty.print("Zorya NEO ".._ZVSTR.." ".._ZGIT)
	local buffer = ""
	function print(...)
		tty.print(...)
	end
	function exit()
		exit = nil
		print = nil
	end
	if (autorun) then
		local c = load(autorun)
		if c then
			pcall(c)
		end
	end
	tty.print("")
	tty.setcolor(2)
	tty.write("boot> ")
	tty.setcolor(0xF0)
	tty.write(" ")
	tty.setcolor(0xF)
	while exit do
		local sig = {computer.pullSignal()}
		if (sig[1] == "key_down") then
			if (sig[3] > 31 and sig[3] ~= 127) then
				local x, y = tty.getcursor()
				tty.setcursor(x-1, y)
				tty.setcolor(0xF)
				tty.write(utf8.char(sig[3]))
				tty.setcolor(0xF0)
				tty.write(" ")
				buffer = buffer .. utf8.char(sig[3])
			elseif (sig[4] == keys.back) then
				if (#buffer > 0) then
					local x, y = tty.getcursor()
					tty.setcursor(x-2, y)
					tty.setcolor(0xF0)
					tty.write(" ")
					tty.setcolor(0xF)
					tty.write(" ")
					tty.setcursor(x-1, y)
					buffer = buffer:sub(1, #buffer-1)
				end
			elseif (sig[4] == keys.enter) then
				if (buffer:sub(1,1) == "=") then
					buffer = "return "..buffer:sub(2)
				elseif (buffer:sub(1,1) == "$") then
					buffer = "return _runcmd(\""..buffer:sub(2).."\")"
				end
				local s, e = load(buffer)
				local x, y = tty.getcursor()
				tty.setcursor(x-1, y)
				tty.setcolor(0xF)
				tty.write(" ")
				tty.print(" ")
				buffer = ""
				if not s then
					tty.setcolor(0x4)
					tty.print(e)
					tty.setcolor(0xf)
				else
					tty.setcolor(0xf)
					xpcall(function()
						tty.print(s())
					end, function(e)
						tty.setcolor(0x4)
						tty.print(debug.traceback(e):gsub("\t", "  "):gsub("\r", "\n"))
					end)
				end
				tty.setcolor(2)
				tty.write(((_DRIVE and _DRIVE:sub(1, 4)) or "boot").."> ")
				tty.setcolor(0xF0)
				tty.write(" ")
				tty.setcolor(0xF)
			end
		end
	end
end
--#include "src/lzss.lua"
local c = component
local gpu = c.proxy(c.list("gpu")())
local screen = c.list("screen")()
gpu.bind(screen)
local w, h = gpu.getResolution()
gpu.setResolution(w, h)
gpu.setBackground(0)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")
cls = function()gpu.fill(1,1,w,h," ")end
local y = 1
function status(msg)
	if gpu and screen then
		gpu.set(1, y, msg)
		if y == h then
			gpu.copy(1, 2, w, h-1, 0, -1)
			gpu.fill(1, h, w, 1, " ")
		else
			y = y + 1
		end
	end
end
status("Decompressing image...")
return load(lzss_decompress($[[luacomp src/zy-neo/zinit.lua -mluamin 2>/dev/null | sed "s/\]\]/]\ ]/g" | lua5.3 src/lzssc.lua | lua utils/mkluastring.lua ]]), "=bios.lua")(lzss_decompress)
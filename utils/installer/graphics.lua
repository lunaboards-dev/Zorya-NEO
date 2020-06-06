local characters = {
	"╔", "╗", "═", "║", "╚", "╝"
}

local proxy, list = component.proxy, component.list
local gpu = proxy(list("gpu")())
if (not gpu.getScreen()) then
	gpu.bind(list("screen")())
end
local usepal
if (gpu.getDepth() > 1) then
	usepal = true
	gpu.setPaletteColor(0, 0x000000)
	gpu.setPaletteColor(1, 0xFFFFFF)
	gpu.setPaletteColor(2, 0x4444FF)
	gpu.setPaletteColor(3, 0xFF7F44)
	gpu.setPaletteColor(4, 0x00007F)
	gpu.setPaletteColor(5, 0x7F00FF)
	gpu.setPaletteColor(6, 0x595959)
end
local function gc(c)
	if usepal then
		return c, true
	end
	return (c == 1) and 1 or 0
end

function gfx.drawtitle()

end
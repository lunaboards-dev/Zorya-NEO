local border_chars = {
	"┌", "─", "┐", "│", "└", "┘"
}
local menu = {}

local entries = {}

local gpu = component.proxy(component.list("gpu")())
local screen = component.list("screen")()
gpu.bind(screen) --fuck off ocemu

local bg, fg = 0, 0xFFFFFF
local timeout = 5

function menu.setfgcolor(color)
	fg = color
end

function menu.setbgcolor(color)
	bg = color
end

function menu.settimeout(to)
	timeout = to
end

function menu.add(text, func)
	entries[#entries+1] = {text, func}
end

function menu.draw()
	local w, h = gpu.getViewport()
	local cls = function()gpu.fill(1,1,w,h," ")end
	gpu.setBackground(bg)
	gpu.setForeground(fg)
	cls()
	--Draw some things
	local namestr = _BIOS .. " " .. string.format("%.1f.%d %s", _ZVER, _ZPAT, _ZGIT)
	gpu.set((w/2)-(#namestr/2), 1, namestr)
	gpu.set(1, 2, border_chars[1])
	gpu.set(2, 2, border_chars[2]:rep(w-2))
	gpu.set(w, 2, border_chars[3])
	for i=1, h-6 do
		gpu.set(1, i+2, border_chars[4])
		gpu.set(w, i+2, border_chars[4])
	end
	gpu.set(1, h-3, border_chars[5])
	gpu.set(2, h-3, border_chars[2]:rep(w-2))
	gpu.set(w, h-3, border_chars[6])
	gpu.set(1, h-1, "Use ↑ and ↓ keys to select which entry is highlighted.")
	gpu.set(1, h, "Use ENTER to boot the selected entry.")
	local stime = computer.uptime()
	local autosel = true
	local ypos = 1
	local sel = 1
	local function redraw()
		gpu.setBackground(bg)
		gpu.setForeground(fg)
		gpu.fill(1, h-2, w, 1, " ")
		if (autosel) then
			gpu.set(1, h-2, "Automatically booting in "..math.floor(timeout-(computer.uptime()-stime)).."s.")
		end
		for i=1, h-6 do
			local entry = entries[ypos+i-1]
			if not entry then break end
			local name = entry[1]
			if not name then break end
			local short = name:sub(1, w-2)
			if (short ~= name) then
				short = short:sub(1, #sub-3).."..."
			end
			if (#short < w-2) then
				short = short .. string.rep(" ", w-2-#short)
			end
			if (sel == ypos+i-1) then
				gpu.setBackground(fg)
				gpu.setForeground(bg)
			else
				gpu.setBackground(bg)
				gpu.setForeground(fg)
			end
			gpu.set(2, i+2, short)
		end
	end
	redraw()
	sel = 1
	while true do
		local sig, _, key, code = computer.pullSignal(0.01)
		if (sig == "key_down") then
			autosel = false
			if (key == 0 and code == 200) then
				sel = sel - 1
				if (sel < 1) then
					sel = 1
				end
				if (sel < ypos) then
					ypos = ypos - 1
				end
			elseif (key == 0 and code == 208) then
				sel = sel + 1
				if (sel > #entries) then
					sel = #entries
				end
				if (sel > ypos+h-7) then
					ypos = ypos+1
				end
			elseif (key == 13 and code == 28) then
				gpu.setBackground(0)
				gpu.setForeground(0xFFFFFF)
				entries[sel][2]()
			end
		end
		if (((computer.uptime()-stime) >= timeout) and autosel) then
			entries[sel][2]()
		end
		redraw()
	end
end

return menu
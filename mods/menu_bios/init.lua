local computer = computer or require("computer")
local component = component or require("component")

local menu = {}

local gpu = component.proxy(component.list("gpu")())
--gpu.bind((component.list("screen")()))

gpu.set(1, 1, _BIOS.." ".._ZVSTR.." BIOS/Bootloader")
gpu.set(1, 2, "(c) 2020 Adorable-Catgirl")
gpu.set(1, 3, "Git Revsion: ".._ZGIT)
gpu.set(1, 5, "Memory: "..math.floor(computer.totalMemory()/1024).."K")
--gpu.set(1, 5)

local logo = {
"       ⣾⣷       ",
"      ⢠⡟⢻⡄      ",
"     ⢀⡾⢡⡌⢷⡀     ",
"⣠⣤⣤⠶⠞⣋⣴⣿⣿⣦⣙⠳⠶⣤⣤⣄",
"⠙⠛⠛⠶⢦⣍⠻⣿⣿⠟⣩⡴⠶⠛⠛⠋",
"     ⠈⢷⡘⢃⡾⠁     ",
"      ⠘⣧⣼⠃      ",
"       ⢿⡿       "
}

local w, h = gpu.getViewport()
gpu.setForeground(0x770077)
for i=1, #logo do
	gpu.set(w-18, 1+i, logo[i])
end
gpu.setForeground(0xFFFFFF)

gpu.set(1, h, "F1 for setup; F2 for boot options.")

local y = 0
local my = h-9
function status(msg)
	msg = msg:sub(1, w-18)
	y = y + 1
	if y > my then
		gpu.copy(2, 9, w, h-10, 0, -1)
		y = my
	end
	gpu.set(1, y+8, msg)
end

for c, t in component.list("") do
	status("Found "..t..": "..c)
end

local et = computer.uptime()+5
while et>=computer.uptime() do
	computer.pullSignal(et-computer.uptime())
end
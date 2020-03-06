local args = {...}
local tbl = args[1]
local dat = args[2]
table.remove(args, 1)
table.remove(args, 1)

local comp = component or require("component")
local computer = computer or require("computer")

function getfile(path)
	for i=1, #tbl do
		if (tbl[i].name == path) then
			return dat:sub(tbl[i].pos, tbl[i].pos+tbl[i].filesize-1)
		end
	end
end

--[[local baddr = computer.getBootAddress()
local c = comp.proxy(baddr)
print("Making directories...")
c.makeDirectory(".zy2")
c.makeDirectory(".zy2/mods")
c.makeDirectory(".zy2/lib")
print("Copying files...")
for i=1, #tbl do
	if (tbl[i].name:sub(1, 13) ~= "installer_dat" and tbl[i].name:sub(1, 4) ~= "bios" and tbl[i].mode & 32768 ~= 0) then
		local h = c.open(".zy2/"..tbl[i].name, "w")
		c.write(h, getfile(tbl[i].name))
		c.close(h)
	end
end
computer.pullSignal(0)
print("Flashing BIOS...")
local eeprom = comp.proxy(comp.list("eeprom")())
eeprom.set(getfile("bios/managed.bios"))
eeprom.setData(baddr)]]

--pastebin installer: HW3rz1gt
local characters = {
	"╔", "╗", "═", "║", "╚", "╝"
}
local computer = computer or require("computer")
local fsaddr = args[1] or computer.getBootAddress()
--print(fsaddr)
local component = component or require("component")
local proxy, list = component.proxy, component.list
local gpu = proxy(list("gpu")())
if (not gpu.getScreen()) then
	gpu.bind(list("screen")())
end
--Load palette
gpu.setPaletteColor(0, 0x000000)
gpu.setPaletteColor(1, 0xFFFFFF)
gpu.setPaletteColor(2, 0x4444FF)
gpu.setPaletteColor(3, 0xFF7F44)
gpu.setPaletteColor(4, 0x00007F)
gpu.setPaletteColor(5, 0x7F00FF)
gpu.setPaletteColor(6, 0x595959)
gpu.setBackground(0, true)
local w, h = gpu.getViewport()
gpu.fill(1, 2, w, h-1, " ")
gpu.setBackground(5, true)
gpu.fill(1, 1, w, 1, " ")
local title = "Zorya NEO Installer v2.0"
local spos = (w/2)-(#title/2)
gpu.setForeground(1, true)
gpu.set(spos, 1, title)
gpu.setForeground(1, true)
gpu.setBackground(5, true)
gpu.fill(6,6,w-12,h-12, " ")
gpu.set(6,6,characters[1])
gpu.set(w-6,6,characters[2])
gpu.set(6,h-6,characters[5])
gpu.set(w-6,h-6,characters[6])
gpu.fill(7,6,w-13,1,characters[3])
gpu.fill(7,h-6,w-13,1,characters[3])
gpu.fill(6,7,1,h-13,characters[4])
gpu.fill(w-6,7,1,h-13,characters[4])
function setStatus(stat)
	gpu.setBackground(5, true)
	gpu.setForeground(1, true)
	gpu.fill(7,(h/2)-3, w-13, 1, " ")
	gpu.set((w/2)-(#stat/2), (h/2)-3, stat)
end
function setBar(pos)
	gpu.setBackground(6, true)
	gpu.fill(8, (h/2)+1, w-16, 1, " ")
	gpu.setBackground(2, true)
	gpu.fill(8, (h/2)+1, ((w-16)/100)*pos, 1, " ")
	computer.pullSignal(0)
end

function mkdir(fs, path)
	fs.makeDirectory(path)
end


setStatus("Setting up directories...")
setBar(100)
local fs = proxy(fsaddr)
fs.makeDirectory(".zy2")
fs.makeDirectory(".zy2/mods")
fs.makeDirectory(".zy2/lib")

local romfs = fs.open(".zy2/image.romfs", "w")
fs.write(romfs, "romfs\1\0")

function writeFile(path, data)
	--local hand = fs.open(path, "w")
	--fs.write(hand, data)
	--fs.close(hand)
	fs.write(romfs, string.char(#path)..path)
	local ext = path:sub(#path-2)
	if (ext == "lua" or ext == "z2l" or ext == "z2y") then
		fs.write(romfs, "x")
	else
		fs.write(romfs, "-")
	end
	fs.write(romfs, string.pack("<i2", #data))
	fs.write(romfs, data)
end

setStatus("Getting file list...")
setBar(0)
local bios_files = load("return "..getfile("installer_dat/bios_list.lua"))()
setBar(33)
local pkg_files = load("return "..getfile("installer_dat/package_list.lua"))()
setBar(67)
local lang = load("return "..getfile("installer_dat/lang/en_US.lua"))()
setBar(100)

setStatus("Extracting files...")
setBar(0)
for i=1, #pkg_files do
	setStatus("Extracting "..(lang["mod_"..pkg_files[i].cat.."_"..pkg_files[i].name.."_name"] or "#mod_"..pkg_files[i].cat.."_"..pkg_files[i].name.."_name").."... ("..i.." of "..#pkg_files..")")
	setBar(100*(i/#pkg_files))
	writeFile(".zy2/"..pkg_files[i].path, getfile(pkg_files[i].path))
end

writeFile("TRAILER!!!", [[{os="Zorya NEO",version="2.0"}]])

setStatus("Extracting EEPROM...")
setBar(0)
local bios = getfile(bios_files[1].path)

setStatus("Flashing EEPROM...")
setBar(33)
local eeprom = proxy(list("eeprom")())
eeprom.set(bios)
setStatus("Writing configuration data...")
setBar(66)
function hexid_to_binid(addr)
  addr=addr:gsub("%-", "")
  local baddr = ""
  for i=1, #addr, 2 do
    baddr = baddr .. string.char(tonumber(addr:sub(i, i+1), 16))
  end
  return baddr
end
eeprom.setData(fs.address)
eeprom.setLabel("Zorya NEO BIOS v2.0")
setBar(100)
setStatus("Rebooting in 5 seconds...")
if not fs.exists(".zy2/cfg.lua") then
	writeFile(fs, ".zy2/cfg.lua", string.format([[local menu = loadmod("menu_classic")
menu.add("OpenOS on %s", function()
	return loadmod("loader_openos")("%s")
end)
menu.draw()]], fsaddr:sub(1, 3), fsaddr))
end
computer = computer or require("computer")
local stime = computer.uptime()
while true do
	setStatus("Rebooting in "..math.ceil(5-(computer.uptime()-stime)).." seconds...")
	if (computer.uptime()-stime > 5) then
		computer.shutdown(true)
	end
	computer.pullSignal(0.01)
	setBar((computer.uptime()-stime)*20)
end

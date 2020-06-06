local function make_platform(plat)
	os.execute("mkdir -p pkg/bios")
	print("Making "..plat..".bios")
	os.execute("luacomp src/loader.lua -O pkg/bios/"..plat..".bios")
	--os.execute("ZY_PLATFORM="..plat.." luacomp src/loader.lua -O pkg/bios/"..plat..".bios")
	print("ZY_PLATFORM="..plat.."luacomp src/loader.lua -O pkg/bios/"..plat..".bios")
	print("[[ $".."(stat --printf=%s pkg/bios/"..plat..".bios) > 4096 ]]")
	if (os.execute("[[ $".."(stat --printf=%s pkg/bios/"..plat..".bios) > 4096 ]]")) then
		io.stderr:write("WARNING: "..plat.." bios is over 4KiB!\n")
	end
end

local function mkplat(plat)
	local h = io.popen("luacomp src/loader.lua")
	local loader = h:read("*a")
	h:close()
	local h = io.popen("ZY_PLATFORM="..plat.." luacomp src/zy-neo/zinit.lua -mluamin | lua5.3 utils/makezbios.lua")
	local dat = h:read("*a")
	h:close()
	os.execute("mkdir -p pkg/bios")
	local h = io.open("pkg/bios/"..plat..".bios", "wb")
	h:write(string.format(loader, dat))
	h:close()
	if (os.execute("[[ $".."(stat --printf=%s pkg/bios/"..plat..".bios) > 4096 ]]")) then
		io.stderr:write("WARNING: "..plat.." bios is over 4KiB!\n")
	end
end

function actions.managed_bios()
	mkplat("managed")
end

function actions.initramfs_bios()
	mkplat("initramfs")
end

function actions.prom_bios()
	mkplat("prom")
end

function actions.osdi_bios()
	mkplat("osdi")
end

actions[#actions+1] = "managed_bios"
actions[#actions+1] = "initramfs_bios"
actions[#actions+1] = "prom_bios"
actions[#actions+1] = "osdi_bios"
local function mkplat(plat)
	local h = io.popen("luacomp src/loader.lua".." 2>/dev/null")
	local loader = h:read("*a")
	h:close()
	local h = io.popen("ZY_PLATFORM="..plat.." luacomp src/zy-neo/neoinit.lua 2>/dev/null | lua5.3 utils/makezbios.lua")
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

--[[function actions.managed_bios()
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

function actions.bootstrap()
	--os.execute("luacomp src/zy-neo/zinit.lua | lua5.3 utils/makezbios.lua > pkg/bios/bootstrap.bin")
	local h = io.popen("luacomp src/zy-neo/zinit.lua")
	local dat = h:read("*a")
	h:close()
	local h = io.open("pkg/bios/bootstrap.bin", "wb")
	h:write(lzss.compress(dat))
	h:close()
end

function actions.bios()
	actions.managed_bios()
	actions.initramfs_bios()
	actions.prom_bios()
	actions.osdi_bios()
	actions.bootstrap()
end]]

local blist = {}

local function addbios(name)
	blist[#blist+1] = name..".bios"
	task(name..".bios", function()
		status("build", name)
		mkplat(name)
	end)
end

addbios("managed")
addbios("initramfs")
addbios("prom")
addbios("osdi")

task("bootstrap.bin", function()
	local h = io.popen("luacomp src/zy-neo/zinit.lua".." 2>/dev/null")
	local dat = h:read("*a")
	h:close()
	local h = io.open("pkg/bios/bootstrap.bin", "wb")
	h:write(EXPORT.lzss.compress(dat))
	h:close()
end)

task("bios", function()
	for i=1, #blist do
		dep(blist[i])
	end
	dep("bootstrap.bin")
end)

--[[actions[#actions+1] = "managed_bios"
actions[#actions+1] = "initramfs_bios"
actions[#actions+1] = "prom_bios"
actions[#actions+1] = "osdi_bios"
actions[#actions+1] = "bootstrap"]]
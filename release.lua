--Makes a release CPIO
local start = os.time()
function status(s)
	io.stderr:write(s.."\n")
end
status("Cleaning last build...")
os.execute("rm -rf pkg")
os.execute("rm -rf release")

status("Making directories...")
os.execute("mkdir -p pkg/mods")
os.execute("mkdir -p pkg/lib")
os.execute("mkdir -p pkg/bios")
os.execute("mkdir -p release")

status("Building EEPROM...")
os.execute("luacomp src/loader.lua -O pkg/bios/managed.bios")
os.execute("luacomp src/zy-neo/zinit.lua -O debug.lua")
if (os.execute("[[ $(stat --printf=%s pkg/bios/managed.bios) > 4096 ]]")) then
	io.stderr:write("WARNING: BIOS is over 4KiB!\n")
end

status("\n\nBuilding modules.")
if (os.execute("stat mods 1>/dev/null 2>&1")) then
	for l in io.popen("ls mods"):lines() do
		status("MOD\t"..l)
		os.execute("sh -c 'cd mods/"..l.."; luacomp -mluamin init.lua | lua ../../utils/zlua.lua > ../../pkg/mods/"..l..".zy2m'")
	end
end
status("Module build complete.\n\nBuilding libraries.")
if (os.execute("stat lib 1>/dev/null 2>&1")) then
	for l in io.popen("ls lib"):lines() do
		status("LIB\t"..l)
		os.execute("sh -c 'cd lib/"..l.."; luacomp -mluamin init.lua | lua ../../utils/zlua.lua > ../../pkg/lib/"..l..".zy2l'")
	end
end
status("Library build complete.\n\nBuilding installer...")
os.execute("cp utils/ser.lua pkg/init.lua")
os.execute("cp -r installer_dat pkg")
status("Packing installer...")
os.execute("cd pkg; find * -depth | lua ../utils/make_tsar.lua | lua ../utils/mkselfextract.lua > ../release/zorya-neo-installer.lua")
status("Making OpenOS util installer...")
os.execute("cd util; find * -depth | lua ../utils/make_tsar.lua | lua ../utils/mkselfextract.lua > ../release/zorya-neo-utils-installer.lua")
print("Making update tsar...")
os.execute("cd pkg; find bios lib mods -depth | lua ../utils/make_tsar.lua > ../release/zorya-neo-update.tsar")
status("Build complete.")
status(string.format("Took %ds.", os.time()-start))
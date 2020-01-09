--Makes a release CPIO
os.execute("rm -rf pkg")
os.execute("mkdir -p pkg/mods")
os.execute("mkdir -p pkg/lib")
os.execute("mkdir -p pkg/bios")
os.execute("luacomp src/loader.lua -O pkg/bios/managed.bios")
if (os.execute("stat mods 1>/dev/null 2>&1")) then
	for l in io.popen("ls mods"):lines() do
		os.execute("zsh -c 'cd mods/"..l.."; luacomp init.lua | lua ../../utils/zlua.lua > ../../pkg/mods/"..l..".zy2m'")
	end
end
if (os.execute("stat lib 1>/dev/null 2>&1")) then
	for l in io.popen("ls lib"):lines() do
		os.execute("zsh -c 'cd lib/"..l.."; luacomp init.lua -mluamin | lua ../../utils/zlua.lua > ../../pkg/lib/"..l..".zy2l'")
	end
end
os.execute("cp utils/ser.lua pkg/init.lua")
os.execute("cp -r installer_dat pkg")
os.execute("cd pkg; find * -depth | cpio -o | lua ../utils/mkselfextract.lua > ../zorya-neo-installer.lua")
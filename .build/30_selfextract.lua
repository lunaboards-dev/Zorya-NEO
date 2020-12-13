local function makeselfextract(indir, outfile)
	local cwd = os.getenv("PWD")
	os.execute("cd "..indir.."; find * -depth | lua "..cwd.."/utils/make_tsar.lua | lua "..cwd.."/utils/mkselfextract.lua > "..cwd.."/"..outfile)
end

task("installer", function()
	os.execute("cp utils/ser.lua pkg/init.lua")
	os.execute("mkdir -p pkg/installer_dat")
	os.execute("cp installer_dat/bios_list.lua pkg/installer_dat")
	os.execute("cp installer_dat/package_list.lua pkg/installer_dat")
	os.execute("mkdir -p pkg/installer_dat/lang")
	local h = io.popen("ls installer_dat/lang | grep lua", "r")
	for line in h:lines() do
		os.execute("luacomp installer_dat/lang/"..line.." -O pkg/installer_dat/lang/"..line.." 2>/dev/null")
	end
	h:close()
	makeselfextract("pkg", "release/zorya-neo-installer.lua")
end)

task("utils", function()
	makeselfextract("util", "release/zorya-neo-utils-installer.lua")
end)
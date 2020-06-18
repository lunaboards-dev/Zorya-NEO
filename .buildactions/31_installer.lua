function actions.installer()
	os.execute("cp utils/ser.lua pkg/init.lua")
	os.execute("mkdir -p pkg/installer_dat")
	os.execute("cp installer_dat/bios_list.lua pkg/installer_dat")
	os.execute("cp installer_dat/package_list.lua pkg/installer_dat")
	os.execute("mkdir -p pkg/installer_dat/lang")
	local h = io.popen("ls installer_dat/lang | grep lua", "r")
	for line in h:lines() do
		os.execute("luacomp installer_dat/lang/"..line.." -O pkg/installer_dat/lang/"..line)
	end
	h:close()
	makeselfextract("pkg", "release/zorya-neo-installer.lua")
end

actions[#actions+1] = "installer"
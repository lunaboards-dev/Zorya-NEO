function actions.installer()
	os.execute("cp utils/ser.lua pkg/init.lua")
	os.execute("cp -r installer_dat pkg")
	makeselfextract("pkg", "release/zorya-neo-installer.lua")
end

actions[#actions+1] = "installer"
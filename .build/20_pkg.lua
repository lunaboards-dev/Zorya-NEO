task("makepkg", function()
	os.execute("cd pkg; find bios lib mods -depth | lua ../utils/make_tsar.lua > ../release/zorya-neo-update.tsar")
end)
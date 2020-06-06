function menu.bios()
	local biossel = menu.create()
	biossel:add(menu.text(lang.getstring("menu_bios_select")))
	local bios = menu.select {
		{text = lang.getstring("bios_type_managed"), value = "managed"},
		{text = lang.getstring("bios_type_initramfs"), value = "initramfs"},
		{text = lang.getstring("bios_type_prom"), value = "prom"},
		{text = lang.getstring("bios_type_osdi"), value = "osdi"},
	}
	bios:select(function(v)
		biossel:destroy()
		menu["bios_"..v]()
	end)
	biossel:add(bios)
	biossel:draw()
end
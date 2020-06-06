function menu.langsetup()
	local langselect = menu.create()
	menu:add(menu.text("Language"))
	local langs = menu.select {
		{text = "English (US)", value = "en_US"}
	}
	langs:select(function(v)
		langselect:destroy()
		lang.load(v)
		menu.bios()
	end)
	menu:add(langs)
	menu:draw()
end
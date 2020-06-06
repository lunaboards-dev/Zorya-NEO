function menu.bios_osdi()
	-- Find OSDI formatted disks.
	local osdi = menu.create()
	local drives = {}
	local dselv = {}
	for d in list("drive") do
		local drive = proxy(d)
		local t = drive.readSector(1)
		local fmt = (t:sub(1, 4) == "OSDI")
		drives[#drives+1] = {dev=drive, addr=d, format=fmt}
		dselv[#dselv+1] = {text=string.format("%s (%s)", d:sub(1,6), lang.getstring((fmt and "osdi_formatted") or "osdi_unformatted")), value=drives[#drives]}
	end
	local disksel = menu.select(dselv)
	disksel:select(function(v)
		if not v.format then
			
	end)
	osdi:add(disksel)
	osdi:destroy()
end

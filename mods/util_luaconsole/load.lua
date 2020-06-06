function load_exec(path)
	if not _DRIVE then
		tty.setcolor(0x4)
		print("need to set root")
	end
	local env = utils.make_env()
	function env.computer.getBootAddress()
		return _DRIVE
	end
	function env.computer.setBootAddress()end
	local ext = path:match("%.(.+)$")
	if (ext == "lua") then
		return load(krequire("utils").readfile(_DRIVE, component.invoke(_DRIVE, "open", path)), "="..path, "t", env)
	elseif (ext == "velx") then
		local fs = component.proxy(_DRIVE)
		local h = fs.open(path)
		local v, e = load_velx(function(a)
			local c = ""
			local d
			while a > 0 do
				d = fs.read(h, a)
				a = a - #d
				c = c .. d
			end
			return c
		end, function(a)
			return fs.seek(h, "cur", a)
		end, function()
			fs.close(h)
		end, path)
		if not v then
			tty.setcolor(0x4)
			print(e)
		end
		return v
	else
		tty.setcolor(0x4)
		print("invalid executable format "..ext)
	end
end
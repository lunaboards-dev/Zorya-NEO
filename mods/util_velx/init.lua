--#include "velx.lua"

local velx = {}

function velx.loadstream(read, seek, close, name)
	return load_velx(read, seek, close, name)
end

function velx.loadfile(addr, file)
	local fs = component.proxy(addr)
	local h = fs.open(file, "rb")
	local function read(a)
		return fs.read(h, a)
	end
	local function seek(a)
		return fs.seek(h, "cur", a)
	end
	local function close()
		return fs.close(h)
	end

	return velx.loadstream(read, seek, close, file)
end

return velx
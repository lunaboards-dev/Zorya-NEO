local vdev = krequire("util_vcomponent")
local utils = krequire("utils")
local thd = krequire("thd")
local comp = component
local eeprom = {}
local lua_code = [[
--#include "luabios.lua"
]]
local function generate_vbios(f_, path)
	local fs = comp.proxy(f_)
	if not fs.exists(path) then
		fs.makeDirectory(path)
	end
	if not fs.exists(path.."/code.lua") then
		local h = fs.open(path.."/code.lua", "wb")
		fs.write(h, lua_code)
		fs.close(h)
	end
	if not fs.exists(path.."/data.bin") then
		local h = fs.open(path.."/data.bin", "wb")
		fs.write(h, "")
		fs.close(h)
	end
	if not fs.exists(path.."/label.txt") then
		local h = fs.open(path.."/label.txt", "wb")
		fs.write(h, "Lua BIOS")
		fs.close(h)
	end
	local tbl = {
		get = function()
			local h = fs.open(path.."/code.lua", "rb")
			return utils.readfile(f_, h)
		end,
		getData = function()
			local h = fs.open(path.."/data.bin", "rb")
			return utils.readfile(f_, h)
		end,
		getLabel = function()
			local h = fs.open(path.."/label.txt", "rb")
			return utils.readfile(f_, h)
		end,
		set = function(data)
			local h = fs.open(path.."/code.lua", "wb")
			fs.write(h, data)
			fs.close(h)
		end,
		setData = function(data)
			local h = fs.open(path.."/data.bin", "wb")
			fs.write(h, data)
			fs.close(h)
		end,
		setLabel = function(label)
			local h = fs.open(path.."/label.txt", "wb")
			fs.write(h, label:sub(1, 16))
			fs.close(h)
		end,
		getDataSize = function()

			return fs.spaceTotal()
		end,
		getSize = function()

			return fs.spaceTotal()
		end,
		getChecksum = function()

			return 0/0
		end,
		makeReadonly = function()

			return
		end
	}
	vdev.register("vdev-ZY_VBIOS", "eeprom", tbl)
	local nice = function()

--#include "machine.lua"

	end
	return nice, tbl
end

return generate_vbios
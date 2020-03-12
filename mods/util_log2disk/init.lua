local vdev = krequire("util_vcomponent")
local utils = krequire("utils")
local component = component
return function(fs, file)
	local px = component.proxy(fs)
	local fh = px.open(file, "w")
	utils.debug_log("test")
	vdev.register("vdev-ZY_LOG2FILE", "sandbox", {
		log = function(...)
			px.write(fh, table.concat({...}, "   ").."\n")
		end
	})
	return true
end

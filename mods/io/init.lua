local vfs = krequire("zorya").loadmod("vfs")
local io = {}
local hand = {}

local hands = {}

function io.open(path, mode)
	local proxy, path = vfs.resolve(path)
	if not proxy then return nil, "file not found" end
end

function io.remove(path)
	local proxy, path = vfs.resolve(path)
	if not proxy then return false end
	return proxy.remove(path)
end

function io.mkdir(path)
	local proxy, path = vfs.resolve(path)
	if not proxy then return false end
	return proxy.makeDirectory(path)
end

function io.move(path, newpath)
	local proxy1, path1 = vfs.resolve(path)
	local proxy2, path2 = vfs.resolve(path)
	if not proxy1 or not proxy2 then return false end
	if proxy1 == proxy2 then
		proxy1.rename(path1, path2)
	end
end

function io.isreadonly(path)
	local proxy = vfs.resolve(path)
	if not proxy then return false end
	return proxy.isReadOnly()
end

function io.exists(path)
	local proxy, path = vfs.resolve(path)
	if not proxy then return false end
	return proxy.exists(path)
end

return io
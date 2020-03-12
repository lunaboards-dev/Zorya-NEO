local component, computer = component, computer
local vfs = {}

local mounts = {}

local function path_split(path)
	local parts = {}
	for m in path:gmatch("/(.+)") do
		if (m ~= "") then
			parts[#parts+1] = m
		end
	end
	return parts
end

local function t_compare(t1, t2)
	if (#t2 > #t1) then return false end
	for i=1, #t2 do
		if t1[i] ~= t2[i] then
			return false
		end
	end
	return true
end

function vfs.init()
	local tmp = component.proxy(computer.tmpAddress())
	mounts[1] = {
		path = "/",
		parts = {"/"},
		proxy = tmp
	}
	for fs in component.list("filesystem") do
		if (fs ~= tmp.address) then
			local name = fs:sub(1, 6)
			tmp.makeDirectory(name)
			vfs.mount("/"..name, component.proxy(fs))
		end
	end
	tmp.makeDirectory("tmp")
end

function vfs.mount(mountpoint, proxy)
	local parts = path_split(mountpoint)
	mounts[#mounts+1] = {path=mountpoint, parts=parts, proxy=proxy}
end

function vfs.resolve(path)
	local path_parts = path_split(path)
	local real_parts = {}
	for i=1, #path_parts do
		if (path_parts[i] == "..") then
			real_parts[#real_parts] = nil
		elseif (path_parts[i] ~= ".") then
			real_parts[#real_parts+1] = path_parts[i]
		end
	end
	path = "/"..table.concat(real_parts, "/")
	local search_mounts = {}
	for i=1, #mounts do
		if (path:sub(1, #mounts[i].path) == mounts[i].path) then
			search_mounts[#search_mounts+1] = mounts[i]
		end
	end
	table.sort(search_mounts, function(a, b)
		return #a.parts > #b.parts
	end)
	for i=1, #search_mounts do
		if (t_compare(real_parts, search_mounts[i].parts)) then
			return search_mounts[i].proxy, path:sub(#search_mounts[i].path+1)
		end
	end
	return nil, "not found"
end

return vfs
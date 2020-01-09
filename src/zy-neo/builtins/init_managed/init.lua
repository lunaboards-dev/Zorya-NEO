local readfile=function(f,h)
	local b=""
	local d,r=component.invoke(f,"read",h,math.huge)
	if not d and r then error(r)end
	b=d
	while d do
		local d,r=component.invoke(f,"read",h,math.huge)
		b=b..(d or "")
		if(not d)then break end
	end
	component.invoke(f,"close",h)
	return b
end

local bfs = {}

local cfg = component.proxy(component.list("eeprom")()).getData()

local baddr = cfg:sub(1, 36)

function bfs.getfile(path)
	local h = assert(component.invoke(baddr, "open", path, "r"))
	return readfile(baddr, h)
end

function bfs.exists(path)
	return component.invoke(baddr, "exists", path)
end


bfs.addr = baddr
-- I am an idiot.
local decompress = ...
local krq = krequire
local sunpack = string.unpack
local ct, cr = component, computer

-- I now must debug every fucking thing.
@[[if svar.get("DEBUG") then]]
do
	local cinvoke, clist, cproxy = ct.invoke, ct.list, ct.proxy
	function component.invoke(addr, meth, ...)
		cinvoke(clist("ocemu")(), "log", addr, meth, ..., debug.getinfo(2).source, debug.getinfo(2).linedefined)
		return cinvoke(addr, meth, ...)
	end

	function component.proxy(addr)
		local proxy = cproxy(addr)
		return setmetatable({}, {__index=function(_, i)
			if proxy[i] then
				return function(...)
					cinvoke(clist("ocemu")(), "log", addr, i, ..., debug.getinfo(3).source, debug.getinfo(3).linedefined)
					return proxy[i](...)
				end
			end
		end})
	end
end
@[[end]]
local cinvoke, clist, cproxy = ct.invoke, ct.list, ct.proxy

local function readfile(f,h)
	local b=""
	local d,r=cinvoke(f,"read",h,math.huge)
	if not d and r then error(r)end
	b=d
	while d do
		local d,r=cinvoke(f,"read",h,math.huge)
		b=b..(d or "")
		if(not d)then break end
	end
	cinvoke(f,"close",h)
	return b
end

--#include "src/zy-neo/builtins/util_tsar.lua"
@[[if not svar.get("ZY_PLATFORM") then]]
--#define "ZY_PLATFORM" "managed"
@[[end]]
--#include @[{"src/zy-neo/builtins/init_"..svar.get("ZY_PLATFORM").."/init.lua"}]
--component.invoke(component.list("sandbox")(), "log", "test")
if not bfs.exists("bootstrap.bin") then
	error("No bootstrap.bin!")
end
local raw = bfs.getfile("bootstrap.bin")
local code = decompress(raw)
--component.invoke(component.list("sandbox")(), "log", code or "<null>")
assert(load(code, "=bootstrap.bin"))(decompress, tsar, bfs, readfile)
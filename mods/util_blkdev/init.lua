local blkdev = {}

do
	local protos = {}
	local blk = {}

	function blkdev.proxy(name, ...)
		return setmetatable({udat=protos[name].open(...),type=name}, {__index=function(t, i)
			if (blk[i]) then
				return blk[i]
			elseif (protos[t.name].hasmethod(t.udat, i)) then
				return function(b, ...)
					return protos[b.type](b.udat, i, ...)
				end
			end
		end})
	end

	function blkdev.register(name, proto)
		protos[name] = proto
	end

	function blk:read(amt)
		return protos[self.type].read(self.udat, amt)
	end

	function blk:write(data)
		return protos[self.type].write(self.udat, data)
	end

	function blk:blktype()
		return self.type
	end

	function blk:seek(whence, amt)
		whence = whence or 0
		if (type(whence) == "number") then
			amt = whence
			whence = "cur"
		end
		if (whence == "cur") then
			return protos[self.type].seek(self.udat, amt)
		elseif (whence == "set") then
			return protos[self.type].setpos(self.udat, amt)
		elseif (whence == "end") then
			return protos[self.type].setpos(self.udat, protos[self.type].size(self.udat)+amt)
		end
	end
end

--#include "hdd.lua"
--#include "prom.lua"
--#include "osdi.lua"
---#include "mtpart.lua"
---#include "mbr.lua"

return blkdev
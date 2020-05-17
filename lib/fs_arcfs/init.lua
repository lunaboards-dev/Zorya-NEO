local arcfs = {}

function arcfs.make(arc)
	local proxy = {}
	local function ni()return nil, "not implemented"end
	local hands = {}
	proxy.remove = ni
	proxy.makeDirectory = ni
	function proxy.exists(path)
		return arc:exists(path)
	end
	function proxy.spaceUsed()
		return 0
	end
	function proxy.open(path, mode)
		if mode ~= "r" and mode ~= "rb" then
			return nil, "read-only filesystem"
		end
	end
	function proxy.isReadOnly()
		return true
	end
	proxy.write = ni
	function proxy.spaceTotal()
		return 0
	end
	function proxy.isDirectory(dir)
		if arc.isdir then return arc:isdir(dir) end
		return #arc:list(dir) > 0
	end
	function proxy.list(path)
		return arc:list(path)
	end
	function proxy.lastModified(path)
		return 0
	end
	function proxy.getLabel()
		return "ARCFS_VOLUME"
	end
	function proxy.close(hand)
		
	end
	function proxy.size(path)

	end
	function proxy.read(hand, count)

	end
	function proxy.seek(hand, whence, amt)

	end
	function proxy.setLabel()
		return "ARCFS_VOLUME"
	end
end
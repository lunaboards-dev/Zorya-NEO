local arcfs = {}

function arcfs.make(arc)
	local proxy = {}
	local function ni()return nil, "not implemented"end
	proxy.remove = ni
	proxy.makeDirectory = ni
	function proxy.exists(path)

	end
end
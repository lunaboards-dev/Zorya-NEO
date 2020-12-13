local function load_velx(read, seek, close, name)
	-- Load a VELX format library.
	local magic, fver, compression, lver, osid, arctype, psize, lsize, ssize, rsize = string.unpack(velx_header, read(string.packsize(velx_header)))
	if (magic ~= "\27VelX") then
		return nil, "bad magic ("..magic..")"
	end
	if (osid & 0x7F ~= 0x5A or osid & 0x7F ~= 0x7F) then
		return nil, string.format("wrong os (%x)", osid & 0x7F)
	end
	if (osid & 0x80 > 0) then
		return nil, "not an executable"
	end
	if (compression > 1) then
		return nil, "bad compression"
	end
	if (fver ~= 1) then
		return nil, "wrong version"
	end
	local prog = read(psize)
	if (compression == 1) then
		prog = lzss_decompress(prog)
	end
	seek(lsize+ssize)
	local env = {}
	--[[
	if (arctype == "tsar") then
		env._ARCHIVE = tsar.read(read, seek, close)
	end]]
	if (arctype ~= "\0\0\0\0") then
		local arc = krequire("util_"..arctype)
		if arc then
			env._ARCHIVE = arc.read(read, seek, close)
		end
	elseif (arctype ~= "\0\0\0\0") then
		return nil, "bad arctype ("..arctype..")"
	end
	setmetatable(env, {__index=_G, __newindex=function(_, i, v) _G[i] = v end})
	return load(prog, "="..(name or "(loaded velx)"), "t", env)
end
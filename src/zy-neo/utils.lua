local utils = {}
function utils.debug_log(...)
	local sb = clist("sandbox")() or clist("ocemu")() 
	if (sb) then cinvoke(sb, "log", ...) end
end

--[[function utils.baddr(address)
	local address = address:gsub("-", "", true)
	local b = ""
	for i=1, #address, 2 do
		b = b .. string.char(tonumber(address:sub(i, i+1), 16))
	end
	return b
end]]

function utils.readfile(f,h)
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

utils.load_lua = load_lua

utils.lzss_decompress = lzss_decompress

-- Hell yeah, deepcopy time.
function utils.deepcopy(src, dest)
	dest = dest or {}
	local coppied = {[src] = dest}
	local cin = {src}
	local cout = {dest}
	while #cin > 0 do
		for k, v in pairs(cin[1]) do
			if (type(v) ~= "table") then
				cout[1][k] = v
			else
				if (coppied[v]) then
					cout[1][k] = coppied[v]
				else
					local t = {}
					cout[1][k] = t
					cin[#cin+1] = v
					cout[#cout+1] = t
					coppied[v] = t
				end
			end
		end
		table.remove(cout, 1)
		table.remove(cin, 1)
	end
	return dest
end

local velx_header = "<c5BBBBc4I3I3I3I4"
function utils.load_velx(read, seek, close, name)
	-- Load a VELX format library.
	local magic, fver, compression, lver, osid, arctype, psize, lsize, ssize, rsize = string.unpack(velx_header, read(string.packsize(velx_header)))
	if (magic ~= "\27VelX") then
		return nil, "bad magic ("..magic..")"
	end
	if (osid & 0x7F ~= 0x5A) then
		return nil, string.format("wrong os (%x ~= 0x5A)", osid & 0x7F)
	end
	if (compression > 1) then
		return nil, "bad compression"
	end
	if ((arctype ~= "\0\0\0\0" and arctype ~= "tsar")) then
		return nil, "bad arctype ("..arctype..")"
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
	if (arctype == "tsar") then
		env._ARCHIVE = tsar.read(read, seek, close)
	end
	setmetatable(env, {__index=_G, __newindex=function(_, i, v) _G[i] = v end})
	return load(prog, "="..(name or "(loaded velx)"), "t", env)
end

local _RENV = _G

function utils.make_env()
	local env = utils.deepcopy(_RENV)
	env._G = env
	env.load = function(scr, name, mode, e)
		return load(scr, name, mode, e or env)
	end
	return env
end

function utils.console_panic(er)
	local con = krequire("zorya").loadmod("util_luaconsole")
	if (con) then
		local gpu = cproxy(clist("gpu")())
		if not gpu.getScreen() or gpu.getScreen() == "" then
			gpu.bind(clist("screen")())
		end
		con(string.format("tty.setcolor(0x4) print([[%s]])", er))
		return true
	end
end

_RENV = utils.make_env()

builtins.utils = function() return utils end
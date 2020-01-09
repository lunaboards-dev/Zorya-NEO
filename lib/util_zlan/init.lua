local component = component
local computer = computer

local mt = krequire("net_minitel")

local zlan = {}
--#include "pack.lua"
function zlan.exists(host, file)
	local sock = net.open(host, 9900)
	sock:w(string.char(2, 1, #file)..file.."x")
	local dat = recv_full_pack(sock)
	sock:c()
	return dat and dat:byte() > 0
end

function zlan.info(host, file)
	if (not zlan.exists(host, file)) then return nil, "not found" end
	local sock = net.open(host, 9900)
	sock:w(string.char(2, 1, #file)..file.."i")
	local info = recv_full_pack(sock)
	local size = string.char(1) | (string.char(2) << 8) | (string.char(3) << 16)
	local nz = string.char(4)
	local name = string.sub(5, 5+nz)
	local vz = string.char(6+nz)
	local ver = string.sub(7+nz, 7+nz+vz)
	local format = string.char(8+nz+vz)
	sock:c()
	return {
		size = size,
		name = name,
		version = version,
		format = format
	}
end

--Do decoding yourself.
function zlan.download(host, file)
	if (not zlan.exists(host, file)) then return nil, "not found" end
	local sock = net.open(host, 9900)
	sock:w(string.char(2, 1, #file)..file.."d")
	local fd = recv_full_pack(sock)
	sock:c()
	return fd
end

return zlan
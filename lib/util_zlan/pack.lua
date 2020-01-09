local function recv_pack_head(sock)
	local head = sock:r(6)
	local jv = head:byte(1)
	local nv = head:byte(2)
	local id = head:byte(3)
	local mx = head:byte(4)
	local size = head:byte(5) | (head:byte(6) << 8)
	return jv, nv, id, mx, head:r(size)
end

local function recv_full_pack(sock)
	local packets = {}
	local rt = 0
	while true do
		if not computer.pullSignal(2) then
			rt = rt + 1
			if (rt > 3) then
				return nil, "timeout"
			end
		else
			local _, _, _, mx, dat = recv_pack_head(sock)
			packets[#packets+1] = dat
		end
	end
	return table.concat(packets, "")
end
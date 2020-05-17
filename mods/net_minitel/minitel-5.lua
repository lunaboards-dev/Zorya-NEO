local c_sock = {}
local h_sock = {}

function c_sock:read(a)
	local dat = self.data:sub(1, a-1)
	self.data = self.data:sub(a)
	return dat
end

function c_sock:recieve(a)

end

function c_sock:write(d)

end

function c_sock:send(d)

end

function c_sock:close()
	
end

function c_sock:timeout(t)
	if t then self.to = t endsi
	return self.to
end
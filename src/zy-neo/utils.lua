
builtins.utils = function()
local utils = {}

function utils.debug_log(...)
	local sb = component.list("sandbox")() or component.list("ocemu")()
	if (sb) then component.invoke(sb, "log", ...) end
end

function utils.baddr(address)
	local address = address:gsub("-", "", true)
	local b = ""
	for i=1, #address, 2 do
		b = b .. string.char(tonumber(address:sub(i, i+1), 16))
	end
	return b
end

function utils.readfile(f,h)
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

utils.load_lua = load_lua

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
return utils
end
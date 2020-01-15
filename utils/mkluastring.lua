local f = io.stdin:read("*a")

--[[io.stdout:write("\"")
for i=1, #f do
	if (f:byte(i) < 32 or f:byte(i) > 126) then
		io.stdout:write(string.format("\\x%.2x",f:byte(i)))
	elseif (f:sub(i,i) == "\\") then
		io.stdout:write("\\\\")
	elseif (f:sub(i,i) == "\"") then
		io.stdout:write("\\\"")
	elseif (f:sub(i,i) == "\n") then
		io.stdout:write("\\n")
	elseif (f:sub(i,i) == "\r") then
		io.stdout:write("\\r")
	else
		io.stdout:write(f:sub(i,i))
	end
end
io.stdout:write("\"\n")]]
local rep = {
	["\0"] = "\\0",
	["\\"] = "\\\\",
	["\""] = "\\\"",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t",
	[" "] = "\x20"
}
local function mkstr(d)
	local dat = "\""
	for i=1, #f do
		if (rep[d:sub(i, i)]) then
			dat = dat .. rep[d:sub(i, i)]
		else
			dat = dat .. (d:sub(i,i))
		end
	end
	dat = dat .. ("\"")
	return dat
end
io.stdout:write(mkstr(f))
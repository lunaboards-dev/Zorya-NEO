local file = arg[1]
if (file == "-") then
	file = io.stdin
else
	file = io.open(file, "r")
end

local ast = {}

local current_node = ast

for line in file:lines() do
	if (line:sub(1, 6) ~= "entry " and line ~= "") then
		--Parse arguments
		local tmp = ""
		local open_quote = false
		local escape = false
		local cmd = nil
		local args = {}
		local pos = 0
		line = line:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
		for i=1, #line do
			local c = line:sub(i, i)
			if (c == " " and not open_quote) then
				if (tmp ~= "") then
					if not cmd then
						cmd = tmp
					else
						args[#args+1] = tmp
					end
				end
				tmp = ""
			elseif (c == "\"" and not escape and not open_quote) then
				open_quote = true
			elseif (c == "\"" and not escape) then
				open_quote = false
				args[#args+1] = "\""..tmp.."\""
				tmp = ""
			elseif (c == "\\" and not escape) then
				escape = true
			else
				if (escape) then escape = false end
				tmp = tmp .. c
			end
		end
		if (tmp ~= "") then
			if not cmd then
				cmd = tmp
			else
				args[#args+1] = tmp
			end
		end
		current_node[#current_node+1] = {type="call", call = cmd, args = args}
	elseif (line ~= "") then
		ast[#ast+1] = {type = "entry", name = line:sub(7)}
		current_node = ast[#ast]
	end
end

print("-- WARNING: Do not edit this file. This file is autogenerated by the zcfg-compiler")
for i=1, #ast do
	if (ast[i].type == "entry") then
		print("menu.entry(\""..ast[i].name.."\", function(env)")
		for j=1, #ast[i] do
			print("\tenv:"..ast[i][j].call.."("..table.concat(ast[i][j].args, ", ")..")")
		end
		print("end)")
	else
		print("menu."..ast[i].call.."("..table.concat(ast[i].args, ", ")..")")
	end
end
#!/usr/bin/env lua5.3
local _env = {}
local directives = {}

function directives.include(env, args)
	local path, err = args.get("string", 1)
	if (not path) then
		return false, err
	end
	local nenv = {code = ""}
	setmetatable(nenv, {__index=_env})
	local data, err = nenv:process(path)
	if (not data) then
		return false, err
	end
	env.code = env.code .. "\n" .. data
	return true
end

local mods = {}

function directives.loadmod(env, args)
	local path, err = args.get("string", 1)
	if (not path) then
		return false, err
	end
	local file = io.open(path, "rb")
	if (not file) then
		return false, "`"..path.."' not found."
	end
	local env = {}
	local copies = {{_G, env}}
	while #copies ~= 0 do
		local c = {}
		for i=1, #copies do
			for k, v in pairs(copies[i][1]) do
				if (type(v) == "table") then
					copies[i][2][k] = {}
					c[#c+1] = {v, copies[i][2][k]}
				else
					copies[i][2][k] = v
				end
			end
		end
		for i=1, #copies do
			copies[i] = nil
		end
		for i=1, #c do
			copies[i] = c[i]
		end
	end
	local dir2a = {}
	env.add_directive = function(name, func) do
		dir2a[#dir2a+1] = {name, func}
	end
	local func, err = load(file:read("*a"), "="..path, "t", env)
	if (not func) then
		return false, err
	end
	local name = func()
	if not name then
		return false, "Module did not return a name."
	end
	for i=1, #dir2a do
		directives[dir2a[i][1]] = dir2a[i][2]
	end
	return true
end
end

function _env:process(path)
	print("PROC", path)
	local file = io.open(path, "rb")
	local f, err = load(file:read("*a"), "="..path)
	if not f then
		io.stderr:write("ERROR: "..err.."\n")
		os.exit(1)
	end
	file:seek("set", 0)
	local ln = 0
	for line in file:lines() do
		ln = ln + 1
		line = line:gsub("^%s+", "")
		if (line:sub(1, 3) == "--#") then
			--Process directive
			local dir = line:sub(4)
			local tmp = ""
			local open_quote = false
			local escape = false
			local cmd = nil
			local args = {}
			local pos = 0
			dir = dir:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
			for i=1, #dir do
				local c = dir:sub(i, i)
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
					args[#args+1] = {"string", tmp}
					tmp = ""
				elseif (c == "\\" and not escape) then
					escape = true
				else
					if (escape) then escape = false end
					tmp = tmp .. c
				end
			end
			--Process arguments
			local rargs = {}
			for i=1, #args do
				if (type(args[i]) == "table") then
					if (args[i][1] == "string") then
						local str = args[i][2]
						local sp, ep = str:find("%$%([%w_]+%)")
						while sp do
							local var = str:sub(sp, ep)
							local st1, st2 = str:sub(1, sp-3), str:sub(ep+2)
							str = st1 .. var
							local nsp = #str
							str = str .. st2
							sp, ep = str:find("%$%([%w_]+%)", nsp)
						end
						args[i][2] = str
					end
					rargs[#rargs+1] = args[i]
				elseif (tonumber(args[i])) then
					rargs[#rargs+1] = {"number", args[i]}
				elseif (args == "true" or args == "false") then
					rargs[#rargs+1] = {"boolean", args[i] == "true"}
				elseif (os.getenv(args[i])) then
					rargs[#rargs+1] = {"var", args[i]}
				else
					io.stderr:write("ERROR: "..path..":"..ln..": Undefined variable.\n")
					os.exit(1)
				end
			end
			if (not directives[cmd]) then
				io.stderr:write("ERROR: "..path..":"..ln..": Unknown directive.\n")
				os.exit(1)
			end
			local rtn, err = directives[cmd](self, {get=function(atype, i)
				if (type(atype) == "number") then
					return rargs[i][2], rargs[i][1]
				end
				if (rargs[i] == nil) then
					return false, "argument #"..i..": expected `"..atype.."', got nil"
				end
				if (rargs[i][1] ~= atype) then
					return false, "argument #"..i..": expected `"..atype.."', got `"..rargs[i][1].."'"
				end
				return rargs[i][2]
			end})
			if (type(rtn) ~= "boolean") then
				io.stderr:write("ERROR: "..path..":"..ln..": Expected return type `boolean', got `"..type(rtn).."'.\n")
				os.exit(1)
			end
			if (not rtn) then
				err = err or "Unknown error"
				io.stderr:write("ERROR: "..path..":"..ln..": "..err..".\n")
			end
		else
			self.code = self.code .. line .. "\n"
		end
	end
	return self.code
end

local env = {code = ""}
setmetatable(env, {__index=_env})
env:process(arg[1])
local tmpfile = os.tmpname()
local tmpf = io.open(tmpfile, "wb")
tmpf:write(env.code)
tmpf:close()
if (os.execute("luamin -f "..tmpfile.." > "..arg[2])) then
	os.execute("stat -c \"Output: %s bytes\" "..arg[2])
else
	io.stderr:write("Error: ")
	os.execute("cat "..arg[2].." 1>&2")
	os.remove(arg[2])
end
os.remove(tmpfile)
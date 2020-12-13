local function make_library(mod)
	os.execute("mkdir -p pkg/lib")
	--print("LIB", mod)
	local arc = false
	if (os.execute("[[ -d lib/"..mod.."/arc ]]")) then
		arc = "lib/"..mod.."/arc"
	end
	local h = io.open("pkg/lib/"..mod..".velx", "w")
	h:write(EXPORT.velx("init.lua", arc, {
		PWD = os.getenv("PWD").."/lib/"..mod
	}))
	h:close()
end

local lib = {}

local h = io.popen("ls lib", "r")
for line in h:lines() do
	--[[actions["mod_"..line] = function()
		make_module(line)
	end]]
	task("lib_"..line, function()
		status("build", line)
		make_library(line)
	end)
	lib[#lib+1] = "lib_"..line
end

task("alllibs", function()
	for i=1, #lib do
		dep(lib[i])
	end
end)
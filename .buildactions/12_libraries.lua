function make_library(mod)
	os.execute("mkdir -p pkg/lib")
	print("LIB", mod)
	local h = io.open("pkg/lib/"..mod..".velx", "w")
	h:write(velx("init.lua", false, {
		PWD = os.getenv("PWD").."/lib/"..mod
	}))
	h:close()
end

local libs = {}

local h = io.popen("ls lib", "r")
for line in h:lines() do
	actions["lib_"..line] = function()
		make_library(line)
	end
	libs[#libs+1] = "lib_"..line
end

function actions.alllibs()
	for i=1, #libs do
		actions[libs[i]]()
	end
end

actions[#actions+1] = "alllibs"
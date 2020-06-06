function make_module(mod)
	os.execute("mkdir -p pkg/mods")
	print("MOD", mod)
	local arc = false
	if (os.execute("[[ -d mods/"..mod.."/arc ]]")) then
		arc = "mods/"..mod.."/arc"
	end
	local h = io.open("pkg/mods/"..mod..".velx", "w")
	h:write(velx("init.lua", arc, {
		PWD = os.getenv("PWD").."/mods/"..mod
	}))
	h:close()
end

local mods = {}

local h = io.popen("ls mods", "r")
for line in h:lines() do
	actions["mod_"..line] = function()
		make_module(line)
	end
	mods[#mods+1] = "mod_"..line
end

function actions.allmods()
	for i=1, #mods do
		actions[mods[i]]()
	end
end

actions[#actions+1] = "allmods"
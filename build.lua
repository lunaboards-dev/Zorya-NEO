local actions = {}

@[[local h = io.popen("ls .buildactions", "r")
for line in h:lines() do]]
--#include @[{".buildactions/"..line}]
@[[end]]

--[[function actions.debug()
	actions.kernel(true)
	actions.crescent()
	actions.velxboot()
	actions.clean()
end]]

function actions.all()
	for i=1, #actions do
		actions[actions[i]]()
	end
end

function actions.list()
	for k, v in pairs(actions) do
		if type(k) == "string" then
			io.stdout:write(k, " ")
		end
	end
	print("")
end

if not arg[1] then
	arg[1] = "all"
end

actions[arg[1]]()

print("Build complete.")
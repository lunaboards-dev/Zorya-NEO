local arg = ...
if (arg == "") then
	arg = "init.lua"
end
load_exec(arg)()
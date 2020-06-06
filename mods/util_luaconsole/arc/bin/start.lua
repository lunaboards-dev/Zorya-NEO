local thd = krequire("thd")
local utils = krequire("utils")
local arg = ...
local name = arg:match("/(.+%..+)^") or arg
thd.add(name, function()
	load_exec(arg)()
end)
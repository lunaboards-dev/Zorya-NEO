local zy = krequire("zorya")
local sys = krequire("sys")
local utils = krequire("utils")

local computer, component = computer, component

local sp = {}

function sp.add_mod_path(drive, path)
	local px = component.proxy(drive)
	zy.add_mod_search(function(mod)
		if (px.exists(path.."/"..mod..".zy2m")) then
			local h = px.open(path.."/"..mod..".zy2m", "r")
			return utils.load_lua(utils.readfile(drive, h))
		elseif (px.exists(path.."/"..mod.."/init.zy2m")) then
			local h = px.open(path.."/"..mod.."/init.zy2m", "r")
			return utils.load_lua(utils.readfile(drive, h))
		end
	end)
end

function sp.add_lib_path(drive, path)
	local px = component.proxy(drive)
	sys.add_search(function(mod)
		if (px.exists(path.."/"..mod..".zy2l")) then
			local h = px.open(path.."/"..mod..".zy2l", "r")
			return utils.load_lua(utils.readfile(drive, h))
		elseif (px.exists(path.."/"..mod.."/init.zy2l")) then
			local h = px.open(path.."/"..mod.."/init.zy2l", "r")
			return utils.load_lua(utils.readfile(drive, h))
		end
	end)
end

return sp
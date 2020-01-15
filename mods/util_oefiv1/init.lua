local comp = component
local computer = computer
local thd = krequire("thd")
local zy = krequire("zorya")
local utils = krequire("utils")

local oefi = {}

local function load_oefi(drive, path, uuid)
	local oefi_env = {}
	local env = {}
	utils.deepcopy(_G, env)
	env.krequire = nil
	env._BIOS = nil
	env._ZVER = nil
	env._ZVSTR = nil
	env._ZPAT = nil
	env.oefi = setmetatable(oefi_env, {__index=oefi})
	function env.computer.getBootAddress()
		return drive
	end
	function oefi_env.returnToOEFI()
		computer.pushSignal("oefi_killall")
		computer.pullSignal("k") --It actually kills the application
	end
	local h = comp.invoke(drive, "open", path)
	local dat = utils.readfile(drive, h)
	comp.invoke(drive, "close", h)
	return load(dat, "="..path, "t", env)
end

function oefi.getAPIVersion()
	return 1
end

function oefi.getImplementationName()
	return _BIOS
end

function oefi.getImplementationVersion()
	return _ZVER
end

function oefi.execOEFIApp(fs, path)
	local uuid = string.char(math.random(0,255),math.random(0,255),math.random(0,255),math.random(0,255))
	local func, manifest = load_oefi(drive, path, uuid)
	local args = {}
	local name = "oefi$"..manifest.name:gsub(" ", "_")
	thd.add(name, function()
		func(unpack(args))
		os.pushSignal("oefi_end", uuid)
	end) --ez
	while true do
		local s, i = computer.pullSignal()
		if (s == "oefi_end" and i == uuid) or s == "oefi_killall" then
			break
		end
	end
end
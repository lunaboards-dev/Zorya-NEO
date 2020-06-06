local comp = component
local computer = computer
local thd = krequire("thd")
local zy = krequire("zorya")
local utils = krequire("utils")
local oefi = {}

local ext = {}

local unpack = unpack or table.unpack

---#include "bios.lua"

local function load_oefi_env(file, envx)
	utils.debug_log(file, envx.fs)
	local cpio = krequire("util_cpio")
	local urf = krequire("util_urf")
	local vdev = zy.loadmod("util_vcomponent")
	local arc = urf.read(envx.fs, file)
	if not arc then
		arc = cpio.read(envx.fs, file)
	end
	local oefi_env = {}
	local env = utils.make_env()
	env.krequire = nil
	env._BIOS = nil
	env._ZVER = nil
	env._ZVSTR = nil
	env._ZPAT = nil
	env.oefi = setmetatable(oefi_env, {__index=oefi})
	local p = gen_proto()
	vdev.install(env)
	vdev.register("zbios", "eeprom", p.methods)
	local fs = component.proxy(envx.fs)
	function oefi_env.loadfile(path)
		local h = fs.open(path)
		local fd = utils.readfile(envx.fs, h)
		fs.close(h)
		return load(fd, "="..path, "t", env)
	end
	function oefi_env.loadInternalFile(path)
		return arc:fetch(path)
	end
	function oefi_env.returnToOEFI()
		computer.pushSignal("oefi_killall")
		computer.pullSignal("k") --It actually kills the application
	end
	function env.computer.pullSignal(...)
		local s = {computer.pullSignal(...)}
		if (s[1] == "oefi_killall") then
			computer.pullSignal("k")
		end
		return unpack(s)
	end
	function oefi_env.getBootAddress()
		return envx.fs
	end
	--vdev.overwrite(env)
	--vdev.register_type("eeprom_oefiemu", gen_proto(baddr(envx.fs.address)))
	--vdev.add_device("biosemu", "eeprom_oefiemu")
	local dat = env.oefi.loadInternalFile("app.exe")
	local func = load(dat, "="..file..":/app.exe", "t", env)
	local cfgdat = env.oefi.loadInternalFile("app.cfg")
	local cfg = {}
	for line in cfgdat:gmatch("(.-)[\r\n]+") do
		utils.debug_log("CONFIG", line)
		local k, v = line:match("(.+)=(.+)")
		utils.debug_log("PARSED", k, v)
		cfg[k] = v
	end
	return func, cfg
end

local function load_oefi(drive, path)
	local ext = path:sub(#path-4, #path)
	return load_oefi_env(path, {fs = drive, uuid=uuid})
end

function oefi.getAPIVersion()
	return 2.1
end

function oefi.getImplementationName()
	return _BIOS
end

function oefi.getImplementationVersion()
	return _ZVER
end

function oefi.execOEFIApp(drive, path)
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

function oefi.getExtensions()
	return ext
end

function oefi.getApplications()
	return {}
end

function ext.ZyNeo_GetOEFIEnv(drive, arc)
	local oefi_env = {}
	local env = utils.make_env()
	env.krequire = nil
	env._BIOS = nil
	env._ZVER = nil
	env._ZVSTR = nil
	env._ZPAT = nil
	env.oefi = setmetatable(oefi_env, {__index=oefi})
	local fs = component.proxy(drive)
	function oefi_env.loadfile(path)
		local h = fs.open(path)
		local fd = utils.readfile(drive, h)
		fs.close(h)
		return load(fd, "="..path, "t", env)
	end
	function oefi_env.loadInternalFile(path)
		if (arc) then
			return arc:fetch(path)
		end
	end
	function oefi_env.returnToOEFI()
		computer.pushSignal("oefi_killall")
		computer.pullSignal("k") --It actually kills the application
	end
	function env.computer.pullSignal(...)
		local s = {computer.pullSignal(...)}
		if (s[1] == "oefi_killall") then
			computer.pullSignal("k")
		end
		return unpack(s)
	end
	function oefi_env.getBootAddress()
		return drive
	end
	return env
end

function ext.ZyNeo_ExecOEFIApp(drive, path, ...)
	local uuid = string.char(math.random(0,255),math.random(0,255),math.random(0,255),math.random(0,255))
	local func, manifest = load_oefi(drive, path, uuid)
	local args = {...}
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

return oefi
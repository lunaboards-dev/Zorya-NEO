local component = require("component")

local function openos_kload(env, fs)
	ENV.BOOTFUNC = ENV.lib.loadfile(fs, "init.lua")
end
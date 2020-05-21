local zy = require("zorya")
local formats = {
	["msdos\0\0\0"] = "fs_fat",
	["FoX FSys"] = "fs_foxfs",
	["linux\0\0\0"] = "fs_ext2"
}


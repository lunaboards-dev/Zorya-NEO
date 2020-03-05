local tsuki = {}

local zy = krequire("zorya")
local thd = krequire("thd")
local utils = krequire("utils")
local arcfs = zy.loadmod("util_arcfs")
local cpio = krequire("util_cpio")

local function kernel(drive, part, name)
	local fs = krequire("fs_foxfs").osdi_proxy(drive, part)
	local stat = fs.stat("/boot/kernel/"..name..".tknl")
	local h = fs.open("/boot/kernel/"..name..".tknl", "r")
	local knl = fs.read(h, stat.size)
	fs.close(h)
	local func = utils.load_lua(knl)
	return setmetatable({
		kernel = func,
		args = {root={drive, part}},
		fs = fs,
	}, {__index=tsuki})
end

function tsuki:initramfs(path)
	local hand = self.fs.open(path, "r")
	local arc = cpio.read_h(fs, hand)
	local fs = arcfs.proxy(arc)
	self:karg("initramfs", fs)
end

function tsuki:karg(key, value)
	self.args[key] = value
end

function tsuki:boot()
	thd.add("tsuki", function()
		self.kernel(self.args) --This is how we do.
		computer.pushSignal("tsuki_dead")
	end)
	while true do if computer.pullSignal() == "tsuki_dead" then break end end
end

return kernel
local zy = krequire("zorya")
local vdev = zy.loadmod("util_vcomponent")
vdev.register("ZORYA_BIOS", "zybios", {
	{
		get_threads_info = function()
			local threads = {}
			for i=1, zy.lkthdn() do
				local info = zy.lkthdi(i)
				threads[i] = {
					name = info[1],
					deadline = info[6]
				}
			end
			return threads
		end,
		get_version = function()
			return string.format("%f.%d", _ZVER, _ZPAT)
		end,
		get_git_revision = function()
			return _ZGIT
		end
	},
	{
		get_threads_info = "get_threads_info():table -- Returns the BIOS thread information.",
		get_version = "get_version():string -- Returns the Zorya NEO version.",
		get_git_revision = "get_git_revision():string -- Returns the git revision of the build."
	}
})

return true
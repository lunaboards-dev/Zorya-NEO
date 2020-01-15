local function gen_proto(drive)
	return {
		methods = {
			get = function()
				return "< Virtual BIOS >"
			end,
			getData = function()
				return string.char(2)..drive.."Zorya NEO BIOS"..string.char(0):rep(6)
			end,
			setData = function()
				return ""
			end,
			set = function()
				return ""
			end,
			getLabel = function()
				return "Virtual OEFI BIOS"
			end,
			setLabel = function()
				return "Virtual OEFI BIOS"
			end
		},
		docs = {}
	}
end
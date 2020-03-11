		-- This our custom machine.lua
		local utils = krequire("utils")
		local computer = computer
		xpcall(function()
			utils.debug_log("Copying env...")
			local env = utils.deepcopy(_G)
			utils.debug_log("Coppied env.")
			env._G = env
			env._ENV = env
			env.krequire = nil
			env._BIOS = nil
			env._ZVSTR = nil
			env._ZVER = nil
			env._ZPAT = nil
			env._ZGIT = nil
			vdev.install(env)
			local _oldlist = env.component.list
			local thdid = string.format("%.4x", math.random(0, 2^16-1))
			function env.component.list(...)
				local ol = _oldlist(...)
				local tcall = function()
					local a, t = ol()
					if (a ~= "vdev-ZY_VBIOS" and t == "eeprom") then
						a, t = ol()
					end
					return a, t
				end
				for k, v in pairs(ol) do
					if (k ~= "vdev-ZY_VBIOS" and v == "eeprom") then
						ol[k] = nil
					end
				end
				return setmetatable({}, {__index=ol, __call=tcall})
			end
			function env.load(code, name, mode, e, ...)
				local e = e or env
				return load(code, name, mode, e, ...)
			end
			local ded = false
			function env.computer.returnToBios()
				local thds = thd.get_threads()
				local vbname = "vbios$"..tbl.getLabel().."#"..thdid
				for i=1, #thds do
					if (thds[i][1] == vbname) then
						thds[i][6] = true
					end
				end
				ded = true
				utils.debug_log("Returning to BIOS...")
			end
			utils.debug_log("Loading vBIOS...")
			thd.add("vbios$"..tbl.getLabel().."#"..thdid, function()
				xpcall(function()
					utils.debug_log("Starting BIOS.")
					assert(load(tbl.get(), "=vbios", "t", env))()
				end, function(err)
					utils.debug_log("ERROR", "vBIOS error!")
					utils.debug_log(err, debug.traceback())
				end)
				utils.debug_log("Sending signal.")
				computer.pushSignal("vbios_dead")
			end)
			while true do
				if computer.pullSignal() == "vbios_dead" then
					utils.debug_log("Got signal.")
					break
				end
			end
			utils.debug_log("Dead.")
		end, function(err)
			utils.debug_log("ERROR", "vBIOS error!")
			utils.debug_log(err, debug.traceback())
		end)
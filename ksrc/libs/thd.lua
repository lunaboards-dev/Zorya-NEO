local thd = {}

local threads = {}

local idx = 1

local computer = computer
local unpack = unpack or table.unpack
local coroutine = coroutine
local c_create = coroutine.create
local c_yield = coroutine.yield
local c_resume = coroutine.resume
local c_status = coroutine.status

function thd.add(name, func)
	local t = assert(c_create(func))
	--component.proxy(component.list("sandbox")()).debug_log(name, t, func)
	threads[#threads+1] = {name, t, {}, 0, ".+"}
	threads[t] = threads[#threads]
end

local sigs = {}
local ps = computer.pullSignal
function thd.autosleep()
	local msleep = math.huge
	for i=1, #threads do
		if (threads[i][4] and threads[i][4] < msleep) then
			msleep = threads[i][4]
		end
	end
	local rsleep = msleep-computer.uptime()
	if (rsleep < 0 or #sigs > 0) then
		rsleep = 0
	end
	local sig = {ps(rsleep)}
	if (#sigs > 0) then
		if (#sig > 0) then
			sigs[#sigs+1] = sig
		end
		sig = sigs[1]
		table.remove(sigs, 1)
	end
	return sig
end

local last_sig = {}

function thd.run()
	last_sig = thd.autosleep()
	for i=1, #threads do
		if (threads[i][4] <= computer.uptime() or #last_sig > 0) then
			if (c_status(threads[i][2]) ~= "running") then
				local er, dl = c_resume(threads[i][2], unpack(last_sig))
				if (not er) then error(threads[i][1]..": "..dl) end
				if (dl == "k") then
					threads[i][6] = true
				end
				dl = computer.uptime() + (dl or math.huge)
				threads[i][4] = dl
				sigs[#sigs+1] = {ps(0)}
			end
		end
	end
	local t = {}
	for i=1, #threads do
		local v = threads[i]
		if (c_status(v[2]) ~= "dead" and not v[6]) then
			t[#t+1] = v
			t[v[2]] = v
		end
	end
	threads = t
	return #threads > 0
end

function thd.kill(i)
	threads[i][6] = true
end

function thd.sched_end()
	return #threads == idx
end

function thd.get_threads()
	return threads
end

function computer.pullSignal(t)
	return c_yield(t)
end

return thd
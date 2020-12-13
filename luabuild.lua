--#!/usr/bin/env luajit
EXPORT = {}

local version = "0.1.0"
local lanes = require("lanes").configure({
	demote_full_userdata = true
})
local argparse = require("argparse")

local nproc = 0
do
	local h = io.popen("nproc", "r")
	local n = h:read("*a"):match("%d+")
	h:close()
	if n and tonumber(n) then
		nproc = tonumber(n)
	end
end

_NPROC = nproc

local tags = {
	["info"] = "\27[36mINFO\27[0m",
	["warning"] = "\27[93mWARNING\27[0m",
	["error"] = "\27[91mERROR\27[0m",
	["build"] = "\27[35mBUILD\27[0m",
	["ok"] = "\27[92mOK\27[0m",
	["link"] = "\27[34mLINK\27[0m",
	["pack"] = "\27[95mPACK\27[0m",
}

function lastmod(path)
	
end

local function wait_start(t)
	while t.status == "pending" do lanes.sleep() end
end

local function getwh()
	local f = io.popen("stty size", "r")
	local w, h = f:read("*n"), f:read("*n")
	f:close()
	return tonumber(w), tonumber(h)
end

local function draw_bar(tag, object, max, current)
	if (#object > 15) then
		object = object:sub(1, 12).."..."
	end
	os.execute("stty raw -echo 2> /dev/null") -- i cannot comprehend what retardation lead me to have to do this
	io.stdout:write("\27[6n")
	io.stdout:flush()
	local lc = ""
	while lc ~= "\27" do
	--	print(string.byte(lc) or "<none>")
		lc = io.stdin:read(1)
	--	print(string.byte(lc))
	end
	io.stdin:read(1)
	local buf = ""
	while lc ~= "R" do
		lc = io.stdin:read(1)
		buf = buf .. lc
	end
	os.execute("stty sane 2> /dev/null")
	--print(buf)
	local y, x = buf:match("(%d+);(%d+)")
	x = tonumber(x)
	y = tonumber(y)
	--print(os.getenv("LINES"), os.getenv("COLUMNS"))
	--local l = tonumber(os.getenv("LINES"))
	--local c = tonumber(os.getenv("COLUMNS"))
	--print(l, c)
	local l, c = getwh() -- WHY
	if (y == l) then
		print("")
		y = y - 1
	end
	local mx = string.format("%x", max)
	local cur = string.format("%."..#mx.."x", current)
	local bar = (current/max)*(c-(26+#mx*2))
	if bar ~= bar then bar = 0 end
	io.stdout:write("\27["..l.."H")
	local pad = 6-#tag
	local opad = 16-#object
	--print(math.floor(bar))
	local hashes = string.rep("#", math.floor(bar))
	local dashes = string.rep("-", c-(26+#mx*2+#hashes))
	io.stdout:write(tags[tag], string.rep(" ", pad), object, string.rep(" ", opad), cur, "/", mx, " [", hashes, dashes, "]")
	io.stdout:write("\27[", x, ";", y, "H")
end

function status(tag, msg)
	print(tags[tag], msg)
end

local threads = {}

local stat = status

local function run(cmd)
	if not status then status = stat end
	local h = io.popen(cmd.." 2>&1", "r")
	local out = h:read("*a")
	local rtn = h:close()
	return rtn, out
end

local tasks = {}
local reflect = {}

function task(name, stuff)
	tasks[#tasks+1] = {name, stuff, false}
end

reflect.task = task
reflect._NPROC = nproc
reflect.status = status
reflect.draw_bar = draw_bar

function dep(name)
	if not status then setmetatable(_G, {__index=reflect}) end
	for i=1, #tasks do
		if (tasks[i][1] == name) then
			if not tasks[i][3] then
				tasks[i][3] = true
				tasks[i][2]()
			end
			return
		end
	end
	status("error", "Task `"..name.."' not found!")
	os.exit(1)
end

reflect.dep = dep

local function sync()
	local errors = {}
	while #threads > 0 do
		for i=1, #threads do
			if (threads[j].status ~= "running") then
				if not threads[j][1] then
					errors[#errors+1] = threads[j][2]
				end
				table.remove(threads, j)
				break
			end
		end
	end
	return errors
end

reflect.sync = sync

local CC_STATE = {
	compiler = "clang",
	flags = {},
	args = {},
	libs = {},
}

local run_t = lanes.gen("*", run)

local function compile(file)
	local compiler_command = compiler .. " -fdiagnostics-color=always "
	for i=1, #CC_STATE.flags do
		compiler_command = compiler_command .. "-f"..CC_STATE.flags[i].." "
	end
	for i=1, #CC_STATE.args do
		compiler_command = compiler_command .. CC_STATE.args[i].." "
	end
	compiler_command = compiler_command .. file
	return run_t(compiler_command)
end

local function link(target, files)
	local nfiles = {}
	for i=1, #files do
		nfiles[i] = files[i]:gsub("%.c$", ".o")
	end

	local compiler_command = compiler .. " -fdiagnostics-color=always "
	for i=1, #CC_STATE.libs do
		compiler_command = compiler_command .. "-l"..CC_STATE.args[i].." "
	end
	compiler_command = compiler_command "-o "..target.. " " .. table.concat(files, " ")
	run(compiler_command)
end

function build(target, files)
	status("build", target.." ("..#files.." source files)")
	draw_bar("build", target, 0, #files)
	for i=1, #files do
		if (#threads == nproc) then
			while true do
				for j=1, #threads do
					if (threads[j].status ~= "running") then
						if not threads[j][1] then
							status("error", "Error in compile, waiting for all threads to finish...")
							local errors = sync()
							print(threads[j][2])
							for k=1, #errors do
								print(errors[k])
							end
							os.exit(1)
						else
							threads[j] = compile(files[i])
							wait_start(threads[j])
							break
						end
					end
				end
				lanes.sleep()
			end
		else
			threads[#threads+1] = compile(files[i])
		end
		draw_bar("build", target, #files, i)
	end
	local errors = sync()
	if #errors > 0 then
		for i=1, #errors do
			print(errors[i])
		end
		os.exit(1)
	end
	status("link", target)
	draw_bar("link", target, 1, 1)
	link(target, files)
end

reflect.build = build
reflect.EXPORT = EXPORT

function find(path)
	local entries = {}
	local h = io.popen("find "..path, "r")
	for l in h:lines() do
		entries[#entries+1] = l
	end
	return entries
end

reflect.find = find

local files = find(".build")
for i=1, #files do
	if (files[i]:match("%.lua$")) then
		dofile(files[i])
	end
end

task("list", function()
	for i=1, #tasks do
		print(tasks[i][1])
	end
end)

local dep_t = lanes.gen("*", dep)

local function run_task(task)
	local t = dep_t(task)
	wait_start(t)
	while true do
		if (t.status ~= "running") then
			if (t.status ~= "done") then
				status("error", "Task '"..task.."' has run into an error!")
				print(t[1])
			end
			break
		end
	end
	lanes.sleep()
end

local parser = argparse("luabuild", "High-speed lua build system.")
parser:option("-j --threads", "Number of threads", nproc)
parser:argument("tasks", "Tasks to run"):args("*")
local args = parser:parse()
status("info", "luabuild version is "..version)
status("info", "lua verison is ".._VERSION)
if not tonumber(args.threads) then
	status("error", "Number of threads must be a number!")
	os.exit(1)
end
nproc = tonumber(args.threads)
status("info", "core count: "..nproc)
for i=1, #args.tasks do
	status("info", "Current task: "..args.tasks[i])
	local st = os.clock()
	run_task(args.tasks[i])
	local dur = os.clock()-st
	status("ok", "Task `"..args.tasks[i].."' completed in "..string.format("%.2fs", dur))
end
status("ok", "Build completed in "..string.format("%.2fs", os.clock()))
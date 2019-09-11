if (not os.execute("stat .git>/dev/null 2>&1")) then
	io.stderr:write("This script must be executed at the root (run utils/mkrelease.lua)\n")
	os.exit(1)
end

os.execute("mkdir -p build/modules")
os.execute("mkdir -p build/loaders")
os.execute("mkdir -p build/microruntime")

local cwd = os.getenv("PWD")

local function dir(path, func)
	local h = io.popen("ls "..path, "r")
	for line in h:lines() do
		func(line)
	end
end

print("Building modules...")
dir("src/modules", function(entry)
	print("MOD", entry)
	os.execute("utils/mkmod.sh src/modules/"..entry.." build/"..entry)
end)

print("Building loaders...")
dir("src/loaders", function(entry)
	print("LOADER", entry)
	os.execute("cd src/loaders/"..entry.."; "..cwd.."/utils/luapreproc.lua init.lua "..cwd.."/build/loaders/"..entry..".bios>/dev/null")
end)

print("Building microruntimes...")
dir("src/microruntime", function(entry)
	print("URT", entry)
	os.execute("cd src/microruntime/"..entry.."; "..cwd.."/utils/luapreproc.lua init.lua "..cwd.."/build/microruntime/"..entry..".urt>/dev/null")
end)

print("Packing...")
os.execute("cd build; find * -depth | cpio -o > ../update.zy2 2>/dev/null")
print("Packaging complete. See update.zy2.")
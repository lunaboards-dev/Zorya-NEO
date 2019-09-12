if (not os.execute("stat .git>/dev/null 2>&1")) then
	io.stderr:write("This script must be executed at the root (run utils/mkrelease.lua)\n")
	os.exit(1)
end

os.execute("mkdir -p build/modules")
os.execute("mkdir -p build/loaders")
os.execute("mkdir -p build/microruntime")
os.execute("mkdir -p build/installerdat")

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
	os.execute("utils/mkmod.sh src/modules/"..entry.." build/modules/"..entry)
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

print("Copying installer info...")
os.execute("cp -r src/installerdat/* build/installerdat")

print("Packing...")
os.execute("cd build; find * -depth | grep -v .git/ |cpio -o > update.zy2 2>/dev/null")
print("Packaging complete. See build/update.zy2.")

print("Note: Package should probably be signed! Use utils/signupdate.sh...")
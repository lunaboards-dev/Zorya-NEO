local h = io.popen("find build -depth -type f | grep -v sig.bin | grep -v update.zy2", "r")
local sigfile = io.open("build/sig.bin", "wb")
for line in h:lines() do
	sigfile:write(line:sub(7).."\0")
	local s = io.popen("openssl dgst -sha256 -sign zbsign.pem "..line, "r")
	sigfile:write(s:read("*a"))
	s:close()
end
sigfile:close()
os.execute("cd build; find * -depth | grep -v update.zy2 | cpio -o > update.zy2")
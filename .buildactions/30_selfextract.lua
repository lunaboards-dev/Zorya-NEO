function makeselfextract(indir, outfile)
	local cwd = os.getenv("PWD")
	os.execute("cd "..indir.."; find * -depth | lua "..cwd.."/utils/make_tsar.lua | lua "..cwd.."/utils/mkselfextract.lua > "..cwd.."/"..outfile)
end
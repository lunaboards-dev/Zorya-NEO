function actions.clean()
	print("Cleaning up...")
	--os.execute("rm -rf .docs")
	--os.execute("rm -rf .ktmp")
	os.execute("mkdir -p pkg")
	os.execute("rm -rf pkg/*")

	os.execute("mkdir -p release")
	os.execute("rm -rf release/*")

end
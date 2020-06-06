local arg = ...
if not _DRIVE then
	for d in component.list("filesystem") do
		print(d)
	end
else
	local t = component.invoke(_DRIVE, "list", arg)
	for i=1, #t do
		print(t[i])
	end
end
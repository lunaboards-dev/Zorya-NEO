local fs = ...
for f in component.list("filesystem") do
	if (f:sub(1, #fs) == fs) then
		_DRIVE = f
	end
end
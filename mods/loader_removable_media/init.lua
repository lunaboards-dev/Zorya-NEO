return function(filter)
	filter = filter or function() return true end
	return function()
		for f in component.list("filesystem") do
			if (filter(f) and component.invoke(f, "spaceTotal") ) then

			end
		end
	end
end
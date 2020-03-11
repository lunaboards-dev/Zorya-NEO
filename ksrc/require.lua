local kpkg = {}
kpkg.libs = {}
local krlib = kpkg.libs
kpkg.search = {}
local krfind = kpkg.search
function krequire(pkg)
	if (krlib[pkg]) then return krlib[pkg] end
	for i=1, #krfind do
		local r = krfind[i](pkg)
		if (r) then krlib[pkg] = r() return krlib[pkg] end
	end
end
local krequire = krequire

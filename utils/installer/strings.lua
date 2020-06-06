local lang = {}
do
	local _LANGINFO = {}
	function lang.load(locale)
		_LANGINFO = blt.deserialize(lzss_decompress(getfile("lang/"..locale..".blt.z")))
	end

	function lang.getstring(str)
		return _LANGINFO[str]
	end
end
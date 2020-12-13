do
	local velx2 = {}

	local vx_header = "c5BHlllHB"

	local vx_section = "llllI4HHB"

	local dtype = {
		["str"] = function(s)
			return s
		end,
		["u8"] = function(s)
			return s:byte()
		end,
		["u16"] = function(s, e)
			return string.unpack(e.."H", s)
		end,
		["u32"] = function(s, e)
			return string.unpack(e.."I4", s)
		end,
		["u64"] = function(s, e)
			return string.unpack(e.."L", s)
		end,
		["i8"] = function(s, e)
			return string.unpack(e.."b", s)
		end,
		["i16"] = function(s, e)
			return string.unpack(e.."h", s)
		end,
		["i32"] = function(s, e)
			return string.unpack(e.."i4", s)
		end,
		["i64"] = function(s, e)
			return string.unpack(e.."l", s)
		end,
		["bool"] = function(s)
			return s:byte() > 0
		end,
		["f32"] = function(s, e)
			return string.unpack(e.."f", s)
		end,
		["f64"] = function(s, e)
			return string.unpack(e.."d", s)
		end
	}

	function util.velx2(read, seek, close, name)
		-- Read main header.
		local h = read(vx_header:packsize())
		local magic, ver, etest = "<c5BH"
		local endian = "<"
		if (magic ~= "\27VelX" or ver ~= 2) then
			return nil, "not a VELXv2"
		end
		if (etest ~= 0xaa55) then
			endian = ">"
		end
		local sections = {}
		local magic, ver, etest, checksum, flags, main_offset, sec_count, btype = string.unpack(endian .. vx_header, h)
		local csum = xxh.state(0)
		for i=1, sec_count do
			local section = {tags={}}
			local sh = read(vx_section:packsize())
			csum:update(sh)
			section.csum, section.size, section.offset, section.flags, section.id, section.tagcount, section.align, section.namelength = string.pack(endian .. vx_section, sh)
			local name = read(namelength)
			csum:update(name)
			for j=1, section.tagcount do
				local th = read(2)
				csum:update(th)
				local tname = read(th:byte(1))
				local tval = read(th:byte(2))
				csum:update(tname)
				csum:update(tval)
				section.tags[tname] = tval
				local ttype, rtname = tname:match("(.+):(.+)")
				if (dtype[ttype]) then
					section.tags[rtname] = dtype[ttype](tval, endian)
				end
			end
			section.pos = seek()
			local sec_csum = xxh.state(0)
			local ramt = section.size
			while ramt > 0 do
				local spoon = 1024*1024
				if (ramt < spoon) then
					spoon = ramt
				end
				local d = read(spoon)
				csum:update(d)
				sec_csum:update(d)
				ramt = ramt - spoon
			end
			local c_scsum = sec_csum:digest()
			if (c_scsum ~= section.csum) then
				section.invalid = true
				-- some warning here
			end
			sections[#sections+1] = section
		end
		local c_csum = csum:digest()
		if (c_csum ~= checksum) then
			return nil, string.format("checksum mismatch %x ~= %x", c_csum, checksum)
		end
		return setmetatable({
			read = read,
			seek = seek,
			close = close,
			sections = sections,
			flags = flags,
			offset = offset,
			type = btype,
		}, {__index=velx2})
	end

	function velx2:getsection(osid, sec)
		for i=1, #self.sections do
			local sec = self.sections[i]
			if (sec.id == osid and sec.name == name or sec.id == 0) then
				self.seek(sec.pos-self.seek())
				local dat = self.read(sec.size)
				if (sec.tags.compression == "lz4") then
					dat = lz4_decompress(dat)
				end
				return dat
			end
		end
	end

	function velx2:gettag(osid, sec, tag)
		for i=1, #self.sections do
			local sec = self.sections[i]
			if (sec.id == osid and sec.name == name or sec.id == 0) then
				return sec.tags[tag]
			end
		end
	end

	function velx2:getsecinfo(osid, sec)
		for i=1, #self.sections do
			local sec = self.sections[i]
			if (sec.id == osid and sec.name == name or sec.id == 0) then
				return sec
			end
		end
	end

	function velx2:getstream(osid, sec)
		for i=1, #self.sections do
			local sec = self.sections[i]
			if (sec.id == osid and sec.name == name or sec.id == 0) then
				local ptr = 0
				return function(a)
					self.seek((sec.pos+ptr)-self.seek())
					if (ptr+a+1 > sec.size) then
						a = sec.size - ptr
					end
					if (a < 1) then
						return ""
					end
					return self.read(a)
				end, function(a)
					a = a-1 or 0
					ptr = ptr + a
					if (ptr < 0) then
						ptr = 0
					elseif (ptr > sec.size-1) then
						ptr = self.size-1
					end
					return ptr+1
				end, function() end
			end
		end
	end
end
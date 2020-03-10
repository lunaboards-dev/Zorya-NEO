local function foxfs_getnodes(prox, sec)
[]
end

local function foxfs_readnode(prox, sec)
	local dat = prox.readSector(sec)
	local node = {pointers={}}
	local size
	node.size, node.namesize, node.mode, node.user, node.group, node.pointers[1], node.pointers[2], node.pointers[3], node.pointers[4], node.pointers[5], node.pointers[6], node.pointers[7], node.pointers[8], node.pointers[9], node.sip, node.dip, node.tip, size = string.unpack("<i3i1i2i2i2i3i3i3i3i3i3i3i3i3i3i3i3", sec)
	node.name = dat:sub(size+1, size+node.namesize)
	return node
end

local function foxfs_update(prox, sec, data)
	
end
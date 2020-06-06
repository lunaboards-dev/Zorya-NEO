local args = {...}
local tbl = args[1]
local dat = args[2]
table.remove(args, 1)
table.remove(args, 1)

local function getfile(path)
	for i=1, #tbl do
		if (tbl[i].name == path) then
			return dat:sub(tbl[i].pos, tbl[i].pos+tbl[i].filesize-1)
		end
	end
end

if debug.debug then
	for i=1, #tbl do
		print(tbl[i].name, tbl[i].filesize)
	end
	print("Zorya NEO Installer")
	print("This was made for OpenComputers, and, as such, is not compatible with your system.")
	os.exit(0)
end

function lzss_decompress(a)local b,c,d,e,j,i,h,g=1,'',''while b<=#a do
e=c.byte(a,b)b=b+1
for k=0,7 do h=c.sub
g=h(a,b,b)if e>>k&1<1 and b<#a then
i=c.unpack('>I2',a,b)j=1+(i>>4)g=h(d,j,j+(i&15)+2)b=b+1
end
b=b+1
c=c..g
d=h(d..g,-4^6)end
end
return c end

local component = component or require("component")
local computer = computer or require("computer")
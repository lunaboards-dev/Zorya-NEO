--#include "src/lzss.lua"
return assert(load(lzss_decompress($[[luacomp src/zy-neo/zinit.lua -mluamin 2>/dev/null | sed "s/\]\]/]\ ]/g" | lua5.3 utils/makezbios.lua ]]), "=bios.lua"))(lzss_decompress)
--#include "src/lzss.lua"
return assert(load(lzss_decompress(%s), "=bios.lua"))(lzss_decompress)
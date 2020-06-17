--#include "src/lzss.lua"
return assert(load(lzss_decompress(%s), "=BOOTSTRAP.lua"))(lzss_decompress)
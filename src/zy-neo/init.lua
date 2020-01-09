@[[if not svar.get("ZY_PLATFORM") then]]
--#define "ZY_PLATFORM" "managed"
@[[end]]
--#include @[{"src/zy-neo/builtins/init_"..svar.get("ZY_PLATFORM").."/init.lua"}]

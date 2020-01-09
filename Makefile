LC = luacomp

VER_MAJ = 2
VER_MIN = 0
VER_PAT = 0

VER_STR = $(VER_MAJ).$(VER_MIN).$(VER_PAT)
VER_NAME = New and Improved

MODS = $(wildcard mods/*)

release: dirs zyneo modules
	find bin -depth | cpio -o > release.cpio
	gzip -9k release.cpio # Maybe one day.

zyneo: bios
	VER_STR=$(VER_STR) ZYNEO_PLATFORM=$(PLATFORM) $(LC) src/zy-neo/init.lua -O bin/zyneo.lua

bios:
	VER_STR=$(VER_STR) ZYNEO_PLATFORM=$(PLATFORM) $(LC) bsrc/bios/init.lua -O bin/zyneo_bios.lua -mluamin
	if [[ $(shell stat --printf=%s) > 4096 ]]; then \
		echo "Warning! BIOS is over 4KiB!" > &2; \
	fi

modules: $(MODS)

mods/%:
	$(LC) src/lkern/$</init.lua -O bin/mods/$<

dirs:
	mkdir -p bin/mods
{
	-- BIOSes
	@[[function add_bios(bios, name, desc)]]
	["bios_@[{bios}]_name"] = @[{string.format("%q", name)}],
	["bios_@[{bios}]_desc"] = @[{string.format("%q", desc)}],
	@[[end]]
	@[[add_bios("managed", "Low Memory Managed FS Loader", "Loads an image.tsar from a managed filesystem for low memeory systems.")
	add_bios("initramfs", "Initramfs Managed System Loader", "Loads an image.tsar from a managed filesystem straight into memory.")
	add_bios("prom", "OSSM PROM Loader", "Loads an image.tsar from an OSSM PROM.")
	add_bios("osdi", "OSDI Loader", "Loads an image.tsar from an OSDI partition.")]]

	-- Packages.
	@[[function add_pkg(pkg, name, desc)]]
	["mod_@[{pkg}]_name"] = @[{string.format("%q", name)}],
	["mod_@[{pkg}]_desc"] = @[{string.format("%q", desc)}],
	@[[end]]

	@[[add_pkg("fs_arcfs", "Archive FS", "Use an archive as a filesystem.")
	add_pkg("fs_foxfs", "FoxFS", "Load from FoxFS volumes.")
	add_pkg("net_minitel", "Microtel", "Minitel for Zorya NEO!")
	add_pkg("util_cpio", "CPIO archive loader", "Load CPIOs.")
	add_pkg("util_osdi", "OSDI library", "Read and write OSDI partition tables.")
	add_pkg("util_romfs", "RomFS archive loader", "Load RomFS archives.")
	add_pkg("util_urf", "URF Archive loader", "Load the most awful archive format ever")
	add_pkg("util_zlan", "zlan 2.0 library", "Load things from zlan.")
	add_pkg("util_vcomponent", "vComponent", "Virtual components.")
	add_pkg("fs_fat", "FAT12/16 FS", "FAT12/16 filesystem loader.")
	add_pkg("core_io", "io library", "PUC Lua compatible io library.")
	add_pkg("loader_fuchas", "Fuchas kernel loader", "Load Fuchas.")
	add_pkg("loader_openos", "OpenOS loader", "Load OpenOS and compatible OSes.")
	add_pkg("loader_tsuki", "Tsuki kernel loader", "Load the Tsuki kernel.")
	add_pkg("menu_bios", "BIOS Menu", "A menu that looks like a real BIOS.")
	add_pkg("menu_classic", "Zorya 1.x Menu", "The classic Zorya 1.x menu that looks like discount GRUB.")
	add_pkg("util_blkdev", "Block device util", "Block devices in Zorya.")
	add_pkg("util_luaconsole", "Lua Recovery Console", "A Lua recovery console for Zorya.")
	add_pkg("util_oefiv1", "OEFIv1 library", "OEFIv1 library and loader.")
	add_pkg("util_oefiv2", "OEFIv2 and 2.1 library", "Library for loading OEFIv2.x executables.")
	add_pkg("util_searchpaths", "Easy searchpaths", "Easier searchpaths for Zorya.")
	add_pkg("util_velx", "VELX loader", "VELX executable loaders.")
	add_pkg("vdev_vbios", "vBIOS library", "Virtual BIOSes in Zorya!")
	add_pkg("core_vfs", "VFS for Zorya", "Virtual Filesystems")
	]]
}
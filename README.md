# Zorya NEO

## What is Zorya NEO?
Zorya NEO is the successor to the Zorya 1.x series of BIOS+Bootloaders for OpenComputers. It's design is now much more modular and extendable.

## How do I begin?
Grab the latest release. Install the BIOS before the utilities. The install is self-extracting. Don't download the tsar.

## How do I configure it?
Edit /.zy2/cfg.lua or use the OpenOS config generator.

## What modules/libraries are included by default?
* Multithreading (`krequire("thd")`)
* TSAR archive reader (`krequire("util_tsar")`)
* CPIO archive reader (`krequire("util_cpio")`)
* URF archive reader (`krequire("util_urf")`)
* Romfs archive reader (`krequire("util_romfs")`)
* Minitel networking (`krequire("net_minitel")`)
* vComponent (`krequire("util_vcomponent")`)
* OEFIv1 (`loadmod("util_oefiv1")`)
* OEFIv2 (`loadmod("util_oefiv2")`)
* OpenOS loader (`loadmod("loader_openos")`)
* Fuchas loader (`loadmod("loader_fuchas")`)
* vBIOS (`loadmod("vdev_vbios")`)
* Search paths configuration (`loadmod("util_searchpaths")`)
* BIOS info component (`loadmod("vdev_biosdev")`)
* VFS (`loadmod("vfs")`)
* Zorya classic menu (`loadmod("menu_classic")`)

## What's the difference between modules and libraries?
There's not really a hard difference. But libraries shouldn't load modules. Modules can load libraries, though.

<hr>
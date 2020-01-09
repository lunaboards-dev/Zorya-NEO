# Zorya NEO

## What is Zorya NEO?
Zorya NEO is the successor to the Zorya 1.x series of BIOS+Bootloaders for OpenComputers. It's design is now much more modular and extendable.

## How do I begin?
wait till it's stable and i release a zorya-neo-installer cpio

## How do I configure it?
Edit /.zy2/cfg.lua

## What modules/libraries are included by default?
* Microtel (`krequire "net_minitel"`)
* Zorya LAN Boot 2.0 (`krequire "util_zlan"`)
* Classic Zorya Menu (`loadmod "menu_classic"`)
* Threading library (`krequire "thd"`)
* Virtual Devices library (`loadmod "util_vdev"`)

<hr>
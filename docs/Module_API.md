# Module API
Modules should always follow a normal convention
* Libraries should always put their methods in `envs.libraries.your_library_here`
* Only boot modules are allowed to write the the global table
* Boot menu modules should always use the loaded config (under `envs.entries`) for use in booting, default is always specified under `envs.default`.
* Modules are allowed to be OEFIv2.1 applications, with the architecture `zoryamod` and the `minversion` of `2.0`. It should be noted that the microruntime will have to support loading OEFIv2.1 modules
* Modules that are signed should be CPIO-based.
* Microruntimes are required to have a basic CPIO implementation for signed modules, but they do not need to support checking signature integrity
* CPIO-based modules may only have three files: `signature.bin` (The signature of the module, not required), `manifest.ini` (Manifest file, required), and `init.lua` (Module code, required)
* Only binary CPIOs are supported for use as module containers.
* Compression is not supported for modules

## Module manifest
An example module manifest is as follows
```ini
[ZORYA_MOD]
name=Example Module
modver=1.0
minver=2.0
maxver=*
author=Adorable-Catgirl
url=https://github.com/Adorable-Catgirl/Zorya-NEO
; update_url=optional
```

A semicolon at the beginning of the line specifies a comment.

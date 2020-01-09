local menu = {}

local gpu = component.proxy(component.list("gpu")())
gpu.bind(component.list("screen")())

gpu.set(1, 1, "Zorya NEO v2.0 BIOS/Bootloader")
gpu.set(1, 2, "(c) 2020 Adorable-Catgirl")
gpu.set(1, 4, "Memory: "..math.floor(computer.totalMemory()/1024).."K")
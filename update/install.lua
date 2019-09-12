local component = component or require("component")
local computer = computer or require("computer")

local inet = component.proxy(component.list("internet")())
local 
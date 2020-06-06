#!/usr/bin/env sh
luacomp build.lua 2>/dev/null | lua - $@
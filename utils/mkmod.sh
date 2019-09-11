#!/bin/sh
ls $1 | cpio -oD $1 > $2.zyr 2>/dev/null
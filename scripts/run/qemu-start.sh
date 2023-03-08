#!/bin/bash

default_qemu="qemu-system-aarch64"
kernel="./build/kernel.elf"

# opt="-M raspi3b -serial stdio"
opt="-M raspi3b -serial null -serial stdio"

if [ "$1" = "--gdb" ]; then
	opt+=" -s -S" 	
fi
# else
# 	opt+=" -serial null -serial stdio"
# fi

cmd="$default_qemu $opt -kernel $kernel"
echo "$cmd"

$cmd

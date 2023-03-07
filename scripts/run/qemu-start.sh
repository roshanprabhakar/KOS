#!/bin/bash

default_qemu="qemu-system-aarch64"
kernel="./build/kernel.elf"

opt="-M raspi3b"

if [ "$1" = "--kernel" ]; then
	kernel="$2"
elif [ "$1" = "--gdb" ]; then
	opt+=" -s -S -monitor stdio" 	
else
	opt+=" -serial null -serial stdio"
fi

cmd="$default_qemu $opt -kernel $kernel"
echo "$cmd"

$cmd

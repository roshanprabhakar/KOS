#!/bin/bash

gdb="gdb-multiarch"
target_bin="build/kernel.elf"

cmd="$gdb $target_bin -x scripts/run/gdbsetup.gdb"

echo "$cmd"
$cmd

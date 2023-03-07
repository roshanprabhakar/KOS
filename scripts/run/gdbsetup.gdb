target remote host.docker.internal:1234

# Stops threads 2,3,4, they cannot run until switched to and continued.
#	The entry code for these hyper threads is verified to be correct, do not
# change.
set scheduler-locking on

break _start
layout regs

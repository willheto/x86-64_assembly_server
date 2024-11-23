Minimalistic x86-64 assembly web-server for linux.

Works only on 64-bit linux, as windows and 32-bit Linux systems use different system calls.
Also includes pre-build server if you don't wanto to install fasm.

Requirements to build and run:
fasm: https://flatassembler.net/download.php

To build and run:
fasm server.asm
ld server.o
strace ./a.out

Servers spins up to port 8080

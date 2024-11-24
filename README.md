## About the project

Minimalistic x86-64 assembly web-server for linux. 

## Features
1. One ('/') endpoint to serve whatever with GET request. Preset maximum size (to read and write) is 1024 bytes though.
2. Other methods than get return 405

## Getting Started

Works only on 64-bit linux, as windows and 32-bit Linux systems use different system calls. Also includes pre-build server if you don't want yo to install a compiler.


Requirements to build and run:
1. fasm: https://flatassembler.net/download.php

To build and run:
1. fasm server.asm
2. ld server.o
3. strace ./a.out

Servers spins up to port 8080

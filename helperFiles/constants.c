#include <sys/syscall.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
/*
 * These c things are NOT used to compile the code.
 * Only purpose is to act as reference file
 * for syscalls and constants used in the code.
 */
 
// rdi rsi rdx r10 r8 r9
socket = SYS_socket
ad_inet = AF_INET
sock_stream = SOCK_STEAM
bind = SYS_bind
listen = SYS_listen
accept = SYS_accept
read = SYS_read
open = SYS_open
o_rdonly = O_RDONLY
write = SYS_write
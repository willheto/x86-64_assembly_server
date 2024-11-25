format ELF64

public buffer
public _start

extrn parse_request_method


; assigning syscall numbers to variables for readability
; TODO: some syscalls are still using magic numbers instead of variables
socket = 41
af_inet = 2
sock_stream = 1
bind = 49
listen = 50
accept = 43
read = 0
open = 2
o_rdonly = 0
write = 1
fstat = 5

section '.text' executable

; create a socket for ipv4 address family and stream socket type
create_socket:
    push rbp
    mov rbp, rsp     
    mov rdi, af_inet
    mov rsi, sock_stream
    mov rdx, 0
    mov rax, socket
    syscall
    mov rsp, rbp      
    pop rbp   
    ret

bind_to_address:
    push rbp
    mov rbp, rsp
    mov rdi, r12
    mov rsi, address
    mov rdx, 16
    mov rax, bind
    syscall
    mov rsp, rbp      
    pop rbp
    ret

listen_connection:
    push rbp
    mov rbp, rsp
    mov rdi, r12
    mov rsi, 10
    mov rax, listen
    syscall
    mov rsp, rbp      
    pop rbp
    ret

_start:
    call create_socket
    mov r12, rax            ; save the socket file descriptor to use in listen_connection
    call bind_to_address
    call listen_connection
    jmp server_loop         ; now we are ready to accept connections



server_loop:
    call accept_connection

    mov r13, rax
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 1024
    mov rax, read
    syscall

    mov rbx, rax
    call parse_request_method

    ; 0 is undefined method, 1 is GET
    cmp rax, 1
    je get_request
    jmp invalid_request ; return 405 is method is not GET

invalid_request:
    mov rdi, method_not_allowed
    mov rsi, o_rdonly  
    mov rax, open 
    syscall       

    mov rdi, rax
    mov rsi, buffer2
    mov rdx, 1024
    mov rax, read
    syscall

    mov rdi, r13
    mov rsi, buffer2
    mov rdx, rax
    mov rax, write
    syscall

    mov rdi, r13
    mov rax, 3
    syscall

    jmp server_loop


get_request:
    mov rdi, path
    mov rsi, o_rdonly  
    mov rax, open 
    syscall       

    mov rdi, rax
    mov rsi, buffer2
    mov rdx, 1024
    mov rax, read
    syscall

    mov rdi, r13
    mov rsi, buffer2
    mov rdx, rax
    mov rax, write
    syscall

    mov rdi, r13
    mov rax, 3
    syscall

    jmp server_loop

exit_loop:
    mov rax, 60
    mov rdi, 0
    syscall

accept_connection:
    mov ebp, esp
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    mov rax, accept
    syscall
    ret

section '.data' writeable
address:
    dw af_inet
    dw 0x901f
    dd 0
    dq 0
buffer:
    db 1024 dup 0
buffer2:
    db 1024 dup 0
path:
    db 'example.json', 0
method_not_allowed:
    db '405.html', 0

statbuf:
    rb 144


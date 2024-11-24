format ELF64

public _start

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
_start:
    mov rdi, af_inet
    mov rsi, sock_stream
    mov rdx, 0
    mov rax, socket
    syscall

    mov r12, rax

    mov rdi, r12
    mov rsi, address
    mov rdx, 16
    mov rax, bind
    syscall

    mov rdi, r12
    mov rsi, 10
    mov rax, listen
    syscall

    jmp server_loop

initialize_parser:
    mov rsi, buffer
    mov rax, 0
    mov rdx, 5
    mov rcx, 0
    ret

parse_request_method_loop:
    ; check if at end of buffer
    test rdx, rdx
    jz end_loop

    ;load current character
    mov al, byte [rsi]

    inc rcx ; increment character count
    cmp al, 32
    jne not_space
    jmp end_loop

not_space:
    inc rsi
    dec rdx
    jmp parse_request_method_loop

end_loop:
    dec rcx
    mov rdx, rcx
    mov rsi, buffer
    mov rdi, 1
    mov rax, 1
    syscall
    call push_return_value_to_stack
    ret

push_return_value_to_stack:
    ; function prologue
    push rbp             ; Save the caller's base pointer
    mov rbp, rsp         ; Set up the new base pointer for the stack frame
    mov rdx, buffer
    mov eax, 0           ; Initialize return value to 0 === undefined method

    ; Check for "GET" string
    mov al, byte [rdx]   ; Load first byte from buffer
    cmp al, 'G'          ; Compare it to 'G'
    jne .not_equal       ; Jump if not equal
    inc rdx              ; Move to next byte
    
    mov al, byte [rdx]   ; Load second byte from buffer
    cmp al, 'E'          ; Compare it to 'E'
    jne .not_equal       ; Jump if not equal
    inc rdx              ; Move to next byte
    
    mov al, byte [rdx]   ; Load third byte from buffer
    cmp al, 'T'          ; Compare it to 'T'
    jne .not_equal       ; Jump if not equal

    ; String matches "GET"
    mov rax, 1   

    ; function epilogue to restore the stack pointer and return
    mov rsp, rbp       
    pop rbp
    ret

.not_equal:
    mov rsp, rbp         ; Restore the stack pointer
    pop rbp              ; Restore the caller's base pointer
    ret


server_loop:
    call accept_connection

    mov r13, rax
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 1024
    mov rax, read
    syscall

    mov rbx, rax
    call initialize_parser
    call parse_request_method_loop

    ; rax now contains the return value from the parser
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


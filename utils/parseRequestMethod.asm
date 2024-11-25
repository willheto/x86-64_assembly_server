format ELF64

public parse_request_method

extrn buffer

section '.text' executable

initialize_parser:
    push rbp
    mov rbp, rsp
    mov rsi, buffer
    mov rax, 0
    mov rdx, 5
    mov rcx, 0
    mov rsp, rbp      
    pop rbp   
    ret

parse_request_method:
    call initialize_parser
    jmp parse_request_method_loop

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

push_return_value_to_stack:
    push rbp             
    mov rbp, rsp         
    mov rdx, buffer
    mov eax, 0           ; Initialize return value to 0 === undefined method

    ; Check for "GET" string
    mov al, byte [rdx]   
    cmp al, 'G'         
    jne .not_equal       
    inc rdx           
    
    mov al, byte [rdx]   
    cmp al, 'E'        
    jne .not_equal      
    inc rdx              
    
    mov al, byte [rdx]  
    cmp al, 'T'         
    jne .not_equal      

    ; String matches "GET"
    mov rax, 1   

    mov rsp, rbp       
    pop rbp
    ret

.not_equal:
    mov rsp, rbp         
    pop rbp
    ret


end_loop:
    dec rcx
    mov rdx, rcx
    mov rsi, buffer
    mov rdi, 1
    mov rax, 1
    syscall
    call push_return_value_to_stack
    ret


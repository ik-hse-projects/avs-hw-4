global read_uint
global skip_whitespaces
global read_int
global input_fd
global input_mirror

extern seed
extern itoa
extern itoa_buffer

SECTION .rodata
str_expected_number:	db "Expected number, but not found"
str_expected_whitespace:db "Expected whitespace, but not found"
str_newline:	db 10
str_space_nul:	db " "

SECTION .data
input_fd:	dd 00000000H
input_mirror:	dd 0FFFFFFFFH
input_position:	dq 0000000000000000H
input_offset:	dq 0000000000000000H

SECTION .bss
current_chunk:	resb    4096


SECTION .text
read_current:
        movsxd  rdi, dword [rel input_fd]
        xor     r8d, r8d
        cmp     edi, -1
        jz      ?_012
        mov     rax, qword [rel input_position]
        cmp     rax, -1
        jz      ?_012
        lea     rsi, [rel current_chunk]
        sub     rax, qword [rel input_offset]
        movzx   r8d, byte [rsi+rax]
        test    r8b, r8b
        jnz     ?_012
        xor     eax, eax
        mov     edx, 4095
        syscall
        test    rax, rax
        jz      ?_013
        mov     rdx, qword [rel input_position]
        mov     byte [rsi+rax], 0
        movzx   r8d, byte [rel current_chunk]
        mov     qword [rel input_offset], rdx
?_012:  mov     eax, r8d
        ret

?_013:
        mov     qword [rel input_position], -1
        mov     eax, r8d
        ret

        nop

random_in_range:
        mov     rax, qword 5851F42D4C957F2DH
        sub     esi, edi
        xor     edx, edx
        imul    rax, qword [rel seed]
        add     rax, 1
        mov     qword [rel seed], rax
        shr     rax, 33
        div     esi
        lea     eax, [rdx+rdi]
        ret


read_uint_internal:
        cmp     dword [rel input_fd], -1
        jz      random_in_range
        push    r12
        xor     r12d, r12d
        push    rbx
        xor     ebx, ebx
        sub     rsp, 8
        jmp     .loop_enter


.loop_begin:
	add     qword [rel input_position], 1
        lea     edx, [r12+r12*4]
        movsx   eax, al
        mov     ebx, 1
        lea     r12d, [rax+rdx*2-30H]
.loop_enter:
	xor     eax, eax
        call    read_current
        lea     edx, [rax-30H]
        cmp     dl, 9
        jbe     .loop_begin
        test    bl, bl
        jnz     .end
        mov     r8d, 1
        mov     edi, 2
        mov     edx, 30
        lea     rsi, [rel str_expected_number]
        mov     rax, r8
        syscall
        mov     eax, 60
        mov     rdi, r8
        syscall
.end:   add     rsp, 8
        mov     eax, r12d
        pop     rbx
        pop     r12
        ret


read_uint:
        push    r12
        call    read_uint_internal
        cmp     dword [rel input_mirror], -1
        mov     r12d, eax
        jz      ?_018
        mov     edi, eax
        call    itoa
        movsxd  rdi, dword [rel input_mirror]
        lea     rsi, [rel itoa_buffer]
        movsxd  rdx, eax
        mov     eax, 1
        syscall
?_018:  mov     eax, r12d
        pop     r12
        ret


read_int_internal:
        cmp     dword [rel input_fd], -1
        jz      ?_020
        push    rbx
        xor     eax, eax
        mov     ebx, 1
        call    read_current
        cmp     al, 45
        jnz     ?_019
        add     qword [rel input_position], 1
        mov     ebx, 4294967295
?_019:  mov     esi, 4294967295
        xor     edi, edi
        call    read_uint_internal
        imul    eax, ebx
        pop     rbx
        ret


?_020:  jmp     random_in_range


read_int:
        push    r12
        call    read_int_internal
        cmp     dword [rel input_mirror], -1
        mov     r12d, eax
        jz      ?_021
        movsxd  rdi, eax
        call    itoa
        movsxd  rdi, dword [rel input_mirror]
        lea     rsi, [rel itoa_buffer]
        movsxd  rdx, eax
        mov     eax, 1
        syscall
?_021:  mov     eax, r12d
        pop     r12
        ret



skip_whitespaces:
        cmp     dword [rel input_fd], -1
        je      ?_030
        push    rbp
        xor     ebp, ebp
        push    rbx
        lea     rbx, [rel str_newline]
        sub     rsp, 8
        jmp     ?_024


?_022:  cmp     al, 9
        jz      ?_023
        cmp     al, 32
        jnz     ?_026
?_023:  add     qword [rel input_position], 1
        mov     ebp, 1
?_024:  xor     eax, eax
        call    read_current
        cmp     al, 13
        jz      ?_025
        cmp     al, 10
        jnz     ?_022
?_025:  movsxd  rdi, dword [rel input_mirror]
        cmp     edi, -1
        jz      ?_023
        mov     eax, 1
        mov     rsi, rbx
        mov     rdx, rax
        syscall
        jmp     ?_023

?_026:  test    bpl, bpl
        jz      ?_029
?_027:  movsxd  rdi, dword [rel input_mirror]
        cmp     edi, -1
        jz      ?_028
        mov     eax, 1
        lea     rsi, [rel str_space_nul]
        mov     rdx, rax
        syscall
?_028:  add     rsp, 8
        pop     rbx
        pop     rbp
        ret

?_029:  mov     r8d, 1
        mov     edi, 2
        mov     edx, 34
        lea     rsi, [rel str_expected_whitespace]
        mov     rax, r8
        syscall
        mov     eax, 60
        mov     rdi, r8
        syscall
        jmp     ?_027

?_030:  ret

global empty_vec
global push
global length
global selection_sort_by_perimiter
global print_vector
global container_info

extern perimiter_of_shape
extern itoa
extern itoa_buffer
extern print_shape

SECTION .rodata
str_newline:	db 10
str_dot_space:	db ". "

SECTION .data

container_info:
	dd 00000001H, 00000000H
	dd 00000000H, 00000000H




SECTION .text
; -----------------------------------------------------------------------------
empty_vec:
        mov     r10d, 16418
        xor     r9d, r9d
        mov     eax, 9
        xor     edi, edi
        mov     r8, -1
        mov     edx, 3
        mov     rsi, qword 0FFFFFFFFFFFH
        syscall
        mov     rdx, 4215904
        mov     qword [rdx+8H], rax
        mov     qword [rdx], rax
        ret



; -----------------------------------------------------------------------------
push:
        mov     rdx, 4215904
        mov     rax, qword [rdx]
        lea     rcx, [rax+20H]
        mov     qword [rdx], rcx
        ret



; -----------------------------------------------------------------------------
get:
        mov     rdx, 4215904
        mov     rax, rdi
        shl     rax, 5
        add     rax, qword [rdx+8H]
        cmp     qword [rdx], rax
        mov     edx, 0
        cmovbe  rax, rdx
        ret

        nop

; -----------------------------------------------------------------------------
length:
        mov     rdx, 4215904
        mov     rax, qword [rdx]
        sub     rax, qword [rdx+8H]
        sar     rax, 5
        ret



; -----------------------------------------------------------------------------
selection_sort_by_perimiter:
        push    r15
        xor     eax, eax
        push    r14
        push    r13
        push    r12
        push    rbp
        push    rbx
        sub     rsp, 104
        call    length
        test    rax, rax
        je      ?_069
        mov     r12, 4215904
        mov     dword [rsp+14H], 0
        mov     rbp, rax
        xor     r14d, r14d
        mov     rax, qword [r12+8H]

?_066:  shl     r14, 5
        sub     rsp, 32
        lea     r15, [rax+r14]
        mov     qword [rsp+38H], r14
        movdqu  xmm6, oword [r15]
        movups  oword [rsp], xmm6
        movdqu  xmm7, oword [r15+10H]
        movups  oword [rsp+10H], xmm7
        call    perimiter_of_shape
        add     dword [rsp+34H], 1
        movsxd  r14, dword [rsp+34H]
        add     rsp, 32
        movapd  xmm1, xmm0
        mov     r13, r14
        cmp     rbp, r14
        jbe     ?_068
        mov     rbx, r14

?_067:  shl     rbx, 5
        add     rbx, qword [r12+8H]
        movsd   qword [rsp+8H], xmm1
        sub     rsp, 32
        movdqu  xmm4, oword [rbx]
        movups  oword [rsp], xmm4
        movdqu  xmm5, oword [rbx+10H]
        movups  oword [rsp+10H], xmm5
        call    perimiter_of_shape
        movsd   xmm1, qword [rsp+28H]
        add     rsp, 32
        comisd  xmm1, xmm0
        minsd   xmm0, xmm1
        cmova   r15, rbx
        add     r13d, 1
        movapd  xmm1, xmm0
        movsxd  rbx, r13d
        cmp     rbx, rbp
        jc      ?_067
        mov     rax, qword [r12+8H]
        mov     r13, qword [rsp+18H]
        movdqu  xmm3, oword [r15]
        movdqu  xmm2, oword [r15+10H]
        add     r13, rax
        movdqu  xmm1, oword [r13]
        movdqu  xmm0, oword [r13+10H]
        movups  oword [r13], xmm3
        movups  oword [r13+10H], xmm2
        movups  oword [rsp+20H], xmm3
        movups  oword [rsp+30H], xmm2
        movups  oword [rsp+40H], xmm1
        movups  oword [rsp+50H], xmm0
        movups  oword [r15], xmm1
        movups  oword [r15+10H], xmm0
        jmp     ?_066

?_068:  mov     r13, qword [rsp+18H]
        add     r13, qword [r12+8H]
        movdqu  xmm2, oword [r15]
        movdqu  xmm1, oword [r15+10H]
        movdqu  xmm0, oword [r13]
        movdqu  xmm3, oword [r13+10H]
        movups  oword [r13], xmm2
        movups  oword [r13+10H], xmm1
        movups  oword [rsp+20H], xmm2
        movups  oword [rsp+30H], xmm1
        movups  oword [rsp+40H], xmm0
        movups  oword [r15], xmm0
        movups  oword [r15+10H], xmm3
?_069:  add     rsp, 104
        pop     rbx
        pop     rbp
        pop     r12
        pop     r13
        pop     r14
        pop     r15
        ret



; -----------------------------------------------------------------------------
print_vector:
        push    r15
        xor     eax, eax
        push    r14
        push    r13
        push    r12
        push    rbp
        push    rbx
        sub     rsp, 40
        call    length
        test    rax, rax
        je      ?_071
        mov     r12, rax
        lea     r15, [rel str_newline]
        xor     ebx, ebx
        mov     ebp, 1
        lea     r14, [rel str_dot_space]
        lea     r13, [rel itoa_buffer]

?_070:  mov     rdi, rbx
        add     rbx, 1
        call    get
        mov     rdi, rbx
        movdqu  xmm0, oword [rax]
        movdqu  xmm1, oword [rax+10H]
        movups  oword [rsp], xmm0
        movups  oword [rsp+10H], xmm1
        call    itoa
        movsxd  rdi, dword [rel container_info]
        mov     rsi, r13
        movsxd  rdx, eax
        mov     rax, rbp
        syscall
        movsxd  rdi, dword [rel container_info]
        mov     edx, 2
        mov     rax, rbp
        mov     rsi, r14
        syscall
        push    qword [rsp+18H]
        push    qword [rsp+18H]
        push    qword [rsp+18H]
        push    qword [rsp+18H]
        call    print_shape
        mov     rax, rbp
        mov     rsi, r15
        mov     rdx, rbp
        movsxd  rdi, dword [rel container_info]
        syscall
        add     rsp, 32
        cmp     rbx, r12
        jnz     ?_070
?_071:  add     rsp, 40
        pop     rbx
        pop     rbp
        pop     r12
        pop     r13
        pop     r14
        pop     r15
        ret

global itoa
global itoa_buffer

global atoi
global seed

SECTION .bss
itoa_buffer:	resb    24
seed:	resq    1

SECTION .text

itoa:
        mov     rax, rdi
        push    rbp
        lea     rcx, [rel itoa_buffer]
        mov     r11, qword 6666666666666667H
        neg     rax
        test    edi, edi
        push    rbx
        mov     r10, rcx
        mov     ebx, edi
        mov     rsi, rcx
        cmovs   rdi, rax
        xor     r8d, r8d

?_006:  mov     rax, rdi
        mov     r9d, r8d
        add     rsi, 1
        imul    r11
        mov     rax, rdi
        add     r8d, 1
        sar     rax, 63
        sar     rdx, 2
        sub     rdx, rax
        mov     rax, rdi
        lea     rbp, [rdx+rdx*4]
        add     rbp, rbp
        sub     rax, rbp
        mov     rbp, rdi
        mov     rdi, rdx
        add     eax, 48
        mov     byte [rsi-1H], al
        cmp     rbp, 9
        jg      ?_006
        test    ebx, ebx
        js      ?_011
        test    r9d, r9d
        jz      ?_010
?_007:  mov     edx, r9d
        movsxd  rsi, r9d
        jmp     ?_009


?_008:  movsxd  rsi, edx
        movzx   eax, byte [r10+rsi]
?_009:  movzx   edi, byte [rcx]
        sub     edx, 1
        mov     byte [rcx], al
        mov     eax, r9d
        sub     eax, edx
        add     rcx, 1
        mov     byte [r10+rsi], dil
        cmp     edx, eax
        jg      ?_008
?_010:  movsxd  rax, r8d
        mov     byte [r10+rax], 0
        mov     eax, r8d
        pop     rbx
        pop     rbp
        ret


?_011:  lea     eax, [r9+2H]
        movsxd  rdx, r8d
        mov     r9d, r8d
        mov     byte [r10+rdx], 45
        mov     r8d, eax
        mov     eax, 45
        jmp     ?_007

atoi:
        movsx   eax, byte [rdi]
        cmp     al, 45
        jnz     ?_003
        movsx   eax, byte [rdi+1H]
        add     rdi, 1
?_003:  xor     r8d, r8d
        test    al, al
        jz      ?_005

?_004:  add     rdi, 1
        lea     r8d, [r8+rax-30H]
        movsx   eax, byte [rdi]
        test    al, al
        jnz     ?_004
?_005:  mov     eax, r8d
        ret



global _start
global perimiter_of_shape
global print_shape

extern read_uint
extern skip_whitespaces
extern read_int

extern itoa
extern itoa_buffer
extern atoi
extern seed

extern input_fd
extern input_mirror

extern empty_vec
extern push
extern length
extern container_info
extern print_vector
extern selection_sort_by_perimiter

SECTION .rodata

str_finish_input:	db "Finish input with EOF (Ctrl+D). Run with -h for help", 10
str_usage:	db "Usage:", 10
		db "  default: read from stdin, write to stdout.", 10
		db "  -r <seed> to use random values", 10
		db "  -f <filename> to read from file", 10
		db "  -m <filename> to mirror the input to the file", 10
		db "  -o <filename> to set output file", 10
		db "Input format:", 10
		db "  First line contains number of shapes.", 10
		db "  In the following lines shapes are entered.", 10
		db "  All values are separated using whitespace", 10
		db "Shapes:", 10
		db "  Circle:    `1 <color> <x> <y> <radius>`", 10
		db "  Rectangle: `2 <color> <x1> <y1> <x2> <y2>`", 10
		db "             where (x1, y1) is the left-upper corner", 10
		db "             and (x2, y2) is the bottom-left.", 10
		db "  Triangle:  `3 <color> <x1> <y1> <x2> <y2> <x3> <y3>`", 10
		db "Colors:", 10

str_red:	db "red"
str_orange:	db "orange"
str_yellow:	db "yellow"
str_green:	db "green"
str_lightblue:	db "light "
str_blue:	db "blue"
str_purple:	db "purple"
str_unknown:	db "unknown color"

str_inv_option:	db "Invalid option: "

str_dot_space:	db ". "

str_newline:	db 10
str_space:	db " "
str_space_nul:	db " "

str_cant_open:	db "Can't open the file"
str_unknown_opt:db "Unknown option."


str_lbr:	db "("
str_comma_space:db ", "
str_rbr:	db ")"

str_color_eq:	db "color="
str_center_eq:	db ", center="
str_radius_eq:	db ", radius="

str_topleft_eq:	db ", top-left="
str_botright_eq:db ", bottom-right="

str_points_eq:	db ", points="

str_spaced_minus:	db " - "

str_Circle:	db "Circle: "
str_Rectangle:	db "Rectangle: "
str_Triangle:	db "Triangle: "
str_UnknownShape:	db "Unknown shape: "
str_Count:	db "Count: "
str_Data:	db "Data:", 10
str_sorted:	db "Sorted:", 10

M_2PI:	dq 6.283185307179586


SECTION .bss
container:	resb    16

SECTION .text

; -----------------------------------------------------------------------------
main:
        push    r12
        push    rbp
        push    rbx
        sub     rsp, 32
        call    parse_args
        mov     esi, 30
        mov     edi, 1
        call    read_uint
        mov     ebp, eax
        xor     eax, eax
        call    empty_vec
        test    ebp, ebp
        jz      ?_002
        xor     ebx, ebx
        mov     r12, rsp

?_001:  xor     eax, eax
        add     ebx, 1
        call    skip_whitespaces
        mov     rdi, r12
        xor     eax, eax
        call    read_shape
        xor     eax, eax
        call    push
        movdqu  xmm0, oword [rsp]
        movdqu  xmm1, oword [rsp+10H]
        movups  oword [rax], xmm0
        movups  oword [rax+10H], xmm1
        cmp     ebx, ebp
        jnz     ?_001
?_002:  mov     ebx, 1
        movsxd  rdi, dword [rel container_info]
        mov     edx, 7
        lea     rsi, [rel str_Count]
        mov     rax, rbx
        syscall
        xor     eax, eax
        call    length
        mov     rdi, rax
        call    itoa
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel itoa_buffer]
        movsxd  rdx, eax
        mov     rax, rbx
        syscall
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel str_newline]
        mov     rax, rbx
        mov     rdx, rbx
        syscall
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel str_Data]
        mov     edx, 6
        mov     rax, rbx
        syscall
        xor     eax, eax
        call    print_vector
        movsxd  rdi, dword [rel container_info]
        mov     edx, 8
        mov     rax, rbx
        lea     rsi, [rel str_sorted]
        syscall
        xor     eax, eax
        call    selection_sort_by_perimiter
        xor     eax, eax
        call    print_vector
        add     rsp, 32
        xor     eax, eax
        pop     rbx
        pop     rbp
        pop     r12
        ret


; -----------------------------------------------------------------------------
perimiter_of_circle:
        sar     rsi, 32
        pxor    xmm0, xmm0
        cvtsi2sd xmm0, esi
        mulsd   xmm0, qword [rel M_2PI]
        ret



; -----------------------------------------------------------------------------
read_color:
        mov     esi, 7
        mov     edi, 1
        jmp     read_uint

        nop

; -----------------------------------------------------------------------------
print_color:
        mov     eax, edi
        movsxd  rdi, dword [rel container_info]
        cmp     eax, 3
        je      .green
        ja      .purple
        cmp     eax, 1
        je      .oragne
        cmp     eax, 2
        jnz     .red
        mov     eax, 1
        lea     rsi, [rel str_yellow]
        mov     edx, 6
        syscall
        ret


.purple:cmp     eax, 5
        je      .blue
        cmp     eax, 6
        jnz     .lightb
        mov     eax, 1
        lea     rsi, [rel str_purple]
        mov     edx, 6
        syscall
        ret


.red:   test    eax, eax
        jnz     .unknown
        mov     eax, 1
        lea     rsi, [rel str_red]
        mov     edx, 3
        syscall
        ret

.lightb:cmp     eax, 4
        jnz     .unknown
        mov     eax, 1
        lea     rsi, [rel str_lightblue]
        mov     edx, 10
        syscall
        ret


.green: mov     eax, 1
        lea     rsi, [rel str_green]
        mov     edx, 5
        syscall
        ret


.oragne:mov     eax, 1
        lea     rsi, [rel str_orange]
        mov     edx, 6
        syscall
        ret


.blue:  mov     eax, 1
        lea     rsi, [rel str_blue]
        mov     edx, 4
        syscall
        ret


.unknown:
	mov     eax, 1
        lea     rsi, [rel str_unknown]
        mov     edx, 13
        syscall
        ret



; -----------------------------------------------------------------------------
parse_args:
        cmp     edi, 1
        jle     ?_056
        push    r15
        push    r14
        lea     r14, [rsi+10H]
        push    r13
        push    r12
        push    rbp
        push    rbx
        sub     rsp, 8
        mov     rbp, qword [rsi+8H]
        test    rbp, rbp
        je      ?_043

?_038:  cmp     byte [rbp], 45
        jne     ?_045
        movzx   eax, byte [rbp+1H]
        test    al, al
        je      ?_045
        cmp     byte [rbp+2H], 0
        jne     ?_045
        cmp     al, 104
        je      ?_048
?_039:  mov     rdi, qword [r14]
        cmp     al, 111
        je      ?_050
?_040:  jg      ?_044
        cmp     al, 102
        je      ?_053
        cmp     al, 109
        jne     ?_052
        mov     r10d, 2
        mov     esi, 65
        mov     edx, 420
        mov     rax, r10
        syscall
        mov     r8, rax
        test    eax, eax
        jns     ?_041
        mov     ebx, 1
        lea     rsi, [rel str_cant_open]
        mov     edx, 19
        mov     rdi, r10
        mov     rax, rbx
        syscall
        mov     eax, 60
        mov     rdi, rbx
        syscall
?_041:  mov     dword [rel input_mirror], r8d
?_042:  mov     rbp, qword [r14+8H]
        add     r14, 16
        test    rbp, rbp
        jne     ?_038
?_043:  add     rsp, 8
        pop     rbx
        pop     rbp
        pop     r12
        pop     r13
        pop     r14
        pop     r15
        ret


?_044:  cmp     al, 114
        jne     ?_052
        call    atoi
        mov     dword [rel input_fd], -1
        cdqe
        sub     rax, 1
        mov     qword [rel seed], rax
        jmp     ?_042


?_045:  mov     eax, 1
        mov     edi, 2
        xor     edx, edx
        lea     rsi, [rel str_inv_option]
        syscall
        cmp     byte [rbp], 0
        je      ?_055
        mov     rdx, rbp

?_046:  add     rdx, 1
        cmp     byte [rdx], 0
        jnz     ?_046
        sub     rdx, rbp
?_047:  mov     r8d, 1
        mov     edi, 2
        mov     rsi, rbp
        mov     rax, r8
        syscall
        mov     eax, 60
        mov     rdi, r8
        syscall
        movzx   eax, byte [rbp+1H]
        cmp     al, 104
        jne     ?_039
?_048:  mov     eax, 1
        mov     edx, 602
        mov     dword [rel container_info], 1
        lea     rsi, [rel str_usage]
        mov     rdi, rax
        syscall
        lea     r13, [rel itoa_buffer]
        mov     r15d, 1
        mov     ebx, 1
        nop
?_049:  mov     r12d, 2
        mov     rax, rbx
        mov     rdi, rbx
        lea     rsi, [rel str_space]
        mov     rdx, r12
        syscall
        mov     rdi, r15
        call    itoa
        mov     rdi, rbx
        mov     rsi, r13
        movsxd  rdx, eax
        mov     rax, rbx
        syscall
        lea     rsi, [rel str_dot_space]
        mov     rax, rbx
        mov     rdx, r12
        syscall
        mov     edi, r15d
        call    print_color
        mov     rax, rbx
        mov     rdi, rbx
        mov     rdx, rbx
        lea     rsi, [rel str_newline]
        syscall
        add     r15, 1
        cmp     r15, 7
        jnz     ?_049
        mov     eax, 60
        xor     edi, edi
        syscall
        movzx   eax, byte [rbp+1H]
        mov     rdi, qword [r14]
        cmp     al, 111
        jne     ?_040

?_050:  mov     r10d, 2
        mov     esi, 65
        mov     edx, 420
        mov     rax, r10
        syscall
        mov     r8, rax
        test    eax, eax
        jns     ?_051
        mov     ebx, 1
        lea     rsi, [rel str_cant_open]
        mov     edx, 19
        mov     rdi, r10
        mov     rax, rbx
        syscall
        mov     eax, 60
        mov     rdi, rbx
        syscall
?_051:  mov     dword [rel container_info], r8d
        jmp     ?_042


?_052:  mov     r8d, 1
        mov     edi, 2
        mov     edx, 14
        lea     rsi, [rel str_unknown_opt]
        mov     rax, r8
        syscall
        mov     eax, 60
        mov     rdi, r8
        syscall
        jmp     ?_042


?_053:  mov     r10d, 2
        xor     esi, esi
        mov     edx, 420
        mov     rax, r10
        syscall
        mov     r8, rax
        test    eax, eax
        jns     ?_054
        mov     ebx, 1
        lea     rsi, [rel str_cant_open]
        mov     edx, 19
        mov     rdi, r10
        mov     rax, rbx
        syscall
        mov     eax, 60
        mov     rdi, rbx
        syscall
?_054:  mov     dword [rel input_fd], r8d
        jmp     ?_042


?_055:  xor     edx, edx
        jmp     ?_047

?_056:
        mov     eax, 1
        lea     rsi, [rel str_finish_input]
        mov     edx, 53
        mov     rdi, rax
        syscall
        mov     dword [rel input_fd], 0
        ret



; -----------------------------------------------------------------------------
distance_between:
        mov     eax, esi
        sar     rsi, 32
        pxor    xmm0, xmm0
        sub     eax, edi
        sar     rdi, 32
        sub     esi, edi
        imul    eax, eax
        imul    esi, esi
        add     esi, eax
        cvtsi2sd xmm0, esi
        sqrtsd  xmm0, xmm0
        ret



; -----------------------------------------------------------------------------
read_point:
        push    rbx
        mov     esi, 2147483647
        xor     edi, edi
        call    read_int
        mov     ebx, eax
        xor     eax, eax
        call    skip_whitespaces
        mov     esi, 2147483647
        xor     edi, edi
        call    read_int
        mov     rdx, rax
        mov     eax, ebx
        pop     rbx
        shl     rdx, 32
        or      rax, rdx
        ret

; -----------------------------------------------------------------------------
read_circle:
        push    rbp
        xor     eax, eax
        push    rbx
        sub     rsp, 8
        call    read_color
        mov     ebp, eax
        xor     eax, eax
        call    skip_whitespaces
        xor     eax, eax
        call    read_point
        mov     rbx, rax
        xor     eax, eax
        call    skip_whitespaces
        mov     esi, 4294967295
        xor     edi, edi
        call    read_uint
        mov     rcx, rbx
        add     rsp, 8
        shr     rbx, 32
        mov     edx, eax
        shl     rcx, 32
        mov     eax, ebp
        shl     rdx, 32
        or      rax, rcx
        or      rdx, rbx
        pop     rbx
        pop     rbp
        ret



; -----------------------------------------------------------------------------
print_point:
        push    r12
        lea     rsi, [rel str_lbr]
        push    rbp
        mov     rbp, rdi
        movsxd  rdi, dword [rel container_info]
        push    rbx
        mov     ebx, 1
        mov     rax, rbx
        mov     rdx, rbx
        syscall
        mov     rdi, rbp
        lea     r12, [rel itoa_buffer]
        sar     rdi, 32
        call    itoa
        movsxd  rdi, dword [rel container_info]
        mov     rsi, r12
        movsxd  rdx, eax
        mov     rax, rbx
        syscall
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel str_comma_space]
        mov     edx, 2
        mov     rax, rbx
        syscall
        movsxd  rdi, ebp
        call    itoa
        movsxd  rdi, dword [rel container_info]
        mov     rsi, r12
        movsxd  rdx, eax
        mov     rax, rbx
        syscall
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel str_rbr]
        mov     rax, rbx
        mov     rdx, rbx
        syscall
        pop     rbx
        pop     rbp
        pop     r12
        ret



; -----------------------------------------------------------------------------
print_circle:
        push    r13
        mov     edx, 6
        push    r12
        mov     r12d, 1
        push    rbp
        mov     rax, r12
        mov     rbp, rdi
        push    rbx
        mov     rbx, rsi
        lea     rsi, [rel str_color_eq]
        sub     rsp, 8
        movsxd  rdi, dword [rel container_info]
        syscall
        mov     r13d, 9
        mov     edi, ebp
        call    print_color
        movsxd  rdi, dword [rel container_info]
        mov     rax, r12
        mov     rdx, r13
        lea     rsi, [rel str_center_eq]
        syscall
        mov     rdi, rbx
        shr     rbp, 32
        shl     rdi, 32
        or      rdi, rbp
        call    print_point
        movsxd  rdi, dword [rel container_info]
        mov     rax, r12
        mov     rdx, r13
        lea     rsi, [rel str_radius_eq]
        syscall
        sar     rbx, 32
        mov     rdi, rbx
        call    itoa
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel itoa_buffer]
        movsxd  rdx, eax
        mov     rax, r12
        syscall
        add     rsp, 8
        pop     rbx
        pop     rbp
        pop     r12
        pop     r13
        ret



; -----------------------------------------------------------------------------
read_rectangle:
        push    r12
        xor     eax, eax
        mov     r12, rdi
        push    rbp
        push    rbx
        call    read_color
        mov     ebp, eax
        xor     eax, eax
        call    skip_whitespaces
        xor     eax, eax
        call    read_point
        mov     rbx, rax
        xor     eax, eax
        call    skip_whitespaces
        xor     eax, eax
        call    read_point
        mov     dword [r12], ebp
        mov     qword [r12+4H], rbx
        pop     rbx
        mov     qword [r12+0CH], rax
        pop     rbp
        mov     rax, r12
        pop     r12
        ret



; -----------------------------------------------------------------------------
print_rectangle:
        push    rbx
        mov     ebx, 1
        mov     edx, 6
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel str_color_eq]
        mov     rax, rbx
        syscall
        mov     edi, dword [rsp+10H]
        call    print_color
        movsxd  rdi, dword [rel container_info]
        mov     edx, 11
        mov     rax, rbx
        lea     rsi, [rel str_topleft_eq]
        syscall
        mov     rdi, qword [rsp+14H]
        call    print_point
        movsxd  rdi, dword [rel container_info]
        mov     edx, 15
        mov     rax, rbx
        lea     rsi, [rel str_botright_eq]
        syscall
        mov     rdi, qword [rsp+1CH]
        pop     rbx
        jmp     print_point



; -----------------------------------------------------------------------------
perimiter_of_rectangle:
        mov     eax, dword [rsp+14H]
        add     eax, dword [rsp+18H]
        sub     eax, dword [rsp+10H]
        sub     eax, dword [rsp+0CH]
        add     eax, eax
        ret



; -----------------------------------------------------------------------------
read_triangle:
        push    r12
        xor     eax, eax
        mov     r12, rdi
        push    rbp
        push    rbx
        call    read_color
        xor     eax, eax
        call    skip_whitespaces
        xor     eax, eax
        call    read_point
        mov     rbp, rax
        xor     eax, eax
        call    skip_whitespaces
        xor     eax, eax
        call    read_point
        mov     rbx, rax
        xor     eax, eax
        call    skip_whitespaces
        xor     eax, eax
        call    read_point
        mov     qword [r12+4H], rbp
        mov     qword [r12+0CH], rbx
        pop     rbx
        mov     qword [r12+14H], rax
        pop     rbp
        mov     rax, r12
        mov     dword [r12], 0
        pop     r12
        ret



; -----------------------------------------------------------------------------
read_shape:
        push    r12
        mov     esi, 4
        mov     r12, rdi
        mov     edi, 1
        push    rbx
        sub     rsp, 72
        call    read_uint
        mov     ebx, eax
        xor     eax, eax
        call    skip_whitespaces
        cmp     ebx, 2
        jz      ?_057
        cmp     ebx, 3
        je      ?_059
        cmp     ebx, 1
        jz      ?_058
        add     rsp, 72
        mov     rax, r12
        pop     rbx
        pop     r12
        ret

?_057:  mov     rdi, rsp
        xor     eax, eax
        call    read_rectangle
        mov     eax, dword [rsp+10H]
        movdqu  xmm3, oword [rsp]
        mov     qword [rsp+38H], 0
        mov     dword [rsp+20H], 2
        mov     dword [rsp+34H], eax
        mov     rax, r12
        movups  oword [rsp+24H], xmm3
        movdqu  xmm4, oword [rsp+20H]
        movdqu  xmm5, oword [rsp+30H]
        movups  oword [r12], xmm4
        movups  oword [r12+10H], xmm5
        add     rsp, 72
        pop     rbx
        pop     r12
        ret


?_058:  xor     eax, eax
        call    read_circle
        pxor    xmm0, xmm0
        mov     dword [rsp+20H], 1
        mov     qword [rsp+24H], rax
        mov     rax, r12
        movups  oword [rsp+30H], xmm0
        mov     qword [rsp+2CH], rdx
        movdqu  xmm1, oword [rsp+20H]
        movdqu  xmm2, oword [rsp+30H]
        movups  oword [r12], xmm1
        movups  oword [r12+10H], xmm2
        add     rsp, 72
        pop     rbx
        pop     r12
        ret


?_059:  mov     rdi, rsp
        xor     eax, eax
        call    read_triangle
        mov     rax, qword [rsp+10H]
        movdqu  xmm6, oword [rsp]
        mov     dword [rsp+20H], 3
        mov     qword [rsp+34H], rax
        mov     eax, dword [rsp+18H]
        movups  oword [rsp+24H], xmm6
        movdqu  xmm7, oword [rsp+20H]
        mov     dword [rsp+3CH], eax
        movdqu  xmm0, oword [rsp+30H]
        mov     rax, r12
        movups  oword [r12], xmm7
        movups  oword [r12+10H], xmm0
        add     rsp, 72
        pop     rbx
        pop     r12
        ret



; -----------------------------------------------------------------------------
print_triangle:
        push    r12
        movsxd  rdi, dword [rel container_info]
        mov     edx, 6
        lea     rsi, [rel str_color_eq]
        push    rbp
        push    rbx
        mov     ebx, 1
        mov     rax, rbx
        syscall
        mov     edi, dword [rsp+20H]
        call    print_color
        movsxd  rdi, dword [rel container_info]
        mov     edx, 9
        mov     rax, rbx
        lea     rsi, [rel str_points_eq]
        syscall
        mov     rdi, qword [rsp+24H]
        lea     rbp, [rel str_spaced_minus]
        mov     r12d, 3
        call    print_point
        mov     rax, rbx
        mov     rsi, rbp
        mov     rdx, r12
        movsxd  rdi, dword [rel container_info]
        syscall
        mov     rdi, qword [rsp+2CH]
        call    print_point
        mov     rax, rbx
        mov     rsi, rbp
        mov     rdx, r12
        movsxd  rdi, dword [rel container_info]
        syscall
        mov     rdi, qword [rsp+34H]
        pop     rbx
        pop     rbp
        pop     r12
        jmp     print_point



; -----------------------------------------------------------------------------
print_shape:
        push    rbx
        mov     r8d, dword [rsp+10H]
        movsxd  rdi, dword [rel container_info]
        cmp     r8d, 2
        jz      ?_060
        cmp     r8d, 3
        je      ?_062
        cmp     r8d, 1
        jz      ?_061
        mov     ebx, 1
        lea     rsi, [rel str_UnknownShape]
        mov     edx, 15
        mov     rax, rbx
        syscall
        mov     edi, r8d
        call    itoa
        movsxd  rdi, dword [rel container_info]
        lea     rsi, [rel itoa_buffer]
        movsxd  rdx, eax
        mov     rax, rbx
        syscall
        pop     rbx
        ret


?_060:  mov     eax, 1
        lea     rsi, [rel str_Rectangle]
        mov     edx, 11
        syscall
        sub     rsp, 32
        movdqu  xmm0, oword [rsp+34H]
        mov     eax, dword [rsp+44H]
        movups  oword [rsp], xmm0
        mov     dword [rsp+10H], eax
        call    print_rectangle
        add     rsp, 32
        pop     rbx
        ret


?_061:  mov     eax, 1
        lea     rsi, [rel str_Circle]
        mov     edx, 8
        syscall
        mov     rdi, qword [rsp+14H]
        mov     rsi, qword [rsp+1CH]
        pop     rbx
        jmp     print_circle


?_062:  mov     eax, 1
        lea     rsi, [rel str_Triangle]
        mov     edx, 10
        syscall
        sub     rsp, 32
        mov     rax, qword [rsp+44H]
        movdqu  xmm1, oword [rsp+34H]
        mov     qword [rsp+10H], rax
        mov     eax, dword [rsp+4CH]
        movups  oword [rsp], xmm1
        mov     dword [rsp+18H], eax
        call    print_triangle
        add     rsp, 32
        pop     rbx
        ret



; -----------------------------------------------------------------------------
perimiter_of_triangle:
        sub     rsp, 24
        mov     rsi, qword [rsp+2CH]
        mov     rdi, qword [rsp+24H]
        call    distance_between
        mov     rsi, qword [rsp+34H]
        mov     rdi, qword [rsp+2CH]
        movsd   qword [rsp+8H], xmm0
        call    distance_between
        movsd   xmm1, qword [rsp+8H]
        mov     rsi, qword [rsp+24H]
        mov     rdi, qword [rsp+34H]
        addsd   xmm1, xmm0
        movsd   qword [rsp+8H], xmm1
        call    distance_between
        addsd   xmm0, qword [rsp+8H]
        add     rsp, 24
        cvttsd2si eax, xmm0
        ret



; -----------------------------------------------------------------------------
perimiter_of_shape:
        sub     rsp, 8
        mov     eax, dword [rsp+10H]
        cmp     eax, 2
        jz      ?_063
        cmp     eax, 3
        jz      ?_065
        cmp     eax, 1
        jz      ?_064
        add     rsp, 8
        ret


?_063:  sub     rsp, 32
        movdqu  xmm1, oword [rsp+34H]
        mov     eax, dword [rsp+44H]
        movups  oword [rsp], xmm1
        mov     dword [rsp+10H], eax
        call    perimiter_of_rectangle
        pxor    xmm0, xmm0
        add     rsp, 32
        cvtsi2sd xmm0, eax
        add     rsp, 8
        ret


?_064:  mov     rdi, qword [rsp+14H]
        mov     rsi, qword [rsp+1CH]
        add     rsp, 8
        jmp     perimiter_of_circle


?_065:  sub     rsp, 32
        mov     rax, qword [rsp+44H]
        movdqu  xmm2, oword [rsp+34H]
        mov     qword [rsp+10H], rax
        mov     eax, dword [rsp+4CH]
        movups  oword [rsp], xmm2
        mov     dword [rsp+18H], eax
        call    perimiter_of_triangle
        pxor    xmm0, xmm0
        add     rsp, 32
        cvtsi2sd xmm0, eax
        add     rsp, 8
        ret



_start:
        mov     rdi, qword [rsp]
        mov     rsi, rsp
        add     rsi, 8
        call    main
        mov     eax, 60
        xor     edi, edi
        syscall
        add     rsp, 8
        ret



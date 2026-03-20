section .data
	fmt_string	db "My name is %s", 0x0a
	string_to_print	db "Sergey"

section .text
	global _start

_start:
	mov rdi, fmt_string
	; push 'y'
	; mov r9, 'e'
	; mov r8, 'g'
	; mor rcx, 'r'
	; mov rdx, 'e'
	mov rsi, string_to_print
	call my_printf
	; add rsp, 8 	; because there was one argument in stack
	
	mov rax, 0x3c	; syscall exit code 
	xor rdi, rdi	
	syscall

; rax - return code
; args: rdi rsi rdx rcx r8 r9 stack

; my_printf(const char* format, ...)
; rdi - ptr on fmt_string
; rbx - address for loop (string), r12 - changing rsp
my_printf:
	push r9
	push r8
	push rcx
	push rdx
	push rsi

	; after that stack looks like that
	; (registers mean chars in them):
	; rsi rdx rcx r8  r9 RETURN_ADDRESS 'y' ...
	;  |   |   |   |   |       |         |
	; rsp rsp rsp rsp rsp     rsp       rsp
	;      +   +   +   +       +         +
	;      8   16  24  32      40        48
	; we don't need to return symbols to registers
	; so we will just jump over return address
	; and change rsp in the end of executing function

	mov rbx, rdi	; because rdi is used for syscalls
	mov r12, rsp	; changing rsp is kinda like shit
	mov r14, 0 	; counter of %
.loop:
	mov al, [rbx]	; move symbol of format string to 1 byte register
	cmp al, 0	; is it the end of string?
	jz .end_of_string
	
	cmp al, '%'	; is it %?
	jne .skip_call

	inc r14		; increase count of %

	mov rax, 0x1	; syscall write code
	mov rdi, 1	; stdout
	mov rsi, r12	; pointer to symbol from arguments
	mov rdx, 1	; count of writing symbols
	syscall

	add r12, 8	; come to next argument in stack

	cmp r14, 5	; 5 arguments are given in registers and pushed after calling
	jne .skip_jump_over_ret
	add r12, 8	; jump over return address

.skip_jump_over_ret:
	add rbx, 2	; skip '%' and symbol after it
	jmp .loop	; continue string processing

.skip_call:
	mov rax, 0x1	; syscall write code
	mov rdi, 1	; stdout
	mov rsi, rbx	; pointer on printing buffer
	mov rdx, 1	; count of writing symbols
	syscall

	inc rbx		; go to next symbol in format string
	jmp .loop	; continue string processing

.end_of_string:
	add rsp, 40	; return stack pointer to return address
	ret


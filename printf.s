section .data
	fmt_string	db "My name is %c%c%c%c%c%c", 0x0a

section .text
	global _start

_start:
	mov rdi, fmt_string
	mov rsi, 'S'
	mov rdx, 'e'
	mov rcx, 'r'
	mov r8, 'g'
	mov r9, 'e'
	push 'y'
	call my_printf
	add rsp, 8

	mov rax, 0x3c
	xor rdi, rdi
	syscall

; rax - return code
; args: rdi rsi rdx rcx r8 r9 stack
; unused: rbx rcx r11 (NO! mov r11, RFLAGS) r12 r13 r14 r15

; my_printf(const char* format, ...)
; rdi - ptr on fmt_string, rsi - expected char
; rbx - address for loop (string), r12 - changing rsp
my_printf:
	push r9
	push r8
	push rcx
	push rdx
	push rsi

	; after that stack looks like that
	; (registers mean chars in them):
	; rsi rdx rcx r8 r9 RETURN_ADDRESS 'y' ...
	; /\
	; rsp in the beginning
	; we don't need to return symbols to registers
	; so we will just jump over return address
	; and change rsp in the end of executing function

	mov rbx, rdi
	mov r12, rsp
	mov r14, 0 ; counter of %c-s
.loop:
	mov al, [rbx]
	cmp al, 0
	jz .end_of_string
	
	cmp al, '%'
	jne .skip_call

	inc r14

	mov rax, 0x1
	mov rdi, 1
	mov rsi, r12
	mov rdx, 1
	syscall

	add r12, 8

	cmp r14, 5
	jne .skip_jump_over_ret
	add r12, 8

.skip_jump_over_ret:
	add rbx, 2
	jmp .loop

.skip_call:
	mov rax, 0x1
	mov rdi, 1
	mov rsi, rbx
	mov rdx, 1
	syscall

	inc rbx
	jmp .loop

.end_of_string:
	add rsp, 40
	ret


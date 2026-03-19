section .data
	fmt_string	db "First letter of my name is %c", 0x0a

section .text
	global _start

_start:
	mov rdi, fmt_string
	mov rsi, 'S'
	call my_printf

	mov rax, 0x3c
	xor rdi, rdi
	syscall

; rax - return code
; args: rdi rsi rdx r10 r8 r9 stack
; unused: rbx rcx (NO! mov rcx, rip) r11 (NO! mov r11, RFLAGS) r12 r13 r14 r15

; my_printf(const char* format, ...)
; rdi - ptr on fmt_string, rsi - expected char
; rbx - address for loop, r12 - constant storage for char code
my_printf:
	; rdi -> rbx
	; rsi -> r12

	mov rbx, rdi
	mov r12, rsi
.loop:
	mov al, [rbx]
	cmp al, 0
	jz .end_of_string
	
	cmp al, '%'
	jne .skip_call

	push r12
	mov rsi, rsp
	call print_symbol
	pop r12
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
	ret
	
; print_symbol(char* symbol)
; rsi - pointer on char buffer
print_symbol:
	mov rax, 0x1
	mov rdi, 1
	mov rdx, 1
	syscall

	ret


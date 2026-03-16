section .bss
	buffer resb 64

section .text
	global _start

_start:
	mov rax, 0x0
	mov rdi, 0
	mov rsi, buffer
	mov rdx, 64
	syscall

	mov rax, 0x1
	mov rdi, 1
	mov rsi, buffer
	mov rdx, 64
	syscall

	mov rax, 0x3c
	xor rdi, rdi
	syscall

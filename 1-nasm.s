section .text
global _start
_start:
	mov rax, 0x01
	mov rdi, 1
	mov rsi, msg
	mov rdx, msglen
	syscall

	mov rax, 0x3c
	xor rdi, rdi
	syscall

section .data
msg: db "Hello, World!", 0x0a
msglen: equ $ - msg

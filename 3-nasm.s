section .data
	filename	db "test.txt", 0
	fmt		db "Seconds since epoch (birth): %llu", 10, 0

section .bss
	statx_buf	resb 256

section .text
	global main
	extern printf

main:
	push rbp
	mov rbp, rsp

	mov rax, 332
	mov rdi, -100
	lea rsi, [filename]
	xor rdx, rdx
	mov r10, 0x800
	lea r8, [statx_buf]
	syscall

	test rax, rax
	js error

	mov rsi, [statx_buf + 152]

	lea rdi, [fmt]
	xor rax, rax
	call printf

error:
	mov rsp, rbp
	pop rbp
	mov rax, 60
	xor rdi, rdi
	syscall

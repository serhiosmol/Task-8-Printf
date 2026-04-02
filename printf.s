global my_printf
; global _start

section .bss
	output_buffer	resb 256
	; dec_buffer	resb 12

; section .data
	; fmt_string	db "My name is %s%c", 0x0a, 0
	; str1		db "Sergey", 0

section .text

; _start:
	; mov rdi, fmt_string
	; mov rdx, '!'
	; mov rsi, str1
	; call my_printf

	; mov rax, 0x3c	; syscall exit code
	; xor rdi, rdi
	; syscall

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

	mov rbx, rdi	; because rdi is used for syscalls
	lea r12, [rsp]
	lea r13, [rel output_buffer] 	; ptr on symbol in output_buffer
	xor r14, r14	; counter of %
.loop:
	mov al, [rbx]	; move symbol of format string to 1 byte register
	test al, al	; is it the end of string?
	jz .end_of_string

	cmp al, '%'	; is it %?
	jne .skip_call

	inc rbx
	mov al, [rbx]	; we need to check symbol after %
	cmp al, 'c'
	je .processing_char	; going to process char (%c)
	cmp al, 's'
	je .processing_string	; going to process string (%s)
	; cmp al, 'd'
	; je .processing_dec
	jmp .skip_call	; skip processing if the format is unknown

.processing_char:
	mov rax, [r12]
	mov byte [r13], al
	inc r13

	add r12, 8	; going to next argument in stack
	inc r14		; increase count of wrote arguments
	jmp .after_processing

.processing_string:
	mov rsi, [r12]	; in stack it's like char** str, so here char* rsi = *str

.copy_string:
	mov al, byte [rsi]
	test al, al
	je .done_copy

	mov [r13], al
	inc r13
	inc rsi
	jmp .copy_string

.done_copy:
	add r12, 8	; going to next argument in stack
	inc r14		; increase count of wrote arguments
	jmp .after_processing

; .processing_dec:
	; mov eax, [r12]
	; cmp rax, 0
	; jge .positive

	; mov byte [r13], '-'
	; inc r13
	; neg rax

; .positive:
	; xor edx, edx 	;
	; mov di, 10
	; div di

.after_processing:
	cmp r14, 5	; 5 arguments are given in registers and pushed after calling
	jne .skip_jump_over_ret
	add r12, 8	; jump over return address

.skip_jump_over_ret:
	inc rbx		; going to next symbol after format
	jmp .loop	; continue string processing

.skip_call:
	mov byte [r13], al	; add symbol to output buffer
	inc r13		; go to next symbol in output buffer
	inc rbx		; go to next symbol in format string
	jmp .loop	; continue string processing

.end_of_string:
	mov rax, 1
	mov rdi, 1
	lea rsi, [rel output_buffer]
	mov rdx, r13
	sub rdx, rsi
	syscall

	pop rsi
	pop rdx
	pop rcx
	pop r8
	pop r9

	xor rax, rax
	ret


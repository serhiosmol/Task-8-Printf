global printf

section .bss
outbuf	resb 256

section .text
printf:
; Push args to the stack for convenience
	push r9
	push r8
	push rcx
	push rdx
	push rsi

	lea r12, [rsp]		; current argument pointer
	lea r13, [rel outbuf] 	; ptr on char in outbuf
	xor r14, r14		; counter of %
.loop:	mov al, [rdi]		; store current char
	test al, al		; end of string?
	je .write		; we've done

	cmp al, '%'		; is it %?
	jne .default

; We've met a start of control sequence, let's check follows it
	inc rdi
	mov al, [rdi]		; the char after %

	cmp al, 'c'		; char?
	je .char

	cmp al, 's'		; string?
	je .str

	jmp short .default
.char:	mov rax, [r12]		; the char will be copied to the output
	jmp short .next_arg	; buffer before the next loop iteration
.str:	mov rsi, [r12]		; string start address -> rsi
.copy:	mov al, [rsi]
	test al, al		; end of string?
	je .next_arg
	mov [r13], al
	inc r13			; inc the bytes written
	inc rsi			; next char in the string
	jmp short .copy
.next_arg:
	add r12, 8		; next from the stack
	inc r14			; inc count of wrote args
.default:
	mov [r13], al		; add char to output buffer
	inc r13			; next char in output buffer
	inc rdi			; next char in format string
	jmp .loop		; continue string processing
.write:	mov rax, 1		; write syscall
	mov rdi, 1		; stdout
	lea rsi, [rel outbuf]	; outbuf
	mov rdx, r13
	sub rdx, rsi		; now len in rdx
	push rdx		; save it for future
	syscall

	pop rax			; return chars printed
	add rsp, 5 * 8		; we've appended 5 args earlier
	ret

global printf

; convert int of base 2-36
; args: %1: integer, %2: target buffer, %3: power
; ret: rax: bytes written
%macro int2str 3
	push %2			; save for future
	push %2
	push %1
	pop rax			; given integer
	pop rcx			; buf addr
	test rax, rax		; 0?
	jge %%lp
	mov byte [rcx], '-'	; write sign in buf
	inc rcx			; count it
	neg rax
%%lp:	test rax, rax		; 0?
	jz %%lpq
; Don't use div for powers of 2
%if %3 = 2 || %3 = 4 || %3 = 8 || %3 = 16
	mov rdx, rax
	and rdx, %3 - 1		; current digit
%if %3 = 2
	shr rax, 1
%elif %3 = 4
	shr rax, 2
%elif %3 = 8
	shr rax, 3
%elif %3 = 16
	shr rax, 4
%elif %3 = 32
	shr rax, 5
%endif
%elif 3 <= %3 && %3 <= 36
	mov r8, %3		; base -> r8 for division
	xor rdx, rdx		; := 0
	div r8
%else
  %error Base of %3 is not supported.
%endif
	cmp dl, 9
	jg %%hex
	add dl, '0'		; digit to char
	jmp short %%dump
%%hex:	add dl, 'a' - 10	; digit to char
%%dump:	mov byte [rcx], dl	; write digit into buffer
	inc rcx			; count it
	jmp short %%lp
%%lpq:	pop rax			; load buf start addr
	mov rdx, rcx
	sub rcx, rax		; count of written bytes -> rcx
	push rcx		; save it to return further
	shr rcx, 1		; we need / 2 swaps
	jrcxz %%quit		; nothing to reverse
	dec rdx			; last char addr -> rdx
%%rev:	mov r8b, [rax]
	mov r9b, [rdx]
	mov [rdx], r8b
	mov [rax], r9b
	inc rax
	dec rdx
	loop %%rev
%%quit:	pop rax			; return bytes written
%endmacro

section .bss
outbuf	resb 256

section .rodata

index:	times 'b' db 255
	db 0
	db 1
	db 2
	times ('o' - 'd' - 1) db 255
	db 3
	times ('s' - 'o' - 1) db 255
	db 4
	times ('x' - 's' - 1) db 255
	db 5
	times (256 - 'x' - 1) db 255

align 8
jmptbl:	dq bin - jmptbl
	dq char - jmptbl
	dq dec - jmptbl
	dq oct - jmptbl
	dq str - jmptbl
	dq hex - jmptbl

section .text
printf:
; Push args to the stack for convenience
	push r9
	push r8
	push rcx
	push rdx
	push rsi
	push rbp
	lea rbp, [rsp + 8]	; current argument pointer
	push r13
	push r14
	push rbx
	
	lea r13, [rel outbuf] 	; ptr on char in outbuf
	xor r14, r14		; counter of %
loop:	mov al, [rdi]		; store current char
	test al, al		; end of string?
	je write		; we've done

	cmp al, '%'		; is it %?
	jne l_default

; We've met a start of control sequence, let's check what follows it
	inc rdi
	mov al, [rdi]		; the char after %
	cmp al, '%'
	je pct
swtch:	movzx rbx, al
	lea rdx, [rel index]
	mov al, [rdx + rbx]
	cmp al, 255
	je l_default
	
	movzx rax, al
	lea rdx, [rel jmptbl]
	mov rbx, [rdx + 8 * rax]
	add rdx, rbx
	jmp rdx

	jmp l_default
pct:	mov rax, '%'
	jmp l_default
char:	mov rax, [rbp]		; the char will be copied to the output
	jmp next_arg		; buffer before the next loop iteration
bin:	int2str qword [rbp], r13, 2	; bytes written -> rax
	add r13, rax
	jmp next_arg
oct:	int2str qword [rbp], r13, 8
	add r13, rax
	jmp next_arg
hex:	int2str qword [rbp], r13, 16
	add r13, rax
	jmp next_arg
dec:	int2str qword [rbp], r13, 10
	add r13, rax
	jmp short next_arg
str:	mov rsi, [rbp]		; string start address -> rsi
copy:	mov al, [rsi]
	test al, al		; end of string?
	je next_arg
	mov [r13], al
	inc r13			; inc the bytes written
	inc rsi			; next char in the string
	jmp short copy
next_arg:
	add rbp, 8		; next from the stack
	inc r14			; inc count of wrote args
	cmp r14, 5
	jne l_default
	add rbp, 8		; skip return address, we've readched [rsp]
l_default:
	mov [r13], al		; add char to output buffer
	inc r13			; next char in output buffer
	inc rdi			; next char in format string
	jmp loop		; continue string processing
write:	mov rax, 1		; write syscall
	mov rdi, 1		; stdout
	lea rsi, [rel outbuf]	; outbuf
	mov rdx, r13
	sub rdx, rsi		; now len in rdx
	push rdx		; save it for future
	syscall
	
	pop rax			; return chars printed
	pop rbx
	pop r14
	pop r13
	pop rbp
	add rsp, 5 * 8		; we've appended 5 args earlier
	ret

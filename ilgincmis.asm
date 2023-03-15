%define SYSCALL_WRITE 	4
%define SYSCALL_READ	3
%define SYSCALL_EXIT	1
%define SYSCALL_OPEN	5
%define SYSCALL_CLOSE	6
%define SYSCALL_CREAT	8
%define SYSCALL_BRK		45

%define FILEDESC_STDOUT	1
%define FILEDESC_STDIN	0

%define BUFSIZE	100
%define O_RDWR	2

global _start

section .data
	qst db "ne diyosun?", 0x0a
	qstlen equ $ - qst
	res db "cok ilgincmis", 0x0a
	reslen equ $ - res
	pth db "dediginsey.log", 0

section .text
_start:
	mov eax, SYSCALL_BRK
	mov ebx, 0
	int 0x80

	cmp eax, 0
	jl .halt

	mov edi, eax ;lowest progbreak address = buffer address

	add eax, BUFSIZE
	mov ebx, eax ;address to set progbreak
	mov eax, SYSCALL_BRK
	int 0x80

	cmp eax, 0
	jl .halt

	;write to screen
	mov eax, SYSCALL_WRITE		
	mov ebx, FILEDESC_STDOUT	
	mov ecx, qst 				
	mov edx, qstlen 			
	int 0x80

	;read from stdin
	mov eax, SYSCALL_READ 		
	mov ebx, FILEDESC_STDIN 	
	mov ecx, edi		
	mov edx, BUFSIZE			
	int 0x80					

	;open a file
	mov eax, SYSCALL_CREAT
	mov ebx, pth
	mov ecx, 02001
	mov edx, 0o777
	int 0x80

	cmp eax, 0
	jl .halt

	;write to file
	mov ebx, eax
	mov eax, SYSCALL_WRITE
	mov ecx, edi
	mov edx, BUFSIZE
	int 0x80

	cmp eax, 0
	jl .halt

	;close file
	mov eax, SYSCALL_CLOSE
	int 0x80

	cmp eax, 0
	jl .halt

	;write to screen
	mov eax, SYSCALL_WRITE
	mov ebx, FILEDESC_STDOUT
	mov ecx, res
	mov edx, reslen
	int 0x80

	;free heap
	mov eax, SYSCALL_BRK
	mov ebx, 0
	int 0x80

	cmp eax, 0
	jl .halt
	
	;exit
	mov eax, SYSCALL_EXIT		
	mov ebx, 0 					
	int 0x80					

.halt:
	mov eax, SYSCALL_EXIT
	mov ebx, 1
	int 0x80
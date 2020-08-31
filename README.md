# Raw-Windows-Shellcode
Some C and Assembly code to build a shellcode from scratch

Tested on **Windows 10**

### List of payloads


#### MessageBox
- Open a message dialog with MessageBoxA()
- NULL free 
- ESP,EBP preserving
- Restore the stack
```
C:\> ml /c /coff MessageBox.asm
C:\> link /subsystem:windows MessageBox.obj
C:\> MessageBox.exe
```

#### CreateProcess

Spawn a shell with CreateProcessA()
- NULL free
- ESP,EPB preserving
```
C:\> ml /c /coff CreateProcess.asm
C:\> link /subsystem:windows CreateProcess.obj
C:\> CreateProcess.exe
```
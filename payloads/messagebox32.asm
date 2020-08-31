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

getLoadLibraryA:
	;; GetProcAddress(kernel32,"LoadLibraryA");
	xor ecx, ecx                            ; zero out ecx
    push ecx;                               ; zeros
    push 'Ayra'
    push 'rbiL'
    push 'daoL'
	push esp                                ; push ptr to string
	push ebx                                ; kernel32 base address
	call esi                                ; call GetProcAddress
    add esp, 10h                            ; clean stack

getUser32:
    ;; LoadLibrary("user32");
    xor ecx, ecx                            ; zero out ecx
    push ecx                                ; zeros
    mov cx, '23'
    push ecx
    push 'resu'
    push esp                                ; push ptr to string
    call eax                                ; call LoadLibraryA
    add esp, 0ch                            ; clean stack

getMessageBoxA:
    ;; GetProcAddress(user32,"MessageBoxA")
    xor ecx, ecx                            ; zero out ecx
    push ecx                                ; zeros
    push 0141786fh
    dec byte ptr [esp + 3h]
    push 'Bega'
    push 'sseM'
	push esp                                ; push ptr to string
    push eax                                ; user32
	call esi                                ; call GetProcAddress
    add esp, 10h                            ; clean stack

getExecution:
    ;; MessageBoxA(NULL, "Hello World!", NULL, MB_OK);
    xor ecx, ecx                            ; zero out ecx
    push ecx                                ; zeros
    push '!dlr'
    push 'oW o'
    push 'lleH'
    mov edi, esp                            ; edi = ptr to string
    push ecx                                ; MB_OK
    push ecx                                ; NULL
    push edi                                ; push ptr to string
    push ecx                                ; NULL
    call eax                                ; call MessageBoxA
    add esp, 10h                            ; clean stack

    ;; Restore execution
    ret
end start

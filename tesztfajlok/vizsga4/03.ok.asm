extern be_egesz
extern ki_egesz
extern be_logikai
extern ki_logikai
global main

section .bss
i: resd 1
section .text
main:
mov dword[i],10
label1:
mov eax, dword[i]
mov ebx,20
inc ebx
cmp eax,ebx
jne label2
jmp label3
label2:
mov eax,[i]
push eax
call ki_egesz
add esp,4
inc dword[i]
jmp label1
label3:
ret

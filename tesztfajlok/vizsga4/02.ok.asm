extern be_egesz
extern ki_egesz
extern be_logikai
extern ki_logikai
global main

section .bss
i: resd 1
j: resd 1
section .text
main:
mov dword[i],10
label4:
mov eax, dword[i]
mov ebx,20
inc ebx
cmp eax,ebx
jne label5
jmp label6
label5:
mov dword[j],0
label1:
mov eax, dword[j]
mov ebx,4
inc ebx
cmp eax,ebx
jne label2
jmp label3
label2:
mov eax,[i]
push eax
call ki_egesz
add esp,4
mov eax,[j]
push eax
call ki_egesz
add esp,4
inc dword[j]
jmp label1
label3:
inc dword[i]
jmp label4
label6:
ret

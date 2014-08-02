.Model Tpascal
.Data

.Code

locals

intr_hand dw ?
          dw ?

dma_addr    dw 0002h
dma_page    dw 83h
dma_pages   dw 87h,83h,81h,82h

base        dw 220h
dma         db 1
irq         db 7
dma_direc   db 59h
dsp_start   db 91h
dsp_com     db 14h

dsp_com_da  db 14h
dsp_com_ad  db 24h

freq        dw 12050
timec       db 166
koko        dw ?
data_addr   dw ?

.386p

PUBLIC init_sb,set_direction,set_freq,reset_dsp
PUBLIC set_dsp,set_irq,disable_irq
PUBLIC speaker_on,speaker_off,set_dma
PUBLIC stop_dma,waitport

PROC waitport
mov cx,30000
wlo:
dec  cx
jcxz pois
mov  dx,[base]
add  dx,000ch
in   al,dx
test al,128
jnz  wlo
pois:
ret
ENDP

PROC init_sb ibase:WORD,idma:BYTE,iirq:BYTE
mov ax,[ibase]
mov [base],ax
mov al,[idma]
mov [dma],al
xor bx,bx
mov bl,al
shl bx,1
mov dx,[dma_pages+bx]
mov [dma_page],dx
mov [dma_addr],bx
add al,58h
mov [dma_direc],al
mov al,[iirq]
mov [irq],al
mov al,04h
or  al,[dma]
out 0ah,al
ret
ENDP init_sb

PROC set_direction direc:BYTE
cmp [direc],0
je  da
da:
mov al,[dma]
add al,58h
mov  [dma_direc],al
;8-bits, fast mode
mov [dsp_start],91h
mov al,[dsp_com_da]
mov [dsp_com],al
mov al,[dma_direc]
out 0bh,al
ret
ENDP set_direction

PROC set_freq ifreq:WORD
mov ax,[ifreq]
mov [ifreq],ax
mov bx,ax
mov dx,15
mov ax,16960
div bx
mov dx,256
sub dx,ax
mov [timec],dl
cmp [freq],22050
ja  end2
;8-bits
mov [dsp_com_da],14h
mov [dsp_com_ad],24h

end2:
cmp [dsp_start],91h
je  da2
ad2:
mov al,[dsp_com_ad]
mov [dsp_com],al
jmp timeconst
da2:
mov al,[dsp_com_da]
mov [dsp_com],al
timeconst:
call waitport
mov dx,[base]
add dx,000ch
;40h = dspfreq
mov al,040h
out dx,al
call waitport
mov dx,[base]
add dx,000ch

mov al,[timec]
out dx,al
ret
ENDP set_freq

PROC reset_dsp
mov dx,[base]
;reset dsp
add dx,0006h
mov al,01h
out dx,al
mov ax,5000
@@viive:
dec ax
jnz @@viive
mov dx,[base]
add dx,0006h
mov al,00h
out dx,al
ret
ENDP reset_dsp

PROC set_irq handler:DWORD
mov  al,[irq]
test al,8       ; onko 7
jz   kymppi1
add  al,60h
kymppi1:
add  al,8
push ax
mov  ah,35h
int  21h
mov  [intr_hand],bx
mov  bx,es
mov  [intr_hand+2],bx
pop  ax
push ds
mov  ah,25h

mov  dx,[word ptr handler]
mov  bx,[word ptr handler+2]
;mov  bx,handseg
;mov  dx,handofs

mov  ds,bx
int  21h
pop  ds
mov  cl,[irq]
mov  ah,254
test cl,8
jnz  kymppi4
rol  ah,cl
in   al,21h
and  al,ah
out  21h,al
jmp  jatkopois2
kymppi4:
and  cl,7
rol  ah,cl
in   al,0a1h
and  al,ah
out  0a1h,al
jatkopois2:
ret
ENDP set_irq

PROC disable_irq
push ds
mov  cl,[irq]
mov  ah,1
test cl,8
jnz  kymppi3
shl  ah,cl
in   al,21h
or   al,ah
out  21h,al
jmp  jatkopois
kymppi3:
and  cl,7
shl  ah,cl
in   al,0a1h
or   al,ah
out  0a1h,al
jatkopois:
mov  ah,25h
mov  al,[irq]
test al,8
jz   kymppi2
add  al,60h
kymppi2:
add  al,8
mov  dx,[intr_hand]
mov  bx,[intr_hand+2]
mov  ds,bx
int  21h
pop  ds
ret
ENDP disable_irq

PROC speaker_on
call waitport
mov  dx,[base]
add  dx,000ch
mov  al,0d1h
out  dx,al
ret
ENDP speaker_on

PROC speaker_off
call waitport
mov  dx,[base]
add  dx,000ch
mov  al,0d3h
out  dx,al
ret
ENDP speaker_off

PROC set_dma data1:DWORD,soffs:WORD,isize:WORD
pushf
cli
mov al,04h
or  al,[dma]
out 0ah,al
mov al,00h
out 0ch,al
les si,[data1]
add si,[soffs]
mov bx,si
and si,0fh
shr bx,4
mov ax,es
add bx,ax
mov di,bx
shl bx,4
add bx,si
mov [data_addr],bx
mov dx,[dma_addr]
mov al,bl
out dx,al
mov al,bh
out dx,al
mov bx,di
shr bx,12
mov al,bl
mov dx,[dma_page]
out dx,al
mov bx,[isize]
mov [koko],bx
mov dx,[dma_addr]
inc dx
mov al,bl
out dx,al
mov al,bh
out dx,al
mov al,[dma]
out 0ah,al
popf
ret
ENDP set_dma

PROC set_dsp
pushf
cli
call waitport
mov  dx,[base]
add  dx,000ch
mov  al,[dsp_com]
out  dx,al
call waitport
mov  dx,[base]
add  dx,000ch
mov  al,[byte ptr koko]
out  dx,al
call waitport
mov  dx,[base]
add  dx,000ch
mov  al,[byte ptr koko+1]
out  dx,al
cmp  [freq],22050
jna  loppu
call waitport
mov  dx,[base]
add  dx,000ch
mov  al,[dsp_start]
out  dx,al
loppu:
popf
ret
ENDP set_dsp

PROC stop_dma
mov  al,04h
or   al,[dma]
out  0ah,al
mov  al,00h
out  0ch,al
mov  al,[dma]
out  0ah,al
ret
ENDP stop_dma

END

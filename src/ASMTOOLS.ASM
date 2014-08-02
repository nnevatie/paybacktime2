.Model Tpascal
.Data
.Code
locals

  l_modifier=52000                    ; light interpolation modifier
  fixed=16                            ; fixed point shifter
  light_level          dd 15*2 dup(0) ; enough room for both sides

  diagonal_x_increment dw 0
  diagonal_y_increment dw 0
  short_distance       dw 0
  straight_x_increment dw 0
  straight_y_increment dw 0
  straight_count       dw 0
  diagonal_count       dw 0

  fastp_toseg          dw 0
  fastp_gseg           dw 0
  fastp_iseg           dw 0

.386p

PUBLIC wipe,put2d,clear,clear1,fastp,fastp_586,inter_low_level
PUBLIC init_fastp_586,los,vidmode
PUBLIC fontxy,fontxyt,sfontxy,sfontxyt
PUBLIC move_custom

wipe  proc far seg1,seg2,off1,off2,amount:word
      push ds
      mov es,seg2
      mov ds,seg1
      mov di,off2
      mov si,off1
      mov cx,amount
      cld
rep   movsd
      pop ds
      ret
wipe  endp

put2d proc far toseg1,cord1,gfxseg1,gfxofs1:word,decment:dword

push ds
cmp gfxofs1,0
jne nodec
mov decment,0
nodec:
mov es,toseg1
mov di,cord1
mov ds,gfxseg1
mov si,gfxofs1
mov dx,8
putloop:
lodsd
sub eax,decment
stosd
lodsd
sub eax,decment
stosd
add di,312
add si,312
dec dx
jnz putloop
pop ds
ret

put2d endp

clear proc far segm,siz:word
      cld
      mov es,segm
      xor di,di
      xor eax,eax
      mov cx,siz
rep   stosd
      ret
clear endp

clear1 proc far segm,of1,siz:word
       cld
       mov es,segm
       mov di,of1
       xor eax,eax
       mov cx,siz
rep    stosd
       ret
clear1 endp

init_fastp_586 proc far toseg,gseg,iseg:word
           mov ax,toseg
           mov fastp_toseg,ax

           mov ax,gseg
           mov fastp_gseg,ax

           mov ax,iseg
           mov fastp_iseg,ax

           ret
init_fastp_586 endp

fastp_586  proc far light,cord,times,gfxofs,infofs:word

           push ds
           mov  di,cord
           mov  dx,times
           mov  es,fastp_toseg
           add  di,2433
           mov  si,gfxofs
           mov  bx,infofs
           mov  fs,fastp_iseg
           mov  ds,fastp_gseg
           push bp
           mov  bp,light

mainloop_586:
           mov  ax,[fs:bx]
           mov  cx,[fs:bx+2]
           add  di,ax
           add  bx,4
           shr  cx,1
           jnc  inloop_586

           mov  al,[ds:si]
           inc  di
           sub  ax,bp
           inc  si
           mov  [es:di-1],al

           or   cx,cx
           jz   end_586
inloop_586:
           mov  ax,[ds:si]
           add  di,2
           sub  ax,bp
           add  si,2
           mov  [es:di-2],ax

           dec  cx
           jnz  inloop_586
end_586:
           dec  dx
           jnz  mainloop_586
           pop  bp
           pop  ds
           ret

fastp_586  endp

inter_low_level proc far l_t:dword,l_l:dword,l_r:dword,l_b:dword,coord,gfxofs:word
;32-bit, low level light interpolation

           mov  eax,l_t
           mov  ebx,eax
           add  eax,l_modifier  ;l_cur left
           mov  esi,ebx
           sub  ebx,l_l
           sub  esi,l_r
           mov  edx,eax         ;l_cur right

           mov  cl,8            ;counter
           sar  ebx,3           ;l_step left
           sar  esi,3           ;l_step rigth
           xor  di,di           ;light_level offset

@inter_upper:
           mov  cs:light_level[di],eax      ;light_level[1,cl]=l_cur
           mov  cs:light_level[di+15*4],edx ;light_level[2,cl]=l_cur2
           add  di,4
           sub  eax,ebx                 ;dec(l_cur,l_step)
           sub  edx,esi                 ;dec(l_cur2,l_step2)
           dec  cl
           jnz  @inter_upper

           ;...and the lower one...

           mov  eax,l_l
           mov  ebx,eax
           add  eax,l_modifier  ;l_cur left
           mov  esi,l_r
           sub  ebx,l_b
           sub  esi,l_b
           mov  edx,l_r         ;l_cur right

           mov  cl,8            ;counter
           add  edx,l_modifier
           sar  ebx,3           ;l_step left
           sar  esi,3           ;l_step rigth

@inter_lower:
           mov  cs:light_level[di],eax      ;light_level[1,cl]=l_cur
           mov  cs:light_level[di+15*4],edx ;light_level[2,cl]=l_cur2
           add  di,4
           sub  eax,ebx                 ;dec(l_cur,l_step)
           sub  edx,esi                 ;dec(l_cur2,l_step2)
           dec  cl
           jnz  @inter_lower

           ; Ok, now the tricky part...

           mov  ecx,4             ;width of the current scanline
           mov  di,14+2433+20*290 ;current destination offset
           push ds
           add  di,coord
           mov  es,fastp_toseg
           mov  ds,fastp_gseg

           mov  si,gfxofs         ;current gfx_ofs

           push bp

           xor  bx,bx
           mov  bp,8              ;yloop

@inter_inner1:
           mov  eax,cs:light_level[bx]
           mov  edx,cs:light_level[bx+15*4]
           sub  eax,edx
           mov  edx,eax
           sar  edx,1fh
           idiv ecx               ;l_step
           mov  edx,cs:light_level[bx]

           push cx                ;outer counter to stack
           push bx                ;light_level offset to stack

@inter_render1:
           mov  ch,[ds:si]
           mov  ebx,edx
           shr  ebx,fixed
           mov  bh,10
           sub  bh,bl
           sub  ch,bh

           mov  [es:di],ch
           sub  edx,eax

           inc  di
           inc  si
           dec  cl
           jnz  @inter_render1

           pop  bx                ;light_level offset from stack
           pop  cx                ;outer counter from stack

           add  di,290-2
           add  bx,4
           sub  di,cx
           add  cl,4

           dec  bp
           jnz  @inter_inner1

           sub  cl,8
           add  di,4
           mov  bp,7              ;yloop

@inter_inner2:
           mov  eax,cs:light_level[bx]
           mov  edx,cs:light_level[bx+15*4]
           sub  eax,edx
           mov  edx,eax
           sar  edx,1fh
           idiv ecx               ;l_step
           mov  edx,cs:light_level[bx]

           push cx                ;outer counter to stack
           push bx                ;light_level offset to stack

@inter_render2:
           mov  ch,[ds:si]
           mov  ebx,edx
           shr  ebx,fixed
           mov  bh,10
           sub  bh,bl
           sub  ch,bh

           mov  [es:di],ch
           sub  edx,eax

           inc  di
           inc  si
           dec  cl
           jnz  @inter_render2

           pop  bx                ;light_level offset from stack
           pop  cx                ;outer counter from stack

           add  di,290+2
           add  bx,4
           sub  di,cx
           sub  cl,4

           dec  bp
           jnz  @inter_inner2

           endi:

           pop  bp
           pop  ds
           ret
inter_low_level  endp

fastp proc far light,toseg,cord,times,gfxofs,infofs,gseg,iseg:word

           push ds
           mov  ax,toseg
           mov  es,ax
           mov  di,cord
           add  di,2433
           xor  dx,dx
           mov  si,gfxofs
           mov  bx,infofs
           mov  fs,iseg
           mov  ds,gseg
mainloop:
           mov  ax,[fs:bx]
           mov  cx,[fs:bx+2]
           add  di,ax
           add  bx,4
           shr  cx,1
           jnc  inloop

           lodsb
           sub  ax,light
           stosb

           or   cx,cx
           jz   end1
inloop:
           lodsw
           sub  ax,light
           stosw
           dec  cx
           jnz  inloop
end1:
           inc  dx
           cmp  dx,times
           jb   mainloop
           pop  ds
           ret

fastp endp

los proc far X1,Y1,X2,Y2,mapseg,mapoffs,entseg1,entofs1:word

    dec x1
    dec y1
    dec x2
    dec y2

    mov fs,mapseg
    mov gs,entseg1

    mov CX, 1  ;Set initial increments for each pixel position
    mov DX, 1
    mov DI, Y2 ;Calculate Vert. distance
    sub DI, Y1
    jge @keep_y
    neg DX
    neg DI
    @Keep_Y:
    mov diagonal_y_increment, DX
    mov SI, X2 ;Calculate horiz. distance
    sub SI, X1
    jge @keep_x
    neg CX
    neg SI
    @Keep_X:
    mov diagonal_x_increment, CX
    cmp SI, DI ;Figure whether straight segments are horizontal or vertical
    jge @horz_seg
    xor CX, CX
    xchg SI, DI
    jmp @Save_Values
    @Horz_seg:
    xor DX, DX
    @Save_values:
    mov short_distance, DI
    mov straight_x_increment, CX
    mov straight_y_increment, DX
    mov AX, short_distance ;Calculate adjustment factor
    ShL AX, 1
    mov straight_count, AX
    sub AX, SI
    mov BX, AX
    sub AX, SI
    mov diagonal_count, AX
    mov CX, X1 ;prepare to draw the line
    mov DX, Y1
    Inc SI
    @MainLoop:  ;Now draw the line
    Dec SI
    jz  @line_finished

    ;Plot Pixel, dx=y coordinate, cx=x coordinate
    pusha
    cmp dx,y1
    jne @ok1
    cmp cx,x1
    jne @ok1
    jmp @eka1

@ok1:
    xor ax,ax
    mov di,mapoffs
    shl cx,7
    add di,cx
    add di,dx
    mov al,[fs:di] ;al=map[x,y]

    mov di,entofs1
    add di,ax
    mov al,[gs:di] ;al=enterable or not (1/0)
    or  al,al
    je  @nosight

@eka1:
    popa

;   End Plot
    cmp BX, 0
    jge @diagonal_line
    add CX, straight_x_increment ; Draw Stright Line Segments
    add DX, straight_y_increment
    add BX, straight_count
    jmp @MainLoop
    @Diagonal_line: ; Draw Diagonal Line Segments
    add CX, diagonal_x_increment
    add DX, diagonal_y_increment
    add BX, diagonal_count
    jmp @MainLoop
    @Line_Finished:

    jmp @alldone
@nosight:
    xor al,al
    jmp @theend
@alldone:
    mov al,1
@theend:
    ret
LOS endp

vidmode proc far mode:word
        mov ax,mode
        int 10h
        ret
vidmode endp

fontxy   proc far x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word

         cmp len,0
         je  @lop

         mov di,y
         mov ax,di
         shl ax,8
         shl di,6
         add di,ax
         add di,x                 ; di, koordinaatti piirtosegiin
         mov es,toseg
         mov gs,stseg
         mov bx,stofs
         inc bx

         push ds
         mov ds,fontseg

         mov cx,len               ; cx = string length
         xor ax,ax
@fontl:  ;xor si,si
         mov byte ptr ch,[gs:bx]  ; gs:bx points to string
         movzx si,ch
         or  ch,ch
         jz @new

         sub si,32                ; es:di points to drawing seg
@new:
         shl si,3                 ; ds:si points to fontseg
         mov dh,7
@rows:   mov dl,6
@pixs:
         lodsb
         or  al,al
         jz  @skip
         mov byte ptr ax,col
         jmp @over
@skip:   mov ax,bcol
@over:   stosb

         dec dl
         jnz @pixs

         add di,314
         add si,764
         dec dh
         jnz @rows

         sub di,2234
         inc bx
         dec cl
         jnz @fontl

         pop ds
@lop:    ret
fontxy   endp

fontxyt  proc far x,y,stseg,stofs,fontseg,toseg,col,len:word

         cmp len,0
         je  @lop1

         mov di,y
         mov ax,di
         shl ax,8
         shl di,6
         add di,ax
         add di,x                 ; di, koordinaatti piirtosegiin
         mov es,toseg
         mov gs,stseg
         mov bx,stofs
         inc bx

         push ds
         mov ds,fontseg

         mov cx,len               ; cx = string length
         xor ax,ax
@fontl1: xor si,si
         mov byte ptr ch,[gs:bx]  ; gs:bx points to string
         movzx si,ch
         or  ch,ch
         jz @new1

         sub si,32                ; es:di points to drawing seg
@new1:
         shl si,3                 ; ds:si points to fontseg
         mov dh,7
@rows1:  mov dl,6

@pixs1:
         lodsb
         or  al,al
         jz  @skip1
         mov byte ptr ax,col
         stosb
         jmp @over1
@skip1:  inc di

@over1:
         dec dl
         jnz @pixs1

         add di,314
         add si,764
         dec dh
         jnz @rows1

         sub di,2234
         inc bx
         dec cl
         jnz @fontl1

         pop ds
@lop1:   ret
fontxyt  endp

sfontxy  proc far x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word

         cmp len,0
         je  @lop2

         mov di,y
         mov ax,di
         shl ax,8
         shl di,6
         add di,ax
         add di,x                 ; di, koordinaatti piirtosegiin
         mov es,toseg
         mov gs,stseg
         mov bx,stofs
         inc bx

         push ds
         mov ds,fontseg

         mov cx,len               ; cx = string length
         xor ax,ax
@fontl2: xor si,si
         mov byte ptr ch,[gs:bx]  ; gs:bx points to string
         movzx si,ch
         or  ch,ch
         jz @new2

         sub si,32                ; es:di points to drawing seg
@new2:
         shl si,3                 ; ds:si points to fontseg
         mov dh,7
@rows2:  mov dl,6
@pixs2:
         lodsb
         or  al,al
         jz  @skip2
         mov byte ptr ax,col
         sub al,dh
         jmp @over2
@skip2:  mov ax,bcol
@over2:  stosb

         dec dl
         jnz @pixs2

         add di,314
         add si,764
         dec dh
         jnz @rows2

         sub di,2234
         inc bx
         dec cl
         jnz @fontl2

         pop ds
@lop2:   ret
sfontxy  endp

sfontxyt proc far x,y,stseg,stofs,fontseg,toseg,col,len:word

         cmp len,0
         je  @lop3

         mov di,y
         mov ax,di
         shl ax,8
         shl di,6
         add di,ax
         add di,x                 ; di, koordinaatti piirtosegiin
         mov es,toseg
         mov gs,stseg
         mov bx,stofs
         inc bx


         push ds
         mov ds,fontseg

         mov cx,len               ; cx = string length
         xor ax,ax
@fontl3: xor si,si
         mov byte ptr ch,[gs:bx]  ; gs:bx points to string
         movzx si,ch
         or  ch,ch
         jz @new3

         sub si,32                ; es:di points to drawing seg
@new3:
         shl si,3                 ; ds:si points to fontseg
         mov dh,7
@rows3:  mov dl,6

@pixs3:
         lodsb
         or  al,al
         jz  @skip3
         mov byte ptr ax,col
         sub al,dh
         stosb
         jmp @over3
@skip3:  inc di

@over3:
         dec dl
         jnz @pixs3

         add di,314
         add si,764
         dec dh
         jnz @rows3

         sub di,2234
         inc bx
         dec cl
         jnz @fontl3

         pop ds
@lop3:   ret
sfontxyt endp

move_custom proc far source:dword,dest:dword,amount:word
         push ds
         cld
         lds  si, source
         les  di, dest
         mov  cx, amount
         mov  bx, cx
         shr  cx, 2
         jz   suite

         rep movsd
suite:
         test bx, 10b
         jz   suite2
         movsw
suite2:
         test bx, 1
         jz   fin
         movsb
fin:
         pop  ds
         ret
move_custom endp



end

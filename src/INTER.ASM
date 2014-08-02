inter_low_level proc l_t:dword,l_l:dword,l_r:dword,l_b:dword,coord,gfxofs:word
;32-bit, low level light interpolation

           mov  eax,l_t
           mov  edx,eax
           mov  ebx,eax
           add  eax,l_modifier

           sub  ebx,l_l
           sar  ebx,3

           mov  cl,8
           xor  di,di
@inter_left:
           mov  cs:light_level[di],eax  ;light_level[1,cl]=l_cur
           add  di,4
           sub  eax,ebx                 ;dec(l_cur,l_step)
           dec  cl
           jnz  @inter_left

           ;...and the second one...

           mov  ebx,edx
           add  edx,l_modifier

           sub  ebx,l_r
           sar  ebx,3

           mov  cl,8
@inter_right:
           mov  cs:light_level[di],edx  ;light_level[2,cl]=l_cur
           add  di,4
           sub  edx,ebx                 ;dec(l_cur,l_step)
           dec  cl
           jnz  @inter_right

           ; Ok, now the tricky part...

           mov  ecx,4             ;width of the current scanline
           mov  di,14+2433+20*290 ;current destination offset
           add  di,coord

           push ds

           mov  es,fastp_toseg
           mov  ds,fastp_gseg

           mov  si,gfxofs         ;current gfx_ofs

           push bp
           mov  bp,8              ;yloop
           xor  bx,bx

@inter_inner1:
           mov  eax,cs:light_level[bx]
           mov  edx,cs:light_level[bx+32]
           sub  eax,edx

           mov  edx,eax
           xor  ch,ch
           sar  edx,1fh
           idiv ecx               ;l_step
           mov  edx,cs:light_level[bx]

           push cx
@inter_render1:

           mov  ch,[ds:si]
           push edx
           push eax
           shr  edx,16
           mov  eax,10
           sub  eax,edx
           sub  ch,al
           pop  eax
           pop  edx

           mov  [es:di],ch
           sub  edx,eax

           inc  di
           inc  si

           dec  cl
           jnz  @inter_render1
           pop  cx

           add  di,290-2
           sub  di,cx
           add  cl,4

           add  bx,4
           dec  bp
           jnz  @inter_inner1

           pop  bp
           pop  ds
           ret
inter_low_level  endp


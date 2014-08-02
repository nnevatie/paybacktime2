.Model Tpascal
.Data
.Code
locals

.386p

PUBLIC produce_bump_fast,produce_bump_fast2,produce_illumination_fast

produce_bump_fast proc liseg,ownseg,dseg1,dseg2:word
      push ds

      mov ds,liseg
      mov es,ownseg
      mov fs,dseg1  ; x
      mov gs,dseg2  ; y

      mov si,63999  ; current offset (without modifications)

@inner:
      mov al,[fs:si]
      cbw
      mov bx,ax
      mov al,[gs:si]
      cbw
      mov di,ax
      sal di,8
      sal ax,6
      add di,ax
      add bx,di

      mov al,[ds:si+bx]
      mov [es:si],al

      dec si
      jnz @inner

      pop ds
      ret
produce_bump_fast endp

produce_bump_fast2 proc liseg,ownseg,dseg1,dseg2:word
      push ds

      mov ds,liseg
      mov es,ownseg
      mov fs,dseg1  ; x
      mov gs,dseg2  ; y

      mov si,31999  ; current offset (without modifications)
@inner2:
      mov bx,si
      add bx,bx
      mov bx,[fs:bx]
      mov al,[ds:bx]
      mov [es:si],al
      dec si
      jnc @inner2

      mov si,31999  ; current offset (without modifications)
@inner22:
      mov bx,si
      add bx,bx
      mov bx,[gs:bx]
      mov al,[ds:bx]
      mov [es:si+32000],al
      dec si
      jnc @inner22

      pop ds
      ret
produce_bump_fast2 endp

produce_illumination_fast proc oseg,cseg,iseg:word
      push ds

      mov ds,iseg
      mov es,oseg
      mov fs,cseg

      mov si,63999    ; current offset
      xor ax,ax
@@inner:
      mov bl,[es:si]
      shl bx,8
      mov al,[fs:si]
      mov di,ax
      mov al,[ds:bx+di]
      mov [es:si],al

      dec si
      jnz @@inner

      pop ds
      ret
produce_illumination_fast endp

end

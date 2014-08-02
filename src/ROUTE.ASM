.Model Tpascal
.Data
.Code
locals
     lx   dw 0
     ly   dw 0
     dist dw 0
.386p

PUBLIC routestart


route8 proc near

       mov si,bx
       shl si,1
       mov word ptr [fs:si],dx         ; [ownseg:cord]:=distance

       mov si,dx
       mov [fs:si+30000],cl            ; [ownseg:cord+30000]:=route

       cmp bx,lx                       ; If at endx/endy begins here
       jne @pois1
       mov di,dx                       ; how many steps
@l1:
       mov si,[fs:di+30000]
       mov [fs:di+50000],si
       dec di
       jnz @l1
       mov dist,dx
@pois1:                                ; If at endx/endy ends here

       mov di,dx                       ; If current route is longer,
       inc di                          ; than the one currently shortest
       cmp di,dist                     ; then jump away
       jae @lab7                       ;

;       mov di,bx                      ; Drawing begins here
;       mov si,bx
;       shr di,7
;       shl di,7
;       sub si,di
;       shr di,7
;       mov ax,di
;       shl di,8
;       shl ax,6
;       add di,ax
;       add di,si
;       inc byte ptr [es:di]           ; Drawing ends here

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si-256],di     ; [ownseg:(y-1)*256+x]=am. of steps
       jbe @lab0
       cmp byte ptr [gs:bx-128],0      ; if[mapseg:bx-128]=0 then enterable
       jne @lab0

       push bx
       push dx
       sub bx,128
       mov cx,0
       inc dx
       call route8                     ; Route8(x,y-1,0,i+1);
       pop dx
       pop bx
@lab0:
;if(mem[mapseg:(y-1)*320+x]=0)and(o[y-1,x]>i+1)then route8(x,y-1,0,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si+2],di       ; [ownseg:y*256+x+2]=am. of steps
       jbe @lab2
       cmp byte ptr [gs:bx+1],0        ; if[mapseg:bx+1]=0 then enterable
       jne @lab2

       push bx
       push dx
       inc bx
       mov cx,2
       inc dx
       call route8                     ; Route8(x+1,y,2,i+1);
       pop dx
       pop bx
@lab2:
;if(mem[mapseg:y*320+x+1]=0)and(o[y,x+1]>i+1)then route8(x+1,y,2,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si+256],di     ; [ownseg:(y+1)*256+x]=am. of steps
       jbe @lab4
       cmp byte ptr [gs:bx+128],0      ; if[mapseg:bx+128]=0 then enterable
       jne @lab4

       push bx
       push dx
       add bx,128
       mov cx,4
       inc dx
       call route8                     ; Route8(x,y+1,4,i+1);
       pop dx
       pop bx
@lab4:
;if(mem[mapseg:(y+1)*320+x]=0)and(o[y+1,x]>i+1)then route8(x,y+1,4,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si-2],di       ; [ownseg:y*256+x-2]=am. of steps
       jbe @lab6
       cmp byte ptr [gs:bx-1],0        ; if[mapseg:bx-1]=0 then enterable
       jne @lab6

       push bx
       push dx
       dec bx
       mov cx,6
       inc dx
       call route8                     ; Route8(x-1,y,6,i+1);
       pop dx
       pop bx
@lab6:
;if(mem[mapseg:y*320+x-1]=0)and(o[y,x-1]>i+1)then route8(x-1,y,6,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si-254],di     ; [ownseg:(y-1)*256+x+2]=am. of steps
       jbe @lab1
       cmp byte ptr [gs:bx-127],0      ; if[mapseg:bx-127]=0 then enterable
       jne @lab1

       push bx
       push dx
       sub bx,127
       mov cx,1
       inc dx
       call route8                     ; Route8(x+1,y-1,1,i+1);
       pop dx
       pop bx
@lab1:
;if(mem[mapseg:(y-1)*320+x+1]=0)and(o[y-1,x+1]>i+1)then route8(x+1,y-1,1,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si+258],di     ; [ownseg:(y+1)*256+x+2]=am. of steps
       jbe @lab3
       cmp byte ptr [gs:bx+129],0      ; if[mapseg:bx+129]=0 then enterable
       jne @lab3

       push bx
       push dx
       add bx,129
       mov cx,3
       inc dx
       call route8                     ; Route8(x+1,y+1,3,i+1);
       pop dx
       pop bx
@lab3:
;if(mem[mapseg:(y+1)*320+x+1]=0)and(o[y+1,x+1]>i+1)then route8(x+1,y+1,3,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si+254],di     ; [ownseg:(y+1)*256+x-2]=am. of steps
       jbe @lab5
       cmp byte ptr [gs:bx+127],0      ; if[mapseg:bx+127]=0 then enterable
       jne @lab5

       push bx
       push dx
       add bx,127
       mov cx,5
       inc dx
       call route8                     ; Route8(x-1,y+1,5,i+1);
       pop dx
       pop bx
@lab5:
;if(mem[mapseg:(y+1)*320+x-1]=0)and(o[y+1,x-1]>i+1)then route8(x-1,y+1,5,i+1);

       mov si,bx
       shl si,1
       mov di,dx                       ; (dx)=amount of steps
       inc di                          ; amount of steps+1 -> (di)
       cmp word ptr [fs:si-258],di     ; [ownseg:(y-1)*256+x-2]=am. of steps
       jbe @lab7
       cmp byte ptr [gs:bx-129],0      ; if[mapseg:bx-129]=0 then enterable
       jne @lab7

       push bx
       push dx
       sub bx,129
       mov cx,7
       inc dx
       call route8                     ; Route8(x-1,y-1,7,i+1);
       pop dx
       pop bx
@lab7:
;if(mem[mapseg:(y-1)*320+x-1]=0)and(o[y-1,x-1]>i+1)then route8(x-1,y-1,7,i+1);

       ret
route8 endp


routestart proc seg1,seg2,x,y,lx1,ly1,maxdist:word
       mov ax,maxdist
       mov dist,ax
       mov ax,0a000h
       mov es,ax
       mov fs,seg1                     ; Ownseg            (fs)
       mov gs,seg2                     ; Mapseg            (gs)

       mov ax,ly1
       shl ax,7
       add ax,lx1
       mov lx,ax                       ; Loppu X

       mov bx,y
       shl bx,7
       add bx,x                        ; Start offset      (bx)

       xor dx,dx                       ; Monellako p„„sty  (dx)
       call route8
       mov ax,dist                     ; Return distance in AX
       ret
routestart endp

end

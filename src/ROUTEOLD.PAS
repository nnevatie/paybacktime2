{$F+}
{$M 65520,0,130000}
const mx=49;my=49;
var ma:pointer;wo,ownseg,mapseg:word;
    o:array[0..99,0..99] of word;
    r,fr:array[0..10000] of byte;
    lx,ly,dist,l:word;
    k:byte;
    c,x,y,a,b:integer;

procedure setpal(n,r,g,b:byte);assembler;
asm mov dx,$3c8;mov al,n;out dx,al;inc dx;mov al,r;out dx,al;mov al,g;out dx,al;mov al,b;out dx,al;end;

procedure wait(t:longint);
var w:longint;
begin
for w:=1 to t do
asm
mov dx,$3da;@vert1:in al,dx;test al,8;jz @vert1;@vert2:in al,dx;test al,8;jnz @vert2;
end;
end;

procedure clean(cleanseg,amount:word);assembler;
asm
db $66;xor ax,ax
mov cx,amount
shr cx,2
mov es,cleanseg
xor di,di
cld
db $66;rep stosw
end;

procedure wipe(seg1,seg2,ofs1,ofs2,amount:word);assembler;
asm
push ds
mov es,seg2
mov di,ofs2
mov ds,seg1
mov si,ofs1
mov cx,amount
shr cx,2
db $66;rep movsw
pop ds
end;

procedure initroute;
begin
for wo:=0 to 15000 do memw[ownseg:wo*2]:=10000;
end;

procedure drawroute8;
begin
x:=1;y:=1;
for c:=1 to dist do begin
if(fr[c]=0)then begin dec(y);end;
if(fr[c]=1)then begin dec(y);inc(x);end;
if(fr[c]=2)then begin inc(x);end;
if(fr[c]=3)then begin inc(y);inc(x);end;
if(fr[c]=4)then begin inc(y);end;
if(fr[c]=5)then begin inc(y);dec(x);end;
if(fr[c]=6)then begin dec(x);end;
if(fr[c]=7)then begin dec(y);dec(x);end;
wait(2);
mem[$a000:y*320+x]:=15;
end;
end;

procedure route8(x,y,d,i:word);
begin
o[y,x]:=i;
r[i]:=d;
if(x=lx)and(y=ly)then for a:=0 to i do begin fr[a]:=r[a];dist:=i;end;
mem[$a000:y*320+x]:=mem[$a000:y*320+x]+1;
if(mem[mapseg:(y-1)*320+x]=0)and(o[y-1,x]>i+1)then route8(x,y-1,0,i+1);
if(mem[mapseg:y*320+x+1]=0)and(o[y,x+1]>i+1)then route8(x+1,y,2,i+1);
if(mem[mapseg:(y+1)*320+x]=0)and(o[y+1,x]>i+1)then route8(x,y+1,4,i+1);
if(mem[mapseg:y*320+x-1]=0)and(o[y,x-1]>i+1)then route8(x-1,y,6,i+1);
if(mem[mapseg:(y-1)*320+x+1]=0)and(o[y-1,x+1]>i+1)then route8(x+1,y-1,1,i+1);
if(mem[mapseg:(y+1)*320+x+1]=0)and(o[y+1,x+1]>i+1)then route8(x+1,y+1,3,i+1);
if(mem[mapseg:(y+1)*320+x-1]=0)and(o[y+1,x-1]>i+1)then route8(x-1,y+1,5,i+1);
if(mem[mapseg:(y-1)*320+x-1]=0)and(o[y-1,x-1]>i+1)then route8(x-1,y-1,7,i+1);
end;

begin
asm mov ax,13h;int 10h;end;
getmem(ma,64000);ownseg:=seg(ma^);clean(ownseg,64000);
getmem(ma,64000);mapseg:=seg(ma^);clean(mapseg,64000);
clean($a000,64000);
randomize;
for x:=0 to mx do begin mem[mapseg:x]:=1;mem[mapseg:my*320+x]:=1;end;
for y:=0 to my do begin mem[mapseg:y*320]:=1;mem[mapseg:my+320*y]:=1;end;
{for x:=0 to 1000 do mem[mapseg:random(my)*320+random(mx)]:=1;}
wipe(mapseg,$a000,0,0,64000);
for y:=0 to my do for x:=0 to mx do o[y,x]:=10000;
lx:=mx-1;ly:=my-1;
asm xor ax,ax;int 16h;end;
route8(1,1,0,0);
drawroute8;
asm xor ax,ax;int 16h;mov ax,3h;int 10h;end;
end.

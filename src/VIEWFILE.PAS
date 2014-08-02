uses crt;
var ma3,ma4:pointer;li,li1,maxline,curline,readyseg,readseg,fisize,i1,a:longint;f:file of byte;f1:file;c2:char;lich:boolean;
    i:word;i2:byte;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

procedure toscreen;
procedure putch(cod:byte;pla:word);assembler;asm mov ax,0b800h;mov es,ax;
mov di,pla;shl di,1;mov ah,cod;mov [es:di],ah;end;
begin
for i:=81 to 1920 do putch(mem[readyseg:i+curline*80],i);
end;

begin
asm mov ax,3h;int 10h;end;
asm mov ah,1;mov cx,2000h;int 10h;end;
getmem(ma3,32000);readseg:=seg(ma3^);for i:=0 to 31999 do mem[readseg:i]:=0;
getmem(ma4,64000);readyseg:=seg(ma4^);for i:=0 to 63999 do mem[readyseg:i]:=32;
assign(f,'pt2.txt');reset(f);fisize:=filesize(f);close(f);
assign(f1,'pt2.txt');reset(f1,fisize);blockread(f1,mem[readseg:1],1);close(f1);
clrscr;li1:=1;i:=1;i1:=1;
repeat
repeat lich:=false;
if(mem[readseg:i]=10)then begin inc(li1);inc(i);i1:=1;lich:=true;end;
if(mem[readseg:i]=13)then begin inc(i);inc(i1);end;
if(mem[readseg:i]<>10)and(mem[readseg:i]<>13)then
begin mem[readyseg:li1*80+i1]:=mem[readseg:i];inc(i);inc(i1);end;
until(i1>=80)or(lich=true);
until(mem[readseg:i]=0);
setpal($1,0,0,0);
textbackground(1);textcolor(15);asm mov ah,2;mov dh,24;mov dl,0;mov bh,0;int 10h end;
write('                                                                                ');
asm mov ah,2;mov dh,0;mov dl,0;mov bh,0;int 10h end;
write('                          PaybackTime infofile reader                           ');
asm mov ah,2;mov dh,24;mov dl,0;mov bh,0;int 10h end;
write('                             Paybacktime Infofile                              ');
textbackground(0);

for i2:=1 to 11 do begin
asm mov ah,2;mov dh,i2;mov dl,0;mov bh,0;int 10h end;textcolor(1+i2);
write('                                                                                ');
end;

asm mov ah,2;mov dh,12;mov dl,0;mov bh,0;int 10h end;textcolor(15);
write('                                                                                ');

for i2:=13 to 23 do begin
asm mov ah,2;mov dh,i2;mov dl,0;mov bh,0;int 10h end;textcolor(25-i2);
write('                                                                                ');
end;

setpal($1,40,0,0);setpal($2,19,19,19);setpal($3,23,23,23);setpal($4,27,27,27);setpal($5,31,31,31);
setpal($14,35,35,35);setpal($7,39,39,39);setpal($38,43,43,43);setpal($39,47,47,47);
setpal($3a,51,51,51);setpal($3b,55,55,55);setpal($3c,59,59,59);setpal($3d,63,63,63);

maxline:=0;for i:=1 to fisize do if(mem[readseg:i]=10)then inc(maxline);curline:=0;toscreen;
repeat
asm mov ah,0;int 16h;mov c2,ah;end;
if(c2=#72)then begin dec(curline);if(curline<0)then curline:=0;toscreen;end;
if(c2=#80)then begin inc(curline);if(curline>maxline-23)then curline:=maxline-23;if curline<0 then curline:=0;toscreen;end;
if(c2=#73)then begin dec(curline,23);if(curline<0)then curline:=0;toscreen;end;
if(c2=#81)then begin inc(curline,23);if(curline>maxline-23)then curline:=maxline-23;if curline<0 then curline:=0;toscreen;end;
until c2=#1;asm mov ah,1;mov ch,13h;mov cl,14h;int 10h;end;textcolor(7);textbackground(0);clrscr;
asm mov ax,3h;int 10h;end;
end.

{$F+}
{$M 2048,0,88000}
uses dos,sbunit,crt;

{$IFNDEF unregistered}
const regname:string[30]='';
const regnumber=60;

const allowexe:array[1..6] of byte=(1,1,1,1,1,1);
{$ELSE}
const regnumber=0; { Unregistered version }
const allowexe:array[1..6] of byte=(1,1,0,0,0,1);
{$ENDIF}

{$IFNDEF unregistered}
const exe:array[1..6] of string=('game1.dat','game2.dat','game3.dat','game4.dat','game5.dat',' ');
{$ELSE}
const exe:array[1..6] of string=('game1.dat','game2.dat',' ',' ',' ',' ');
{$ENDIF}

const PEL_val:array[0..16] of word=
($0,$1,$2,$3,$4,$5,$14,$7,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f,regnumber);

const linecoord:array[1..6] of word=(254,274,295,315,335,364);

const palette:array[0..16*3-1] of byte=
(0,0,0,
8,8,19,
14,8,25,
8,14,25,
20,8,25,
11,13,27,
14,14,25,
20,14,25,
20,14,31,
20,20,38,
22,20,39,
25,23,39,
20,27,44,
30,28,47,
31,33,52,
58,58,75);

var ma:pointer;c:char;s,s1:string;f:file;f1:file of byte;
    serror,error,ver1,mver1,dma1,irq1:byte;
    i,a,timer,lo1,lo2,ownseg,wo,line,iwo,ia:word;
    po:pointer;
    bases:string[3];
    code,hunds,tens,rest:integer;
    c1,debug:byte;
    moffs,oldintseg,oldintofs:word;
    avl,max:longint;
    envadd,envirq,envdma:word;
    tstr:string[3];
    envstr:string;

    t:integer;

label exitp;
{$L ASMTOOLS.OBJ}
procedure clear(segm,siz:word);external;
procedure wipe(seg1,seg2,ofs1,ofs2,amount:word);external;

function checkfile(st1:string):boolean;var fil1:file;begin assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;end;

procedure wait(t:longint);
var w:longint;
begin
for w:=1 to t do
asm
mov dx,$3da;@vert1:in al,dx;test al,8;jz @vert1;@vert2:in al,dx;test al,8;jnz @vert2;
end;
end;


procedure musicint;interrupt;
begin
asm mov al,20h;out 20h,al;end;
if(mver=1)and(musics=1)then playmusic;
end;

procedure getvect(vec:byte);assembler;
asm mov ah,$35;mov al,vec;int $21;mov oldintseg,es;mov oldintofs,bx;end;

procedure setvect(vec:byte;tseg,tofs:word);assembler;
asm push ds;mov ah,$25;mov al,vec;mov dx,tofs;mov ds,tseg;int $21;pop ds;end;

procedure goxy(x,y:byte);assembler;asm mov ah,2;mov dh,y;mov dl,x;mov bh,0;int $10;end;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

procedure credits;
var i:byte;
begin

if(mver<>0)then begin
musics:=0;
endplayer;
clear(tuneseg,7800 div 4);
s:='music\pcdits.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
initplayer(tuneseg);

getvect(8);
setvect(8,seg(musicint),ofs(musicint));
timer:=round(1193180/78);
asm cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;end;
musics:=1;
end;

assign(f,'gfx\pcdits.svf');
reset(f,38400);
portw[$03c4]:=$0102;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
portw[$03c4]:=$0202;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
portw[$03c4]:=$0402;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
portw[$03c4]:=$0802;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
close(f);

for i:=0 to 15 do
setpal(PEL_val[i],
       round(palette[i*3]*0.63),
       round(palette[i*3+1]*0.63),
       round(palette[i*3+2]*0.63));

asm
xor ax,ax
int 16h
end;

if(mver<>0)then begin
musics:=0;endplayer;
timer:=0;
asm cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;end;
setvect(8,oldintseg,oldintofs);
end;

end;

procedure init;
var i:byte;begin

for i:=0 to 15 do
setpal(PEL_val[i],0,0,0);

assign(f,'gfx\main.svf');
reset(f,38400);
portw[$03c4]:=$0102;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
portw[$03c4]:=$0202;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
portw[$03c4]:=$0402;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
portw[$03c4]:=$0802;
blockread(f,mem[ownseg:0],1);
wipe(ownseg,$a000,0,0,9600);
close(f);

for i:=0 to 15 do
setpal(PEL_val[i],
       round(palette[i*3]*0.63),
       round(palette[i*3+1]*0.63),
       round(palette[i*3+2]*0.63));

line:=1;

if(mver<>0)then begin
clear(tuneseg,7800 div 4);
s:='music\intro.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
initplayer(tuneseg);
musics:=1;

getvect(8);
setvect(8,seg(musicint),ofs(musicint));
timer:=round(1193180/50);
asm cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;end;
end;
end;

procedure removep(y:word);
begin

assign(f,'gfx\main.svf');
reset(f,38400);
blockread(f,mem[ownseg:0],1);
portw[$03c4]:=$0102;
wipe(ownseg,$a000,y*80,y*80,320);
blockread(f,mem[ownseg:0],1);
portw[$03c4]:=$0202;
wipe(ownseg,$a000,y*80,y*80,320);
blockread(f,mem[ownseg:0],1);
portw[$03c4]:=$0402;
wipe(ownseg,$a000,y*80,y*80,320);
blockread(f,mem[ownseg:0],1);
portw[$03c4]:=$0802;
wipe(ownseg,$a000,y*80,y*80,320);
close(f);
end;

procedure pointer(y:word);
begin
portw[$03c4]:=$0c02;
for i:=0 to 31 do begin
mem[$a000:80*y+25+i]:=255;
mem[$a000:80*(y+15)+25+i]:=255;
end;
{mem[$a000:25+80*(295+i)]:=128;}
y:=y*80;
asm
mov ax,$a000
mov es,ax
mov di,y
add di,24

{mov ax,0e02h
mov dx,03c4h
out dx,ax}

mov cx,16
@loop1:
mov byte ptr [es:di],255
mov byte ptr [es:di+33],255
add di,80
dec cx
jnz @loop1
end;
end;

begin

{$IFNDEF unregistered}
writeln;
writeln('PaybackTime 2.1 (Win32) Good Riddance Edition (C) 2000 N. Nevatie, K. Luojus.');
writeln;
writeln('PT2.1 is released as freeware, distribution allowed.');
{writeln('With this game, big thanks go to Australia!');}
{$ELSE}
writeln;
writeln('PaybackTime 2 (C) 1997 N. Nevatie, K. Luojus.');
writeln;
writeln('This is the unregistered version of PaybackTime 2.');
writeln('Refer to REGISTER.ENG/FIN for info on registering.');
{$ENDIF}

wait(150);
error:=0;

{write('  Debug AI ? [Y/N] ');
repeat asm xor ax,ax;int $16;mov c,ah;end;until(c=#21)or(c=#49);
if(c=#21)then begin debug:=1;write('Y');end;
if(c=#49)then begin debug:=0;write('N');end;}

serror:=0;
if(checkfile('payback.cfg')=false)then exec('setup.exe','');

assign(f1,'payback.cfg');reset(f1);
read(f1,mver1,ver1,mem[seg(base):ofs(base)],mem[seg(base):ofs(base)+1],irq1,dma1);
mver:=mver1;ver:=ver1;irq:=irq1;dma:=dma1;
musics:=mver;if(ver=0)then sounds:=false else sounds:=true;
close(f1);
if(getenv('BLASTER')<>'') then
begin

{ Base-address check }

envstr:=getenv('BLASTER');
for i:=0 to length(envstr) do
  if(envstr[i]='A')or(envstr[i]='a') then break;
tstr[0]:=#4;
tstr[1]:='$';
for a:=1 to 3 do
  tstr[a+1]:=envstr[a+i];
val(tstr,t,code);
if(t<>base)and((ver<>0)or(mver<>0))then begin
writeln;
writeln('WARNING:');
writeln('BLASTER environment variable indicates a possible base-address');
writeln('conflict with the current sound settings. ');
writeln('Run setup to reconfigure your soundcard. ');
serror:=1;
end;

{ IRQ check }

envstr:=getenv('BLASTER');
for i:=0 to length(envstr) do
  if(envstr[i]='I')or(envstr[i]='i') then break;
tstr[0]:=#1;
tstr[1]:=envstr[i+1];
val(tstr,t,code);
if(t<>irq)and((ver<>0)or(mver<>0)) then begin
writeln;
writeln('WARNING:');
writeln('BLASTER environment variable indicates a possible IRQ');
writeln('conflict with the current sound settings. ');
writeln('Run setup to reconfigure your soundcard. ');
serror:=1;
end;

{ DMA check }

envstr:=getenv('BLASTER');
for i:=0 to length(envstr) do
  if(envstr[i]='D')or(envstr[i]='d') then break;
tstr[0]:=#1;
tstr[1]:=envstr[i+1];
val(tstr,t,code);
if(t<>dma)and((ver<>0)or(mver<>0)) then begin
writeln;
writeln('WARNING:');
writeln('BLASTER environment variable indicates a possible DMA');
writeln('conflict with the current sound settings. ');
writeln('Run setup to reconfigure your soundcard. ');
serror:=1;
end;

if(serror=1) then
begin
writeln;
writeln('Press any key to proceed.');
asm xor ax,ax;int 16h;end;
end;

end;

asm mov ax,12h;int 10h;end;
getmem(ma,64000);ownseg:=seg(ma^);

getmem(musaptr,14000);musaseg:=seg(musaptr^);
moffs:=ofs(musaptr^);

getmem(ma,7800);tuneseg:=seg(ma^);

avl:=memavail;
max:=maxavail;

initsound;
init;

pointer(linecoord[line]);
repeat

asm xor ax,ax;int 16h;mov c,ah;end;
if(c=#72)then begin
removep(linecoord[line]);
dec(line);if(line<1)then line:=6;
pointer(linecoord[line]);
end;

if(c=#80)then begin
removep(linecoord[line]);
inc(line);if(line>6)then line:=1;
pointer(linecoord[line]);
end;

if(c=#28)and(allowexe[line]=1)then begin

if(mver<>0)then begin
musics:=0;
endplayer;
timer:=0;
asm cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;end;
setvect(8,oldintseg,oldintofs);
end;

for i:=0 to 15 do
setpal(PEL_val[i],0,0,0);
freesound;

if(line<>6)then begin
str(ver,s1);
str(mver,s);
s1:=s1+' '+s;
str(base,s);
s1:=s1+' '+s;
str(dma,s);
s1:=s1+' '+s;
str(irq,s);
s1:=s1+' '+s;
str(ownseg,s);
s1:=s1+' '+s;
str(musaseg,s);
s1:=s1+' '+s;
lo1:=memw[seg(musaptr):ofs(musaptr)];
lo2:=memw[seg(musaptr):ofs(musaptr)+2];

str(lo1,s);
s1:=s1+' '+s;
str(lo2,s);
s1:=s1+' '+s;
str(debug,s);
s1:=s1+' '+s;
str(tuneseg,s);
s1:=s1+' '+s;
swapvectors;
exec('gamedata\'+exe[line],s1);
swapvectors;

if(dosexitcode<>0) then begin error:=8;goto exitp;end;

asm mov ax,12h;int 10h;end;
end else
begin
credits;
end;

initsound;
init;
pointer(linecoord[line]);

end;
until(c=#1);

exitp:
freesound;

if(mver<>0)then begin musics:=0;endplayer;setvect(8,oldintseg,oldintofs);end;

asm mov al,54;out $43,al;pusha;popa;mov cx,0; { fixing time }
mov al,cl;out $40,al;pusha;popa;mov al,ch;out $40,al;
mov ah,4;int $1a;mov ah,2;int $1a;mov bl,10;mov al,ch;and ch,15;shr al,4;mul bl;add ch,al;mov al,cl;and cl,15;
shr al,4;mul bl;add cl,al;mov al,dh;and dh,15;shr al,4;mul bl;add dh,al;mov dl,0;mov ah,$2d;int $21;end;
asm mov ax,3h;int 10h;end;

if(error=8) then
begin
writeln;
writeln('  Fatal       :  Not enough conventional memory!');
writeln('  Requirements:  598K of conventional memory required. ');
writeln;

end;
linear:=seg(musaptr^)*16+ofs(musaptr^);
startp:=linear div 65535;
maxb:=(startp+1)*65535-linear;

{writeln('total heap        : ',avl);
writeln('largest heap block: ',max);
writeln('musaseg           : ',musaseg);
writeln('musaoffs          : ',moffs);
writeln('latest block size : ',blocksize);
writeln('max. block size   : ',maxb);}

{$IFDEF unregistered}
writeln('                                Pay attention!');
writeln;
writeln('    This game is shareware and you are strongly encouraged to register it.');
writeln('         By paying the 20 USD register-fee (80 FIM from Finland),');
writeln('         you will be granted with:');
writeln;
writeln('         * The full registered version of the game (no limitations)');
writeln('         * The game-editors:  Weapon editor    (Weaponry Tomorrow Ltd.)');
writeln('                              Item editor      (Sunset Medi & Armor Co.)');
writeln('                              Map editor (MDC-Construction Inc.)');
writeln('         * Lots of superb, betatested mapfiles');
writeln('         * Many well-balanced weapon/item-sets');
writeln('         * Good karma (optional)');
writeln;
writeln('            Keep developers developing, make your contribution now!');
writeln;
writeln('        Please refer to REGISTER.ENG (REGISTER.FIN for finnish people)');
writeln('               for more details on registering PaybackTime 2.');
writeln;
{$ELSE}
if(error=0) then writeln('Thank you for playing PT2.');
{$ENDIF}
end.

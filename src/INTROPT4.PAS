uses crt,utils,sbunit;

const beatdec=8;
      beatdel=22;

const stupid_stars=100;
const scaler=16;

const vertices=81;
const faces=154;

const xcords:array[0..vertices-1] of integer=(
-153,-212,-69,-128,-96,-64,-41,45,63,7,37,-52,-14,-144,-122,-166,92,
75,147,209,136,212,203,73,66,164,132,-176,-244,-80,-148,-111,-74,
-47,52,72,8,43,-60,-16,-166,-140,-191,106,86,170,241,157,244,
234,84,76,189,152,-153,-212,-69,-128,-96,-64,-41,45,63,7,37,
-52,-14,-144,-122,-166,92,75,147,209,136,212,203,73,66,164,132
);

const ycords:array[0..vertices-1] of integer=(
-13,17,13,0,-13,7,13,14,6,6,-13,-13,6,4,9,11,7,
14,19,7,-9,-10,-19,-13,-6,7,12,54,54,54,54,54,54,
54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,
54,54,54,54,54,123,92,96,110,123,102,96,95,103,103,123,
123,103,105,100,98,102,95,90,102,119,120,129,123,116,102,97
);

const zcords:array[0..vertices-1] of integer=(
-73,92,75,-4,-72,40,75,76,33,32,-75,-73,32,22,51,61,39,
79,105,39,-49,-57,-105,-74,-36,38,65,-85,108,88,-5,-84,47,
88,89,39,38,-88,-85,38,26,60,71,46,93,124,46,-57,-67,
-124,-86,-42,44,76,-73,92,75,-4,-72,40,75,76,33,32,-75,
-73,32,22,51,61,39,79,105,39,-49,-57,-105,-74,-36,38,65
);

const facea:array[0..faces-1] of word=(
1,1,2,2,3,3,3,4,6,7,9,9,12,12,17,18,19,
19,20,20,20,20,21,0,0,1,1,2,2,3,3,4,4,
5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,
13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,
21,21,22,22,23,23,24,24,25,25,26,26,27,27,28,28,
29,29,30,30,31,31,32,32,33,33,34,34,35,35,36,36,
37,37,38,38,39,39,40,40,41,41,42,42,43,43,44,44,
45,45,46,46,47,47,48,48,49,49,50,50,51,51,52,52,
53,53,67,69,69,68,68,67,54,54,66,66,61,66,64,63,
80,80,80,79,79,78,77,76,76);

const faceb:array[0..faces-1] of word=(
0,13,1,15,2,14,13,3,5,6,8,7,11,10,16,17,18,
26,19,25,24,23,20,1,28,2,29,3,30,4,31,0,27,
6,33,7,34,8,35,9,36,10,37,11,38,12,39,5,32,
14,41,15,42,13,40,17,44,18,45,19,46,20,47,21,48,
22,49,23,50,24,51,25,52,26,53,16,43,28,55,29,56,
30,57,31,58,27,54,33,60,34,61,35,62,36,63,37,64,
38,65,39,66,32,59,41,68,42,69,40,67,44,71,45,72,
46,73,47,74,48,75,49,76,50,77,51,78,52,79,53,80,
43,70,54,67,55,69,56,68,67,57,59,60,62,61,65,64,
70,71,72,80,73,79,78,77,74);

const facec:array[0..faces-1] of word=(
13,15,15,14,14,13,0,0,12,12,7,12,10,9,26,26,26,
25,25,24,23,22,22,28,27,29,28,30,29,31,30,27,31,
33,32,34,33,35,34,36,35,37,36,38,37,39,38,32,39,
41,40,42,41,40,42,44,43,45,44,46,45,47,46,48,47,
49,48,50,49,51,50,52,51,53,52,43,53,55,54,56,55,
57,56,58,57,54,58,60,59,61,60,62,61,63,62,64,63,
65,64,66,65,59,66,68,67,69,68,67,69,71,70,72,71,
73,72,74,73,75,74,76,75,77,76,78,77,79,78,80,79,
70,80,55,55,56,56,57,57,57,58,60,61,63,63,66,66,
71,72,73,73,74,74,74,74,75);

const paldata:array[0..767] of integer=(
0,0,0,0,1,6,0,1,6,0,1,
6,0,1,7,0,1,7,0,1,8,
0,2,8,0,2,8,0,2,9,0,
2,9,0,2,9,0,2,10,0,3,
10,0,3,11,0,3,11,0,3,11,
0,3,12,1,4,12,1,4,12,1,
4,13,1,4,13,1,4,14,1,5,
14,1,5,14,1,5,15,1,5,15,
2,5,15,2,6,16,2,6,16,2,
6,17,2,6,17,2,7,17,3,7,
18,3,7,18,3,7,18,3,8,19,
4,8,19,4,8,20,4,8,20,4,
9,20,4,9,21,5,9,21,5,10,
21,5,10,22,5,10,22,6,11,23,
6,11,23,6,11,23,7,11,24,7,
12,24,7,12,24,7,12,25,8,13,
25,8,13,26,8,13,26,9,14,26,
9,14,27,9,14,27,10,15,28,10,
15,28,10,15,28,11,16,29,11,16,
29,11,16,29,12,17,30,12,17,30,
13,18,31,13,18,31,13,18,31,14,
19,32,14,19,32,14,20,32,15,20,
33,15,20,33,16,21,34,16,21,34,
17,22,34,17,22,35,17,22,35,18,
23,35,18,23,36,19,24,36,19,24,
37,20,24,37,20,25,37,21,25,38,
21,26,38,21,26,38,22,27,39,22,
27,39,23,28,40,23,28,40,24,29,
40,24,29,41,25,30,41,25,30,41,
26,31,42,26,31,42,27,31,43,27,
32,43,28,33,43,29,33,44,29,33,
44,30,34,45,30,35,45,31,35,45,
31,36,46,32,36,46,33,37,46,33,
37,47,34,38,47,34,38,48,35,39,
48,36,39,48,36,40,49,37,40,49,
37,41,49,38,42,50,39,42,50,39,
43,51,40,43,51,41,44,51,41,44,
52,42,45,52,43,45,52,43,46,53,
44,47,53,45,47,54,45,48,54,46,
48,54,47,49,55,47,50,55,48,50,
55,49,51,56,49,51,56,50,52,57,
51,53,57,52,53,57,52,54,58,53,
55,58,54,55,58,55,56,59,55,56,
59,56,57,60,57,58,60,58,58,60,
58,59,61,59,60,61,60,60,61,61,
61,62,61,62,62,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,63,63,63);

var wo,i,a:word;
    px,py,su,xa,ya,za,sza,zo:integer;
    ownseg:word;
    muzak,mver1,ver1,irq1,dma1,db:byte;
    p:pointer;
    f:file;f1:file of byte;
    lx,ly,tx,ty:longint;
    avex,avey,avez:array[0..faces-1] of longint;
    polcol:integer;
    tz:array[0..vertices-1] of longint;
    otd:array[0..faces-1] of word;
    vx,vy,vz:longint;
    dx,dy:array[0..vertices-1] of integer;
    sit,cot:array[0..359] of longint;
    a1,xadd,cadd,yadd,zadd:shortint;
    yco:integer;
    oldintseg,oldintofs,timer:word;
    s:string;
    ma:pointer;
    intno,beatdelay:word;
    currentpal:array[0..768] of integer;
    c:char;
    spx, spy, red, green:longint;
    star_x, star_y, star_z:array[0..stupid_stars] of integer;

label endi;

procedure mblur(segi:word);
assembler;
asm
   mov es,segi
   xor di,di
   mov cx,65535
@mblur1:
   mov al,[es:di+320]
   add al,[es:di+321]
   add al,[es:di+319]
   add al,[es:di+640]
   shr al, 2
   sub al, 1
   jnc @ok
   xor al,al
@ok:
   mov [es:di],al
   inc di
   dec cx
   jnz @mblur1
end;

procedure quicksort(lo,hi:integer);
var i,j,x,y:longint;
begin i:=lo;j:=hi;x:=avez[(lo+hi) div 2];
repeat
while avez[i]<x do inc(i);while x<avez[j] do dec(j);
if i<=j then begin y:=avez[i];avez[i]:=avez[j];avez[j]:=y;y:=otd[i];otd[i]:=otd[j];otd[j]:=y;inc(i);dec(j);end;
until i>j;
if lo<j then quicksort(lo,j);if i<hi then quicksort(i,hi);
end;

procedure musicint;interrupt;
var t:word;
begin
asm mov al,20h;out 20h,al;end;
{if(mver<>0)and(muzak=1)then playmusic;}

if(intno=0) then begin
for t:=1 to 255 do
begin
if(currentpal[t*3]>paldata[t*3]) then dec(currentpal[t*3],beatdec);
if(currentpal[t*3+1]>paldata[t*3+1]) then dec(currentpal[t*3+1],beatdec);
if(currentpal[t*3+2]>paldata[t*3+2]) then dec(currentpal[t*3+2],beatdec);

if(currentpal[t*3]<paldata[t*3]) then currentpal[t*3]:=paldata[t*3];
if(currentpal[t*3+1]<paldata[t*3+1]) then currentpal[t*3+1]:=paldata[t*3+1];
if(currentpal[t*3+2]<paldata[t*3+2]) then currentpal[t*3+2]:=paldata[t*3+2];

setpal(t,currentpal[t*3],currentpal[t*3+1],currentpal[t*3+2]);
end;

if(beatdelay=0) then begin
for t:=1 to 255 do  begin
currentpal[t*3]:=63;
currentpal[t*3+1]:=63;
currentpal[t*3+2]:=63;
end;
beatdelay:=beatdel;
end;

dec(beatdelay);
end;

end;

procedure getvect(vec:byte);assembler;
asm mov ah,$35;mov al,vec;int $21;mov oldintseg,es;mov oldintofs,bx;end;

procedure setvect(vec:byte;tseg,tofs:word);assembler;
asm push ds;mov ah,$25;mov al,vec;mov dx,tofs;mov ds,tseg;int $21;pop ds;end;

begin
assign(f1,'payback.cfg');reset(f1);
read(f1,mver1,ver1,mem[seg(base):ofs(base)],mem[seg(base):ofs(base)+1],irq1,dma1);
mver:=mver1;ver:=ver1;irq:=irq1;dma:=dma1;
musics:=mver;if(ver=0)then sounds:=false else sounds:=true;
close(f1);

getmem(ma,12000);tuneseg:=seg(ma^);

s:='intro.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
initplayer(tuneseg);
intno:=0;
beatdelay:=beatdel;

getvect(8);
setvect(8,seg(musicint),ofs(musicint));
timer:=round(1193180/60);
asm cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;end;

muzak:=1;

for wo:=0 to 359 do
begin
sit[wo]:=round(sin(wo*pi/140)*1024);
cot[wo]:=round(cos(wo*pi/180)*1024);
end;

for wo:=0 to stupid_stars do begin
star_x[wo]:=random(800);
star_y[wo]:=random(200)-100;
star_z[wo]:=random(800)+300;
end;

asm
mov ax,13h
int 10h
end;
clearb($a000,65535);
for wo:=0 to 255 do setpal(wo,paldata[wo*3],paldata[wo*3+1],paldata[wo*3+2]);

getmem(p,65535);
ownseg:=seg(p^);
clearb(ownseg,64000);

zo:=450;
xa:=270;
ya:=90;
za:=90;
sza:=0;
su:=2;
yadd:=1;
xadd:=4;
zadd:=2;
yco:=60;
cadd:=0;

clearb(ownseg,64000);

repeat
{clearb(ownseg,64000);}
mblur(ownseg);

for i:=0 to stupid_stars do
begin
spx:=((star_x[i] shl 8) div star_z[i])+160;
spy:=((star_y[i] shl 8) div star_z[i])+100;
mem[ownseg:spy*320+spx]:=255-(star_z[i] shr 2);
dec(star_z[i],10);
if(star_z[i]<250) then star_z[i]:=1000;
end;

for i:=0 to vertices-1 do
begin

vx:=(cot[za]*xcords[i]+sit[za]*(ycords[i]))div 1024;
vy:=(cot[za]*(ycords[i])-sit[za]*xcords[i])div 1024;
vz:=(cot[xa]*zcords[i]-sit[xa]*vy)div 1024;
tx:=(cot[ya]*vx-sit[ya]*vz)div 1024;
ty:=(cot[xa]*vy+sit[xa]*zcords[i])div 1024+yco;
tz[i]:=(cot[ya]*vz+sit[ya]*vx)div 1024;

if(tz[i]=-zo)then inc(tz[i]);
dx[i]:=(tx shl 8) div (tz[i]+zo)+160+sit[za] div 50;
dy[i]:=(ty shl 8) div (tz[i]+zo)+100+cot[za] div 50;

end;

for wo:=0 to faces-1 do
begin
{avex[wo]:=(dx[facea[wo]]+dx[faceb[wo]]+dx[facec[wo]]) div 3;
avey[wo]:=(dy[facea[wo]]+dy[faceb[wo]]+dy[facec[wo]]) div 3;}
avez[wo]:=(tz[facea[wo]]+tz[faceb[wo]]+tz[facec[wo]]) div 3;
otd[wo]:=wo;
end;
quicksort(0,faces-1);

for i:=faces-50 downto 0 do
{if(avex[otd[i]]>-50)and(avex[otd[i]]<370)and(avey[otd[i]]>-50)and(avey[otd[i]]<250)and
(avez[i]+zo>100)then}
begin

polcol:=-(avez[i] shr 1)+70;
if polcol>255 then polcol:=255;
if polcol<0 then polcol:=0;

xquadra(
dx[facea[otd[i]]],dy[facea[otd[i]]],
dx[faceb[otd[i]]],dy[faceb[otd[i]]],
dx[facec[otd[i]]],dy[facec[otd[i]]],
dx[facec[otd[i]]],dy[facec[otd[i]]],
polcol,ownseg);

{dline(dx[facea[otd[i]]],dy[facea[otd[i]]],
      dx[faceb[otd[i]]],dy[faceb[otd[i]]],polcol,ownseg);
dline(dx[faceb[otd[i]]],dy[faceb[otd[i]]],
      dx[facec[otd[i]]],dy[facec[otd[i]]],polcol,ownseg);
dline(dx[facec[otd[i]]],dy[facec[otd[i]]],
      dx[facea[otd[i]]],dy[facea[otd[i]]],polcol,ownseg);
}
end;

wait(1);
copyb(ownseg,$a000,0,0,64000);

inc(zo,su);
if(zo>1000) then
 begin
 su:=0;
 yadd:=0;
 zadd:=0;
 xadd:=0;
 cadd:=0;

 su:=-2;
 yadd:=1;
 zadd:=4;
 xadd:=2;
 cadd:=0;

 end;

 inc(yco,cadd);

inc(xa,xadd);
if xa>=360 then dec(xa,360);
if xa<0 then inc(xa,360);

inc(ya,yadd);
if ya>=360 then dec(ya,360);
if ya<0 then inc(ya,360);

inc(za,zadd);
if za>=360 then dec(za,360);
if za<0 then inc(za,360);
inc(sza,1);
if sza>359 then dec(sza,360);

if(su<0) and(zo<550) then begin
su:=2;
yadd:=1;
xadd:=4;
zadd:=2;
end;

until keypressed;
{ dummy }
asm xor ax,ax;int 16h;mov c,ah;end;

endi:
{wait(1);}
for i:=0 to 255 do setpal(0,a,a,a);
clearb($a000,64000);
s:='boom.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
initplayer(tuneseg);

intno:=1;
a1:=63;
{for wo:=1 to 64 do begin
wait(3);
setpal(0,a1,a1,a1);
dec(a1,1);
end;
wait(25);
}
muzak:=0;
wait(50);
setvideo(3);
{endplayer;}
setvect(8,oldintseg,oldintofs);
end.

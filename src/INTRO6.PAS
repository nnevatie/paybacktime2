{$M 1024,0,640000}
uses crt,utils,sbunit;

const beatdec=2;
      beatdel=128;
      mfade=16;
const scaler=16;

const vertices=130;
const faces=256;

const xcords:array[0..vertices-1] of integer=(
-58,-933,520,-110,-190,-315,-319,-514,-1139,-611,-614,86,224,345,443,512,1056,
552,-71,-83,-94,-103,-109,-113,-113,-468,-263,-174,-13,145,293,719,539,
408,476,829,293,160,31,-245,-370,-476,-1124,-614,-637,-627,-44,-172,99,
-287,-26,230,-382,-141,110,339,-446,-236,-4,179,412,-312,-300,-104,95,
282,439,81,237,82,387,264,689,914,444,300,106,603,578,480,318,
112,606,602,540,426,269,84,-212,-240,-684,-274,-413,-497,-311,-477,-585,
-620,-331,-517,-605,-713,-700,-305,-325,-610,-696,-726,-698,-521,-536,-381,-504,
-380,-208,-309,-307,-163,-5,-273,-152,-19,108,216,-107,-3,168,282,367,
414);

const ycords:array[0..vertices-1] of integer=(
-223,-937,-497,414,-315,-401,-498,-539,-583,-606,-608,-292,-357,-414,-460,-493,-511,
-512,-63,87,221,329,406,1032,450,-677,-598,-774,-776,-747,-689,-1268,-352,
-258,-49,505,215,205,381,358,269,152,362,-138,-295,-448,-393,-499,-477,
-606,-614,-1148,-702,-756,-735,-643,-763,-1321,-876,-706,-598,-750,-846,-888,-872,
-799,-675,-126,-184,39,-231,0,196,-2,-29,178,330,-290,-61,148,315,
418,-321,-122,68,233,358,433,-150,12,-87,166,-55,-303,296,114,-114,
-358,244,246,56,-261,-397,401,313,148,-32,-231,-428,-544,-388,-612,-216,
-447,-643,-115,-242,-485,-627,151,-10,-196,-386,-557,300,80,55,-109,-284,
-454);

const zcords:array[0..vertices-1] of integer=(
679,-226,-226,-226,660,603,416,392,557,93,-68,660,603,512,392,249,328,
-68,660,603,512,392,249,93,-68,-295,-156,-381,-392,-381,-348,-295,-295,
-348,-381,-512,-381,-348,-295,-295,-348,-381,-392,-381,-348,-295,657,610,610,
512,554,1046,356,414,414,356,140,222,181,378,37,-81,-121,-133,-133,
-121,-99,657,610,610,512,554,892,548,414,414,356,140,171,181,171,
140,-99,-121,-133,-133,-121,-99,657,610,1041,512,554,512,356,414,414,
356,54,171,163,257,140,-99,-185,-133,-133,-121,-99,-379,-454,-454,-512,
-554,-512,-484,-631,-1113,-544,-524,-638,-677,-638,-524,-429,-327,-576,-576,-526,
-429);

const facea:array[0..faces-1] of word=(
0,4,4,11,5,5,46,46,12,6,6,47,47,48,48,13,7,
7,49,49,50,50,51,51,14,8,8,52,52,53,53,54,54,
55,55,15,9,9,56,56,57,57,58,58,59,59,60,60,16,
10,10,61,61,62,62,63,63,64,64,65,65,66,66,17,0,
11,11,18,12,12,67,67,19,13,13,68,68,69,69,20,14,
14,70,70,71,71,72,72,21,15,15,73,73,74,74,75,75,
76,76,22,16,16,77,77,78,78,79,79,80,80,81,81,23,
17,17,82,82,83,83,84,84,85,85,86,86,87,87,24,0,
18,18,4,19,19,88,88,5,20,20,89,89,90,90,6,21,
21,91,91,92,92,93,93,7,22,22,94,94,95,95,96,96,
97,97,8,23,23,98,98,99,99,100,100,101,101,102,102,9,
24,24,103,103,104,104,105,105,106,106,107,107,108,108,10,1,
45,45,25,44,44,109,109,26,43,43,110,110,111,111,27,42,
42,112,112,113,113,114,114,28,41,41,115,115,116,116,117,117,
118,118,29,40,40,119,119,120,120,121,121,122,122,123,123,30,
39,39,124,124,125,125,126,126,127,127,128,128,129,129,31);

const faceb:array[0..faces-1] of word=(
4,5,46,46,6,47,47,48,48,7,49,49,50,50,51,51,8,
52,52,53,53,54,54,55,55,9,56,56,57,57,58,58,59,
59,60,60,10,61,61,62,62,63,63,64,64,65,65,66,66,
1,25,25,26,26,27,27,28,28,29,29,30,30,31,31,11,
12,67,67,13,68,68,69,69,14,70,70,71,71,72,72,15,
73,73,74,74,75,75,76,76,16,77,77,78,78,79,79,80,
80,81,81,17,82,82,83,83,84,84,85,85,86,86,87,87,
2,32,32,33,33,34,34,35,35,36,36,37,37,38,38,18,
19,88,88,20,89,89,90,90,21,91,91,92,92,93,93,22,
94,94,95,95,96,96,97,97,23,98,98,99,99,100,100,101,
101,102,102,24,103,103,104,104,105,105,106,106,107,107,108,108,
3,39,39,40,40,41,41,42,42,43,43,44,44,45,45,45,
44,109,109,43,110,110,111,111,42,112,112,113,113,114,114,41,
115,115,116,116,117,117,118,118,40,119,119,120,120,121,121,122,
122,123,123,39,124,124,125,125,126,126,127,127,128,128,129,129,
3,38,38,37,37,36,36,35,35,34,34,33,33,32,32);

const facec:array[0..faces-1] of word=(
11,46,11,12,47,46,48,12,13,49,47,50,48,51,13,14,52,
49,53,50,54,51,55,14,15,56,52,57,53,58,54,59,55,
60,15,16,61,56,62,57,63,58,64,59,65,60,66,16,17,
25,61,26,62,27,63,28,64,29,65,30,66,31,17,2,18,
67,18,19,68,67,69,19,20,70,68,71,69,72,20,21,73,
70,74,71,75,72,76,21,22,77,73,78,74,79,75,80,76,
81,22,23,82,77,83,78,84,79,85,80,86,81,87,23,24,
32,82,33,83,34,84,35,85,36,86,37,87,38,24,3,4,
88,4,5,89,88,90,5,6,91,89,92,90,93,6,7,94,
91,95,92,96,93,97,7,8,98,94,99,95,100,96,101,97,
102,8,9,103,98,104,99,105,100,106,101,107,102,108,9,10,
39,103,40,104,41,105,42,106,43,107,44,108,45,10,1,25,
109,25,26,110,109,111,26,27,112,110,113,111,114,27,28,115,
112,116,113,117,114,118,28,29,119,115,120,116,121,117,122,118,
123,29,30,124,119,125,120,126,121,127,122,128,123,129,30,31,
38,124,37,125,36,126,35,127,34,128,33,129,32,31,2);

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
    zoomseg1, zoomseg2, ownseg1, ownseg2, curseg, otherseg:word;
    muzak,mver1,ver1,irq1,dma1,db:byte;
    p:pointer;
    f:file;f1:file of byte;
    lx,ly,tx,ty:longint;
    avex,avey,avez:array[0..faces-1] of longint;
    polcol1,polcol2,polcol3:integer;
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
    newx, newy, fromoffs, count:longint;
    spx, spy: integer;
label endi;

procedure mblur(segi:word);
assembler;
asm
   mov  dx,curseg
   xor  di,di
   mov  cx,otherseg
   push ds
   mov  ds,zoomseg1
   mov  si,64000
   mov  di,32000

@mblur1:
   xor  ax, ax
   mov  es, cx
   mov  bx, [ds:si]
   mov  al, [es:bx]
   sub  al, mfade
   jnc   @nope1
   xor  al, al
@nope1:
   mov  es, dx
   mov  [es:di], al
   
   sub  si,2
   dec  di
   jnz  @mblur1
   pop  ds

   push ds
   mov  ds,zoomseg2
   mov  si,64000
   mov  di,32000
@mblur2:
   mov  es, cx
   mov  bx, [ds:si]
   mov  al, [es:bx]
   sub  al, mfade
   jnc   @nope2
   xor  al, al
@nope2:
   mov  es, dx
   mov  [es:di+32000], al
   sub  si,2
   dec  di
   jnz  @mblur2
   pop  ds

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
{
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
}
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

{getmem(ma,12000);tuneseg:=seg(ma^);

s:='c:\payback\music\start.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);}
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
sit[wo]:=round(sin(wo*pi/150)*1024);
cot[wo]:=round(cos(wo*pi/180)*1024);
end;

asm
mov ax,13h
int 10h
end;

clearb($a000,65535);
for wo:=0 to 255 do setpal(wo,paldata[wo*3],paldata[wo*3+1],paldata[wo*3+2]);

getmem(p,65535);
ownseg1:=seg(p^);
clearb(ownseg1,65535);
getmem(p,65535);
ownseg2:=seg(p^);
clearb(ownseg2,65535);

getmem(p,65535);
zoomseg1:=seg(p^);
clearb(zoomseg1,65535);
getmem(p,65535);
zoomseg2:=seg(p^);
clearb(zoomseg2,65535);

spx:=0;
spy:=0;
for count:=0 to 31999 do
begin
newx:=round((spx-160)/1.4)+160;
newy:=round((spy-100)/1.2)+100;
fromoffs:=(newy*320)+newx;
memw[zoomseg1:count*2]:=fromoffs;
inc(spx,1);
if(spx=320)then begin inc(spy,1);spx:=0;end;
end;

for count:=32000 to 63999 do
begin
newx:=round((spx-160)/1.4)+160;
newy:=round((spy-100)/1.2)+100;
fromoffs:=(newy*320)+newx;
memw[zoomseg2:count*2-64000]:=fromoffs;
inc(spx,1);
if(spx=320)then begin inc(spy,1);spx:=0;end;
end;

zo:=5000;
xa:=270;
ya:=90;
za:=90;
sza:=0;
su:=0;
yadd:=1;
xadd:=4;
zadd:=2;
yco:=60;
cadd:=0;

curseg:=ownseg1;
otherseg:=ownseg2;
repeat
{clearb(curseg,64000);}
mblur(curseg);

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

polcol1:=-(avez[i] shr 3)+60;
if polcol1>255 then polcol1:=255;
if polcol1<0 then polcol1:=0;

{polcol1:=-(tz[facea[otd[i]]] shr 3)+60;
if polcol1>255 then polcol1:=255;
if polcol1<0 then polcol1:=0;

polcol2:=-(tz[faceb[otd[i]]] shr 3)+60;
if polcol2>255 then polcol2:=255;
if polcol2<0 then polcol2:=0;

polcol3:=-(tz[facec[otd[i]]] shr 3)+60;
if polcol3>255 then polcol3:=255;
if polcol3<0 then polcol3:=0;}

xquadra(
dx[facea[otd[i]]],dy[facea[otd[i]]],
dx[faceb[otd[i]]],dy[faceb[otd[i]]],
dx[facec[otd[i]]],dy[facec[otd[i]]],
dx[facec[otd[i]]],dy[facec[otd[i]]],
polcol1,curseg);

{xtetragourad(
dx[facea[otd[i]]],dy[facea[otd[i]]],polcol1,
dx[faceb[otd[i]]],dy[faceb[otd[i]]],polcol2,
dx[facec[otd[i]]],dy[facec[otd[i]]],polcol3,
curseg);}

{dline(dx[facea[otd[i]]],dy[facea[otd[i]]],
      dx[faceb[otd[i]]],dy[faceb[otd[i]]],polcol,curseg);
dline(dx[faceb[otd[i]]],dy[faceb[otd[i]]],
      dx[facec[otd[i]]],dy[facec[otd[i]]],polcol,curseg);
dline(dx[facec[otd[i]]],dy[facec[otd[i]]],
      dx[facea[otd[i]]],dy[facea[otd[i]]],polcol,curseg);}

end;

wait(1);
copyb(curseg,$a000,0,0,64000);

inc(zo,su);
if(zo>50000) then
 begin
 su:=0;
 yadd:=0;
 zadd:=0;
 xadd:=0;
 cadd:=0;

 su:=-10;
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

if(su<0) and(zo<6000) then begin
su:=-10;
yadd:=1;
xadd:=4;
zadd:=2;
end;

if(curseg=ownseg1)then curseg:=ownseg2 else curseg:=ownseg1;
if(otherseg=ownseg1)then otherseg:=ownseg2 else otherseg:=ownseg1;

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
{a1:=63;
for wo:=1 to 64 do begin
wait(3);
setpal(0,a1,a1,a1);
dec(a1,1);
end;

muzak:=0;
wait(50);
}
setvideo(3);
{endplayer;}
setvect(8,oldintseg,oldintofs);
end.

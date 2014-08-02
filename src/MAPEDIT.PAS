{$M 16000,0,250000}
{$F+}
const icol=79;

var out,grs1,grs2,grs3,grs4,depcon,depment,cmapx,cmapy,mapx,mapy,mp:byte;
    c1,c:char;dep,n3d,sav,depl,con,lop,ow,nofils,away:boolean;
    f:file;f1:file of byte;s,s1,svfname:string;ma:pointer;
    im,im1,id,id1,wd,wd1,dd,dd1,i,a,i1,a1,ni,tem,px,py,cx1,cy1,cx2,cy2:integer;
    le,depinfseg,picseg,newseg,loadseg,mapseg,ownseg,gfxseg,infoseg,x3,wo:word;
    fontseg,line,page,fils,filseg,filofs,dtaseg,dtaofs,a3,i3,code:word;
    map,depmap:array [-9..109,-9..118] of byte;
    deplable:array[1..100] of boolean;
    lightx,lighty,lightt:array[1..200] of byte;
    tl,tl2,light:byte;
    lightmap:array[-10..110,-10..110] of byte;
    preclights:array[1..3,-10..10,-10..10] of byte;
    losseg,losofs,entseg,entofs:word;
    lightable:array[0..80] of boolean;
    lmode,ambil,oldambil,lightamo:byte;

const tgfxofs:array[1..90] of word=(0,256,512,768,1120,1754,2388,3100,3656,4230,4804,5516,6228,6862,7496,8208,8829,9450,10138,
10954,11770,12484,13198,14094,14748,15484,16040,16694,17128,17562,18078,18802,19436,20070,20684,21298,21810,22328,22902,23476,
23948,24410,24762,25110,26006,26646,27133,27620,28122,28624,29107,29589,30076,30538,31050,31406,31866,32378,32890,33420,33950,
34368,34756,35174,35562,35818,36074,36330,36600,36888,37175,37462,37760,38114,38371,38731,39053,39400,39717,40040,40694,41383,
42225,43080,43932,44790,45662,46510,47279,47781);

const tinfofs:array[1..90] of word=(0,60,120,180,252,384,516,656,776,908,1040,1180,1320,1452,1584,1724,1876,2028,2160,2300,
2440,2572,2704,2844,2976,3116,3236,3368,3504,3640,3744,3876,4008,4140,4272,4404,4580,4764,4892,5020,5188,5364,5452,5544,5684,
5792,5884,5976,6068,6160,6252,6344,6436,6528,6620,6840,6940,7056,7172,7288,7404,7516,7612,7724,7820,7880,7940,8000,8076,8152,
8228,8304,8380,8460,8520,8688,8828,8952,9084,9160,10128,10280,10424,10556,10688,10828,10960,11152,11480,12052);

const ttimes:array[1..90] of word=(15,15,15,18,33,33,35,30,33,33,35,35,33,33,35,38,38,33,35,35,33,33,35,33,35,30,33,34,34,26,
33,33,33,33,33,44,46,32,32,42,44,22,23,35,27,23,23,23,23,23,23,23,23,23,55,25,29,29,29,29,28,24,28,24,15,15,15,19,19,19,19,19,
20,15,42,35,31,33,19,242,38,36,33,33,35,33,48,82,143,112);

const de:array[1..161] of byte=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);


const lightval:array[1..11] of longint=
($0a0a0a0a,
$09090909,
$08080808,
$07070707,
$06060606,
$05050505,
$04040404,
$03030303,
$02020202,
$01010101,
$00000000);

{$L ASMTOOLS.OBJ}
procedure wipe(seg1,seg2,off1,off2,amount:word);external;
procedure put2d(toseg1,cord1,gfxseg1,gfxofs1:word;decment:longint);external;
procedure clear(segm,siz:word);external;
procedure fastp(ligval,toseg,cord,times,gfxofs,infofs,gseg,iseg:word);external;
{procedure los(x1,y1,x2,y2,mapseg,mapoffs,entseg1,entofs1:word);external;}
procedure fontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure fontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;
procedure sfontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure sfontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;

procedure helpscreen;
var hscreen:byte;
begin

assign(f,'gfx\maphelp.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
wipe(ownseg,$a000,0,0,16000);
asm xor ax,ax;int 16h;end;
end;

procedure line_of_sight(x1,y1,x2,y2:word);
assembler;
var start,ddx,ddy,sx,sy:word;              { locals }
asm
    { losseg,losofs,entseg,entofs }

    mov  ax,[y1]
    mov  es,losseg
    mov  di,[x1]

    cmp  ax,[y2]
    jne  @ok_coords
    cmp  di,[x2]
    jne  @ok_coords
    mov  al,1
    jmp  @exit

@ok_coords:

    shl  di,7
    mov  si,entofs
    xor  bx,bx
    add  di,losofs
    push ds
    add  di,ax
    mov  ds,entseg    { locals should stay in codeseg... }
    sub  di,129

    clc
    mov  ax,[x2]
    mov  dx,128
    sub  ax,[x1]
    jnc  @l1
    neg  ax
    mov  dx,-128 { 0ffffh }
@l1:
    mov  [ddx],ax
    mov  [sx],dx
    mov  ax,[y2]
    clc
    mov  dx,1    { width of map }
    sub  ax,[y1]
    jnc  @l2
    neg  ax
    mov  dx,-1   { -width of map }
@l2:
    mov  [start],di

    mov  [ddy],ax
    mov  [sy],dx
    cmp  ax,[ddx]
    ja   @l5
    mov  cx,[ddx]
    mov  dx,[ddx]
{    inc  cl}
    shr  dx,1

    { ok, let's check it }
@l3:
    mov  bl,[es:di]       { al=map[di] }
    mov  al,[ds:si+bx]    { al=enterable or not }
    or   al,al
    je   @done1

@no1:
    clc
    add  di,[sx]
    sub  dx,[ddy]
    jnc  @l4
    add  di,[sy]
    add  dx,[ddx]
@l4:
    dec  cl
    jnz  @l3
    jmp  @l8
@l5:
    mov  cx,[ddy]
{    inc  cl}
    mov  dx,[ddy]
    shr  dx,1

    { ok, let's check it }
@l6:
    mov  bl,[es:di]       { al=map[di] }
    mov  al,[ds:si+bx]    { al=enterable or not }
    or   al,al
    je   @done2

@no2:
    clc
    add  di,[sy]
    sub  dx,[ddx]
    jnc  @l7
    add  di,[sx]
    add  dx,[ddy]
@l7:
    dec  cl
    jnz  @l6
@l8:
    mov  al,1
    pop  ds
    jmp  @exit

@done1:
    { check if we'll have to fake the visibility }
    { CASE: The first block (should be seen) }
    cmp di,[start]
    je  @no1

@done2:
    { check if we'll have to fake the visibility }
    { CASE: The first block (should be seen) }
    cmp di,[start]
    je  @no2

    pop  ds
@exit:

end;


procedure wait(t:longint);
var w:longint;
begin
for w:=1 to t do
asm
mov dx,$3da;@vert1:in al,dx;test al,8;jz @vert1;@vert2:in al,dx;test al,8;jnz @vert2;
end;
end;

procedure depput(toseg,cord,infoseg:word;col:byte);assembler;
asm push ds;mov cl,col;mov es,toseg;mov di,cord;xor dx,dx;xor si,si;mov ds,infoseg;
@mainloop: mov ax,[ds:si];add di,ax;add si,2;mov [es:di],cl;
inc dx;cmp dx,224;jb @mainloop;pop ds;end;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

procedure window(x1,y1,x2,y2,col:integer);
var x,y,wo:word;
begin
for x:=x1 to x2 do for y:=y1 to y2 do mem[ownseg:y*320+x]:=0;
for x:=x1 to x2 do begin mem[ownseg:y1*320+x]:=col;mem[ownseg:y2*320+x]:=col;end;
for y:=y1 to y2 do begin mem[ownseg:y*320+x1]:=col;mem[ownseg:y*320+x2]:=col;end;
end;

procedure fastfont(snew:string;x,y,col,bcol,toseg,tpar,shad:word);
begin
if(tpar=0)and(shad=0)then fontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=0)then fontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,mem[seg(snew):ofs(snew)]);
if(tpar=0)and(shad=1)then sfontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=1)then sfontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,mem[seg(snew):ofs(snew)]);
end;

procedure textxy(x,y:integer;text:string;col:byte);
begin
fastfont(text,x,y,col,0,ownseg,1,1);
end;

procedure text(x,y:integer;col,bgcol:byte;text:string);
begin
fastfont(text,x,y,col,bgcol,ownseg,0,1);
end;

function keypress:boolean;label nt;begin asm mov ah,1;int 16h;jnz nt end;keypress:=false;nt:end;

procedure goxy(x,y:byte);assembler;asm mov ah,2;mov dh,y;mov dl,x;mov bh,0;int 10h end;

procedure lball(cord:word;size:byte);
var colt:longint;
begin
if size<=3 then colt:=$f2f2f2f2 else
begin colt:=$04040404;
dec(size,3);
end;
if size=1 then
begin
inc(cord,963);
memw[ownseg:cord]:=colt;
memw[ownseg:cord+320]:=colt;
end;
if size=2 then
begin
inc(cord,642);
memw[ownseg:cord+1]:=colt;
meml[ownseg:cord+320]:=colt;
meml[ownseg:cord+640]:=colt;
memw[ownseg:cord+961]:=colt;
end;
if size=3 then
begin
inc(cord,321);
meml[ownseg:cord+1]:=colt;
memw[ownseg:cord+320]:=colt;
meml[ownseg:cord+322]:=colt;
memw[ownseg:cord+640]:=colt;
meml[ownseg:cord+642]:=colt;
memw[ownseg:cord+960]:=colt;
meml[ownseg:cord+962]:=colt;
memw[ownseg:cord+1280]:=colt;
meml[ownseg:cord+1282]:=colt;
meml[ownseg:cord+1601]:=colt;
end;
end;

procedure lball3d(cord:word;size:byte);
var colt:longint;
begin
if size<=3 then colt:=$f2f2f2f2 else
begin colt:=$04040404;
dec(size,3);
end;
if size=1 then
begin
inc(cord,873);

memw[mapseg:cord]:=colt;
memw[mapseg:cord+290]:=colt;
end;
if size=2 then
begin
inc(cord,582);
memw[mapseg:cord+1]:=colt;
meml[mapseg:cord+290]:=colt;
meml[mapseg:cord+580]:=colt;
memw[mapseg:cord+871]:=colt;
end;
if size=3 then
begin
inc(cord,291);
meml[mapseg:cord+1]:=colt;
memw[mapseg:cord+290]:=colt;
meml[mapseg:cord+292]:=colt;
memw[mapseg:cord+580]:=colt;
meml[mapseg:cord+582]:=colt;
memw[mapseg:cord+870]:=colt;
meml[mapseg:cord+872]:=colt;
memw[mapseg:cord+1160]:=colt;
meml[mapseg:cord+1162]:=colt;
meml[mapseg:cord+1451]:=colt;
end;
end;

procedure updateball;
begin
for i:=0 to 7 do wipe(picseg,ownseg,(i shl 8)+(i shl 6),11812+(i shl 8)+(i shl 6),2);
lball(11812,light);
end;

procedure updateball2;
begin
for i:=0 to 7 do wipe(picseg,ownseg,(i shl 8)+(i shl 6),282+116*320+(i shl 8)+(i shl 6),2);
lball(282+116*320,light);
end;

procedure calclights;
var tlight,xt,yt,xt1,yt1:integer;
    lio,lirange:byte;
    tlt:byte;
begin
for yt:=1 to mapy do
for xt:=1 to mapx do
lightmap[xt,yt]:=1;
for yt:=1 to mapy do
for xt:=1 to mapx do
if (lmode=1)and(lightamo>0) then
begin
for i:=1 to lightamo do
begin
if (lightx[i]=xt)and(lighty[i]=yt)then
   begin
   tlt:=lightt[i];
   if tlt>3 then dec(tlt,3);
   for yt1:=yt-(1+tlt*3) to yt+(1+tlt*3) do
   for xt1:=xt-(1+tlt*3) to xt+(1+tlt*3) do
       begin
       line_of_sight(xt,yt,xt1,yt1);
        asm
        mov lio,al
        end;
        if lio=1 then
        inc(lightmap[xt1,yt1],preclights[tlt,xt-xt1,yt-yt1]);
       end;
   end;
end;
end;

for yt:=1 to mapy do
for xt:=1 to mapx do
begin
inc(lightmap[xt,yt],ambil);
if lightmap[xt,yt]>11 then lightmap[xt,yt]:=11;
end;
end;{proc }

procedure precalcl;
var tlight,xt1,yt1:integer;
    lio,lirange:byte;
    tlt:byte;
begin
for tlt:=1 to 3 do
begin
   for yt1:=-(1+tlt*3) to (1+tlt*3) do
   for xt1:=-(1+tlt*3) to (1+tlt*3) do
       begin
        lirange:=round(sqrt(sqr(0-xt1)+sqr(0-yt1)));
        tlight:=11-(lirange*(4-tlt));
        if tlight<0 then tlight:=0;
        inc(preclights[tlt,xt1,yt1],tlight);
        if preclights[tlt,xt1,yt1]>11 then preclights[tlt,xt1,yt1]:=11;
       end;
end;
end;{proc }

procedure deptoscre(cord:word;col:byte);assembler;
asm mov es,ownseg;mov di,cord;mov bl,col;
mov [es:di],bl;mov [es:di+3],bl;mov [es:di+6],bl;
mov [es:di+321],bl;mov [es:di+324],bl;mov [es:di+327],bl;
mov [es:di+642],bl;mov [es:di+645],bl;
mov [es:di+960],bl;mov [es:di+963],bl;mov [es:di+966],bl;
mov [es:di+1281],bl;mov [es:di+1284],bl;mov [es:di+1287],bl;
mov [es:di+1602],bl;mov [es:di+1605],bl;mov [es:di+1920],bl;
mov [es:di+1923],bl;mov [es:di+1926],bl;
mov [es:di+2241],bl;mov [es:di+2244],bl;mov [es:di+2247],bl;
end;

function filload(s12:string):string;
procedure point(ax,ay,lx,ly:word;col:byte);var wo:word;begin
for wo:=ax to lx do begin mem[ownseg:wo+ay*320]:=col;mem[ownseg:wo+ly*320]:=col;end;
for wo:=ay to ly do begin mem[ownseg:wo*320+ax]:=col;mem[ownseg:wo*320+lx]:=col;end;end;
procedure getfirst(name:string;arc:word);
begin filseg:=seg(name);filofs:=ofs(name);inc(filofs,1);
asm push ds;mov al,0;mov ah,$2f;int $21;mov dtaofs,bx;mov dtaseg,es;pop ds;end;for i3:=34 to 41 do mem[dtaseg:dtaofs+i3]:=0;
asm push ds;stc;mov cx,arc;mov al,0;mov ah,$4e;mov dx,filofs;mov ds,filseg;int $21;pop ds;mov code,ax;end;
if code=0 then move(mem[dtaseg:dtaofs+30],mem[infoseg:1],12);end;
procedure getnext;
begin for i3:=34 to 41 do mem[dtaseg:dtaofs+i3]:=0;
asm mov al,0;mov ah,$2f;int $21;mov dtaofs,bx;mov dtaseg,es;push ds;stc;
mov al,0;mov ah,$4f;mov dx,filofs;mov ds,filseg;int $21;pop ds;mov code,ax;end;
if code=0 then move(mem[dtaseg:dtaofs+30],mem[infoseg:1+fils*12],12);end;
procedure uppage;begin
for a3:=(page-1)*15+1 to (page-1)*15+15 do begin
for i3:=(a3-1)*12+1 to a3*12 do s[i3-(a3-1)*12]:=chr(mem[infoseg:i3]);
text(10,(a3-((page-1)*15))*12-1,20,0,s);end;
end;
begin
clear(infoseg,3500);
chdir('maps');
away:=false;nofils:=false;code:=0;fils:=0;line:=1;page:=1;mem[infoseg:0]:=12;s[0]:=chr(mem[infoseg:0]);
getfirst(s12+#0,39);if code=0 then fils:=1 else nofils:=true;
if fils=1 then repeat getnext;if code=0 then inc(fils);until(code<>0)or(fils>1000);
if fils>=1 then begin window(0,0,117,199,9);
chdir('..');
uppage;
repeat
point(7,(line*12)-2,109,8+(line*12),icol);
wipe(ownseg,$a000,0,0,16000);
point(7,(line*12)-2,109,8+(line*12),0);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#72)and((page-1)*15+line>1)then begin dec(line);if line<1 then begin dec(page);line:=15;uppage;end;end;
if(c1=#80)and((page-1)*15+line<fils)then begin inc(line);if line>15 then begin inc(page);line:=1;uppage;end;end;
if(c1=#81)and(page<1+trunc((fils-1)/15))then begin inc(page);if line>fils-(page-1)*15 then line:=fils-(page-1)*15;uppage;end;
if(c1=#73)and(page>1)then begin dec(page);uppage;end;
if(c1=#1)then begin away:=true;c1:=#28;end;
until c1=#28;
a3:=line+(page-1)*15;for i3:=(a3-1)*12+1 to a3*12 do s[i3-(a3-1)*12]:=chr(mem[infoseg:i3]);
filload:='maps\'+s;
assign(f,'gamedata\tinfo.dat');reset(f,12500);blockread(f,mem[infoseg:0],1);close(f);
end;end;

{function getstring(x,y,col,maxpit,pcol:integer;stri:string):string;
var pla,po,i:integer;c1,c2:char;
begin pla:=1;fastfont(stri,x,y,col,0,$a000,0,1);
repeat
for po:=1 to 5 do mem[$a000:320*(8+y)+x+6*(pla-1)+po-1]:=pcol;
asm mov ah,0;int 16h;mov c1,al;mov c2,ah;end;
if(c1>=#32)and(length(stri)<maxpit)and(pla<=maxpit)then begin insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1=#8)and(pla>1)then begin dec(pla);delete(stri,pla,1);end;
if(c2=#83)then delete(stri,pla,1);
if(c2=#75)and(pla>1)then dec(pla);
if(c2=#77)and(pla<maxpit)and(pla<=length(stri))then inc(pla);
for i:=1 to 8 do for po:=x to x+(maxpit)*6 do mem[$a000:(y+i)*320+po]:=0;
fastfont(stri,x,y,col,0,$a000,0,1);
until(c1=#13)or(c2=#28)or(c2=#1);
if(c2=#1)then begin mem[seg(stri):ofs(stri)]:=1;stri[1]:=#255;end;
getstring:=stri;
end;
}
function getstring(x,y,col,maxpit,pcol:integer;stri:string;num:boolean):string;
var pla,po,i:integer;c1,c2:char;mi:boolean;
begin mi:=false;if num=false then
for i:=16 downto 1 do if(stri[i]=#0)or(stri[i]=#32)and(mi=false)then delete(stri,i,1) else mi:=true;
pla:=1;fastfont(stri,x,y,col,0,ownseg,0,1);
repeat
for po:=1 to 5 do mem[$a000:320*(8+y)+x+6*(pla-1)+po-1]:=pcol;
asm mov ah,0;int 16h;mov c1,al;mov c2,ah;end;
if(c1>=#32)and(length(stri)<maxpit)and(num=false)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1>=#48)and(c1<=#57)and(length(stri)<maxpit)and(num=true)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1=#8)and(pla>1)then begin dec(pla);delete(stri,pla,1);end;
if(c2=#83)then delete(stri,pla,1);
if(c2=#75)and(pla>1)then dec(pla);
if(c2=#77)and(pla<maxpit)and(pla<=length(stri))then inc(pla);
for i:=1 to 7 do move(de[1],mem[ownseg:(y+i)*320+x],maxpit*6+1);
fastfont(stri,x,y,col,0,ownseg,0,1);
for i:=1 to 8 do move(mem[ownseg:(y+i)*320+x],mem[$a000:(y+i)*320+x],maxpit*6+1);
until(c1=#13)or(c2=#28);
getstring:=stri;
end;


procedure loadpic(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin
filc:=0;plac:=0;assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);
blockread(file1,mem[loadseg:0],1);close(file1);
repeat colo:=mem[loadseg:filc];coun:=mem[loadseg:filc+1];for iv:=plac to plac+coun do mem[ownseg:iv]:=colo;
inc(plac,coun);inc(filc,2);
until iv>=63999;
end;

function checkfile(st1:string):boolean;var fil1:file;begin assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;end;

procedure drawpics;var plnu,col:byte;
procedure textnew(co:word;text:string;col:byte);
var ty,tx,c:integer;begin for c:=1 to length(text) do for tx:=1 to 8 do for ty:=1 to 8 do
if mem[$f000:$fa6e+ord(text[c])*8+ty-1] and ($80shr(tx-1))<>0 then mem[newseg:co+ty*290+tx+(c-1)*8]:=col;end;
procedure newput(times,gfxofs,infofs,iseg:word);assembler;
asm push ds;mov es,newseg;xor di,di;xor dx,dx;mov ds,gfxseg;mov si,gfxofs;mov bx,infofs;
@mainloop: push ds;mov ds,iseg;mov ax,[ds:bx];add di,ax;mov cx,[ds:bx+2];add bx,4;pop ds;
shr cx,1;jnc @inloop;movsb;or cx,cx;jz @end1;@inloop: movsw;dec cx;jnz @inloop;
@end1: inc dx;cmp dx,times;jb @mainloop;pop ds;end;
begin clear(newseg,3000);
if(mp<>0)then newput(ttimes[mp],tgfxofs[mp],tinfofs[mp],infoseg);

if(depcon=255)then textnew(3541,'N',70);
if(depcon=0)then textnew(3541,'R',70);
if(depcon=1)then depput(newseg,341,depinfseg,1);
if(depcon=4)then depput(newseg,341,depinfseg,4);
if(depcon=3)then depput(newseg,341,depinfseg,3);
if(depcon=14)then depput(newseg,341,depinfseg,14);
updateball2;

for i:=0 to 34 do wipe(newseg,ownseg,i*290,6670+i*320,8);
for i:=0 to 34 do wipe(newseg,ownseg,50+i*290,22990+i*320,8);
end;

procedure drawmap;
var x1,y1,x2,y2,xl:integer;lig,wod:word;co,image:byte;

procedure icon;var ia:integer;c2:word;
begin c2:=8233+(px-cx2+py-cy2)*2320+((px-cx2-py+cy2)shl 4);
for ia:=7 to 14 do begin mem[mapseg:c2+ia*290+(ia-7)*2]:=icol;mem[mapseg:c2+ia*290+(ia-7)*2+1]:=icol;
mem[mapseg:30+c2+ia*290-(ia-7)*2]:=icol;mem[mapseg:31+c2+ia*290-(ia-7)*2]:=icol;end;
for ia:=-9 to 13 do begin mem[mapseg:15+c2+ia*290]:=icol;mem[mapseg:16+c2+ia*290]:=icol;end;
for ia:=-16 to 6 do begin mem[mapseg:c2+ia*290]:=icol;mem[mapseg:31+c2+ia*290]:=icol;end;
for ia:=-16 to -10 do begin mem[mapseg:c2+ia*290+(ia+17)*2]:=icol;mem[mapseg:c2+ia*290+(ia+17)*2+1]:=icol;
mem[mapseg:30+c2+ia*290-(ia+17)*2]:=icol;mem[mapseg:31+c2+ia*290-(ia+17)*2]:=icol;end;
for ia:=-24 to -17 do begin mem[mapseg:14+c2+ia*290-(ia+24)*2]:=icol;mem[mapseg:15+c2+ia*290-(ia+24)*2]:=icol;
mem[mapseg:16+c2+ia*290+(ia+24)*2]:=icol;mem[mapseg:17+c2+ia*290+(ia+24)*2]:=icol;end;
end;

begin y1:=cy2-5;
clear(mapseg,16384);

for xl:=4 downto -3 do begin for x1:=cx2+xl to cx2+8-xl do begin
if(map[x1,y1]<>0)then
fastp(lightval[lightmap[x1,y1]],mapseg,(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),ttimes[map[x1,y1]],tgfxofs[map[x1,y1]],
tinfofs[map[x1,y1]],gfxseg,infoseg);

if lightamo>0 then for lig:=1 to lightamo do
if(lightx[lig]=x1)and(lighty[lig]=y1)then
lball3d(2445+(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),lightt[lig]);

if(depmap[x1,y1]>0)and(depment>0)then depput(mapseg,2433+(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),depinfseg,depmap[x1,y1]);

if(px=x1)and(py=y1)then icon;

end;inc(y1);end;

for x1:=cx2-4 to cx2+12 do begin
if(map[x1,y1]<>0)then
fastp(lightval[lightmap[x1,y1]],mapseg,(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),
ttimes[map[x1,y1]],tgfxofs[map[x1,y1]],tinfofs[map[x1,y1]],gfxseg,infoseg);

if lightamo>0 then for lig:=1 to lightamo do
if(lightx[lig]=x1)and(lighty[lig]=y1)then
lball3d(2445+(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),lightt[lig]);

if(depmap[x1,y1]>0)and(depment>0)then depput(mapseg,2433+(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),depinfseg,depmap[x1,y1]);

if(px=x1)and(py=y1)then icon;
end;inc(y1);

for xl:=-3 to 5 do begin for x1:=cx2+xl to cx2+11-xl do begin
if(map[x1,y1]<>0)then
fastp(lightval[lightmap[x1,y1]],mapseg,(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),ttimes[map[x1,y1]],tgfxofs[map[x1,y1]],
tinfofs[map[x1,y1]],gfxseg,infoseg);

if lightamo>0 then for lig:=1 to lightamo do
if(lightx[lig]=x1)and(lighty[lig]=y1)then
lball3d(2445+(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),lightt[lig]);

if(depmap[x1,y1]>0)and(depment>0)then depput(mapseg,2433+(x1-cx2+y1-cy2)*2320+((x1-cx2-y1+cy2)shl 4),depinfseg,depmap[x1,y1]);

if(px=x1)and(py=y1)then icon;
end;inc(y1);end;

for i:=0 to 127 do wipe(mapseg,ownseg,8137+i*290,i*320,64);
end;

procedure draw3dmap;
begin cx2:=px-4;cy2:=py-3;drawmap;
str(px,s);textxy(230,15,s,70);str(py,s);textxy(230,25,s,70);
str(mp,s);textxy(230,50,s,70);
wipe(ownseg,$a000,0,0,16000);
end;

procedure draw2dmap;var x1,y1,x2,y2:byte;lis:word;lig:byte;

procedure depaway;begin for i:=0 to 7 do wipe(picseg,ownseg,(i shl 8)+(i shl 6),7332+(i shl 8)+(i shl 6),2);end;

begin
for x1:=cx1 to cx1+34 do for y1:=cy1 to cy1+24 do begin if((map[x1,y1])>39)then lis:=2240 else lis:=0;
x3:=((y1-cy1)shl 11)+((y1-cy1)shl 9)+((x1-cx1)shl 3);

put2d(ownseg,x3,picseg,lis+(map[x1,y1] shl 3),lightval[lightmap[x1,y1]]);

if lightamo>0 then for lig:=1 to lightamo do
if(lightx[lig]=x1)and(lighty[lig]=y1)then lball(x3,lightt[lig]);

if(depmap[x1,y1]>0)and(depment>0)then deptoscre(x3,depmap[x1,y1]);

end;
for i:=0 to 4 do begin mem[ownseg:i+961+((py-cy1)shl 11)+((py-cy1)shl 9)+((px-cx1)shl 3)]:=icol;
mem[ownseg:3+(i shl 8)+(i shl 6)+320+((py-cy1)shl 11)+((py-cy1)shl 9)+((px-cx1)shl 3)]:=icol;end;
if(mp>39)then lis:=2240 else lis:=0;
for i:=0 to 7 do wipe(picseg,ownseg,lis+(mp shl 3)+(i shl 8)+(i shl 6),292+2560+(i shl 8)+(i shl 6),2);
str(px,s);textxy(250,15,s,70);str(py,s);textxy(250,25,s,70);
str(mp,s);textxy(250,50,s,70);
str(lightamo,s);textxy(250,70,s,70);
if(depcon=255)then begin depaway;textxy(293,22,'n',70);end;
if(depcon=0)then begin depaway;textxy(293,22,'r',70);end;
if(depcon=1)then begin depaway;deptoscre(7332,1);end;
if(depcon=4)then begin depaway;deptoscre(7332,4);end;
if(depcon=3)then begin depaway;deptoscre(7332,3);end;
if(depcon=14)then begin depaway;deptoscre(7332,14);end;
updateball;
wipe(ownseg,$a000,0,0,16000);
end;


begin
asm mov ax,$13;int $10;end;
depcon:=255;depment:=1;n3d:=false;con:=false;mapx:=35;mapy:=25;
cx1:=1;cy1:=1;cx2:=1;cy2:=1;px:=1;py:=1;mp:=1;
light:=1;
lightable[1]:=true;
lightable[2]:=true;
lightable[3]:=true;
lightable[4]:=true;
lightable[16]:=true;
lightable[17]:=true;
lightable[36]:=true;
lightable[37]:=true;
lightable[40]:=true;
lightable[41]:=true;
lightable[42]:=true;
lightable[43]:=true;
lightable[45]:=true;
lightable[46]:=true;
lightable[47]:=true;
lightable[48]:=true;
lightable[49]:=true;
lightable[50]:=true;
lightable[51]:=true;
lightable[52]:=true;
lightable[53]:=true;
lightable[54]:=true;
lightable[55]:=true;
lightable[56]:=true;
lightable[57]:=true;
lightable[58]:=true;
lightable[59]:=true;
lightable[60]:=true;
lightable[61]:=true;
lightable[62]:=true;
lightable[63]:=true;
lightable[64]:=true;
lightable[65]:=true;
lightable[66]:=true;
lightable[67]:=true;
lightable[68]:=true;
lightable[69]:=true;
lightable[70]:=true;
lightable[71]:=true;
lightable[72]:=true;
lightable[73]:=true;
lightable[74]:=true;
lightable[75]:=true;
lightable[76]:=true;
lightable[77]:=true;
lightable[78]:=true;
lightable[79]:=true;

entseg:=seg(lightable);entofs:=ofs(lightable);
losseg:=seg(map);losofs:=ofs(map)+1290;

deplable[1]:=true;deplable[2]:=true;deplable[3]:=true;deplable[4]:=true;
deplable[36]:=true;deplable[37]:=true;deplable[40]:=true;deplable[41]:=true;

for a:=65 to 80 do deplable[a]:=true;

for a:=1 to mapx do for i:=1 to mapy do map[a,i]:=1;

getmem(ma,65535);mapseg:=seg(ma^);clear(mapseg,16384);
getmem(ma,64000);ownseg:=seg(ma^);clear(ownseg,16000);
getmem(ma,32000);loadseg:=seg(ma^);clear(loadseg,8000);
getmem(ma,48000);gfxseg:=seg(ma^);clear(gfxseg,12000);
getmem(ma,14000);infoseg:=seg(ma^);clear(infoseg,3500);
getmem(ma,12000);newseg:=seg(ma^);clear(newseg,3000);
getmem(ma,5120);picseg:=seg(ma^);clear(picseg,1280);
getmem(ma,500);depinfseg:=seg(ma^);clear(depinfseg,125);
getmem(ma,6000);fontseg:=seg(ma^);
assign(f,'gfx\font.fnt');reset(f,6000);blockread(f,mem[fontseg:0],1);close(f);

assign(f,'gamedata\tgfx.dat');reset(f,47951);blockread(f,mem[gfxseg:0],1);close(f);
assign(f,'gamedata\tinfo.dat');reset(f,12500);blockread(f,mem[infoseg:0],1);close(f);
assign(f,'gamedata\depinfo.dat');reset(f,448);blockread(f,mem[depinfseg:0],1);close(f);

assign(f,'gamedata\mapedit2.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do setpal(i,mem[ownseg:i*3],mem[ownseg:1+i*3],mem[ownseg:2+i*3]);

loadpic('gfx\minimap.svf');for wo:=0 to 5119 do mem[picseg:wo]:=mem[ownseg:wo];

svfname:='gfx\mapedit.svf';loadpic(svfname);
precalcl;
lmode:=1;
lightamo:=0;
ambil:=5;
calclights;

repeat
{ Draw the map }
if(n3d=false)then draw2dmap else draw3dmap;
{ Wait until a key is pressed }
asm xor ax,ax;int $16;mov c1,ah;end;
case c1 of
{ Change the viewingmode 2d/3d }
#57:if(n3d=true)then begin n3d:=false;svfname:='gfx\mapedit.svf';loadpic(svfname);
if(cx1<1)then cx1:=1;if(cy1<1)then cy1:=1;if(cx1+35>mapx)then cx1:=mapx-34;if(cy1+25>mapy)then cy1:=mapy-24;
end else begin n3d:=true;svfname:='gfx\newmaped.svf';loadpic(svfname);drawpics;end;

{ Deploy a blue guy }
#48:if(deplable[map[px,py]]=true)then depmap[px,py]:=1;

{ Deploy a red guy }
#19:if(deplable[map[px,py]]=true)then depmap[px,py]:=4;

{ Deploy a green guy }
#34:if(deplable[map[px,py]]=true)then depmap[px,py]:=3;

{ Deploy a yellow guy }
#21:if(deplable[map[px,py]]=true)then depmap[px,py]:=14;

{ Remove deployment }
#18:depmap[px,py]:=0;

{ Deployement continuous mode on/off }
#32:begin dep:=false;
if(depcon=0)and(dep=false)then begin depcon:=1;dep:=true;if(n3d=true)then drawpics;end;
if(depcon=1)and(dep=false)then begin depcon:=4;dep:=true;if(n3d=true)then drawpics;end;
if(depcon=4)and(dep=false)then begin depcon:=3;dep:=true;if(n3d=true)then drawpics;end;
if(depcon=3)and(dep=false)then begin depcon:=14;dep:=true;if(n3d=true)then drawpics;end;
if(depcon=14)and(dep=false)then begin depcon:=255;dep:=true;if(n3d=true)then drawpics;end;
if(depcon=255)and(dep=false)then begin depcon:=0;dep:=true;if(n3d=true)then drawpics;end;
end;

{ View deployement on/off }
#64:depment:=1-depment;

{ Continuous mode on/off }
#46:if(con=true)then con:=false else con:=true;

{ Move around the screen }
#77:if(px<mapx)then begin if(px-cx1>33)then inc(cx1);if((px-cx2)-(py-cy2)>7)or((px-cx2)+(py-cy2)>13)then inc(cx2);inc(px);end;
#75:if(px>1)then begin if(px-cx1<1)then dec(cx1);if((px-cx2)-(py-cy2)<-5)or((px-cx2)+(py-cy2)<1)then dec(cx2);dec(px);end;
#72:if(py>1)then begin if(py-cy1<1)then dec(cy1);if((px-cx2)-(py-cy2)>7)or((px-cx2)+(py-cy2)<1)then dec(cy2);dec(py);end;
#80:if(py<mapy)then begin if(py-cy1>23)then inc(cy1);if((px-cx2)-(py-cy2)<-5)or((px-cx2)+(py-cy2)>13)then inc(cy2);inc(py);end;

{ Change current piece }
#78:begin if mp<79 then inc(mp) else mp:=0;if(n3d=true)then drawpics;end;
#74:begin if mp>0 then dec(mp) else mp:=79;if(n3d=true)then drawpics;end;

{ Save the map }
#31:begin sav:=false;ow:=true;grs1:=0;grs2:=0;grs3:=0;grs4:=0;
for i:=1 to 100 do for a:=1 to 100 do begin
if(depmap[i,a]=1)then inc(grs1);
if(depmap[i,a]=4)then inc(grs2);
if(depmap[i,a]=3)then inc(grs3);
if(depmap[i,a]=14)then inc(grs4);
end;
if(grs1>=20)and(grs2>=20)and(grs3>=20)and(grs4>=20)then sav:=true;
if sav=false then begin window(14,61,266,101,9);
textxy(47,66,'Not enough room for 20 warriors.',52);
textxy(47,76,'You must have atleast 20 squares ',52);
textxy(47,86,'of deployment area for each team. ',52);
wipe(ownseg,$a000,0,0,16000);
asm xor ax,ax;int $16;mov c1,ah;end;end;
if sav=true then begin window(0,61,280,131,9);
textxy(9,66,'Wallstrength (1-500, def=30)      :',52);
textxy(9,76,'Doorstrength (1-500, def=25)      :',52);
textxy(9,86,'Item in drawer % (0-100, def=20)  :',52);
textxy(9,96,'Max. items in drawer (1-50, def=1):',52);
textxy(9,112,'Name of the battlefield           :',52);
wipe(ownseg,$a000,0,0,16000);out:=0;
if(out=0)then s:=getstring(224,66,52,3,55,'',true);
if(s[1]=#255)then out:=1;val(s,wd1,tem);

if((wd1<1)or(wd1>500))then if wd=0 then wd:=30;
if wd1<>0 then wd:=wd1;
str(wd,s);
textxy(224,66,s,52);wipe(ownseg,$a000,0,0,16000);
if(out=0)then s:=getstring(224,76,52,3,55,'',true);
if(s[1]=#255)then out:=1;val(s,dd1,tem);

if((dd1<1)or(dd1>500))then if dd=0 then dd:=25;
if dd1<>0 then dd:=dd1;

str(dd,s);
textxy(224,76,s,52);wipe(ownseg,$a000,0,0,16000);
if(out=0)then s:=getstring(224,86,52,3,55,'',true);

if(s[1]=#255)then out:=1;val(s,id1,tem);
if(id1<0)or(id1>100)then id:=20;
if id1<>0 then id:=id1;
str(id,s);
textxy(224,86,s,52);wipe(ownseg,$a000,0,0,16000);

if(out=0)then s:=getstring(224,96,52,2,55,'',true);
if(s[1]=#255)then out:=1;
val(s,im1,tem);
if(im1<0)or(im1>50)then im:=1;
if im1<>0 then im:=im1;
str(im,s);
textxy(224,96,s,52);wipe(ownseg,$a000,0,0,16000);

if(out=0)then s:=getstring(224,112,52,8,55,'',false);
if(s[1]=#255)then out:=1;
if(s<>'')and(out=0)then begin

a:=mem[seg(s):ofs(s)];out:=0;
for i:=1 to a do if(out=0)and(s[i]=#46)then begin out:=1;i1:=i;end;
if(out=1)then delete(s,i1,20);
s:=s+'.map';

if(checkfile('maps\'+s)=true)then begin
window(0,61,280,131,9);
for a:=1 to 12 do s[a]:=upcase(s[a]);
s1:=s+' already exists !';
textxy(57,80,s1,52);
textxy(57,94,'Do you want to overwrite it ?',52);
textxy(57,104,'           (Y/N)             ',52);
wipe(ownseg,$a000,0,0,16000);
repeat asm xor ax,ax;int $16;mov c1,ah;end;until(c1=#49)or(c1=#21);
if(c1=#49)then ow:=false;
end;
if(ow=true)then begin
for wo:=0 to 99 do move(map[wo+1,1],mem[ownseg:wo*100],100);
for wo:=0 to 99 do move(depmap[wo+1,1],mem[ownseg:10000+wo*100],100);
for wo:=1 to 200 do { lights }
begin
mem[ownseg:20000+wo*3-3]:=lightx[wo];
mem[ownseg:20000+wo*3+1-3]:=lighty[wo];
mem[ownseg:20000+wo*3+2-3]:=lightt[wo];
end;
mem[ownseg:20600]:=mapx;mem[ownseg:20601]:=mapy;
mem[ownseg:20602]:=wd;mem[ownseg:20603]:=dd;
mem[ownseg:20604]:=id;mem[ownseg:20605]:=im;
assign(f,'maps\'+s);rewrite(f,20606);blockwrite(f,mem[ownseg:0],1);close(f);
end;
clear(ownseg,16000);
end;end;
loadpic(svfname);if(n3d=true)then drawpics;end;

{ Load a map }
#38:begin s:=filload('*.map');if(nofils=false)and(away=false)then
begin cx1:=1;cy1:=1;cx2:=1;cy2:=1;px:=1;py:=1;
assign(f1,s);reset(f1);le:=filesize(f1);close(f1);
if(le=20606)then begin
assign(f,s);reset(f,20606);blockread(f,mem[ownseg:0],1);close(f);
for wo:=1 to 100 do move(mem[ownseg:(wo-1)*100],map[wo,1],100);
for wo:=1 to 100 do move(mem[ownseg:10000+(wo-1)*100],depmap[wo,1],100);

wd:=mem[ownseg:20602];dd:=mem[ownseg:20603];
id:=mem[ownseg:20604];im:=mem[ownseg:20605];

for wo:=1 to 200 do { lights }
begin
lightx[wo]:=mem[ownseg:20000+wo*3-3];
lighty[wo]:=mem[ownseg:20000+wo*3+1-3];
lightt[wo]:=mem[ownseg:20000+wo*3+2-3];
end;
lightamo:=0;
for a:=1 to 200 do
if lightt[a]<>0 then inc(lightamo);

mapx:=mem[ownseg:20600];mapy:=mem[ownseg:20601];
wd:=mem[ownseg:20602];dd:=mem[ownseg:20603];
id:=mem[ownseg:20604];im:=mem[ownseg:20605];
end;
end else if(away=false)then begin
window(21,61,259,80,9);textxy(55,66,'No map files to load. (*.map)',52);
wipe(ownseg,$a000,0,0,16000);asm xor ax,ax;int $16;end;end;
clear(ownseg,16000);loadpic(svfname);if(n3d=true)then drawpics;
calclights;
end;

{ Change the size of the map }
#63:begin px:=1;py:=1;cx1:=1;cy1:=1;cx2:=1;cy2:=1;cmapx:=mapx;cmapy:=mapy;
window(27,61,245,91,9);
textxy(39,66,'Width of the map (35-100)  :',52);
textxy(39,76,'Heigth of the map (25-100) :',52);
wipe(ownseg,$a000,0,0,16000);
s:=getstring(212,66,52,3,55,'',true);val(s,mapx,tem);if(mapx<35)or(mapx>100)then mapx:=cmapx;
s:=getstring(212,76,52,3,55,'',true);val(s,mapy,tem);if(mapy<25)or(mapy>100)then mapy:=cmapy;
for a:=1 to 100 do for i:=1 to 100 do if(i>mapx)or(a>mapy)then begin map[i,a]:=0;depmap[i,a]:=0;end;
loadpic(svfname);if(n3d=true)then drawpics;end;

{ Help me!}
#$23:begin helpscreen;
loadpic(svfname);if(n3d=true)then drawpics;end;

{ Change light in use }
#59:begin inc(light);if light>6 then light:=1;if(n3d=true)then drawpics;end;

{ Insert/erase light }
#60:begin
if(lightable[map[px,py]]=true)then begin
tl:=0;
for a:=1 to 200 do
if (lightt[a]=0)and(tl=0)then tl:=a;
if tl=0 then
 begin

   tl2:=0;
for a:=1 to 200 do
if (lightx[a]=px)and(lighty[a]=py)then
  begin
   lightt[a]:=0;
   lightx[a]:=0;
   lighty[a]:=0;
   if a=lightamo then dec(lightamo);
   tl2:=1;
   calclights;
  end;

 if(tl2=0)then begin   {pois otettu vai ei? }
 window(21,61,261,81,9);textxy(86,66,'Already 200 lights!  ',52);
 wipe(ownseg,$a000,0,0,16000);
 asm
 xor ax,ax
 int 16h
 end;
 end;

 end
 else
 begin
 tl2:=0;
 for a:=1 to lightamo do
 begin
  if(lightx[a]=px)and(lighty[a]=py)then
  begin
   lightt[a]:=0;
   lightx[a]:=0;
   lighty[a]:=0;
   if a=lightamo then dec(lightamo);
   tl2:=1;
   calclights;
  end;
 end;
 if tl2=0 then
 begin
  lightx[tl]:=px;
  lighty[tl]:=py;
  lightt[tl]:=light;
  if tl=lightamo+1 then inc(lightamo);
  calclights;
 end;
 end;

if lightamo>0 then
begin {start}
 for a:=1 to lightamo do
 begin
  if (a>1)and(lightt[a]<>0) then
  begin
   tl2:=0;
   for tl:=a-1 downto 1 do
   if (lightt[tl]=0)and(tl2=0)then
   begin
    lightt[tl]:=lightt[tl+1];
    lightx[tl]:=lightx[tl+1];
    lighty[tl]:=lighty[tl+1];
    lightt[tl+1]:=0;
    tl2:=1;
   end;
  end;
 end;
end;{start}
lightamo:=0;
for a:=1 to 200 do
if lightt[a]<>0 then inc(lightamo);
end;
end;

{ Adjusts ambientlight }
#61:if(ambil>0)and(lmode=1)then begin dec(ambil);calclights;end;
#62:if(ambil<10)and(lmode=1)then begin inc(ambil);calclights;end;
{ Adjusts lmode }
#65:begin
if lmode=1 then
 begin
 oldambil:=ambil;
 ambil:=10;
 end else ambil:=oldambil;
lmode:=1-lmode;
calclights;
end;
{ Recalcs lightmap }
#66:calclights;

{ Clear the map }
#83:begin
window(41,61,241,81,9);textxy(80,66,'Clear the map ? (y/N)',52);
wipe(ownseg,$a000,0,0,16000);
asm xor ax,ax;int $16;mov c1,ah;end;
if(c1=#21)then begin
for a:=1 to 200 do
lightt[a]:=0;calclights;
for i:=1 to 100 do for a:=1 to 100 do begin map[a,i]:=0;depmap[a,i]:=0;end;
for i:=1 to mapy do for a:=1 to mapx do map[a,i]:=mp;end;
loadpic(svfname);if(n3d=true)then drawpics;
end;

#59:begin helpscreen;end;

{ Quitting }
#1:begin window(31,61,249,81,9);textxy(58,66,'Do you want to quit ? (y/N)',52);
wipe(ownseg,$a000,0,0,16000);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#21)then lop:=true;
loadpic(svfname);if(n3d=true)then drawpics;end;

{ A piece into map }
#28:begin map[px,py]:=mp;if(deplable[map[px,py]]=false)then depmap[px,py]:=0;end;

{ Remove a piece from the map }
#14:map[px,py]:=0;
end;

{ Continuous mode check }
if(con=true)then begin map[px,py]:=mp;if(deplable[map[px,py]]=false)then depmap[px,py]:=0;end;

{ Deployement continuous mode check }
if(depcon<>255)and(deplable[map[px,py]]=true)then depmap[px,py]:=depcon;
if(depcon=0)then depmap[px,py]:=0;

until lop=true;
asm mov ax,$3;int $10;end;
end.

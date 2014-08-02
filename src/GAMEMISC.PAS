{$F+ $O+}
unit gamemisc;

interface
uses varunit,crt,sbunit;

procedure selectcontroller;
procedure chooseunits(unitti:byte);
procedure chooseplayers(unitti:byte);
procedure helpscreen;
procedure endstatisticsscreen;
procedure endstuff;
procedure melee;
procedure statscreen;
procedure viewmap;

implementation

procedure selectcontroller;
var te1,te2,a1,a2,startc,shadeok,ol1,line,hums,temptots,tots,cpus,choos:byte;c2:char;

procedure drawarrows;
var a1,a2,va:byte;
begin
a2:=0;
for a1:=0 to 3 do if(control[a1]>0)then inc(a2);
if(a2<3)then for a1:=0 to 3 do ally[a1]:=a1;
for va:=0 to 23 do move_custom(mem[visibseg:20000+va*24],mem[ownseg:148+320*88+va*320],24);
if(ally[0]=ally[1])then blittrp(visibseg,ownseg,21000,0,148,88,24,24);
if(ally[2]=ally[3])then blittrp(visibseg,ownseg,21000,0,148,107,24,24);
if(ally[0]=ally[2])then blittrp(visibseg,ownseg,21024,0,139,88,24,24);
if(ally[1]=ally[3])then blittrp(visibseg,ownseg,21024,0,158,88,24,24);
if(ally[0]=ally[3])then blittrp(visibseg,ownseg,21048,0,148,88,24,24);
if(ally[1]=ally[2])then blittrp(visibseg,ownseg,21072,0,148,88,24,24);
wipe(ownseg,$a000,0,0,16000);
end;

procedure point(ax,ay,lx,ly:word;col:byte);var wo,new:word;begin
new:=0;
for wo:=ax to lx do begin
mem[minfoseg:new]:=mem[ownseg:wo+ay*320];inc(new);
mem[minfoseg:new]:=mem[ownseg:wo+ly*320];inc(new);
mem[ownseg:wo+ay*320]:=col;
mem[ownseg:wo+ly*320]:=col;
end;
for wo:=ay+1 to ly-1 do begin
mem[minfoseg:new]:=mem[ownseg:wo*320+ax];inc(new);
mem[minfoseg:new]:=mem[ownseg:wo*320+lx];inc(new);
mem[ownseg:wo*320+ax]:=col;
mem[ownseg:wo*320+lx]:=col;
end;
end;

procedure rempoint(ax,ay,lx,ly:word);
var wo,new:word;begin
new:=0;
for wo:=ax to lx do begin
mem[ownseg:wo+ay*320]:=mem[minfoseg:new];inc(new);
mem[ownseg:wo+ly*320]:=mem[minfoseg:new];inc(new);
end;
for wo:=ay+1 to ly-1 do begin
mem[ownseg:wo*320+ax]:=mem[minfoseg:new];inc(new);
mem[ownseg:wo*320+lx]:=mem[minfoseg:new];inc(new);
end;
end;

procedure pointer(lin,po:byte);
begin
if(po=1)then begin
if(lin>=1)and(lin<=6)then point(18,20+(lin*10),142,30+(lin*10),15);
if(lin>=7)and(lin<=12)then point(18,40+(lin*10),142,50+(lin*10),15);
if(lin>=13)and(lin<=18)then point(178,20+((lin-12)*10),302,30+((lin-12)*10),15);
if(lin>=19)and(lin<=24)then point(178,40+((lin-12)*10),302,50+((lin-12)*10),15);
if(lin=25)then point(230,184,302,194,15);
end;
if(po=0)then begin
if(lin>=1)and(lin<=6)then rempoint(18,20+(lin*10),142,30+(lin*10));
if(lin>=7)and(lin<=12)then rempoint(18,40+(lin*10),142,50+(lin*10));
if(lin>=13)and(lin<=18)then rempoint(178,20+((lin-12)*10),302,30+((lin-12)*10));
if(lin>=19)and(lin<=24)then rempoint(178,40+((lin-12)*10),302,50+((lin-12)*10));
if(lin=25)then rempoint(230,184,302,194);
end;
end;

function color(lin:byte):byte;
begin
color:=5;
if(lin>=1)and(lin<=6)then color:=0;
if(lin>=7)and(lin<=12)then color:=2;
if(lin>=13)and(lin<=18)then color:=1;
if(lin>=19)and(lin<=24)then color:=3;
end;

procedure removeally(n:byte);
var na,lo1,amo:byte;
begin
amo:=0;
for lo1:=0 to 3 do if(ally[lo1]=ally[n])then inc(amo);
if(amo<3)then for lo1:=0 to 3 do if(ally[lo1]=ally[n])then ally[lo1]:=lo1;
if(amo=3)and(ally[n]<>n)then ally[n]:=n else begin
for lo1:=3 downto 0 do if(ally[lo1]=ally[n])and(n<>lo1)then na:=lo1;
for lo1:=0 to 3 do if(ally[lo1]=ally[n])and(n<>lo1)then ally[lo1]:=na;
end;
end;

procedure remshade(ax,ay,col:byte);
var wo1,colamo:word;
begin
wo1:=ax+10+ay*320;
colamo:=1500*col;
asm
push ds;
mov si,colamo
mov di,wo1;
mov es,ownseg;
mov ds,visibseg;
mov bx,10
@lope:
mov cx,62;
rep movsw;
add di,196
dec bx
jnz @lope;
pop ds;
end;
end;

procedure shade(ax,ay,col:byte);
var ncor,wo1,wo2,colamo:word;
begin
wo1:=ax+10+ay*320;
colamo:=1500*col;
asm
push ds;
mov es,visibseg;
mov di,colamo
mov si,wo1;
mov ds,ownseg;
mov bx,10
@lope:
mov cx,62;
rep movsw;
add si,196
dec bx
jnz @lope;
pop ds;
end;
if(col=0)then for wo1:=ay to ay+9 do for wo2:=ax+10 to ax+133 do
if(mem[ownseg:(wo1 shl 8)+(wo1 shl 6)+wo2]<>8)then
begin
ncor:=(wo1 shl 8)+(wo1 shl 6)+wo2;
if(mem[ownseg:ncor]>80)then dec(mem[ownseg:ncor],7);
if(mem[ownseg:ncor]<80)then mem[ownseg:ncor]:=80;
end;

if(col=1)then for wo1:=ay to ay+9 do for wo2:=ax+10 to ax+133 do
if(mem[ownseg:(wo1 shl 8)+(wo1 shl 6)+wo2]<>8)then
begin
ncor:=(wo1 shl 8)+(wo1 shl 6)+wo2;
if(mem[ownseg:ncor]>112)then dec(mem[ownseg:ncor],12);
if(mem[ownseg:ncor]<112)then mem[ownseg:ncor]:=112;
end;

if(col=2)then for wo1:=ay to ay+9 do for wo2:=ax+10 to ax+133 do
if(mem[ownseg:(wo1 shl 8)+(wo1 shl 6)+wo2]<>8)then
begin
ncor:=(wo1 shl 8)+(wo1 shl 6)+wo2;
if(mem[ownseg:ncor]>16)then dec(mem[ownseg:ncor],12);
if(mem[ownseg:ncor]<16)then mem[ownseg:ncor]:=16;
end;

if(col=3)then for wo1:=ay to ay+9 do for wo2:=ax+10 to ax+133 do
if(mem[ownseg:(wo1 shl 8)+(wo1 shl 6)+wo2]<>8)then
begin
ncor:=(wo1 shl 8)+(wo1 shl 6)+wo2;
if(mem[ownseg:ncor]>160)then dec(mem[ownseg:ncor],12);
if(mem[ownseg:ncor]<160)then mem[ownseg:ncor]:=160;
end;
end;

begin
away:=false;line:=1;
for wo:=0 to 767 do sofpal[wo]:=defpal[wo];
for wo:=0 to 767 do defpal[wo]:=0;
fade(4);
clear($a000,16000);
assign(f,'gamedata\control.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do begin
setpal(i,0,0,0);
defpal[i*3]:=mem[ownseg:i*3];
defpal[i*3+1]:=mem[ownseg:i*3+1];
defpal[i*3+2]:=mem[ownseg:i*3+2];
end;
for wo:=0 to 767 do sofpal[wo]:=0;
loadpic('gfx\control.svf');

clear(visibseg,3500);
for wo:=0 to 23 do move_custom(mem[ownseg:148+320*88+wo*320],mem[visibseg:20000+wo*24],24);

assign(f,'gfx\chains.svf');reset(f,8000);blockread(f,mem[visibseg:21000],1);close(f);

ally[0]:=0;control[0]:=1;shade(8,40,0);
ally[1]:=1;control[1]:=1;shade(8,110,2);
ally[2]:=2;control[2]:=0;shade(168,40,1);
ally[3]:=3;control[3]:=0;shade(168,110,3);

wipe(ownseg,$a000,0,0,16000);
fade(4);
for wo:=0 to 767 do defpal[wo]:=0;

repeat
pointer(line,1);

{$IFNDEF unregistered}
fastfont('Press space to choose allies.  ',8,184,208,0,ownseg,0,1);
{$ELSE}
fastfont('Unregistered: Two players only.',8,184,208,0,ownseg,0,1);
{$ENDIF}

drawarrows;
wipe(ownseg,$a000,0,0,16000);
pointer(line,0);
asm xor ax,ax;int 16h;mov c1,ah;end;
if(c1=#72)then begin dec(line);
if(line=0)then line:=25;
if(line=12)then line:=25;
end;
if(c1=#80)then begin inc(line);
if(line=13)then line:=25;
if(line=26)then line:=1;
end;
if(c1=#75)and(line<>25)then begin
if(line>12)then dec(line,12) else inc(line,12);
end;
if(c1=#77)and(line<>25)then begin
if(line>12)then dec(line,12) else inc(line,12);
end;

if(c1=#28)then begin
hums:=0;tots:=0;shadeok:=1;
if(line>=1)and(line<=6)then remshade(8,20+(control[0]+1)*10,0);
if(line>=7)and(line<=12)then remshade(8,40+(control[2]+7)*10,2);
if(line>=13)and(line<=18)then remshade(168,20+(control[1]+1)*10,1);
if(line>=19)and(line<=24)then remshade(168,40+(control[3]+7)*10,3);

temptots:=0;
for wo:=0 to teams do if(control[wo]>0) then inc(temptots);

if(line>=1)and(line<=6)then begin
ol1:=control[0];
control[0]:=line-1;
if(line=1)then removeally(0);
for wo:=0 to teams do begin if(control[wo]=1)then inc(hums);
if(control[wo]>0)then inc(tots);end;

{$IFNDEF unregistered}
if(tots<2)or(hums<0)then begin control[0]:=ol1;shadeok:=0;end;
{$ELSE}
if(tots<2)or(hums<0)or(tots>2)then begin control[0]:=ol1;shadeok:=0;end;
{$ENDIF}
end;

if(line>=7)and(line<=12)then begin
ol1:=control[2];control[2]:=line-7;
if(line=7)then removeally(2);
for wo:=0 to teams do begin if(control[wo]=1)then inc(hums);if(control[wo]>0)then inc(tots);end;
{$IFNDEF unregistered}
if(tots<2)or(hums<0)then begin control[2]:=ol1;shadeok:=0;end;
{$ELSE}
if(tots<2)or(hums<0)or(tots>2)then begin control[2]:=ol1;shadeok:=0;end;
{$ENDIF}
end;

if(line>=13)and(line<=18)then begin
ol1:=control[1];control[1]:=line-13;
if(line=13)then removeally(1);
for wo:=0 to teams do begin if(control[wo]=1)then inc(hums);if(control[wo]>0)then inc(tots);end;
{$IFNDEF unregistered}
if(tots<2)or(hums<0)then begin control[1]:=ol1;shadeok:=0;end;
{$ELSE}
if(tots<2)or(hums<0)or(tots>2)then begin control[1]:=ol1;shadeok:=0;end;
{$ENDIF}
end;

if(line>=19)and(line<=24)then begin
ol1:=control[3];control[3]:=line-19;
if(line=19)then removeally(3);
for wo:=0 to teams do begin if(control[wo]=1)then inc(hums);if(control[wo]>0)then inc(tots);end;
{$IFNDEF unregistered}
if(tots<2)or(hums<0)then begin control[3]:=ol1;shadeok:=0;end;
{$ELSE}
if(tots<2)or(hums<0)or(tots>2)then begin control[3]:=ol1;shadeok:=0;end;
{$ENDIF}
end;

if(line>=1)and(line<=6)then shade(8,20+(control[0]+1)*10,0);
if(line>=7)and(line<=12)then shade(8,40+(control[2]+7)*10,2);
if(line>=13)and(line<=18)then shade(168,20+(control[1]+1)*10,1);
if(line>=19)and(line<=24)then shade(168,40+(control[3]+7)*10,3);
end;

if(c1=#1)then begin away:=true;c1:=#28;line:=25;end;


if(c1=#57)and(line<>25)and(control[color(line)]>0)then begin         { Choosing allies }
tots:=0;
for wo:=0 to teams do if(control[wo]>0)then inc(tots);
if(tots>2)then begin

startc:=color(line);
fastfont('Choose an ally and press space.',8,184,208,0,ownseg,0,1);

repeat
pointer(line,1);
{str(ally[0],s);fastfont(s,1,1,208,0,ownseg,0,0);
str(ally[1],s);fastfont(s,1,11,208,0,ownseg,0,0);
str(ally[2],s);fastfont(s,1,21,208,0,ownseg,0,0);
str(ally[3],s);fastfont(s,1,31,208,0,ownseg,0,0);}
wipe(ownseg,$a000,0,0,16000);
pointer(line,0);
asm xor ax,ax;int 16h;mov c1,ah;end;
if(c1=#72)then begin dec(line);
if(line=0)then line:=24;
if(line=12)then line:=24;
end;
if(c1=#80)then begin inc(line);
if(line=13)then line:=24;
if(line=25)then line:=1;
end;
if(c1=#75)and(line<>25)then begin
if(line>12)then dec(line,12) else inc(line,12);
end;
if(c1=#77)and(line<>25)then begin
if(line>12)then dec(line,12) else inc(line,12);
end;

if(c1=#57)and(startc=color(line))then begin { Removing allies }
removeally(color(line));
{str(ally[0],s);fastfont(s,1,1,208,0,ownseg,0,0);
str(ally[1],s);fastfont(s,1,11,208,0,ownseg,0,0);
str(ally[2],s);fastfont(s,1,21,208,0,ownseg,0,0);
str(ally[3],s);fastfont(s,1,31,208,0,ownseg,0,0);}
drawarrows;c1:=#1;
end;

if(c1=#57)and(startc<>color(line))and(control[startc]>0)and(control[color(line)]>0)then begin   { Adding allies }

te1:=0;te2:=0;
for a1:=0 to 3 do if(ally[a1]=ally[startc])then inc(te1);
for a1:=0 to 3 do if(ally[a1]=ally[color(line)])then inc(te2);

if((te1+te2)<tots)then
if(ally[startc]>ally[color(line)])then begin
a2:=ally[startc];
for a1:=0 to 3 do if(ally[a1]=a2)then ally[a1]:=ally[color(line)];
end else begin
a2:=ally[color(line)];
for a1:=0 to 3 do if(ally[a1]=a2)then ally[a1]:=ally[startc];
end;

{str(ally[0],s);fastfont(s,1,1,208,0,ownseg,0,0);
str(ally[1],s);fastfont(s,1,11,208,0,ownseg,0,0);
str(ally[2],s);fastfont(s,1,21,208,0,ownseg,0,0);
str(ally[3],s);fastfont(s,1,31,208,0,ownseg,0,0);}
drawarrows;c1:=#1;
end;

until(c1=#1);
end;

end;                         { Choosing allies }

until(c1=#28)and(line=25);

if(away=false)then begin
fade(4);clear($a000,16000);
for wo:=0 to 767 do sofpal[wo]:=0;
assign(f,'gamedata\select.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for c3:=0 to 767 do defpal[c3]:=mem[ownseg:c3];
defpal[3]:=0;defpal[4]:=0;defpal[5]:=63;
defpal[9]:=0;defpal[10]:=40;defpal[11]:=0;
defpal[12]:=63;defpal[13]:=0;defpal[14]:=0;
defpal[36]:=0;defpal[37]:=40;defpal[38]:=0;
defpal[570]:=11;defpal[571]:=11;defpal[572]:=11;
loadpic('gfx\select.svf');
wipe(ownseg,$a000,0,0,16000);
fade(4);
end;
end;

procedure chooseunits(unitti:byte);
var unitcol:byte;
begin
pntr:=false;
assign(f,'data\groups.dat');reset(f,29000);blockread(f,mem[gfxseg:0],1);close(f);
grs:=mem[gfxseg:0]-1;mem[seg(s):ofs(s)]:=16;line:=1;
for i:=1 to 10 do begin move_custom(mem[gfxseg:1+(i-1)*1440],s[1],16);
fastfont(s,10,1+i*12,20,0,ownseg,0,1);
end;

for i:=11 to 20 do begin move_custom(mem[gfxseg:1+(i-1)*1440],s[1],16);
fastfont(s,145,1+(i-10)*12,20,0,ownseg,0,1);
end;

if(unitti>0)and(control[0]=1)then begin
move_custom(mem[gfxseg:1+(gr1[0]-1)*1440],s[1],16);
if(gr1[0]<11)then
fastfont(s,10,1+gr1[0]*12,20,1,ownseg,0,1)
else fastfont(s,145,1+(gr1[0]-10)*12,20,1,ownseg,0,1)
end;

if(unitti>1)and(control[1]=1)then begin
move_custom(mem[gfxseg:1+(gr1[1]-1)*1440],s[1],16);
if(gr1[1]<11)then
fastfont(s,10,1+gr1[1]*12,20,4,ownseg,0,1)
else fastfont(s,145,1+(gr1[1]-10)*12,20,4,ownseg,0,1)
end;

if(unitti>2)and(control[2]=1)then begin
move_custom(mem[gfxseg:1+(gr1[2]-1)*1440],s[1],16);
if(gr1[2]<11)then
fastfont(s,10,1+gr1[2]*12,20,3,ownseg,0,1)
else fastfont(s,145,1+(gr1[2]-10)*12,20,3,ownseg,0,1)
end;

if(unitti=0)then begin fastfont('Blue, choose your unit.                            ',10,143,20,0,ownseg,0,1);unitcol:=1;end;
if(unitti=1)then begin fastfont('Red, choose your unit.                             ',10,143,20,0,ownseg,0,1);unitcol:=4;end;
if(unitti=2)then begin fastfont('Green, choose your unit.                           ',10,143,20,0,ownseg,0,1);unitcol:=3;end;
if(unitti=3)then begin fastfont('Yellow, choose your unit.                          ',10,143,20,0,ownseg,0,1);unitcol:=14;end;

repeat
if line<=10 then point(7,(line*12),141,10+(line*12),unitcol);
if line>10 then point(143,((line-10)*12),277,10+((line-10)*12),unitcol);
wipe(ownseg,$a000,0,0,16000);
if line<=10 then point(7,(line*12),141,10+(line*12),0);
if line>10 then point(143,((line-10)*12),277,10+((line-10)*12),0);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#72)and(line>1)then dec(line);if(c1=#80)and(line<grs)then inc(line);
if(c1=#75)and(line>10)then dec(line,10);if(c1=#77)and(line+10<=grs)then inc(line,10);
if(c1=#28)and(mem[gfxseg:25+((line-1)*1440)]<1)then begin fastfont('No warriors in this unit.',10,143,20,0,ownseg,0,1);
wipe(ownseg,$a000,0,0,16000);
asm mov ah,0;int 16h;end;fastfont('                         ',10,143,20,0,ownseg,0,1);end;
if(c1=#1)then begin pntr:=true;end;
until((c1=#28)and(mem[gfxseg:25+((line-1)*1440)]>0)and(line<>gr1[0])and(line<>gr1[1])and(line<>gr1[2]))or(c1=#1);
gr1[unitti]:=line;pls:=mem[gfxseg:(gr1[unitti]-1)*1440+25];line:=1;plamo:=0;
end;

procedure chooseplayers(unitti:byte);
var unitcol:byte;
begin
for i:=1 to 10 do begin move_custom(mem[gfxseg:(gr1[unitti]-1)*1440+281+(i-1)*58],s[1],16);
fastfont(s,10,1+i*12,20,0,ownseg,0,1);end;

for i:=11 to 20 do begin
move_custom(mem[gfxseg:(gr1[unitti]-1)*1440+281+(i-1)*58],s[1],16);fastfont(s,145,1+(i-10)*12,20,0,ownseg,0,1);end;

{$IFNDEF unregistered}
if(unitti=0)then begin fastfont('Blue, choose your warriors.         ',10,143,20,0,ownseg,0,1);unitcol:=1;end;
if(unitti=1)then begin fastfont('Red, choose your warriors.          ',10,143,20,0,ownseg,0,1);unitcol:=4;end;
if(unitti=2)then begin fastfont('Green, choose your warriors.        ',10,143,20,0,ownseg,0,1);unitcol:=3;end;
if(unitti=3)then begin fastfont('Yellow, choose your warriors.       ',10,143,20,0,ownseg,0,1);unitcol:=14;end;
{$ELSE}
if(unitti=0)then begin fastfont('Blue, choose your warriors. Unregistered: Max. 10  ',10,143,20,0,ownseg,0,1);
unitcol:=1;end;
if(unitti=1)then begin fastfont('Red, choose your warriors. Unregistered: Max. 10   ',10,143,20,0,ownseg,0,1);
unitcol:=4;end;
if(unitti=2)then begin fastfont('Green, choose your warriors. Unregistered: Max. 10 ',10,143,20,0,ownseg,0,1);
unitcol:=3;end;
if(unitti=3)then begin fastfont('Yellow, choose your warriors. Unregistered: Max. 10',10,143,20,0,ownseg,0,1);
unitcol:=14;end;
{$ENDIF}

repeat
if line<=10 then point(7,(line*12),141,10+(line*12),unitcol);
if line>10 then point(143,((line-10)*12),277,10+((line-10)*12),unitcol);
wipe(ownseg,$a000,0,0,16000);
if line<=10 then point(7,(line*12),141,10+(line*12),0);
if line>10 then point(143,((line-10)*12),277,10+((line-10)*12),0);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#72)and(line>1)then dec(line);if(c1=#80)and(line<pls)then inc(line);
if(c1=#75)and(line>10)then dec(line,10);if(c1=#77)and(line+10<=pls)then inc(line,10);

if(c1=#28)then begin alr:=false;
if(chosen[unitti,line]=true)then begin chosen[unitti,line]:=false;dec(plamo);alr:=true;end;

{$IFNDEF unregistered}
if(chosen[unitti,line]=false)and(plamo<20)and(alr=false)then
{$ELSE}
if(chosen[unitti,line]=false)and(plamo<10)and(alr=false)then
{$ENDIF}
begin chosen[unitti,line]:=true;inc(plamo);end;
move_custom(mem[gfxseg:(gr1[unitti]-1)*1440+281+(line-1)*58],s[1],16);if chosen[unitti,line]=true then bc:=unitcol else bc:=0;
if line<=10 then
fastfont(s,10,1+line*12,20,bc,ownseg,0,1) else fastfont(s,145,1+(line-10)*12,20,bc,ownseg,0,1);end;
until(c1=#1)and(plamo>0);
gr[unitti]:=plamo;
end;

procedure helpscreen;
var hscreen:byte;
begin
palswap;
fade(4);
clear($a000,16000);
assign(f,'gamedata\help.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do
begin
setpal(i,0,0,0);
defpal[i*3]:=mem[ownseg:i*3];
defpal[i*3+1]:=mem[ownseg:i*3+1];
defpal[i*3+2]:=mem[ownseg:i*3+2];
end;
for wo:=0 to 768 do sofpal[wo]:=0;
assign(f,'gfx\helpf.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
wipe(ownseg,$a000,0,0,16000);
fade(4);
for wo:=0 to 768 do defpal[wo]:=0;
hscreen:=0;
repeat
ch:=readk;
if ch<>#1 then
begin
hscreen:=1-hscreen;
if hscreen=0 then begin
assign(f,'gfx\helpf.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
wipe(ownseg,$a000,0,0,16000);
end else
begin
assign(f,'gfx\helps.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
wipe(ownseg,$a000,0,0,16000);
end;
end;
until ch=#1;
ch:=#0;
fade(4);
clear($a000,16000);

init(1);drawmap;
menufill(mline);
end;

procedure endstatisticsscreen;
var value:array[0..teams] of longint;del1:real;
    goexit:byte;

procedure drawbars(cord:byte);
begin
del:=0;for a:=0 to teams do if(del<value[a])then del:=value[a];
if(del<>0)then begin del1:=del/100;
for a:=0 to teams do value[a]:=round(value[a]/del1);

for wo1:=1 to 100 do begin
for a:=0 to teams do if(value[a]>=wo1)then begin
  mem[$a000:(a*3+cord)*320+166+wo1]:=a+1;
  mem[$a000:(a*3+cord+1)*320+166+wo1]:=a+1;
  if(keypressed)then begin
  { dummy }
  asm xor ax,ax;int 16h;mov c1,ah;end;
  goexit:=1;break;end;
  end;
if(value[0]>=wo1)or(value[1]>=wo1)or(value[2]>=wo1)or(value[3]>=wo1)then wait(2);
if(goexit=1)then break;
end;

end;
end;

begin
palswap;
fade(4);
clear($a000,16000);
assign(f,'gamedata\ends.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do begin
defpal[i*3]:=mem[ownseg:i*3];
defpal[i*3+1]:=mem[ownseg:i*3+1];
defpal[i*3+2]:=mem[ownseg:i*3+2];
end;
assign(f,'gfx\endstat.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
wipe(ownseg,$a000,0,0,16000);
fade(4);

wait(20);
goexit:=0;

for a:=0 to teams do value[a]:=0;
for a:=0 to teams do for i:=1 to warriors do
if(dead[a,i]=false)or(escaped[a,i]=true)then inc(value[a],5);
for wo1:=1 to 100 do begin
for a:=0 to teams do if(value[a]>=wo1)then begin
mem[$a000:(a*3+16)*320+166+wo1]:=a+1;
mem[$a000:(a*3+17)*320+166+wo1]:=a+1;
if(keypressed)then begin
{ dummy }
asm xor ax,ax;int 16h;mov c1,ah;end;
goexit:=1;break;end;
end;
if(value[0]>=wo1)or(value[1]>=wo1)or(value[2]>=wo1)or(value[3]>=wo1)then wait(2);
if(goexit=1) then break;
end;

wait(15);
for a:=0 to teams do value[a]:=0;
for a:=0 to teams do for i:=1 to gr[a] do
if(dead[a,i]=true)and(escaped[a,i]=false)then inc(value[a],5);

if(goexit=0) then
for wo1:=1 to 100 do begin
for a:=0 to teams do if(value[a]>=wo1)then begin
mem[$a000:(a*3+31)*320+166+wo1]:=a+1;
mem[$a000:(a*3+32)*320+166+wo1]:=a+1;
if(keypressed)then begin
{ dummy }
asm xor ax,ax;int 16h;mov c1,ah;end;
goexit:=1;break;end;
end;
if(value[0]>=wo1)or(value[1]>=wo1)or(value[2]>=wo1)or(value[3]>=wo1)then wait(2);
if(goexit=1) then break;
end;

wait(15);for a:=0 to teams do value[a]:=shots[a];
if(goexit=0) then drawbars(46);

for a:=0 to teams do begin
if(shots[a]>0)then value[a]:=round((hits[a]/shots[a])*100) else value[a]:=0;
end;
if(goexit=0)then
for wo1:=1 to 100 do begin
for a:=0 to teams do if(value[a]>=wo1)then begin
mem[$a000:(a*3+61)*320+166+wo1]:=a+1;
mem[$a000:(a*3+62)*320+166+wo1]:=a+1;
if(keypressed)then begin
{ dummy }
asm xor ax,ax;int 16h;mov c1,ah;end;
goexit:=1;break;end;
end;
if(value[0]>=wo1)or(value[1]>=wo1)or(value[2]>=wo1)or(value[3]>=wo1)then wait(2);
if(goexit=1) then break;
end;

wait(15);for a:=0 to teams do value[a]:=dcaused[a];
if(goexit=0)then drawbars(76);

wait(15);for a:=0 to teams do value[a]:=penet[a];
if(goexit=0)then drawbars(91);

wait(15);for a:=0 to teams do value[a]:=dbleed[a];
if(goexit=0)then drawbars(106);

wait(15);for a:=0 to teams do value[a]:=mpsused[a];
if(goexit=0)then drawbars(121);

wait(15);for a:=0 to teams do value[a]:=ifound[a];
if(goexit=0)then drawbars(136);

wait(15);for a:=0 to teams do value[a]:=eprimed[a];
if(goexit=0)then drawbars(151);

for a:=0 to teams do for i:=1 to gr[a] do inc(expgain[a],xpgain[a,i]);
wait(15);for a:=0 to teams do value[a]:=expgain[a];
if(goexit=0)then drawbars(166);

wait(15);for a:=0 to teams do value[a]:=mgain[a];
if(goexit=0)then drawbars(181);

if(goexit=0)then
asm xor ax,ax;int $16;end;
for wo:=0 to 768 do defpal[wo]:=0;
fade(4);
end;

procedure endstuff;
var winners:byte;
    wingrp:array[0..teams-1] of byte;

begin

li1:=0;
for a:=1 to gr[grp] do inc(li1,mps[grp,a]);
li2:=grpmps[grp]-li1;
inc(mpsused[grp],li2);

pntr:=false;for a1:=0 to 1 do for i1:=1 to gr[a1] do begin c2:=1;
repeat
if(invprime[a1,i1,c2]<>0)then begin dec(invprime[a1,i1,c2]);
if(invprime[a1,i1,c2]<1)then begin
xda:=mem[wepseg:(invtype[a1,i1,c2]-1)*59+26];yda:=mem[wepseg:(invtype[a1,i1,c2]-1)*59+27];
efa:=mem[wepseg:(invtype[a1,i1,c2]-1)*59+28];era:=mem[wepseg:(invtype[a1,i1,c2]-1)*59+29];
exgrp:=a1;expln:=i1;
explosion(plx[a1,i1],ply[a1,i1],era,yda+random(xda),efa);drop(a1,i1,c2,true);dec(c2);end;
pntr:=true;
dell;
end;inc(c2);
until(c2>15);end;
if(dritem>0)then begin wo1:=0;
repeat inc(wo1);
if(itemp[wo1]<>0)then begin
dec(itemp[wo1],1);
if(itemp[wo1]<1)and(mem[wepseg:(itemt[wo1]-1)*59+1]=4)then begin
xda:=mem[wepseg:(itemt[wo1]-1)*59+26];yda:=mem[wepseg:(itemt[wo1]-1)*59+27];
efa:=mem[wepseg:(itemt[wo1]-1)*59+28];era:=mem[wepseg:(itemt[wo1]-1)*59+29];

exgrp:=0;expln:=itemex[wo1];
if(itemex[wo1]>warriors)then begin exgrp:=1;expln:=itemex[wo1]-warriors;end;
if(itemex[wo1]>(2*warriors))then begin exgrp:=2;expln:=itemex[wo1]-(2*warriors);end;
if(itemex[wo1]>(3*warriors))then begin exgrp:=3;expln:=itemex[wo1]-(3*warriors);end;

explosion(itemx[wo1],itemy[wo1],era,yda+random(xda),efa);
pntr:=true;
for c3:=wo1 to dritem+1 do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itema[c3]:=itema[c3+1];itemt[c3]:=itemt[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;
dec(dritem);dec(wo1);
end;end;
until(wo1>=dritem);
end;
dell;

if(esced=1)then begin
inftxt('The fight was cancelled.        ',15,1,0);
inftxt('Press enter to continue.        ',15,2,0);
repeat ch:=readk;until ch=#28;
end;

if(esced=0)then begin       { Esced ? }
for i:=0 to teams do begin wic[i]:=0;for a:=1 to gr[i] do
if(dead[i,a]=false)then wic[i]:=1;end;
winners:=0;
for i:=0 to teams do if wic[i]=1 then inc(winners);

if(wic[0]=1)or(wic[1]=1)or(wic[2]=1)or(wic[3]=1)then begin
inftxt('       ...And we have a winner...   ',15,1,0);
inftxt('      !!!   CONGRATULATIONS   !!!    ',15,2,0);end;

if(wic[0]=0)and(wic[1]=0)and(wic[2]=0)and(wic[3]=0)then begin
inftxt('All teams were crushed...       ',15,1,0);
inftxt('Press enter to continue.        ',15,2,0);end;
repeat ch:=readk;until ch=#28;

assign(f,'data\groups.dat');reset(f,29000);blockread(f,mem[gfxseg:0],1);close(f);

c3:=0;
for i:=0 to teams do if(wic[i]=1)then begin wingrp[c3]:=i;inc(c3);end;


if(dritem>0)then { Items to groups }
for c3:=1 to dritem do
if(itemt[c3]<>0)and(itemhide[c3]=0)then begin
a1:=random(winners);
si:=wingrp[a1];
if(gr1[si]<>100)then begin
wo:=25+(gr1[si]-1)*1440;
if(mem[gfxseg:wo+itemt[c3]]<99)and(control[si]=1)then
inc(mem[gfxseg:wo+itemt[c3]]);
end;
end;                           { Items to groups }


for del:=0 to teams do if(wic[del]=0)then begin { Losers armors to pool }
for c3:=1 to gr[del] do if(arminuse[del,c3]<>0)and(dead[del,c3]=true)and(escaped[del,c3]=false)then
begin
a1:=random(winners);
si:=wingrp[a1];
if(gr1[si]<>100)then begin
wo:=25+(gr1[si]-1)*1440;
if(mem[gfxseg:wo+200+arminuse[del,c3]]<99)and(control[si]=1)then
inc(mem[gfxseg:wo+200+arminuse[del,c3]]);end;
end;
end;                                            { Losers armors to pool }



for si:=0 to teams do if(control[si]=1)then begin  { Do all teams loop }


if(wic[si]=1)then begin         { if winner then take armors, please }
{ Winners own armors to storage }
for c3:=1 to gr[si] do if(arminuse[si,c3]<>0)and(dead[si,c3]=true)then
begin wo:=25+(gr1[si]-1)*1440;
if(mem[gfxseg:wo+200+arminuse[si,c3]]<99)then inc(mem[gfxseg:wo+200+arminuse[si,c3]]);end;
{ Winners own armors to storage }
end;                            { if winner then take armors, please }

if(wic[si]=1)then begin wo:=0;    { If winner then add victories }
move_custom(mem[gfxseg:21+(gr1[si]-1)*1440],wo,2);inc(wo);move_custom(wo,mem[gfxseg:21+(gr1[si]-1)*1440],2);
end;

if(wic[si]=0)then begin wo:=0;    { If loser then add losses }
move_custom(mem[gfxseg:23+(gr1[si]-1)*1440],wo,2);inc(wo);move_custom(wo,mem[gfxseg:23+(gr1[si]-1)*1440],2);
end;

end;                                               { Do all teams loop }

for nu:=0 to teams do if(control[nu]=1)then begin a:=0;  { Skill & Exp }
for wo:=1 to warriors do if(plnnum[nu,wo]<>0)then begin inc(a);
if(dead[nu,a]=false)and(escaped[nu,a]=false)then inc(xpgain[nu,a],300+random(300));
inc(skpoints[nu,a],xpgain[nu,a]);inc(exp[nu,a],xpgain[nu,a]);
if(skpoints[nu,a]>999999)then skpoints[nu,a]:=999999;if(exp[nu,a]>999999)then exp[nu,a]:=999999;
c3:=281+((gr1[nu]-1)*1440)+((plnnum[nu,a]-1)*58);
move_custom(exp[nu,a],mem[gfxseg:c3+16],4);
move_custom(skpoints[nu,a],mem[gfxseg:c3+20],4);
for i:=1 to 6 do mem[gfxseg:c3+30+i]:=lochps[nu,a,i];
move_custom(invtype[nu,a,1],mem[gfxseg:c3+43],15);
end;
end;                                                     { Skill & Exp }

{ Deleting dead members }
for nu:=0 to teams do if(control[nu]=1)then begin a:=0;by1:=0;
for wo:=1 to warriors do
if(plnnum[nu,wo]<>0)then begin inc(a);
if(dead[nu,a]=true)and(escaped[nu,a]=false)then begin
for i:=(plnnum[nu,a]-by1) to 19 do begin c3:=281+((gr1[nu]-1)*1440)+((i-1)*58);
move_custom(mem[gfxseg:c3+58],mem[gfxseg:c3],58);end;
for e:=0 to 57 do mem[gfxseg:c3+58+e]:=0;
del:=mem[gfxseg:25+(gr1[nu]-1)*1440];dec(del);mem[gfxseg:25+(gr1[nu]-1)*1440]:=del;inc(by1);end;
end;end;
{ Deleting dead members }

for nu:=0 to teams do if(control[nu]=1)then begin        { Fixing money }
lisa:=0;del:=0;
move_custom(mem[gfxseg:17+(gr1[nu]-1)*1440],del,4);
lisa:=killed[nu]*100;lisa:=lisa*100;del:=del+lisa;mgain[nu]:=lisa;
if(wic[nu]=1)then begin inc(del,30000 div winners);inc(mgain[nu],30000 div winners);end;
if(del>999999999)then del:=999999999;
move_custom(del,mem[gfxseg:17+(gr1[nu]-1)*1440],4);
end;                               { Fixing money }

assign(f,'data\groups.dat');reset(f,29000);blockwrite(f,mem[gfxseg:0],1);close(f);
end;                        { Esced ? }
end;

procedure melee;
var sect2,end1,bare,mable,manh:boolean;
    dcol,melt1,melt2,koh,hitran,hitpla,pay,mhand,hg,hn,notext,place:byte;
    temhps,maccu,mdam,trans,tdam,damb:integer;
    hitp:word;

function rc(xm,ym:byte):boolean;
begin if(round(sqrt(sqr(plx[grp,pln]-xm)+sqr(ply[grp,pln]-ym)))<2)then rc:=true else rc:=false;end;
begin
broken:=0;
end1:=false;meled:=false;mable:=false;bare:=false;mhand:=0;manh:=false;

if(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]=3)and(lochps[grp,pln,3]>0)then
begin mhand:=rarm[grp,pln];mable:=true;end;

if(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]=3)and(lochps[grp,pln,4]>0)then
begin mhand:=larm[grp,pln];mable:=true;end;

if(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]=3)and
(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]=3)and(larm[grp,pln]<>rarm[grp,pln])and
(lochps[grp,pln,3]>0)and(lochps[grp,pln,4]>0)then begin
inftxt('Which hand to attack with ?     ',15,1,0);
inftxt('(r)ight or (l)eft hand          ',15,2,0);
repeat ch:=readk;until (ch=#38)or(ch=#19);
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
if(ch=#19)then mhand:=rarm[grp,pln];
if(ch=#38)then mhand:=larm[grp,pln];
mable:=true;end;

if(mhand=0)and(lochps[grp,pln,3]+lochps[grp,pln,4]>0)then begin mable:=true;bare:=true;end;
accuracy:=melaccu[grp,pln];
if(mable=true)then begin
if mhand<>0 then readwep(invtype[grp,pln,mhand]);
if bare=false then pay:=round(mpscost*0.01*basmp[grp,pln]);
if bare=true then pay:=10;

if(mps[grp,pln]<pay) then mpsflash;
if(mps[grp,pln]>=pay)then begin

if(bare=true)then inftxt('You are attacking barehanded.   ',15,1,0) else begin
inftxt('You are attacking with          ',15,1,0);inftxt(wepnam,15,1,23);end;
inftxt(cle,0,2,0);

ix:=plx[grp,pln];iy:=ply[grp,pln];pntr:=false;ico:=true;
repeat
drawmap;ch:=readk;
case ch of
#77:if(ix<mapx)and(rc(ix+1,iy)=true)then
begin if cx<98 then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)>13)then cx:=cx+1;ix:=ix+1;end;
#75:if(ix>1)and(rc(ix-1,iy)=true)then
begin if cx>-3 then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)<1)then cx:=cx-1;ix:=ix-1;end;
#72:if(iy>1)and(rc(ix,iy-1)=true)then
begin if cy>-3 then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)<1)then cy:=cy-1;iy:=iy-1;end;
#80:if(iy<mapy)and(rc(ix,iy+1)=true)then
begin if cy<98 then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)>13)then cy:=cy+1;iy:=iy+1;end;
#46:begin cx:=ix-4;cy:=iy-3;end;
end;
until(ch=#28)or(ch=#1);

for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=ix)and(ply[a,i]=iy)and(dead[a,i]=false)then
if(ix<>plx[grp,pln])or(iy<>ply[grp,pln])then begin hg:=a;hn:=i;manh:=true;end;

if(ch=#28)then begin
if(secheck(plx[grp,pln],ply[grp,pln],ix,iy,fc[grp,pln])=1)then sect2:=true else sect2:=false;

if(plx[grp,pln]=ix)and(ply[grp,pln]=iy)then sect2:=false;

if(sect2=true)and(manh=true)then begin
if(bare=false)then mdam:=ydam+random(xdam+1);
if(bare=true)then mdam:=random(5)+1;

maccu:=round((melaccu[grp,pln]+accuracy)/2);

melt1:=fc[hg,hn]+4;if(melt1>7)then dec(melt1,8);
melt2:=secheck(plx[hg,hn],ply[hg,hn],plx[grp,pln],ply[grp,pln],melt1);
if(melt2=1)then begin inc(maccu,15);inftxt(cle,15,1,0);
inftxt('Backstabbing bonus +15% !       ',2,1,0);inftxt(cle,15,2,0);
repeat ch:=readk;until ch=#28;ch:=#0;
end;

if(maccu<5)then maccu:=5;if(maccu>99)then maccu:=99;
inftxt(cle,15,1,0);inftxt('Chances to hit are :   % >    < ',15,1,0);
inftxt('Press esc to skip attacking.  ',15,2,0);str(maccu,s);inftxt(s,15,1,21);
ch:=readk;if ch=#1 then end1:=true;inftxt(cle,0,2,0);
if(end1=false)then dec(mps[grp,pln],pay);

if(end1=false)then begin play('melee.svs',10000);
a:=1+random(99);str(a,s);inftxt(s,15,1,27);wait(20);
if(a<=maccu)and(end1=false)then begin
{ melee damage }

damb:=random(100)+1;
if(damb>=93)and(damb<=97)then begin
mdam:=round(mdam*1.5);
inftxt(cle,15,1,0);inftxt('A severe hit. 150% damage !     ',2,1,0);
repeat ch:=readk;until ch=#28;
end;

if(damb>=98)and(damb<=100)then begin
mdam:=round(mdam*2);
inftxt(cle,15,1,0);inftxt('A critical hit. 200% damage !   ',2,1,0);
repeat ch:=readk;until ch=#28;
end;


if(ally[grp]<>ally[hg])then inc(xpgain[exgrp,expln],mdam*4);

cx:=ix-4;cy:=iy-3;ico:=false;drawmap;effect(16,1);
hitran:=random(16)+1;koh:=19;

if(hitran=1)then begin hitpla:=1;koh:=8;s:='Head ';place:=5;end;
if(hitran=2)or(hitran=3)or(hitran=4)or(hitran=5)or(hitran=6)then begin hitpla:=2;koh:=28;s:='Chest ';place:=6;end;
if(hitran=7)or(hitran=8)then begin hitpla:=3;koh:=16;s:='Right arm ';place:=10;end;
if(hitran=9)or(hitran=10)then begin hitpla:=4;koh:=16;s:='Left arm ';place:=9;end;
if(hitran=11)or(hitran=12)or(hitran=13)then begin hitpla:=5;koh:=16;s:='Right leg ';place:=10;end;
if(hitran=14)or(hitran=15)or(hitran=16)then begin hitpla:=6;koh:=16;s:='Left leg ';place:=9;end;

if(hitpla>2)and(lochps[hg,hn,hitpla]=0)then notext:=1 else notext:=0;

tdam:=mdam-locaps[hg,hn,hitpla];
temhps:=lochps[hg,hn,hitpla]-tdam;
if temhps<0 then temhps:=0;
hitp:=round(temhps/((tothps[hg,hn]*koh)/100)*100);
if(lochps[hg,hn,hitpla])=0 then hitp:=200;

if(hitp<=100)then begin s1:='barely wounded        ';dcol:=14;end;
if(hitp<=75)then begin s1:='lightly wounded        ';dcol:=5;end;
if(hitp<=50)then begin s1:='heavily wounded       ';dcol:=6;end;
if(hitp<=25)then begin s1:='critically wounded    ';dcol:=7;end;
if(hitp=200)then begin s1:='blown useless already ';dcol:=8;end;
if(hitp=0)then begin
case hitpla of
1:s1:='blown off !              ';
2:s1:='He''s down !              ';
3:s1:='blown useless !          ';
4:s1:='blown useless !          ';
5:s1:='blown useless !          ';
6:s1:='blown useless !          ';
end;
dcol:=8;
end;
if(tdam<1)then begin s1:='armor hit             ';dcol:=3;end;
if(hitpla<>2)or(hitp>0)then inftxt(s,dcol,2,0) else place:=0;
inftxt(s1,dcol,2,place);

str(mdam,s);
inftxt('Damage caused :                 ',15,1,0);inftxt(s,15,1,17);
repeat ch:=readk;until ch=#28;

if tdam>0 then begin
if(hg<>grp)then inc(penet[grp],tdam);

end;

if(tdam<0)then tdam:=0;dec(lochps[hg,hn,hitpla],tdam);
dec(locaps[hg,hn,hitpla],round(mdam/3));if locaps[hg,hn,hitpla]<0 then locaps[hg,hn,hitpla]:=0;
if(lochps[hg,hn,hitpla]<=0)then begin
trans:=-lochps[hg,hn,hitpla];lochps[hg,hn,hitpla]:=0;
if(trans>0)and(hitpla>2)then begin
temp1:=trans-locaps[hg,hn,2];if temp1<0 then temp1:=0;dec(lochps[hg,hn,2],temp1);
if lochps[hg,hn,2]<0 then lochps[hg,hn,2]:=0;
dec(locaps[hg,hn,2],round(trans/3));if locaps[hg,hn,2]<0 then locaps[hg,hn,2]:=0;
str(trans,s);


if(lochps[hg,hn,1]>0)and(lochps[hg,hn,2]<1)then begin
inftxt('He''s down !                   ',2,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until ch=#28;end;

end;end;


if(lochps[hg,hn,1]<=0)or(lochps[hg,hn,2]<=0)then begin
dead[hg,hn]:=true;
if(grp<>hg)then inc(killed[grp]);

for by1:=1 to 15 do if(invtype[hg,hn,1]<>0)then drop(hg,hn,1,false);
cx:=ix-4;cy:=iy-3;ico:=false;drawmap;play('death.svs',10000);effect(17,1);
end;
if(mem[wepseg:(invtype[hg,hn,rarm[hg,hn]]-1)*59+32]=1)and(lochps[hg,hn,3]=0)and
(invtype[hg,hn,rarm[hg,hn]]<>0)then begin drop(hg,hn,rarm[hg,hn],false);rarm[hg,hn]:=0;end;
if(mem[wepseg:(invtype[hg,hn,larm[hg,hn]]-1)*59+32]=1)and(lochps[hg,hn,4]=0)and
(invtype[hg,hn,larm[hg,hn]]<>0)then begin drop(hg,hn,larm[hg,hn],false);larm[hg,hn]:=0;end;

if((mem[wepseg:(invtype[hg,hn,rarm[hg,hn]]-1)*59+32]=2))and(invtype[hg,hn,rarm[hg,hn]]<>0)then
if(lochps[hg,hn,3]=0)or(lochps[hg,hn,4]=0)then begin drop(hg,hn,rarm[hg,hn],false);rarm[hg,hn]:=0;larm[hg,hn]:=0;end;

end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);meled:=true; { end of melee damage }
end;
end else begin
if(sect2=false)then
if(plx[grp,pln]=ix)and(ply[grp,pln]=iy)then begin
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end else begin inftxt('Target out of sector.          ',15,1,0);
inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);end;

if(manh=false)and(sect2=true)then begin

if bare=false then mdam:=ydam+random(xdam)+1;
if bare=true then mdam:=random(5)+1;
if(end1=false)then dec(mps[grp,pln],pay);

play('melee.svs',10000);wait(20);
ico:=false;cx:=ix-4;cy:=iy-3;drawmap;effect(239,1);

{ Do we have to calc the lights ? }
{if(mdam>=walldam)and(wall[map[ix,iy]]=true)then broken:=1;}

if(map[ix,iy]=1)and(bare=false)then map[ix,iy]:=65;
if(map[ix,iy]=2)and(bare=false)then map[ix,iy]:=66;
if(map[ix,iy]=3)and(bare=false)then map[ix,iy]:=67;
if(map[ix,iy]=4)and(bare=false)then map[ix,iy]:=68;
if(map[ix,iy]=42)and(bare=false)then begin map[ix,iy]:=65;explosion(ix,iy,5,27+random(14),5);dell;end;
if(map[ix,iy]=43)and(bare=false)then begin map[ix,iy]:=65;explosion(ix,iy,6,42+random(14),5);dell;end;
pntr:=true;
if(mdam>=walldam)and(map[ix,iy]>=5)and(map[ix,iy]<=17)then begin map[ix,iy]:=69;broken:=1;end;
if(mdam>=round(walldam*1.5))and(map[ix,iy]>=18)and(map[ix,iy]<=22)then begin map[ix,iy]:=69;broken:=1;end;
if(mdam>=walldam*2)and(map[ix,iy]=23)then begin map[ix,iy]:=69;broken:=1;end;
if(mdam>=round(walldam*1.5))and(map[ix,iy]>=24)and(map[ix,iy]<=27)then begin map[ix,iy]:=69;broken:=1;end;
if(mdam>=walldam)and(map[ix,iy]>=28)and(map[ix,iy]<=33)then begin map[ix,iy]:=69;broken:=1;end;

if(mdam>=doordam)and(map[ix,iy]>=34)and(map[ix,iy]<=35)then begin map[ix,iy]:=70;checkbomb(ix,iy);broken:=1;end;
if(mdam>=doordam)and(map[ix,iy]>=36)and(map[ix,iy]<=37)then map[ix,iy]:=70;
if(mdam>=doordam)and(map[ix,iy]>=38)and(map[ix,iy]<=39)then begin map[ix,iy]:=71;checkbomb(ix,iy);broken:=1;end;
if(mdam>=doordam)and(map[ix,iy]>=40)and(map[ix,iy]<=41)then map[ix,iy]:=71;

if(map[ix,iy]=44)then map[ix,iy]:=75;
if(map[ix,iy]=45)then map[ix,iy]:=76;
if(map[ix,iy]>=46)and(map[ix,iy]<=54)then map[ix,iy]:=79;
if(map[ix,iy]=55)then map[ix,iy]:=74;
if(map[ix,iy]=56)then map[ix,iy]:=72;
if(map[ix,iy]=57)or(map[ix,iy]=58)then map[ix,iy]:=73;
if(map[ix,iy]=59)or(map[ix,iy]=60)then map[ix,iy]:=78;
if(map[ix,iy]>=61)and(map[ix,iy]<=64)then map[ix,iy]:=77;

drawmap;wait(20);

end;
end;

end;
end else begin {inftxt('Not enough movement points.    ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);}end;

cnt;pntr:=true;ico:=false;

end else begin inftxt('Your both hands are disabled.  ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);end;
if(broken=1)then calclights;see;drawmap;
end;

procedure statscreen;


begin

palswap;fade(4);clear($a000,16000);

for wo:=0 to 767 do sofpal[wo]:=0;
assign(f,'gamedata\stats.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for c3:=0 to 767 do defpal[c3]:=mem[ownseg:c3];
assign(f,'gfx\stats.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
wipe(ownseg,$a000,0,0,16000);

fastfont(rank+' '+plname[grp,pln],15,5,207,0,ownseg,1,1);
str(exp[grp,pln],s);
fastfont('Experience        : '+s,15,23,207,0,ownseg,1,1);
str(xpgain[grp,pln],s);
fastfont('Experience gained : '+s,15,36,207,0,ownseg,1,1);
str(tothps[grp,pln],s);
fastfont('Total hitpoints   : '+s,15,49,207,0,ownseg,1,1);
str(basmp[grp,pln],s);
fastfont('Base MPS          : '+s,15,62,207,0,ownseg,1,1);
str(react[grp,pln],s);
fastfont('Reactions         : '+s,15,75,207,0,ownseg,1,1);
str(firaccu[grp,pln],s);
fastfont('Firing accuracy   : '+s,15,88,207,0,ownseg,1,1);
str(throaccu[grp,pln],s);
fastfont('Throwing accuracy : '+s,15,101,207,0,ownseg,1,1);
str(melaccu[grp,pln],s);
fastfont('Melee accuracy    : '+s,15,114,207,0,ownseg,1,1);

wo:=0;for a:=1 to 6 do inc(wo,lochps[grp,pln,a]);
bleed[grp,pln]:=tothps[grp,pln]-wo-bleeded[grp,pln];
bleed[grp,pln]:=round(bleed[grp,pln]/tothps[grp,pln]*bleedc*hfactor(grp,pln));
if(bleed[grp,pln]<0)then bleed[grp,pln]:=0;str(bleed[grp,pln],s);
fastfont('Bleeding          : '+s,15,140,207,0,ownseg,1,1);

s:='                ';
for a:=1 to 16 do begin by1:=mem[itemseg:((arminuse[grp,pln]-1)*30)+a+1];s[a]:=chr(by1);end;
if arminuse[grp,pln]=0 then s:='None';
fastfont('Armor worn        : '+s,15,127,207,0,ownseg,1,1);
wipe(ownseg,$a000,0,0,16000);

fade(4);

asm xor ax,ax;int $16;end;
for wo:=0 to 768 do defpal[wo]:=0;
fade(4);
init(1);see;drawmap;
end;

procedure viewmap;
var cx1,cy1,lo,visi:byte;
    ta,mis,iis,ne:integer;
    x3,lis:word;
    iisx,iisy:array[1..300] of byte;
    misx,misy,misc,misf:array[1..20] of byte;
procedure calc;
begin
for visiy:=1 to mapy do for visix:=1 to mapx do begin
i:=visiofsi(plx[grp,pln],ply[grp,pln],visix,visiy);
if(i=1)then if(secheck(plx[grp,pln],ply[grp,pln],visix,visiy,fc[grp,pln])=1)then
mem[visibseg:grp*10000+visiy*100+visix]:=1;
end;
mem[visibseg:grp*10000+ply[grp,pln]*100+plx[grp,pln]]:=1;
end;

procedure face(cord,fac:word);
var ni:byte;begin
case fac of
0:begin mem[ownseg:cord+321]:=14;mem[ownseg:cord+322]:=14;mem[ownseg:cord+641]:=14;end;
1:for ni:=2 to 3 do mem[ownseg:cord+321+ni]:=14;
2:begin mem[ownseg:cord+325]:=14;mem[ownseg:cord+326]:=14;mem[ownseg:cord+646]:=14;end;
3:for ni:=2 to 3 do mem[ownseg:cord+326+ni*320]:=14;
4:begin mem[ownseg:cord+1606]:=14;mem[ownseg:cord+1925]:=14;mem[ownseg:cord+1926]:=14;end;
5:for ni:=2 to 3 do mem[ownseg:cord+1921+ni]:=14;
6:begin mem[ownseg:cord+1601]:=14;mem[ownseg:cord+1921]:=14;mem[ownseg:cord+1922]:=14;end;
7:for ni:=2 to 3 do mem[ownseg:cord+321+ni*320]:=14;
end;end;

procedure drawman(cord:word;col,fa:byte);
var colt:longint;
begin
if(col=0)then colt:=$05050505;         { Other warriors }
if(col=1)then colt:=$07070707;
if(col=2)then colt:=$09090909;
if(col=3)then colt:=$0b0b0b0b;

if(col=10)then colt:=$06060606;        { Warrior in use }
if(col=11)then colt:=$08080808;
if(col=12)then colt:=$0a0a0a0a;
if(col=13)then colt:=$0c0c0c0c;

memw[ownseg:cord+643]:=colt;
meml[ownseg:cord+962]:=colt;
meml[ownseg:cord+1282]:=colt;
memw[ownseg:cord+1603]:=colt;
face(cord,fa);
end;

procedure iball(cord:word);
begin
memw[ownseg:cord+963]:=$0e0e;
memw[ownseg:cord+1283]:=$0e0e;
end;

procedure deptoscre(cord:word;col:byte);assembler;
asm mov es,ownseg;mov di,cord;mov bl,col;mov ax,4
@loop:
mov [es:di],bl;mov [es:di+2],bl;mov [es:di+4],bl;mov [es:di+6],bl;
mov [es:di+321],bl;mov [es:di+323],bl;mov [es:di+325],bl;mov [es:di+327],bl;
add di,640;dec ax
jnz @loop
end;

procedure draw2dmap;var x1,y1,x2,y2,lig:byte;
begin
for x1:=12 to 140 do clear1(ownseg,x1*320+32,64);
for x1:=cx1 to cx1+31 do for y1:=cy1 to cy1+15 do begin if((map[x1,y1])>39)then lis:=2240 else lis:=0;
x3:=(32+12*320)+((y1-cy1)shl 11)+((y1-cy1)shl 9)+((x1-cx1)shl 3);
if(mem[visibseg:grp*10000+y1*100+x1]>0)then
put2d(ownseg,x3,wepseg,lis+(map[x1,y1] shl 3),lightval[lightmap[x1,y1]]);

if(visi=1)and(mem[visibseg:grp*10000+y1*100+x1]<>1)then deptoscre(x3,13);

if(iis>0)then for c3:=1 to iis do if(iisx[c3]=x1)and(iisy[c3]=y1)then iball(x3);
if(mis>0)then for c3:=1 to mis do if(misx[c3]=x1)and(misy[c3]=y1)then
if(plx[grp,pln]=x1)and(ply[grp,pln]=y1)then
drawman(x3,10+misc[c3],misf[c3]) else
drawman(x3,misc[c3],misf[c3]);

end;
wipe(ownseg,$a000,0,0,16000);
end;

begin
clear(wepseg,1500);clear(ownseg,1500);
loadpic('gfx\minimap.svf');for wo:=0 to 5119 do mem[wepseg:wo]:=mem[ownseg:wo];
palswap;
fade(4);

assign(f,'gamedata\view.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do begin
setpal(i,0,0,0);
defpal[i*3]:=mem[ownseg:i*3];
defpal[i*3+1]:=mem[ownseg:i*3+1];
defpal[i*3+2]:=mem[ownseg:i*3+2];
end;
for wo:=0 to 768 do sofpal[wo]:=0;

loadpic('gfx\view.svf');wipe(ownseg,$a000,0,0,16000);

{manlight(1);}
mis:=0;iis:=0;lo:=0;pntr:=false;visi:=0;calc;

for li1:=1 to dritem do if(itemhide[li1]=0)then
begin ne:=0;for a:=1 to gr[grp] do if(dead[grp,a]=false)then begin
if(ne=0)then begin ne:=secheck(plx[grp,a],ply[grp,a],itemx[li1],itemy[li1],fc[grp,a]);
if(ne=1)then ne:=visiofsi(plx[grp,a],ply[grp,a],itemx[li1],itemy[li1]);end;
end;
if(ne=1)then begin inc(iis);iisx[iis]:=itemx[li1];iisy[iis]:=itemy[li1];end;
end;

for a:=0 to teams do for i:=1 to gr[a] do
if(escaped[a,i]=false)and(dead[a,i]=false)then if(insi[a,i]=true)then begin
inc(mis);misx[mis]:=plx[a,i];misy[mis]:=ply[a,i];misf[mis]:=fc[a,i];misc[mis]:=a;end;

ta:=plx[grp,pln]-16;if(ta<=0)then ta:=1;if(ta>mapx-31)then ta:=mapx-31;cx1:=ta;
ta:=ply[grp,pln]-8;if(ta<=0)then ta:=1;if(ta>mapy-15)then ta:=mapy-15;cy1:=ta;
draw2dmap;

fade(4);

repeat
asm xor ax,ax;int $16;mov c1,ah;end;
if(c1=#72)then if(cy1>1)then begin dec(cy1);draw2dmap;end;
if(c1=#75)then if(cx1>1)then begin dec(cx1);draw2dmap;end;
if(c1=#77)then if(cx1<mapx-31)then begin inc(cx1);draw2dmap;end;
if(c1=#80)then if(cy1<mapy-15)then begin inc(cy1);draw2dmap;end;
if(c1=#1)then lo:=1;
if(c1=#57)then begin visi:=1-visi;draw2dmap;end;
until lo=1;
{manlight(0);}
pntr:=true;

for wo:=0 to 768 do defpal[wo]:=0;
fade(4);
clear($a000,16000);
wepstoseg;

calcvisiall;fillvisi;see;
init(1);see;drawmap;
end;

end.
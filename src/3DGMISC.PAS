{$F+ $O+}
unit 3dgmisc;

interface
procedure selectcontroller;



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


end.
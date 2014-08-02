{$F+}
{$M 50000,0,147000}
uses overlay,crt,sbunit,varunit,pbtunit,extunit,gamemisc;
{$O pbtunit}
{$O extunit}
{$O sbunit}
{$O gamemisc}

label finalend,finalend1;

procedure musicint;interrupt;
begin
asm mov al,20h;out 20h,al;end;
if(mver=1)and(musics=1)then playmusic;
end;

procedure getvect(vec:byte);
begin asm mov ah,$35;mov al,vec;int $21;mov oldintseg,es;mov oldintofs,bx;end;end;

procedure setvect(vec:byte;tseg,tofs:word);
begin asm push ds;mov ah,$25;mov al,vec;mov dx,tofs;mov ds,tseg;int $21;pop ds;end;end;

procedure menufl(row:byte);
begin
if(mline<>row)then begin menuflash(row,bcolo,4,15,15);wait(10);menuflash(row,4,bcolo,15,15);end else
begin menuflash(row,15,4,bcolo,15);wait(10);menuflash(row,15,bcolo,4,15);end;
end;

function keypress:boolean;label nt;begin asm mov ah,1;int $16;jnz nt end;keypress:=false;nt:end;

begin        { THE 3DGAME BEGINS FROM THIS LINE }
{ Check the config-file somewhere here in the begining !!! }

ovrinit('3dgame.ovr');
{writeln(ovrgetbuf);asm xor ax,ax;int 16h;end;}
ovrinitems;

randomize;
asm mov ax,13h;int 10h;end;
losseg:=seg(map);losofs:=ofs(map)+1290;
entseg:=seg(firable);entofs:=ofs(firable);

getmem(ma,6000);wepseg:=seg(ma^);
getmem(ma,1900);itemseg:=seg(ma^);
getmem(ma,48600);gfxseg:=seg(ma^);
getmem(ma,12600);infoseg:=seg(ma^);
getmem(ma,8000);mgfxseg:=seg(ma^);
getmem(ma,4000);minfoseg:=seg(ma^);
getmem(ma,280);igfxseg:=seg(ma^);
getmem(ma,280);iinfoseg:=seg(ma^);
getmem(ma,40100);visibseg:=seg(ma^);

getmem(ma,6000);fontseg:=seg(ma^);
assign(f,'gfx\font.fnt');reset(f,6000);blockread(f,mem[fontseg:0],1);close(f);

new(wseen_p);

{ Checking the parameters given by payback.exe }
mver:=0;ver:=0;sounds:=false;musics:=0;
if(paramcount>0)then begin
val(paramstr(1),ver,code);if(ver=1)then sounds:=true;
val(paramstr(2),mver,code);if(mver=1)then musics:=1;
val(paramstr(3),base,code);
val(paramstr(4),dma,code);
val(paramstr(5),irq,code);
val(paramstr(6),ownseg,code);
val(paramstr(7),musaseg,code);
val(paramstr(8),wo,code);memw[seg(musaptr):ofs(musaptr)]:=wo;
val(paramstr(9),wo,code);memw[seg(musaptr):ofs(musaptr)+2]:=wo;
val(paramstr(10),debug,code);
val(paramstr(11),tuneseg,code);
end else begin
asm mov ax,3h;int 10h;end;for i:=1 to 26 do writeln;goxy(0,0);
writeln('Error occured     : STARTED THE WRONG FILE.');
writeln('Solution proposed : TRY EXECUTING ''PAYBACK.EXE'' FILE PLEASE.');
goto finalend1;
end;
{ Checking the parameters given by payback.exe }

tch:=true;pntr:=true;turn:=1;pln:=1;grp:=0;icol:=242;
cle:='                                          ';mline:=1;

enter[1]:=true;enter[2]:=true;enter[3]:=true;enter[4]:=true;enter[36]:=true;enter[37]:=true;enter[40]:=true;enter[41]:=true;
enter[65]:=true;enter[66]:=true;enter[67]:=true;enter[68]:=true;enter[69]:=true;enter[70]:=true;enter[71]:=true;
enter[72]:=true;enter[73]:=true;enter[74]:=true;enter[75]:=true;enter[76]:=true;enter[77]:=true;enter[78]:=true;
enter[79]:=true;

oply[34]:=true;oply[35]:=true;oply[36]:=true;oply[37]:=true;
oply[38]:=true;oply[39]:=true;oply[40]:=true;oply[41]:=true;

open[36]:=true;open[37]:=true;open[40]:=true;open[41]:=true;

firable[1]:=true;firable[2]:=true;firable[3]:=true;firable[4]:=true;firable[16]:=true;firable[17]:=true;firable[36]:=true;
firable[37]:=true;firable[40]:=true;firable[41]:=true;firable[45]:=true;firable[46]:=true;firable[47]:=true;firable[48]:=true;
firable[49]:=true;firable[50]:=true;firable[51]:=true;firable[52]:=true;firable[53]:=true;firable[54]:=true;firable[56]:=true;
firable[61]:=true;firable[62]:=true;firable[63]:=true;firable[64]:=true;firable[65]:=true;firable[66]:=true;firable[67]:=true;
firable[68]:=true;firable[69]:=true;firable[70]:=true;firable[71]:=true;firable[72]:=true;firable[73]:=true;firable[74]:=true;
firable[75]:=true;firable[76]:=true;firable[77]:=true;firable[78]:=true;firable[79]:=true;

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

interable[1]:=true;
interable[2]:=true;
interable[3]:=true;
interable[4]:=true;
interable[16]:=false;
interable[17]:=false;
interable[36]:=false;
interable[37]:=false;
interable[40]:=false;
interable[41]:=false;
interable[42]:=false;
interable[43]:=false;
interable[45]:=false;
interable[46]:=false;
interable[47]:=false;
interable[48]:=false;
interable[49]:=false;
interable[50]:=false;
interable[51]:=false;
interable[52]:=false;
interable[53]:=false;
interable[54]:=false;
interable[55]:=false;
interable[56]:=false;
interable[57]:=false;
interable[58]:=false;
interable[59]:=false;
interable[60]:=false;
interable[61]:=false;
interable[62]:=false;
interable[63]:=false;
interable[64]:=false;
interable[65]:=true;
interable[66]:=true;
interable[67]:=true;
interable[68]:=false;
interable[69]:=false;
interable[70]:=false;
interable[71]:=false;
interable[72]:=false;
interable[73]:=false;
interable[74]:=true;
interable[75]:=false;
interable[76]:=false;
interable[77]:=false;
interable[78]:=false;
interable[79]:=false;

for i:=5 to 35 do wall[i]:=true;
wall[38]:=true;
wall[39]:=true;
wall[44]:=true;

fcx[0]:=-1;fcy[0]:=-1;
fcx[1]:=0;fcy[1]:=-1;
fcx[2]:=+1;fcy[2]:=-1;
fcx[3]:=+1;fcy[3]:=0;
fcx[4]:=+1;fcy[4]:=+1;
fcx[5]:=0;fcy[5]:=+1;
fcx[6]:=-1;fcy[6]:=+1;
fcx[7]:=-1;fcy[7]:=0;
for a:=0 to teams do for i:=1 to warriors do begin oppor[a,i]:=true;mode[a,i]:=0;end;

initsound;

clear(tuneseg,2500);
s:='music\start.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
getvect(8);
initplayer(tuneseg);
musics:=1;
setvect(8,seg(musicint),ofs(musicint));{setintvec(8,Addr(musicint));}
timer:=round(1193180/52);
{ ajastimen alustus }
asm
cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;
end;

error:=false;
if checkfile('data\groups.dat')=false then begin asm mov ax,3h;int 10h;end;for i:=1 to 26 do writeln;
goxy(0,0);writeln('Error occured : Groups.dat file does not exist.');error:=true;end;

{$IFNDEF unregistered}
if checkfile('data\weapons.dat')=false then begin
if error=false then begin asm mov ax,3h;int 10h;end;for i:=1 to 26 do writeln;goxy(0,0);end;
writeln('Error occured : Weapons.dat file does not exist.');error:=true;end;
if checkfile('data\items.dat')=false then begin
if error=false then begin asm mov ax,3h;int 10h;end;for i:=1 to 26 do writeln;goxy(0,0);end;
writeln('Error occured : Items.dat file does not exist.');error:=true;end;
{$ENDIF}

if error=true then goto finalend;

clear(ownseg,16000);
clear(wepseg,1500);

assign(f,'gamedata\mds.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do begin
frontpal[i*3]:=mem[ownseg:i*3];
frontpal[i*3+1]:=mem[ownseg:i*3+1];
frontpal[i*3+2]:=mem[ownseg:i*3+2];
setpal(i,mem[ownseg:i*3],mem[ownseg:i*3+1],mem[ownseg:i*3+2]);
end;
{loadpic('gfx\modes.svf');}
assign(f,'gfx\modes.svf');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);

wipe(ownseg,$a000,0,0,16000);
away:=false;i:=1;
uselight:=1;
ambientl:=0;
reports:=1;
repeat
if reports=1 then fastfont('On ',194,55,33,193,ownseg,0,0) else
fastfont('Off',194,55,33,193,ownseg,0,0);
str(ambientl,s);
if ambientl<10 then s:=s+' ';
fastfont(s,198,66,33,193,ownseg,0,0);

point(67,42+(i*11),253,52+(i*11),33);
wipe(ownseg,$a000,0,0,16000);
point(67,42+(i*11),253,52+(i*11),179);
asm xor ax,ax;int 16h;mov c1,ah;end;
if(c1=#72)then begin dec(i);if i<1 then i:=6;if i=3 then i:=2;end;
if(c1=#80)then begin inc(i);if i>6 then i:=1;if i=3 then i:=4;end;
if((c1=#75)or(c1=#77))and(i=1)then reports:=1-reports;
if(c1=#75)and(i=2)and(ambientl>0)then dec(ambientl);
if(c1=#77)and(i=2)and(ambientl<10)then inc(ambientl);

if(c1=#1)then begin away:=true;c1:=#28;i:=3;end;
until (c1=#28)and(i>=3);
gmode:=i-3;if(away=true)then begin asm mov ax,3h;int 10h;end;goto finalend;end;

if(ambientl=10)then uselight:=0;
if(uselight=0)then
for yt:=1 to 100 do for xt:=1 to 100 do inc(lightmap[xt,yt],ambientl+1);

palswap;
fade(4);

{ Load map begins here }
s:=filload('maps','*.map');
mapname:=s;
chdir('..');
if nofils=true then begin asm mov ax,3h;int 10h;end;
for i:=1 to 26 do writeln;goxy(0,0);writeln('Error occured : No map files in the directory.');
goto finalend;end;
if away=true then begin asm mov ax,3h;int 10h;end;goto finalend;end;
chdir('maps');

{$IFNDEF unregistered}
assign(f,s);reset(f,100);for i:=1 to 100 do blockread(f,map[i,1],1);close(f);
clear(musaseg,3500);
assign(f,s);reset(f,10000);seek(f,1);blockread(f,mem[musaseg:0],1);close(f);
reset(f,20606);blockread(f,mem[ownseg:0],1);close(f);
{$ELSE}
assign(f,'mintegr.dat');
reset(f,20606);
seek(f,filline-1);
blockread(f,mem[ownseg:0],1);
close(f);

wor3:=0;
for wor1:=1 to 100 do
for wor2:=1 to 100 do begin map[wor1,wor2]:=mem[ownseg:wor3];
inc(wor3);end;

clear(musaseg,3500);
for wor1:=0 to 9999 do
mem[musaseg:wor1]:=mem[ownseg:10000+wor1];

{$ENDIF}
chdir('..');

lightamo:=0;
for wo:=1 to 200 do { lights }
begin
lightsx[wo]:=mem[ownseg:20000+wo*3-3];
lightsy[wo]:=mem[ownseg:20000+wo*3+1-3];
lightst[wo]:=mem[ownseg:20000+wo*3+2-3];
if(lightst[wo]>0)then inc(lightamo);
end;

mapx:=mem[ownseg:20600];
mapy:=mem[ownseg:20601];
walldam:=mem[ownseg:20602];
doordam:=mem[ownseg:20603];
itempd:=mem[ownseg:20604];
itemm:=mem[ownseg:20605];
clear(ownseg,16000);

{ Load map ends here }

{ If swapfile exists then NO choose units nor controller selection}
{ Select controllers for different teams begins here }

selectcontroller;
for byt:=0 to teams do drawable[byt]:=1;
if(away=true)then begin asm mov ax,$3;int $10;end;goto finalend;end;

{ Select controllers for different teams ends here }

{ Choose units begins here, if no swapfile }

for byt:=0 to teams do if(control[byt]=1)then begin
chooseunits(byt);
if(pntr=true)then begin asm mov ax,$3;int $10;end;goto finalend;end;
chooseplayers(byt);
end;
itemtoseg;wepstoseg;
for byt:=0 to teams do if(control[byt]>1)then cpuchooseplayers(byt);

{ Choose units ends here, Fix players into units begins here }

for nu:=0 to teams do begin a:=0;
for wo:=1 to 20 do if(chosen[nu,wo]=true)then begin inc(a);plnnum[nu,a]:=wo;end;
end;

for nu:=0 to teams do if(control[nu]=1)then begin a:=0;
for wo:=1 to 20 do begin
if(chosen[nu,wo]=true)then begin inc(a);
c3:=16;move_custom(mem[seg(c3):ofs(c3)],plname[nu,a][0],1);
c3:=1+((gr1[nu]-1)*1440+280)+((wo-1)*58);
move_custom(mem[gfxseg:c3],plname[nu,a][1],16);
move_custom(mem[gfxseg:c3+16],mem[seg(exp[nu,a]):ofs(exp[nu,a])],4);
move_custom(mem[gfxseg:c3+20],mem[seg(skpoints[nu,a]):ofs(skpoints[nu,a])],4);
arminuse[nu,a]:=mem[gfxseg:c3+24];tothps[nu,a]:=mem[gfxseg:c3+25];
basmp[nu,a]:=mem[gfxseg:c3+26];mps[nu,a]:=basmp[nu,a];
react[nu,a]:=mem[gfxseg:c3+27];firaccu[nu,a]:=mem[gfxseg:c3+28];
melaccu[nu,a]:=mem[gfxseg:c3+29];throaccu[nu,a]:=mem[gfxseg:c3+30];
for i:=1 to 6 do begin lochps[nu,a,i]:=mem[gfxseg:c3+30+i];
e:=mem[gfxseg:c3+36+i];locaps[nu,a,i]:=e;totaps[nu,a,i]:=e;end;
move_custom(mem[gfxseg:c3+43],mem[seg(invtype[nu,a,1]):ofs(invtype[nu,a,1])],15);
end;end;end;
{ Fix players into units ends here }

clear(gfxseg,12150);
clear(infoseg,3150);
clear(mgfxseg,2000);
clear(minfoseg,1000);
clear(igfxseg,70);
clear(iinfoseg,70);
clear(visibseg,10000);

assign(f1,'gamedata\tgfx.dat');reset(f1);le1:=filesize(f1);close(f1);
assign(f1,'gamedata\tinfo.dat');reset(f1);le2:=filesize(f1);close(f1);
assign(f,'gamedata\tgfx.dat');reset(f,le1);blockread(f,mem[gfxseg:0],1);close(f);
assign(f,'gamedata\tinfo.dat');reset(f,le2);blockread(f,mem[infoseg:0],1);close(f);
assign(f,'gamedata\mgfx.dat');reset(f,7652);blockread(f,mem[mgfxseg:0],1);close(f);
assign(f,'gamedata\minfo.dat');reset(f,3920);blockread(f,mem[minfoseg:0],1);close(f);
assign(f,'gamedata\igfx.dat');reset(f,221);blockread(f,mem[igfxseg:0],1);close(f);
assign(f,'gamedata\iinfo.dat');reset(f,188);blockread(f,mem[iinfoseg:0],1);close(f);


wepstoseg;itemtoseg;
for nu:=0 to teams do if(control[nu]>0)then begin
for wo:=1 to gr[nu] do begin armin:=false;
for a:=1 to 15 do begin

if(invtype[nu,wo,a]>=1)and(invtype[nu,wo,a]<=100)then begin
c3:=1;s:='    ';for e:=1 to 4 do begin by1:=mem[wepseg:((invtype[nu,wo,a])-1)*59+49+e];
if(by1<>32)then inc(c3);s[e]:=chr(by1);end;delete(s,c3,5-c3);val(s,clsize,code);
invammo[nu,wo,a]:=clsize;end;

if(invtype[nu,wo,a]>=101)and(invtype[nu,wo,a]<=200)then begin
c3:=1;s:='    ';for e:=1 to 4 do begin by1:=mem[wepseg:((invtype[nu,wo,a])-101)*59+49+e];
if(by1<>32)then inc(c3);s[e]:=chr(by1);end;delete(s,c3,5-c3);val(s,clsize,code);
invammo[nu,wo,a]:=clsize;end;

if(invtype[nu,wo,a]>=200)and(invtype[nu,wo,a]<=250)then invammo[nu,wo,a]:=mem[itemseg:(invtype[nu,wo,a]-201)*30+24];

if(armin=false)and(invtype[nu,wo,a]>=1)and(invtype[nu,wo,a]<=100)then begin
if(mem[wepseg:((invtype[nu,wo,a])-1)*59+32]=1)and(lochps[nu,wo,3]>0)then begin rarm[nu,wo]:=a;armin:=true;end;
if(mem[wepseg:((invtype[nu,wo,a])-1)*59+32]=1)and(lochps[nu,wo,4]>0)then begin larm[nu,wo]:=a;armin:=true;end;
if(mem[wepseg:((invtype[nu,wo,a])-1)*59+32]=2)and(lochps[nu,wo,3]>0)and(lochps[nu,wo,4]>0)then
begin rarm[nu,wo]:=a;larm[nu,wo]:=a;armin:=true;end;
end;
end;end;end;

for a:=0 to teams do if(control[a]=0)then gr[a]:=0;
for a:=0 to teams do for wo:=1 to warriors do dead[a,wo]:=true;
for a:=0 to teams do if(control[a]>0)then for wo:=1 to gr[a] do dead[a,wo]:=false;
for a:=0 to teams do for i:=1 to warriors do xpgain[a,i]:=0;
wepstoseg;itemtoseg;

{ Fix drawers begins here }
a:=0;for x1:=1 to mapx do for y1:=1 to mapy do if(map[x1,y1]=59)or(map[x1,y1]=60)then inc(a);
{ a=drawers in battlefield }
if a>0 then begin
i:=itemm;itemm:=round(50/a);if(itemm>i)then itemm:=i;if(itemm=0)then itemm:=1;
if(itempd<>0)then for x1:=1 to mapx do for y1:=1 to mapy do  { drawer stuff }
if(map[x1,y1]=59)or(map[x1,y1]=60)then begin

for c2:=1 to itemm do if((random(100)+1)<(itempd))and(dritem<50)then
begin                                      { some items into 1 drawer }

inc(dritem);
itemx[dritem]:=x1;
itemy[dritem]:=y1;
itemp[dritem]:=0;
itemhide[dritem]:=1;

i:=0;for a:=1 to 49 do if(mem[itemseg:1+(a-1)*30]=2)then inc(i);

byt:=0;if(i>0)and(random(5)=4)then begin a:=1+random(i);byt:=1;
if(mem[itemseg:1+(a-1)*30]=2)then itemt[dritem]:=200+a;
end else itemt[dritem]:=1+random(weapon_amount);

if(byt=0)then begin c3:=1;s:='    ';
for e:=1 to 4 do begin by1:=mem[wepseg:(itemt[dritem]-1)*59+49+e];
if(by1<>32)then inc(c3);s[e]:=chr(by1);end;
delete(s,c3,5-c3);val(s,itema[dritem],code);
end else itema[dritem]:=mem[itemseg:24+(a-1)*30];
end;                                       { some items into 1 drawer }
end;                                       { drawer stuff }
end;
{ Fix drawers ends here }

assign(f,'gamedata\light.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=0 to 255 do begin
frontpal[i*3]:=mem[ownseg:i*3];
frontpal[i*3+1]:=mem[ownseg:i*3+1];
frontpal[i*3+2]:=mem[ownseg:i*3+2];
end;

assign(f,'gamedata\tile2.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for i:=240 to 254 do begin
frontpal[i*3]:=mem[ownseg:i*3];
frontpal[i*3+1]:=mem[ownseg:i*3+1];
frontpal[i*3+2]:=mem[ownseg:i*3+2];
end;
for wo:=0 to 768 do defpal[wo]:=0;
fade(4);

for wo:=0 to 255 do topcol[wo]:=wo;

for wo:=0 to 255 do begin
if(wo>=16)and(wo<=37) then topcol[wo]:=37;
if(wo>=38)and(wo<=63) then topcol[wo]:=63;
if(wo>=96)and(wo<=111) then topcol[wo]:=111;
if(wo>=112)and(wo<=145) then topcol[wo]:=145;
if(wo>=146)and(wo<=171) then topcol[wo]:=171;
if(wo>=172)and(wo<=188) then topcol[wo]:=188;
if(wo>=189)and(wo<=213) then topcol[wo]:=213;
if(wo>=214)and(wo<=239) then topcol[wo]:=239;
end;

precalcl;
calclights;

clear(ownseg,16000);
wipe(ownseg,$a000,0,0,16000);
init(0);wepstoseg;clear(itemseg,450);
assign(f,'gamedata\depinfo.dat');reset(f,448);blockread(f,mem[itemseg:0],1);close(f);
for a:=0 to teams do for i:=1 to gr[a] do begin wo:=0;
for c2:=1 to 6 do inc(wo,lochps[a,i,c2]);bleeded[a,i]:=tothps[a,i]-wo;end;

init_fastp_586(ownseg,gfxseg,infoseg);

                      { Deployment begins }

for i:=0 to teams do for a:=1 to warriors do begin
plx[i,a]:=200;ply[i,a]:=200;insi[i,a]:=true;inhusi[i,a]:=true;end;

for byt2:=0 to teams do
if(control[byt2]=1)then begin
if(byt2=0)then begin s1:='Blue will deploy now.  ';setpal(255,10,10,63);end;
if(byt2=1)then begin s1:='Red will deploy now.   ';setpal(255,63,0,0);end;
if(byt2=2)then begin s1:='Green will deploy now. ';setpal(255,0,63,0);end;
if(byt2=3)then begin s1:='Yellow will deploy now.';setpal(255,63,63,0);end;
inftxt('Press enter to deploy. ',255,1,0);
inftxt(s1,255,2,0);
repeat asm mov ah,0;int 16h;mov c1,ah;end;until c1=#28;
deployment(byt2,gr[byt2]);
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
clear(ownseg,16000);
for i:=0 to 127 do wipe(ownseg,$a000,0,i*320,64);
end;
for byt2:=0 to teams do if(control[byt2]>1)then cpudeploy(byt2,gr[byt2]);

                      { Deployment ends }

clear(musaseg,3500);clear(itemseg,450);itemtoseg;
if(gmode=1)then for wo:=0 to 40000 do mem[visibseg:wo]:=2;

visimode:=true;
fastmode:=false;
grp:=teams; { Due to the first turn }
turn:=0;
pntr:=true;

a:=musics;
musics:=0;
s:='music\a1.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
initplayer(tuneseg);
musics:=a;

timer:=round(1193180/50);
{ ajastimen alustus }
asm
cli;push ax;push cx;mov al,36h;out 43h,al;pusha;popa;mov cx,timer;mov al,cl;
out 40h,al;pusha;popa;mov al,ch;out 40h,al;pusha;popa;pop cx;pop ax;sti;
end;

repeat
chturn;
until(lop=true)or(control[grp]=1);
ch:=#0;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);cnt;see;
grpmps[grp]:=0;for a:=1 to gr[grp] do inc(grpmps[grp],basmp[grp,a]);

for a:=0 to teams do        {We've seen nobody}
for i:=1 to warriors do
for tm:=0 to teams do
for wo:=1 to warriors do 
for a1:=1 to 4 do wseen_p^[a,i,tm,wo,a1]:=-10;

repeat             { GAMELOOP }
tm:=0;for i:=1 to 6 do begin inc(tm,lochps[grp,pln,i]);end;
tem:=(tm/tothps[grp,pln]);if tem>1 then tem:=1.0;tem:=2.0-tem;
if(lochps[grp,pln,1]<round(tothps[grp,pln]*0.04))then tem:=tem+0.3;
if(lochps[grp,pln,3]=0)then tem:=tem+0.2;
if(lochps[grp,pln,4]=0)then tem:=tem+0.2;
if(lochps[grp,pln,5]=0)then tem:=tem+0.4;
if(lochps[grp,pln,6]=0)then tem:=tem+0.4;
tem2:=tem*tem;
ico:=false;

drawmap;

if(oppor[grp,pln]=true)then fastfont(' ON',234,160,tcolo,bcolo,$a000,0,0) else fastfont('OFF',234,160,tcolo,bcolo,$a000,0,0);

fastfont(rank_short(grp,pln)+plname[grp,pln]+'  ',14,162,tcolo,bcolo,$a000,0,0);

fastfont('Health : ',14,180,tcolo,bcolo,$a000,0,0);
s:='Where am I ?    ';
if tem<=1.75 then s:='Critical        ';
if tem<=1.5 then s:='Heavily wounded ';
if tem<=1.25 then s:='Slightly wounded';
if tem<=1.1 then s:='OK              ';
fastfont(s,70,180,tcolo,bcolo,$a000,0,0);

str(mps[grp,pln],s);
if(mps[grp,pln]<10)then insert('  ',s,1);
if(mps[grp,pln]<100)and(mps[grp,pln]>=10)then insert(' ',s,1);
fastfont(s,276,24,tcolo,87,$a000,0,0);

str(turn,s);
if(turn<10)then insert('  ',s,1);
if(turn<100)and(turn>=10)then insert(' ',s,1);
fastfont(s,276,53,tcolo,bcolo,$a000,0,0);

if(reports=1) then reportwar(grp,pln);

if(lop=false)then ch:=readk;  { case ch of }

if(ch=#14)then begin
play('tick.svs',10000);
menuflash(mline,15,4,bcolo,15);wait(10);menuflash(mline,15,bcolo,4,15);
case mline of
1:ch:=#57;
2:ch:=#28;
3:ch:=#50;
4:ch:=#20;
5:ch:=#25;
6:ch:=#30;
7:ch:=#35;
8:ch:=#23;
9:ch:=#31;
10:ch:=#34;
11:ch:=#47;
12:ch:=#38;
13:ch:=#33;
14:ch:=#17;
15:ch:=#49;
16:ch:=#19;
17:ch:=#18;
18:ch:=#1;
19:ch:=#16;
end;
end;

if(ch=#28)and(free=false)then begin
menufl(2);exgrp:=grp;expln:=pln;calcvisi1all;shoot;dell;
if(broken=1)then calclights;
if(shooted=true)then pguard;calcvisiall;see;
drawmap;ch:=#0;end;

if(ch=#46)then cnt;

if(ch=#34)then if(free=false)then begin
menufl(10);if(oppor[grp,pln]=false)then oppor[grp,pln]:=true else oppor[grp,pln]:=false;end;

if(ch=#35)then if(free=false)then begin
menufl(7);health;ch:=#0;menufill(mline);end;

if(ch=#49)then if(free=false)then begin menufl(15);nguy;end;

if(ch=#38)then if(free=false)and(visimode=false)then begin menufl(12);
{for visiy:=1 to mapy do for visix:=1 to mapx do begin
i:=visiofsi(plx[grp,pln],ply[grp,pln],visix,visiy);
if(i=1)then if(secheck(plx[grp,pln],ply[grp,pln],visix,visiy,fc[grp,pln])=1)then
mem[visibseg:grp*10000+visiy*100+visix]:=1;
end;}
{mem[visibseg:grp*10000+ply[grp,pln]*100+plx[grp,pln]]:=1;}
visimode:=true;
{inftxt('You are now in visibility-mode. ',15,1,0);
}
inftxt('Dummy light disabled.           ',15,1,0);
wait(30);
inftxt(cle,0,1,0);end
else
if(visimode=true)then begin menufl(12);
inftxt('Dummy light enabled.            ',15,1,0);
wait(30);
inftxt(cle,0,1,0);
visimode:=false;pntr:=true;
{cnt;
calcvisiall;
fillvisi;
see;}
drawmap;
end;

if(ch=#17)then if(free=false)then begin menufl(14);wepstat;ch:=#0;end;

if(ch=#31)then if(free=false)then begin menufl(9);statscreen;ch:=#0;menufill(mline);end;

if(ch=#47)then if(free=false)then begin menufl(11);viewmap;ch:=#0;menufill(mline);end;

if(ch=#23)then if(free=false)then begin menufl(8);invscreen;see;ch:=#0;menufill(mline);end;

if(ch=#25)then if(free=false)then begin menufl(5);pickup;see;if(pickuped=true)then pguard;see;ch:=#0;end;

if(ch=#30)then if(free=false)then begin menufl(6);healing;see;if(healed=true)then pguard;see;ch:=#0;end;

if(ch=#20)then if(free=false)then begin menufl(4);calcvisi1all;throwing;see;if(throwed=true)then pguard;see;ch:=#0;end;

if(ch=#57)then if(free=false)then begin menufl(1);usedoor;calcvisi1;see;if(doped=true)then pguard;see;ch:=#0;end;

if(ch=#50)then if(free=false)then begin
menufl(3);exgrp:=grp;expln:=pln;melee;calcvisi1;see;if meled=true then pguard;see;ch:=#0;end;

if(ch=#18)then if(free=false)then begin
menufl(17);snd:=false;if(ver<>0)and(sounds=true)then
begin sounds:=false;snd:=true;inftxt('Effects are disabled.           ',15,1,0);wait(30);end;
if(snd=false)and(ver<>0)and(sounds=false)then
begin sounds:=true;inftxt('Effects are enabled.            ',15,1,0);wait(30);end;
inftxt(cle,0,1,0);see;end;

if(ch=#19)then if(free=false)then begin
menufl(16);snd:=false;if(mver<>0)and(musics=1)then
begin musics:=0;endplayer;
snd:=true;inftxt('Music disabled.                 ',15,1,0);wait(30);end;
if(snd=false)and(mver<>0)and(musics=0)then
begin musics:=1;initplayer(tuneseg);
inftxt('Music enabled.                  ',15,1,0);wait(30);end;
inftxt(cle,0,1,0);see;end;

if(ch=#33)then if(free=true)then begin
menufl(13);free:=false;pntr:=true;inftxt(cle,0,1,0);cnt;see;drawmap;end else begin
menufl(13);calcvisi1all;pntr:=false;free:=true;inftxt('You are now in freescroll-mode. ',15,1,0);end;

if(ch=#73)then begin menufill(mline);dec(mline);if(mline<1)then mline:=19;menufill(mline);end;

if(ch=#81)then begin menufill(mline);inc(mline);if(mline>19)then mline:=1;menufill(mline);end;

if(ch=#72)then if free=false then begin
fw:=true;moving;cnt;calcvisi1;see;if moved=true then pguard;see;end
else begin if cx>0 then dec(cx);if cy>0 then dec(cy);end;

if(ch=#80)then if free=false then begin fw:=false;moving;cnt;calcvisi1;see;if moved=true then pguard;see;end
else begin if cx<mapx-7 then inc(cx);if cy<mapy-7 then inc(cy);end;

if(ch=#75)then if free=false then begin
if mps[grp,pln]<round(tem2) then mpsflash;
if mps[grp,pln]>=round(tem2) then begin
play('turn.svs',12000);dec(mps[grp,pln],round(tem2));
if fc[grp,pln]>0 then dec(fc[grp,pln])else fc[grp,pln]:=7;calcvisi1;see;pguard;see;end;end
else begin if cx>0 then dec(cx);if cy<mapy-7 then inc(cy);end;

if(ch=#77)then if free=false then begin
if mps[grp,pln]<round(tem2) then mpsflash;
if mps[grp,pln]>=round(tem2) then begin
play('turn.svs',12000);dec(mps[grp,pln],round(tem2));
if fc[grp,pln]<7 then inc(fc[grp,pln]) else fc[grp,pln]:=0;calcvisi1;see;pguard;see;end;end
else begin if cx<mapx-7 then inc(cx);if cy>0 then dec(cy);end;

if(ch=#59)then helpscreen;

if(ch=#60)then
if(fastmode=true) then
begin
fastmode:=false;
inftxt('Fast game-mode disabled.        ',15,1,0);wait(30);
inftxt(cle,0,1,0);see;
end else
begin
fastmode:=true;
inftxt('Fast game-mode enabled.         ',15,1,0);wait(30);
inftxt(cle,0,1,0);see;
end;

if(ch=#16)then begin menufl(19);play('quit.svs',8000);
inftxt('Want to quit already ?          ',15,1,0);inftxt('Press [F10] to confirm...       ',15,2,0);
ch:=readk;if ch=#68 then begin lop:=true;esced:=1;end else begin
if free=false then inftxt(cle,0,1,0);inftxt(cle,0,2,0);see;
if free=true then inftxt('You are now in freescroll-mode. ',15,1,0);end;end;

if(ch=#1)then if(free=false)then begin
menufl(18);inftxt('Do you want to end your turn ? ',15,1,0);ch:=readk;
if(ch=#21)then
begin
 repeat chturn;until(control[grp]=1)or(lop=true);
end
 else begin inftxt(cle,0,1,0);see;end;
end
else begin visimode:=false;free:=false;pntr:=true;cnt;calcvisiall;fillvisi;inftxt(cle,0,1,0);see;end;

{end;} { case ch of }

{ Check if guys are dead }
i:=0;
for a:=1 to gr[grp] do if(dead[grp,a]=false)then i:=1;
if(i=0)then repeat chturn;until(control[grp]=1)or(lop=true);
{ Check if guys are dead }

{ End game check }
if(lop=false)then begin
{i:=0;
for wo:=0 to teams do begin c3:=0;
for a:=1 to gr[wo] do if(dead[wo,a]=false)and(c3=0)then begin c3:=1;inc(i);end;end;
if(i<2)then lop:=true;}
lop:=true;
for i:=0 to teams do begin wiped[i]:=1;
for c3:=1 to warriors do if(dead[i,c3]=false)then wiped[i]:=0;end;
for i:=0 to teams do if(wiped[i]=0)then c3:=i;
for i:=0 to teams do if(wiped[i]=0)and(ally[i]<>ally[c3])then lop:=false;

end;
{ End game check }

until lop=true;    { GAMELOOP }
endstuff;
if(esced=0)then begin
endplayer;
a:=musics;musics:=0;s:='music\endtune.svm';
assign(f1,s);reset(f1);wo:=filesize(f1);close(f1);
assign(f,s);reset(f,wo);blockread(f,mem[tuneseg:0],1);close(f);
initplayer(tuneseg);musics:=a;
endstatisticsscreen;
end;
asm mov ax,3h;int 10h end;
finalend:

wait(10);
freesound;

musics:=0;endplayer;
setvect(8,oldintseg,oldintofs);
asm mov al,54;out $43,al;pusha;popa;mov cx,0; { Ajastimen ja ajan palautus }
mov al,cl;out $40,al;pusha;popa;mov al,ch;out $40,al;
mov ah,4;int $1a;mov ah,2;int $1a;mov bl,10;mov al,ch;and ch,15;shr al,4;mul bl;add ch,al;mov al,cl;and cl,15;
shr al,4;mul bl;add cl,al;mov al,dh;and dh,15;shr al,4;mul bl;add dh,al;mov dl,0;mov ah,$2d;int $21;end;
finalend1:

{writeln(memavail);
asm xor ax,ax;int $16;end;}

end.         { THE 3DGAME ENDS TO THIS LINE }

{$F+ $O+}
unit pbtunit;

interface
uses sbunit,varunit,extunit;

procedure cputurn(teami:byte);
procedure chturn;
procedure cpushoot(teami,man,tgrp,tman:byte);
procedure cpuchooseplayers(teami:byte);
procedure cpudeploy(teami,boys:byte);
procedure cpureload(teami,man:byte);

implementation

procedure cputurn(teami:byte);     { CPUTURN }
var doneall,shootok,hpla,his,quit,a1,i,o,u,t1,t2,f1,f2:byte;nwo,wox,woy:word;
    su:shortint;
    limbcond:array[1..6] of real;
    f:file;af1:file of byte;

const hmodi:array[1..6] of real=(0.8,0.28,0.16,0.16,0.16,0.16);
const psidelay:array[2..5] of byte=(2,2,1,0); { Delay before knowledge }

function hucount:byte;
var a1,a2,a3,wo:byte;
begin
a2:=0;a3:=0;
for a1:=0 to teams do if(control[a1]=1)then begin { Human teams left }
for wo:=1 to gr[a1] do if(dead[a1,wo]=false)then a2:=1;
if(a2=1)then begin inc(a3);a2:=0;end;
end;
hucount:=a3;
end;

procedure countallinsi;
var huteam,a1,i1,o1:byte;
begin
for a1:=0 to teams do for wo:=1 to warriors do inhusi[a1,wo]:=false;

huleft:=hucount;

if(huleft=0)or(debug=1)then begin debug:=1;    { CPU teams fighting }
for a1:=0 to teams do if(control[a1]>0)then drawable[a1]:=1 else drawable[a1]:=0;
for a1:=0 to teams do for wo:=1 to warriors do inhusi[a1,wo]:=true;
end;                                           { CPU teams fighting }

if(huleft=1)then begin           { Huleft = 1 }
for a1:=0 to teams do if(control[a1]=1)then
for o1:=1 to gr[a1] do if(dead[a1,o1]=false)then huteam:=a1;

for a1:=0 to teams do if(control[a1]>1)then  { All cputeams }
for i1:=1 to warriors do                     { All warriors in a cputeam }
for o1:=1 to gr[huteam] do                   { Every living human }
if(dead[huteam,o1]=false)then
if(secheck(plx[huteam,o1],ply[huteam,o1],plx[a1,i1],ply[a1,i1],fc[huteam,o1])=1)then
if(visiofsi(plx[huteam,o1],ply[huteam,o1],plx[a1,i1],ply[a1,i1])=1)then
inhusi[a1,i1]:=true;

for a1:=0 to teams do if(control[a1]>0)then drawable[a1]:=1 else drawable[a1]:=0;
for a1:=1 to gr[huteam] do inhusi[huteam,a1]:=true;
end;                             { Huleft = 1 }
end;

procedure lookcond(teami,man:byte);
begin
wo:=0;
for a:=1 to 6 do inc(wo,lochps[teami,man,a]);
bleed[teami,man]:=tothps[teami,man]-wo-bleeded[teami,man];
bleed[teami,man]:=round(bleed[teami,man]/tothps[teami,man]*bleedc*hfactor(grp,pln));
if(bleed[teami,man]<0)then bleed[teami,man]:=0;

hcond[man]:=0;lcond[man]:=0;
if(lochps[teami,man,3]=0)then hcond[man]:=1;
if(lochps[teami,man,4]=0)then hcond[man]:=2;
if(lochps[teami,man,3]=0)and(lochps[teami,man,4]=0)then hcond[man]:=3;
if(lochps[teami,man,5]=0)then lcond[man]:=1;
if(lochps[teami,man,6]=0)then lcond[man]:=2;
if(lochps[teami,man,5]=0)and(lochps[teami,man,6]=0)then lcond[man]:=3;
end;

procedure countvisi(teami,man:byte);
var a1,i1:byte;
begin
foes[man]:=0;
for a1:=0 to teams do if(control[a1]<>0)and(teami<>a1)and(ally[teami]<>ally[a1])then
for i1:=1 to gr[a1] do
if(visiofsi(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1])=1)and
(dead[a1,i1]=false)then inc(foes[man]);
end;

function nearest(teami,man:byte):byte;
var a1,i1,gro1,man1,ran:byte;
function rc(x1,y1,x2,y2:byte):byte;begin rc:=round(sqrt(sqr(x1-x2)+sqr(y1-y2)));end;
begin
ran:=200;
gro1:=0;
man1:=0;
for a1:=0 to teams do for i1:=1 to gr[a1] do if(a1<>teami)and(ally[teami]<>ally[a1])and(dead[a1,i1]=false)then
if(rc(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1])<ran)then
if(visiofsi(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1])=1)and
(visiman(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1],teami)=0)then
begin
ran:=rc(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1]);
gro1:=a1;
man1:=i1;
end;
if(ran=200)then begin gro1:=0;man1:=0;end;
nearest:=gro1*warriors+man1;
end;

function snearest(teami,man:byte):byte;
var a1,i1,gro1,man1,ran:byte;
function rc(x1,y1,x2,y2:byte):byte;begin rc:=round(sqrt(sqr(x1-x2)+sqr(y1-y2)));end;
begin
ran:=200;
gro1:=0;
man1:=0;
for a1:=0 to teams do for i1:=1 to gr[a1] do if(a1<>teami)and(ally[teami]<>ally[a1])and(dead[a1,i1]=false)then
if(rc(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1])<ran)then
if(visiofsi(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1])=1)and
(secheck(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1],fc[teami,man])=1)and
(visiman(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1],teami)=0)then
begin
ran:=rc(plx[teami,man],ply[teami,man],plx[a1,i1],ply[a1,i1]);
gro1:=a1;
man1:=i1;
end;
if(ran=200)then begin gro1:=0;man1:=0;end;
snearest:=gro1*warriors+man1;
end;

procedure firstaiding(teami,man:byte);
var u,o,his:byte;
begin
{inftxt('Debug: Healing.             ',255,2,0);}

lookcond(teami,man);
if(dead[teami,man]=false)and(hcond[man]<3)then begin repeat{ Healing loop }
if(hcond[allw]>0)or(lcond[allw]>0)or
((bleed[teami,allw]*2)>=lochps[teami,allw,2])then begin { condition bad }

a1:=0;
for his:=1 to 15 do if(invtype[teami,allw,his]>200)and(invtype[teami,allw,his]<251)and(a1=0)then begin
a1:=1;           { Now heal me, please! }

for o:=1 to 6 do
limbcond[o]:=100*(lochps[teami,allw,o]/(round(hmodi[o]*tothps[teami,allw])));

o:=0;u:=150;
for o:=1 to 6 do if(limbcond[o]<u)then begin u:=round(limbcond[o]);hpla:=o;end;
if((bleed[teami,allw]*2)>=lochps[teami,allw,2])then hpla:=2;

inc(lochps[teami,allw,hpla],mem[itemseg:((invtype[teami,allw,his]-201)*30)+25]);
if(lochps[teami,allw,hpla]>round(tothps[teami,allw]*hmodi[hpla]))then
lochps[teami,allw,hpla]:=round(tothps[teami,allw]*hmodi[hpla]);
dec(invammo[teami,allw,his]);
if(invammo[teami,allw,his]<1)then drop(teami,allw,his,true);
dec(mps[teami,allw],15);
pguard;                                      { Guarding !!! }
end;             { Now heal me, please! }
end;                                         { condition bad }

quit:=0;
lookcond(teami,allw);                     { Do we quit already ? }
a1:=0;for his:=1 to 15 do if(invtype[teami,allw,his]>200)and(invtype[teami,allw,his]<251)then a1:=1;
if(a1=0)then quit:=1;

if(hcond[allw]=0)and(lcond[allw]=0)and(bleed[teami,allw]<(lochps[teami,allw,2]*2))then quit:=1;
if(mps[teami,allw]<15)then quit:=1; { Do we quit already ? }
until(quit=1);            { Healing loop }
end;
end;

procedure meleeaiding(teami,man:byte);              { Meleeaiding }
var nv,hands,h1,h2:byte;
begin

if(mode[teami,man]=1)then begin
hands:=0;h1:=0;h2:=0;
if(lochps[teami,man,3]>0)then hands:=1;
if(lochps[teami,man,4]>0)then hands:=2;
if(lochps[teami,man,3]>0)and(lochps[teami,man,4]>0)then hands:=3;

for nv:=1 to 15 do if(mem[wepseg:((invtype[teami,man,nv])-1)*59+32]=1)and
(mem[wepseg:((invtype[teami,man,nv])-1)*59+1]=3)then inc(h1);

for nv:=1 to 15 do if(mem[wepseg:((invtype[teami,man,nv])-1)*59+32]=2)and
(mem[wepseg:((invtype[teami,man,nv])-1)*59+1]=3)then inc(h2);

if(h1=0)and(h2>0)and(hands<3)then firstaiding(teami,man);
end;
end;                                                { Meleeaiding }

procedure turning(teami,man:byte);
var u,o,his:byte;
begin
a1:=0;                 { Is there a warrior already in sight? }
for u:=0 to teams do if(u<>teami)and(ally[u]<>ally[teami])then
for o:=1 to gr[u] do
if(visiofsi(plx[teami,allw],ply[teami,allw],plx[u,o],ply[u,o])=1)and
(secheck(plx[teami,allw],ply[teami,allw],plx[u,o],ply[u,o],fc[teami,allw])=1)and
(dead[u,o]=false)then a1:=1;

if(a1=0)then begin      { If no foes in sector }
i:=nearest(teami,allw);
t1:=i div 20;
t2:=i-t1*20;
u:=100;
for o:=0 to 7 do if(secheck(plx[teami,allw],ply[teami,allw],plx[t1,t2],ply[t1,t2],o)=1)then u:=o;

if(i<>0)then begin      { If someone in sight, and not in sector }
i:=0;
o:=fc[teami,allw];
for his:=1 to 8 do begin
if o<>u then begin inc(o);
inc(i);end;
if o>7 then o:=0;
end;

if(i<5)then su:=1 else su:=-1;
repeat
inc(fc[teami,allw],su);
if(fc[teami,allw]=8)then fc[teami,allw]:=0;
if(fc[teami,allw]>250)then fc[teami,allw]:=7;

if(debug=1)then begin countallinsi;
cx:=plx[teami,allw]-4;cy:=ply[teami,allw]-3;drawmap;
end;
play('turn.svs',10000);
dec(mps[teami,man],1);
if(debug=1)then wait(20);
wait(5);

{inftxt('Debug: Turning.             ',255,2,0);}

pguard;

until(secheck(plx[teami,allw],ply[teami,allw],plx[t1,t2],ply[t1,t2],fc[teami,allw])=1);
end;
end;
end;

procedure loadhands(teami,man:byte);
var capa,wehand,hands,nv1,nv2:word;
begin
wepstoseg;
wehand:=0;hands:=0;
if(lochps[teami,man,3]>0)then hands:=1;
if(lochps[teami,man,4]>0)then hands:=2;
if(lochps[teami,man,3]>0)and(lochps[teami,man,4]>0)then hands:=3;

for nv1:=1 to 15 do if(invtype[teami,man,nv1]>=1)and(invtype[teami,man,nv1]<=101)and
(mem[wepseg:((invtype[teami,man,nv1])-1)*59+1]<=2)and
(larm[teami,man]=0)and(rarm[teami,man]=0)then begin     { Get gun }

if(hands=3)then begin larm[teami,man]:=nv1;rarm[teami,man]:=nv1;end;

if(mem[wepseg:((invtype[teami,man,nv1])-1)*59+32]=1)and(hands>0)then begin
if(hands=1)then rarm[teami,man]:=nv1;
if(hands=2)then larm[teami,man]:=nv1;
end;

end;                                                    { Get gun }
if(invammo[teami,man,larm[teami,man]]+invammo[teami,man,rarm[teami,man]]<1)then cpureload(teami,man);

wepstoseg;
capa:=0;                 { Melee checking begins here }
for nv1:=1 to 15 do if(invtype[teami,man,nv1]>=1)and(invtype[teami,man,nv1]<=101)and
(mem[wepseg:((invtype[teami,man,nv1])-1)*59+1]<=2)then capa:=1;

if(capa=0)then begin mode[teami,man]:=1;   { Melee stuff }
meleeaiding(teami,man);

for nv1:=1 to 15 do if(invtype[teami,man,nv1]>=1)and(invtype[teami,man,nv1]<=101)and
(larm[teami,man]=0)and(rarm[teami,man]=0)and(hands>0)and
(mem[wepseg:((invtype[teami,man,nv1])-1)*59+1]=3)then begin { Found a melee }

if(hands=3)then begin larm[teami,man]:=nv1;rarm[teami,man]:=nv1;end;

if(mem[wepseg:((invtype[teami,man,nv1])-1)*59+32]=1)and(hands>0)then begin
if(hands=1)then rarm[teami,man]:=nv1;
if(hands=2)then larm[teami,man]:=nv1;
end;

end;                                                         { Found a melee }
end;                                       { Melee stuff }

end;

procedure hinvestigate(teami,man:byte);
var islots,c3,nv1,nv2,grabd:word;
begin

nv2:=1;
for nv1:=1 to 15 do if(invtype[teami,man,nv1]>0)then nv2:=nv1; { Free slots? }

if(nv2<15)and(dritem>0)and(larm[teami,man]=0)and(rarm[teami,man]=0)and
((lochps[teami,man,3]+lochps[teami,man,4])>0)then begin { Arm hands }
grabd:=0;
for nv1:=1 to dritem do if(plx[teami,man]=itemx[nv1])and(ply[teami,man]=itemy[nv1])and
(itemt[nv1]>=1)and(itemt[nv1]<=101)and(itema[nv1]>0)
and(grabd=0)and(mps[teami,man]>=10)then begin { We've sthing }
dec(mps[teami,man],10);

for nv2:=1 to 15 do if(invtype[teami,man,nv2]>0)then islots:=nv2+1;
invtype[teami,man,islots]:=itemt[nv1];
invammo[teami,man,islots]:=itema[nv1];
invprime[teami,man,islots]:=itemp[nv1];

for c3:=nv1 to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;
itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;

dec(dritem);grabd:=1;

end;                                                         { We've sthing }
end;                                                  { Arm hands }
loadhands(teami,man);
end;

procedure walkroute(teami,man:byte);   { WALKROUTE - Procedure }
var desx,desy,tface,a5,a6,x,y,wo,mpsc,rcount,problem,rang:integer;
begin
rcount:=0;problem:=0;wo:=routep[teami,man];grp:=teami;pln:=man;
if(dist[teami,man]>1)then
repeat                        { Repeat until - loop }

if(problem=0)then begin
x:=plx[teami,man];y:=ply[teami,man];mpsc:=0;
if(mem[visibseg:teami*10000+man*500-500+wo]=0)then begin dec(y);inc(mpsc,4);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=1)then begin dec(y);inc(x);inc(mpsc,6);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=2)then begin inc(x);inc(mpsc,4);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=3)then begin inc(y);inc(x);inc(mpsc,6);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=4)then begin inc(y);inc(mpsc,4);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=5)then begin inc(y);dec(x);inc(mpsc,6);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=6)then begin dec(x);inc(mpsc,4);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=7)then begin dec(y);dec(x);inc(mpsc,6);end;
end;

if(lochps[teami,man,5]+lochps[teami,man,6]<1)then problem:=20;
if(dead[teami,man]=true)then problem:=25;

if(mps[teami,man]>0)then        { Turning }
if(plx[teami,man]+fcx[fc[teami,man]]<>x)or(ply[teami,man]+fcy[fc[teami,man]]<>y)then begin

a6:=0;a5:=fc[teami,man];
repeat
if(a5=0)then a5:=7 else dec(a5);
inc(a6);
until(plx[teami,man]+fcx[a5]=x)and(ply[teami,man]+fcy[a5]=y);
if(a6<4)then tface:=-1 else tface:=1;
if(a6>3)then a6:=8-a6;

for a5:=1 to a6 do if(mps[teami,man]>0)then begin
if(tface=1)then if(fc[teami,man]=7)then fc[teami,man]:=0 else inc(fc[teami,man]);
if(tface=-1)then if(fc[teami,man]=0)then fc[teami,man]:=7 else dec(fc[teami,man]);
dec(mps[teami,man]);
cx:=plx[teami,man]-4;cy:=ply[teami,man]-3;
countallinsi;
play('turn.svs',10000);if(debug=1)or(inhusi[teami,man]=true)then begin drawmap;if(debug=0)then wait(10);end;
wait(3);

pguard;

hinvestigate(teami,man);

end;
end;                            { Turning }


if(mps[teami,man]>3)then begin    { Sesam open la door }
a5:=map[plx[teami,man]+fcx[fc[teami,man]],ply[teami,man]+fcy[fc[teami,man]]];
if(a5=34)or(a5=35)or(a5=38)or(a5=39)then begin usedoor;
countallinsi;
if(debug=1)or(inhusi[teami,man]=true)then begin drawmap;if(debug=0)then wait(10);end;
{inftxt('Debug: Open door.           ',255,2,0);}
wait(20);
end;

pguard;

hinvestigate(teami,man);

end;                              { Sesam open la door }

if(mps[teami,man]<mpsc)then problem:=11;          { Mps shortage }

for a5:=0 to teams do if(ally[a5]<>ally[teami])then for a6:=1 to warriors do
if(dead[a5,a6]=false)and(a5<>teami)and(mode[teami,man]=0)and
(secheck(plx[teami,man],ply[teami,man],plx[a5,a6],ply[a5,a6],fc[teami,man])=1)and
(visiman(plx[teami,man],ply[teami,man],plx[a5,a6],ply[a5,a6],teami)=0)and
(visiofsi(plx[teami,man],ply[teami,man],plx[a5,a6],ply[a5,a6])=1)then begin
rang:=round(crange(plx[teami,man],ply[teami,man],plx[a5,a6],ply[a5,a6]));
rang:=105-(rang*7);
if(rang>random(100))then begin
friend[teami,man]:=a5*warriors+a6;
{ Set AIDELAY to zero because we have a new target }
aidelay[teami,man]:=0;
problem:=12;              { Man in sight }
end;end;

if(wo>=dist[teami,man])then
begin
{ If some AIDELAY left, we'll just hang around }
if(aidelay[teami,man]>0) then begin
repeat
  desx:=plx[teami,man]+random(10)-5;
  desy:=ply[teami,man]+random(10)-5;
  if(desx<0) then desx:=0;
  if(desx>mapx) then desx:=mapx;
  if(desy<0) then desy:=0;
  if(desy>mapy) then desy:=mapy;
until (enter[map[desx,desy]]=true)and((desx<>plx[teami,man])or(desy<>ply[teami,man]));
  { Set the destination }
  aipatrolx[teami,man]:=desx;
  aipatroly[teami,man]:=desy;
  aipatrol[teami,man]:=1;
end;
problem:=13;   { Route walked through }
end;

for a5:=0 to teams do for a6:=1 to warriors do    { Man in the way }
if(plx[a5,a6]=x)and(ply[a5,a6]=y)and(dead[a5,a6]=false)then problem:=15;

if(problem=0)then begin                 { No problems }
inc(wo);
inc(routep[teami,man]);
dec(mps[teami,man],mpsc);
plx[teami,man]:=x;
ply[teami,man]:=y;
cx:=plx[teami,man]-4;cy:=ply[teami,man]-3;
countallinsi;
play('walk.svs',10000);
if(debug=1)or(inhusi[teami,man]=true)then begin drawmap;if(debug=0)then wait(10);end;
if(inhusi[teami,man]=false)then for a5:=0 to 128 do clear1($a000,a5*320,64);
wait(3);

{inftxt('Debug: Walking.           ',255,2,0);}

pguard;

hinvestigate(teami,man);

end;                                    { No problems }


until(problem>10);           { Repeat until - loop }
end;                                   { WALKROUTE - Procedure }


procedure routecheck(teami,man:byte);   { ROUTECHECK - Procedure }
var a1,wox,woy,f1,f2,a5,x,y,wo,problem:integer;
    nwo:word;
begin
problem:=0;wo:=1;grp:=teami;pln:=man;
if(dist[teami,man]>1)then
x:=plx[teami,man];y:=ply[teami,man];

repeat                        { Repeat until - loop }

{if(problem=0)then begin}
if(mem[visibseg:teami*10000+man*500-500+wo]=0)then dec(y);
if(mem[visibseg:teami*10000+man*500-500+wo]=1)then begin dec(y);inc(x);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=2)then inc(x);
if(mem[visibseg:teami*10000+man*500-500+wo]=3)then begin inc(y);inc(x);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=4)then inc(y);
if(mem[visibseg:teami*10000+man*500-500+wo]=5)then begin inc(y);dec(x);end;
if(mem[visibseg:teami*10000+man*500-500+wo]=6)then dec(x);
if(mem[visibseg:teami*10000+man*500-500+wo]=7)then begin dec(y);dec(x);end;
inc(wo);

for a1:=0 to teams do if(ally[a1]=ally[teami])then
for a5:=1 to warriors do if(a5<>man)and(dead[a1,a5]=false)then
if(plx[a1,a5]=x)and(ply[a1,a5]=y)and(random(100)>25)then problem:=1;
{end;}

until(wo>=dist[teami,man])or(problem=1);           { Repeat until - loop }

if(problem=1)then begin  { NEW ROUTE }

asm mov ax,0101h;mov cx,10000;mov es,gfxseg;xor di,di;cld;rep stosw;end;
for wox:=1 to mapx do for woy:=1 to mapy do if(enter[map[wox,woy]]=true)or
(map[wox,woy]=34)or(map[wox,woy]=35)or(map[wox,woy]=38)or(map[wox,woy]=39)then
mem[gfxseg:wox+woy*128]:=0;

for a1:=0 to teams do if(ally[a1]=ally[teami])then
for a5:=1 to warriors do if(a5<>man)and(dead[a1,a5]=false)then
mem[gfxseg:plx[a1,a5]+ply[a1,a5]*128]:=4; { MARK WARRIORS }

clear(ownseg,16000);for wo:=0 to 15000 do memw[ownseg:wo*2]:=routedist+1;

f1:=friend[teami,man] div warriors;
f2:=friend[teami,man]-f1*warriors;
routestart(ownseg,gfxseg,plx[teami,man],ply[teami,man],plx[f1,f2],ply[f1,f2],routedist);
asm mov nwo,ax;end;
dist[teami,man]:=nwo;

routep[teami,man]:=1;
clear1(visibseg,teami*10000+man*500-500,124);
move_custom(mem[ownseg:50000],mem[visibseg:teami*10000+man*500-500],500);

end;                     { NEW ROUTE }

end;                                   { ROUTECHECK - Procedure }

procedure checkfriend(teami,man:byte);
var alive,f1,f2:integer;
begin

alive:=0;
for f1:=0 to teams do
for f2:=1 to warriors do
if(f1<>teami)and(ally[f1]<>ally[teami])then if(dead[f1,f2]=false)then alive:=1;

if(alive=1)then begin
f1:=friend[teami,man] div warriors;
f2:=friend[teami,man]-f1*warriors;
if(friend[teami,man]=0)or(dead[f1,f2]=true)then begin
repeat
f1:=random(4);
f2:=random(gr[f1])+1;
until(f1<>teami)and(ally[f1]<>ally[teami])and(dead[f1,f2]=false)and(f2<=gr[f1]);
friend[teami,man]:=f1*warriors+f2;
end;                                   { Getting a new friend }
end;
end;

procedure shooting(teami,man:byte);
var u,o,a1:byte;
begin
a1:=0;                 { Is there a shootable warrior in sight? }
for u:=0 to teams do if(u<>teami)and(ally[u]<>ally[teami])then
for o:=1 to gr[u] do
if(visiofsi(plx[teami,man],ply[teami,man],plx[u,o],ply[u,o])=1)and
(secheck(plx[teami,man],ply[teami,man],plx[u,o],ply[u,o],fc[teami,man])=1)and
(visiman(plx[teami,man],ply[teami,man],plx[u,o],ply[u,o],teami)=0)and
(dead[u,o]=false)then a1:=1;

if(a1=1)then begin
repeat
turning(teami,man);
a1:=snearest(teami,man);
t1:=a1 div 20;
t2:=a1-t1*20;
cputemp:=a1;
if(cputemp>0)then begin

huleft:=hucount;                { Shooting }
if(debug=1)then huleft:=5;
if(huleft=1)then debug:=1;
cpushoot(teami,man,t1,t2);
if(huleft=1)then debug:=0;      { Shooting }

{inftxt('Debug: Shooting.          ',255,2,0);}

if(cpush=true)then pguard;end;
cpureload(teami,man);
shootok:=0;
if(invammo[teami,man,rarm[teami,man]]>0)and(lochps[teami,man,3]>0)and(cputemp>0)then shootok:=1;
if(invammo[teami,man,larm[teami,man]]>0)and(lochps[teami,man,4]>0)and(cputemp>0)then shootok:=1;
until(mps[teami,man]<1+round(basmp[teami,man]*cpumpscost*0.01))or(shootok=0);
end;

end;

procedure meleestuff(teami,man:byte);
var v1,quitvar,hitran,hitpla,acha,melt1,melt2,f1,f2,bare,mhand,pay:byte;
    maccu,mdam,trans,tdam,damb:integer;


function rc(xm,ym:byte):boolean;
begin if(round(sqrt(sqr(plx[teami,man]-xm)+sqr(ply[teami,man]-ym)))<2)then rc:=true else rc:=false;end;

begin
bare:=0;
f1:=friend[teami,man] div warriors;
f2:=friend[teami,man]-f1*warriors;

repeat                { Multihacking }

if(rc(plx[f1,f2],ply[f1,f2])=true)and(lochps[teami,man,3]+lochps[teami,man,4]>0)and
(dead[f1,f2]=false)then begin               { If buddy is alive in range }
if(larm[teami,man]+rarm[teami,man]=0)then bare:=1;

if(bare=0)and(rarm[teami,man]=0)then mhand:=larm[teami,man];
if(bare=0)and(larm[teami,man]=0)then mhand:=rarm[teami,man];

if(bare=0)then readwep(invtype[grp,pln,mhand]);
if(bare=0)then pay:=round(mpscost*0.01*basmp[teami,man]);
maccu:=round((melaccu[teami,man]+accuracy)/2);
if(bare=1)then begin pay:=10;maccu:=melaccu[teami,man];end;

melt1:=fc[f1,f2]+4;
if(melt1>7)then dec(melt1,8);
melt2:=secheck(plx[f1,f2],ply[f1,f2],plx[teami,man],ply[teami,man],melt1);
if(melt2=1)then inc(maccu,15);
if(maccu<5)then maccu:=5;if(maccu>99)then maccu:=99;

if(bare=0)then mdam:=ydam+random(xdam)+1;
if(bare=1)then mdam:=random(5)+1;

if(mps[teami,man]>=pay)then begin    { If enough mps }
dec(mps[teami,man],pay);
play('melee.svs',10000);wait(20);

acha:=1+random(99);
if(acha<=maccu)then begin     { We've got a hit }

if(bare=0)then inftxt('CPU attacks with '+wepnam,15,1,0);
if(bare=1)then inftxt('CPU makes his move with the knuckles!',15,1,0);

damb:=random(100)+1;
if(damb>=93)and(damb<=97)then mdam:=round(mdam*1.5);
if(damb>=98)and(damb<=100)then mdam:=round(mdam*2);

countallinsi;
cx:=plx[f1,f2]-4;cy:=ply[f1,f2]-3;
ico:=false;drawmap;effect(16,1);wait(10);
hitran:=random(16)+1;

if(hitran=1)then hitpla:=1;
if(hitran=2)or(hitran=3)or(hitran=4)or(hitran=5)or(hitran=6)then hitpla:=2;
if(hitran=7)or(hitran=8)then hitpla:=3;
if(hitran=9)or(hitran=10)then hitpla:=4;
if(hitran=11)or(hitran=12)or(hitran=13)then hitpla:=5;
if(hitran=14)or(hitran=15)or(hitran=16)then hitpla:=6;


tdam:=mdam-locaps[f1,f2,hitpla];

if(tdam>0)and(f1<>teami)then inc(penet[teami],tdam);

if(tdam<0)then tdam:=0;dec(lochps[f1,f2,hitpla],tdam);
dec(locaps[f1,f2,hitpla],round(mdam/3));if locaps[f1,f2,hitpla]<0 then locaps[f1,f2,hitpla]:=0;
if(lochps[f1,f2,hitpla]<=0)then begin
trans:=-lochps[f1,f2,hitpla];lochps[f1,f2,hitpla]:=0;
if(trans>0)and(hitpla>2)then begin
temp1:=trans-locaps[f1,f2,2];if temp1<0 then temp1:=0;dec(lochps[f1,f2,2],temp1);
if lochps[f1,f2,2]<0 then lochps[f1,f2,2]:=0;
dec(locaps[f1,f2,2],round(trans/3));if locaps[f1,f2,2]<0 then locaps[f1,f2,2]:=0;

end;


if(lochps[f1,f2,1]<=0)or(lochps[f1,f2,2]<=0)then begin
dead[f1,f2]:=true;
if(teami<>f1)then inc(killed[teami]);

for by1:=1 to 15 do if(invtype[f1,f2,1]<>0)then drop(f1,f2,1,false);
countallinsi;
cx:=plx[f1,f2]-4;cy:=ply[f1,f2]-3;
ico:=false;drawmap;play('death.svs',10000);effect(17,1);wait(20);
end;
if(mem[wepseg:(invtype[f1,f2,rarm[f1,f2]]-1)*59+32]=1)and(lochps[f1,f2,3]=0)and
(invtype[f1,f2,rarm[f1,f2]]<>0)then begin drop(f1,f2,rarm[f1,f2],false);rarm[f1,f2]:=0;end;
if(mem[wepseg:(invtype[f1,f2,larm[f1,f2]]-1)*59+32]=1)and(lochps[f1,f2,4]=0)and
(invtype[f1,f2,larm[f1,f2]]<>0)then begin drop(f1,f2,larm[f1,f2],false);larm[f1,f2]:=0;end;

if((mem[wepseg:(invtype[f1,f2,rarm[f1,f2]]-1)*59+32]=2))and(invtype[f1,f2,rarm[f1,f2]]<>0)then
if(lochps[f1,f2,3]=0)or(lochps[f1,f2,4]=0)then begin drop(f1,f2,rarm[f1,f2],false);rarm[f1,f2]:=0;larm[f1,f2]:=0;end;

end;

end;                          { We've got a hit }

{inftxt('Debug: Melee.          ',255,2,0);}

pguard;      { regardless of hit or miss }
end;                                 { If enough mps }

end;                                        { If buddy is alive in range }

quitvar:=0;
if(mps[teami,man]<pay)then quitvar:=1;
if(dead[f1,f2]=true)then quitvar:=1;
if(dead[teami,man]=true)then quitvar:=1;
if(lochps[teami,man,3]+lochps[teami,man,4]=0)then quitvar:=1;
if(rc(plx[f1,f2],ply[f1,f2])=false)then quitvar:=1;
until(quitvar=1);     { Multihacking }

inftxt(cle,15,1,0);
for v1:=0 to 128 do clear1($a000,v1*320,64);

end;     { End of Meleestuff-procedure }


procedure bombing(teami,man:byte);   { Here begins bombing }
var tx,ty,pricost,finx,finy,bestcount,cucount,i1,inum,cha,eninra,eninsi,gp1,m1:byte;
    damax:word;borange:real;
    enx,eny:array[1..60] of byte;

begin
eninsi:=0;
for gp1:=0 to teams do if(ally[teami]<>ally[gp1])then
for m1:=1 to warriors do if(dead[gp1,m1]=false)and { All live enemies }
{ CHECK FOR: SECTOR, LOS, LOM, RANGE, LIGHT }
(secheck(plx[teami,man],ply[teami,man],plx[gp1,m1],ply[gp1,m1],fc[teami,man])=1)and
(visiofsi(plx[teami,man],ply[teami,man],plx[gp1,m1],ply[gp1,m1])=1)and
(visiman(plx[teami,man],ply[teami,man],plx[gp1,m1],ply[gp1,m1],teami)=0)and
(crange(plx[teami,man],ply[teami,man],plx[gp1,m1],ply[gp1,m1])<=15)and
(crange(plx[teami,man],ply[teami,man],plx[gp1,m1],
ply[gp1,m1])*(11-lightmap[plx[gp1,m1],ply[gp1,m1]])+
((11-lightmap[plx[gp1,m1],ply[gp1,m1]])*5)<90)then begin
inc(eninsi);enx[eninsi]:=plx[gp1,m1];eny[eninsi]:=ply[gp1,m1];
end;

if(eninsi>0)then begin         { Anyone insight? }

damax:=0;inum:=0;
for i1:=1 to 15 do if(mem[wepseg:((invtype[teami,man,i1])-1)*59+1]=4)then begin
readwep(invtype[teami,man,i1]);
if(damax<((xdam div 2)+ydam))then begin damax:=ydam+(xdam div 2);inum:=i1;
pricost:=((mpscost*basmp[teami,man])div 100)+15;
borange:=exprad/2;end;
end;

bestcount:=0;
if(eninsi>1)then begin
for gp1:=1 to eninsi do begin
cucount:=0;
for m1:=1 to eninsi do if(m1<>gp1)then if
((crange(enx[gp1],eny[gp1],enx[m1],eny[m1])<=borange))then inc(cucount);
if(cucount>bestcount)then begin bestcount:=cucount;finx:=enx[gp1];finy:=eny[gp1];end;
end;

end else begin finx:=enx[eninsi];finy:=eny[eninsi];end;


cha:=1+random(100);
if(mps[teami,man]>=pricost)and(inum>0)then begin dec(mps[teami,man],pricost);
if((bestcount=1)and(cha>80))or((bestcount=2)and(cha>20))or((bestcount>2))then begin
play('throw.svs',10000);wait(40);
invprime[teami,man,inum]:=1;
tx:=plx[teami,man];ty:=ply[teami,man];      { Teleporting to site }
plx[teami,man]:=finx;ply[teami,man]:=finy;
drop(teami,man,inum,false);
plx[teami,man]:=tx;ply[teami,man]:=ty;      { Teleporting back }
end;
end;

end;                           { Anyone in sight? }

end;         { End of bombing }


{ END of PROCEDURES of CPUTURN }

begin          { Beginning of the CPUturn }
for wo:=0 to 127 do clear1($a000,wo*320,64);

{ Insit p„„lle, Drawable ja Inhusi m„„r„„v„t keit„ piirret„„n }
for a1:=0 to teams do if(control[a1]>1)then drawable[a1]:=1 else drawable[a1]:=0;
for a1:=0 to teams do for wo:=1 to gr[a1] do if(control[a1]>0)then insi[a1,wo]:=true;
countallinsi;
{ Insit p„„lle, Drawable ja Inhusi m„„r„„v„t keit„ piirret„„n }

{ Main playerloop }
for allw:=1 to gr[teami] do if(dead[teami,allw]=false)then begin

meleeaiding(teami,allw);
hinvestigate(teami,allw);

asm mov ax,0101h;mov cx,10000;mov es,gfxseg;xor di,di;cld;rep stosw;end;
for wox:=1 to mapx do for woy:=1 to mapy do if(enter[map[wox,woy]]=true)or
(map[wox,woy]=34)or(map[wox,woy]=35)or(map[wox,woy]=38)or(map[wox,woy]=39)then
mem[gfxseg:wox+woy*128]:=0;
clear(ownseg,16000);for wo:=0 to 15000 do memw[ownseg:wo*2]:=routedist+1;

if(control[teami]=2)then s:='Here goes nothing ... ';
if(control[teami]=3)then s:='Searching, seeking ... ';
if(control[teami]=4)then s:='Kicking ass right now ... ';
if(control[teami]=5)then s:='COMING THROUGH ... ';
if(allw mod 4=0)then s:=s+'|';
if(allw mod 4=1)then s:=s+'/';
if(allw mod 4=2)then s:=s+'-';
if(allw mod 4=3)then s:=s+'\';
inftxt(s,255,1,0);

checkfriend(teami,allw);

f1:=friend[teami,allw] div warriors;
f2:=friend[teami,allw]-f1*warriors;

if(aidelay[teami,allw]>0)and(aipatrol[teami,allw]=1)then begin
  routestart(ownseg,gfxseg,plx[teami,allw],ply[teami,allw],
  aipatrolx[teami,allw],aipatroly[teami,allw],routedist);
  asm mov nwo,ax;end;dist[teami,allw]:=nwo;
  routep[teami,allw]:=1;
  clear1(visibseg,teami*10000+allw*500-500,124);
  move_custom(mem[ownseg:50000],mem[visibseg:teami*10000+allw*500-500],500);
  routecheck(teami,allw);
  end;

if(aidelay[teami,allw]<=0)then begin
  routestart(ownseg,gfxseg,plx[teami,allw],ply[teami,allw],plx[f1,f2],ply[f1,f2],routedist);
  asm mov nwo,ax;end;dist[teami,allw]:=nwo;

  routep[teami,allw]:=1;
  clear1(visibseg,teami*10000+allw*500-500,124);
  move_custom(mem[ownseg:50000],mem[visibseg:teami*10000+allw*500-500],500);
  routecheck(teami,allw);
  aidelay[teami,allw]:=psidelay[control[teami]];
  aipatrol[teami,allw]:=0;
end else dec(aidelay[teami,allw]);

assign(af1,'gamedata\tgfx.dat');reset(af1);le1:=filesize(af1);close(af1);
assign(f,'gamedata\tgfx.dat');reset(f,le1);blockread(f,mem[gfxseg:0],1);close(f);

if(dist[teami,allw]<routedist)then walkroute(teami,allw);{ Moving }

if(dead[teami,allw]=false)then lookcond(teami,allw);
if(dead[teami,allw]=false)then countvisi(teami,allw); { Calc. (foes) in LOS }
if(foes[allw]=0)and(dead[teami,allw]=false)then begin firstaiding(teami,allw);loadhands(teami,allw);countallinsi;end;
if(dead[teami,allw]=false)then begin bombing(teami,allw);countallinsi;end;
if(dead[teami,allw]=false)and(mode[teami,allw]=0)then begin shooting(teami,allw);cpureload(teami,allw);countallinsi;end;
if(dead[teami,allw]=false)and(mode[teami,allw]=1)then begin meleestuff(teami,allw);countallinsi;end;

end;
{ Main playerloop }

inftxt(cle,15,1,0);
for wo:=0 to 127 do clear1($a000,wo*320,64);
for a1:=0 to teams do for wo:=1 to warriors do inhusi[a1,wo]:=true;
for a1:=0 to teams do for wo:=1 to warriors do insi[a1,wo]:=true;
for a1:=0 to teams do drawable[a1]:=1;
end;       { ************* End of the CPUturn ************* }


procedure chturn;
var newone,ftime,allwiped,byte1,endgroup,bi,yc,a1,a2,i1,c1,yda,xda,efa,era,del:byte;wo1,wo3,oldteam:word;

procedure checkexplosives;       { Checkexplosives }
var a1,i1:byte;
begin
for a1:=0 to teams do for i1:=1 to gr[a1] do begin c1:=1;
repeat
if(invprime[a1,i1,c1]<>0)then begin dec(invprime[a1,i1,c1]);
if(invprime[a1,i1,c1]<1)then begin
xda:=mem[wepseg:(invtype[a1,i1,c1]-1)*59+26];yda:=mem[wepseg:(invtype[a1,i1,c1]-1)*59+27];
efa:=mem[wepseg:(invtype[a1,i1,c1]-1)*59+28];era:=mem[wepseg:(invtype[a1,i1,c1]-1)*59+29];

exgrp:=a1;expln:=i1;

drop(a1,i1,c1,true);explosion(plx[a1,i1],ply[a1,i1],era,yda+random(xda),efa);dec(c1);end;
end;inc(c1);
until(c1>15);end;

if(dritem>0)then begin wo3:=0;             { If items on the ground }
repeat inc(wo3);
if(itemp[wo3]<>0)then begin
dec(itemp[wo3],1);
if(itemp[wo3]<1)and(mem[wepseg:(itemt[wo3]-1)*59+1]=4)then begin
xda:=mem[wepseg:(itemt[wo3]-1)*59+26];yda:=mem[wepseg:(itemt[wo3]-1)*59+27];
efa:=mem[wepseg:(itemt[wo3]-1)*59+28];era:=mem[wepseg:(itemt[wo3]-1)*59+29];

exgrp:=0;expln:=itemex[wo3];
if(itemex[wo3]>warriors)then begin exgrp:=1;expln:=itemex[wo3]-warriors;end;
if(itemex[wo3]>(2*warriors))then begin exgrp:=2;expln:=itemex[wo3]-(2*warriors);end;
if(itemex[wo3]>(3*warriors))then begin exgrp:=3;expln:=itemex[wo3]-(3*warriors);end;

explosion(itemx[wo3],itemy[wo3],era,yda+random(xda),efa);

for c3:=wo3 to dritem+1 do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itema[c3]:=itema[c3+1];itemt[c3]:=itemt[c3+1];itemp[c3]:=itemp[c3+1];
itemhide[c3]:=itemhide[c3+1];end;
dec(dritem);dec(wo3);
end;end;
until(wo3>=dritem);
end;                                       { If items on the ground }
if(control[grp]>1)then for a1:=0 to 128 do clear1($a000,a1*320,64);

end;                             { Checkexplosives }

begin
ftime:=0;if(turn=0)then ftime:=1;
if(control[grp]=1)and(turn>0)then begin      { Not in the beginning }
pntr:=false;oldteam:=grp;tch:=false;
menufill(mline);mline:=1;
broken:=0;
fastfont('                     ',14,162,tcolo,bcolo,$a000,0,0);
fastfont('                            ',14,180,tcolo,bcolo,$a000,0,0);
end;                                         { Not in the beginning }

if(turn>0)then begin             { No idea to do this in the begining }
li1:=0;
for a:=1 to gr[grp] do inc(li1,mps[grp,a]);
li2:=grpmps[grp]-li1;
inc(mpsused[grp],li2);

checkexplosives;

for i:=1 to warriors do   {Clear wseen}
for tm:=0 to teams do begin
for wo:=1 to warriors do
for a1:=1 to 3 do wseen_p^[grp,i,tm,wo,a1]:=-10;
enseen[grp,i]:=0;
reported[grp,i]:=0;
end;

{ Bleeding }
for bi:=1 to gr[grp] do if(dead[grp,bi]=false)then begin wo:=0;for a:=1 to 6 do inc(wo,lochps[grp,bi,a]);
bleed[grp,bi]:=tothps[grp,bi]-wo-bleeded[grp,bi];
bleed[grp,bi]:=round(bleed[grp,bi]/tothps[grp,bi]*bleedc*hfactor(grp,bi));
if(bleed[grp,bi]<0)then bleed[grp,bi]:=0;
inc(dbleed[grp],bleed[grp,bi]);
dec(lochps[grp,bi,2],bleed[grp,bi]);
inc(bleeded[grp,bi],bleed[grp,bi]);

if(bleed[grp,bi]>0)and(control[grp]=1)then begin
cx:=plx[grp,bi]-4;cy:=ply[grp,bi]-3;
drawmap;
s:=plname[grp,bi];
s:=s+'               ';
inftxt(s,4,1,0);
s:='suffers ';
str(bleed[grp,bi],s1);
s:=s+s1+' pts from bleeding... ';
if(bleed[grp,bi]<10)then s:=s+' ';
inftxt(s,4,2,0);
waitkey;
end;
if(lochps[grp,bi,2]<1)then begin
dead[grp,bi]:=true;for by1:=1 to 15 do if(invtype[grp,bi,1]<>0)then drop(grp,bi,1,false);
if(control[grp]=1)then begin
s:=plname[grp,bi];
s:=s+'               ';
inftxt(s,4,1,0);
inftxt('bleeds to death !!!             ',4,2,0);
drawmap;
waitkey;
end;
end;end;
{ Bleeding }
inftxt(cle,0,1,0);
inftxt(cle,0,2,0);
end;                             { No idea to do this in the begining }

for a1:=0 to teams do begin wiped[a1]:=1;
for i1:=1 to warriors do if(dead[a1,i1]=false)then wiped[a1]:=0;end;
allwiped:=1;i1:=0;
for a1:=0 to teams do if(wiped[a1]=0)then inc(i1);
if(i1>=2)then allwiped:=0;

if(control[grp]=1)and(turn>0)and(allwiped<>1)then begin

del:=0;
for i:=0 to 63 do begin
for c:=0 to 256 do mem[$a000:320+i*640+c]:=0;
inc(del);
if del=4 then begin del:=0;wait(1);end;
end;
del:=0;
for i:=63 downto 0 do begin for c:=0 to 256 do mem[$a000:i*640+c]:=0;
inc(del);
if del=4 then begin del:=0;wait(1);end;
end;
play('endturn.svs',10000);

loadpic('gfx\score.svf');
str(killed[0],s);if(killed[0]<10)then insert(' ',s,1);fastfont(s,18,94,132,sco,ownseg,0,1);
str(killed[1],s);if(killed[1]<10)then insert(' ',s,1);fastfont(s,55,94,132,sco,ownseg,0,1);
str(killed[2],s);if(killed[2]<10)then insert(' ',s,1);fastfont(s,95,94,132,sco,ownseg,0,1);
str(killed[3],s);if(killed[3]<10)then insert(' ',s,1);fastfont(s,143,94,132,sco,ownseg,0,1);

for i:=1 to 29 do begin
yc:=0;
for a:=115-(i shl 2) to 115 do begin inc(yc);
wipe(ownseg,$a000,(640+((a shl 8)+(a shl 6))),(38+((yc shl 8)+(yc shl 6))),46);
end;
wait(1);end;
end;

if(broken=1)then calclights;
dell;

for a1:=0 to teams do begin wiped[a1]:=1;    { Get a new team and player }
for i1:=1 to warriors do if(dead[a1,i1]=false)then wiped[a1]:=0;end;
allwiped:=1;i1:=0;
{for a1:=0 to teams do if(wiped[a1]=0)then inc(i1);if(i1>=2)then allwiped:=0;}
for a1:=0 to teams do if(wiped[a1]=0)then a2:=a1;
for a1:=0 to teams do if(wiped[a1]=0)and(ally[a1]<>ally[a2])then allwiped:=0;

if(allwiped=0)then begin           { Atleast 2 groups left }
newone:=0;

repeat                                  { Goes to the next available group }
if(grp=teams)then inc(turn);
if(newone>0)then checkexplosives else newone:=1;
if(grp<teams)then inc(grp) else grp:=0;
until(wiped[grp]=0)and(control[grp]>0); { Goes to the next available group }

for i:=1 to gr[grp] do begin
mps[grp,i]:=basmp[grp,i];
reported[grp,i]:=0;
end;
visimode:=true;

pln:=0;                                 { Goes to the next available man }
repeat
inc(pln);
until(dead[grp,pln]=false);             { Goes to the next available man }

if(control[grp]>1)then begin            { Go to CPUTURN begins }
if(grp=0)then begin setpal(255,0,0,63);mancol:=1;inftxt('It''s blue computer''s turn.      ',255,1,0);end;
if(grp=1)then begin setpal(255,63,0,0);mancol:=2;inftxt('It''s red computer''s turn.       ',255,1,0);end;
if(grp=2)then begin setpal(255,0,63,0);mancol:=3;inftxt('It''s green computer''s turn.     ',255,1,0);end;
if(grp=3)then begin setpal(255,63,63,0);mancol:=14;inftxt('It''s yellow computer''s turn.    ',255,1,0);end;
inftxt('Press enter to continue.        ',255,2,0);
fastfont('                ',11,162,22,bcolo,$a000,0,0);
fastfont('                          ',11,180,22,bcolo,$a000,0,0);
fastfont('   ',276,24,22,bcolo,$a000,0,0);
fastfont('   ',276,53,22,bcolo,$a000,0,0);
{repeat ch:=readk;until ch=#28;}
inftxt('                                ',255,1,0);
inftxt('                                ',255,2,0);

cputurn(grp);
end;                                    { Go to CPUTURN ends }

end;                               { Atleast 2 groups left }

for a1:=0 to teams do begin wiped[a1]:=1;
for i1:=1 to warriors do if(dead[a1,i1]=false)then wiped[a1]:=0;end;
lop:=true;i1:=0;
{for a1:=0 to teams do if(wiped[a1]=0)then inc(i1);if(i1>=2)then lop:=false;}
for a1:=0 to teams do if(wiped[a1]=0)then a2:=a1;
for a1:=0 to teams do if(wiped[a1]=0)and(ally[a1]<>ally[a2])then lop:=false;

if(lop=false)and(control[grp]=1)then begin    { If atleast 2 groups left }

if(ftime<>1)then begin loadpic('gfx\score.svf');
str(killed[0],s);if(killed[0]<10)then insert(' ',s,1);fastfont(s,18,94,132,sco,ownseg,0,1);
str(killed[1],s);if(killed[1]<10)then insert(' ',s,1);fastfont(s,55,94,132,sco,ownseg,0,1);
str(killed[2],s);if(killed[2]<10)then insert(' ',s,1);fastfont(s,95,94,132,sco,ownseg,0,1);
str(killed[3],s);if(killed[3]<10)then insert(' ',s,1);fastfont(s,143,94,132,sco,ownseg,0,1);
for a:=0 to 115 do wipe(ownseg,$a000,(640+(a shl 8)+(a shl 6)),(((a shl 8)+(a shl 6))-602),46);
end;

if grp=0 then begin setpal(255,0,0,63);mancol:=1;end;
if grp=1 then begin setpal(255,63,0,0);mancol:=2;end;
if grp=2 then begin setpal(255,0,63,0);mancol:=3;end;
if grp=3 then begin setpal(255,63,63,0);mancol:=14;end;
if grp=0 then inftxt('It''s your turn, blue.           ',255,1,0);
if grp=1 then inftxt('It''s your turn, red.            ',255,1,0);
if grp=2 then inftxt('It''s your turn, green.          ',255,1,0);
if grp=3 then inftxt('It''s your turn, yellow.         ',255,1,0);

inftxt('Press enter to proceed.         ',255,2,0);
fastfont('                ',11,162,22,bcolo,$a000,0,0);
fastfont('                          ',11,180,22,bcolo,$a000,0,0);
fastfont('   ',276,24,22,bcolo,$a000,0,0);fastfont('   ',276,53,22,bcolo,$a000,0,0);
repeat ch:=readk;until ch=#28;

if(ftime<>1)then begin
for i:=29 downto 1 do begin yc:=0;
for a:=119-(i shl 2) to 119 do begin inc(yc);
wipe(ownseg,$a000,(640+((a shl 8)+(a shl 6))),(38+((yc shl 8)+(yc shl 6))),46);
end;
wait(1);end;
end;

play('go.svs',10000);inftxt(cle,0,1,0);inftxt(cle,0,2,0);menufill(mline);

if(lop=false)then begin
cx:=plx[grp,pln]-4;cy:=ply[grp,pln]-3;see;calcvisiall;scree:=true;drawmap;

del:=0;
for i:=63 downto 0 do begin move_custom(mem[ownseg:8137+i*580],mem[$a000:i*640],256);
inc(del);
if del=4 then begin del:=0;wait(1);end;
end;
del:=0;
for i:=0 to 63 do begin move_custom(mem[ownseg:290+8137+i*580],mem[$a000:320+i*640],256);
inc(del);
if del=4 then begin del:=0;wait(1);end;
end;
end;tch:=true;pntr:=true;
end;                                           { If atleast 2 groups left }

grpmps[grp]:=0;
for a:=1 to gr[grp] do inc(grpmps[grp],basmp[grp,a]);
end;

procedure cpushoot(teami,man,tgrp,tman:byte);
const autorate:array[2..5]of byte=(20,40,70,85);
var double,handok,osuma,misc,ent,newp,loppu,nosh:boolean;
    svis1,svis2,koh,sx,sy,range,shman,shgrp,nx,ny,cguy,totguy:byte;
    armhp,chohi:integer;
    tgx,tgy:shortint;

procedure hit(lopx,lopy:byte);  { Hit }
var tdam,dam,trans,hitran,hitpla,hpla,dg,dn,buc:integer;mandead:boolean;
    la,damb:byte;
begin
pntr:=false;
mandead:=false;trans:=0;dam:=0;
if(weaptype=1)then begin dam:=ydam+random(xdam);if(xdam>0)then inc(dam);end;
if(weaptype=2)then begin for buc:=1 to burs do inc(dam,(ydam+random(xdam)));
if(xdam>0)then inc(dam,1);
end;
for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=lopx)and(ply[a,i]=lopy)then
if(dead[a,i]=false)and(ent=false)then begin dg:=a;dn:=i;mandead:=true;end;
if(mandead=true)then begin
if(debug=0)then begin play('hurt.svs',10000);wait(7);end;

if(debug=1)then begin
cx:=lopx-4;cy:=lopy-3;ico:=false;pntr:=false;drawmap;effect(16,1);
end;
{ Ex disabled line above !! }

begin hitran:=random(16)+1;koh:=19;

damb:=random(100)+1;
if(damb>=97)and(damb<=99)and(mandead=true)then
begin
dam:=round(dam*1.5);
{inftxt('A severe hit. 150% damage !     ',2,1,0);
repeat ch:=readk;until ch=#28;}
end;
if (damb=100)and(mandead=true)then
begin
dam:=round(dam*2);
{inftxt('A critical hit. 200% damage !   ',2,1,0);
repeat ch:=readk;until ch=#28;}
end;

{if(guard=false)then inftxt('You hit him to the              ',15,1,0) else
begin inftxt('Hit to the                      ',15,1,0);koh:=11;end;
}
if aim=true then hitran:=aimpla;
if(hitran=1)then begin hitpla:=1;{inftxt('head.',15,1,koh);}end;
if(hitran=2)or(hitran=3)or(hitran=4)or(hitran=5)or(hitran=6)then begin hitpla:=2;{inftxt('chest.',15,1,koh);}end;
if(hitran=7)or(hitran=8)then begin hitpla:=3;{inftxt('right arm.',15,1,koh);}end;
if(hitran=9)or(hitran=10)then begin hitpla:=4;{inftxt('left arm.',15,1,koh);}end;
if(hitran=11)or(hitran=12)or(hitran=13)then begin hitpla:=5;{inftxt('right leg.',15,1,koh);}end;
if(hitran=14)or(hitran=15)or(hitran=16)then begin hitpla:=6;{inftxt('left leg.',15,1,koh);}end;

{str(dam,s);inftxt('Damage caused :                 ',15,2,0);inftxt(s,15,2,17);repeat ch:=readk;until ch=#28;}

tdam:=dam-locaps[dg,dn,hitpla];if tdam>0 then begin
if(guard=false)and(dg<>grp)then inc(penet[grp],tdam);
if(guard=true)and(dg<>guardgrp)then inc(penet[guardgrp],tdam);
{inftxt(cle,0,2,0);str(tdam,s);inftxt('   points of damage penetrated  ',2,1,0);inftxt(s,2,1,0);
repeat ch:=readk;until ch=#28;}end;

if tdam<0 then tdam:=0;dec(lochps[dg,dn,hitpla],tdam);
dec(locaps[dg,dn,hitpla],round(dam/5));if locaps[dg,dn,hitpla]<0 then locaps[dg,dn,hitpla]:=0;
if lochps[dg,dn,hitpla]<0 then begin trans:=-lochps[dg,dn,hitpla];lochps[dg,dn,hitpla]:=0;
if(trans>0)and(hitpla<>1)and(hitpla<>2)then begin
temp1:=trans-locaps[dg,dn,2];if temp1<0 then temp1:=0;dec(lochps[dg,dn,2],temp1);
if lochps[dg,dn,2]<0 then lochps[dg,dn,2]:=0;
dec(locaps[dg,dn,2],round(trans/5));if locaps[dg,dn,2]<0 then locaps[dg,dn,2]:=0;
{str(trans,s);inftxt('Damage transfered to chest :    ',2,1,0);inftxt(s,2,1,29);}
{if temp1>0 then begin str(temp1,s);inftxt('   points of damage penetrated  ',2,2,0);inftxt(s,2,2,0);end;
repeat ch:=readk;until ch=#28;}end;end;
if(lochps[dg,dn,1]<=0)or(lochps[dg,dn,2]<=0)then
begin dead[dg,dn]:=true;
if(guard=false)and(dg<>grp)then inc(killed[grp]);
if(guard=true)and(dg<>guardgrp)then inc(killed[guardgrp]);
end;

if(guard=false)and(ally[dg]<>ally[grp])then begin inc(xpgain[exgrp,expln],dam*2);inc(dcaused[exgrp],dam);end;
if(guard=true)and(ally[dg]<>ally[guardgrp])then begin inc(xpgain[exgrp,expln],dam*2);inc(dcaused[exgrp],dam);end;

if(mem[wepseg:(invtype[dg,dn,rarm[dg,dn]]-1)*59+32]<>2)and(lochps[dg,dn,3]=0)and
(invtype[dg,dn,rarm[dg,dn]]<>0)then begin drop(dg,dn,rarm[dg,dn],false);rarm[dg,dn]:=0;end;
if(mem[wepseg:(invtype[dg,dn,larm[dg,dn]]-1)*59+32]<>2)and(lochps[dg,dn,4]=0)and
(invtype[dg,dn,larm[dg,dn]]<>0)then begin drop(dg,dn,larm[dg,dn],false);larm[dg,dn]:=0;end;

if((mem[wepseg:(invtype[dg,dn,rarm[dg,dn]]-1)*59+32]=2))and(invtype[dg,dn,rarm[dg,dn]]<>0)then
if(lochps[dg,dn,3]=0)or(lochps[dg,dn,4]=0)then begin drop(dg,dn,rarm[dg,dn],false);rarm[dg,dn]:=0;larm[dg,dn]:=0;end;

end;
if(debug=1)then begin pntr:=false;drawmap;end;
if(dead[dg,dn]=true)then begin for by1:=1 to 15 do if(invtype[dg,dn,1]<>0)then drop(dg,dn,1,false);
play('death.svs',10000);wait(20);if(debug=1)then effect(17,1);end;
{inftxt(cle,0,1,0);inftxt(cle,0,2,0);}
end;

if(mandead=false)then begin {ico:=false;cx:=lopx-4;cy:=lopy-3;pntr:=false;drawmap;
if(weaptype=1)then effect(239,2) else effect(96,1);}

if(map[lopx,lopy]=1)then map[lopx,lopy]:=65;
if(map[lopx,lopy]=2)then map[lopx,lopy]:=66;
if(map[lopx,lopy]=3)then map[lopx,lopy]:=67;
if(map[lopx,lopy]=4)then map[lopx,lopy]:=68;
if(map[lopx,lopy]=42)then begin map[lopx,lopy]:=65;explosion(lopx,lopy,5,27+random(14),5);dell;end;
if(map[lopx,lopy]=43)then begin map[lopx,lopy]:=65;explosion(lopx,lopy,6,42+random(14),5);dell;end;
pntr:=true;

if(dam>=walldam)and(map[lopx,lopy]>=5)and(map[lopx,lopy]<=17)then begin map[lopx,lopy]:=69;broken:=1;end;
if(dam>=round(walldam*1.5))and(map[lopx,lopy]>=18)and(map[lopx,lopy]<=22)then begin map[lopx,lopy]:=69;broken:=1;end;
if(dam>=walldam*2)and(map[lopx,lopy]=23)then begin map[lopx,lopy]:=69;broken:=1;end;
if(dam>=round(walldam*1.5))and(map[lopx,lopy]>=24)and(map[lopx,lopy]<=27)then begin map[lopx,lopy]:=69;broken:=1;end;
if(dam>=walldam)and(map[lopx,lopy]>=28)and(map[lopx,lopy]<=33)then begin map[lopx,lopy]:=69;broken:=1;end;

if(dam>=doordam)and(map[lopx,lopy]>=34)and(map[lopx,lopy]<=35)then begin map[lopx,lopy]:=70;checkbomb(lopx,lopy);broken:=1;end;
if(dam>=doordam)and(map[lopx,lopy]>=36)and(map[lopx,lopy]<=37)then map[lopx,lopy]:=71;
if(dam>=doordam)and(map[lopx,lopy]>=38)and(map[lopx,lopy]<=39)then begin map[lopx,lopy]:=70;checkbomb(lopx,lopy);broken:=1;end;
if(dam>=doordam)and(map[lopx,lopy]>=40)and(map[lopx,lopy]<=41)then map[lopx,lopy]:=71;

if(map[lopx,lopy]=42)or(map[lopx,lopy]=43)then map[lopx,lopy]:=65;
if(map[lopx,lopy]=44)then begin map[lopx,lopy]:=75;broken:=1;end;
if(map[lopx,lopy]=45)then map[lopx,lopy]:=76;

if(map[lopx,lopy]>=46)and(map[lopx,lopy]<=54)then map[lopx,lopy]:=79;
if(map[lopx,lopy]=55)then map[lopx,lopy]:=74;
if(map[lopx,lopy]=56)then map[lopx,lopy]:=72;
if(map[lopx,lopy]=57)or(map[lopx,lopy]=58)then map[lopx,lopy]:=73;
if(map[lopx,lopy]=59)or(map[lopx,lopy]=60)then map[lopx,lopy]:=78;
if(map[lopx,lopy]>=61)and(map[lopx,lopy]<=64)then map[lopx,lopy]:=77;

end;
{pntr:=false;drawmap;}wait(3);end;    { END OF CPUHIT }

begin       { CPUSHOOT }
exgrp:=teami;expln:=man;
shman:=man;shgrp:=teami;
grp:=teami;pln:=man;
armhp:=0;hitbon:=0;shable:=false;shooted:=false;cpush:=false;handok:=true;vali:=false;

if(guard=false)then begin { No this stuff if coming from Guard-proc }

if(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]>2)and
(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]>2)and
(vali=false)and(handok=true)and(invammo[grp,pln,islo]<1)then begin
handok:=false;vali:=true;end; { No weapons }

if(vali=false)and(lochps[grp,pln,3]<1)and(lochps[grp,pln,4]<1) then begin
shooted:=false;handok:=false;vali:=true;end; { Both hands Damaged }

if(lochps[grp,pln,3]>0)and { Rightarm OK }
(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]<=2)and
(invtype[grp,pln,rarm[grp,pln]]>0)and(invtype[grp,pln,rarm[grp,pln]]<=100)then begin
handc:=invtype[grp,pln,rarm[grp,pln]];shable:=true;islo:=rarm[grp,pln];armhp:=lochps[grp,pln,3];end;

if(lochps[grp,pln,4]>0)and { Leftarm OK }
(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]<=2)and
(invtype[grp,pln,larm[grp,pln]]>0)and(invtype[grp,pln,larm[grp,pln]]<=100)then begin
handc:=invtype[grp,pln,larm[grp,pln]];shable:=true;islo:=larm[grp,pln];armhp:=lochps[grp,pln,4];end;

if(handok=true)and(vali=false)and(rarm[grp,pln]=larm[grp,pln])then
if(lochps[grp,pln,3]=0)or(lochps[grp,pln,4]=0)then begin
handok:=false;vali:=true;end; {Too much damage for 2 handed weapon }

if(vali=false)and(handok=true)then
if(rarm[grp,pln]=0)and(larm[grp,pln]=0)or
(invtype[grp,pln,rarm[grp,pln]]>100)and(invtype[grp,pln,larm[grp,pln]]>100)
or((mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]>2)and
(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]>2))then begin
handok:=false;shable:=true;vali:=true;end; { No weapons }

if(rarm[grp,pln]=larm[grp,pln])and(lochps[grp,pln,3]>0)and(lochps[grp,pln,4]>0)and
(invtype[grp,pln,rarm[grp,pln]]>0)and(invtype[grp,pln,rarm[grp,pln]]<=100)and
(invtype[grp,pln,larm[grp,pln]]>0)and(invtype[grp,pln,larm[grp,pln]]<=100)then begin
if(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+32]=1)then hitbon:=15;
handc:=invtype[grp,pln,rarm[grp,pln]];shable:=true;islo:=rarm[grp,pln];end; { 2 handed weapon }

if(shable=false)then handok:=false;

readwep(handc);  { Get weapon data }

cpumpscost:=mpscost;

if(vali=false)then if
(lochps[grp,pln,3]<1)and(invtype[grp,pln,larm[grp,pln]]>100)or
(lochps[grp,pln,3]<1)and(invtype[grp,pln,larm[grp,pln]]=0)or
(lochps[grp,pln,4]<1)and(invtype[grp,pln,rarm[grp,pln]]>100)or
(lochps[grp,pln,4]<1)and(invtype[grp,pln,rarm[grp,pln]]=0)then begin
handok:=false;vali:=true;
end;

if(invammo[grp,pln,islo]<1)and(invtype[grp,pln,islo]<=100)and
(mem[wepseg:(invtype[grp,pln,islo]-1)*59+1]<=2)and
(handok=true)and(vali=false)then
begin handok:=false;end;     { Out of ammo dude }

if(mps[grp,pln]<round(basmp[grp,pln]*mpscost*0.01))then handok:=false; { Enough mps? }

end; { No this stuff if coming from Guard-proc }

if(handok=true)then begin
sx:=plx[grp,pln];sy:=ply[grp,pln];
ix:=plx[tgrp,tman];iy:=ply[tgrp,tman];

if(guard=true)then begin   { If coming from proc-Guard }
lioma:=true;sx:=plx[teami,man];sy:=ply[teami,man];
end;                       { If coming from proc-Guard }

shooted:=false;if(guard=false)then begin rapid:=false;rafi:=1;end;
nosh:=false;sect:=true;chohi:=50;ent:=false;
pntr:=false;loppu:=false;

if(guard=false)then begin  { If not coming from proc-Guard }

{ Autofire Check }
if(mpscosta<>0)then begin
rare1:=(mpscost*0.01)*basmp[teami,man];
rare2:=mpscosta*0.01*basmp[teami,man];
maxfi:=round((mps[teami,man]-rare1)/rare2);
if(maxfi>invammo[teami,man,islo])then maxfi:=invammo[teami,man,islo];
rafi:=round(maxfi-((100-autorate[control[teami]])*maxfi)div 100);
if(rafi>1)then rapid:=true else rapid:=false;
end;
{ Autofire Check }

burs:=1;        { Multifire check }
if(loppu=false)and(mps[grp,pln]>=basmp[grp,pln]*mpscost*0.01)and(burst>1)and
(weaptype=2)and(invammo[grp,pln,islo]>1)then begin
burs:=invammo[grp,pln,islo];
if(burst<=burs)then burs:=burst;
end;            { Multifire check }

end;                       { If not coming from proc-Guard }


if(loppu=false)then begin
range:=round(sqrt(sqr(ix-sx)+sqr(iy-sy)));
re:=(lochps[grp,pln,3]/(tothps[grp,pln]*0.16));

if mem[wepseg:(invtype[grp,pln,islo]-1)*59+32]=1 then
re:=(armhp/(tothps[grp,pln]*0.16)) else
re:=((lochps[grp,pln,3]+lochps[grp,pln,4])/(tothps[grp,pln]*0.32));
if re>1 then re:=1;

if guard=true then begin
if mem[wepseg:(invtype[guardgrp,e,islo]-1)*59+32]=1 then
re:=(garmhp/(tothps[guardgrp,e]*0.16))else
re:=((lochps[guardgrp,e,3]+lochps[guardgrp,e,4])/(tothps[guardgrp,e]*0.32));
if re>1 then re:=1;end;

chohi:=round(((accuracy+firaccu[grp,pln])/2)-((accufact/10)*(range-1)))+hitbon;
if chohi>round((accuracy+firaccu[grp,pln])/2)+hitbon then
chohi:=round((accuracy+firaccu[grp,pln])/2)+hitbon;
if(rapid=true)then dec(chohi,round(accuracy*0.2));
chohi:=round(chohi*re);

dec(chohi,round(crange(sx,sy,ix,iy)*((11-lightmap[ix,iy])div 2)));

if(chohi<5)then chohi:=5;
if(chohi>98)then chohi:=99;
aim:=false;double:=false;

misc:=false;
if(misc=false)then begin

if(rapid=false)then rafi:=1;
for rcn:=1 to rafi do begin
if(guard=false)then if(shman<>pln)or(dead[grp,shman]=true)or(shgrp<>grp)then loppu:=true;
if(guard=true)then if(dead[guardgrp,shman]=true)then loppu:=true;
if(loppu=false)then begin
if(guard=false)then inc(shots[grp]);if(guard=true)then inc(shots[guardgrp]);

if(loppu=false)then if(weaptype=2)then play('energy.svs',9000) else play('shoot.svs',11000);
wait(4);if(weaptype=2)then wait(3);            { To hear sounds }
a:=1+random(99);         { Result of firing }

misc:=false;osuma:=false;   { Did we miss or did we hit }
if(a<=chohi)then osuma:=true else aim:=false;
x1:=sx;y1:=sy;x2:=ix;y2:=iy;pn:=21;gn:=4;
if(rcn=1)then raent:=false;
for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=ix)and(ply[a,i]=iy)and(dead[a,i]=false)then misc:=true;
if(misc=false)and(rcn=1)and(enter[map[ix,iy]]=true)and(guard=false)then raent:=true;
misc:=false;                { Did we miss or did we hit }

{ raent = aiming to floor }

if(osuma=true)and(guard=false)then inc(hits[grp]);
if(osuma=true)and(guard=true)then inc(hits[guardgrp]);

if(osuma=false)then begin      { Missed the target !! }

for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=ix)and(ply[a,i]=iy)and(dead[a,i]=false)then misc:=true;
if(enter[map[ix,iy]]=true)and(misc=false)then begin
a:=round(range/10);if(a>3)then a:=3;
if(rcn=1)then raent:=true;
ent:=true;x2:=x2+random(2*a+1)-a;y2:=y2+random(2*a+1)-a;end;

if(ent=false)and(rapid=false)then begin a:=round(1+(range/10));si:=random(2*a+1)-a;
if abs(x2-x1)<abs(y2-y1) then inc(x2,si) else inc(y2,si);end;
if(raent=false)and(rapid=true)then begin a:=round(1+(range/10));si:=random(2*a+1)-a;
if(raent=false)then ent:=false;
if abs(x2-x1)<abs(y2-y1) then inc(x2,si) else inc(y2,si);end;

for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=ix)and(ply[a,i]=iy)then
begin gn:=a;pn:=i;end; { gn,pn points to the man targeted at the first place }
end;                           { Missed the target !! }

{ Calculating the line of fligth for bullet }
newp:=false;vx:=x1;vy:=y1;
if x1-x2<>0 then yd:=(y2-y1)/(x2-x1) else begin xd:=0;yd:=1;if y1>y2 then yd:=-1;end;
if y1-y2<>0 then xd:=(x2-x1)/(y2-y1) else begin yd:=0;xd:=1;if x1>x2 then xd:=-1;end;
if xd>1 then xd:=1;if yd>1 then yd:=1;if xd<-1 then xd:=-1;if yd<-1 then yd:=-1;
if (x1>x2) and (y1<y2) then yd:=-yd;
if (x1>x2) and (y1>y2) then begin xd:=-xd;yd:=-yd;end;
if (x1<x2) and (y1>y2) then begin xd:=-xd;end;
{ Calculating the line of fligth for bullet }

repeat             { Calculating the final landing site for bullet }
vpx:=px;vpy:=py;vx:=vx+xd;vy:=vy+yd;px:=round(vx);py:=round(vy);

if(ent=true)and(px=x2)and(py=y2)then newp:=true;

if(firable[map[px,py]]=false)then newp:=true;

if(enter[map[px,py]]=false)and(px=x2)and(py=y2)then newp:=true;

for a:=0 to teams do for i:=1 to gr[a] do if(a<>gn)or(i<>pn)then
if(plx[a,i]=px)and(ply[a,i]=py)and(dead[a,i]=false)then newp:=true;

if(raent=true)and(osuma=true)and(px=x2)and(py=y2)then newp:=true;
until newp=true;   { Calculating the final landing site for bullet }

{ What does the bullet accomplish (landing site in [px,py]) }
pntr:=false;ico:=false;
if(weaptype=1)and(exprad>1)and(enter[map[px,py]]=false)then begin px:=vpx;py:=vpy;
shooted:=true;cpush:=true;end;
if(weaptype=1)and(exprad>1)then begin
explosion(px,py,exprad,ydam+random(xdam)+1,expfact);
shooted:=true;cpush:=true;
pntr:=false;
if(control[grp]=1)or(debug=1)then drawmap;
wait(20);
end;
if(weaptype<>1)or(exprad=1)then begin hit(px,py);shooted:=true;cpush:=true;end;
{ What does the bullet accomplish (landing site in [px,py]) }

{ Quit if the shooter is already dead }
if(pln<>shman)and(guard=false)then loppu:=true;
if(dead[guardgrp,shman]=true)and(guard=true)then loppu:=true;
{ Quit if the shooter is already dead }

{ Removing ammos and movement points }
if(pln=shman)and(guard=false)and(rapid=false)then begin
if(double=false)then dec(mps[grp,pln],round(basmp[grp,pln]*mpscost*0.01)) else
dec(mps[grp,pln],2*(round(basmp[grp,pln]*mpscost*0.01)));
if weaptype=1 then dec(invammo[grp,pln,islo],1);
if weaptype=2 then dec(invammo[grp,pln,islo],burs);end;

if(e=shman)and(guard=true)and(rapid=false)then begin
dec(mps[guardgrp,e],round(basmp[guardgrp,e]*mpscost*0.01));
dec(invammo[guardgrp,e,islo],1);cpush:=true;end;

if(guard=false)and(pln=shman)and(rapid=true)and(rcn=1)then begin
dec(mps[grp,pln],round(((rafi-1)*((mpscosta*0.01)*basmp[grp,pln]))+(mpscost*0.01*basmp[grp,pln])));
dec(invammo[grp,pln,islo],rafi);cpush:=true;end;

if(guard=true)and(e=shman)and(rapid=true)and(rcn=1)then begin
dec(mps[guardgrp,e],round(((rafi-1)*((mpscosta*0.01)*basmp[guardgrp,e]))+(mpscost*0.01*basmp[guardgrp,e])));
dec(invammo[guardgrp,e,islo],rafi);cpush:=true;end;
{ Removing ammos and movement points }

{ To be sure that mps>=0 }
if(guard=false)and(mps[grp,pln]<0)then mps[grp,pln]:=0;
if(guard=true)and(mps[guardgrp,e]<0)then mps[guardgrp,e]:=0;

end;end;end;end;   { Some important ends, please do not remove them all }

pntr:=true;cnt;
end;end;             { END OF CPUSHOOT }

procedure cpuchooseplayers(teami:byte);         { CpuChooseplayers }
const manbonus:array[2..5]of word=(125,180,280,400);
const hpsbonus:array[2..5]of byte=(10,20,40,60);
const mpsbonus:array[2..5]of byte=(10,20,40,60);
const reactbonus:array[2..5]of byte=(10,20,30,48);
const firbonus:array[2..5]of byte=(10,20,30,45);
const melbonus:array[2..5]of byte=(10,25,50,75);
const throbonus:array[2..5]of byte=(10,25,50,75);
const apsbonus:array[2..5]of byte=(0,0,0,0);
const armrand:array[2..5]of byte=(70,80,100,45);
const armplus:array[2..5]of byte=(0,5,25,60);
const weprand:array[2..5]of byte=(60,60,70,50);
const wepplus:array[2..5]of byte=(0,5,20,55);
const totalweps:array[2..5]of byte=(1,1,2,2);
const totalclips:array[2..5]of byte=(1,2,2,3);
const melrand:array[2..5]of byte=(70,80,100,40);
const melplus:array[2..5]of byte=(0,5,25,70);
const totalmelee:array[2..5]of byte=(1,1,1,1);
const explorand:array[2..5]of byte=(40,50,60,60);
const exploplus:array[2..5]of byte=(0,5,20,40);
const totalexplos:array[2..5]of byte=(1,1,2,2);
const medirand:array[2..5]of byte=(70,80,70,40);
const mediplus:array[2..5]of byte=(0,5,25,60);
const totalmedi:array[2..5]of byte=(1,1,2,2);

var i,a,tm1,tm2,groups,wo,wo1,wo2,tlo,thi:word;by,la:byte;
    apros,ipros,wpros,mpros,epros:real;
    afirst,alast,ifirst,ilast,wfirst,wlast,mfirst,mlast,efirst,elast:byte;
    value,order:array[1..100] of longint;
    slotti:array[1..20] of byte;

procedure quicksort(lo,hi:integer);
var i,j,x,y:longint;
begin i:=lo;j:=hi;x:=value[(lo+hi) div 2];
repeat
while(value[i]<x)do inc(i);
while(x<value[j])do dec(j);
if(i<=j)then begin
y:=value[i];value[i]:=value[j];value[j]:=y;
y:=order[i];order[i]:=order[j];order[j]:=y;
inc(i);dec(j);end;
until(i>j);
if(lo<j)then quicksort(lo,j);
if(i<hi)then quicksort(i,hi);
end;

procedure sortweps;               { Weapons into order }
var wo,a:word;
begin
for wo:=1 to 100 do begin order[wo]:=wo;la:=1;s:='      ';
for a:=1 to 6 do begin by:=mem[wepseg:wo*59-42+a];
if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,value[wo],code);end;
end;                              { Weapons into order }

procedure sortitems;              { Armors and medikits into order }
var wo,a:word;
begin
for wo:=1 to 50 do begin order[wo]:=wo;la:=1;s:='      ';
for a:=1 to 6 do begin by:=mem[itemseg:wo*30-13+a];
if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,value[wo],code);end;
end;                              { Armors and medikits into order }


begin
groups:=0;tm2:=0;         { Get a proper amount of warriors into group }
for tm1:=0 to teams do if(control[tm1]=1)then
begin inc(groups,gr[tm1]);inc(tm2);end;
if(groups=0)then begin groups:=8;tm2:=1;end;  { If no human players }
groups:=trunc(groups/tm2);
groups:=round(groups*(manbonus[control[teami]]/100));
if(groups=0)then groups:=1;
if(groups>warriors)then groups:=warriors;
gr[teami]:=groups;
gr1[teami]:=100;          { Get a proper amount of warriors into group }

              { Calculating weapon and armor selections }

for wo:=1 to warriors do slotti[wo]:=1;

sortweps;                         { Select projectile and laser weapons }
wfirst:=0;wlast:=100;
for i:=1 to 100 do if(wfirst=0)then if(mem[wepseg:i*59-58]=1)or(mem[wepseg:i*59-58]=2)then wfirst:=i;
for i:=1 to 100 do if(mem[wepseg:i*59-58]=3)and(wlast=100)and(i>=wfirst)then wlast:=i-1;
wpros:=(wlast-wfirst+1)/100;
quicksort(wfirst,wlast);
{ 2 projectile/laser weapons, 3 clips to each }
for tm1:=1 to gr[teami] do begin
for wo1:=1 to totalweps[control[teami]] do begin   { How many weapons }
wo:=round(wpros*wepplus[control[teami]]);
wo:=1+wo+random(round(wpros*weprand[control[teami]]));
{ I say "No thanks" to same weapons. (hopefully/usually) }
if(slotti[tm1]<>1)and(wo=invtype[teami,tm1,slotti[tm1]-1])then wo:=wo+random(9)-4;
{ I say "No thanks" to same weapons. (hopefully/usually) }
if(wo>(wlast-wfirst))then wo:=1+wlast-wfirst;if(wo<1)then wo:=1;
invtype[teami,tm1,slotti[tm1]]:=order[wo+wfirst-1];
if(wfirst=wlast)then invtype[teami,tm1,slotti[tm1]]:=wfirst;
if(wfirst=0)then invtype[teami,tm1,slotti[tm1]]:=0;
if(invtype[teami,tm1,slotti[tm1]]<>0)then inc(slotti[tm1]);
end;                                             { How many weapons }
end;                              { Select projectile and laser weapons }


sortweps;                         { Select melee weapons }
mfirst:=0;mlast:=100;
for i:=1 to 100 do if(mem[wepseg:i*59-58]=3)and(mfirst=0)then mfirst:=i;
for i:=1 to 100 do if(mem[wepseg:i*59-58]=4)and(mlast=100)and(i>=mfirst)then mlast:=i-1;
mpros:=(mlast-mfirst+1)/100;
quicksort(mfirst,mlast);
{ Always 1 Melee weapon }
for tm1:=1 to gr[teami] do begin
for wo1:=1 to totalmelee[control[teami]] do begin   { How many meleeweapons }
wo:=round(mpros*melplus[control[teami]]);
wo:=1+wo+random(round(mpros*melrand[control[teami]]));
if(wo>(mlast-mfirst))then wo:=1+mlast-mfirst;if(wo<1)then wo:=1;
invtype[teami,tm1,slotti[tm1]]:=order[wo+mfirst-1];
if(mfirst=mlast)then invtype[teami,tm1,slotti[tm1]]:=mfirst;
if(mfirst=0)then invtype[teami,tm1,slotti[tm1]]:=0;
if(invtype[teami,tm1,slotti[tm1]]<>0)then inc(slotti[tm1]);
end;                                                { How many meleeweapons }
end;                              { Select melee weapons }


sortweps;                         { Select explosives }
efirst:=0;elast:=100;
for i:=1 to 100 do if(mem[wepseg:i*59-58]=4)and(efirst=0)then efirst:=i;
for i:=1 to 100 do if(mem[wepseg:i*59-58]=0)and(elast=100)and(i>=efirst)then elast:=i-1;
epros:=(elast-efirst+1)/100;
quicksort(efirst,elast);
{ 3 Explosives }
for tm1:=1 to gr[teami] do begin
for wo1:=1 to totalexplos[control[teami]] do begin   { How many explosives }
wo:=round(epros*exploplus[control[teami]]);
wo:=1+wo+random(round(epros*explorand[control[teami]]));
if(wo>(elast-efirst))then wo:=1+elast-efirst;if(wo<1)then wo:=1;
invtype[teami,tm1,slotti[tm1]]:=order[wo+efirst-1];
if(efirst=elast)then invtype[teami,tm1,slotti[tm1]]:=efirst;
if(efirst=0)then invtype[teami,tm1,slotti[tm1]]:=0;
if(invtype[teami,tm1,slotti[tm1]]<>0)then inc(slotti[tm1]);
end;                                                 { How many explosives }
end;                              { Select explosives }

for tm1:=1 to gr[teami] do begin                { Select clips }
for wo1:=1 to totalweps[control[teami]] do if(invtype[teami,tm1,wo1]<>0)then
for wo2:=1 to totalclips[control[teami]] do begin  { How many clips }
invtype[teami,tm1,slotti[tm1]]:=100+invtype[teami,tm1,wo1];inc(slotti[tm1]);
end;                                               { How many clips }
end;                                            { Select clips }

sortitems;                        { Select medikits and flares }
ifirst:=0;ilast:=50;
for i:=1 to 50 do if(mem[itemseg:i*30-29]=2)and(ifirst=0)then ifirst:=i;
for i:=1 to 50 do if(mem[itemseg:i*30-29]=1)and(ilast=50)and(i>=ifirst)then ilast:=i-1;
ipros:=(ilast-ifirst+1)/100;
quicksort(ifirst,ilast);
{ 2 Medikits }
for tm1:=1 to gr[teami] do begin              { Medikits for all warriors }
for wo1:=1 to totalmedi[control[teami]] do begin   { How many medikits }
wo:=round(ipros*mediplus[control[teami]]);
wo:=1+wo+random(round(ipros*medirand[control[teami]]));
if(wo>(ilast-ifirst))then wo:=1+ilast-ifirst;if(wo<1)then wo:=1;
invtype[teami,tm1,slotti[tm1]]:=200+order[wo+ifirst-1];
if(ifirst=ilast)then invtype[teami,tm1,slotti[tm1]]:=200+ifirst;
if(ifirst=0)then invtype[teami,tm1,slotti[tm1]]:=0;
if(invtype[teami,tm1,slotti[tm1]]<>0)then inc(slotti[tm1]);
end;                                               { How many medikits }
end;                                          { Medikits for all warriors }
{ 1 Flare }
for tm1:=1 to gr[teami] do begin                     { Select flares }
invtype[teami,tm1,slotti[tm1]]:=251+random(3);
end;                                                 { Select flares }

                                  { Select medikits and flares }

sortitems;                        { Select armors }
afirst:=0;alast:=50;
for i:=1 to 50 do if(mem[itemseg:i*30-29]=1)and(afirst=0)then afirst:=i;
for i:=1 to 50 do if(mem[itemseg:i*30-29]=0)and(alast=50)and(i>=afirst)then alast:=i-1;
apros:=(alast-afirst+1)/100;
quicksort(afirst,alast);

for tm1:=1 to gr[teami] do begin
wo:=round(apros*armplus[control[teami]]);
wo:=wo+1+random(round(apros*armrand[control[teami]]));
if(wo>(alast-afirst))then wo:=1+alast-afirst;if(wo<1)then wo:=1;
arminuse[teami,tm1]:=order[afirst+wo-1];

if(afirst=alast)then arminuse[teami,tm1]:=afirst;
if(afirst=0)then arminuse[teami,tm1]:=0;
if(arminuse[teami,tm1]<>0)then
for i:=1 to 6 do begin
locaps[teami,tm1,i]:=mem[itemseg:((arminuse[teami,tm1]-1)*30)+23+i];
inc(locaps[teami,tm1,i],apsbonus[control[teami]]);
totaps[teami,tm1,i]:=locaps[teami,tm1,i];
end;
end;                              { Select armors }

              { Calculating weapon and armor selections }

for tm1:=1 to gr[teami] do begin                { Get player stats }
tothps[teami,tm1]:=random(50)+35+hpsbonus[control[teami]];
basmp[teami,tm1]:=random(40)+35+mpsbonus[control[teami]];
mps[teami,tm1]:=basmp[teami,tm1];
react[teami,tm1]:=random(20)+30+reactbonus[control[teami]];
firaccu[teami,tm1]:=random(30)+35+firbonus[control[teami]];
melaccu[teami,tm1]:=random(30)+35+melbonus[control[teami]];
throaccu[teami,tm1]:=random(30)+35+throbonus[control[teami]];
lochps[teami,tm1,1]:=round(tothps[teami,tm1]*0.08);
lochps[teami,tm1,2]:=round(tothps[teami,tm1]*0.28);
lochps[teami,tm1,3]:=round(tothps[teami,tm1]*0.16);
lochps[teami,tm1,4]:=round(tothps[teami,tm1]*0.16);
lochps[teami,tm1,5]:=round(tothps[teami,tm1]*0.16);
lochps[teami,tm1,6]:=round(tothps[teami,tm1]*0.16);
aidelay[teami,tm1]:=0;
end;                                            { Get player stats }
end;                                            { CpuChooseplayers }

procedure cpudeploy(teami,boys:byte);           { CpuDeployment }
var xal,yal,nab,nac,newa,ab,ac:byte;dbits:word;
    dplace:array[1..warriors] of word;

begin
if(teami=0)then ac:=1;
if(teami=1)then ac:=4;
if(teami=2)then ac:=3;
if(teami=3)then ac:=14;
dbits:=0;
for yal:=1 to mapy do for xal:=1 to mapx do
if(mem[musaseg:(xal-1)*100+(yal-1)]=ac)then inc(dbits);
for ab:=1 to boys do begin
repeat
newa:=0;nab:=random(dbits)+1;
if(ab>1)then begin newa:=0;
for nac:=1 to ab-1 do if(nab=dplace[nac])then newa:=1;end;
until(newa=0);
dplace[ab]:=nab;
nab:=0;
for yal:=1 to mapy do for xal:=1 to mapx do
if(mem[musaseg:(xal-1)*100+(yal-1)]=ac)then begin
inc(nab);if(nab=dplace[ab])then begin plx[teami,ab]:=xal;ply[teami,ab]:=yal;end;
end;
end;

for ab:=1 to boys do fc[teami,ab]:=random(8);
end;                                            { CpuDeployment }

procedure cpureload(teami,man:byte);
var line:byte;
begin
cpurel:=false;line:=0;
line:=rarm[teami,man];if(rarm[teami,man]=0)then line:=larm[teami,man];
if(lochps[teami,man,3]+lochps[teami,man,4]>=1)and(invtype[teami,man,line]>=1)and(line>0)
and(invtype[teami,man,line]<=100)and(mps[teami,man]>=10)and(invammo[teami,man,line]<1)then begin
for i:=1 to 15 do
if((invtype[teami,man,i]-100)=invtype[teami,man,line])and(cpurel=false)and(invammo[teami,man,i]>=1)then begin
invammo[teami,man,line]:=invammo[teami,man,i];invammo[teami,man,i]:=0;cpurel:=true;drop(teami,man,i,true);end;
if(cpurel=true)then begin dec(mps[teami,man],10);
if(invammo[teami,man,line]=0)then drop(teami,man,line,false);

{inftxt('Debug: Reload.          ',255,2,0);}

pguard;

end;
end;
end;

end.

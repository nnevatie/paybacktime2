{$F+ $O+}
unit extunit;
interface
uses sbunit,varunit;

procedure throwing;
procedure pickup;
procedure healing;
procedure wepstat;
procedure invscreen;
procedure shoot;
procedure pguard;

implementation

procedure throwing;
var pum,bhand,trap,newp,thable:boolean;x1,y1,x2,y2,thand,expinh:byte;thrange,thacc,test:integer;
function rc(xm,ym:byte):boolean;
begin if(round(sqrt(sqr(plx[grp,pln]-xm)+sqr(ply[grp,pln]-ym)))<=15)then rc:=true else rc:=false;end;
begin { BEGIN THROWING }
bhand:=false;thable:=false;thand:=0;throwed:=false;dropuse:=0;

if(lochps[grp,pln,3]>=1)and(rarm[grp,pln]<>0)and(invtype[grp,pln,rarm[grp,pln]]<>0)then
begin thand:=rarm[grp,pln];thable:=true;end;
if(lochps[grp,pln,4]>=1)and(larm[grp,pln]<>0)and(invtype[grp,pln,larm[grp,pln]]<>0)then
begin thand:=larm[grp,pln];thable:=true;end;

if(mps[grp,pln]<8)then mpsflash;

if(rarm[grp,pln]<>larm[grp,pln])and(rarm[grp,pln]<>0)and(larm[grp,pln]<>0)and(mps[grp,pln]>=8)and
(lochps[grp,pln,3]>=1)and(lochps[grp,pln,4]>=1)and(invtype[grp,pln,rarm[grp,pln]]<>0)and(invtype[grp,pln,larm[grp,pln]]<>0)then
begin { ARMS OK }
inftxt('Which hand to throw/trap with ? ',15,1,0);
inftxt('(r)ight or (l)eft hand.         ',15,2,0);
repeat ch:=readk;until (ch=#38)or(ch=#19);
if(ch=#19)then thand:=rarm[grp,pln];
if(ch=#38)then thand:=larm[grp,pln];
thable:=true;bhand:=true;end;

if(thable=true)then
if(mps[grp,pln]>=8)then
begin { MPS OK }

inftxt('Choose your target.             ',15,1,0);inftxt(cle,0,2,0);
ix:=plx[grp,pln];iy:=ply[grp,pln];pntr:=false;ico:=true;

repeat
cx:=ix-4;cy:=iy-3;drawmap;ch:=readk;

case ch of
#77:if(ix<mapx)and(rc(ix+1,iy)=true)then
begin if cx<98 then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)>13)then cx:=cx+1;ix:=ix+1;end;
#75:if(ix>1)and(rc(ix-1,iy)=true)then
begin if cx>-3 then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)<1)then cx:=cx-1;ix:=ix-1;end;
#72:if(iy>1)and(rc(ix,iy-1)=true)then
begin if cy>-3 then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)<1)then cy:=cy-1;iy:=iy-1;end;
#80:if(iy<mapy)and(rc(ix,iy+1)=true)then
begin if cy<98 then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)>13)then cy:=cy+1;iy:=iy+1;end;
end;
until (ch=#28)or(ch=#1);

if(ch=#28)then
begin { RETURN PRESSED }
sect:=false;
{case fc[grp,pln] of
0:if(ply[grp,pln]-iy+1>0)and(plx[grp,pln]-ix+1>0)then sect:=true;
1:if(abs(ix-plx[grp,pln])<=abs(iy-ply[grp,pln]))and(ply[grp,pln]-iy>0) then sect:=true;
2:if(ply[grp,pln]-iy+1>0)and(plx[grp,pln]-ix-1<0)then sect:=true;
3:if(abs(ix-plx[grp,pln])>=abs(iy-ply[grp,pln]))and(plx[grp,pln]-ix<0) then sect:=true;
4:if(ply[grp,pln]-iy-1<0)and(plx[grp,pln]-ix-1<0)then sect:=true;
5:if(abs(ix-plx[grp,pln])<=abs(iy-ply[grp,pln]))and(ply[grp,pln]-iy<0) then sect:=true;
6:if(ply[grp,pln]-iy-1<0)and(plx[grp,pln]-ix+1>0)then sect:=true;
7:if(abs(ix-plx[grp,pln])>=abs(iy-ply[grp,pln]))and(plx[grp,pln]-ix>0) then sect:=true;
end;}

if(secheck(plx[grp,pln],ply[grp,pln],ix,iy,fc[grp,pln])=1)then sect:=true else sect:=false;

if(sect=true)then
begin { SECTOR OK }
liosi:=false;lioma:=false;
liofsi(plx[grp,pln],ply[grp,pln],ix,iy);liofman(plx[grp,pln],ply[grp,pln],ix,iy);

trap:=false;expinh:=0;   { Trapping }
if(invtype[grp,pln,rarm[grp,pln]]>=1)and(invtype[grp,pln,rarm[grp,pln]]<=100)then begin
readwep(invtype[grp,pln,rarm[grp,pln]]);if(weaptype=4)then expinh:=1;end;

if(invtype[grp,pln,larm[grp,pln]]>=1)and(invtype[grp,pln,larm[grp,pln]]<=100)then begin
readwep(invtype[grp,pln,larm[grp,pln]]);
if(weaptype=4)and(expinh=0)then expinh:=2;
if(weaptype=4)and(expinh=1)then expinh:=3;end;

if(map[ix,iy]=34)or(map[ix,iy]=35)or(map[ix,iy]=38)or(map[ix,iy]=39)then
if(expinh>0)and(sqrt(sqr(plx[grp,pln]-ix)+sqr(ply[grp,pln]-iy))<2)then

if(mps[grp,pln]>=15)then begin
inftxt('Do you want to trap that door ?',15,1,0);inftxt(cle,0,2,0);trap:=true;
if(expinh=1)and(bhand=true)then begin inftxt('Trapping with right hand bomb. ',15,2,0);thand:=rarm[grp,pln];end;
if(expinh=2)and(bhand=true)then begin inftxt('Trapping with left hand bomb.  ',15,2,0);thand:=larm[grp,pln];end;
repeat ch:=readk;until(ch=#49)or(ch=#21);
broken:=0;
pum:=false;
if(ch=#21)then begin for test:=1 to dritem do  { Traptest }
if(itemhide[test]=1)and(ix=itemx[test])and(iy=itemy[test])then begin readwep(itemt[test]);
inftxt('That door was already trapped ! ',2,1,0);inftxt(cle,0,2,0);asm xor ax,ax;int $16;end;inftxt(cle,0,1,0);

for c3:=test to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;
{ N„m„ ensin, jottei toista exploa! }

explosion(plx[grp,pln]+fcx[fc[grp,pln]],ply[grp,pln]+fcy[fc[grp,pln]],exprad,ydam+random(xdam)+1,expfact);
pntr:=true;
if(broken=1)then calclights;
dell;see;
itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;
dec(dritem);pum:=true;
end;
cnt;end;  { Traptest }

if(pum=false)and(ch=#21)and(expinh>=1)and(expinh<=2)then begin
x1:=plx[grp,pln];y1:=ply[grp,pln];plx[grp,pln]:=ix;ply[grp,pln]:=iy;
if(expinh=1)then drop(grp,pln,rarm[grp,pln],false);
if(expinh=2)then drop(grp,pln,larm[grp,pln],false);

itemhide[dritem]:=1;plx[grp,pln]:=x1;ply[grp,pln]:=y1;
dec(mps[grp,pln],15);
end;

if(pum=false)and(ch=#21)and(expinh=3)then begin
x1:=plx[grp,pln];y1:=ply[grp,pln];plx[grp,pln]:=ix;ply[grp,pln]:=iy;
drop(grp,pln,thand,false);itemhide[dritem]:=1;
plx[grp,pln]:=x1;ply[grp,pln]:=y1;
dec(mps[grp,pln],15);
end;

if(ch=#49)then ch:=#0;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end else begin trap:=true;inftxt('Not enough MPS to trap that.   ',15,1,0);inftxt(cle,0,2,0);
ch:=readk;ch:=#0;inftxt(cle,0,1,0);end;

 { Trapping }

if(trap=false)and(liosi=true)and(lioma=true)then begin { LOS OK }
throwed:=true;play('throw.svs',10000);

thrange:=round(sqrt(sqr(plx[grp,pln]-ix)+sqr(ply[grp,pln]-iy)));
thacc:=round(throaccu[grp,pln]-(thrange*3));

if(thacc<1)then thacc:=1;if(thacc>99)then thacc:=99;

a:=1+random(99);if(a<=thacc)then
begin
{x1:=plx[grp,pln];y1:=ply[grp,pln];plx[grp,pln]:=ix;ply[grp,pln]:=iy;
drop(grp,pln,thand,false);plx[grp,pln]:=x1;ply[grp,pln]:=y1;

inftxt('Nice throw !                    ',15,1,0);
delay(500);
inftxt(cle,0,1,0);
}
dec(mps[grp,pln],8);{cx:=ix-4;cy:=iy-3;ico:=false;drawmap;delay(500);
}x2:=ix;
y2:=iy;
end else {nice}
begin {miss}

a:=round(thrange/5);
if a>3 then a:=3;
x2:=ix+random(2*a+1)-a;
y2:=iy+random(2*a+1)-a;
dec(mps[grp,pln],8);
{cx:=ix-4;cy:=iy-3;ico:=false;drawmap;delay(500);
}
end; {miss}

x1:=plx[grp,pln];y1:=ply[grp,pln];
newp:=false;
vx:=x1;vy:=y1;
if x1-x2<>0 then yd:=(y2-y1)/(x2-x1) else begin xd:=0;yd:=1;if y1>y2 then yd:=-1;end;
if y1-y2<>0 then xd:=(x2-x1)/(y2-y1) else begin yd:=0;xd:=1;if x1>x2 then xd:=-1;end;
if xd>1 then xd:=1;if yd>1 then yd:=1;if xd<-1 then xd:=-1;if yd<-1 then yd:=-1;
if (x1>x2) and (y1<y2) then yd:=-yd;if (x1>x2) and (y1>y2) then begin xd:=-xd;yd:=-yd;end;
if (x1<x2) and (y1>y2) then begin xd:=-xd;end;{if xd<0 then vx:=vx-0.1;if yd<0 then vy:=vy-0.1;}
px:=x1;py:=y1;
repeat

vpx:=px;vpy:=py;
vx:=vx+xd;vy:=vy+yd;
px:=round(vx);py:=round(vy);

if(px=x2)and(py=y2)then newp:=true;

if(firable[map[px,py]]=false)then newp:=true;
if(enter[map[px,py]]=false)and(px=x2)and(py=y2)then newp:=true;
for a:=0 to teams do for i:=1 to gr[a] do
if (a<>grp)or(i<>pln) then
if(plx[a,i]=px)and(ply[a,i]=py)and(dead[a,i]=false)then newp:=true;
until newp=true;

if(enter[map[px,py]]=false)then begin px:=vpx;py:=vpy;end;

x1:=plx[grp,pln];y1:=ply[grp,pln];plx[grp,pln]:=px;ply[grp,pln]:=py;
if(invtype[grp,pln,thand]>=251)and(invtype[grp,pln,thand]<=253)then invammo[grp,pln,thand]:=1;
dropuse:=1;
drop(grp,pln,thand,false);plx[grp,pln]:=x1;ply[grp,pln]:=y1;

if(px=ix)and(py=iy)then begin
inftxt('Nice throw !                    ',15,1,0);
wait(10);inftxt(cle,0,1,0);
cx:=px-4;cy:=py-3;ico:=false;drawmap;wait(70);

end else begin
inftxt('Missed !                        ',15,1,0);
wait(10);inftxt(cle,0,1,0);
cx:=px-4;cy:=py-3;ico:=false;drawmap;wait(70);

end;

if(dropuse=1)then calclights;

end else if(trap=false)then
begin inftxt('Target out of sight.            ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);end
end else if(trap=false)then
begin inftxt('Target out of sector.           ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);end;
end;

cnt;pntr:=true;ico:=false;see;drawmap;

end else begin {inftxt('Not enough movement points.     ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0); }
end else begin inftxt('No items in your hands.         ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);
end;
end;


procedure pickup;
var test:word;itnu,hites,ites,islots:word;endi,picked:boolean;pag1,lin1:byte;ipre:array[1..300]of word;
procedure pageup;
begin
for c3:=(pag1-1)*5+1 to (pag1-1)*5+5 do begin s:='                ';
if(itemt[ipre[c3]]>=1)and(itemt[ipre[c3]]<=100)then begin
for a:=1 to 16 do begin by1:=mem[wepseg:((itemt[ipre[c3]]-1)*59)+a+1];s[a]:=chr(by1);end;end;
if(itemt[ipre[c3]]>=101)and(itemt[ipre[c3]]<=200)then begin
for a:=1 to 16 do begin by1:=mem[wepseg:((itemt[ipre[c3]]-101)*59)+a+33];s[a]:=chr(by1);end;end;
if(itemt[ipre[c3]]>=201)and(itemt[ipre[c3]]<=253)then begin
for a:=1 to 16 do begin by1:=mem[itemseg:((itemt[ipre[c3]]-201)*30)+a+1];s[a]:=chr(by1);end;end;
fastfont(s,63,40+(c3-((pag1-1)*5))*12,25,0,ownseg,0,1);end;
end;
function rc(xm,ym:byte):boolean;
begin if(round(sqrt(sqr(plx[grp,pln]-xm)+sqr(ply[grp,pln]-ym)))<2)then rc:=true else rc:=false;end;

begin
pickuped:=false;dropuse:=0;

if(mps[grp,pln]<10)then mpsflash;

if(lochps[grp,pln,3]+lochps[grp,pln,4]>=1)then
if(mps[grp,pln]>=10)then begin
islots:=0;for wo:=15 downto 1 do if(invtype[grp,pln,wo]=0)then islots:=wo;
if(islots<>0)then begin
inftxt('What do you want to pickup ?    ',15,1,0);inftxt(cle,0,2,0);
ix:=plx[grp,pln];iy:=ply[grp,pln];pntr:=false;ico:=true;
icol:=242;for wo:=1 to dritem do if(itemx[wo]=ix)and(itemy[wo]=iy)and(itemhide[wo]=0)then icol:=2;
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
end;
icol:=242;for wo:=1 to dritem do if(itemx[wo]=ix)and(itemy[wo]=iy)and(itemhide[wo]=0)then icol:=2;
until (ch=#28)or(ch=#1);

picked:=false;endi:=false;ites:=0;hites:=0;
for wo:=1 to dritem do if(itemx[wo]=ix)and(itemy[wo]=iy)and(itemhide[wo]=0)then inc(ites);
for wo:=1 to dritem do if(itemx[wo]=ix)and(itemy[wo]=iy)and(itemhide[wo]=1)then inc(hites);

{ Boobytrapped door }
if(map[ix,iy]=34)or(map[ix,iy]=35)or(map[ix,iy]=38)or(map[ix,iy]=39)then begin
inftxt('Do you want to examine that ?   ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#49)or(ch=#21);

if(ch=#21)and(hites=1)and(mps[grp,pln]<20)then begin
dec(mps[grp,pln],10);
inftxt('The door is trapped !          ',15,1,0);
ites:=0;asm xor ax,ax;int $16;end;inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

if(ch=#21)and(hites=1)and(mps[grp,pln]>=20)then begin    { A1 }
dec(mps[grp,pln],10);
inftxt('The door is trapped !          ',15,1,0);
inftxt('Do you want to disarm it ?     ',15,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49);
ites:=0;
if ch=#21 then begin { yes }
dec(mps[grp,pln],10);
if(random(100)+1<=react[grp,pln])then begin    { Rand, *reaction* }
inftxt('You managed to disarm it !     ',15,1,0);inftxt(cle,0,2,0);
for test:=1 to dritem do begin { Traptest }
if(itemhide[test]=1)and(ix=itemx[test])and(iy=itemy[test])then begin
for c3:=test to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;
itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;
dec(dritem);
end;end;  { Traptest }
asm xor ax,ax;int $16;end;inftxt(cle,0,1,0);
end     { Rand }
else begin   { Bad luck beg }
inftxt('You failed to disarm it !!!    ',2,1,0);inftxt(cle,0,2,0);
asm xor ax,ax;int $16;end;inftxt(cle,0,1,0);

for test:=1 to dritem do  { Traptest }
if(itemhide[test]=1)and(ix=itemx[test])and(iy=itemy[test])then begin

readwep(itemt[test]);

for c3:=test to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;

explosion(ix,iy,exprad,ydam+random(xdam)+1,expfact);
pntr:=true;
dell;
itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;
dec(dritem);cnt;
end;  { Traptest }

end;         { Bad luck beg }
end;    { Yes }
if(ch=#49)then begin inftxt(cle,0,1,0);inftxt(cle,0,2,0);ch:=#0;ites:=0;end;
end;    { A1 }


if(ch=#21)and(hites=0)then begin
inftxt('Nothing found...                ',15,1,0);inftxt(cle,0,2,0);
asm xor ax,ax;int $16;end;dec(mps[grp,pln],10);ch:=#0;
end;

if(ch=#49)then ch:=#0;
end;  { Boobytrapped door }

if(map[ix,iy]>=59)and(map[ix,iy]<=60)then begin { Hided item }
inftxt('Do you want to examine that ?   ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#49)or(ch=#21);

if(ch=#21)and(hites>0)then begin ites:=hites;ch:=#28;dec(mps[grp,pln],10);
if(mps[grp,pln]<10)then begin
inftxt('There''s something in it!        ',15,1,0);
inftxt('Too bad, no time to pick it up. ',15,2,0);
asm xor ax,ax;int $16;end;ch:=#0;ites:=0;inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;
end;

if(ch=#21)and(hites=0)then begin
inftxt('Nothing found...                ',15,1,0);inftxt(cle,0,2,0);
asm xor ax,ax;int $16;end;dec(mps[grp,pln],10);ch:=#0;
end;

if(ch=#49)then ch:=#0;
end;  { Hided item }

if(ites>0)and(ch=#28)and(mps[grp,pln]>=10)then begin { Picking up }
for wo:=1 to 300 do ipre[wo]:=0;c3:=0;
for wo:=1 to dritem do if(itemx[wo]=ix)and(itemy[wo]=iy)and(itemt[wo]<>0)then begin inc(c3);ipre[c3]:=wo;end;

for wo:=1 to dritem do if(itemx[wo]=ix)and(itemy[wo]=iy)and(itemt[wo]<>0)then itnu:=wo;
wipe($a000,ownseg,0,0,16000);
for wo:=49 to 111 do for c3:=60 to 196 do mem[ownseg:wo*320+c3]:=0;
for wo:=49 to 111 do begin mem[ownseg:wo*320+60]:=1;mem[ownseg:wo*320+196]:=1;end;
for wo:=60 to 196 do begin mem[ownseg:49*320+wo]:=1;mem[ownseg:111*320+wo]:=1;end;
pag1:=1;lin1:=1;pageup;
repeat
point(62,39+(lin1*12),194,49+(lin1*12),4);
wipe(ownseg,$a000,0,0,16000);
point(62,39+(lin1*12),194,49+(lin1*12),0);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#72)and((pag1-1)*5+lin1>1)then begin dec(lin1);if lin1<1 then begin dec(pag1);lin1:=5;pageup;end;end;
if(c1=#80)and((pag1-1)*5+lin1<ites)then begin inc(lin1);if lin1>5 then begin inc(pag1);lin1:=1;pageup;end;end;
if(c1=#81)and(pag1<1+trunc((ites-1)/5))then begin inc(pag1);if lin1>ites-(pag1-1)*5 then lin1:=ites-(pag1-1)*5;pageup;end;
if(c1=#73)and(pag1>1)then begin dec(pag1);pageup;end;
if(c1=#1)then begin endi:=true;end;
until(c1=#28)or(c1=#1);
if(endi=true)then itnu:=0 else itnu:=ipre[(lin1+(pag1-1)*5)];

if(endi=false)then begin if(hites>0)then inc(ifound[grp]);
picked:=true;{ Pickup }
if(itemt[itnu]>=251)and(itemt[itnu]<=253)then begin itema[itnu]:=0;dropuse:=1;end;
invtype[grp,pln,islots]:=itemt[itnu];invammo[grp,pln,islots]:=itema[itnu];invprime[grp,pln,islots]:=itemp[itnu];

for c3:=itnu to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;
itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;

pickuped:=true;dec(mps[grp,pln],10);dec(dritem);end; { Pickup }
if(dropuse=1)then calclights;
end;    { Picking up }

end else begin inftxt('No space in your inventory.     ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;end;
cnt;pntr:=true;ico:=false;if picked=true then {init(0);}see;drawmap;
end else begin {inftxt('Not enough movement points.     ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);}end
else begin inftxt('Your hands are disabled.        ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);end;
end;

procedure healing;
var his,hg,hm,hpla:byte;hmod:real;
function rc(xm,ym:byte):boolean;
begin if(round(sqrt(sqr(plx[grp,pln]-xm)+sqr(ply[grp,pln]-ym)))<2)then rc:=true else rc:=false;end;

begin healed:=false;
if(mps[grp,pln]<15)then mpsflash;

if(invtype[grp,pln,rarm[grp,pln]]>200)or(invtype[grp,pln,larm[grp,pln]]>200)then
if(mps[grp,pln]>=15)then begin
if(invtype[grp,pln,rarm[grp,pln]]>200)and(invtype[grp,pln,larm[grp,pln]]<201)then his:=rarm[grp,pln];
if(invtype[grp,pln,larm[grp,pln]]>200)and(invtype[grp,pln,rarm[grp,pln]]<201)then his:=larm[grp,pln];

if(invtype[grp,pln,rarm[grp,pln]]>200)and(invtype[grp,pln,larm[grp,pln]]>200)then begin
inftxt('Which hand to heal with ?       ',15,1,0);inftxt('(r)ight or (l)eft hand          ',15,2,0);
repeat ch:=readk;until (ch=#38)or(ch=#19);
if ch=#19 then his:=rarm[grp,pln];if ch=#38 then his:=larm[grp,pln];
end;

inftxt('Who do you want to heal ?       ',15,1,0);inftxt(cle,0,2,0);
ix:=plx[grp,pln];iy:=ply[grp,pln];pntr:=false;ico:=true;
icol:=242;
for wo:=0 to teams do
for a:=1 to gr[wo] do if(plx[wo,a]=ix)and(ply[wo,a]=iy)and(dead[wo,a]=false)and(ally[wo]=ally[a])then icol:=2;
repeat
drawmap;ch:=readk;
case ch of
#77:if(ix<100)and(rc(ix+1,iy)=true)then
begin if cx<98 then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)>13)then cx:=cx+1;ix:=ix+1;end;
#75:if(ix>1)and(rc(ix-1,iy)=true)then
begin if cx>-3 then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)<1)then cx:=cx-1;ix:=ix-1;end;
#72:if(iy>1)and(rc(ix,iy-1)=true)then
begin if cy>-3 then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)<1)then cy:=cy-1;iy:=iy-1;end;
#80:if(iy<100)and(rc(ix,iy+1)=true)then
begin if cy<98 then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)>13)then cy:=cy+1;iy:=iy+1;end;
end;
icol:=242;for a:=1 to gr[grp] do if(plx[grp,a]=ix)and(ply[grp,a]=iy)and(dead[grp,a]=false)then icol:=2;
until (ch=#28)or(ch=#1);
hm:=0;
for a:=0 to teams do
for wo:=1 to gr[a] do if(plx[a,wo]=ix)and(ply[a,wo]=iy)and(dead[a,wo]=false)and(ally[a]=ally[grp])then begin hm:=wo;hg:=a;end;

if(ch=#28)and(mps[grp,pln]>=15)and(hm<>0)and(invammo[grp,pln,his]>0)then begin
inftxt('(1)head, (2)chest, (3)r.arm   ',15,1,0);
inftxt('(4)l.arm, (5)r.leg, (6)l.leg  ',15,2,0);

repeat ch:=readk;until(ch>=#1)and(ch<=#7);
case ch of
#2:begin hpla:=1;hmod:=0.08;end;
#3:begin hpla:=2;hmod:=0.28;end;
#4:begin hpla:=3;hmod:=0.16;end;
#5:begin hpla:=4;hmod:=0.16;end;
#6:begin hpla:=5;hmod:=0.16;end;
#7:begin hpla:=6;hmod:=0.16;end;
end;
if(ch<>#1)then begin
inc(lochps[hg,hm,hpla],mem[itemseg:((invtype[grp,pln,his]-201)*30)+25]);
if(lochps[hg,hm,hpla]>round(tothps[hg,hm]*hmod))then lochps[hg,hm,hpla]:=round(tothps[hg,hm]*hmod);
dec(invammo[grp,pln,his]);if(invammo[grp,pln,his]<1)then drop(grp,pln,his,true);
inftxt(cle,0,1,0);inftxt(cle,0,2,0);dec(mps[grp,pln],15);healed:=true;
end else begin inftxt(cle,0,1,0);inftxt(cle,0,2,0);end;end;

cnt;pntr:=true;ico:=false;see;drawmap;icol:=242;
end else begin {inftxt('Not enough movement points.    ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);}end
else begin inftxt('No medikit in your hands.      ',15,1,0);inftxt(cle,0,2,0);ch:=readk;ch:=#0;inftxt(cle,0,1,0);end;
end;

procedure wepstat;
begin
if(rarm[grp,pln]<>larm[grp,pln])then begin { One handed weapon }
s:=cle;s1:='                ';
if(invtype[grp,pln,rarm[grp,pln]]<101)and(invtype[grp,pln,rarm[grp,pln]]>0)then readwep(invtype[grp,pln,rarm[grp,pln]]);
if(invtype[grp,pln,rarm[grp,pln]]<201)and(invtype[grp,pln,rarm[grp,pln]]>100)then readwep(invtype[grp,pln,rarm[grp,pln]]-100);
str(invammo[grp,pln,rarm[grp,pln]],s);
if(rarm[grp,pln]=0)then begin wepnam:='';clnam:='';s:='';s1:='';end;
c3:=15;if lochps[grp,pln,3]=0 then c3:=2;
if(rarm[grp,pln]<>0)then begin inftxt('A: '+s,c3,1,22);
if(invtype[grp,pln,rarm[grp,pln]]<101)and(invtype[grp,pln,rarm[grp,pln]]>0)then inftxt('R: '+wepnam,c3,1,0);
if(invtype[grp,pln,rarm[grp,pln]]<201)and(invtype[grp,pln,rarm[grp,pln]]>100)then inftxt('R: '+clnam,c3,1,0);
if(invtype[grp,pln,rarm[grp,pln]]<254)and(invtype[grp,pln,rarm[grp,pln]]>200)then
begin for a:=1 to 16 do begin by1:=mem[itemseg:((invtype[grp,pln,rarm[grp,pln]]-201)*30)+a+1];s1[a]:=chr(by1);end;
inftxt('R: '+s1,c3,1,0);end;end;


s:=cle;s1:='                ';
if(invtype[grp,pln,larm[grp,pln]]<101)and(invtype[grp,pln,larm[grp,pln]]>0)then readwep(invtype[grp,pln,larm[grp,pln]]);
if(invtype[grp,pln,larm[grp,pln]]<201)and(invtype[grp,pln,larm[grp,pln]]>100)then readwep(invtype[grp,pln,larm[grp,pln]]-100);
str(invammo[grp,pln,larm[grp,pln]],s);
if(larm[grp,pln]=0)then begin wepnam:='';clnam:='';s:='';s1:='';end;
c3:=15;if(lochps[grp,pln,4]=0)then c3:=2;
if(larm[grp,pln]<>0)then begin inftxt('A: '+s,c3,2,22);
if(invtype[grp,pln,larm[grp,pln]]<101)and(invtype[grp,pln,larm[grp,pln]]>0)then inftxt('L: '+wepnam,c3,2,0);
if(invtype[grp,pln,larm[grp,pln]]<201)and(invtype[grp,pln,larm[grp,pln]]>100)then inftxt('L: '+clnam,c3,2,0);
if(invtype[grp,pln,larm[grp,pln]]<254)and(invtype[grp,pln,larm[grp,pln]]>200)then
begin for a:=1 to 16 do begin by1:=mem[itemseg:((invtype[grp,pln,larm[grp,pln]]-201)*30)+a+1];s1[a]:=chr(by1);end;
inftxt('L: '+s1,c3,2,0);end;end;
end;

if(rarm[grp,pln]=larm[grp,pln])then begin { Two handed weapon }
s:=cle;s1:='                ';
if(invtype[grp,pln,rarm[grp,pln]]<101)and(invtype[grp,pln,rarm[grp,pln]]>0)then readwep(invtype[grp,pln,rarm[grp,pln]]);
if(invtype[grp,pln,rarm[grp,pln]]<201)and(invtype[grp,pln,rarm[grp,pln]]>100)then readwep(invtype[grp,pln,rarm[grp,pln]]-100);
str(invammo[grp,pln,rarm[grp,pln]],s);
if(rarm[grp,pln]=0)then begin wepnam:='';clnam:='';s:='';s1:='';end;
c3:=15;if(lochps[grp,pln,3]=0)or(lochps[grp,pln,4]=0) then c3:=2;
if(rarm[grp,pln]<>0)then begin inftxt('A: '+s,c3,1,22);
if(invtype[grp,pln,rarm[grp,pln]]<101)and(invtype[grp,pln,rarm[grp,pln]]>0)then inftxt('B: '+wepnam,c3,1,0);
if(invtype[grp,pln,rarm[grp,pln]]<201)and(invtype[grp,pln,rarm[grp,pln]]>100)then inftxt('B: '+clnam,c3,1,0);
if(invtype[grp,pln,rarm[grp,pln]]<254)and(invtype[grp,pln,rarm[grp,pln]]>200)then
begin for a:=1 to 16 do begin by1:=mem[itemseg:((invtype[grp,pln,rarm[grp,pln]]-201)*30)+a+1];s1[a]:=chr(by1);end;
inftxt('B: '+s1,c3,1,0);end;end;
end;

ch:=readk;inftxt(cle,0,1,0);inftxt(cle,0,2,0);see;
end;

procedure invscreen;
const icolo=115;
var invtest:boolean;plast,pturn,pgrp:shortint;
    pst:array[0..teams] of string[10];
    ok,pcol:array[0..teams] of byte;

procedure upscre;
begin
e:=0;loadpic('gfx\invenpic.svf');
for i:=1 to 15 do begin s:='                ';s1:='    ';
if(invtype[grp,pln,i]>=1)and(invtype[grp,pln,i]<=100)then begin inc(e);
if(mem[wepseg:(invtype[grp,pln,i]-1)*59+1]<3)then str(invammo[grp,pln,i],s1);
for a:=1 to 16 do begin by1:=mem[wepseg:((invtype[grp,pln,i]-1)*59)+a+1];s[a]:=chr(by1);end;end;
if(invtype[grp,pln,i]>=101)and(invtype[grp,pln,i]<=200)then begin inc(e);str(invammo[grp,pln,i],s1);
for a:=1 to 16 do begin by1:=mem[wepseg:((invtype[grp,pln,i]-101)*59)+a+33];s[a]:=chr(by1);end;end;
if(invtype[grp,pln,i]>=201)and(invtype[grp,pln,i]<=250)then begin inc(e);str(invammo[grp,pln,i],s1);
for a:=1 to 16 do begin by1:=mem[itemseg:((invtype[grp,pln,i]-201)*30)+a+1];s[a]:=chr(by1);end;end;

if(invtype[grp,pln,i]>=251)and(invtype[grp,pln,i]<=253)then begin inc(e);
for a:=1 to 16 do begin by1:=mem[itemseg:((invtype[grp,pln,i]-201)*30)+a+1];s[a]:=chr(by1);end;end;

fastfont(s,38,10+i*11,207,icolo,ownseg,0,1);
if (length(s1)<4) then for by1:=3 downto length(s1) do insert(' ',s1,1);
fastfont(s1,181,10+i*11,207,icolo,ownseg,0,1);
str(invprime[grp,pln,i]-1,s);if(invprime[grp,pln,i]-1<10)then insert(' ',s,1);
if(invprime[grp,pln,i]=0)then begin s:=' -';
fastfont(s,232,10+i*11,207,icolo,ownseg,0,1);end else
fastfont(s,232,10+i*11,1,icolo,ownseg,0,1);

end;for wo:=14 to 23 do for c3:=21 to 183 do mem[ownseg:c3*320+wo]:=icolo;
if(rarm[grp,pln]<>larm[grp,pln])and(rarm[grp,pln]<>0)then fastfont('R',14,10+rarm[grp,pln]*11,1,icolo,ownseg,0,1);
if(rarm[grp,pln]<>larm[grp,pln])and(larm[grp,pln]<>0)then fastfont('L',14,10+larm[grp,pln]*11,1,icolo,ownseg,0,1);
if(rarm[grp,pln]=larm[grp,pln])and(rarm[grp,pln]<>0)then fastfont('B',14,10+rarm[grp,pln]*11,1,icolo,ownseg,0,1);
str(mps[grp,pln],s);if(mps[grp,pln]<10)then insert('  ',s,1);
if(mps[grp,pln]<100)and(mps[grp,pln]>=10)then insert(' ',s,1);
fastfont(s,280,20,207,icolo,ownseg,0,1);
wipe(ownseg,$a000,0,0,16000);
end;

begin
dropuse:=0;
invtest:=false;for i:=1 to 15 do if(invtype[grp,pln,i]<>0)then invtest:=true;
if invtest=true then begin

palswap;fade(4);clear($a000,16000);
for wo:=0 to 767 do sofpal[wo]:=0;
assign(f,'gamedata\invenpic.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for c3:=0 to 767 do defpal[c3]:=mem[ownseg:c3];
loadpic('gfx\invenpic.svf');
wipe(ownseg,$a000,0,0,16000);
line:=1;upscre;
fade(4);

repeat
fastfont('                                     ',10,189,207,icolo,ownseg,0,1);
if(invtype[grp,pln,line]>=1)and(invtype[grp,pln,line]<=100)then begin
readwep(invtype[grp,pln,line]);

if(weaptype=1)or(weaptype=2)then begin
fastfont('S :     MPS . A :     MPS . T : 8 MPS',10,189,207,icolo,ownseg,0,1);
str(round(mpscost*0.01*basmp[grp,pln]),s);
fastfont(s,37,189,1,icolo,ownseg,0,1);
str(round(mpscosta*0.01*basmp[grp,pln]),s);if(mpscosta=0)then s:='-  ';
fastfont(s,122,189,1,icolo,ownseg,0,1);
end;

if(weaptype=3)then begin fastfont('M :     MPS . T : 8 MPS',10,189,207,icolo,ownseg,0,1);
str(round(mpscost*0.01*basmp[grp,pln]),s);
fastfont(s,37,189,1,icolo,ownseg,0,1);end;

if(weaptype=4)then begin fastfont('Priming time :     MPS . T : 8 MPS',10,189,207,icolo,ownseg,0,1);
str(round(mpscost*0.01*basmp[grp,pln]),s);
fastfont(s,100,189,1,icolo,ownseg,0,1);end;

end;

if(invtype[grp,pln,line]>=101)and(invtype[grp,pln,line]<=200)then begin
fastfont('Reload time : 10 MPS . T : 8 MPS',10,189,207,icolo,ownseg,0,1);
end;

if(invtype[grp,pln,line]>=201)and(invtype[grp,pln,line]<=250)then begin
fastfont('Usage time : 15 MPS . T : 8 MPS',10,189,207,icolo,ownseg,0,1);
end;

if(invtype[grp,pln,line]>=251)and(invtype[grp,pln,line]<=253)then begin
fastfont('T : 8 MPS                      ',10,189,207,icolo,ownseg,0,1);
end;

str(mps[grp,pln],s);if(mps[grp,pln]<10)then insert('  ',s,1);
if(mps[grp,pln]<100)and(mps[grp,pln]>=10)then insert(' ',s,1);
fastfont(s,280,20,207,icolo,ownseg,0,1);
for wo:=14 to 23 do for c3:=21 to 183 do mem[ownseg:c3*320+wo]:=icolo;
if(rarm[grp,pln]<>larm[grp,pln])and(rarm[grp,pln]<>0)then fastfont('R',14,10+rarm[grp,pln]*11,1,icolo,ownseg,0,1);
if(rarm[grp,pln]<>larm[grp,pln])and(larm[grp,pln]<>0)then fastfont('L',14,10+larm[grp,pln]*11,1,icolo,ownseg,0,1);
if(rarm[grp,pln]=larm[grp,pln])and(rarm[grp,pln]<>0)and(larm[grp,pln]<>0)then
fastfont('B',14,10+rarm[grp,pln]*11,1,icolo,ownseg,0,1);

point(35,9+(line*11),168,19+(line*11),15);
wipe(ownseg,$a000,0,0,16000);
point(35,9+(line*11),168,19+(line*11),icolo);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#72)and(line>1)then begin dec(line);play('tick.svs',10000);end;
if(c1=#80)and(line<e)then begin inc(line);play('tick.svs',10000);end;

if(c1=#19)and(lochps[grp,pln,3]>=1)then begin
if(rarm[grp,pln]=larm[grp,pln])and(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+32]=2)and
(invtype[grp,pln,rarm[grp,pln]]>=1)and(invtype[grp,pln,rarm[grp,pln]]<=100)and(line<>rarm[grp,pln])then larm[grp,pln]:=0;

if(rarm[grp,pln]=larm[grp,pln])and(mem[wepseg:(invtype[grp,pln,line]-1)*59+32]=1)and
(invtype[grp,pln,rarm[grp,pln]]>=1)and(invtype[grp,pln,rarm[grp,pln]]<=100)and(line=rarm[grp,pln])then larm[grp,pln]:=0;

if(rarm[grp,pln]=larm[grp,pln])and(invtype[grp,pln,rarm[grp,pln]]>=101)and(invtype[grp,pln,rarm[grp,pln]]<=253)and
(line=rarm[grp,pln])then larm[grp,pln]:=0;

if(mem[wepseg:(invtype[grp,pln,line]-1)*59+32]=1)and(invtype[grp,pln,line]>=1)and(invtype[grp,pln,line]<=100)and
(mps[grp,pln]>=6)and(rarm[grp,pln]<>line)then begin rarm[grp,pln]:=line;dec(mps[grp,pln],6);end;

if(mem[wepseg:(invtype[grp,pln,line]-1)*59+32]=2)and(invtype[grp,pln,line]>=1)and(invtype[grp,pln,line]<=100)
and(lochps[grp,pln,4]>=1)and(mps[grp,pln]>=10)and(rarm[grp,pln]<>line)
then begin rarm[grp,pln]:=line;larm[grp,pln]:=line;dec(mps[grp,pln],10);end;

if(invtype[grp,pln,line]>=101)and(invtype[grp,pln,line]<=253)and(mps[grp,pln]>=6)and(rarm[grp,pln]<>line)then
begin rarm[grp,pln]:=line;dec(mps[grp,pln],6);end;
end;

if(c1=#38)and(lochps[grp,pln,4]>=1)then begin
if(rarm[grp,pln]=larm[grp,pln])and(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+32]=2)and
(invtype[grp,pln,rarm[grp,pln]]>=1)and(invtype[grp,pln,rarm[grp,pln]]<=100)and(line<>rarm[grp,pln])then rarm[grp,pln]:=0;

if(rarm[grp,pln]=larm[grp,pln])and(mem[wepseg:(invtype[grp,pln,line]-1)*59+32]=1)and
(invtype[grp,pln,rarm[grp,pln]]>=1)and(invtype[grp,pln,rarm[grp,pln]]<=100)and(line=rarm[grp,pln])then rarm[grp,pln]:=0;

if(rarm[grp,pln]=larm[grp,pln])and
(invtype[grp,pln,rarm[grp,pln]]>=101)and(invtype[grp,pln,rarm[grp,pln]]<=253)and(line=rarm[grp,pln])then rarm[grp,pln]:=0;

if(mem[wepseg:(invtype[grp,pln,line]-1)*59+32]=1)and(invtype[grp,pln,line]>=1)and(invtype[grp,pln,line]<=100)
and(mps[grp,pln]>=6)and(larm[grp,pln]<>line)then begin larm[grp,pln]:=line;dec(mps[grp,pln],6);end;

if(mem[wepseg:(invtype[grp,pln,line]-1)*59+32]=2)and(invtype[grp,pln,line]>=1)and(invtype[grp,pln,line]<=100)and
(lochps[grp,pln,3]>=1)and(mps[grp,pln]>=10)and(rarm[grp,pln]<>line)
then begin rarm[grp,pln]:=line;larm[grp,pln]:=line;dec(mps[grp,pln],10);end;

if(invtype[grp,pln,line]>=101)and(invtype[grp,pln,line]<=253)and(mps[grp,pln]>=6)and(larm[grp,pln]<>line)then
begin larm[grp,pln]:=line;dec(mps[grp,pln],6);end;

end;

if(c1=#28)and(lochps[grp,pln,3]+lochps[grp,pln,4]>=1)and(invtype[grp,pln,line]>=1)and(invtype[grp,pln,line]<=100)
and(mps[grp,pln]>=10)then begin rel:=false;for i:=1 to 15 do
if((invtype[grp,pln,i]-100)=invtype[grp,pln,line])and(rel=false)and(invammo[grp,pln,i]>=1)then begin
invammo[grp,pln,line]:=invammo[grp,pln,i];invammo[grp,pln,i]:=0;
play('reload.svs',10000);
rel:=true;drop(grp,pln,i,true);end;
if(rel=true)then begin if(invtype[grp,pln,line]=0)then dec(line);upscre;dec(mps[grp,pln],10);end;end;

if(c1=#32)and(mps[grp,pln]>=4)and(lochps[grp,pln,3]+lochps[grp,pln,4]>=1)and(invtype[grp,pln,line]<>0)then begin
dec(mps[grp,pln],4);if(invtype[grp,pln,line]>=251)and(invtype[grp,pln,line]<=253)then invammo[grp,pln,line]:=1;
drop(grp,pln,line,false);dropuse:=1;if(line>1)then dec(line);upscre;end;

if(c1=#25)then begin readwep(invtype[grp,pln,line]); if(mem[wepseg:((invtype[grp,pln,line]-1)*59+1)]=4)and
(lochps[grp,pln,3]+lochps[grp,pln,4]>=1)and
(mps[grp,pln]>=round(mpscost*0.01*basmp[grp,pln]))and(invprime[grp,pln,line]=0)then begin

for wo:=0 to teams do ok[wo]:=0;
for wo:=0 to teams do
for i:=1 to warriors do if(dead[wo,i]=false)then ok[wo]:=1;

for wo:=0 to teams do if(ok[wo]=1)then plast:=wo;  { Get the last group }

fastfont('Prime: After    turns,        player.',10,189,207,icolo,ownseg,0,1);
pst[0]:='blue  ';pst[1]:='red   ';pst[2]:='green ';pst[3]:='yellow';
pcol[0]:=10;pcol[1]:=11;pcol[2]:=12;pcol[3]:=15;

pturn:=0;pgrp:=grp;

repeat
str(pturn,s);if(pturn<10)then insert(' ',s,1);
fastfont(s,87,189,1,icolo,ownseg,0,0);
fastfont(pst[pgrp],147,189,pcol[pgrp],icolo,ownseg,0,0);
wipe(ownseg,$a000,57600,57600,1600);

ch:=readk;

if(ch=#75)then if(pturn>0)or(pgrp>grp)then begin
repeat
if(pgrp<=0)then begin pgrp:=3;dec(pturn);end else dec(pgrp);
until(ok[pgrp]=1);
end;

if(ch=#77)then if(pturn<20)or(pgrp<plast)then begin
repeat
if(pgrp>=3)then begin pgrp:=0;inc(pturn);end else inc(pgrp);
until(ok[pgrp]=1);
end;

until(ch=#28)or(ch=#1);
fastfont('                                    ',10,189,207,icolo,ownseg,0,1);
if(ch=#28)then begin inc(eprimed[grp]);
invprime[grp,pln,line]:=4*pturn+pgrp-grp+1;
play('prime.svs',12000);
dec(mps[grp,pln],round(mpscost*0.01*basmp[grp,pln]));
end;
upscre;end;
end;

until(c1=#1)or(e=0);if(dropuse=1)then calclights;
for wo:=0 to 767 do begin sofpal[wo]:=defpal[wo];defpal[wo]:=0;end;
fade(4);init(1);
end else begin
inftxt('No items in your inventory.     ',15,1,0);inftxt(cle,0,2,0);
ch:=readk;ch:=#0;end;see;drawmap;
end;



procedure shoot;
label beg;
var double,handok,osuma,misc,ent,newp,loppu,nosh:boolean;
    ftime,svis1,svis2,koh,sx,sy,range,shman,shgrp,nx,ny,cguy,totguy:byte;
    armhp,chohi,atchohi,tchohi:integer;
    tgx,tgy:shortint;
    sholight:byte;
    guy:array[1..warriors*4] of byte;
    guygrp:array[1..warriors*4] of byte;

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

procedure hit(lopx,lopy:byte);  { BEGIN OF HIT PROCEDURE }
var tdam,dam,trans,hitran,hitpla,hpla,dg,dn,buc:integer;mandead:boolean;
    place,dcol,notext,cpug,la,damb:byte;
    hitp:word;
    temhps:integer;

begin
cpug:=1;
if(guard=true)and(control[grp]=1)then cpug:=0;
if(guard=true)and(control[guardgrp]=1)and(hucount<2)then cpug:=0;
if(guard=false)then cpug:=0;

pntr:=false;
mandead:=false;trans:=0;dam:=0;
if(weaptype=1)then begin dam:=ydam+random(xdam);if(xdam>0)then inc(dam);end;
if(weaptype=2)then begin for buc:=1 to burs do inc(dam,(ydam+random(xdam)));
if(xdam>0)then inc(dam,1);
end;
for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=lopx)and(ply[a,i]=lopy)then
if(dead[a,i]=false)and(ent=false)then begin dg:=a;dn:=i;mandead:=true;end;
if(mandead=true)and(sholight=0)then begin
cx:=lopx-4;cy:=lopy-3;
ico:=false;pntr:=false;
if(cpug=0)or(debug=1)then begin

if(fastmode=false) then begin
drawmap;effect(16,1);
end;
if(fastmode=true) then begin
drawmap;effect(16,4);
end;

end;
begin hitran:=random(16)+1;koh:=19;

damb:=random(100)+1;
if(damb>=97)and(damb<=99)and(mandead=true)then
begin
dam:=round(dam*1.5);
if(cpug=0)then begin
if(fastmode=false) then begin inftxt('A severe hit. 150% damage !     ',2,1,0);
repeat ch:=readk;until ch=#28;
end;
end;
end;
if(damb=100)and(mandead=true)and(cpug=0)then
begin
dam:=round(dam*2);
if(cpug=0)then begin
if(fastmode=false) then begin inftxt('A critical hit. 200% damage !   ',2,1,0);
repeat ch:=readk;until ch=#28;
end;
end;
end;

if(aim=true)then hitran:=aimpla;
if(hitran=1)then begin hitpla:=1;koh:=8;if(cpug=0)then s:='Head ';place:=5;end;
if(hitran=2)or(hitran=3)or(hitran=4)or(hitran=5)or(hitran=6)then begin hitpla:=2;koh:=28;if(cpug=0)then s:='Chest ';
place:=6;end;
if(hitran=7)or(hitran=8)then begin hitpla:=3;koh:=16;if(cpug=0)then s:='Right arm ';place:=10;end;
if(hitran=9)or(hitran=10)then begin hitpla:=4;koh:=16;if(cpug=0)then s:='Left arm ';place:=9;end;
if(hitran=11)or(hitran=12)or(hitran=13)then begin hitpla:=5;koh:=16;if(cpug=0)then s:='Right leg ';place:=10;end;
if(hitran=14)or(hitran=15)or(hitran=16)then begin hitpla:=6;koh:=16;if(cpug=0)then s:='Left leg ';place:=9;end;

if(hitpla>2)and(lochps[dg,dn,hitpla]=0)then notext:=1 else notext:=0;

tdam:=dam-locaps[dg,dn,hitpla];
temhps:=lochps[dg,dn,hitpla]-tdam;
if temhps<0 then temhps:=0;
hitp:=round(temhps/((tothps[dg,dn]*koh)/100)*100);
if(lochps[dg,dn,hitpla])=0 then hitp:=200;

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
if(cpug=0)and(fastmode=false)then if(hitpla<>2)or(hitp>0)then inftxt(s,dcol,2,0) else place:=0;
if(cpug=0)and(fastmode=false)then inftxt(s1,dcol,2,place);

str(dam,s);
if(cpug=0)and(fastmode=false)then begin inftxt('Damage caused :                 ',15,1,0);inftxt(s,15,1,17);
repeat ch:=readk;until ch=#28;end;

if tdam>0 then begin
if(guard=false)and(dg<>grp)then inc(penet[grp],tdam);
if(guard=true)and(dg<>guardgrp)then inc(penet[guardgrp],tdam);

end;

if(tdam<0)then tdam:=0;dec(lochps[dg,dn,hitpla],tdam);
dec(locaps[dg,dn,hitpla],round(dam/5));if locaps[dg,dn,hitpla]<0 then locaps[dg,dn,hitpla]:=0;
if(lochps[dg,dn,hitpla]<=0)then begin
trans:=-lochps[dg,dn,hitpla];lochps[dg,dn,hitpla]:=0;
if(trans>0)and(hitpla>2)then begin
temp1:=trans-locaps[dg,dn,2];if temp1<0 then temp1:=0;dec(lochps[dg,dn,2],temp1);
if lochps[dg,dn,2]<0 then lochps[dg,dn,2]:=0;
dec(locaps[dg,dn,2],round(trans/5));if locaps[dg,dn,2]<0 then locaps[dg,dn,2]:=0;
str(trans,s);


if(lochps[dg,dn,1]>0)and(lochps[dg,dn,2]<1)and(cpug=0)then begin
if fastmode=false then begin
inftxt('He''s down !                   ',2,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until ch=#28;end;
end;

end;end;
if(lochps[dg,dn,1]<=0)or(lochps[dg,dn,2]<=0)then begin
dead[dg,dn]:=true;
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
pntr:=false;
if(cpug=0)or(debug=1)then drawmap;

if(dead[dg,dn]=true)then begin for by1:=1 to 15 do if(invtype[dg,dn,1]<>0)then drop(dg,dn,1,false);
play('death.svs',10000);
if(cpug=0)or(debug=1)then
begin
if(fastmode=false) then effect(17,1) else effect(17,4);
end;

end;
if(cpug=0)and(fastmode=false)then begin inftxt(cle,0,1,0);inftxt(cle,0,2,0);end;
end;

if sholight<>0 then        { Aiming at light }
for la:=1 to lightamo do
if(lightsx[la]=lopx)and(lightsy[la]=lopy)and(lightst[la]>0)and(lightst[la]<=3)
then begin
lightsx[la]:=0;
lightsy[la]:=0;
lightst[la]:=0;
if la=lightamo then dec(lightamo);
ico:=false;cx:=lopx-4;cy:=lopy-3;
pntr:=false;drawmap;broken:=1;
if(weaptype=1)then effect(239,2) else effect(96,1);
end;                       { Aiming at light }


if(mandead=false)and(sholight=0)then begin ico:=false;cx:=lopx-4;cy:=lopy-3;pntr:=false;
if(cpug=0)or(debug=1)then begin drawmap;

if(fastmode=false) then begin
if(weaptype=1)then effect(239,2)
else effect(96,1);
end else
begin
if(weaptype=1)then effect(239,4)
else effect(96,2);
end;

end;

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
pntr:=false;
if(cpug=0)or(debug=1)then drawmap;wait(1);
end;    { END OF HIT PROCEDURE }

begin
broken:=0;sholight:=0;
armhp:=0;hitbon:=0;shable:=false;shooted:=false;handok:=true;vali:=false;
shman:=pln;shgrp:=grp;
if(guard=true)then shman:=e;if(guard=true)then shgrp:=guardgrp;
if(guard=false)then begin { Guard begin }

if(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]>2)and
(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]>2)and

(vali=false)and(handok=true)and(invammo[grp,pln,islo]<1)then begin
handok:=false;inftxt('No weapons in your hands.      ',15,1,0);inftxt(cle,0,2,0);ch:=readk;inftxt(cle,0,1,0);vali:=true;end;

if(vali=false)and(lochps[grp,pln,3]<1)and(lochps[grp,pln,4]<1) then begin
shooted:=false;handok:=false;inftxt(cle,0,2,0); { Both hands Damaged }
vali:=true;inftxt('Your hands are too damaged.     ',2,1,0);repeat ch:=readk;until ch=#28;inftxt(cle,0,1,0);end;

if(lochps[grp,pln,3]>0)and { Rightarm OK }

(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]<=2)and

(invtype[grp,pln,rarm[grp,pln]]>0)and(invtype[grp,pln,rarm[grp,pln]]<=100)then begin
handc:=invtype[grp,pln,rarm[grp,pln]];shable:=true;islo:=rarm[grp,pln];armhp:=lochps[grp,pln,3];end;

if(lochps[grp,pln,4]>0)and { Leftarm OK }

(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]<=2)and

(invtype[grp,pln,larm[grp,pln]]>0)and(invtype[grp,pln,larm[grp,pln]]<=100)then begin
handc:=invtype[grp,pln,larm[grp,pln]];shable:=true;islo:=larm[grp,pln];armhp:=lochps[grp,pln,4];end;

if(lochps[grp,pln,3]>0)and(lochps[grp,pln,4]>0)and(rarm[grp,pln]<>larm[grp,pln])and
(invtype[grp,pln,rarm[grp,pln]]>0)and(invtype[grp,pln,rarm[grp,pln]]<=100)and
(invtype[grp,pln,larm[grp,pln]]>0)and(invtype[grp,pln,larm[grp,pln]]<=100)and
(mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]<=2)and(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]<=2)
then begin
inftxt('Which hand to shoot with ?      ',15,1,0);
inftxt('(r)ight or (l)eft hand          ',15,2,0);
repeat ch:=readk;until (ch=#38)or(ch=#19); { Two different weapons }
if ch=#19 then begin handc:=invtype[grp,pln,rarm[grp,pln]];islo:=rarm[grp,pln];armhp:=lochps[grp,pln,3];end;
if ch=#38 then begin handc:=invtype[grp,pln,larm[grp,pln]];islo:=larm[grp,pln];armhp:=lochps[grp,pln,4];end;
shable:=true;end;

if(handok=true)and(vali=false)and(rarm[grp,pln]=larm[grp,pln])then
if(lochps[grp,pln,3]=0)or(lochps[grp,pln,4]=0)then begin
inftxt('Your hand is too badly damaged. ',2,1,0);handok:=false;vali:=true;
repeat ch:=readk;until ch=#28;inftxt(cle,0,1,0); {Too much damage 2 hand wep}
end;

if(vali=false)and(handok=true)then
if(rarm[grp,pln]=0)and(larm[grp,pln]=0)or
(invtype[grp,pln,rarm[grp,pln]]>100)and(invtype[grp,pln,larm[grp,pln]]>100)
or((mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+1]>2)and
(mem[wepseg:(invtype[grp,pln,larm[grp,pln]]-1)*59+1]>2))

then begin
inftxt('No weapons in your hands.',15,1,0);handok:=false;shable:=true;vali:=true;ch:=readk;inftxt(cle,0,1,0);end;
{ No weapons }

hitbon:=-15;
if(rarm[grp,pln]=larm[grp,pln])and(lochps[grp,pln,3]>0)and(lochps[grp,pln,4]>0)and
(invtype[grp,pln,rarm[grp,pln]]>0)and(invtype[grp,pln,rarm[grp,pln]]<=100)and
(invtype[grp,pln,larm[grp,pln]]>0)and(invtype[grp,pln,larm[grp,pln]]<=100)then begin
{if mem[wepseg:(invtype[grp,pln,rarm[grp,pln]]-1)*59+32]=1 then hitbon:=0;}
hitbon:=0;
handc:=invtype[grp,pln,rarm[grp,pln]];shable:=true;islo:=rarm[grp,pln];end; { 2 handed weapon }
if shable=false then handok:=false;

readwep(handc);  { Get weapon data }

if(vali=false)then if
(lochps[grp,pln,3]<1)and(invtype[grp,pln,larm[grp,pln]]>100)or
(lochps[grp,pln,3]<1)and(invtype[grp,pln,larm[grp,pln]]=0)or
(lochps[grp,pln,4]<1)and(invtype[grp,pln,rarm[grp,pln]]>100)or
(lochps[grp,pln,4]<1)and(invtype[grp,pln,rarm[grp,pln]]=0)then begin
inftxt('Your hand is too badly damaged. ',2,1,0);handok:=false;vali:=true;
repeat ch:=readk;until ch=#28;inftxt(cle,0,1,0);
end;

if(invammo[grp,pln,islo]<1)and
(invtype[grp,pln,islo]<=100)and
(mem[wepseg:(invtype[grp,pln,islo]-1)*59+1]<=2)and
(handok=true)and(vali=false)then
begin handok:=false;inftxt('Out of ammo.                   ',15,1,0);inftxt(cle,0,2,0);ch:=readk;inftxt(cle,0,1,0);end;

if(mps[grp,pln]<round(basmp[grp,pln]*mpscost*0.01))then
begin
handok:=false; { Enough mps }
mpsflash;
end;

end; { Guard }

if(handok=true)then begin
sx:=plx[grp,pln];sy:=ply[grp,pln];
ix:=plx[grp,pln];iy:=ply[grp,pln];

if(targ[grp,pln]<>0)and(dead[targgrp[grp,pln],targ[grp,pln]]=false)and
(insi[targgrp[grp,pln],targ[grp,pln]]=true)and(guard=false)then begin
liofsi(plx[grp,pln],ply[grp,pln],plx[targgrp[grp,pln],targ[grp,pln]],ply[targgrp[grp,pln],targ[grp,pln]]);

sect:=false;

if(secheck(plx[grp,pln],ply[grp,pln],
plx[targgrp[grp,pln],targ[grp,pln]],ply[targgrp[grp,pln],targ[grp,pln]],
fc[grp,pln])=1)then sect:=true else sect:=false;

if(liosi=true)and(sect=true)then begin ix:=plx[targgrp[grp,pln],targ[grp,pln]];iy:=ply[targgrp[grp,pln],targ[grp,pln]];end;
end;

if guard=true then begin lioma:=true;sx:=plx[guardgrp,e];sy:=ply[guardgrp,e];end; { Guard }
beg:
shooted:=false;if guard=false then rapid:=false;
nosh:=false;sect:=false;chohi:=50;ent:=false;aimch:=true;
pntr:=false;loppu:=false;
if guard=true then begin aimch:=false;sect:=true;end; { Guard }

if guard=false then begin  { Guard begin }

totguy:=0;cguy:=1;
for wo:=1 to warriors do guy[wo]:=0;
for i:=0 to teams do if(ally[i]<>ally[grp])then
for wo:=1 to gr[i] do begin
liofsi(plx[grp,pln],ply[grp,pln],plx[i,wo],ply[i,wo]);
if(insi[i,wo]=true)and(liosi=true)and(dead[i,wo]=false)and(escaped[i,wo]=false)
and(secheck(plx[grp,pln],ply[grp,pln],plx[i,wo],ply[i,wo],fc[grp,pln])=1)then
begin inc(totguy);guy[totguy]:=wo;
guygrp[totguy]:=i;
end;
end;

icol:=242;
{inftxt('Choose your target.             ',15,1,0);}
inftxt('Acc. S.:      Acc. Auto:        ',15,1,0);


if totguy>0 then begin
str(totguy,s);
inftxt('Space: Next enemy ('+s+')       ',15,2,0);
end else
inftxt(cle,0,2,0);
ftime:=0;
sx:=plx[grp,pln];
sy:=ply[grp,pln];

repeat

range:=round(sqrt(sqr(ix-sx)+sqr(iy-sy)));
re:=(lochps[grp,pln,3]/(tothps[grp,pln]*0.16));
if mem[wepseg:(invtype[grp,pln,islo]-1)*59+32]=1 then
re:=(armhp/(tothps[grp,pln]*0.16)) else
re:=((lochps[grp,pln,3]+lochps[grp,pln,4])/(tothps[grp,pln]*0.32));
if re>1 then re:=1;

tchohi:=round(((accuracy+firaccu[grp,pln])/2)-((accufact/10)*(range-1)))+hitbon;
if tchohi>round((accuracy+firaccu[grp,pln])/2)+hitbon then tchohi:=round((accuracy+firaccu[grp,pln])/2)+hitbon;
atchohi:=tchohi;
tchohi:=round(tchohi*re);
dec(tchohi,round(crange(sx,sy,ix,iy)*((11-lightmap[ix,iy])div 2)));
if tchohi<1 then tchohi:=1;if tchohi>98 then tchohi:=99;
str(tchohi,s);

if(secheck(plx[grp,pln],ply[grp,pln],ix,iy,fc[grp,pln])=0)or
(visiofsi(plx[grp,pln],ply[grp,pln],ix,iy)=0)then inftxt('-   ',14,1,9) else
inftxt(s+'%  ',14,1,9);

dec(atchohi,round(accuracy*0.2));atchohi:=round(atchohi*re);
dec(atchohi,round(crange(sx,sy,ix,iy)*((11-lightmap[ix,iy])div 2)));
if atchohi<1 then atchohi:=1;if atchohi>98 then atchohi:=99;
str(atchohi,s);

if(secheck(plx[grp,pln],ply[grp,pln],ix,iy,fc[grp,pln])=0)or
(visiofsi(plx[grp,pln],ply[grp,pln],ix,iy)=0)or(mpscosta=0)then
inftxt('-   ',14,1,25) else inftxt(s+'%  ',14,1,25);

s:='           ';

for wo:=0 to teams do
for i:=1 to warriors do
if(insi[wo,i]=true)and
(dead[wo,i]=false)and(plx[wo,i]=ix)and(ply[wo,i]=iy)and((wo<>grp)or(i<>pln))then
if(ally[wo]=ally[grp])then begin
s:='-FRIENDLY- ';a:=3;end else begin
s:=' -ENEMY-   ';a:=7;end;

inftxt(s,a,1,30);


cx:=ix-4;cy:=iy-3;ico:=true;pntr:=false;drawmap;ch:=readk;
case ch of
#77:if ix<mapx then begin if cx<98 then if ((ix-cx)-(iy-cy)>7) or ((ix-cx)+(iy-cy)>13) then cx:=cx+1;ix:=ix+1;end;
#75:if ix>1 then begin if cx>-3 then if ((ix-cx)-(iy-cy)<-5) or ((ix-cx)+(iy-cy)<1) then cx:=cx-1;ix:=ix-1;end;
#72:if iy>1 then begin if cy>-3 then if ((ix-cx)-(iy-cy)>7) or ((ix-cx)+(iy-cy)<1) then cy:=cy-1;iy:=iy-1;end;
#80:if iy<mapy then begin if cy<98 then if ((ix-cx)-(iy-cy)<-5) or ((ix-cx)+(iy-cy)>13) then cy:=cy+1;iy:=iy+1;end;
#57:if(totguy>0)then begin
if(ftime=0)and(guygrp[cguy]=targ[grp,pln])and(guy[cguy]=targ[grp,pln])and(totguy>1)then inc(cguy);
ftime:=1;
tgx:=plx[guygrp[cguy],guy[cguy]]-4;
tgy:=ply[guygrp[cguy],guy[cguy]]-3;
cx:=ix-4;
cy:=iy-3;
repeat
if cx<tgx then inc(cx);
if cx>tgx then dec(cx);
if cy<tgy then inc(cy);
if cy>tgy then dec(cy);
ix:=cx+4;
iy:=cy+3;

pntr:=false;drawmap;
wait(1);

until(cx=tgx)and(cy=tgy);
inc(cguy);
if(cguy>totguy)then cguy:=1;end;
end; {next guy}
icol:=242;
if lightamo>0 then
for wo:=1 to lightamo do if(lightsx[wo]=ix)and(lightsy[wo]=iy)and
(lightst[wo]>0)and(lightst[wo]<=3)then icol:=2;
until (ch=#28)or(ch=#1);
inftxt('           ',15,1,30);

if ch=#1 then begin loppu:=true;sect:=false;end;

if(loppu=false)and(plx[grp,pln]=ix)and(ply[grp,pln]=iy)then loppu:=true;

if loppu=false then begin

for i:=0 to teams do for a:=1 to warriors do
if(plx[i,a]=ix)and(ply[i,a]=iy)and(dead[i,a]=false)and(insi[i,a]=true)
then begin targ[grp,pln]:=a;targgrp[grp,pln]:=i;end;

sect:=false;
if(secheck(plx[grp,pln],ply[grp,pln],ix,iy,fc[grp,pln])=1)then sect:=true else sect:=false;
end;

if(sect=true)and(loppu=false)then begin
liofsi(plx[grp,pln],ply[grp,pln],ix,iy);
if(visiman(plx[grp,pln],ply[grp,pln],ix,iy,grp)=1)then lioma:=false else lioma:=true;
end;

if(sect=true)then
if(liosi=false)or(lioma=false)then begin
inftxt('Target out of sight.            ',15,1,0);
inftxt('To shoot anyway, press enter.   ',15,2,0);
ch:=readk;if ch=#28 then begin liosi:=true;lioma:=true;aimch:=false;end
else loppu:=true;end;

{ Autofire Check }
if(mpscosta<>0)and(weaptype=1)and(sect=true)and(invammo[grp,pln,islo]>=2)then begin
rare1:=(mpscost*0.01)*basmp[grp,pln];rare2:=(mpscosta*0.01)*basmp[grp,pln];
maxfi:=round((mps[grp,pln]-rare1)/rare2);if maxfi>invammo[grp,pln,islo] then maxfi:=invammo[grp,pln,islo];
if(maxfi>1)and(loppu=false)then begin inftxt('Do you want to use autofire ?   ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then loppu:=true;
if ch=#21 then begin
rafi:=2;rapid:=true;
inftxt('Use arrows to choose how many   ',15,1,0);
inftxt('rounds to fire :                ',15,2,0);
repeat
str(rafi,s);s:=s+'  '; inftxt(s,15,2,18);
ch:=readk;
if(ch=#75)and(rafi>2)then dec(rafi);
if(ch=#77)and(rafi<maxfi)then inc(rafi);
if ch=#1 then loppu:=true;
until(ch=#28)or(ch=#1);
end;end;end;{ Autofire Check }

burs:=1;if(mps[grp,pln]>=basmp[grp,pln]*mpscost*0.01)and(burst>1)and(weaptype=2)and(sect=true)
and(invammo[grp,pln,islo]>1) then begin
if(loppu=false)then begin
{inftxt('Do you want to use multifire ?',15,1,0);inftxt(cle,0,2,0);}
{repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then loppu:=true;
if ch=#21 then begin}
inftxt('Use arrows to choose how many   ',15,1,0);
inftxt('Charges to fire :               ',15,2,0);
repeat
str(burs,s);s:=s+'  '; inftxt(s,15,2,19);
ch:=readk;
if(ch=#75)and(burs>1)then dec(burs);
if(ch=#77)and(burs<burst)and(burs<invammo[grp,pln,islo])then inc(burs);
if ch=#1 then loppu:=true;
until(ch=#28)or(ch=#1);
{end;}
end;end;{ Autofire Check }

end; { Guard end }


if(loppu=false)and(sect=true)and(liosi=true)and(lioma=true)then begin
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
if chohi>round((accuracy+firaccu[grp,pln])/2)+hitbon then chohi:=round((accuracy+firaccu[grp,pln])/2)+hitbon;
if rapid=true then dec(chohi,round(accuracy*0.2));chohi:=round(chohi*re);

dec(chohi,round(crange(sx,sy,ix,iy)*((11-lightmap[ix,iy])div 2)));

if chohi<1 then chohi:=1;if chohi>98 then chohi:=99;
aim:=false;double:=false;

if(exprad=1)and(mps[grp,pln]>=round(1.5*(mpscost*0.01)*basmp[grp,pln]))
and(aimch=true)and(rapid=false)then
for a:=0 to teams do for i:=1 to gr[a] do
if(plx[a,i]=ix)and(ply[a,i]=iy)and(dead[a,i]=false)then
{enough light?}
if crange(sx,sy,ix,iy)*(11-lightmap[ix,iy])+((11-lightmap[ix,iy])*5)<90 then

begin inftxt('Do you want to aim ?           ',15,1,0);
inftxt('(a)im, (esc)skip aiming.      ',15,2,0);
repeat ch:=readk;until(ch=#1)or(ch=#30);
if ch=#30 then begin
inftxt('(1)head, (2)chest, (3)r.arm   ',15,1,0);
inftxt('(4)l.arm, (5)r.leg, (6)l.leg  ',15,2,0);
double:=true;aim:=true;aimpla:=0;
repeat
ch:=readk;
case ch of
#2:begin dec(chohi,40);aimpla:=1;end;
#3:begin dec(chohi,15);aimpla:=2;end;
#4:begin dec(chohi,25);aimpla:=7;end;
#5:begin dec(chohi,25);aimpla:=9;end;
#6:begin dec(chohi,25);aimpla:=11;end;
#7:begin dec(chohi,25);aimpla:=14;end;
end;until aimpla<>0;
end;end;
if chohi<1 then chohi:=1;

if(aim=false)and(exprad=1)and(mps[grp,pln]>=round(1.5*(mpscost*0.01)*basmp[grp,pln]))
and(aimch=true)and(rapid=false)then
for a:=1 to lightamo do
if(lightsx[a]=ix)and(lightsy[a]=iy)and(lightst[a]>0)and(lightst[a]<=3)then
{enough light?}
if crange(sx,sy,ix,iy)*(11-lightmap[ix,iy])+((11-lightmap[ix,iy])*5)<90 then
begin inftxt('Do you want to aim at light ? ',15,1,0);
inftxt('(a)im, (esc)skip aiming.      ',15,2,0);
repeat ch:=readk;until(ch=#1)or(ch=#30);
if ch=#30 then begin
inftxt(cle,15,1,0);
inftxt(cle,15,2,0);
sholight:=a;
dec(chohi,20);
double:=true;
inftxt(cle,15,1,0);
inftxt(cle,15,2,0);
end;
end;

misc:=false;
if guard=false then begin { Guard check }
inftxt('Chances to hit are :   % >    < ',15,1,0);
inftxt('Press esc to skip shooting.   ',15,2,0);
str(chohi,s);inftxt(s,15,1,21);
ch:=readk;if ch=#1 then misc:=true;
inftxt(cle,0,2,0);
end; { Guard }
if misc=true then begin inftxt(cle,0,1,0);inftxt(cle,0,2,0);end else begin

if(rapid=true)and(guard=false)and(fastmode=false)
then begin cx:=plx[grp,pln]-4;cy:=ply[grp,pln]-3;
ico:=false;pntr:=false;drawmap;
end;

if(rapid=false)then rafi:=1;
for rcn:=1 to rafi do begin
if(guard=false)then if(shman<>pln)or(dead[grp,shman]=true)or(shgrp<>grp)then loppu:=true;
if(guard=true)then if(dead[guardgrp,shman]=true)then loppu:=true;
if(loppu=false)then begin
if(guard=false)then inc(shots[grp]);if(guard=true)then inc(shots[guardgrp]);

if(rapid=true)and(guard=false)then
if(fastmode=false) then
begin
inftxt('Chances to hit are :   % >    < ',15,1,0);
str(chohi,s);inftxt(s,15,1,21);
end else inftxt(cle,15,1,0);

if(loppu=false)then
if(weaptype=2)then
begin
freqi:=20000-((xdam+ydam)*350*burst)+random(200);
play('energy.svs',freqi)
end
else
begin
freqi:=20000-((xdam+ydam)*200)+random(200);
play('shoot.svs',freqi);
end;


a:=1+random(99);
if(guard=false)then begin { Type in the chance of hit if not guarding fire }

if(fastmode=false) then begin
str(a,s);inftxt(s,15,1,27);wait(10);
end;

if(rapid=false)then inftxt(cle,0,1,0);
end;                      { Type in the chance of hit if not guarding fire }

misc:=false;osuma:=false;   { Did we miss or did we hit }
if(a<=chohi)then osuma:=true else aim:=false;
if(sholight<>0)and(osuma=false)then sholight:=0;
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
newp:=false;
vx:=x1;vy:=y1;
px:=x1;py:=y1;

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
if(weaptype=1)and(exprad>1)and(enter[map[px,py]]=false)then begin px:=vpx;py:=vpy;shooted:=true;end;
if(weaptype=1)and(exprad>1)then begin
explosion(px,py,exprad,ydam+random(xdam)+1,expfact);shooted:=true;
pntr:=false;drawmap;wait(1);
end;
if(weaptype<>1)or(exprad=1)then begin hit(px,py);shooted:=true;end;
{ What does the bullet accomplish (landing site in [px,py]) }

{ Quit if the shooter is already dead }
if(pln<>shman)and(guard=false)then loppu:=true;
if(dead[guardgrp,shman]=true)and(guard=true)then loppu:=true;
{ Quit if the shooter is already dead }

{ Removing ammos and movement points }
if(pln=shman)and(guard=false)and(rapid=false)then begin
if(double=false)then dec(mps[grp,pln],round(basmp[grp,pln]*mpscost*0.01)) else
dec(mps[grp,pln],round(1.5*(basmp[grp,pln]*mpscost*0.01)));
if weaptype=1 then dec(invammo[grp,pln,islo],1);
if weaptype=2 then dec(invammo[grp,pln,islo],burs);end;

if(e=shman)and(guard=true)and(rapid=false)then begin
dec(mps[guardgrp,e],round(basmp[guardgrp,e]*mpscost*0.01));
dec(invammo[guardgrp,e,islo],1);end;

if(guard=false)and(pln=shman)and(rapid=true)and(rcn=1)then begin
dec(mps[grp,pln],round(((rafi-1)*((mpscosta*0.01)*basmp[grp,pln]))+(mpscost*0.01*basmp[grp,pln])));
dec(invammo[grp,pln,islo],rafi);end;

if(guard=true)and(e=shman)and(rapid=true)and(rcn=1)then begin
dec(mps[guardgrp,e],round(((rafi-1)*((mpscosta*0.01)*basmp[guardgrp,e]))+(mpscost*0.01*basmp[guardgrp,e])));
dec(invammo[guardgrp,e,islo],rafi);end;
{ Removing ammos and movement points }

{ To be sure that mps>=0 }
if(guard=false)and(mps[grp,pln]<0)then mps[grp,pln]:=0;
if(guard=true)and(mps[guardgrp,e]<0)then mps[guardgrp,e]:=0;

end;end;end;end;   { Some important ends, please do not remove them all }

if(guard=false)then begin { Skip this if shooting came from guarding }
if(sect=false)and(loppu=false)then begin
inftxt(cle,0,2,0);inftxt('Target out of sector.           ',15,1,0);nosh:=true;
wait(20);end;
if(nosh=true)and(loppu=false)then goto beg;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;                      { Skip this if shooting came from guarding }
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
pntr:=true;cnt;
end;end;             { ******** END OF SHOOT ******** }

procedure pguard;
var gran,gt:byte;maxsh:shortint;
begin  { PROC guard }
broken:=0;
for gt:=0 to teams do if(ally[gt]<>ally[grp])then { Every group... }
begin
guardgrp:=gt;
for e:=1 to gr[gt] do if(dead[gt,e]=false)then begin
sect:=false;gran:=random(101);burs:=1;garmhp:=0;allok:=true;shable:=false;

if(lochps[gt,e,3]<1)and(lochps[gt,e,4]<1)then
allok:=false; { Both hands Damaged }

if(lochps[gt,e,4]>0)and { Leftarm OK }
(invtype[gt,e,larm[gt,e]]>0)and(invtype[gt,e,larm[gt,e]]<=100)then begin
handc:=invtype[gt,e,larm[gt,e]];shable:=true;islo:=larm[gt,e];garmhp:=lochps[gt,e,4];end;

if(lochps[gt,e,3]>0)and { Rightarm OK }
(invtype[gt,e,rarm[gt,e]]>0)and(invtype[gt,e,rarm[gt,e]]<=100)then begin
handc:=invtype[gt,e,rarm[gt,e]];shable:=true;islo:=rarm[gt,e];garmhp:=lochps[gt,e,3];end;

if(rarm[gt,e]=larm[gt,e])and(lochps[gt,e,3]=0)or(lochps[gt,e,4]=0)and
(invtype[gt,e,rarm[gt,e]]>0)and(invtype[gt,e,rarm[gt,e]]<=100)and
(invtype[gt,e,larm[gt,e]]>0)and(invtype[gt,e,larm[gt,e]]<=100)then begin
allok:=false; { Too much damage 2 hand wep}
end;

if(rarm[gt,e]=0)and(larm[gt,e]=0)or
(invtype[gt,e,rarm[gt,e]]>100)and
(invtype[gt,e,larm[gt,e]]>100)then
allok:=false; { no weapons }

if(rarm[gt,e]=larm[gt,e])and(lochps[gt,e,3]>0)and(lochps[gt,e,4]>0)and
(invtype[gt,e,rarm[gt,e]]>0)and(invtype[gt,e,rarm[gt,e]]<=100)and
(invtype[gt,e,larm[gt,e]]>0)and(invtype[gt,e,larm[gt,e]]<=100)
then begin handc:=invtype[gt,e,rarm[gt,e]];shable:=true;islo:=rarm[gt,e];end; { 2 handed weapon }
if shable=false then allok:=false;  { 2 handed weapon }
if(invammo[gt,e,islo]<1)then allok:=false;
readwep(handc);

{if(mps[gt,e]>=(round(basmp[gt,e]*mpscost*0.01)))and(allok=true)
and(dead[grp,pln]=false)and(gran<=react[gt,e])then begin
if(secheck(plx[gt,e],ply[gt,e],plx[grp,pln],ply[grp,pln],fc[gt,e])=1)then sect:=true else sect:=false;
end;}
if(secheck(plx[gt,e],ply[gt,e],plx[grp,pln],ply[grp,pln],fc[gt,e])=1)then sect:=true else sect:=false;

if(sect=true) then begin { CHECKING line of sight }
liofsi(plx[gt,e],ply[gt,e],plx[grp,pln],ply[grp,pln]);
if(liosi=true)and(crange(plx[gt,e],ply[gt,e],plx[grp,pln],
ply[grp,pln])*(11-lightmap[plx[grp,pln],ply[grp,pln]])+
((11-lightmap[plx[grp,pln],ply[grp,pln]])*5)<90) then begin
liofman(plx[gt,e],ply[gt,e],plx[grp,pln],ply[grp,pln]);

{ OK, we've seen him, mark him up }

{ marking as the last seen position (always done) }
if(wseen_p^[gt,e,grp,pln,1]=-10) then inc(enseen[gt,e]); {one more enemy}
wseen_p^[gt,e,grp,pln,1]:=plx[grp,pln];
wseen_p^[gt,e,grp,pln,2]:=ply[grp,pln];
wseen_p^[gt,e,grp,pln,3]:=fc[grp,pln];  {current facing}

if(own=false)and(oppor[gt,e]=true)
and(mps[gt,e]>=round(basmp[gt,e]*mpscost*0.01))and(allok=true)
and(dead[grp,pln]=false)and(gran<=react[gt,e])then begin

{if crange(plx[gt,e],ply[gt,e],plx[grp,pln],
ply[grp,pln])*(11-lightmap[plx[grp,pln],ply[grp,pln]])+
((11-lightmap[plx[grp,pln],ply[grp,pln]])*5)<90 then}
begin {light check}

rapid:=false;rafi:=1;
if(mpscosta<>0)then begin
rare1:=(mpscost*0.01)*basmp[gt,e];rare2:=mpscosta*0.01*basmp[gt,e];
maxfi:=round((mps[gt,e]-rare1)/rare2);
if(maxfi>invammo[gt,e,islo])then maxfi:=invammo[gt,e,islo];
rafi:=round(maxfi-(gran/react[gt,e]*maxfi));
if(rafi>1)then rapid:=true;end;

guard:=true;
exgrp:=gt;
expln:=e;
shoot;
guard:=false;
for i:=0 to 128 do begin clear1($a000,i*320,64);clear1(ownseg,i*320,64);end;
end;{light check}
end;end;end;end; { CHECKING line of sight }

end; { every...}
if dead[grp,pln]=true then nguy;
if broken=1 then calclights;
dell;
end; { PROC guard }

end.

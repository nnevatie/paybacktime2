{$F+}
unit varunit;
interface
uses  sbunit;
const tcolo=136;
      bcolo=89;

      bleedc=15;
      hbfac=1.8;
      abfac=1.3;
      lbfac=1.5;

      sco=95;
      teams=3;
      warriors=20;
      routedist=1000;

type
    {1,2=last seen. 3=facing)}
    type_wseen=array[0..teams,1..warriors,0..teams,1..warriors,1..3] of shortint;

var mode:array[0..teams,1..warriors] of byte;
    wiped:array[0..teams] of byte;
    ally:array[0..teams] of byte;
    inhusi:array[0..teams,1..warriors] of boolean;
    wseen_p:^type_wseen;

    filline,huleft:byte;
    weapon_amount,wor1,wor2,wor3:word;

    wic,control,drawable:array[0..teams] of byte;
    routep:array[0..teams,1..warriors] of word;
    friend:array[0..teams,1..warriors] of byte;
    dist:array[0..teams,1..warriors] of word;
    vali,shable,allok,error,nofils,cpush,shooted,raent,rapid,own,moved,guard,aimch,aim,away,meled,pickuped,healed,
    throwed,doped,cpurel,rel,armin,alr,lioma,pntr,ico,free,sect,liosi,fw,lop,scree,tch,snd,explos:boolean;
    stri1,stri2,stri3,s,s1,cle,mapname:string;
    handc,mapx,mapy,aimpla,pn,gn,eis,mc,pln,grp,nu,i,a,tm,e,rcn,by1,islo,icol,mancol,cputemp,
    esced,dropuse,itempd,itemm,lightamo,vari,exgrp,expln,cmline,a1,i1,c2,yda,xda,efa,era:byte;
    ma,ma3,ma4:pointer;
    del,lisa,li1,li2,xtr1,xtr2:longint;
    hitbon,vpx,vpy,ix,iy,x1,x2,y1,y2,cx,cy,si:shortint;
    rare1,rare2,tem,tem2,re,vx,vy,xd,yd,mpc:real;
    grs,plamo,bc,pls,page,a3,i3,dtaseg,dtaofs,filseg,filofs,code,fils,turn,
    cpumpscost,line,wo,wof,c3,c,px,py,fisize,wo1:word;
    guardgrp:byte;
    ownseg,itemseg,wepseg,newseg,oldintseg,oldintofs:word;
    infoseg,gfxseg,minfoseg,mgfxseg,iinfoseg,igfxseg:word;

    ch,c1:char;
    dritem,garmhp,temp1,burs,maxfi,rafi,walldam,doordam:integer;
    f:file;f1:file of byte;
    killed:array[0..teams] of byte;
    plx,ply,fc:array[0..teams,1..warriors] of byte;
    mps:array[0..teams,1..warriors] of integer;
    map:array[-9..109,-9..118] of byte;
    lightmap:array[-10..110,-10..110] of byte;
    preclights:array[1..3,-10..10,-10..10] of byte;

    lightsx:array[1..200] of byte;
    lightsy:array[1..200] of byte;
    lightst:array[1..200] of byte;
    topcol:array[0..255] of byte;

    fcx,fcy:array[0..7] of shortint;
    firable,enter,oply,open,lightable,interable,wall:array[0..80] of boolean;
    wepnam,clnam:string[16];
    weaptype:byte;
    clsize:integer;
    xdam,ydam,accuracy,accufact,expfact,exprad,mpscost,mpscosta,burst,hreq:shortint;

    chosen:array[0..teams,1..20] of boolean;

    gr:array[0..teams] of byte;
    insi:array[0..teams,1..warriors] of boolean;
    gr1:array[0..teams] of byte;
    plnnum:array[0..teams,1..warriors] of byte;
    oppor,escaped,dead:array[0..teams,1..warriors] of boolean;
    lochps,totaps,locaps:array[0..teams,1..warriors,1..6] of integer;
    plname:array[0..teams,1..warriors] of string[16];
    aipatrol,aipatrolx,aipatroly,arminuse,tothps,
    reported,enseen,basmp,react,firaccu,throaccu,melaccu:array[0..teams,1..warriors] of byte;
    aidelay:array[0..teams,1..warriors] of byte;
    xpgain,skpoints,exp:array[0..teams,1..warriors] of longint;
    targ,targgrp,rarm,larm:array[0..teams,1..warriors] of byte;
    bleed,bleeded:array[0..teams,1..warriors] of integer;

    invtype,invprime:array[0..teams,1..warriors,0..15] of byte;
    invammo:array[0..teams,1..warriors,0..15] of integer;
    itemhide,itemx,itemy,itemt,itemp,itemex:array[1..1200] of byte;
    itema:array[1..1200] of integer;

    sgsbdriver,ofsbdriver,statusword:word;
    sbdriver:pointer;
    gmode,visix,visiy:byte;
    visimode:boolean;
    uselight,byt,byt2:byte;
    drawrad:real;
    drawx,drawy,drawfra:integer;
    le1,le2,le3,le4:word;
    mline,mlineold:shortint;
    visibseg,data1:word;
    depment:byte;
    grpmps,shots,hits,dcaused,penet,dbleed,mpsused,ifound,eprimed,expgain,mgain:array[0..teams] of longint;
    sofpal,defpal,frontpal:array [0..768] of shortint;
    losseg,losofs,entseg,entofs:word;
    xt,yt,xt1,yt1:integer;
    broken,ambientl,lio,lirange:byte;
    tlight:integer;
    freqi,timer:word;
    xvelo,yvelo:array[1..50] of shortint; { for effects }
    trlight:byte;
    fastmode,exit:boolean;

    reports,allw,debug:byte;
    foes,hcond,lcond:array[1..warriors] of byte;

const lights:array[1..25] of word=
($0a0a,$0909,
$0808,$0707,
$0606,$0505,
$0404,$0303,
$0202,$0101,
$0000,$0000,
$0000,$0000,
$0000,$0000,
$0000,$0000,
$0000,$0000,
$0000,$0000,
$0000,$0000,
$0000);

const lightval:array[1..25] of longint=
($0a0a0a0a,$09090909,
$08080808,$07070707,
$06060606,$05050505,
$04040404,$03030303,
$02020202,$01010101,
$00000000,$00000000,
$00000000,$00000000,
$00000000,$00000000,
$00000000,$00000000,
$00000000,$00000000,
$00000000,$00000000,
$00000000,$00000000,
$00000000);


const gfxofs:array[1..90] of word=(0,256,512,768,1120,1754,2388,3100,3656,4230,4804,5516,6228,6862,7496,8208,8829,9450,10138,
10954,11770,12484,13198,14094,14748,15484,16040,16694,17128,17562,18078,18802,19436,20070,20684,21298,21810,22328,22902,23476,
23948,24410,24762,25110,26006,26646,27133,27620,28122,28624,29107,29589,30076,30538,31050,31406,31866,32378,32890,33420,33950,
34368,34756,35174,35562,35818,36074,36330,36600,36888,37175,37462,37760,38114,38371,38731,39053,39400,39717,40040,40694,41383,
42225,43080,43932,44790,45662,46510,47279,47781);

const infofs:array[1..90] of word=(0,60,120,180,252,384,516,656,776,908,1040,1180,1320,1452,1584,1724,1876,2028,2160,2300,2440,
2572,2704,2844,2976,3116,3236,3368,3504,3640,3744,3876,4008,4140,4272,4404,4580,4764,4892,5020,5188,5364,5452,5544,5684,5792,
5884,5976,6068,6160,6252,6344,6436,6528,6620,6840,6940,7056,7172,7288,7404,7516,7612,7724,7820,7880,7940,8000,8076,8152,8228,
8304,8380,8460,8520,8688,8828,8952,9084,9160,10128,10280,10424,10556,10688,10828,10960,11152,11480,12052);

const times:array[1..90] of word=(15,15,15,18,33,33,35,30,33,33,35,35,33,33,35,38,38,33,35,35,33,33,35,33,35,30,33,34,34,26,33,
33,33,33,33,44,46,32,32,42,44,22,23,35,27,23,23,23,23,23,23,23,23,23,55,25,29,29,29,29,28,24,28,24,15,15,15,19,19,19,19,19,20,
15,42,35,31,33,19,242,38,36,33,33,35,33,48,82,143,112);


const mgfxofs:array[1..40] of word=(0,261,489,648,882,1145,1379,1538,1766,2027,2255,2414,2648,2911,3145,3304,3532,3793,4021,
4180,4414,4677,4911,5070,5298,5559,5787,5946,6180,6443,6677,6836,7064,7211,7358,7505,0,0,0,0);

const minfofs:array[1..40] of word=(0,136,244,348,456,592,700,804,912,1048,1156,1260,1368,1504,1612,1716,1824,1960,2068,2172,
2280,2416,2524,2628,2736,2872,2980,3084,3192,3328,3436,3540,3648,3716,3784,3852,0,0,0,0);

const mtimes:array[1..40] of word=(34,27,26,27,34,27,26,27,34,27,26,27,34,27,26,27,34,27,26,27,34,27,26,27,34,27,26,27,34,27,
26,27,17,17,17,17,0,0,0,0);

const igfxofs:array[1..6] of word=(0,22,66,93,151,194);

const iinfofs:array[1..6] of word=(0,24,52,92,140,164);

const itimes:array[1..6] of word=(6,7,10,12,6,6);

procedure move_custom(var source,dest;amount:word);
procedure fastp(light,toseg,cord,times,gfxofs,infofs,gseg,iseg:word);
procedure fastp_586(light,cord,times,gfxofs,infofs:word);
procedure init_fastp_586(toseg,gseg,iseg:word);
procedure wipe(seg1,seg2,off1,off2,amount:word);
procedure clear(segm,siz:word);
procedure clear1(segm,of1,siz:word);
{procedure los(x1,y1,x2,y2,mapseg,mapoffs,entseg1,entofs1:word);}
procedure put2d(toseg1,cord1,gfxseg1,gfxofs1:word;decment:longint);
procedure fontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);
procedure fontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);
procedure sfontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);
procedure sfontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);
procedure routestart(seg1,seg2,x,y,lx1,ly1,maxdist:word);

procedure line_of_sight(x1,y1,x2,y2:word);  { Very optimized }
function hfactor(grp,man:byte):real;
procedure readwep(w1:word);
procedure wait(t:longint);
function crange(x1,y1,x2,y2:byte):real;
procedure see;
procedure cnt;
function filload(hak,s12:string):string;
procedure liofsi(x1,y1,x2,y2:shortint);
function visiofsi(x1,y1,x2,y2:shortint):byte;
function secheck(sx1,sy1,sx2,sy2,sfc:shortint):byte;
procedure liofman(x1,y1,x2,y2:shortint);
function visiman(x1,y1,x2,y2,team:shortint):byte;
procedure reportwar(team,war:byte);
procedure nguy;
procedure inftxt(inf:string;col,lin,pla:byte);
procedure init(dr:byte);
procedure fastpixel(xco,yco,segm:word;col:byte);
procedure dell;
procedure effect(col,delay:byte);
procedure point(ax,ay,lx,ly:word;col:byte);
procedure setpal(n,r,g,b:byte);
function keypress:boolean;
procedure goxy(x,y:byte);
function checkfile(st1:string):boolean;
procedure loadraw(st1:string);
procedure loadpic(st1:string);
procedure palswap;
procedure fade(speed:byte);
procedure menufill(line2:byte);
procedure menuflash(line3,col1,col2,col3,col4:byte);
function readk:char;
procedure waitkey;
procedure drawmap;
procedure fillvisi;
procedure calcvisi1;
procedure calcvisi1all;
procedure calcvisiall;
procedure manlight(onoff:byte);
procedure calclights;
procedure precalcl;
procedure deployment(team1,guys:byte);
procedure drop(grnu,plnu,invnu:byte;fever:boolean);
procedure moving;
procedure itemtoseg;
procedure wepstoseg;
procedure explosion(x,y,ra,da,dafa:integer);
procedure checkbomb(bx,by:byte);
procedure usedoor;
procedure health;
procedure fastfont(snew:string;x,y,col,bcol,toseg,tpar,shad:word);
function  rank:string;
function  rank_short(gr,pl:byte):string;
procedure blittrp(sseg,dseg,sx,sy,dex,dey,width,height:word);
procedure mpsflash;

implementation

{$L ASMTOOLS.OBJ}
procedure move_custom(var source,dest;amount:word);external;
procedure fastp(light,toseg,cord,times,gfxofs,infofs,gseg,iseg:word);external;
procedure fastp_586(light,cord,times,gfxofs,infofs:word);external;
procedure inter_low_level(lt,ll,lr,lb:longint;coord,gfxofs:word);external;
procedure init_fastp_586(toseg,gseg,iseg:word);external;

procedure wipe(seg1,seg2,off1,off2,amount:word);external;
procedure clear(segm,siz:word);external;
procedure clear1(segm,of1,siz:word);external;
{procedure los(x1,y1,x2,y2,mapseg,mapoffs,entseg1,entofs1:word);external;}
procedure put2d(toseg1,cord1,gfxseg1,gfxofs1:word;decment:longint);external;
procedure fontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure fontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;
procedure sfontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure sfontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;

{$L ROUTE.OBJ}
procedure routestart(seg1,seg2,x,y,lx1,ly1,maxdist:word);external;

function rank:string;
var ranks:string;
begin ranks:='Rookie    ';
if exp[grp,pln]>=500 then ranks:='Trooper   ';
if exp[grp,pln]>=1000 then ranks:='Private   ';
if exp[grp,pln]>=2500 then ranks:='Corporal  ';
if exp[grp,pln]>=4000 then ranks:='Sergeant  ';
if exp[grp,pln]>=6000 then ranks:='Lieutenant';
if exp[grp,pln]>=9000 then ranks:='Captain   ';
if exp[grp,pln]>=15000 then ranks:='Major     ';
if exp[grp,pln]>=30000 then ranks:='Colonel   ';
if exp[grp,pln]>=60000 then ranks:='General   ';
rank:=ranks;
end;

function rank_short(gr,pl:byte):string;
var ranks:string;
begin
 ranks:='Rook. ';
if exp[gr,pl]>=500 then ranks:='Troop. ';
if exp[gr,pl]>=1000 then ranks:='Priv. ';
if exp[gr,pl]>=2500 then ranks:='Corp. ';
if exp[gr,pl]>=4000 then ranks:='Serg. ';
if exp[gr,pl]>=6000 then ranks:='Lieut. ' ;
if exp[gr,pl]>=9000 then ranks:='Capt. ';
if exp[gr,pl]>=15000 then ranks:='Maj. ';
if exp[gr,pl]>=30000 then ranks:='Col. ';
if exp[gr,pl]>=60000 then ranks:='Gen. ';
rank_short:=ranks;
end;

procedure mpsflash;
begin
play('mps.svs',8000);
setpal(87,63,0,0);
wait(3);
setpal(87,40,0,0);
wait(3);
setpal(87,20,2,5);
wait(3);
setpal(87,4,4,8);
wait(5);
end;

procedure blittrp(sseg,dseg,sx,sy,dex,dey,width,height:word);
assembler;    { No clipping, TRANSPARENT }
asm
mov  es,dseg
mov  di,dey
mov  ax,di
shl  di,8
shl  ax,6
add  di,ax
add  di,dex     { di = destination offset }

mov  si,sy
mov  ax,si
shl  si,8
shl  ax,6
add  si,ax
add  si,sx     { si = source offset }
push ds
mov  ds,sseg
push bp

mov  bx,width
mov  dx,height
mov  bp,320
sub  bp,bx

@row1:
mov  cx,bx
@beg1:
lodsb
or   al,al
je   @next1
stosb
dec  cx
jnz  @beg1
jmp  @ok1

@next1:
inc  di
dec  cx
jnz  @beg1

@ok1:
add  si,bp
add  di,bp
dec  dx
jnz  @row1

pop  bp
pop  ds
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

function hfactor(grp,man:byte):real;
var i,tm:byte;
    tem:real;
begin
tm:=0;for i:=1 to 6 do begin inc(tm,lochps[grp,man,i]);end;
tem:=(tm/tothps[grp,man]);if tem>1 then tem:=1.0;tem:=2.0-tem;
if(lochps[grp,man,1]<round(tothps[grp,man]*0.04))then tem:=tem+hbfac;
if(lochps[grp,man,3]=0)then tem:=tem+abfac;
if(lochps[grp,man,4]=0)then tem:=tem+abfac;
if(lochps[grp,man,5]=0)then tem:=tem+lbfac;
if(lochps[grp,man,6]=0)then tem:=tem+lbfac;
hfactor:=tem;
end;

procedure readwep(w1:word);
var by,ta,la:byte;code:integer;
begin
wof:=(w1-1)*59+1;
weaptype:=mem[wepseg:wof];
wepnam:='                    ';for ta:=1 to 16 do begin by:=mem[wepseg:wof+ta];wepnam[ta]:=chr(by);end;
{ price 6 bytes }
accuracy:=mem[wepseg:wof+23];
accufact:=mem[wepseg:wof+24];
xdam:=mem[wepseg:wof+25];
ydam:=mem[wepseg:wof+26];
expfact:=mem[wepseg:wof+27];
exprad:=mem[wepseg:wof+28];
mpscost:=mem[wepseg:wof+29];
mpscosta:=mem[wepseg:wof+30];
hreq:=mem[wepseg:wof+31];
burst:=mem[wepseg:wof+32];
clnam:='                    ';for ta:=1 to 16 do begin by:=mem[wepseg:wof+32+ta];clnam[ta]:=chr(by);end;
la:=1;s:='    ';for ta:=1 to 4 do begin by:=mem[wepseg:wof+48+ta];if(by<>32)then inc(la);s[ta]:=chr(by);end;
delete(s,la,5-la);val(s,clsize,code);
{ clprice 6 bytes }
end;


procedure wait(t:longint);
var w:longint;
begin
for w:=1 to t do
asm
mov dx,$3da;@vert1:in al,dx;test al,8;jz @vert1;@vert2:in al,dx;test al,8;jnz @vert2;
end;
end;

function crange(x1,y1,x2,y2:byte):real;
begin crange:=sqrt(sqr(x1-x2)+sqr(y1-y2));end;

procedure see;
begin
for a:=0 to teams do for i:=1 to gr[a] do insi[a,i]:=false;eis:=0;

for a:=0 to teams do
if(ally[a]=ally[grp])then for wo:=1 to 20 do insi[a,wo]:=true else
for c:=1 to gr[grp] do for i:=1 to gr[a] do begin
sect:=false;liosi:=false;

if(secheck(plx[grp,c],ply[grp,c],plx[a,i],ply[a,i],fc[grp,c])=1)then sect:=true else sect:=false;

if(sect=true)and(dead[grp,c]=false)and(dead[a,i]=false)then begin liofsi(plx[grp,c],ply[grp,c],plx[a,i],ply[a,i]);
if(liosi=true)and(dead[a,i]=false)then begin

if crange(plx[grp,c],ply[grp,c],plx[a,i],
ply[a,i])*(11-lightmap[plx[a,i],ply[a,i]])+
((11-lightmap[plx[a,i],ply[a,i]])*5)<90 then

begin
insi[a,i]:=true;
if(c=pln)and(dead[a,i]=false)then inc(eis);
end;
end;end;end;
if(lop=false)and(tch=true)and(eis>0)and(free=false)then begin
if(control[grp]=1)then begin
str(eis,s);inftxt('   ',0,1,0);
if(eis<10)then insert(' ',s,2);inftxt(s,15,1,0);
if(eis=1)then inftxt(' Enemy in sight               ',15,1,2);
if(eis>1)then inftxt(' Enemies in sight             ',15,1,2);
end;
end else if(free=false)then if(control[grp]=1)or(debug=1)then inftxt(cle,0,1,0);
end;

procedure cnt;begin cx:=plx[grp,pln]-4;cy:=ply[grp,pln]-3;end;

function filload(hak,s12:string):string;

const unregmaps=3;
const unregmap:array[1..unregmaps] of string[12]=
('MC-CLUB.MAP ','SSTATION.MAP','VILLAGE.MAP ');

procedure getfirst(name:string;arc:word);
begin
{$IFNDEF unregistered}
filseg:=seg(name);filofs:=ofs(name);inc(filofs,1);
asm push ds;mov al,0;mov ah,$2f;int $21;mov dtaofs,bx;mov dtaseg,es;pop ds;end;for i3:=34 to 41 do mem[dtaseg:dtaofs+i3]:=0;
asm push ds;stc;mov cx,arc;mov al,0;mov ah,$4e;mov dx,filofs;mov ds,filseg;int $21;pop ds;mov code,ax;end;

if code=0 then move_custom(mem[dtaseg:dtaofs+30],mem[infoseg:1],12);
{$ELSE}
{ Let's fake those mapfiles }
move_custom(mem[seg(unregmap[1][1]):ofs(unregmap[1][1])],mem[infoseg:1],12);
{$ENDIF}
end;


procedure getnext;
begin
{$IFNDEF unregistered}
for i3:=34 to 41 do mem[dtaseg:dtaofs+i3]:=0;
asm mov al,0;mov ah,$2f;int $21;mov dtaofs,bx;mov dtaseg,es;push ds;stc;
mov al,0;mov ah,$4f;mov dx,filofs;mov ds,filseg;int $21;pop ds;mov code,ax;end;

if code=0 then move_custom(mem[dtaseg:dtaofs+30],mem[infoseg:1+fils*12],12);
{$ELSE}
{ Let's fake those mapfiles }
move_custom(mem[seg(unregmap[1+fils][1]):ofs(unregmap[1+fils][1])],mem[infoseg:1+fils*12],12);
{$ENDIF}
end;

procedure uppage;begin
for a3:=(page-1)*10+1 to (page-1)*10+10 do begin
for i3:=(a3-1)*12+1 to a3*12 do s[i3-(a3-1)*12]:=chr(mem[infoseg:i3]);
fastfont(s,10,1+(a3-((page-1)*10))*12,20,0,ownseg,0,1);end;
end;

procedure mapup;var x,y:byte;begin

{$IFNDEF unregistered}
a3:=line+(page-1)*10;
for i3:=(a3-1)*12+1 to a3*12 do s[i3-(a3-1)*12]:=chr(mem[infoseg:i3]);
assign(f,s);reset(f,20606);blockread(f,mem[gfxseg:0],1);close(f);
{$ELSE}
assign(f,'mintegr.dat');reset(f,20606);
seek(f,line-1);
blockread(f,mem[gfxseg:0],1);close(f);
{$ENDIF}

for wo:=0 to 9999 do inc(mem[gfxseg:wo],100);

for wo:=0 to 9999 do case mem[gfxseg:wo] of
100:mem[gfxseg:wo]:=0;              { Blank }
101,102,103:mem[gfxseg:wo]:=24;     { Floors }
104:mem[gfxseg:wo]:=3;
105,106,107,108,109,110,111,112,113,114,115,116,117,118:mem[gfxseg:wo]:=190;  { Walls }
119,120,121,122,123,124,125,126,127,128,129,130,131,132,133:mem[gfxseg:wo]:=190;  { Walls }
134,135,136,137,138,139,140,141:mem[gfxseg:wo]:=14; { Doors }
142,143:mem[gfxseg:wo]:=6;              { Barrel & Gastank }
146,147,148,149,150,151,152,153,154:mem[gfxseg:wo]:=11;    { Tacticaltables }
144,145,155,156,157,158,159,160,161,162,163,164:mem[gfxseg:wo]:=11; { Misc }
165,166,167,168,169,170,171,172,173,174,175,176,177,178,179:mem[gfxseg:wo]:=30;
end;

for wo:=120 to 319 do for y:=0 to 199 do mem[ownseg:wo+y*320]:=0;
wo:=120+(100-mem[gfxseg:20600])+((100-mem[gfxseg:20601])*320);
for x:=0 to mem[gfxseg:20600]-1 do for y:=0 to mem[gfxseg:20601]-1 do begin
mem[ownseg:wo+x*2+y*640]:=mem[gfxseg:y+x*100];
mem[ownseg:wo+1+x*2+y*640]:=mem[gfxseg:y+x*100];
mem[ownseg:wo+320+x*2+y*640]:=mem[gfxseg:y+x*100];
mem[ownseg:wo+321+x*2+y*640]:=mem[gfxseg:y+x*100];
end;
end;

begin
clear(infoseg,2550);
away:=false;nofils:=false;code:=0;fils:=0;line:=1;page:=1;mem[infoseg:0]:=12;s[0]:=chr(mem[infoseg:0]);

assign(f,'gamedata\pick.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for c3:=0 to 767 do defpal[c3]:=mem[ownseg:c3];

assign(f,'gamedata\select.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for c3:=60 to 767 do defpal[c3]:=mem[ownseg:c3];

defpal[3]:=0;defpal[4]:=0;defpal[5]:=63;
defpal[9]:=0;defpal[10]:=40;defpal[11]:=0;
defpal[12]:=63;defpal[13]:=0;defpal[14]:=0;
defpal[36]:=0;defpal[37]:=40;defpal[38]:=0;
defpal[90]:=5;defpal[91]:=5;defpal[92]:=5;

defpal[570]:=11;defpal[571]:=11;defpal[572]:=11;

loadpic('gfx\mappick.svf');

chdir(hak);

getfirst(s12+#0,39);
{$IFNDEF unregistered}
if code=0 then fils:=1 else nofils:=true;
{$ELSE}
fils:=1;
{$ENDIF}

if fils=1 then
repeat getnext;
if code=0 then inc(fils);
{$IFNDEF unregistered}
until(code<>0)or(fils>1000);
{$ELSE}
until(code<>0)or(fils>unregmaps-1);
{$ENDIF}

uppage;
mapup;
wipe(ownseg,$a000,0,0,16000);
fade(4);

if fils>=1 then begin

repeat
point(7,(line*12),109,10+(line*12),33);
wipe(ownseg,$a000,0,0,16000);
point(7,(line*12),109,10+(line*12),0);
asm mov ah,0;int 16h;mov c1,ah;end;
if(c1=#72)and((page-1)*10+line>1)then begin dec(line);if line<1 then begin dec(page);line:=10;uppage;end;end;
if(c1=#80)and((page-1)*10+line<fils)then begin inc(line);if line>10 then begin inc(page);line:=1;uppage;end;end;
if(c1=#81)and(page<1+trunc((fils-1)/10))then begin inc(page);if line>fils-(page-1)*10 then line:=fils-(page-1)*10;uppage;end;
if(c1=#73)and(page>1)then begin dec(page);uppage;end;
if(c1=#1)then begin away:=true;c1:=#28;end;
if(c1=#72)or(c1=#80)or(c1=#81)or(c1=#73)then mapup;
until c1=#28;
a3:=line+(page-1)*10;for i3:=(a3-1)*12+1 to a3*12 do s[i3-(a3-1)*12]:=chr(mem[infoseg:i3]);
filload:=s;
end;
filline:=line;
end;

procedure liofsi(x1,y1,x2,y2:shortint);
var vis1,vis2:byte;
label end1;
begin
liosi:=false;
{vx:=x1;vy:=y1;
if x1-x2<>0 then yd:=(y2-y1)/(x2-x1) else begin xd:=0;yd:=1;if y1>y2 then yd:=-1;end;
if y1-y2<>0 then xd:=(x2-x1)/(y2-y1) else begin yd:=0;xd:=1;if x1>x2 then xd:=-1;end;
if xd>1 then xd:=1;if yd>1 then yd:=1;if xd<-1 then xd:=-1;if yd<-1 then yd:=-1;
if (x1>x2) and (y1<y2) then yd:=-yd;
if (x1>x2) and (y1>y2) then begin xd:=-xd;yd:=-yd;end;
if (x1<x2) and (y1>y2) then begin xd:=-xd;end;
repeat vx:=vx+xd;vy:=vy+yd;px:=round(vx);py:=round(vy);
if(px<>x2)or(py<>y2)then if firable[map[px,py]]=false then liosi:=false;until(px=x2)and(py=y2)or(liosi=false);
}
{los(x1,y1,x2,y2,losseg,losofs,entseg,entofs);
asm mov vis1,al;end;
los(x2,y2,x1,y1,losseg,losofs,entseg,entofs);
asm mov vis2,al;end;}
line_of_sight(x1,y1,x2,y2);
asm mov vis1,al;end;
line_of_sight(x2,y2,x1,y1);
asm mov vis2,al;end;
if(vis1=1)and(vis2=1)then liosi:=true;
end;

function visiofsi(x1,y1,x2,y2:shortint):byte;
var t,vis,vis1:byte;

begin
{for t:=1 to 100 do begin
vis:=1;liosi:=true;vx:=x1;vy:=y1;
if x1-x2<>0 then yd:=(y2-y1)/(x2-x1) else begin xd:=0;yd:=1;if y1>y2 then yd:=-1;end;
if y1-y2<>0 then xd:=(x2-x1)/(y2-y1) else begin yd:=0;xd:=1;if x1>x2 then xd:=-1;end;
if xd>1 then xd:=1;if yd>1 then yd:=1;if xd<-1 then xd:=-1;if yd<-1 then yd:=-1;
if (x1>x2) and (y1<y2) then yd:=-yd;
if (x1>x2) and (y1>y2) then begin xd:=-xd;yd:=-yd;end;
if (x1<x2) and (y1>y2) then begin xd:=-xd;end;
repeat vx:=vx+xd;vy:=vy+yd;px:=round(vx);py:=round(vy);
if(px<>x2)or(py<>y2)then if firable[map[px,py]]=false then vis:=0;until(px=x2)and(py=y2)or(vis=0);
visiofsi:=vis;
end;
}

{los(x1,y1,x2,y2,losseg,losofs,entseg,entofs);}
line_of_sight(x1,y1,x2,y2);

asm
mov vis,al
end;
{los(x2,y2,x1,y1,losseg,losofs,entseg,entofs);}
line_of_sight(x2,y2,x1,y1);
{asm
or  al,al
jne @sok
cmp vis,1
je  @sok
mov vis,0
jmp @end
@sok:
mov vis,1
@end:
end;
}
asm
mov vis1,al
end;
if(vis=0)or(vis1=0)then vis:=0;
visiofsi:=vis;
end;

function secheck(sx1,sy1,sx2,sy2,sfc:shortint):byte;
var secto:byte;
begin secto:=0;
case sfc of
0:if(sy1>=sy2)and(sx1>=sx2)then secto:=1;
1:if(abs(sx2-sx1)<=abs(sy2-sy1))and(sy1>sy2)then secto:=1;
2:if(sy1>=sy2)and(sx1<=sx2)then secto:=1;
3:if(abs(sx2-sx1)>=abs(sy2-sy1))and(sx1<sx2)then secto:=1;
4:if(sy1<=sy2)and(sx1<=sx2)then secto:=1;
5:if(abs(sx2-sx1)<=abs(sy2-sy1))and(sy1<sy2)then secto:=1;
6:if(sy1<=sy2)and(sx1>=sx2)then secto:=1;
7:if(abs(sx2-sx1)>=abs(sy2-sy1))and(sx1>sx2)then secto:=1;
end;
secheck:=secto;
end;

procedure liofman(x1,y1,x2,y2:shortint);
begin
own:=false;lioma:=true;vx:=x1;vy:=y1;
if x1-x2<>0 then yd:=(y2-y1)/(x2-x1) else begin xd:=0;yd:=1;if y1>y2 then yd:=-1;end;
if y1-y2<>0 then xd:=(x2-x1)/(y2-y1) else begin yd:=0;xd:=1;if x1>x2 then xd:=-1;end;
if xd>1 then xd:=1;if yd>1 then yd:=1;if xd<-1 then xd:=-1;if yd<-1 then yd:=-1;
if (x1>x2) and (y1<y2) then yd:=-yd;
if (x1>x2) and (y1>y2) then begin xd:=-xd;yd:=-yd;end;
if (x1<x2) and (y1>y2) then begin xd:=-xd;end;
{if xd<0 then vx:=vx-0.1;if yd<0 then vy:=vy-0.1;}
repeat vx:=vx+xd;vy:=vy+yd;px:=round(vx);py:=round(vy);
if(px<>x2)or(py<>y2)then for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=px)and(ply[a,i]=py)and(dead[a,i]=false)
then begin lioma:=false;if ally[a]=ally[guardgrp] then own:=true;end;
until(px=x2)and(py=y2);end;

function visiman(x1,y1,x2,y2,team:shortint):byte;
var own,lioma:byte;
begin
own:=0;lioma:=1;vx:=x1;vy:=y1;
if x1-x2<>0 then yd:=(y2-y1)/(x2-x1) else begin xd:=0;yd:=1;if y1>y2 then yd:=-1;end;
if y1-y2<>0 then xd:=(x2-x1)/(y2-y1) else begin yd:=0;xd:=1;if x1>x2 then xd:=-1;end;
if xd>1 then xd:=1;if yd>1 then yd:=1;if xd<-1 then xd:=-1;if yd<-1 then yd:=-1;
if (x1>x2) and (y1<y2) then yd:=-yd;
if (x1>x2) and (y1>y2) then begin xd:=-xd;yd:=-yd;end;
if (x1<x2) and (y1>y2) then begin xd:=-xd;end;
repeat vx:=vx+xd;vy:=vy+yd;px:=round(vx);py:=round(vy);
if(px<>x2)or(py<>y2)then for a:=0 to teams do for i:=1 to gr[a] do if(plx[a,i]=px)and(ply[a,i]=py)and(dead[a,i]=false)
then begin lioma:=0;if(ally[a]=ally[team])then own:=1;end;
until(px=x2)and(py=y2);
visiman:=own;end;

procedure reportwar(team,war:byte);
var vg,vw:byte;

procedure drawarw(a:byte);
var tx,ty:word;
const ax=115;
      ay=15;
begin
assign(f,'gfx\arws.svf');reset(f,7040);blockread(f,mem[ownseg:0],1);close(f);

for ty:=0 to 21 do
for tx:=0 to 24 do if mem[ownseg:ty*320+tx+a]>15 then
mem[$a000:(ty+ay)*320+(tx+ax)]:=mem[ownseg:ty*320+tx+a];

end;
begin

if(turn>1)and(reported[team,war]=0) then begin  { if not already done }
a:=0;
for wo:=length(plname[grp,pln]) downto 1 do begin
if(plname[grp,pln][wo]=#32)or((plname[grp,pln][wo]=#0))then inc(a) else break;
end;

if(enseen[grp,pln]>0) then begin
inftxt(plname[grp,pln],14,1,0);
inftxt(':                   ',14,1,length(plname[grp,pln])-a);
if(enseen[grp,pln]=1) then
inftxt('''I have sighted an enemy warrior.''   >>> ',7,2,0)

else begin
str(enseen[grp,pln],s);
inftxt('''I have sighted '+s+' enemy warriors!''   >>>  ',7,2,0)
end;
waitkey;

wo:=1;

for vg:=0 to teams do
for vw:=1 to warriors do
begin

{str(vg,stri1);
str(vw,stri2);
str(wseen_p^[grp,pln,vg,vw,1],stri3);
inftxt(stri1+' '+stri2+' '+stri3+'  ',15,1,0);
waitkey;}

if(wseen_p^[grp,pln,vg,vw,1]<>-10)and(vg<>grp)then begin

if((plx[vg,vw]<>wseen_p^[grp,pln,vg,vw,1])or(ply[vg,vw]<>wseen_p^[grp,pln,vg,vw,2]))then begin
if(enseen[grp,pln]>1)then begin
str(wo,s);
if(wo=1)then s:=s+'st';
if(wo=2)then s:=s+'nd';
if(wo=3)then s:=s+'rd';
if(wo>=4)then s:=s+'th';
inftxt(''''+s+' enemy warrior was last seen here,     ',7,1,0);
inc(wo);
end else
inftxt('''The enemy warrior was last seen here,     ',7,1,0);

cx:=wseen_p^[grp,pln,vg,vw,1]-4;
cy:=wseen_p^[grp,pln,vg,vw,2]-3;
ix:=cx+4;iy:=cy+3;ico:=true;
drawmap;

case wseen_p^[grp,pln,vg,vw,3] of
0:begin s:='north.'''+'                           ';
  drawarw(0);end;
1:begin s:='north-east.'''+'                       ';
  drawarw(1*25);end;
2:begin s:='east.'''+'                            ';
  drawarw(2*25);end;
3:begin s:='south-east.'''+'                       ';
  drawarw(3*25);end;
4:begin s:='south.'''+'                           ';
  drawarw(4*25);end;
5:begin s:='south-west.'''+'                       ';
  drawarw(5*25);end;
6:begin s:='west.'''+'                            ';
  drawarw(6*25);end;
7:begin s:='north-west.'''+'                       ';
  drawarw(7*25);end;
end;

inftxt(' facing '+s,7,2,0);

waitkey;

end;
end;
end;

end;
cx:=plx[grp,pln]-4;
cy:=ply[grp,pln]-3;
ico:=false;
drawmap;

inftxt(cle,15,1,0);
inftxt(cle,15,2,0);

reported[team,war]:=1;
see;
end;                     { if not already done }

end;


procedure nguy;
begin
a:=0;
repeat
inc(pln);
if(pln>gr[grp])then begin pln:=1;inc(a);end;
until(dead[grp,pln]=false)or(a>2);
{if(a>2)then begin chturn;cturn:=1;end;}
if(a<2)and(guard=false)then begin cnt;calcvisiall;see;
end;
end;

procedure inftxt(inf:string;col,lin,pla:byte);
begin if inf[length(inf)]=#32 then delete(inf,length(inf),1);
fastfont(inf,2+pla*6,120+lin*10,col,bcolo,$a000,0,0);end;

procedure init(dr:byte);
var i:byte;begin
if dr<>2 then
for wo:=0 to 768 do defpal[wo]:=frontpal[wo];

loadraw('gfx\3dfront.svf');
{for wo:=0 to 63999 do
if mem[ownseg:wo]>=48 then inc(mem[ownseg:wo],32);}
wipe(ownseg,$a000,0,0,16000);
if dr=1 then drawmap;
if dr<>2 then begin
for wo:=0 to 768 do sofpal[wo]:=0;
fade(4);end;
end;

procedure fastpixel(xco,yco,segm:word;col:byte);
assembler;
asm
mov es,segm
mov di,yco
mov ax,di
shl di,8
shl ax,6
add di,ax
add di,xco
mov al,col
mov byte ptr [es:di],al
end;

procedure dell;
var b1,b2,b3:byte;
begin
if(lightamo>0)then
begin {start}
 for b1:=1 to lightamo do
 begin
  if (b1>1)and(lightst[b1]<>0) then
  begin
   b3:=0;
   for b2:=b1-1 downto 1 do
   if (lightst[b2]=0)and(b3=0)then
   begin
    lightst[b2]:=lightst[b2+1];
    lightsx[b2]:=lightsx[b2+1];
    lightsy[b2]:=lightsy[b2+1];
    lightst[b2+1]:=0;
    b3:=1;
   end;
  end;
 end;
end;
end;

procedure effect(col,delay:byte);
var ofse,wh,lo,wor,wo1,wo2:word;
    count,xco,yco:array[1..50] of word;
    su:array[1..50] of byte;
begin
for wo1:=1 to 50 do
begin
xco[wo1]:=2560;
yco[wo1]:=960;
xvelo[wo1]:=random(5*16)-2*16;
yvelo[wo1]:=random(5*26)-2*26;
count[wo1]:=random(30)+1;
end;
ofse:=11288;
wo1:=ofse;
wo2:=0;
for wor:=1 to 100 do
begin
wipe($a000,ownseg,wo1,wo2+100,20);

asm
add wo1,320
add wo2,320
end;
end;
if (col=239)or(col=96) then play('wallhit.svs',12000);
if col=16 then play('hurt.svs',10000);

for wh:=0 to 30 do
begin

 wo1:=0;
 wo2:=0;
 for wor:=1 to 100 do
 begin
  wipe(ownseg,ownseg,wo1+100,wo2,20);
  asm
  add wo1,320
  add wo2,320
  end;
 end;

 for lo:=1 to 30 do begin
 if count[lo]>0 then
 begin
 fastpixel(xco[lo] shr 6,yco[lo] shr 6,ownseg,col+wh div 2);

 inc(xco[lo],xvelo[lo]);
 inc(yco[lo],yvelo[lo]);
 inc(yvelo[lo],3);
 if (su[lo]=0)and(yco[lo]>=2560) then begin yvelo[lo]:=-yvelo[lo] div 2;su[lo]:=1;end;
 dec(count[lo]);
 end;
 end;

 wo1:=0;
 wo2:=ofse;
 for wor:=1 to 100 do
 begin
  wipe(ownseg,$a000,wo1,wo2,20);
  asm
  add wo1,320
  add wo2,320
  end;
 end;
 if wh mod delay=0 then wait(1);
end;

 wo1:=0;
 wo2:=ofse;
 for wor:=1 to 100 do
 begin
  wipe(ownseg,$a000,wo1+100,wo2,20);
  asm
  add wo1,320
  add wo2,320
  end;
 end;
end;

{procedure text(x,y:integer;col,bgcol:byte;text:string);
var ty,tx,c:integer;co:word;begin co:=(y shl 8)+(y shl 6)+x-8;
for c:=1 to length(text) do for tx:=1 to 8 do for ty:=1 to 8 do
if mem[$f000:$fa6e+((ord(text[c]))shl 3)+ty-1] and ($80shr(tx-1))=0 then
mem[ownseg:co+(ty shl 8)+(ty shl 6)+tx+(c shl 3)]:=bgcol
else mem[ownseg:co+(ty shl 8)+(ty shl 6)+tx+(c shl 3)]:=col+ty;end;

procedure textxy(x,y:integer;text:string;col,bcol:byte);
var ty,tx,c:integer;co:word;begin co:=(y shl 8)+(y shl 6)+x-8;
for c:=1 to length(text) do for tx:=1 to 8 do for ty:=1 to 8 do
if mem[$f000:$fa6e+((ord(text[c]))shl 3)+ty-1] and ($80shr(tx-1))=0 then
mem[$a000:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=bcol
else mem[$a000:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=col;end;

procedure texti(x,y:integer;text:string;col,bcol:byte;segi:word);
var ty,tx,c:integer;co:word;begin co:=(y shl 8)+(y shl 6)+x-8;
for c:=1 to length(text) do for tx:=1 to 8 do for ty:=1 to 8 do
if mem[$f000:$fa6e+((ord(text[c]))shl 3)+ty-1] and ($80shr(tx-1))=0 then
mem[segi:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=bcol
else mem[segi:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=col;end;

procedure tptext(x,y:integer;col:byte;text:string);
var ty,tx,c:integer;co:word;begin co:=(y shl 8)+(y shl 6)+x-8;
for c:=1 to length(text) do for tx:=1 to 8 do for ty:=1 to 8 do
if mem[$f000:$fa6e+((ord(text[c]))shl 3)+ty-1] and ($80shr(tx-1))=0 then
mem[$a000:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=mem[ownseg:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]
else mem[$a000:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=col;end;

procedure tptexti(x,y:integer;col:byte;text:string;segi:word);
var ty,tx,c:integer;co:word;begin co:=(y shl 8)+(y shl 6)+x-8;
for c:=1 to length(text) do for tx:=1 to 8 do for ty:=1 to 8 do
if mem[$f000:$fa6e+((ord(text[c]))shl 3)+ty-1] and ($80shr(tx-1))<>0 then
mem[segi:co+tx+(ty shl 8)+(ty shl 6)+(c shl 3)]:=col+ty;end;
}
procedure point(ax,ay,lx,ly:word;col:byte);var wo:word;begin
for wo:=ax to lx do begin mem[ownseg:wo+ay*320]:=col;mem[ownseg:wo+ly*320]:=col;end;
for wo:=ay to ly do begin mem[ownseg:wo*320+ax]:=col;mem[ownseg:wo*320+lx]:=col;end;end;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

function keypress:boolean;label nt;begin asm mov ah,1;int 16h;jnz nt end;keypress:=false;nt:end;

procedure goxy(x,y:byte);assembler;asm mov ah,2;mov dh,y;mov dl,x;mov bh,0;int 10h end;

function checkfile(st1:string):boolean;var fil1:file;begin assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;end;

procedure loadraw(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin filc:=0;plac:=0;iv:=0;
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[ownseg:0],1);close(file1);
end;

procedure loadpic(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin filc:=0;plac:=0;iv:=0;
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[gfxseg:0],1);close(file1);

repeat
colo:=mem[gfxseg:filc];coun:=mem[gfxseg:filc+1];
for iv:=plac to plac+coun-1 do mem[ownseg:iv]:=colo;
inc(plac,coun);inc(filc,2);
until iv>=63999;

assign(f,'gamedata\tgfx.dat');reset(f,47767);blockread(f,mem[gfxseg:0],1);close(f);
end;

procedure palswap;
var wor:word;
begin
for wor:=0 to 768 do begin defpal[wor]:=0;
sofpal[wor]:=frontpal[wor];
end;
end;

procedure fade(speed:byte);
var t,byt:byte;i:word;
    time:byte;
begin
time:=0;
for t:=1 to 16 do
begin
for i:=0 to 768 do
begin
if sofpal[i]<defpal[i] then begin inc(sofpal[i],speed);
if sofpal[i]>defpal[i] then sofpal[i]:=defpal[i];end;
if sofpal[i]>defpal[i] then begin dec(sofpal[i],speed);
if sofpal[i]<defpal[i] then sofpal[i]:=defpal[i];end;
end;
wait(1);
for i:=0 to 255 do
setpal(i,sofpal[i*3],sofpal[i*3+1],sofpal[i*3+2]);
end;
end;


procedure menufill(line2:byte);
var x,y:word;
begin
for y:=74+(line2-1)*6 to 80+(line2-1)*6 do for x:=267 to 311 do
if(mem[$a000:x+((y shl 8)+(y shl 6))]=bcolo)then
mem[$a000:x+((y shl 8)+(y shl 6))]:=15 else
mem[$a000:x+((y shl 8)+(y shl 6))]:=bcolo;
end;

procedure menuflash(line3,col1,col2,col3,col4:byte);
var x,y:word;
begin
for y:=74+(line3-1)*6 to 80+(line3-1)*6 do for x:=267 to 311 do begin
if(mem[$a000:x+((y shl 8)+(y shl 6))]=col1)then mem[$a000:x+((y shl 8)+(y shl 6))]:=col2;
if(mem[$a000:x+((y shl 8)+(y shl 6))]=col3)then mem[$a000:x+((y shl 8)+(y shl 6))]:=col4;
end;end;

procedure fillvisi;
begin
if gmode=1 then begin
for x1:=1 to mapx do
for y1:=1 to mapy do if
mem[visibseg:(grp*10000)+y1*100+x1]=1 then
mem[visibseg:(grp*10000)+y1*100+x1]:=2
end;
end;

procedure calcvisi1;
var x1,y1,xl:integer;t1,t2:byte;
begin
if(gmode>1)and(dead[grp,pln]=false)then begin

if(gmode=2)then begin
for t1:=1 to mapx do for t2:=1 to mapy do
if{visibmap[grp,t1,t2]=1}
mem[visibseg:grp*10000+t2*100+t1]=1
then {visibmap[grp,t1,t2]:=2;}
mem[visibseg:grp*10000+t2*100+t1]:=2;
end;

if(gmode=3)then begin
for t1:=1 to mapx do for t2:=1 to mapy do
if{visibmap[grp,t1,t2]=1}
mem[visibseg:grp*10000+t2*100+t1]=1
then {visibmap[grp,t1,t2]:=0;}
mem[visibseg:grp*10000+t2*100+t1]:=0;
end;

y1:=cy-5;

for xl:=4 downto -3 do begin for x1:=cx+xl to cx+9-xl do
if(secheck(plx[grp,pln],ply[grp,pln],x1,y1,fc[grp,pln])=1)then
if(visiofsi(plx[grp,pln],ply[grp,pln],x1,y1)=1)and({visibmap[grp,x1,y1]=0}mem[visibseg:grp*10000+y1*100+x1]=0)then
mem[visibseg:grp*10000+y1*100+x1]:=1;
{visibmap[grp,x1,y1]:=1;}

inc(y1);
end;

for x1:=cx-4 to cx+12 do
if(secheck(plx[grp,pln],ply[grp,pln],x1,y1,fc[grp,pln])=1)then
if(visiofsi(plx[grp,pln],ply[grp,pln],x1,y1)=1)and({visibmap[grp,x1,y1]=0}mem[visibseg:grp*10000+y1*100+x1]=0)then
mem[visibseg:grp*10000+y1*100+x1]:=1;
{visibmap[grp,x1,y1]:=1;}

inc(y1);

for xl:=-3 to 5 do begin for x1:=cx+xl to cx+12-xl do
if(secheck(plx[grp,pln],ply[grp,pln],x1,y1,fc[grp,pln])=1)then
if(visiofsi(plx[grp,pln],ply[grp,pln],x1,y1)=1)and({visibmap[grp,x1,y1]=0}mem[visibseg:grp*10000+y1*100+x1]=0)then
mem[visibseg:grp*10000+y1*100+x1]:=1;
{visibmap[grp,x1,y1]:=1;}

inc(y1);
end;
if{visibmap[grp,plx[grp,pln],ply[grp,pln]]=0}
mem[visibseg:grp*10000+ply[grp,pln]*100+plx[grp,pln]]=0
then {visibmap[grp,plx[grp,pln],ply[grp,pln]]:=1;}
mem[visibseg:grp*10000+ply[grp,pln]*100+plx[grp,pln]]:=1;

end;
end;

procedure calcvisi1all;
var x1,y1:integer;t1,t2:byte;
begin
if(gmode>1)and(dead[grp,pln]=false)then begin
for x1:=1 to mapx do for y1:=1 to mapy do
if(secheck(plx[grp,pln],ply[grp,pln],x1,y1,fc[grp,pln])=1)then
if(visiofsi(plx[grp,pln],ply[grp,pln],x1,y1)=1)and({visibmap[grp,x1,y1]=0}mem[visibseg:grp*10000+y1*100+x1]=0)then
mem[visibseg:grp*10000+y1*100+x1]:=1;
{visibmap[grp,x1,y1]:=1;}

if{visibmap[grp,plx[grp,pln],ply[grp,pln]]=0}
mem[visibseg:grp*10000+ply[grp,pln]*100+plx[grp,pln]]=0
then {visibmap[grp,plx[grp,pln],ply[grp,pln]]:=1;}
mem[visibseg:grp*10000+ply[grp,pln]*100+plx[grp,pln]]:=1;
{if(visibmap[grp,plx[grp,pln],ply[grp,pln]]=0)then visibmap[grp,plx[grp,pln],ply[grp,pln]]:=1;}
end;
end;


procedure calcvisiall;
var x1,y1:integer;t1,t2:byte;
begin
if(gmode>1)then begin
if(gmode=3)then for t1:=1 to mapy do for t2:=1 to mapx do {visibmap[grp,t2,t1]:=0;}mem[visibseg:grp*10000+t1*100+t2]:=0;

for t1:=1 to gr[grp] do if(dead[grp,t1]=false)then if(t1=pln)then
mem[visibseg:grp*10000+ply[grp,t1]*100+plx[grp,t1]]:=1
{visibmap[grp,plx[grp,t1],ply[grp,t1]]:=1}
else
mem[visibseg:grp*10000+ply[grp,t1]*100+plx[grp,t1]]:=2;
{visibmap[grp,plx[grp,t1],ply[grp,t1]]:=2;}

for x1:=1 to mapx do for y1:=1 to mapy do for t1:=1 to gr[grp] do
if(dead[grp,t1]=false)then
if(secheck(plx[grp,t1],ply[grp,t1],x1,y1,fc[grp,t1])=1)then
if(visiofsi(plx[grp,t1],ply[grp,t1],x1,y1)=1)and({visibmap[grp,x1,y1]<>2}mem[visibseg:grp*10000+y1*100+x1]<>2)then
if(t1=pln)then
mem[visibseg:grp*10000+y1*100+x1]:=1
{visibmap[grp,x1,y1]:=1}
else
mem[visibseg:grp*10000+y1*100+x1]:=2;
{visibmap[grp,x1,y1]:=2;}
end;
end;

function readk:char;var c:char;begin asm mov ah,0;int 16h;mov c,ah end;readk:=c;end;
procedure waitkey;assembler;asm xor ax,ax;int $16;end;

procedure drawmap;
var x1,y1,x2,y2,xl:integer;wod:word;co,image,lig:byte;
    cord:word;

procedure icon;var ia:shortint;c2:word;
begin c2:=8233+(ix-cx)*2320+(iy-cy)*2320+((ix-cx)-(iy-cy))*16;
for ia:=7 to 14 do begin mem[ownseg:c2+ia*290+(ia-7)*2]:=icol;mem[ownseg:c2+ia*290+(ia-7)*2+1]:=icol;
mem[ownseg:30+c2+ia*290-(ia-7)*2]:=icol;mem[ownseg:31+c2+ia*290-(ia-7)*2]:=icol;end;
for ia:=-9 to 13 do begin mem[ownseg:15+c2+ia*290]:=icol;mem[ownseg:16+c2+ia*290]:=icol;end;
for ia:=-16 to 6 do begin mem[ownseg:c2+ia*290]:=icol;mem[ownseg:31+c2+ia*290]:=icol;end;
for ia:=-16 to -10 do begin mem[ownseg:c2+ia*290+(ia+17)*2]:=icol;mem[ownseg:c2+ia*290+(ia+17)*2+1]:=icol;
mem[ownseg:30+c2+ia*290-(ia+17)*2]:=icol;mem[ownseg:31+c2+ia*290-(ia+17)*2]:=icol;end;
for ia:=-24 to -17 do begin mem[ownseg:14+c2+ia*290-(ia+24)*2]:=icol;mem[ownseg:15+c2+ia*290-(ia+24)*2]:=icol;
mem[ownseg:16+c2+ia*290+(ia+24)*2]:=icol;mem[ownseg:17+c2+ia*290+(ia+24)*2]:=icol;end;
end;

procedure depput(toseg,cord,infoseg:word;col:byte);assembler;
asm push ds;mov cl,col;mov es,toseg;mov di,cord;xor dx,dx;xor si,si;mov ds,infoseg;
@mainloop: mov ax,[ds:si];add di,ax;add si,2;mov [es:di],cl;
inc dx;cmp dx,224;jb @mainloop;pop ds;end;


procedure castshadow(cord:word);
begin
if(depment=0)then begin
asm
mov es,ownseg
mov di,cord
mov ax,0202h
sub [es:di-2],ax
sub [es:di],ax
sub [es:di+2],ax
sub [es:di+4],ax
sub [es:di+6],ax
sub [es:di+8],ax

sub [es:di-4+290],ax
sub [es:di-2+290],ax
sub [es:di+290],ax
sub [es:di+2+290],ax
sub [es:di+4+290],ax
sub [es:di+6+290],ax
sub [es:di+8+290],ax
sub [es:di+10+290],ax

sub [es:di-6+580],ax
sub [es:di-4+580],ax
sub [es:di-2+580],ax
sub [es:di+580],ax
sub [es:di+2+580],ax
sub [es:di+4+580],ax
sub [es:di+6+580],ax
sub [es:di+8+580],ax
sub [es:di+10+580],ax
sub [es:di+12+580],ax

sub [es:di-6+870],ax
sub [es:di-4+870],ax
sub [es:di-2+870],ax
sub [es:di+870],ax
sub [es:di+2+870],ax
sub [es:di+4+870],ax
sub [es:di+6+870],ax
sub [es:di+8+870],ax
sub [es:di+10+870],ax
sub [es:di+12+870],ax

sub [es:di-4+1160],ax
sub [es:di-2+1160],ax
sub [es:di+1160],ax
sub [es:di+2+1160],ax
sub [es:di+4+1160],ax
sub [es:di+6+1160],ax
sub [es:di+8+1160],ax
sub [es:di+10+1160],ax

sub [es:di-2+1450],ax
sub [es:di+1450],ax
sub [es:di+2+1450],ax
sub [es:di+4+1450],ax
sub [es:di+6+1450],ax
sub [es:di+8+1450],ax
end;
end;
end;

procedure lball3d(cord:word;size:byte);
var colt:longint;
    c,xl,yl:integer;

begin
if size<=3 then begin
colt:=$f2f2f2f2;
if size=1 then
begin
inc(cord,874+2*290);
for yl:=-6 to 6 do
for xl:=-6 to 6 do begin
c:=topcol[mem[ownseg:cord+yl*290+xl]];
inc(mem[ownseg:cord+yl*290+xl],preclights[1,xl,yl]);
if mem[ownseg:cord+yl*290+xl]>c then mem[ownseg:cord+yl*290+xl]:=c;
end;
end;
if size=2 then
begin
inc(cord,583+4*290);
for yl:=-8 to 8 do
for xl:=-8 to 8 do begin
c:=topcol[mem[ownseg:cord+yl*290+xl]];
inc(mem[ownseg:cord+yl*290+xl],preclights[2,xl,yl]);
if mem[ownseg:cord+yl*290+xl]>c then mem[ownseg:cord+yl*290+xl]:=c;
end;

end;
if size=3 then
begin
inc(cord,292+7*290);
for yl:=-9 to 9 do
for xl:=-9 to 9 do begin
c:=topcol[mem[ownseg:cord+yl*290+xl]];
inc(mem[ownseg:cord+yl*290+xl],preclights[3,xl,yl]);
if mem[ownseg:cord+yl*290+xl]>c then mem[ownseg:cord+yl*290+xl]:=c;
end;

end;
end;
end;

procedure fp_inter_light; { Interpolated light }
{ Using global variables directly }

const fixed_point=16;
      l_modifier=52000;

var light_top,light_right,light_bottom,light_left:longint;
    t1,t2,t3,offse,goffse:word;

    light_level:array[1..2,1..15] of longint;
    l_cur,l_step:longint;

begin
light_top:=(lightmap[x1,y1]+lightmap[x1-1,y1]+
             lightmap[x1-1,y1-1]+lightmap[x1,y1-1]);
if(light_top>11*4) then light_top:=11*4;
light_top:=(light_top shl fixed_point) shr 2;

light_right:=(lightmap[x1,y1]+lightmap[x1,y1-1]+
               lightmap[x1+1,y1-1]+lightmap[x1+1,y1]);
if(light_right>11*4) then light_right:=11*4;
light_right:=(light_right shl fixed_point) shr 2;

light_left:=(lightmap[x1,y1]+lightmap[x1,y1+1]+
              lightmap[x1-1,y1+1]+lightmap[x1-1,y1]);
if(light_left>11*4) then light_left:=11*4;
light_left:=(light_left shl fixed_point) shr 2;

light_bottom:=(lightmap[x1,y1]+lightmap[x1+1,y1]+
                lightmap[x1+1,y1+1]+lightmap[x1,y1+1]);
if(light_bottom>11*4) then light_bottom:=11*4;
light_bottom:=(light_bottom shl fixed_point) shr 2;

inter_low_level(light_top,light_left,
                light_right,light_bottom,
                (x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),
                gfxofs[map[x1,y1]]);

{
l_cur:=light_top+l_modifier;
l_step:=(light_top-light_left) div 8;
for t1:=1 to 8 do begin
light_level[1,t1]:=l_cur;
dec(l_cur,l_step);
end;
l_cur:=light_top+l_modifier;
l_step:=(light_top-light_right) div 8;
for t1:=1 to 8 do begin
light_level[2,t1]:=l_cur;
dec(l_cur,l_step);
end;

l_cur:=light_left+l_modifier;
l_step:=(light_left-light_bottom) div 8;
for t1:=9 to 15 do begin
light_level[1,t1]:=l_cur;
dec(l_cur,l_step);
end;
l_cur:=light_right+l_modifier;
l_step:=(light_right-light_bottom) div 8;
for t1:=9 to 15 do begin
light_level[2,t1]:=l_cur;
dec(l_cur,l_step);
end;

t1:=4;
offse:=13+2433+20*290;
goffse:=0;

for t2:=1 to 8 do begin
l_cur:=light_level[1,t2];
l_step:=(light_level[1,t2]-light_level[2,t2]) div t1;

for t3:=1 to t1 do
begin
mem[ownseg:coord+offse+t3]:=mem[gfxseg:gfx_ofs+goffse]-(10-(l_cur shr fixed_point));
inc(goffse,1);
dec(l_cur,l_step);
end;

inc(t1,4);
inc(offse,290-2);
end;

dec(t1,8);
inc(offse,4);

for t2:=1 to 7 do begin
l_cur:=light_level[1,t2+8];
l_step:=(light_level[1,t2+8]-light_level[2,t2+8]) div t1;

for t3:=1 to t1 do
begin
mem[ownseg:coord+offse+t3]:=mem[gfxseg:gfx_ofs+goffse]-(10-(l_cur shr fixed_point));
inc(goffse,1);
dec(l_cur,l_step);
end;

dec(t1,4);
inc(offse,290+2);
end;
}
end;


begin
y1:=cy-5;
if(depment=0)and(visimode=false)then manlight(1);
clear(ownseg,16000);

for xl:=4 downto -3 do begin for x1:=cx+xl to cx+8-xl do begin { First loop }
if(map[x1,y1]<>0)then if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)then
if(interable[map[x1,y1]]=false) then
fastp_586(lights[lightmap[x1,y1]],
(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),times[map[x1,y1]],gfxofs[map[x1,y1]],infofs[map[x1,y1]])
else fp_inter_light;

if(depment>0)then if(mem[musaseg:x1*100+y1-101]=depment)and(mem[musaseg:x1*100+y1-101]>0)and(map[x1,y1]<>0)then
depput(ownseg,2433+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),itemseg,depment);

for a:=0 to teams do for i:=1 to gr[a] do
if(escaped[a,i]=false)and(dead[a,i]=true)and(plx[a,i]=x1)and(ply[a,i]=y1)then
if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)then
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),mtimes[33+a],mgfxofs[33+a],minfofs[33+a],mgfxseg,minfoseg);

if(dritem>0)then
for wod:=1 to dritem do if(itemx[wod]=x1)and(itemy[wod]=y1)then
begin
byt:=0;for a:=1 to gr[grp] do if(dead[grp,a]=false)then begin
if(byt=0)then begin byt:=secheck(plx[grp,a],ply[grp,a],itemx[wod],itemy[wod],fc[grp,a]);
if(byt=1)then byt:=visiofsi(plx[grp,a],ply[grp,a],itemx[wod],itemy[wod]);end;
if(itemx[wod]=plx[grp,a])and(itemy[wod]=ply[grp,a])then byt:=1;
end;

if(itemhide[wod]=0)and(byt=1)then begin
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]<=2)then image:=4;
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]=3)then image:=3;
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]=4)then image:=5;
if(itemt[wod]>=101)then image:=1;if(itemt[wod]>=201)then image:=2;
if(itemt[wod]>=251)then image:=6;
fastp($0000,ownseg,6389+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),itimes[image],igfxofs[image],iinfofs[image],igfxseg,iinfoseg);
end;end;

for i:=0 to teams do if(drawable[i]=1)or(debug=1)then for a:=1 to gr[i] do
if(plx[i,a]=x1)and(ply[i,a]=y1)and(dead[i,a]=false)and(insi[i,a]=true)and
(inhusi[i,a]=true)then begin
castshadow((2445+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4))+290*25);
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4-1),
mtimes[1+(8*i)+fc[i,a]],mgfxofs[1+(8*i)+fc[i,a]],minfofs[1+(8*i)+fc[i,a]],mgfxseg,minfoseg);
end;

if(lightamo>0)then
if(control[grp]>1)or(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)
then for lig:=1 to lightamo do
if(lightsx[lig]=x1)and(lightsy[lig]=y1)then
lball3d(2445+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),lightst[lig]);

if(drawfra>0)then if(sqrt(sqr(drawx-x1)+sqr(drawy-y1))<=drawrad)then
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),times[80+drawfra],gfxofs[80+drawfra],infofs[80+drawfra],gfxseg,infoseg);

if(ico=true)and(ix=x1)and(iy=y1)then icon;
end;inc(y1);end;       { First loop }

for x1:=cx-4 to cx+12 do begin       { Second loop }
if(map[x1,y1]<>0)then if(mem[visibseg:grp*10000+y1*100+x1]>0)or(control[grp]>1)
or(depment>0)then
if(interable[map[x1,y1]]=false) then
fastp_586(lights[lightmap[x1,y1]],
(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),times[map[x1,y1]],gfxofs[map[x1,y1]],infofs[map[x1,y1]])
else fp_inter_light;

if(depment>0)then if(mem[musaseg:x1*100+y1-101]=depment)and(mem[musaseg:x1*100+y1-101]>0)and(map[x1,y1]<>0)then
depput(ownseg,2433+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),itemseg,depment);

for a:=0 to teams do for i:=1 to gr[a] do
if(escaped[a,i]=false)and(dead[a,i]=true)and(plx[a,i]=x1)and(ply[a,i]=y1)then
if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)then
fastp(0,ownseg,
(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),mtimes[33+a],mgfxofs[33+a],minfofs[33+a],mgfxseg,minfoseg);

if dritem>0 then for wod:=1 to dritem do if(itemx[wod]=x1)and(itemy[wod]=y1)then
begin
byt:=0;for a:=1 to gr[grp] do if(dead[grp,a]=false)then begin
if(byt=0)then begin byt:=secheck(plx[grp,a],ply[grp,a],itemx[wod],itemy[wod],fc[grp,a]);
if(byt=1)then byt:=visiofsi(plx[grp,a],ply[grp,a],itemx[wod],itemy[wod]);end;
if (itemx[wod]=plx[grp,a])and(itemy[wod]=ply[grp,a])then byt:=1;
end;

if(itemhide[wod]=0)and(byt=1)then begin
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]<=2)then image:=4;
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]=3)then image:=3;
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]=4)then image:=5;
if(itemt[wod]>=101)then image:=1;if(itemt[wod]>=201)then image:=2;
if(itemt[wod]>=251)then image:=6;
fastp($0000,ownseg,6389+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),itimes[image],igfxofs[image],iinfofs[image],igfxseg,iinfoseg);
end;end;

for i:=0 to teams do if(drawable[i]=1)or(debug=1)then for a:=1 to gr[i] do
if(plx[i,a]=x1)and(ply[i,a]=y1)and(dead[i,a]=false)and(insi[i,a]=true)
and(inhusi[i,a]=true)then begin
castshadow((2445+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4))+290*25);
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4-1),
mtimes[1+(8*i)+fc[i,a]],mgfxofs[1+(8*i)+fc[i,a]],minfofs[1+(8*i)+fc[i,a]],mgfxseg,minfoseg);
end;

if(lightamo>0)then
if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)
then for lig:=1 to lightamo do
if(lightsx[lig]=x1)and(lightsy[lig]=y1)then
lball3d(2445+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),lightst[lig]);

if(drawfra>0)then if(sqrt(sqr(drawx-x1)+sqr(drawy-y1))<=drawrad)then
fastp(0,ownseg,
(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),times[80+drawfra],gfxofs[80+drawfra],infofs[80+drawfra],gfxseg,infoseg);

if(ico=true)and(ix=x1)and(iy=y1)then icon;
end;inc(y1);       { Second loop }

for xl:=-3 to 5 do begin for x1:=cx+xl to cx+11-xl do begin { Third loop }
if(map[x1,y1]<>0)then if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)then
if(interable[map[x1,y1]]=false) then
fastp_586(lights[lightmap[x1,y1]],
(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),times[map[x1,y1]],gfxofs[map[x1,y1]],infofs[map[x1,y1]])
else fp_inter_light;

if(depment>0)then if(mem[musaseg:x1*100+y1-101]=depment)and(mem[musaseg:x1*100+y1-101]>0)and(map[x1,y1]<>0)then
depput(ownseg,2433+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),itemseg,depment);

for a:=0 to teams do for i:=1 to gr[a] do
if(escaped[a,i]=false)and(dead[a,i]=true)and(plx[a,i]=x1)and(ply[a,i]=y1)then
if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)then
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),mtimes[33+a],mgfxofs[33+a],minfofs[33+a],mgfxseg,minfoseg);

if dritem>0 then for wod:=1 to dritem do if(itemx[wod]=x1)and(itemy[wod]=y1)then
begin
byt:=0;for a:=1 to gr[grp] do if(dead[grp,a]=false)then begin
if(byt=0)then begin byt:=secheck(plx[grp,a],ply[grp,a],itemx[wod],itemy[wod],fc[grp,a]);
if(byt=1)then byt:=visiofsi(plx[grp,a],ply[grp,a],itemx[wod],itemy[wod]);end;
if (itemx[wod]=plx[grp,a])and(itemy[wod]=ply[grp,a])then byt:=1;
end;

if(itemhide[wod]=0)and(byt=1)then begin
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]<=2)then image:=4;
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]=3)then image:=3;
if(itemt[wod]<=100)and(mem[wepseg:((itemt[wod]-1)*59+1)]=4)then image:=5;
if(itemt[wod]>=101)then image:=1;if(itemt[wod]>=201)then image:=2;
if(itemt[wod]>=251)then image:=6;
fastp($0000,ownseg,6389+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),itimes[image],igfxofs[image],iinfofs[image],igfxseg,iinfoseg);
end;end;

for i:=0 to teams do if(drawable[i]=1)or(debug=1)then for a:=1 to gr[i] do
if(plx[i,a]=x1)and(ply[i,a]=y1)and(dead[i,a]=false)and(insi[i,a]=true)
and(inhusi[i,a]=true)then begin
castshadow((2445+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4))+290*25);
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4-1),
mtimes[1+(8*i)+fc[i,a]],mgfxofs[1+(8*i)+fc[i,a]],minfofs[1+(8*i)+fc[i,a]],mgfxseg,minfoseg);
end;

if(lightamo>0)then
if(mem[visibseg:grp*10000+y1*100+x1]>0)or(depment>0)or(control[grp]>1)
then for lig:=1 to lightamo do
if(lightsx[lig]=x1)and(lightsy[lig]=y1)then
lball3d(2445+(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),lightst[lig]);

if(drawfra>0)then if(sqrt(sqr(drawx-x1)+sqr(drawy-y1))<=drawrad)then
fastp(0,ownseg,(x1-cx+y1-cy)*2320+((x1-cx-y1+cy)shl 4),times[80+drawfra],gfxofs[80+drawfra],infofs[80+drawfra],gfxseg,infoseg);

if(ico=true)and(ix=x1)and(iy=y1)then icon;
end;inc(y1);end;      { Third loop }

if(pntr=true)and(explos=false)and(drawfra=0)and(control[grp]=1)then begin
co:=mancol;x1:=plx[grp,pln];y1:=ply[grp,pln];
del:=(x1-cx)*2320+(y1-cy)*2320+((x1-cx)-(y1-cy))*16;
mem[ownseg:del+1866]:=co;mem[ownseg:del+1867]:=co;mem[ownseg:del+1868]:=co;
mem[ownseg:del+1869]:=co;mem[ownseg:del+1870]:=co;mem[ownseg:del+1871]:=co;
mem[ownseg:del+2157]:=co;mem[ownseg:del+2158]:=co;mem[ownseg:del+2159]:=co;
mem[ownseg:del+2160]:=co;mem[ownseg:del+2448]:=co;mem[ownseg:del+2449]:=co;end;

if scree=false then
asm
push ds
mov  ax,0a000h
xor  di,di
mov  es,ax
mov  si,8137
mov  ds,ownseg
mov  bx,128
cld
@inloop:
mov  cx,64
db   66h
rep  movsw
add  si,290-256
add  di,320-256
dec  bx
jnz  @inloop
pop  ds
end;

scree:=false;
if(depment=0)and(visimode=false)then manlight(0);
end;

procedure manlight(onoff:byte);
begin
entseg:=seg(lightable);entofs:=ofs(lightable);
xt:=plx[grp,pln];yt:=ply[grp,pln];
if(onoff=0)then
begin

   for yt1:=yt-4 to yt+4 do
   for xt1:=xt-4 to xt+4 do
        begin
        {los(xt,yt,xt1,yt1,losseg,losofs,entseg,entofs);}
        line_of_sight(xt,yt,xt1,yt1);
        asm
        mov lio,al
        end;
        if lio=1 then
        dec(lightmap[xt1,yt1],preclights[1,xt-xt1,yt-yt1]);
       end;
end;
if(onoff=1)then
begin
   for yt1:=yt-4 to yt+4 do
   for xt1:=xt-4 to xt+4 do
        begin
        {los(xt,yt,xt1,yt1,losseg,losofs,entseg,entofs);}
        line_of_sight(xt,yt,xt1,yt1);
        asm
        mov lio,al
        end;
        if lio=1 then
        inc(lightmap[xt1,yt1],preclights[1,xt-xt1,yt-yt1]);
       end;
end;
entseg:=seg(firable);entofs:=ofs(firable);
end;

procedure calclights;
var tlt:byte;
begin
if (uselight=1) then
begin { uselights }
entseg:=seg(lightable);entofs:=ofs(lightable);
for yt:=1 to mapy do
for xt:=1 to mapx do
lightmap[xt,yt]:=1;

if(lightamo>0)then
for i:=1 to lightamo do
begin
if (lightst[i]<>0)then
   begin
   tlt:=lightst[i];
   if tlt>3 then dec(tlt,3);
   xt:=lightsx[i];
   yt:=lightsy[i];
   for yt1:=yt-(1+tlt*3) to yt+(1+tlt*3) do
   for xt1:=xt-(1+tlt*3) to xt+(1+tlt*3) do
        begin
        {los(xt,yt,xt1,yt1,losseg,losofs,entseg,entofs);}
        line_of_sight(xt,yt,xt1,yt1);
        asm
        mov lio,al
        end;
        if lio=1 then
        inc(lightmap[xt1,yt1],preclights[tlt,xt-xt1,yt-yt1]);
       end;
   end;
end;

if(dritem>0)then
for wo:=1 to dritem do
begin
if (itemt[wo]>=251)and(itema[wo]>0)then
   begin
   tlt:=itemt[wo]-250;
   xt:=itemx[wo];
   yt:=itemy[wo];
   for yt1:=yt-(1+tlt*3) to yt+(1+tlt*3) do
   for xt1:=xt-(1+tlt*3) to xt+(1+tlt*3) do
        begin
        {los(xt,yt,xt1,yt1,losseg,losofs,entseg,entofs);}
        line_of_sight(xt,yt,xt1,yt1);
        asm
        mov lio,al
        end;
        if lio=1 then
        inc(lightmap[xt1,yt1],preclights[tlt,xt-xt1,yt-yt1]);
       end;
   end;
end;

for yt:=1 to mapy do
for xt:=1 to mapx do
begin
inc(lightmap[xt,yt],ambientl);
if lightmap[xt,yt]>11 then lightmap[xt,yt]:=11;
end;
entseg:=seg(firable);entofs:=ofs(firable);
end;
end;{proc }

procedure precalcl;
var
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

procedure deployment(team1,guys:byte);

function rc(pl,gr,xm,ym:byte):boolean;
begin if(round(sqrt(sqr(plx[gr,pl]-xm)+sqr(ply[gr,pl]-ym)))<2)then rc:=true else rc:=false;end;

var a2,i2,dgrp,depy,dept,team:byte;depok:boolean;
begin

for i:=0 to teams do for a:=1 to warriors do insi[i,a]:=false;
for a:=1 to guys do insi[team1,a]:=true;

dgrp:=team1;

if(dgrp=0)then team:=1;
if(dgrp=1)then team:=4;
if(dgrp=2)then team:=3;
if(dgrp=3)then team:=14;
depment:=team;pntr:=false;
grp:=dgrp;

a2:=1;i2:=1;
depok:=false;
repeat
depy:=1;
{ Is there a guy already ? }
for dept:=1 to warriors do if (plx[dgrp,dept]=i2)and(ply[dgrp,dept]=a2)then depy:=0;
if(mem[musaseg:(i2-1)*100+(a2-1)]=depment)and(depy=1)then depok:=true;

if(depok=false)then begin inc(a2);
if(a2>100)then begin inc(i2);a2:=1;end;
end;
if(a2>99)and(i2>99)then begin a2:=1;i2:=1;end;
until depok=true;

for wo:=1 to guys do begin
ix:=i2;iy:=a2;

fastfont(rank_short(dgrp,wo)+plname[dgrp,wo]+'   ',11,162,tcolo,bcolo,$a000,0,0);
wepstoseg;
if(larm[team1,wo]>0)then readwep(invtype[team1,wo,larm[team1,wo]]);
if(rarm[team1,wo]>0)then readwep(invtype[team1,wo,rarm[team1,wo]]);
s:=wepnam+'    ';
if(larm[team1,wo]+rarm[team1,wo]=0)then s:='knuckles               ';
inftxt('Weapon: '+s,14,2,0);


icol:=depment;
inftxt('Choose your starting position. ',15,1,0);
repeat
icol:=242;
if(mem[musaseg:ix*100+iy-101]=depment)and(depok=true)then icol:=depment;
cx:=ix-4;cy:=iy-3;ico:=true;drawmap;asm xor ax,ax;int $16;mov c1,ah;end;
case c1 of
#77:if(ix<mapx)then begin if(cx<98)then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)>13)then cx:=cx+1;ix:=ix+1;end;
#75:if(ix>1)then begin if(cx>-3)then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)<1)then cx:=cx-1;ix:=ix-1;end;
#72:if(iy>1)then begin if(cy>-3)then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)<1)then cy:=cy-1;iy:=iy-1;end;
#80:if(iy<mapy)then begin if(cy<98)then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)>13)then cy:=cy+1;iy:=iy+1;end;
end;
depok:=true;
for i:=1 to wo do if(plx[dgrp,i]=ix)and(ply[dgrp,i]=iy)then depok:=false;
i2:=ix;a2:=iy;
icol:=242;
if(mem[musaseg:ix*100+iy-101]=depment)and(depok=true)then icol:=depment;

until(c1=#28)and(mem[musaseg:ix*100+iy-101]=depment)and(depok=true);
plx[dgrp,wo]:=ix;ply[dgrp,wo]:=iy;

inftxt('Choose your facing.            ',15,1,0);
inc(ix);inc(iy);
fc[dgrp,wo]:=4;
icol:=242;
repeat
cx:=ix-4;cy:=iy-3;ico:=true;drawmap;asm xor ax,ax;int $16;mov c1,ah;end;
case c1 of
#77:if(rc(wo,dgrp,ix+1,iy)=true)then
begin if(cx<98)then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)>13)then cx:=cx+1;ix:=ix+1;end;
#75:if(rc(wo,dgrp,ix-1,iy)=true)then
begin if(cx>-3)then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)<1)then cx:=cx-1;ix:=ix-1;end;
#72:if(rc(wo,dgrp,ix,iy-1)=true)then
begin if(cy>-3)then if((ix-cx)-(iy-cy)>7)or((ix-cx)+(iy-cy)<1)then cy:=cy-1;iy:=iy-1;end;
#80:if(rc(wo,dgrp,ix,iy+1)=true)then
begin if(cy<98)then if((ix-cx)-(iy-cy)<-5)or((ix-cx)+(iy-cy)>13)then cy:=cy+1;iy:=iy+1;end;
end;

if(plx[dgrp,wo]=ix+1)and(ply[dgrp,wo]=iy+1)then fc[dgrp,wo]:=0;
if(plx[dgrp,wo]=ix)and(ply[dgrp,wo]=iy+1)then fc[dgrp,wo]:=1;
if(plx[dgrp,wo]=ix-1)and(ply[dgrp,wo]=iy+1)then fc[dgrp,wo]:=2;
if(plx[dgrp,wo]=ix-1)and(ply[dgrp,wo]=iy)then fc[dgrp,wo]:=3;
if(plx[dgrp,wo]=ix-1)and(ply[dgrp,wo]=iy-1)then fc[dgrp,wo]:=4;
if(plx[dgrp,wo]=ix)and(ply[dgrp,wo]=iy-1)then fc[dgrp,wo]:=5;
if(plx[dgrp,wo]=ix+1)and(ply[dgrp,wo]=iy-1)then fc[dgrp,wo]:=6;
if(plx[dgrp,wo]=ix+1)and(ply[dgrp,wo]=iy)then fc[dgrp,wo]:=7;

depok:=true;if(plx[dgrp,wo]=ix)and(ply[dgrp,wo]=iy)then depok:=false;
until(c1=#28)and(depok=true);

end;
fastfont('                       ',11,162,tcolo,bcolo,$a000,0,0);depment:=0;ico:=false;
inftxt(cle,15,2,0);
end;

procedure drop(grnu,plnu,invnu:byte;fever:boolean);
var wo1:word;
begin
if fever=false then begin inc(dritem);
itemx[dritem]:=plx[grnu,plnu];
itemy[dritem]:=ply[grnu,plnu];
itemt[dritem]:=invtype[grnu,plnu,invnu];
itema[dritem]:=invammo[grnu,plnu,invnu];
itemp[dritem]:=invprime[grnu,plnu,invnu];end;
itemex[dritem]:=grnu*warriors+plnu;

for wo1:=invnu to 15 do begin
invtype[grnu,plnu,wo1]:=invtype[grnu,plnu,wo1+1];
invammo[grnu,plnu,wo1]:=invammo[grnu,plnu,wo1+1];
invprime[grnu,plnu,wo1]:=invprime[grnu,plnu,wo1+1];
end;
invtype[grnu,plnu,15]:=0;
invammo[grnu,plnu,15]:=0;
invprime[grnu,plnu,15]:=0;
if(rarm[grnu,plnu]=invnu)then rarm[grnu,plnu]:=0;
if(larm[grnu,plnu]=invnu)then larm[grnu,plnu]:=0;
if(rarm[grnu,plnu]>invnu)then dec(rarm[grnu,plnu]);
if(larm[grnu,plnu]>invnu)then dec(larm[grnu,plnu]);
end;

procedure moving;
var esca,np:boolean;tfc:byte;begin moved:=false;
if(lochps[grp,pln,5]>0)or(lochps[grp,pln,6]>0) then begin
mc:=4;if fw=false then begin inc(mc,2);end;if fc[grp,pln]mod 2=0 then inc(mc,2);mc:=round(mc*tem2);
np:=false;tfc:=fc[grp,pln];if fw=false then inc (fc[grp,pln],4);if fc[grp,pln]>7 then dec(fc[grp,pln],8);

if(mps[grp,pln]<mc) then mpsflash;

case fc[grp,pln] of
0:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln]-1,ply[grp,pln]-1]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]-1)and(ply[a,i]=ply[grp,pln]-1)then
np:=true;if((plx[grp,pln]-cx)+(ply[grp,pln]-cy)<4) and (np=false) then begin dec(cx,2);dec(cy,2);end;
if np=false then begin dec(plx[grp,pln]);dec(ply[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln]-1,ply[grp,pln]-1]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

1:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln],ply[grp,pln]-1]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]) and (ply[a,i]=ply[grp,pln]-1) then
np:=true;if ((plx[grp,pln]-cx)-(ply[grp,pln]-cy)>6)or((plx[grp,pln]-cx)+(ply[grp,pln]-cy)<3)then if(np=false) then dec(cy,2);
if np=false then begin dec(ply[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln],ply[grp,pln]-1]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;


2:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln]+1,ply[grp,pln]-1]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]+1)and(ply[a,i]=ply[grp,pln]-1)then
np:=true;if((plx[grp,pln]-cx)-(ply[grp,pln]-cy)>5) and (np=false) then begin inc(cx,2);dec(cy,2);end;
if np=false then begin inc(plx[grp,pln]);dec(ply[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln]+1,ply[grp,pln]-1]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

3:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln]+1,ply[grp,pln]]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]+1)and(ply[a,i]=ply[grp,pln])then
np:=true;if((plx[grp,pln]-cx)-(ply[grp,pln]-cy)>6)or((plx[grp,pln]-cx)+(ply[grp,pln]-cy)>11)then if(np=false) then inc(cx,2);
if np=false then begin inc(plx[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln]+1,ply[grp,pln]]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

4:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln]+1,ply[grp,pln]+1]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]+1)and(ply[a,i]=ply[grp,pln]+1)then
np:=true;if((plx[grp,pln]-cx)+(ply[grp,pln]-cy)>12)and(np=false)then begin inc(cx,2);inc(cy,2);end;
if np=false then begin inc(plx[grp,pln]);inc(ply[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln]+1,ply[grp,pln]+1]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

5:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln],ply[grp,pln]+1]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln])and(ply[a,i]=ply[grp,pln]+1)then
np:=true;if((plx[grp,pln]-cx)-(ply[grp,pln]-cy)<-4)or((plx[grp,pln]-cx)+(ply[grp,pln]-cy)>12)then if(np=false)
then inc(cy,2);if np=false then begin inc(ply[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln],ply[grp,pln]+1]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

6:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln]-1,ply[grp,pln]+1]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]-1)and(ply[a,i]=ply[grp,pln]+1)then
np:=true;if((plx[grp,pln]-cx)-(ply[grp,pln]-cy)<-4)and(np=false) then begin dec(cx,2);inc(cy,2);end;
if np=false then begin dec(plx[grp,pln]);inc(ply[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln]-1,ply[grp,pln]+1]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

7:if(mps[grp,pln]>=mc)and(enter[map[plx[grp,pln]-1,ply[grp,pln]]]=true)then begin
for a:=0 to teams do for i:=1 to gr[a] do if dead[a,i]=false then if (plx[a,i]=plx[grp,pln]-1)and(ply[a,i]=ply[grp,pln])then
np:=true;if((plx[grp,pln]-cx)-(ply[grp,pln]-cy)<-4)or((plx[grp,pln]-cx)+(ply[grp,pln]-cy)<4)then if(np=false)then dec(cx,2);
if np=false then begin dec(plx[grp,pln]);dec(mps[grp,pln],mc);moved:=true;end;end else
if(mps[grp,pln]>=mc)and(map[plx[grp,pln]-1,ply[grp,pln]]=0)then begin

inftxt('Do you really want to escape ?  ',15,1,0);inftxt(cle,0,2,0);
repeat ch:=readk;until(ch=#21)or(ch=#49)or(ch=#1);
if ch=#1 then esca:=false;
if ch=#21 then esca:=true;

if esca=true then begin escaped[grp,pln]:=true;dead[grp,pln]:=true;nguy;end;
inftxt(cle,0,1,0);inftxt(cle,0,2,0);
end;

end;

if(moved=true)then play('walk.svs',10000);
fc[grp,pln]:=tfc;end;
end;

procedure itemtoseg;
var by1:byte;i,fisize:word;f:file;f1:file of byte;
    is:string;

const unregsize=390;

begin
{$IFNDEF unregistered}
is:='data\items.dat';
{$ELSE}
is:='gamedata\setia.dat';
{$ENDIF}
clear(itemseg,450);

assign(f1,is);
reset(f1);
{$IFNDEF unregistered}
fisize:=filesize(f1);
{$ELSE}
fisize:=unregsize;
{$ENDIF}
close(f1);
if fisize>=128 then begin
assign(f,is);
reset(f,fisize);blockread(f,mem[itemseg:1],1);close(f);end else
begin
assign(f1,is);
reset(f1);for i:=1 to fisize do begin read(f1,by1);mem[itemseg:i]:=by1;end;close(f1);end;

mem[itemseg:1501]:=3;s:='Small flare     ';
for a:=1 to 16 do mem[itemseg:1501+a]:=ord(s[a]);
mem[itemseg:1531]:=3;s:='Medium flare    ';
for a:=1 to 16 do mem[itemseg:1531+a]:=ord(s[a]);
mem[itemseg:1561]:=3;s:='Large flare     ';
for a:=1 to 16 do mem[itemseg:1561+a]:=ord(s[a]);
end;

procedure wepstoseg;
var by1:byte;i,fisize:word;f:file;f1:file of byte;
    ws:string;

const unregsize=1416;

begin
{$IFNDEF unregistered}
ws:='data\weapons.dat';
{$ELSE}
ws:='gamedata\setw.dat';
{$ENDIF}

clear(wepseg,1500);
assign(f1,ws);
reset(f1);
{$IFNDEF unregistered}
fisize:=filesize(f1);
{$ELSE}
fisize:=unregsize;
{$ENDIF}
close(f1);

weapon_amount:=fisize div 59;

if fisize>=128 then begin
assign(f,ws);
reset(f,fisize);
blockread(f,mem[wepseg:1],1);close(f);end else
begin
assign(f1,ws);
reset(f1);
for i:=1 to fisize do begin
read(f1,by1);mem[wepseg:i]:=by1;
end;close(f1);end;
end;

procedure explosion(x,y,ra,da,dafa:integer);
var val,exran:real;xpnew,xlo,ylo,texdam,exdam,exdam2,texdam2,rval:integer;la,li:byte;
    losby:byte;

begin
broken:=1;
drawx:=x;drawy:=y;drawrad:=ra/2;
explos:=true;play('explo.svs',8000);pntr:=false;ico:=false;
cx:=x-4;cy:=y-3;
if(control[grp]=1)or(debug=1)then drawmap;
for drawfra:=1 to 10 do begin
if(control[grp]=1)or(debug=1)then drawmap;wait(1);
end;drawfra:=0;
val:=0.5;if(control[grp]=1)or(debug=1)then drawmap;
repeat
for ylo:=y-ra to y+ra do
for xlo:=x-ra to x+ra do begin
exran:=sqrt(sqr(x-xlo)+sqr(y-ylo));
losby:=0;if(exran>val)and(exran<=val+0.5)then
begin
 {los(x,y,xlo,ylo,losseg,losofs,entseg,entofs);}
 line_of_sight(x,y,xlo,ylo);
 asm
 mov losby,al
 end;
{liofsi(x,y,xlo,ylo);}
end;
if(losby=1)or(exran=0)and(val=0.5)then begin
exdam:=round(da-(exran*dafa));if exdam<1 then exdam:=1;

if lightamo>0 then
for la:=1 to lightamo do
if(lightsx[la]=xlo)and(lightsy[la]=ylo)and(lightst[la]>0)and(lightst[la]<=3)
then
begin
lightsx[la]:=0;
lightsy[la]:=0;
lightst[la]:=0;
if la=lightamo then dec(lightamo);
end;

if(map[xlo,ylo]=1)then map[xlo,ylo]:=65;
if(map[xlo,ylo]=2)then map[xlo,ylo]:=66;
if(map[xlo,ylo]=3)then map[xlo,ylo]:=67;
if(map[xlo,ylo]=4)then map[xlo,ylo]:=68;
if(map[xlo,ylo]=42)and(exran>0)then begin map[xlo,ylo]:=65;explosion(xlo,ylo,5,27+random(14),5);end;
if(map[xlo,ylo]=43)and(exran>0)then begin map[xlo,ylo]:=65;explosion(xlo,ylo,6,42+random(14),5);end;
if(exdam>=walldam)and(map[xlo,ylo]>=5)and(map[xlo,ylo]<=17)then map[xlo,ylo]:=69;
if(exdam>=round(walldam*1.5))and(map[xlo,ylo]>=18)and(map[xlo,ylo]<=22)then map[xlo,ylo]:=69;
if(exdam>=walldam*2)and(map[xlo,ylo]=23)then map[xlo,ylo]:=69;
if(exdam>=round(walldam*1.5))and(map[xlo,ylo]>=24)and(map[xlo,ylo]<=27)then map[xlo,ylo]:=69;
if(exdam>=walldam)and(map[xlo,ylo]>=28)and(map[xlo,ylo]<=33)then map[xlo,ylo]:=69;

if(exdam>=doordam)and(map[xlo,ylo]>=34)and(map[xlo,ylo]<=35)then begin map[xlo,ylo]:=70;checkbomb(xlo,ylo);end;
if(exdam>=doordam)and(map[xlo,ylo]>=36)and(map[xlo,ylo]<=37)then map[xlo,ylo]:=70;
if(exdam>=doordam)and(map[xlo,ylo]>=38)and(map[xlo,ylo]<=39)then begin map[xlo,ylo]:=71;checkbomb(xlo,ylo);end;
if(exdam>=doordam)and(map[xlo,ylo]>=40)and(map[xlo,ylo]<=41)then map[xlo,ylo]:=71;

if(map[xlo,ylo]=42)or(map[xlo,ylo]=43)then map[xlo,ylo]:=65;
if(map[xlo,ylo]=44)then map[xlo,ylo]:=75;
if(map[xlo,ylo]=45)then map[xlo,ylo]:=76;
if(map[xlo,ylo]>=46)and(map[xlo,ylo]<=54)then map[xlo,ylo]:=79;
if(map[xlo,ylo]=55)then map[xlo,ylo]:=74;
if(map[xlo,ylo]=56)then map[xlo,ylo]:=72;
if(map[xlo,ylo]=57)or(map[xlo,ylo]=58)then map[xlo,ylo]:=73;
if(map[xlo,ylo]=59)or(map[xlo,ylo]=60)then map[xlo,ylo]:=78;
if(map[xlo,ylo]>=61)and(map[xlo,ylo]<=64)then map[xlo,ylo]:=77;
pntr:=true;

for la:=0 to teams do for li:=1 to gr[la] do
if(plx[la,li]=xlo)and(ply[la,li]=ylo)and(dead[la,li]=false)then begin{1}
cx:=plx[la,li]-4;cy:=ply[la,li]-3;if(control[grp]=1)or(debug=1)then drawmap;

xpnew:=0;wo:=0;for i:=1 to 6 do begin inc(wo,lochps[la,li,i]);inc(wo,locaps[la,li,i]);end;

for nu:=1 to 6 do begin{2} rval:=random(90);inc(rval,10);
texdam2:=round(exdam*rval/100);inc(xpnew,texdam2);
texdam:=texdam2-locaps[la,li,nu];if texdam<0 then texdam:=0;
if(guard=false)and(la<>grp)then inc(penet[exgrp],texdam);
if(guard=true)and(la<>guardgrp)then inc(penet[exgrp],texdam);

dec(lochps[la,li,nu],texdam);
dec(locaps[la,li,nu],round(texdam2/2));if locaps[la,li,nu]<0 then locaps[la,li,nu]:=0;
if(lochps[la,li,nu]<0)then begin{3} tm:=-lochps[la,li,nu];
if(guard=false)and(la<>grp)then dec(penet[exgrp],tm);
if(guard=true)and(la<>guardgrp)then dec(penet[exgrp],tm);

lochps[la,li,nu]:=0;if(tm>0)and(nu<>1)and(nu<>2)then begin{4}
texdam:=tm-locaps[la,li,2];
if(guard=false)and(la<>grp)then inc(penet[exgrp],texdam);
if(guard=true)and(la<>guardgrp)then inc(penet[exgrp],texdam);
if texdam<0 then texdam:=0;dec(lochps[la,li,2],texdam);
dec(locaps[la,li,2],round(tm/2));if locaps[la,li,2]<0 then locaps[la,li,2]:=0;end{4};end;{3}end;{2}
if(lochps[la,li,2]<0)then begin
if(guard=false)and(la<>grp)then inc(penet[exgrp],lochps[la,li,2]);
if(guard=true)and(la<>guardgrp)then inc(penet[exgrp],lochps[la,li,2]);
end;
if(lochps[la,li,2]<0)then lochps[la,li,2]:=0;

if(xpnew>wo)then xpnew:=wo;
if(guard=false)and(exgrp<>la)then inc(dcaused[exgrp],xpnew);
if(guard=true)and(exgrp<>la)then inc(dcaused[exgrp],xpnew);
if(guard=false)and(ally[exgrp]<>ally[la])then inc(xpgain[exgrp,expln],xpnew);
if(guard=true)and(ally[exgrp]<>ally[la])then inc(xpgain[exgrp,expln],xpnew);

if(control[grp]=1)and(fastmode=false)then begin
str(xpnew,s);inftxt('    points of damage caused.    ',2,1,0);inftxt(s,2,1,0);repeat ch:=readk;until ch=#28;
end;

if(lochps[la,li,1]<=0)or(lochps[la,li,2]<=0)then begin
for by1:=1 to 15 do if(invtype[la,li,1]<>0)then drop(la,li,1,false);
dead[la,li]:=true;
if(la<>exgrp)then inc(killed[exgrp]);

if(control[grp]=1)or(debug=1)then drawmap;
play('death.svs',10000);

if(fastmode=false) then begin
if(control[grp]=1)or(debug=1)then effect(17,1);
wait(50);
end else
begin
if(control[grp]=1)or(debug=1)then effect(17,4);
wait(5);
end;
end;

if(mem[wepseg:(invtype[la,li,rarm[la,li]]-1)*59+32]<>2)and(lochps[la,li,3]=0)and
(invtype[la,li,rarm[la,li]]<>0)then begin drop(la,li,rarm[la,li],false);rarm[la,li]:=0;end;
if (mem[wepseg:(invtype[la,li,larm[la,li]]-1)*59+32]<>2)and(lochps[la,li,4]=0)and
(invtype[la,li,larm[la,li]]<>0)then begin drop(la,li,larm[la,li],false);larm[la,li]:=0;end;
if((mem[wepseg:(invtype[la,li,rarm[la,li]]-1)*59+32]=2))and(invtype[la,li,rarm[la,li]]<>0)then
if(lochps[la,li,3]=0)or(lochps[la,li,4]=0)then begin drop(la,li,rarm[la,li],false);rarm[la,li]:=0;larm[la,li]:=0;end;
if(control[grp]=1)then begin inftxt(cle,0,1,0);inftxt(cle,0,2,0);end;
end;{1}
end;end;val:=val+0.5;
until val>=ra/2;
if(control[grp]=1)or(debug=1)then drawmap;if(dead[grp,pln]=true)then nguy;
explos:=false;
end;

procedure checkbomb(bx,by:byte);
var wof1,test,c3:word;xdam1,ydam1,exprad1,expfact1:byte;
begin
for test:=1 to dritem do
if(itemhide[test]=1)and(bx=itemx[test])and(by=itemy[test])then begin
wof1:=(itemt[test]-1)*59+1;xdam1:=mem[wepseg:wof1+25];ydam1:=mem[wepseg:wof1+26];
expfact1:=mem[wepseg:wof1+27];exprad1:=mem[wepseg:wof1+28];

for c3:=test to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;

explosion(bx,by,exprad1,ydam1+random(xdam1)+1,expfact1);

pntr:=true;
dell;
itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;
dec(dritem);
end;
end;

procedure usedoor;
var nodoor:boolean;test,c3:word;
begin nodoor:=false;doped:=false;broken:=0;

if(mps[grp,pln]<4) then mpsflash;

for a:=0 to teams do for i:=1 to gr[a] do
if(plx[grp,pln]+fcx[fc[grp,pln]]=plx[a,i])and(ply[grp,pln]+fcy[fc[grp,pln]]=ply[a,i])then nodoor:=true;
if nodoor=false then begin if(oply[map[plx[grp,pln]+fcx[fc[grp,pln]],ply[grp,pln]+fcy[fc[grp,pln]]]]=true)and(mps[grp,pln]>3)
then begin play('door.svs',10000);dec(mps[grp,pln],4);doped:=true;
if(open[map[plx[grp,pln]+fcx[fc[grp,pln]],ply[grp,pln]+fcy[fc[grp,pln]]]]=true)
then dec(map[plx[grp,pln]+fcx[fc[grp,pln]],ply[grp,pln]+fcy[fc[grp,pln]]],2)
else inc(map[plx[grp,pln]+fcx[fc[grp,pln]],ply[grp,pln]+fcy[fc[grp,pln]]],2);
if(control[grp]=1)or(debug=1)then drawmap;

for test:=1 to dritem do  { Traptest }
if(itemhide[test]=1)and(plx[grp,pln]+fcx[fc[grp,pln]]=itemx[test])and(ply[grp,pln]+fcy[fc[grp,pln]]=itemy[test])then begin
readwep(itemt[test]);

if(control[grp]=1)or(debug=1)then begin drawmap;
inftxt('That door was trapped !         ',2,1,0);
inftxt(cle,0,2,0);asm xor ax,ax;int $16;end;inftxt(cle,0,1,0);
end;

exgrp:=0;expln:=itemex[test];
if(itemex[test]>warriors)then begin exgrp:=1;expln:=itemex[test]-warriors;end;
if(itemex[test]>(2*warriors))then begin exgrp:=2;expln:=itemex[test]-(2*warriors);end;
if(itemex[test]>(3*warriors))then begin exgrp:=3;expln:=itemex[test]-(3*warriors);end;

for c3:=test to dritem do begin itemx[c3]:=itemx[c3+1];itemy[c3]:=itemy[c3+1];
itemt[c3]:=itemt[c3+1];itema[c3]:=itema[c3+1];itemp[c3]:=itemp[c3+1];itemhide[c3]:=itemhide[c3+1];end;

explosion(plx[grp,pln]+fcx[fc[grp,pln]],ply[grp,pln]+fcy[fc[grp,pln]],exprad,ydam+random(xdam)+1,expfact);
pntr:=true;
dell;

itemx[c3]:=0;itemy[c3]:=0;itemt[c3]:=0;itema[c3]:=0;itemp[c3]:=0;itemhide[c3]:=0;
dec(dritem);cnt;
end;  { Traptest }
end;end;
if(doped=true)or(broken=1)then calclights;if(control[grp]=1)then see;
end;

procedure health;
procedure text(x,y:integer;text:string;col:byte);
begin
fastfont(text,x,y,col,0,ownseg,1,0);
end;
begin
clear(ownseg,16000);
loadpic('gfx\thspic.svf');
if lochps[grp,pln,1]=round(tothps[grp,pln]*0.08) then a:=3 else a:=14;if lochps[grp,pln,1]=0 then a:=2;
str(lochps[grp,pln,1],s);text(69,18,s,a);text(86,18,'/',15);str(round(tothps[grp,pln]*0.08),s);text(94,18,s,15);
if lochps[grp,pln,2]=round(tothps[grp,pln]*0.28) then a:=3 else a:=14;if lochps[grp,pln,2]=0 then a:=2;
str(lochps[grp,pln,2],s);text(69,39,s,a);text(86,39,'/',15);str(round(tothps[grp,pln]*0.28),s);text(94,39,s,15);
if lochps[grp,pln,3]=round(tothps[grp,pln]*0.16) then a:=3 else a:=14;if lochps[grp,pln,3]=0 then a:=2;
str(lochps[grp,pln,3],s);text(69,71,s,a);text(86,71,'/',15);str(round(tothps[grp,pln]*0.16),s);text(94,71,s,15);
if lochps[grp,pln,4]=round(tothps[grp,pln]*0.16) then a:=3 else a:=14;if lochps[grp,pln,4]=0 then a:=2;
str(lochps[grp,pln,4],s);text(69,52,s,a);text(86,52,'/',15);str(round(tothps[grp,pln]*0.16),s);text(94,52,s,15);
if lochps[grp,pln,5]=round(tothps[grp,pln]*0.16) then a:=3 else a:=14;if lochps[grp,pln,5]=0 then a:=2;
str(lochps[grp,pln,5],s);text(69,109,s,a);text(86,109,'/',15);str(round(tothps[grp,pln]*0.16),s);text(94,109,s,15);
if lochps[grp,pln,6]=round(tothps[grp,pln]*0.16) then a:=3 else a:=14;if lochps[grp,pln,6]=0 then a:=2;
str(lochps[grp,pln,6],s);text(69,95,s,a);text(86,95,'/',15);str(round(tothps[grp,pln]*0.16),s);text(94,95,s,15);
if locaps[grp,pln,1]=totaps[grp,pln,1] then a:=3 else a:=14;if locaps[grp,pln,1]=0 then a:=2;
str(locaps[grp,pln,1],s);text(117,18,s,a);text(134,18,'/',15);str(totaps[grp,pln,1],s);text(142,18,s,15);
if locaps[grp,pln,2]=totaps[grp,pln,2] then a:=3 else a:=14;if locaps[grp,pln,2]=0 then a:=2;
str(locaps[grp,pln,2],s);text(117,39,s,a);text(134,39,'/',15);str(totaps[grp,pln,2],s);text(142,39,s,15);
if locaps[grp,pln,3]=totaps[grp,pln,3] then a:=3 else a:=14;if locaps[grp,pln,3]=0 then a:=2;
str(locaps[grp,pln,3],s);text(117,71,s,a);text(134,71,'/',15);str(totaps[grp,pln,3],s);text(142,71,s,15);
if locaps[grp,pln,4]=totaps[grp,pln,4] then a:=3 else a:=14;if locaps[grp,pln,4]=0 then a:=2;
str(locaps[grp,pln,4],s);text(117,52,s,a);text(134,52,'/',15);str(totaps[grp,pln,4],s);text(142,52,s,15);
if locaps[grp,pln,5]=totaps[grp,pln,5] then a:=3 else a:=14;if locaps[grp,pln,5]=0 then a:=2;
str(locaps[grp,pln,5],s);text(117,109,s,a);text(134,109,'/',15);str(totaps[grp,pln,5],s);text(142,109,s,15);
if locaps[grp,pln,6]=totaps[grp,pln,6] then a:=3 else a:=14;if locaps[grp,pln,6]=0 then a:=2;
str(locaps[grp,pln,6],s);text(117,95,s,a);text(134,95,'/',15);str(totaps[grp,pln,6],s);text(142,95,s,15);

wo:=0;for a:=1 to 6 do inc(wo,lochps[grp,pln,a]);
bleed[grp,pln]:=tothps[grp,pln]-wo-bleeded[grp,pln];
bleed[grp,pln]:=
round(bleed[grp,pln]/tothps[grp,pln]*bleedc*hfactor(grp,pln));
if(bleed[grp,pln]<0)then bleed[grp,pln]:=0;str(bleed[grp,pln],s);
if(bleed[grp,pln]=0)then a:=3 else a:=2;
text(79,139,s,a);

for i:=0 to 157 do move_custom(mem[ownseg:i*320],mem[$a000:(i+22)*320+75],175);
repeat ch:=readk;until ch<>#0;
init(2);see;
end;

procedure fastfont(snew:string;x,y,col,bcol,toseg,tpar,shad:word);
begin
if(tpar=0)and(shad=0)then fontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=0)then fontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,mem[seg(snew):ofs(snew)]);
if(tpar=0)and(shad=1)then sfontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=1)then sfontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,mem[seg(snew):ofs(snew)]);
end;

end.

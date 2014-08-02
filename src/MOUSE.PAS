{$F+}
unit mouse;
interface
const mpixs=24;
const mcord:array[0..mpixs] of word=(
0,1,320,321,322,640,641,642,643,960,961,962,963,964,1280,1281,1282,1283,1284,1285,1600,1601,1602,1603,1920);

const mcol:array[0..mpixs] of byte=(
253,255,253,253,255,253,253,253,255,253,253,253,253,255,253,253,253,253,254,255,253,253,254,254,254);

const mlimx:array[0..mpixs] of word=(
320,319,320,319,318,320,319,318,317,320,319,318,317,316,320,319,318,317,316,315,320,319,318,317,320);

const mlimy:array[0..mpixs] of byte=(
200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,198,198,198,198,197);

const mlimy1:array[0..mpixs] of byte=(
160,160,159,159,159,158,158,158,158,157,157,157,157,157,156,156,156,156,156,156,155,155,155,155,154);

var pcol1,pcol2,tst,swp:array[0..mpixs] of byte;
    mx,my,pmx,pmy,cord,pcord,tp,lp,rp:word;
    mouseon:byte;

function checkmouse:byte;
procedure initmouse;
procedure mousetoseg(segm:word);
procedure updatemouse;

implementation

function checkmouse:byte;
var mcheck:word;
begin
asm xor ax,ax;int $33;mov mcheck,ax;mov ax,2;int $33;end;
checkmouse:=mcheck;
end;

procedure initmouse;
begin
asm mov cx,320;mov dx,100;mov ax,4;int $33;mov mx,160;mov my,100;end;
mouseon:=1;
end;

procedure mousetoseg(segm:word);
var k:byte;
begin
cord:=mx+(my shl 8)+(my shl 6);
for k:=0 to mpixs do if(mx<mlimx[k])and(my<mlimy1[k])then mem[segm:cord+mcord[k]]:=mcol[k];
end;

procedure updatemouse;
var k,ki:byte;
begin
if(mouseon=1)then begin
asm mov ax,mx;mov pmx,ax;mov ax,my;mov pmy,ax;      { pmx=mx, pmy=my. }
mov ax,3;int $33;and bx,3;mov tp,bx;shr cx,1;mov mx,cx;mov my,dx;end;
lp:=0;rp:=0;if(tp=1)or(tp=3)then lp:=1;if(tp=2)or(tp=3)then rp:=1; { Buttons }
cord:=mx+(my shl 8)+(my shl 6);pcord:=pmx+(pmy shl 8)+(pmy shl 6);
for k:=0 to mpixs do begin tst[k]:=0;pcol2[k]:=mem[$a000:cord+mcord[k]];end;
{ Uuden pointterin alta graffat talteen, varmuuden vuoksi kaikki }
for k:=0 to mpixs do for ki:=0 to mpixs do if(tst[k]=0)and((pcord+mcord[k])=(cord+mcord[ki]))then
begin swp[k]:=ki;tst[k]:=1;ki:=26;end;
{ Tutkitaan peittyyk” vanhat, swp[k] n„ytt„„ mik„ uusi piste peit„„ vanhan }
for k:=0 to mpixs do if(tst[k]=1)then if(mem[$a000:pcord+mcord[k]]>=253)then pcol2[swp[k]]:=pcol1[k];
{ Jos uusi peit„„ ja vanhaa on j„ljell„, niin pcol2[swp[k]]=pcol1[k]; }
for k:=0 to mpixs do if(tst[k]=0)then if(mem[$a000:pcord+mcord[k]]>=253)then mem[$a000:pcord+mcord[k]]:=pcol1[k];
{ Jos uusi ei peit„ vanhaa, niin vanha takas ruutuun }
for k:=0 to mpixs do if(mx<mlimx[k])and(my<mlimy[k])then mem[$a000:cord+mcord[k]]:=mcol[k];
{ Pointteri ruutuun }
for k:=0 to mpixs do pcol1[k]:=pcol2[k]; { Pcol1:een tulevan pointterin alus }
end;
end;

end.
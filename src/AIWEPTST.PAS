const hpsbonus:array[2..5]of byte=(10,20,40,65);
const mpsbonus:array[2..5]of byte=(10,20,40,65);
const reactbonus:array[2..5]of byte=(10,20,30,48);
const firbonus:array[2..5]of byte=(10,25,50,75);
const melbonus:array[2..5]of byte=(10,25,50,75);
const throbonus:array[2..5]of byte=(10,25,50,75);
const apsbonus:array[2..5]of byte=(0,2,5,10);
const armrand:array[2..5]of byte=(70,80,100,40);
const armplus:array[2..5]of byte=(0,5,25,80);
const weprand:array[2..5]of byte=(70,80,100,40);
const wepplus:array[2..5]of byte=(0,5,25,80);
const totalweps:array[2..5]of byte=(1,1,2,2);
const totalclips:array[2..5]of byte=(1,2,2,3);

var ma:pointer;s:string;code:integer;
    wepseg,i,a,tm1,tm2,groups,wo,wo1,wo2,tlo,thi:word;by,la:byte;
    apros,ipros,wpros,mpros,epros:real;
    afirst,alast,ifirst,ilast,wfirst,wlast,mfirst,mlast,efirst,elast:byte;
    value,order:array[1..100] of longint;
    invtype:array[1..15] of byte;

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

procedure wepstoseg;
var by1:byte;i,fisize:word;f:file;f1:file of byte;begin
for wo:=0 to 6500 do mem[wepseg:wo]:=0;
assign(f1,'weapons.dat');reset(f1);fisize:=filesize(f1);close(f1);
if fisize>=128 then begin assign(f,'weapons.dat');reset(f,fisize);blockread(f,mem[wepseg:1],1);close(f);end else
begin assign(f1,'weapons.dat');reset(f1);for i:=1 to fisize do begin read(f1,by1);mem[wepseg:i]:=by1;end;close(f1);end;
end;


begin
randomize;
getmem(ma,7000);wepseg:=seg(ma^);
wepstoseg;
wfirst:=0;wlast:=0;


                                  { Weapons into order }
for wo:=1 to 100 do begin order[wo]:=wo;la:=1;s:='      ';
for a:=1 to 6 do begin by:=mem[wepseg:wo*59-42+a];
if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,value[wo],code);
end;                              { Weapons into order }

for i:=1 to 100 do if(wfirst=0)then if(mem[wepseg:i*59-58]=1)or(mem[wepseg:i*59-58]=2)then wfirst:=i;
for i:=1 to 100 do if(mem[wepseg:i*59-58]=3)and(wlast=0)and(i>=wfirst)then wlast:=i-1;
wpros:=(wlast-wfirst)/100;
quicksort(wfirst,wlast);

wo:=round(wpros*wepplus[5]);
wo:=1+wo+random(round(wpros*weprand[5]));
if(wo>(1+wlast-wfirst))then wo:=1+wlast-wfirst;if(wo<1)then wo:=1;
invtype[1]:=order[wo]+wfirst-1;
if(wfirst=wlast)then invtype[1]:=wfirst;
if(wfirst=0)then invtype[1]:=0;

mem[seg(s):ofs(s)]:=16;
for a:=1 to 16 do begin by:=mem[wepseg:(invtype[1])*59-59+a+1];s[a]:=chr(by);end;
writeln;writeln(s);
writeln(invtype[1]);
writeln(value[wo]);
asm xor ax,ax;int $16;end;
end.







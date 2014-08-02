var ma:pointer;s:string;code:integer;pros:real;
    arminuse,first,last,by,la:byte;itemseg,wo,i,a:word;
    value,order:array[1..100] of longint;

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

procedure itemtoseg;
var by1:byte;i,fisize:word;f:file;f1:file of byte;
begin
getmem(ma,1900);itemseg:=seg(ma^);
for wo:=0 to 1900 do mem[itemseg:wo]:=0;
assign(f1,'items.dat');reset(f1);fisize:=filesize(f1);close(f1);
if fisize>=128 then begin assign(f,'items.dat');reset(f,fisize);blockread(f,mem[itemseg:1],1);close(f);end else
begin assign(f1,'items.dat');reset(f1);for i:=1 to fisize do begin read(f1,by1);mem[itemseg:i]:=by1;end;close(f1);end;
mem[itemseg:1501]:=3;s:='Small flare     ';
for a:=1 to 16 do mem[itemseg:1501+a]:=ord(s[a]);
mem[itemseg:1531]:=3;s:='Medium flare    ';
for a:=1 to 16 do mem[itemseg:1531+a]:=ord(s[a]);
mem[itemseg:1561]:=3;s:='Large flare     ';
for a:=1 to 16 do mem[itemseg:1561+a]:=ord(s[a]);
end;

procedure sortitems;
begin
for wo:=1 to 50 do begin order[wo]:=wo;la:=1;s:='      ';
for a:=1 to 6 do begin by:=mem[itemseg:wo*30-13+a];
if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,value[wo],code);end;
end;

begin
randomize;itemtoseg;

sortitems;                        { Select armors }
first:=0;last:=50;
for i:=1 to 50 do if(mem[itemseg:i*30-29]=1)and(first=0)then first:=i;
for i:=1 to 50 do if(mem[itemseg:i*30-29]=0)and(last=50)and(i>=first)then last:=i-1;
pros:=(last-first+1)/100;
quicksort(first,last);

wo:=round(pros*0);
wo:=1+wo+random(round(pros*100));
if(wo>(last-first))then wo:=1+last-first;if(wo<1)then wo:=1;

arminuse:=order[first+wo-1];         { The new magical one }

arminuse:=order[wo]+first-1;         { The old mystery one }

if(first=last)then arminuse:=first;
if(first=0)then arminuse:=0;

mem[seg(s):ofs(s)]:=16;
for a:=1 to 16 do s[a]:=chr(mem[itemseg:arminuse*30+a-29]);
writeln;writeln(s);
writeln(arminuse);
writeln(value[first+wo-1]);
asm xor ax,ax;int $16;end;
end.

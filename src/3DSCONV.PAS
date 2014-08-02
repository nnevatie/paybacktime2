uses utils;

const s=1000;

var u,b,wo,i,a:longint;
    dx,dy:array[0..2] of integer;
    segi:word;
    p:pointer;
    xco,yco,zco:array[1..s] of integer;
    facea,faceb,facec:array[1..s] of word;
    file1:file;file2:file of byte;le:longint;
    fit:text;
    st1:string;
    temps:string[10];
    t,vertices,faces:longint;
    code:integer;

begin

if paramcount<2 then begin
writeln('Fatal mis-usage encountered, not enough parameters! ');
writeln('Source and destination filenames expected.');
halt;
end;

getmem(p,64000);
segi:=seg(p^);
st1:=paramstr(1);
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[segi:0],1);close(file1);

a:=0;
for wo:=0 to le do
if chr(mem[segi:wo])=':' then begin inc(a);if a=3 then i:=wo;end;

for wo:=0 to 10 do temps[wo]:=#0;
a:=0;
for wo:=1 to 4 do
if mem[segi:i+wo+1]<>32 then
begin
temps[wo]:=chr(mem[segi:i+wo+1]);
inc(a);
end;
mem[seg(temps):ofs(temps)]:=a;
val(temps,vertices,code);

writeln('Found VERTICES... - ',vertices,' -');
asm xor ax,ax;int 16h;end;

a:=0;
i:=0;
for wo:=0 to le do
if chr(mem[segi:wo])=':' then begin inc(a);if a=4 then i:=wo;end;

for wo:=0 to 10 do mem[seg(temps):ofs(temps)]:=0;
a:=0;
for wo:=1 to 4 do
if(mem[segi:i+wo+1]<>32)and(mem[segi:i+wo+1]<>13) then
begin
temps[wo]:=chr(mem[segi:i+wo+1]);
inc(a);
end;
mem[seg(temps):ofs(temps)]:=a;
val(temps,faces,code);

writeln('Found FACES...    - ',faces,' -');
asm xor ax,ax;int 16h;end;

{faces:=12;}
i:=1;
b:=1;
for t:=0 to vertices-1 do begin

a:=0;
for wo:=0 to le do  { Take the X-value }
if chr(mem[segi:wo])='X' then begin
if i>0 then dec(i);
if (a=0)and(i=0) then a:=wo;
end;
for wo:=0 to 10 do mem[seg(temps):ofs(temps)+wo]:=0;
wo:=3;
u:=0;
repeat
temps[wo-2]:=chr(mem[segi:a+wo]);
inc(u);
inc(wo);
until(chr(mem[segi:a+wo])='.')or(chr(mem[segi:a+wo])=' ');
mem[seg(temps):ofs(temps)]:=u;
val(temps,xco[t],code);
writeln('t=',t,' xco=',xco[t]);

i:=b;
a:=0;
for wo:=0 to le do  { Take the Y-value }
if chr(mem[segi:wo])='Y' then begin
if i>0 then dec(i);
if (a=0)and(i=0) then a:=wo;
end;
for wo:=0 to 10 do mem[seg(temps):ofs(temps)+wo]:=0;
wo:=3;
u:=0;
repeat
temps[wo-2]:=chr(mem[segi:a+wo]);
inc(u);
inc(wo);
until (chr(mem[segi:a+wo])='.')or(chr(mem[segi:a+wo])=' ') ;
mem[seg(temps):ofs(temps)]:=u;
val(temps,yco[t],code);
writeln(yco[t]);

i:=b;
a:=0;
for wo:=0 to le do  { Take the Z-value }
if chr(mem[segi:wo])='Z' then begin
if i>0 then dec(i);
if (a=0)and(i=0) then a:=wo;
end;
for wo:=0 to 10 do mem[seg(temps):ofs(temps)+wo]:=0;
wo:=3;
u:=0;
repeat
temps[wo-2]:=chr(mem[segi:a+wo]);
inc(u);
inc(wo);
until(chr(mem[segi:a+wo])='.')or(chr(mem[segi:a+wo])=' ');
mem[seg(temps):ofs(temps)]:=u;
val(temps,zco[t],code);
writeln(zco[t]);

inc(b);
i:=b;
end;

i:=1;
b:=1;
for t:=0 to faces-1 do begin
i:=b+t*2;
a:=0;
for wo:=10 to le do  { Take the 1st Facepoint }
if chr(mem[segi:wo])='A' then begin
if i>0 then dec(i);
if (a=0)and(i=0) then a:=wo;
end;
for wo:=0 to 10 do mem[seg(temps):ofs(temps)+wo]:=0;
wo:=2;
u:=0;
repeat
temps[wo-1]:=chr(mem[segi:a+wo]);
inc(u);
inc(wo);
until chr(mem[segi:a+wo])=' ';
mem[seg(temps):ofs(temps)]:=u;
val(temps,facea[t],code);
{writeln(facea[t]);}

i:=b+t*2;
a:=0;
for wo:=100 to le do  { Take the 2nd Facepoint }
if chr(mem[segi:wo])='B' then begin
if i>0 then dec(i);
if (a=0)and(i=0) then a:=wo;
end;
for wo:=0 to 10 do mem[seg(temps):ofs(temps)+wo]:=0;
wo:=2;
u:=0;
repeat
temps[wo-1]:=chr(mem[segi:a+wo]);
inc(u);
inc(wo);
until chr(mem[segi:a+wo])=' ';
mem[seg(temps):ofs(temps)]:=u;
val(temps,faceb[t],code);
{writeln(faceb[t]);}

i:=b+t*2;
a:=0;
for wo:=100 to le do  { Take the 2nd Facepoint }
if chr(mem[segi:wo])='C' then begin
if i>0 then dec(i);
if (a=0)and(i=0) then a:=wo;
end;
for wo:=0 to 10 do mem[seg(temps):ofs(temps)+wo]:=0;
wo:=2;
u:=0;
repeat
temps[wo-1]:=chr(mem[segi:a+wo]);
inc(u);
inc(wo);
until chr(mem[segi:a+wo])=' ';
mem[seg(temps):ofs(temps)]:=u;
val(temps,facec[t],code);
{writeln(facec[t]);}

inc(b);
i:=b;
end;

assign(fit,paramstr(2));

rewrite(fit);
write(fit,'const vertices=',vertices,';');
writeln(fit);
write(fit,'const faces=',faces,';');

for i:=1 to 2 do writeln(fit);
write(fit,'const xcords:array[0..vertices-1] of integer=(');
writeln(fit);
for i:=0 to vertices-1 do begin
write(fit,xco[i]);
if (i mod (vertices-1)<>0)or(i=0)then write(fit,',');
if (i mod 16=0)and(i<>0)then writeln(fit);
end;
write(fit,');');

for i:=1 to 2 do writeln(fit);
write(fit,'const ycords:array[0..vertices-1] of integer=(');
writeln(fit);
for i:=0 to vertices-1 do begin
write(fit,yco[i]);
if (i mod (vertices-1)<>0)or(i=0)then write(fit,',');
if (i mod 16=0)and(i<>0)then writeln(fit);
end;
write(fit,');');

for i:=1 to 2 do writeln(fit);
write(fit,'const zcords:array[0..vertices-1] of integer=(');
writeln(fit);
for i:=0 to vertices-1 do begin
write(fit,zco[i]);
if (i mod (vertices-1)<>0)or(i=0)then write(fit,',');
if (i mod 16=0)and(i<>0)then writeln(fit);
end;
write(fit,');');

for i:=1 to 2 do writeln(fit);
write(fit,'const facea:array[0..faces-1] of word=(');
writeln(fit);
for i:=0 to faces-1 do begin
write(fit,facea[i]);
if (i mod (faces-1)<>0)or(i=0)then write(fit,',');
if (i mod 16=0)and(i<>0)then writeln(fit);
end;
write(fit,');');

for i:=1 to 2 do writeln(fit);
write(fit,'const faceb:array[0..faces-1] of word=(');
writeln(fit);
for i:=0 to faces-1 do begin
write(fit,faceb[i]);
if (i mod (faces-1)<>0)or(i=0)then write(fit,',');
if (i mod 16=0)and(i<>0)then writeln(fit);
end;
write(fit,');');

for i:=1 to 2 do writeln(fit);
write(fit,'const facec:array[0..faces-1] of word=(');
writeln(fit);
for i:=0 to faces-1 do begin
write(fit,facec[i]);
if (i mod (faces-1)<>0)or(i=0)then write(fit,',');
if (i mod 16=0)and(i<>0)then writeln(fit);
end;
write(fit,');');
close(fit);


setvideo(19);
for i:=0 to faces-1 do
begin
dx[0]:=(xco[facea[i]] shl 6) div (zco[facea[i]]+500)+160;
dy[0]:=(yco[facea[i]] shl 6) div (zco[facea[i]]+500)+100;
dx[1]:=(xco[faceb[i]] shl 6) div (zco[faceb[i]]+500)+160;
dy[1]:=(yco[faceb[i]] shl 6) div (zco[faceb[i]]+500)+100;
dx[2]:=(xco[facec[i]] shl 6) div (zco[facec[i]]+500)+160;
dy[2]:=(yco[facec[i]] shl 6) div (zco[facec[i]]+500)+100;
dline(dx[0],dy[0],dx[1],dy[1],15,$a000);
dline(dx[1],dy[1],dx[2],dy[2],15,$a000);
dline(dx[1],dy[1],dx[0],dy[0],15,$a000);
end;
asm xor ax,ax;int 16h;end;
setvideo(3);


end.

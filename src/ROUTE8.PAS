{$F+}
{$M 65520,0,130000}
const mx=99;my=99;dist1=500;
var dist,ax,ay,lx,ly,x,y,wo,ownseg,mapseg:word;
    ma:pointer;f:file;

{$L ROUTE.OBJ }
procedure routestart(seg1,seg2,x,y,lx1,ly1,maxdist:word);external;

procedure wait(t:longint);
var w:longint;
begin
for w:=1 to t do
asm
mov dx,$3da;@vert1:in al,dx;test al,8;jz @vert1;@vert2:in al,dx;test al,8;jnz @vert2;
end;
end;

procedure clean(cleanseg,amount:word);assembler;
asm
db $66;xor ax,ax
mov cx,amount
shr cx,2
mov es,cleanseg
xor di,di
cld
db $66;rep stosw
end;

procedure wipe(seg1,seg2,ofs1,ofs2,amount:word);assembler;
asm
push ds
mov es,seg2
mov di,ofs2
mov ds,seg1
mov si,ofs1
mov cx,amount
shr cx,2
db $66;rep movsw
pop ds
end;

procedure drawroute8;
var x,y:byte;wo:word;
begin
x:=1;y:=1;
for wo:=1 to dist do begin
if(mem[ownseg:50000+wo]=0)then begin dec(y);end;
if(mem[ownseg:50000+wo]=1)then begin dec(y);inc(x);end;
if(mem[ownseg:50000+wo]=2)then begin inc(x);end;
if(mem[ownseg:50000+wo]=3)then begin inc(y);inc(x);end;
if(mem[ownseg:50000+wo]=4)then begin inc(y);end;
if(mem[ownseg:50000+wo]=5)then begin inc(y);dec(x);end;
if(mem[ownseg:50000+wo]=6)then begin dec(x);end;
if(mem[ownseg:50000+wo]=7)then begin dec(y);dec(x);end;
mem[$a000:y*320+x]:=14;wait(1);
end;
end;

begin
randomize;
asm mov ax,13h;int 10h;end;
getmem(ma,64000);ownseg:=seg(ma^);clean(ownseg,64000);
getmem(ma,64000);mapseg:=seg(ma^);clean(mapseg,64000);
clean($a000,64000);
for x:=0 to mx do begin mem[mapseg:x]:=1;mem[mapseg:my*128+x]:=1;end;
for y:=0 to my do begin mem[mapseg:y*128]:=1;mem[mapseg:my+128*y]:=1;end;

{for x:=0 to 20000 do mem[mapseg:random(my)*320+random(mx)]:=1;}
assign(f,'route.raw');reset(f,64000);blockread(f,mem[$a000:0],1);close(f);

for wo:=0 to 120 do wipe($a000,mapseg,320*wo,wo shl 7,128);
{for wo:=0 to 120 do wipe(mapseg,$a000,wo shl 7,320*wo,128);}
for wo:=0 to 15000 do memw[ownseg:wo*2]:=dist1+1;
ax:=1;ay:=1;lx:=mx-1;ly:=my-1;
asm xor ax,ax;int 16h;end;

routestart(ownseg,mapseg,ax,ay,lx,ly,dist1);
asm mov dist,ax;end;
for wo:=0 to 120 do wipe(mapseg,$a000,wo shl 7,320*wo,128);

if(dist<dist1)then drawroute8 else writeln('No routes coming through.');
asm xor ax,ax;int 16h;mov ax,3h;int 10h;end;
end.

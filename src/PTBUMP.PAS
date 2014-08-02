{$M 1024,0,655360}
{$F+}

{ Fast multi-color bumpmapping for PT2. }

const
    smooth=1;
    lights=5;
    l_radius=100;
    l_speed=1;

    build=0;
    l_modif=124;
    safety=1000;
    d_multip=1;

var
    ownseg,color_image,lightseg:word;
    deltaseg1,deltaseg2,light_image,illumi:word;
    p:pointer;

    f:file;
    lighta:array[1..lights] of byte;
    lightx,lighty:array[1..lights] of word;
    palette:array[0..768] of byte;
    i,a,t:word;
    r,g,b:integer;
    a1,i1,temp:longint;
    frames,time1,time2:longint;
    sin_cos_table:array[0..255+64] of longint;  { fixed 16.16 }


{$L BUMP_ASM.OBJ}
procedure produce_bump_fast(liseg,oseg,dseg1,dseg2:word);external;
procedure produce_bump_fast2(liseg,oseg,dseg1,dseg2:word);external;
procedure produce_illumination_fast(oseg,cseg,iseg:word);external;

function findbest(red,green,blue:byte):byte;  { Ported from C }
var	best,t:byte;
	c_error,least_error:word;
begin
	least_error:=500;
	for t:=0 to 255 do begin
          c_error:=(abs(palette[t*3]-red)+
		    abs(palette[t*3+1]-green)+
		    abs(palette[t*3+2]-blue));

	  if(c_error<least_error) then
            begin least_error:=c_error;best:=t;end;

	  if(least_error=0) then break;
        end;

	findbest:=best;
end;

procedure setpal(n,r,g,b:byte);
begin
port[$3c8]:=n;
port[$3c9]:=r;
port[$3c9]:=g;
port[$3c9]:=b;
end;

procedure mem_copy(soseg,deseg,amount:word);
assembler;
asm
push ds
mov ds,soseg
xor si,si
mov es,deseg
xor di,di
mov cx,amount
shr cx,2
cld
db 66h
rep movsw
pop ds
end;

procedure mem_clear(deseg,amount:word);
assembler;
asm
mov es,deseg
xor di,di
db  66h
xor ax,ax
mov cx,amount
shr cx,2
cld
db 66h
rep stosw
end;

procedure add_light_fast(soseg,deseg,xco,yco:word);
assembler;
asm
push ds
mov ds,soseg
xor si,si
mov es,deseg
mov di,yco
mov ax,di
shl di,8
shl ax,6
add di,ax
add di,xco

mov bx,128
@outer:
mov cx,128
@inner:
mov al,[ds:si]
add [es:di],al
jnc @nofear
mov byte ptr [es:di],255
@nofear:
inc si
inc di
dec cx
jnz @inner
add di,320-128
dec bx
jnz @outer


pop  ds
end;



begin
getmem(p,65535);
ownseg:=seg(p^);
getmem(p,65535);
lightseg:=seg(p^);
getmem(p,65535);
deltaseg1:=seg(p^);
getmem(p,65535);
deltaseg2:=seg(p^);
getmem(p,65535);
color_image:=seg(p^);
getmem(p,128*128);
light_image:=seg(p^);
getmem(p,65535);
illumi:=seg(p^);

for i:=0 to 255+64 do begin
sin_cos_table[i]:=round(cos(i*(3.14159/128))*65536)*l_radius;
end;

for i:=0 to 65535 do begin { total wiping }
mem[lightseg:i]:=0;
mem[ownseg:i]:=0;
mem[deltaseg1:i]:=0;
mem[deltaseg2:i]:=0;
mem[color_image:i]:=0;
mem[illumi:i]:=0;
end;

asm
mov ax,13h
int 10h
end;

assign(f,'gamedata\phenom.dat');reset(f,768);blockread(f,palette,1);close(f);
for i:=0 to 255 do setpal(i,palette[i*3],palette[i*3+1],palette[i*3+2]);
assign(f,'gfx\phenom.svf');reset(f,64000);blockread(f,mem[color_image:0],1);close(f);
assign(f,'gfx\phenom_l.svf');reset(f,128*128);blockread(f,mem[light_image:0],1);close(f);
assign(f,'gamedata\phenom_i.dat');reset(f,256*256-1);blockread(f,mem[illumi:0],1);close(f);
assign(f,'gamedata\phenom_b.dat');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);

if(build=1) then begin
for i:=0 to 63999 do begin
  mem[ownseg:i]:=round((palette[mem[color_image:i]*3]+palette[mem[color_image:i]*3+1]+palette[mem[color_image:i]*3+2])*1.34);
  mem[$a000:i]:=15;
  end;
if(smooth>0) then
  for i:=1 to smooth do
    for a:=0 to 63999 do begin
     mem[ownseg:a]:=(mem[ownseg:a-1]+mem[ownseg:a+1]+
                  mem[ownseg:a-320]+mem[ownseg:a+320]) shr 2;
    mem[$a000:a]:=i;
    end;
assign(f,'gamedata\phenom_b.dat');rewrite(f,64000);blockwrite(f,mem[ownseg:0],1);close(f);
end;

for i:=0 to 63999 do
  begin
  i1:=mem[ownseg:i];
  dec(i1,mem[ownseg:i+1]);
  i1:=(i1*d_multip);
  a1:=mem[ownseg:i];
  dec(a1,mem[ownseg:i+320]);
  a1:=(a1*d_multip);

  if(i1>safety) then i1:=safety;
  if(i1<-safety) then i1:=-safety;
  if(a1>safety) then a1:=safety;
  if(a1<-safety) then a1:=-safety;

  if(i<32000) then
  memw[deltaseg1:i*2]:=i+a1*320+i1 else
  memw[deltaseg2:i*2-64000]:=i+a1*320+i1;
  end;

if(build=1) then begin
	for i1:=0 to 255 do  { Build illuminate values }
          for a1:=0 to 255 do
          begin
	  r:=palette[a1*3]+((i1-l_modif) div 2);
	  g:=palette[a1*3+1]+((i1-l_modif) div 2);
	  b:=palette[a1*3+2]+((i1-l_modif) div 2);
	  if(r>63) then r:=63;
	  if(g>63) then g:=63;
	  if(b>63) then b:=63;
	  if(r<0) then r:=0;
	  if(g<0) then g:=0;
          if(b<0) then b:=0;
          mem[illumi:i1*256+a1]:=findbest(r,g,b);

	  mem[$0a000:i1*320+a1]:=255;
{          write(r,' ',g,' ',b,' ');
          write(temp,' ');
          writeln(illumi^[i1,a1]);}
          end;

assign(f,'gamedata\phenom_i.dat');rewrite(f,256*256-1);blockwrite(f,mem[illumi:0],1);close(f);
end;

a:=0;
i1:=255 div lights;
for i:=1 to lights do
begin
lighta[i]:=a;
inc(a,i1);
end;

frames:=0;
time1:=meml[$40:$6c];

for i:=0 to 65535 do begin { total wiping }
mem[lightseg:i]:=0;
mem[ownseg:i]:=0;
mem[$a000:i]:=0;
end;

repeat

asm
mov es,lightseg
xor di,di
db  66h
xor ax,ax
mov cx,16384
cld
db 66h
rep stosw
end;

for i:=1 to lights do begin
  lightx[i]:=96+(sin_cos_table[lighta[i]] shr 16);
  lighty[i]:=36+(sin_cos_table[lighta[i]+64] shr 17);
  add_light_fast(light_image,lightseg,lightx[i],lighty[i]);
  inc(lighta[i],l_speed);
end;

produce_bump_fast2(lightseg,ownseg,deltaseg1,deltaseg2);
produce_illumination_fast(ownseg,color_image,illumi);
mem_copy(ownseg+200,$a000+200,64000-10*320*2);

for i:=1 to lights do
begin
inc(lightx[i],random(5));
inc(lighty[i],random(5));
end;
inc(frames);

until port[$60]=1;
time2:=meml[$40:$6c];

asm
mov ax,3h
int 10h
end;

writeln('FPS: ',round(frames/((time2-time1)/18.2)));

end.
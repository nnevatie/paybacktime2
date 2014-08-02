var musics,sounds,ver,mver,temp1,irq,dma:byte;code:integer;c1:byte;c:char;base:word;
    f1:file of byte;

begin
for c1:=0 to 24 do writeln;
asm mov ah,2;xor dx,dx;xor bx,bx;int $10;end;
writeln;
writeln('PaybackTime II Sound setup.');
writeln;write('Music? [Y/N] (Adlib compatible soundcard required) ');
repeat asm xor ax,ax;int $16;mov c,ah;end;until(c=#21)or(c=#49);
if(c=#21)then begin mver:=1;musics:=1;write('Y');end;
if(c=#49)then begin mver:=0;musics:=0;write('N');end;
writeln;write('Sound? [Y/N] (100% SB-compatible soundcard required) ');
repeat asm xor ax,ax;int $16;mov c,ah;end;until(c=#21)or(c=#49);
if(c=#21)then begin ver:=1;sounds:=1;write('Y');end;
if(c=#49)then begin ver:=0;sounds:=0;write('N');end;
if(ver=1)then begin
writeln;
write('SB base address 2?0h = ');
repeat asm xor ax,ax;int $16;mov c1,ah;end;until(c1>=2)and(c1<=10);dec(c1);
writeln('2',c1,'0h ');
case c1 of
1:base:=$210;
2:base:=$220;
3:base:=$230;
4:base:=$240;
5:base:=$250;
6:base:=$260;
7:base:=$270;
8:base:=$280;
9:base:=$290;
end;

write('SB irq               = ');
repeat asm xor ax,ax;int $16;mov c1,ah;end;until(c1>=2)and(c1<=10);
irq:=c1-1;
writeln(irq);
write('SB dma (low)         = ');
repeat asm xor ax,ax;int $16;mov c1,ah;end;until(c1>=2)and(c1<=10);
dma:=c1-1;
writeln(dma);
end;

assign(f1,'payback.cfg');
rewrite(f1);
write(f1,musics,sounds,mem[seg(base):ofs(base)],mem[seg(base):ofs(base)+1],irq,dma);
close(f1);
writeln;
end.
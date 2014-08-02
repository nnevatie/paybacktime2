var totinf,totgfx,mainxlo,mainylo,xlo,ylo,ownseg,tamount,picseg,gfxseg,infseg,vals,colo,count:word;
    fs1,fs2:longint;f:file of byte;fil:text;f1:file;ma:pointer;
    times,gfxofs,infofs:array[1..6] of word;

procedure fastp(cord,times,gfxseg,gfxofs,infseg,infofs:word);
begin
asm push ds;mov es,ownseg;mov di,cord;xor dx,dx;mov ds,gfxseg;mov si,gfxofs;mov bx,infofs;
@mainloop: push ds;mov ds,infseg;mov ax,[ds:bx];add di,ax;add bx,2;mov cx,[ds:bx];add bx,2;pop ds;
shr cx,1;jnc @inloop;movsb;or cx,cx;jz @end1;
@inloop: movsw;dec cx;jnz @inloop;
@end1: inc dx;cmp dx,times;jb @mainloop;pop ds;end;
end;


procedure loadpic(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin filc:=0;plac:=0;
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[picseg:0],1);close(file1);
repeat
colo:=mem[picseg:filc];coun:=mem[picseg:filc+1];
for iv:=plac to plac+coun-1 do mem[ownseg:iv]:=colo;
inc(plac,coun);inc(filc,2);
until iv>=63999;
end;


begin asm mov ax,$13;int $10; end;
getmem(ma,64000);ownseg:=seg(ma^);asm mov es,ownseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;
getmem(ma,64000);picseg:=seg(ma^);asm mov es,picseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;
getmem(ma,64000);infseg:=seg(ma^);asm mov es,infseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;
getmem(ma,64000);gfxseg:=seg(ma^);asm mov es,gfxseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;

loadpic('items.svf');

asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
asm xor ax,ax;int $16;end;

fs1:=0;fs2:=0;
totgfx:=fs1;totinf:=fs2;

for mainxlo:=1 to 6 do begin { mainloop2 }
tamount:=mainxlo;gfxofs[mainxlo]:=totgfx;infofs[mainxlo]:=totinf;

count:=0;colo:=0;vals:=0;
for ylo:=1 to 12 do for xlo:=1+((mainxlo-1)*15) to 14+((mainxlo-1)*15) do begin
if(mem[ownseg:ylo*320+xlo]<>0)and(colo=0)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(totinf,2);end;
if(mem[ownseg:ylo*320+xlo]=0)and(colo=1)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(totinf,2);end;
inc(count);
if(colo=1)and(xlo=14+((mainxlo-1)*15))then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
colo:=0;inc(vals);count:=0;inc(totinf,2);end;

if(colo=0)and(ylo<>12)and(xlo=14+((mainxlo-1)*15))then inc(count,276);

end;times[mainxlo]:=vals;

for ylo:=1 to 12 do for xlo:=1+((mainxlo-1)*15) to 14+((mainxlo-1)*15) do
if(mem[ownseg:ylo*320+xlo]<>0)then begin mem[gfxseg:totgfx]:=mem[ownseg:ylo*320+xlo];inc(totgfx);end;
end; { mainloop2 }


assign(f1,'igfx.dat');rewrite(f1,totgfx);blockwrite(f1,mem[gfxseg:0],1);close(f1);
assign(f1,'iinfo.dat');rewrite(f1,totinf);blockwrite(f1,mem[infseg:0],1);close(f1);

assign(fil,'ioffsets.dat');rewrite(fil);
write(fil,'const igfxofs:array[1..6] of word=(');
for count:=1 to 6 do begin write(fil,gfxofs[count]);if(count<>6)then write(fil,',');end;
writeln(fil,');');writeln(fil);

write(fil,'const iinfofs:array[1..6] of word=(');
for count:=1 to 6 do begin write(fil,infofs[count]);if(count<>6)then write(fil,',');end;
writeln(fil,');');writeln(fil);

write(fil,'const itimes:array[1..6] of word=(');
for count:=1 to 6 do begin write(fil,times[count] div 2);if(count<>6)then write(fil,',');end;
writeln(fil,');');close(fil);

asm mov ax,$3;int $10;end;
end.

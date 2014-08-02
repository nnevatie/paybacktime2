var totinf,totgfx,mainxlo,mainylo,xlo,ylo,ownseg,tamount,picseg,gfxseg,infseg,vals,colo,count:word;
    fs1,fs2:longint;f:file of byte;fil:text;f1:file;ma:pointer;
    times,gfxofs,infofs:array[1..100] of word;

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
for iv:=plac to plac+coun do mem[ownseg:iv]:=colo;
inc(plac,coun);inc(filc,2);
until iv>=63999;
end;


begin asm mov ax,$13;int $10; end;
getmem(ma,64000);ownseg:=seg(ma^);asm mov es,ownseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;
getmem(ma,64000);picseg:=seg(ma^);asm mov es,picseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;
getmem(ma,64000);infseg:=seg(ma^);asm mov es,infseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;
getmem(ma,64000);gfxseg:=seg(ma^);asm mov es,gfxseg;xor di,di;xor ax,ax;mov cx,32000;rep stosw;end;

loadpic('final1.svf');
asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
asm xor ax,ax;int $16;end;

fs1:=0;fs2:=0;tamount:=0;totgfx:=0;totinf:=0;

for mainylo:=1 to 5 do for mainxlo:=1 to 9 do begin { mainloop }
inc(tamount);
gfxofs[((mainylo-1)*9)+mainxlo]:=totgfx;infofs[((mainylo-1)*9)+mainxlo]:=totinf;

count:=0;colo:=0;vals:=0;
for ylo:=1+((mainylo-1)*36) to 35+((mainylo-1)*36) do
for xlo:=1+((mainxlo-1)*33) to 32+((mainxlo-1)*33) do begin
if(mem[ownseg:ylo*320+xlo]<>0)and(colo=0)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(totinf,2);end;
if(mem[ownseg:ylo*320+xlo]=0)and(colo=1)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(totinf,2);end;
inc(count);
if(colo=1)and(xlo=32+((mainxlo-1)*33))then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
colo:=0;inc(vals);count:=0;inc(totinf,2);end;

if(colo=0)and(ylo<>35+((mainylo-1)*36))and(xlo=32+((mainxlo-1)*33))then inc(count,258);

end;times[((mainylo-1)*9)+mainxlo]:=vals;

for ylo:=1+((mainylo-1)*36) to 35+((mainylo-1)*36) do for xlo:=1+((mainxlo-1)*33) to 32+((mainxlo-1)*33) do
if(mem[ownseg:ylo*320+xlo]<>0)then begin mem[gfxseg:totgfx]:=mem[ownseg:ylo*320+xlo];inc(totgfx);end;
end; { mainloop }

loadpic('final2.svf');

asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
asm xor ax,ax;int $16;end;

for mainylo:=1 to 5 do for mainxlo:=1 to 9 do begin { mainloop2 }
inc(tamount);if(tamount<=90)then begin { tileamount check }
gfxofs[((mainylo-1)*9+45)+mainxlo]:=totgfx;
infofs[((mainylo-1)*9+45)+mainxlo]:=totinf;

count:=0;colo:=0;vals:=0;
for ylo:=1+((mainylo-1)*36) to 35+((mainylo-1)*36) do
for xlo:=1+((mainxlo-1)*33) to 32+((mainxlo-1)*33) do begin
if(mem[ownseg:ylo*320+xlo]<>0)and(colo=0)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(totinf,2);end;
if(mem[ownseg:ylo*320+xlo]=0)and(colo=1)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(totinf,2);end;
inc(count);
if(colo=1)and(xlo=32+((mainxlo-1)*33))then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
colo:=0;inc(vals);count:=0;inc(totinf,2);end;

if(colo=0)and(ylo<>35+((mainylo-1)*36))and(xlo=32+((mainxlo-1)*33))then inc(count,258);

end;times[(((mainylo-1)*9)+45)+mainxlo]:=vals;

for ylo:=1+((mainylo-1)*36) to 35+((mainylo-1)*36) do for xlo:=1+((mainxlo-1)*33) to 32+((mainxlo-1)*33) do
if(mem[ownseg:ylo*320+xlo]<>0)then begin mem[gfxseg:totgfx]:=mem[ownseg:ylo*320+xlo];inc(totgfx);end;
end; { tileamount check }
end; { mainloop2 }


assign(f1,'tgfx.dat');rewrite(f1,totgfx);blockwrite(f1,mem[gfxseg:0],1);close(f1);
assign(f1,'tinfo.dat');rewrite(f1,totinf);blockwrite(f1,mem[infseg:0],1);close(f1);

assign(fil,'toffsets.dat');rewrite(fil);
write(fil,'const gfxofs:array[1..90] of word=(');
for count:=1 to 90 do begin write(fil,gfxofs[count]);write(fil,',');end;
writeln(fil,');');writeln(fil);

write(fil,'const infofs:array[1..90] of word=(');
for count:=1 to 90 do begin write(fil,infofs[count]);write(fil,',');end;
writeln(fil,');');writeln(fil);

write(fil,'const times:array[1..90] of word=(');
for count:=1 to 90 do begin write(fil,times[count] div 2);write(fil,',');end;
writeln(fil,');');close(fil);

asm mov ax,$3;int $10;end;
end.

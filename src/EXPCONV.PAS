var ma:pointer;count,ownseg,picseg,gfxseg,infseg,segcount,vals,colo,loopc,gcount,t1:word;k,fs1,fs2:longint;f:file of byte;
    times,gfxofs,infofs:array[1..100] of word;
    fil:text;f1:file;

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


loadpic('c:\turbo\payback\explo1.svf');
asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
count:=0;colo:=0;vals:=0;
gfxofs[1]:=gcount;infofs[1]:=segcount;
for loopc:=0 to 63999 do begin
if(mem[ownseg:loopc]<>0)and(colo=0)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(segcount,2);end;
if(mem[ownseg:loopc]=0)and(colo=1)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(segcount,2);end;
if(loopc mod 319=0)and(loopc<>0)then dec(count,30);inc(count);
end;
times[1]:=vals;
for loopc:=0 to 63999 do if(mem[ownseg:loopc]<>0)then begin
mem[gfxseg:gcount]:=mem[ownseg:loopc];inc(gcount);end;


loadpic('c:\turbo\payback\explo2.svf');
asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
count:=0;colo:=0;vals:=0;
gfxofs[2]:=gcount;infofs[2]:=segcount;
for loopc:=0 to 63999 do begin
if(mem[ownseg:loopc]<>0)and(colo=0)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(segcount,2);end;
if(mem[ownseg:loopc]=0)and(colo=1)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(segcount,2);end;
if(loopc mod 319=0)and(loopc<>0)then dec(count,30);inc(count);
end;
times[2]:=vals;
for loopc:=0 to 63999 do if(mem[ownseg:loopc]<>0)then begin
mem[gfxseg:gcount]:=mem[ownseg:loopc];inc(gcount);end;


loadpic('c:\turbo\payback\explo3.svf');
asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
count:=0;colo:=0;vals:=0;
gfxofs[3]:=gcount;infofs[3]:=segcount;
for loopc:=0 to 63999 do begin
if(mem[ownseg:loopc]<>0)and(colo=0)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(segcount,2);end;
if(mem[ownseg:loopc]=0)and(colo=1)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(segcount,2);end;
if(loopc mod 319=0)and(loopc<>0)then dec(count,30);inc(count);
end;
times[3]:=vals;
for loopc:=0 to 63999 do if(mem[ownseg:loopc]<>0)then begin
mem[gfxseg:gcount]:=mem[ownseg:loopc];inc(gcount);end;


loadpic('c:\turbo\payback\explo4.svf');
asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;end;
count:=0;colo:=0;vals:=0;
gfxofs[4]:=gcount;infofs[4]:=segcount;
for loopc:=0 to 63999 do begin
if(mem[ownseg:loopc]<>0)and(colo=0)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(segcount,2);end;
if(mem[ownseg:loopc]=0)and(colo=1)then begin asm mov es,infseg;mov di,segcount;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=0;count:=0;inc(segcount,2);end;
if(loopc mod 319=0)and(loopc<>0)then dec(count,30);inc(count);
end;
times[4]:=vals;
for loopc:=0 to 63999 do if(mem[ownseg:loopc]<>0)then begin
mem[gfxseg:gcount]:=mem[ownseg:loopc];inc(gcount);end;


assign(f1,'egfx.dat');rewrite(f1,gcount);blockwrite(f1,mem[gfxseg:0],1);close(f1);
assign(f1,'einfo.dat');rewrite(f1,segcount);blockwrite(f1,mem[infseg:0],1);close(f1);

assign(fil,'eoffsets.dat');rewrite(fil);

write(fil,'const egfxofs:array[1..4] of word=(');
for count:=1 to 4 do begin write(fil,gfxofs[count]);write(fil,',');end;
writeln(fil,');');writeln(fil);

write(fil,'const einfofs:array[1..4] of word=(');
for count:=1 to 4 do begin write(fil,infofs[count]);write(fil,',');end;
writeln(fil,');');writeln(fil);

write(fil,'const etimes:array[1..4] of word=(');
for count:=1 to 4 do begin write(fil,times[count] div 2);write(fil,',');end;
writeln(fil,');');close(fil);

asm mov ax,$3;int $10;end;
end.

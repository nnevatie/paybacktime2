var totinf,xlo,ylo,ownseg,tamount,picseg,infseg,vals,colo,count:word;
    fs1,fs2:longint;f:file of byte;fil:text;f1:file;ma:pointer;

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

loadpic('deplo.svf');
asm push ds;mov ax,$a000;mov es,ax;mov ds,ownseg;xor di,di;xor si,si;mov cx,32000;rep movsw;pop ds;xor ax,ax;int $16;end;

{ converting }
totinf:=0;count:=0;colo:=0;vals:=0;
for ylo:=1 to 35 do for xlo:=1 to 32 do begin
if(mem[ownseg:ylo*320+xlo]<>0)and(colo=0)then begin asm mov es,infseg;mov di,totinf;mov ax,count;mov [es:di],ax;end;
inc(vals);colo:=1;count:=0;inc(totinf,2);end;
if(mem[ownseg:ylo*320+xlo]=0)and(colo=1)then begin colo:=0;end;
inc(count);
if(colo=1)and(xlo=32)then begin colo:=0;end;

if(colo=0)and(ylo<>35)and(xlo=32)then inc(count,258);
end;
{ converting }

assign(f1,'depinfo.dat');rewrite(f1,totinf);blockwrite(f1,mem[infseg:0],1);close(f1);

asm mov ax,$3;int $10;end;
writeln(vals);writeln(totinf);
asm xor ax,ax;int $16;end;
end.

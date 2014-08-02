var wo,gfxseg:word;ma:pointer;s,s1:string;f:file;
    a,i,mapx,mapy,wd,dd:byte;
    plx,ply:array[0..1,1..10] of byte;

function checkfile(st1:string):boolean;var fil1:file;begin assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;end;

begin
writeln('This program converts maps from PT V1.5 to PT V2.0 !');
getmem(ma,22000);gfxseg:=seg(ma^);
if(paramcount>0)then begin s:=paramstr(1);
if(checkfile(s)=true)then begin
assign(f,s);reset(f,10064);blockread(f,mem[gfxseg:0],1);close(f);

s1:=s;delete(s1,length(s1)-2,3);insert('old',s1,length(s1)+1);
assign(f,s1);rewrite(f,10064);blockwrite(f,mem[gfxseg:0],1);close(f);
{ converting part of code }
mapx:=mem[gfxseg:10060];mapy:=mem[gfxseg:10061];wd:=mem[gfxseg:10062];dd:=mem[gfxseg:10063];

for a:=0 to 1 do for i:=1 to 10 do begin
plx[a,i]:=mem[gfxseg:10000+30*a+3*(i-1)];
ply[a,i]:=mem[gfxseg:10001+30*a+3*(i-1)];
end;

for wo:=10000 to 20600 do mem[gfxseg:wo]:=0;
for i:=1 to 10 do mem[gfxseg:10000+(ply[0,i]-1)+(plx[0,i]-1)*100]:=1;
for i:=1 to 10 do mem[gfxseg:10000+(ply[1,i]-1)+(plx[1,i]-1)*100]:=4;

mem[gfxseg:20600]:=mapx;
mem[gfxseg:20601]:=mapy;
mem[gfxseg:20602]:=wd;
mem[gfxseg:20603]:=dd;
mem[gfxseg:20604]:=20;
mem[gfxseg:20605]:=1;

{ converting part of code }

assign(f,s);rewrite(f,20606);blockwrite(f,mem[gfxseg:0],1);close(f);
end else writeln('Invalid filename, such file not found !');
end else writeln('Parameter missing, map name should be given as a parameter !');
end.

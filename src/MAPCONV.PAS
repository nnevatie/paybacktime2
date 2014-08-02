var wo,gfxseg:word;ma:pointer;s,s1:string;f:file;

function checkfile(st1:string):boolean;var fil1:file;begin assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;end;

begin
writeln('This program converts maps from PT V1.02 and PT V1.2 to PT V1.5 !');
getmem(ma,12000);gfxseg:=seg(ma^);
if(paramcount>0)then begin s:=paramstr(1);
if(checkfile(s)=true)then begin
assign(f,s);reset(f,10064);blockread(f,mem[gfxseg:0],1);close(f);

s1:=s;delete(s1,length(s1)-2,3);insert('old',s1,length(s1)+1);
assign(f,s1);rewrite(f,10064);blockwrite(f,mem[gfxseg:0],1);close(f);

for wo:=0 to 9999 do mem[gfxseg:wo]:=mem[gfxseg:wo]+100;

for wo:=0 to 9999 do case mem[gfxseg:wo] of
100:mem[gfxseg:wo]:=0;
101:mem[gfxseg:wo]:=1;
102:mem[gfxseg:wo]:=5;
103:mem[gfxseg:wo]:=6;
104:mem[gfxseg:wo]:=7;
105:mem[gfxseg:wo]:=8;
106:mem[gfxseg:wo]:=9;
107:mem[gfxseg:wo]:=10;
108:mem[gfxseg:wo]:=11;
109:mem[gfxseg:wo]:=12;
110:mem[gfxseg:wo]:=13;
111:mem[gfxseg:wo]:=14;
112:mem[gfxseg:wo]:=15;
113:mem[gfxseg:wo]:=34;
114:mem[gfxseg:wo]:=35;
115:mem[gfxseg:wo]:=36;
116:mem[gfxseg:wo]:=37;
117:mem[gfxseg:wo]:=18;
118:mem[gfxseg:wo]:=16;
119:mem[gfxseg:wo]:=17;
120:mem[gfxseg:wo]:=56;
121:mem[gfxseg:wo]:=57;
122:mem[gfxseg:wo]:=58;
123:mem[gfxseg:wo]:=42;
124:mem[gfxseg:wo]:=55;
125:mem[gfxseg:wo]:=4;
126:mem[gfxseg:wo]:=3;
end;

assign(f,s);rewrite(f,10064);blockwrite(f,mem[gfxseg:0],1);close(f);
end else writeln('Invalid filename, such file not found !');
end else writeln('Parameter missing, map name should be given as a parameter !');
end.

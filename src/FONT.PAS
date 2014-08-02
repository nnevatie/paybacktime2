{$f+}
var ma:pointer;fontseg:word;wo:longint;f:file;

{$L ASMTOOLS.OBJ}
procedure vidmode(mode:word);external;
procedure fontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure fontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;
procedure sfontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure sfontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;

procedure fastfont(snew:string;x,y,col,bcol,toseg,tpar,shad:word);
begin
if(tpar=0)and(shad=0)then fontxy(x,y,seg(snew),ofs(snew),fontseg,toseg,col,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=0)then fontxyt(x,y,seg(snew),ofs(snew),fontseg,toseg,col,mem[seg(snew):ofs(snew)]);
if(tpar=0)and(shad=1)then sfontxy(x,y,seg(snew),ofs(snew),fontseg,toseg,col+8,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=1)then sfontxyt(x,y,seg(snew),ofs(snew),fontseg,toseg,col+8,mem[seg(snew):ofs(snew)]);
end;

begin
getmem(ma,6000);fontseg:=seg(ma^);
assign(f,'font.fnt');reset(f,6000);blockread(f,mem[fontseg:0],1);close(f);
vidmode(19);
for wo:=1 to 10000 do fastfont('Tim the Guardian',10,10,20,0,$a000,1,1);
vidmode(3);
end.
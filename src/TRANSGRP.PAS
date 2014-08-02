var wo,source,dest:word;ma:pointer;f:file;li,la,grs1,grs,grnum:byte;code:integer;
    s:string;c1:char;
begin
getmem(ma,30000);source:=seg(ma^);for wo:=0 to 29999 do mem[source:wo]:=0;
getmem(ma,30000);dest:=seg(ma^);for wo:=0 to 29999 do mem[dest:wo]:=0;

if(paramcount>0)then begin
val(paramstr(2),grnum,code);        { grnum = group to be transferred }
assign(f,paramstr(1));reset(f,29000);blockread(f,mem[source:0],1);close(f);
assign(f,paramstr(3));reset(f,29000);blockread(f,mem[dest:0],1);close(f);
grs:=mem[dest:0];grs1:=mem[source:0];
if(grs<20)then begin if(grs1>grnum)then begin
mem[seg(s):ofs(s)]:=16;
move(mem[source:1+(grnum-1)*1440],s[1],16);
li:=0;for la:=16 downto 1 do begin if(s[la]=#0)and(li=0)then delete(s,la,1);if(s[la]<>#0)then li:=1;end;
write('Do you want to transfer : ',s,' ? (Y/N) ');
repeat asm xor ax,ax;int $16;mov c1,ah;end;until(c1=#21)or(c1=#49);
if(c1=#21)then begin
mem[dest:0]:=grs+1;
move(mem[source:1+(grnum-1)*1440],mem[dest:1+(grs-1)*1440],1440);
assign(f,paramstr(3));rewrite(f,29000);blockwrite(f,mem[dest:0],1);close(f);
writeln;writeln(s,' has been transferred to ',paramstr(3));
end;
end else write('You are transferring a group that doesn''t exist, can''t do that.');
end else write('Choose a destination-file which doesn''t already have 20 groups.');
end else begin writeln('You need to specify the following parameters :');
writeln;writeln('1. Source group-file');
writeln('2. The number of the group you want to transfer');
writeln('3. Destination group-file ');
writeln;writeln('For example: TRANSGRP GROUPS1.DAT 3 GROUPS.DAT');
end;
end.

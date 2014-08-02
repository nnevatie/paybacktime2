{$M 64000,0,32000}
{$I-} {I/O checks must be disabled!}
uses crt,dos;

var sopath,depath:string;
    f:file;

procedure file_copy(source,dest:string);
var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buf: array[1..2048*16] of Char;
begin
  Assign(FromF, source); { Open input file }
  Reset(FromF, 1);  { Record size = 1 }
  Assign(ToF, dest); { Open output file }
  Rewrite(ToF, 1);  { Record size = 1 }
  repeat
    write('þ');
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
  writeln;
end;

begin
writeln;
writeln('PaybackTime 2.1 (Win32) installation utility');
writeln;

getdir(0,sopath);

writeln('Enter destination path: (Example)');
writeln('c:\payback');
readln(depath);

if(depath[length(depath)]='\') then delete(depath,length(depath),1);

chdir(depath);
if(IOResult<>0) then
begin
writeln('Directory not found. Creating directory '''+depath+'''','.');
delay(200);
mkdir(depath);
if(IOResult<>0) then
begin
writeln('Directory cannot be created. Terminating installation.');
delay(200);
halt;
end;
end;

if(sopath[length(sopath)]='\') then delete(sopath,length(sopath),1);

if(sopath<>depath)and(depath<>'') then begin
writeln('Copying data');
file_copy(sopath+'\pt2.dat',depath+'\pt2.dat');
end;
if(sopath<>depath) then chdir(depath);

if(depath<>'')then writeln('Decompressing data to directory '''+depath+'''')
else writeln('Decompressing data');

delay(500);
swapvectors;
exec('pt2.dat','');
swapvectors;

if(depath='') then depath:=sopath;

if(sopath<>depath) then begin
assign(f,'pt2.dat');
reset(f);
close(f);
erase(f);
end;

clrscr;
writeln;
writeln('Type ''PT2'' to play!');
{writeln(sopath);
writeln(depath);}

end.
var ma:pointer;wo,ownseg:word;f:file;fnew:file of byte;
begin
getmem(ma,64000);ownseg:=seg(ma^);
assign(fnew,'datax.dat');rewrite(fnew);

assign(f,'weapons.dat');reset(f,5900);blockread(f,mem[ownseg:0],1);close(f);
for wo:=0 to 5899 do write(fnew,mem[ownseg:wo]);

assign(f,'items.dat');reset(f,1500);blockread(f,mem[ownseg:0],1);close(f);
for wo:=0 to 1499 do write(fnew,mem[ownseg:wo]);

assign(f,'groups.dat');reset(f,29000);blockread(f,mem[ownseg:0],1);close(f);
for wo:=0 to 28999 do write(fnew,mem[ownseg:wo]);

close(fnew);

end.

var ma:pointer;ownseg:word;f:file;
begin
getmem(ma,64000);ownseg:=seg(ma^);
assign(f,'chains.raw');reset(f,64000);blockread(f,mem[ownseg:0],1);close(f);
assign(f,'chains.new');rewrite(f,8000);blockwrite(f,mem[ownseg:0],1);close(f);
end.

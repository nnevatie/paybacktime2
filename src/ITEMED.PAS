{$f+}
const maxitem=50;
cle:string='                ';cletri:string[16]=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
de:array[1..161] of byte=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
typestr:array[1..2] of string=('Armor   ','Medikit ');
picp:array[1..16*4] of byte=(48,59,59,63,49,54,54,59,50,51,51,56,51,46,46,52,52,43,43,49,53,39,39,46,54,35,35,42,55,32,32,39,
56,28,28,35,57,25,25,32,58,22,22,29,59,19,19,25,60,16,16,22,61,13,13,18,62,10,10,15,63,7,7,12);

var ma:pointer;fontseg,picseg,ownseg,wo:word;
    ch1,ch2:char;
    expva,la,by,a,li,shi,line,bg:byte;
    s1,s:string[16];
    f:file;f1:file of byte;
    filn,filr,code:integer;
    itemnam:array[1..maxitem] of string[16];
    itemtype:array[1..maxitem] of shortint;
    itemprice:array[1..maxitem] of longint;
    itemval:array[1..maxitem,1..7] of shortint;
    ch:array[1..16] of char;
    parea:array[0..400] of byte;

{$L ASMTOOLS.OBJ}
procedure wipe(seg1,seg2,off1,off2,amount:word);external;
procedure fontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure fontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;
procedure sfontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure sfontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;

procedure wait(t:longint);
var w:longint;
begin
for w:=1 to t do
asm
mov dx,$3da;@vert1:in al,dx;test al,8;jz @vert1;@vert2:in al,dx;test al,8;jnz @vert2;
end;
end;

function shift:byte;var b:byte;begin
asm mov cx,ds;mov ax,0040h;mov ds,ax;mov al,[0017h];and al,3;mov b,al;mov ds,cx;end;shift:=b;end;

function checkfile(st1:string):boolean;
var fil1:file;begin
assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;
end;

procedure fastfont(snew:string;x,y,col,bcol,toseg,tpar,shad:word);
begin
if(tpar=0)and(shad=0)then fontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=0)then fontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,mem[seg(snew):ofs(snew)]);
if(tpar=0)and(shad=1)then sfontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=1)then sfontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,mem[seg(snew):ofs(snew)]);
end;

procedure loadpic(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin filc:=0;plac:=0;
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[ownseg:0],1);close(file1);

fastfont('S = Save items',10,132,22,0,ownseg,1,0);
fastfont('L = Load items',10,142,22,0,ownseg,1,0);

fastfont('Page Up / Down = Cycle Items',10,152,22,0,ownseg,1,0);
fastfont('<- / ->, Enter = Change Value',10,162,22,0,ownseg,1,0);

wipe(ownseg,picseg,0,0,16000);
{repeat
colo:=mem[picseg:filc];coun:=mem[picseg:filc+1];
for iv:=plac to plac+coun do mem[ownseg:iv]:=colo;
inc(plac,coun);inc(filc,2);
until iv>=63999;}
end;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

{procedure point(ax,ay,lx,ly:word;col:byte);
begin
for wo:=ax to lx do begin mem[ownseg:wo+ay*320]:=col;mem[ownseg:wo+ly*320]:=col;end;
for wo:=ay to ly do begin mem[ownseg:wo*320+ax]:=col;mem[ownseg:wo*320+lx]:=col;end;
end;}

procedure point(ax,ay,lx,ly:word;col:byte);
var n:word;
begin
n:=0;
for wo:=ax to lx do begin
parea[n]:=mem[ownseg:wo+ay*320];
parea[n+1]:=mem[ownseg:wo+ly*320];
mem[ownseg:wo+ay*320]:=col;
mem[ownseg:wo+ly*320]:=col;
inc(n,2);
end;
for wo:=ay+1 to ly-1 do begin
parea[n]:=mem[ownseg:wo*320+ax];
parea[n+1]:=mem[ownseg:wo*320+lx];
mem[ownseg:wo*320+ax]:=col;
mem[ownseg:wo*320+lx]:=col;
inc(n,2);
end;
end;

procedure rempoint(ax,ay,lx,ly:word;col:byte);
var n:word;
begin
n:=0;
for wo:=ax to lx do begin
mem[ownseg:wo+ay*320]:=parea[n];
mem[ownseg:wo+ly*320]:=parea[n+1];
inc(n,2);
end;
for wo:=ay+1 to ly-1 do begin
mem[ownseg:wo*320+ax]:=parea[n];
mem[ownseg:wo*320+lx]:=parea[n+1];
inc(n,2);
end;
end;



{procedure textxy(x,y:integer;col:byte;text:string);
begin
fastfont(text,x,y,col,0,ownseg,0,1);
end;
}
procedure textxy(x,y:integer;col:byte;text:string);
var wor:word;
begin
for wor:=0 to 7 do
wipe(picseg,ownseg,(y+wor)*320+x,(y+wor)*320+x,(mem[seg(text):ofs(text)]*6) div 4+1);
fastfont(text,x,y,col-5,0,ownseg,1,1);
end;

{function getstring(x,y,col,maxpit,pcol:integer;stri:string;num:boolean):string;
var pla,po,i:integer;c1,c2:char;mi:boolean;
begin mi:=false;if num=false then
for i:=16 downto 1 do if(stri[i]=#0)or(stri[i]=#32)and(mi=false)then delete(stri,i,1) else mi:=true;
pla:=1;textxy(x,y,col,stri);
repeat
for po:=1 to 5 do mem[$a000:320*(8+y)+x+6*(pla-1)+po-1]:=pcol;
asm mov ah,0;int 16h;mov c1,al;mov c2,ah;end;
if(c1>=#32)and(length(stri)<maxpit)and(num=false)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1>=#48)and(c1<=#57)and(length(stri)<maxpit)and(num=true)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1=#8)and(pla>1)then begin dec(pla);delete(stri,pla,1);end;
if(c2=#83)then delete(stri,pla,1);
if(c2=#75)and(pla>1)then dec(pla);
if(c2=#77)and(pla<maxpit)and(pla<=length(stri))then inc(pla);
for i:=1 to 7 do move(de[1],mem[ownseg:(y+i)*320+x],maxpit*6+1);
textxy(x,y,col,stri);
for i:=1 to 8 do move(mem[ownseg:(y+i)*320+x],mem[$a000:(y+i)*320+x],maxpit*6+1);
until(c1=#13)or(c2=#28);
if num=false then for i:=length(stri)+1 to 20 do insert(#0,stri,i);
getstring:=stri;
end;}

function getstring(x,y,col,maxpit,pcol:integer;stri:string;num:boolean):string;
var pla,po,i:integer;c1,c2:char;mi:boolean;
begin mi:=false;if num=false then
for i:=16 downto 1 do if(stri[i]=#0)or(stri[i]=#32)and(mi=false)then delete(stri,i,1) else mi:=true;
pla:=1;

{fastfont(stri,x,y,col,0,ownseg,0,1);}
textxy(x,y,col,stri);

repeat
for po:=1 to 5 do mem[$a000:320*(8+y)+x+6*(pla-1)+po-1]:=pcol;
asm mov ah,0;int 16h;mov c1,al;mov c2,ah;end;
if(c1>=#32)and(length(stri)<maxpit)and(num=false)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1>=#48)and(c1<=#57)and(length(stri)<maxpit)and(num=true)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1=#8)and(pla>1)then begin dec(pla);delete(stri,pla,1);end;
if(c2=#83)then delete(stri,pla,1);
if(c2=#75)and(pla>1)then dec(pla);
if(c2=#77)and(pla<maxpit)and(pla<=length(stri))then inc(pla);
{for i:=1 to 7 do move(de[1],mem[ownseg:(y+i)*320+x],maxpit*6+1);}
for i:=0 to 8 do wipe(picseg,ownseg,(y+i)*320+x,(y+i)*320+x,(maxpit*6+1)div 4);

{fastfont(stri,x,y,col,0,ownseg,0,1);}
textxy(x,y,col,stri);

{for i:=1 to 8 do move(mem[ownseg:(y+i)*320+x],mem[$a000:(y+i)*320+x],maxpit*6+1);}
for i:=0 to 8 do wipe(ownseg,$a000,(y+i)*320+x,(y+i)*320+x,(maxpit*6+1)div 4);

until(c1=#13)or(c2=#28);
if num=false then for i:=length(stri)+1 to 20 do insert(#0,stri,i);
getstring:=stri;
end;

procedure updatetyp;begin for wo:=1 to 7 do itemval[filn,wo]:=0;end;

procedure update;
begin
if itemtype[filn]=1 then begin
textxy(11,50,22,'Head armor      :');str(itemval[filn,1],s);s:=s+'  ';textxy(120,50,22,s);
textxy(11,60,22,'Chest armor     :');str(itemval[filn,2],s);s:=s+'  ';textxy(120,60,22,s);
textxy(11,70,22,'Right arm armor :');str(itemval[filn,3],s);s:=s+'  ';textxy(120,70,22,s);
textxy(11,80,22,'Left arm armor  :');str(itemval[filn,4],s);s:=s+'  ';textxy(120,80,22,s);
textxy(11,90,22,'Right leg armor :');str(itemval[filn,5],s);s:=s+'  ';textxy(120,90,22,s);
textxy(11,100,22,'Left leg armor  :');str(itemval[filn,6],s);s:=s+'  ';textxy(120,100,22,s);
textxy(11,110,22,'MPS Penalty     :');str(itemval[filn,7],s);s:=s+'  ';textxy(120,110,22,s);
end;
if itemtype[filn]=2 then begin
textxy(11,50,22,'Charges         :');str(itemval[filn,1],s);s:=s+'  ';textxy(120,50,22,s);
textxy(11,60,22,'Healing         :');str(itemval[filn,2],s);s:=s+'  ';textxy(120,60,22,s);
textxy(11,70,22,'                 ');textxy(120,70,22,'   ');
textxy(11,80,22,'                 ');textxy(120,80,22,'   ');
textxy(11,90,22,'                 ');textxy(120,90,22,'   ');
textxy(11,100,22,'                 ');textxy(120,100,22,'   ');
textxy(11,110,22,'                 ');textxy(120,110,22,'   ');
end;
textxy(120,20,22,typestr[itemtype[filn]]);
textxy(120,30,22,cle);textxy(120,30,22,itemnam[filn]);
str(itemprice[filn],s);textxy(120,40,22,cle);textxy(120,40,22,s);
str(filn,s);s:=s+'  ';textxy(120,5,22,s);
if(itemtype[filn]=2)and(line>5)then line:=5;
end;


procedure save;
var c1:byte;
begin
fastfont('Saving data...',156,132,14,0,$a000,1,0);
assign(f1,'data\items.dat');rewrite(f1);

for c1:=2 downto 1 do
for wo:=1 to maxitem do begin
if(itemtype[wo]=c1)and(itemnam[wo][1]<>#0)then begin

by:=itemtype[wo];write(f1,by);
for a:=1 to 16 do begin by:=ord(itemnam[wo][a]);write(f1,by);end;
s:='      ';for a:=1 to 6 do begin str(itemprice[wo],s);by:=ord(s[a]);write(f1,by);end;
by:=itemval[wo,1];write(f1,by);
by:=itemval[wo,2];write(f1,by);
by:=itemval[wo,3];write(f1,by);
by:=itemval[wo,4];write(f1,by);
by:=itemval[wo,5];write(f1,by);
by:=itemval[wo,6];write(f1,by);
by:=itemval[wo,7];write(f1,by);
end;end;
close(f1);update;wait(10);wipe(ownseg,$a000,0,0,16000);
end;

procedure load(ls:string);
begin
if checkfile('data\items.dat')=true then begin
fastfont(ls,156,132,14,0,$a000,1,0);
assign(f1,'data\items.dat');reset(f1);wo:=filesize(f1);filr:=trunc(wo/30);

for wo:=1 to maxitem do begin itemtype[wo]:=1;itemnam[wo]:=cletri;
itemprice[wo]:=0;for a:=1 to 7 do itemval[wo,a]:=0;end;

for wo:=1 to filr do begin
read(f1,by);itemtype[wo]:=by;
itemnam[wo]:=cletri;for a:=1 to 16 do begin read(f1,by);itemnam[wo][a]:=chr(by);end;
la:=1;s:='      ';for a:=1 to 6 do begin read(f1,by);if by<>32then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,itemprice[wo],code);
read(f1,by);itemval[wo,1]:=by;
read(f1,by);itemval[wo,2]:=by;
read(f1,by);itemval[wo,3]:=by;
read(f1,by);itemval[wo,4]:=by;
read(f1,by);itemval[wo,5]:=by;
read(f1,by);itemval[wo,6]:=by;
read(f1,by);itemval[wo,7]:=by;
end;close(f1);update;wait(10);wipe(ownseg,$a000,0,0,16000);
end;end;


begin
asm mov ax,13h;int 10h;end;
filn:=1;line:=1;
getmem(ma,64000);ownseg:=seg(ma^);
getmem(ma,64000);picseg:=seg(ma^);
getmem(ma,6000);fontseg:=seg(ma^);
assign(f,'gfx\font.fnt');reset(f,6000);blockread(f,mem[fontseg:0],1);close(f);

for wo:=0 to 15 do setpal(picp[1+wo*4],picp[wo*4+2],picp[wo*4+3],picp[wo*4+4]);

assign(f,'gamedata\itemed.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for wo:=0 to 255 do setpal(wo,mem[ownseg:wo*3],mem[ownseg:wo*3+1],mem[ownseg:wo*3+2]);

loadpic('gfx\itempic.svf');
for wo:=1 to maxitem do begin itemtype[wo]:=1;end;

textxy(11,5,22,'Item number     :');
textxy(11,20,22,'Item type       :');
textxy(11,30,22,'Item name       :');
textxy(11,40,22,'Price           :');
wipe(ownseg,$a000,0,0,16000);load('Loading data...');

repeat
point(10,9+(line*10),115,19+(line*10),14);
wipe(ownseg,$a000,0,0,16000);
rempoint(10,9+(line*10),115,19+(line*10),0);

asm mov ah,0;int 16h;mov ch1,al;mov ch2,ah;end;   { ah:scancode }
shi:=shift;

if(ch2=#75)and(line=1)then begin dec(itemtype[filn]);if itemtype[filn]<1 then itemtype[filn]:=2;updatetyp;update;end;
if(ch2=#77)and(line=1)then begin inc(itemtype[filn]);if itemtype[filn]>2 then itemtype[filn]:=1;updatetyp;update;end;

if(ch1=#13)and(line=2)then itemnam[filn]:=getstring(120,30,22,16,24,itemnam[filn],false);

if(ch1=#13)and(line=3)then begin str(itemprice[filn],s);
val(getstring(120,40,22,6,24,s,true),itemprice[filn],code);
str(itemprice[filn],s);textxy(120,40,22,cle);textxy(120,40,22,s);end;


if(ch2=#75)and(line=4)and(itemval[filn,1]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,1],li);
if itemval[filn,1]<0 then itemval[filn,1]:=0;str(itemval[filn,1],s);s:=s+'    ';textxy(120,50,22,s);end;
if(ch2=#77)and(line=4)and(itemval[filn,1]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,1],li);
if itemval[filn,1]>100 then itemval[filn,1]:=100;str(itemval[filn,1],s);s:=s+'    ';textxy(120,50,22,s);end;

if(ch2=#75)and(line=5)and(itemval[filn,2]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,2],li);
if itemval[filn,2]<0 then itemval[filn,2]:=0;str(itemval[filn,2],s);s:=s+'    ';textxy(120,60,22,s);end;
if(ch2=#77)and(line=5)and(itemval[filn,2]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,2],li);
if itemval[filn,2]>100 then itemval[filn,2]:=100;str(itemval[filn,2],s);s:=s+'    ';textxy(120,60,22,s);end;

if(ch2=#75)and(line=6)and(itemval[filn,3]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,3],li);
if itemval[filn,3]<0 then itemval[filn,3]:=0;str(itemval[filn,3],s);s:=s+'    ';textxy(120,70,22,s);end;
if(ch2=#77)and(line=6)and(itemval[filn,3]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,3],li);
if itemval[filn,3]>100 then itemval[filn,3]:=100;str(itemval[filn,3],s);s:=s+'    ';textxy(120,70,22,s);end;

if(ch2=#75)and(line=7)and(itemval[filn,4]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,4],li);
if itemval[filn,4]<0 then itemval[filn,4]:=0;str(itemval[filn,4],s);s:=s+'    ';textxy(120,80,22,s);end;
if(ch2=#77)and(line=7)and(itemval[filn,4]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,4],li);
if itemval[filn,4]>100 then itemval[filn,4]:=100;str(itemval[filn,4],s);s:=s+'    ';textxy(120,80,22,s);end;

if(ch2=#75)and(line=8)and(itemval[filn,5]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,5],li);
if itemval[filn,5]<0 then itemval[filn,5]:=0;str(itemval[filn,5],s);s:=s+'    ';textxy(120,90,22,s);end;
if(ch2=#77)and(line=8)and(itemval[filn,5]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,5],li);
if itemval[filn,5]>100 then itemval[filn,5]:=100;str(itemval[filn,5],s);s:=s+'    ';textxy(120,90,22,s);end;

if(ch2=#75)and(line=9)and(itemval[filn,6]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,6],li);
if itemval[filn,6]<0 then itemval[filn,6]:=0;str(itemval[filn,6],s);s:=s+'    ';textxy(120,100,22,s);end;
if(ch2=#77)and(line=9)and(itemval[filn,6]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,6],li);
if itemval[filn,6]>100 then itemval[filn,6]:=100;str(itemval[filn,6],s);s:=s+'    ';textxy(120,100,22,s);end;

if(ch2=#75)and(line=10)and(itemval[filn,7]>0)then begin if shi=0 then li:=1 else li:=10;dec(itemval[filn,7],li);
if itemval[filn,7]<0 then itemval[filn,7]:=0;str(itemval[filn,7],s);s:=s+'    ';textxy(120,110,22,s);end;
if(ch2=#77)and(line=10)and(itemval[filn,7]<100)then begin if shi=0 then li:=1 else li:=10;inc(itemval[filn,7],li);
if itemval[filn,7]>100 then itemval[filn,7]:=100;str(itemval[filn,7],s);s:=s+'    ';textxy(120,110,22,s);end;


if(ch2=#73)and(filn<maxitem)and(shi=0)then begin inc(filn);update;end;
if(ch2=#81)and(filn>1)and(shi=0)then begin dec(filn);update;end;

if(ch2=#73)and(shi>0)then begin inc(filn,10);if filn>maxitem then filn:=maxitem;update;end;
if(ch2=#81)and(shi>0)then begin dec(filn,10);if filn<1 then filn:=1;update;end;

if(ch2=#72)and(line>1)then dec(line);
if(ch2=#80)and(line<10)then begin inc(line);if(itemtype[filn]=2)and(line>5)then line:=5;end;

if(ch2=#31)then begin save;load('Reordering data...');end;
if(ch2=#38)then load('Loading data...');

until(ch1=#1)or(ch2=#1);
asm mov ax,3h;int 10h;end;
end.

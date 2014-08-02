{$f+}
const maxweps=100;
picp:array[1..24*4] of byte =(16,59,59,59,21,42,42,42,23,35,35,35,25,28,28,28,26,25,25,25,27,21,21,21,28,18,18,18,29,
14,14,14,30,11,11,11,48,59,59,63,49,54,54,59,50,51,51,56,51,46,46,
52,52,43,43,49,53,39,39,46,54,35,35,42,55,32,32,39,56,28,28,35,57,25,25,32,58,22,22,29,59,19,19,25,60,16,16,22,
61,13,13,18,62,10,10,15);
cle:string='                ';cletri:string[16]=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
de:array[1..161] of byte=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
typestr:array[1..4] of string=('Projectile weapon','Energy weapon    ','Melee weapon     ','Explosive        ');

var ma:pointer;picseg,ownseg,fontseg,wo:word;ch1,ch2:char;expva,la,by,a,li,shi,line,bg:byte;s1,s:string[20];
    f:file;f1:file of byte;
    filn,filr,code:integer;era:real;
    wepnam,clnam:array[1..maxweps] of string[16];
    xdam,ydam,accufact,expfact,exprad,mpscost,mpscosta,burst,hreq:array[1..maxweps] of shortint;

    accuracy,weaptype:array[1..maxweps] of byte;
    clprice,wepprice:array[1..maxweps] of longint;
    clsize:array[1..maxweps] of integer;
    typ:array[1..9] of boolean;
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

procedure fastfont(snew:string;x,y,col,bcol,toseg,tpar,shad:word);
begin
if(tpar=0)and(shad=0)then fontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=0)then fontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col,mem[seg(snew):ofs(snew)]);
if(tpar=0)and(shad=1)then sfontxy(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,bcol,mem[seg(snew):ofs(snew)]);
if(tpar=1)and(shad=1)then sfontxyt(x,y+1,seg(snew),ofs(snew),fontseg,toseg,col+8,mem[seg(snew):ofs(snew)]);
end;

function shift:byte;var b:byte;begin
asm mov cx,ds;mov ax,0040h;mov ds,ax;mov al,[0017h];and al,3;mov b,al;mov ds,cx;end;shift:=b;end;

function checkfile(st1:string):boolean;
var fil1:file;begin
assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;
end;

procedure loadpic(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin filc:=0;plac:=0;
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[ownseg:0],1);close(file1);

fastfont('S = Save weapons',10,175,22,0,ownseg,1,0);
fastfont('L = Load weapons',10,185,22,0,ownseg,1,0);

fastfont('Page Up / Down = Cycle Weapons',120,175,22,0,ownseg,1,0);
fastfont('<- / ->, Enter = Change Value',120,185,22,0,ownseg,1,0);

wipe(ownseg,picseg,0,0,16000);
{repeat
colo:=mem[picseg:filc];coun:=mem[picseg:filc+1];
for iv:=plac to plac+coun do mem[ownseg:iv]:=colo;
inc(plac,coun);inc(filc,2);
until iv>=63999;}
end;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

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

procedure textxy(x,y:integer;col:byte;text:string);
var wor:word;
begin
for wor:=0 to 7 do
wipe(picseg,ownseg,(y+wor)*320+x,(y+wor)*320+x,(mem[seg(text):ofs(text)]*6) div 4+1);
fastfont(text,x,y,col,0,ownseg,1,1);
end;

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


procedure update;
procedure typecheck;
begin
for wo:=1 to 9 do typ[wo]:=true;
case weaptype[filn] of
1:begin typ[5]:=false;end;
2:begin typ[2]:=false;typ[3]:=false;typ[4]:=false;end;
3:begin for wo:=1 to 8 do typ[wo]:=false;end;
4:begin typ[1]:=false;typ[4]:=false;typ[5]:=false;typ[6]:=false;typ[7]:=false;typ[8]:=false;typ[9]:=false;end;
end;end;
begin
typecheck;
str(filn,s);s:=s+'  ';textxy(137,5,47,s);
textxy(135,20,50,typestr[weaptype[filn]]);
textxy(135,30,50,cle);textxy(135,30,50,wepnam[filn]);
str(wepprice[filn],s);textxy(135,40,50,cle);textxy(135,40,50,s);
if typ[9]=true then begin str(accuracy[filn],s);s:=s+'    ';textxy(135,50,50,s);end else textxy(135,50,50,'-   ');
if typ[1]=true then begin a:=trunc(accufact[filn]/10);str(a,s);s:=s+'.';la:=accufact[filn]-a*10;str(la,s1);s:=s+s1;
s:=s+'    ';textxy(135,60,50,s);end else textxy(135,60,50,'-   ');
str(xdam[filn],s);if length(s)<3 then for wo:=1 to 3-length(s) do insert(' ',s,1);textxy(176,70,50,s);
str(ydam[filn],s);s:=s+'   ';textxy(211,70,50,s);
if(typ[2]=true)and(expfact[filn]>=1)then begin str(expfact[filn],s);s:=s+'            ';textxy(135,80,50,s);end
else textxy(135,80,50,'Not in use   ');
if typ[2]=false then begin textxy(135,80,50,cle);textxy(135,80,50,'-   ');end;
if (typ[3]=true)and(exprad[filn]>1)then begin expva:=trunc(exprad[filn]/2);str(expva,s);if(exprad[filn]mod 2)=1 then
s:=s+'.5' else s:=s+'.0';s:=s+'            ';textxy(135,90,50,s);end else textxy(135,90,50,'Not in use   ');
if typ[3]=false then begin textxy(135,90,50,cle);textxy(135,90,50,'-   ');end;
str(mpscost[filn],s);s:=s+'    ';textxy(135,100,50,s);
if mpscosta[filn]>0 then begin str(mpscosta[filn],s);s:=s+'             ';textxy(135,110,50,s);end
else textxy(135,110,50,'Not in use   ');
if typ[4]=false then textxy(135,110,50,'-              ');
str(hreq[filn],s);s:=s+'    ';textxy(135,120,50,s);
if typ[5]=true then begin str(burst[filn],s);s:=s+'    ';textxy(135,130,50,s);end else textxy(135,130,50,'-   ');
if typ[6]=true then begin textxy(135,140,50,cle);textxy(135,140,50,clnam[filn]);end else begin
textxy(135,140,50,cle);textxy(135,140,50,'-');end;
if typ[7]=true then begin str(clsize[filn],s);s:=s+'    ';textxy(135,150,50,s);end else textxy(135,150,50,'-   ');
if typ[8]=true then begin str(clprice[filn],s);textxy(135,160,50,cle);textxy(135,160,50,s);end else begin
textxy(135,160,50,cle);textxy(135,160,50,'-');end;
end;

procedure save;
var c1:byte;
begin
fastfont('Saving data...',156,175,14,0,$a000,1,0);
assign(f1,'data\weapons.dat');rewrite(f1);

for c1:=1 to 4 do
for wo:=1 to maxweps do begin
if(weaptype[wo]=c1)and(wepnam[wo][1]<>#0)then begin

write(f1,weaptype[wo]);
for a:=1 to 16 do begin by:=ord(wepnam[wo][a]);write(f1,by);end;
s:='      ';for a:=1 to 6 do begin str(wepprice[wo],s);by:=ord(s[a]);write(f1,by);end;
by:=accuracy[wo];write(f1,by);by:=accufact[wo];write(f1,by);
by:=xdam[wo];write(f1,by);by:=ydam[wo];write(f1,by);
by:=expfact[wo];write(f1,by);by:=exprad[wo];write(f1,by);
by:=mpscost[wo];write(f1,by);by:=mpscosta[wo];write(f1,by);
by:=hreq[wo];write(f1,by);by:=burst[wo];write(f1,by);
for a:=1 to 16 do begin by:=ord(clnam[wo][a]);write(f1,by);end;
s:='    ';for a:=1 to 4 do begin str(clsize[wo],s);by:=ord(s[a]);write(f1,by);end;
s:='      ';for a:=1 to 6 do begin str(clprice[wo],s);by:=ord(s[a]);write(f1,by);end;
end;end;
close(f1);wait(10);wipe(ownseg,$a000,0,0,16000);
end;

procedure load(ls:string);
begin
fastfont(ls,156,175,14,0,$a000,1,0);

for wo:=1 to maxweps do begin weaptype[wo]:=1;wepnam[wo]:=cletri;wepprice[wo]:=0;accuracy[wo]:=0;accufact[wo]:=0;
xdam[wo]:=0;ydam[wo]:=0;expfact[wo]:=0;exprad[wo]:=1;mpscost[wo]:=0;mpscosta[wo]:=0;hreq[wo]:=1;burst[wo]:=1;
clnam[wo]:=cletri;clprice[wo]:=0;end;

if checkfile('data\weapons.dat')=true then begin
assign(f1,'data\weapons.dat');reset(f1);
wo:=filesize(f1);filr:=trunc(wo/59);
for wo:=1 to filr do begin
read(f1,weaptype[wo]);
wepnam[wo]:=cletri;for a:=1 to 16 do begin read(f1,by);wepnam[wo][a]:=chr(by);end;
la:=1;s:='      ';for a:=1 to 6 do begin read(f1,by);if by<>32then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,wepprice[wo],code);
read(f1,by);accuracy[wo]:=by;
read(f1,by);accufact[wo]:=by;
read(f1,by);xdam[wo]:=by;
read(f1,by);ydam[wo]:=by;
read(f1,by);expfact[wo]:=by;
read(f1,by);exprad[wo]:=by;
read(f1,by);mpscost[wo]:=by;
read(f1,by);mpscosta[wo]:=by;
read(f1,by);hreq[wo]:=by;
read(f1,by);burst[wo]:=by;
delete(clnam[wo],0,256);clnam[wo]:=cletri;for a:=1 to 16 do begin read(f1,by);clnam[wo][a]:=chr(by);end;
la:=1;s:='    ';for a:=1 to 4 do begin read(f1,by);if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,5-la);val(s,clsize[wo],code);
la:=1;s:='      ';for a:=1 to 6 do begin read(f1,by);if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,clprice[wo],code);
end;
close(f1);wait(10);wipe(ownseg,$a000,0,0,16000);
end;end;

begin
asm mov ax,13h;int 10h;end;
getmem(ma,64000);ownseg:=seg(ma^);getmem(ma,64000);picseg:=seg(ma^);filn:=1;line:=1;
getmem(ma,6000);fontseg:=seg(ma^);
assign(f,'gfx\font.fnt');reset(f,6000);blockread(f,mem[fontseg:0],1);close(f);

assign(f,'gamedata\weaponed.dat');reset(f,768);blockread(f,mem[ownseg:0],1);close(f);
for wo:=0 to 255 do setpal(wo,mem[ownseg:wo*3],mem[ownseg:wo*3+1],mem[ownseg:wo*3+2]);
loadpic('gfx\wepedpic.svf');

for wo:=0 to 23 do setpal(picp[1+wo*4],picp[wo*4+2],picp[wo*4+3],picp[wo*4+4]);

textxy(14,5,47,'Weapon number     :');
textxy(14,20,53,'Weapon type       :');
textxy(14,30,53,'Weapon name       :');
textxy(14,40,53,'Price             :');
textxy(14,50,53,'Accuracy %        :');
textxy(14,60,53,'Accuracy factor   :');
textxy(14,70,53,'Damage            :');
textxy(14,80,53,'Explosion factor  :');
textxy(14,90,53,'Explosion radius  :');
textxy(14,100,53,'MPS Cost %        :');
textxy(14,110,53,'MPS Cost auto %   :');
textxy(14,120,53,'Hands required    :');
textxy(14,130,53,'Maximum burst     :');
textxy(14,140,53,'Clip type         :');
textxy(14,150,53,'Clip size         :');
textxy(14,160,53,'Clip price        :');
textxy(135,70,50,'Random');textxy(200,70,50,'+');

wipe(ownseg,$a000,0,0,16000);
load('Loading data');update;
repeat
point(11,9+(line*10),129,19+(line*10),14);
wipe(ownseg,$a000,0,0,16000);
rempoint(11,9+(line*10),129,19+(line*10),0);

asm mov ah,0;int 16h;mov ch1,al;mov ch2,ah;end;   { ah:scancode }
shi:=shift;

if(ch2=#75)and(line=1)then begin dec(weaptype[filn]);if weaptype[filn]=0 then weaptype[filn]:=4;
update;textxy(135,20,50,typestr[weaptype[filn]]);end;
if(ch2=#77)and(line=1)then begin inc(weaptype[filn]);if weaptype[filn]=5 then weaptype[filn]:=1;
update;textxy(135,20,50,typestr[weaptype[filn]]);end;

if(ch1=#13)and(line=2)then wepnam[filn]:=getstring(135,30,50,16,15,wepnam[filn],false);

if(ch1=#13)and(line=3)then begin str(wepprice[filn],s);
val(getstring(135,40,50,6,15,s,true),wepprice[filn],code);
str(wepprice[filn],s);textxy(135,40,50,cle);textxy(135,40,50,s);end;

if(typ[9]=true)and(ch2=#75)and(line=4)and(accuracy[filn]>0)then begin if shi=0 then li:=1 else li:=10;dec(accuracy[filn],li);
if accuracy[filn]>230 then accuracy[filn]:=0;str(accuracy[filn],s);s:=s+'    ';textxy(135,50,50,s);end;
if(typ[9]=true)and(ch2=#77)and(line=4)and(accuracy[filn]<150)then begin if shi=0 then li:=1 else li:=10;inc(accuracy[filn],li);
if accuracy[filn]>150 then accuracy[filn]:=150;
str(accuracy[filn],s);s:=s+'    ';textxy(135,50,50,s);end;

if(typ[1]=true)and(ch2=#75)and(line=5)and(accufact[filn]>0)then begin if shi=0 then li:=1 else li:=10;dec(accufact[filn],li);
if accufact[filn]<0 then accufact[filn]:=0;
a:=trunc(accufact[filn]/10);str(a,s);s:=s+'.';la:=accufact[filn]-a*10;str(la,s1);s:=s+s1;
s:=s+'    ';textxy(135,60,50,s);end;
if(typ[1]=true)and(ch2=#77)and(line=5)and(accufact[filn]<100)then begin if shi=0 then li:=1 else li:=10;inc(accufact[filn],li);
if accufact[filn]>100 then accufact[filn]:=100;
a:=trunc(accufact[filn]/10);str(a,s);s:=s+'.';la:=accufact[filn]-a*10;str(la,s1);s:=s+s1;
s:=s+'    ';textxy(135,60,50,s);end;

if(ch2=#28)and(line=6)then begin a:=1;
str(xdam[filn],s);if length(s)<3 then for wo:=1 to 3-length(s) do insert(' ',s,1);textxy(176,70,50,s);
str(ydam[filn],s);s:=s+'   ';textxy(211,70,50,s);
point(173+(a-1)*35,69,197+(a-1)*35,79,14);
wipe(ownseg,$a000,0,0,16000);
rempoint(173+(a-1)*35,69,197+(a-1)*35,79,0);
repeat
asm mov ah,0;int 16h;mov ch1,al;mov ch2,ah;end;   { ah:scancode }
shi:=shift;
if ch2=#75 then begin dec(a);if a=0 then a:=2;end;
if ch2=#77 then begin inc(a);if a=3 then a:=1;end;
if ch2=#72 then begin if shi>0 then li:=10 else li:=1;if a=1 then inc(xdam[filn],li);if a=2 then inc(ydam[filn],li);
if xdam[filn]>100 then xdam[filn]:=100;if ydam[filn]>100 then ydam[filn]:=100;end;
if ch2=#80 then begin if shi>0 then li:=10 else li:=1;if a=1 then dec(xdam[filn],li);if a=2 then dec(ydam[filn],li);
if xdam[filn]<0 then xdam[filn]:=0;if ydam[filn]<0 then ydam[filn]:=0;end;
str(xdam[filn],s);if length(s)<3 then for wo:=1 to 3-length(s) do insert(' ',s,1);textxy(176,70,50,s);
str(ydam[filn],s);s:=s+'   ';textxy(211,70,50,s);
point(173+(a-1)*35,69,197+(a-1)*35,79,14);
wipe(ownseg,$a000,0,0,16000);
rempoint(173+(a-1)*35,69,197+(a-1)*35,79,0);
until ch2=#28;
end;


if(typ[2]=true)and(ch2=#75)and(line=7)and(expfact[filn]>0)then begin if shi=0 then li:=1 else li:=10;dec(expfact[filn],li);
if expfact[filn]<0 then expfact[filn]:=0;str(expfact[filn],s);s:=s+'            ';textxy(135,80,50,s);end;
if(typ[2]=true)and(expfact[filn]=0)then textxy(135,80,50,'Not in use   ');
if(typ[2]=true)and(ch2=#77)and(line=7)and(expfact[filn]<100)then begin if shi=0 then li:=1 else li:=10;inc(expfact[filn],li);
if expfact[filn]>100 then expfact[filn]:=100;str(expfact[filn],s);s:=s+'            ';textxy(135,80,50,s);end;

if(typ[3]=true)and(ch2=#75)and(line=8)and(exprad[filn]>1)then begin if shi=0 then li:=1 else li:=10;dec(exprad[filn],li);
if exprad[filn]<1 then exprad[filn]:=1;expva:=trunc(exprad[filn]/2);str(expva,s);if(exprad[filn]mod 2)=1 then s:=s+'.5'
else s:=s+'.0';s:=s+'            ';textxy(135,90,50,s);end;
if(typ[3]=true)and(ch2=#77)and(line=8)and(exprad[filn]<100)then begin if shi=0 then li:=1 else li:=10;inc(exprad[filn],li);
if exprad[filn]>100 then exprad[filn]:=100;expva:=trunc(exprad[filn]/2);str(expva,s);if(exprad[filn]mod 2)=1 then s:=s+'.5'
else s:=s+'.0';s:=s+'            ';textxy(135,90,50,s);end;
if(typ[3]=true)and(exprad[filn]=1)then textxy(135,90,50,'Not in use   ');

if(ch2=#75)and(line=9)and(mpscost[filn]>0)then begin if shi=0 then li:=1 else li:=10;dec(mpscost[filn],li);
if mpscost[filn]<0 then mpscost[filn]:=0;str(mpscost[filn],s);s:=s+'    ';textxy(135,100,50,s);end;
if(ch2=#77)and(line=9)and(mpscost[filn]<100)then begin if shi=0 then li:=1 else li:=10;inc(mpscost[filn],li);
if mpscost[filn]>100 then mpscost[filn]:=100;str(mpscost[filn],s);s:=s+'    ';textxy(135,100,50,s);end;

if(typ[4]=true)and(ch2=#75)and(line=10)and(mpscosta[filn]>0)then begin if shi=0 then li:=1 else li:=10;dec(mpscosta[filn],li);
if mpscosta[filn]<0 then mpscosta[filn]:=0;
if mpscosta[filn]>0 then begin str(mpscosta[filn],s);s:=s+'             ';textxy(135,110,50,s);end;end;
if(typ[4]=true)and(mpscosta[filn]=0)then textxy(135,110,50,'Not in use   ');
if(typ[4]=true)and(ch2=#77)and(line=10)and(mpscosta[filn]<100)then begin if shi=0then li:=1 else li:=10;inc(mpscosta[filn],li);
if mpscosta[filn]>100 then mpscosta[filn]:=100;str(mpscosta[filn],s);s:=s+'            ';textxy(135,110,50,s);end;

if(ch2=#75)and(line=11)and(hreq[filn]>1)then begin dec(hreq[filn]);str(hreq[filn],s);s:=s+'    ';textxy(135,120,50,s);end;
if(ch2=#77)and(line=11)and(hreq[filn]<2)then begin inc(hreq[filn]);str(hreq[filn],s);s:=s+'    ';textxy(135,120,50,s);end;

if(typ[5]=true)and(ch2=#75)and(line=12)and(burst[filn]>1)then begin if shi=0 then li:=1 else li:=10;dec(burst[filn],li);
if burst[filn]<1 then burst[filn]:=1;str(burst[filn],s);s:=s+'    ';textxy(135,130,50,s);end;
if(typ[5]=true)and(ch2=#77)and(line=12)and(burst[filn]<100)then begin if shi=0 then li:=1 else li:=10;inc(burst[filn],li);
if burst[filn]>100 then burst[filn]:=100;str(burst[filn],s);s:=s+'    ';textxy(135,130,50,s);end;

if(typ[6]=true)and(ch1=#13)and(line=13)then clnam[filn]:=getstring(135,140,50,16,15,clnam[filn],false);

if(typ[7]=true)and(ch2=#75)and(line=14)and(clsize[filn]>0)then begin if shi=0 then li:=1 else li:=10;dec(clsize[filn],li);
if clsize[filn]<0 then clsize[filn]:=0;str(clsize[filn],s);s:=s+'    ';textxy(135,150,50,s);end;
if(typ[7]=true)and(ch2=#77)and(line=14)and(clsize[filn]<1000)then begin if shi=0 then li:=1 else li:=10;inc(clsize[filn],li);
if clsize[filn]>1000 then clsize[filn]:=1000;str(clsize[filn],s);s:=s+'    ';textxy(135,150,50,s);end;

if(typ[8]=true)and(ch1=#13)and(line=15)then begin str(clprice[filn],s);
val(getstring(135,160,50,6,15,s,true),clprice[filn],code);str(clprice[filn],s);textxy(135,160,50,cle);textxy(135,160,50,s);end;


if(ch2=#73)and(filn<maxweps)and(shi=0)then begin inc(filn);update;end;
if(ch2=#81)and(filn>1)and(shi=0)then begin dec(filn);update;end;

if(ch2=#73)and(shi>0)then begin inc(filn,10);if filn>maxweps then filn:=maxweps;update;end;
if(ch2=#81)and(shi>0)then begin dec(filn,10);if filn<1 then filn:=1;update;end;

if ch2=#72 then begin dec(line);if line<1 then line:=15;end;
if ch2=#80 then begin inc(line);if line>15 then line:=1;end;

if ch2=#31 then begin save;load('Reordering data...');update;end;
if ch2=#38 then begin load('Loading data...');update;end;

until(ch1=#1)or(ch2=#1);
asm mov ax,3h;int 10h;end;
end.

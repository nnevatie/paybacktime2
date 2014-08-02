{$F+}
const maxgr=20;maxpl=20;maxweps=100;maxitem=55;
cle:string='                ';
cletri:string[16]=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
de:array[1..161] of byte=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
typestr:array[1..4] of string=('Projectile weapon','Energy weapon    ','Melee weapon     ','Explosive        ');
itemtypestr:array[1..3] of string=('Armor            ','Medikit          ','Flare            ');

picp:array[1..16*4] of byte=(48,59,59,63,49,54,54,59,50,51,51,56,51,46,46,52,52,43,43,49,53,39,39,46,54,35,35,42,55,32,32,39,
56,28,28,35,57,25,25,32,58,22,22,29,59,19,19,25,60,16,16,22,61,13,13,18,62,10,10,15,63,7,7,12);

var ma,ma1:pointer;n1,i3,a1,i1,mis,i,a,picseg,fontseg,ownseg,saveseg,wo,filr:word;ch1,ch2:char;del,ose:longint;
    n2,man,items,totweps,otpage,page,xs,grnum,by,line,trline,vline,otline:byte;s,s1:string[16];s3:string;
    f:file;f1:file of byte;code,tu:integer;
    undostrg,tempstrg:array[1..255] of byte;
    undomoney:longint;
    grs:byte;wcurmax,icurmax:byte;

    wdraw:array[1..100] of byte;
    idraw:array[1..55] of byte;
    worddraw:array[1..100] of byte;
    iorddraw:array[1..55] of byte;

    grname:array[1..maxgr] of string[16];
    grmoney:array[1..maxgr] of longint;
    grwins,grloses:array[1..maxgr] of word;
    grpls:array[1..maxgr] of byte;
    grstrg:array[1..maxgr,1..255] of byte;

    plname:array[1..maxgr,1..maxpl] of string[16];
    exp,skpoints:array[1..maxgr,1..maxpl] of longint;
    arminuse,tothps,basmp,react,firaccu,melaccu,throaccu:array[1..maxgr,1..maxpl] of byte;
    lochps,locaps:array[1..maxgr,1..maxpl,1..6] of byte;
    invtype:array[1..maxgr,1..maxpl,1..15] of byte;

    wepnam,clnam:array[1..maxweps] of string[16];
    xdam,ydam,accuracy,accufact,expfact,exprad,mpscost,mpscosta,burst,hreq:array[1..maxweps] of shortint;
    weaptype:array[1..maxweps] of byte;
    clprice,wepprice:array[1..maxweps] of longint;
    clsize:array[1..maxweps] of integer;

    itemnam:array[1..maxitem] of string[16];
    itemtype:array[1..maxitem] of shortint;
    itemprice:array[1..maxitem] of longint;
    itemval:array[1..maxitem,1..7] of shortint;

    label exit1,update1;

{$L ASMTOOLS.OBJ}
procedure wipe(seg1,seg2,off1,off2,amount:word);external;
procedure clear(segm,siz:word);external;
procedure fontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure fontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;
procedure sfontxy(x,y,stseg,stofs,fontseg,toseg,col,bcol,len:word);external;
procedure sfontxyt(x,y,stseg,stofs,fontseg,toseg,col,len:word);external;

procedure undo;
begin
grmoney[grnum]:=undomoney;
for i:=1 to 255 do grstrg[grnum,i]:=undostrg[i];
end;

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

procedure loadpic(st1:string);
var file1:file;file2:file of byte;iv,colo,coun,filc,plac,le:longint;
begin filc:=0;plac:=0;
assign(file2,st1);reset(file2);le:=filesize(file2);close(file2);
assign(file1,st1);reset(file1,le);blockread(file1,mem[ownseg:0],1);close(file1);
end;

procedure loadpic2(st1:string);
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

function checkfile(st1:string):boolean;
var fil1:file;begin
assign(fil1,st1);{$i-}reset(fil1);{$i+}
if ioresult=0 then begin checkfile:=true;close(fil1);end else checkfile:=false;
end;

procedure setpal(n,r,g,b:byte);begin port[$3c8]:=n;port[$3c9]:=r;port[$3c9]:=g;port[$3c9]:=b;end;

procedure point(ax,ay,lx,ly:word;col:byte);
begin
for wo:=ax to lx do begin mem[ownseg:wo+(ay shl 8)+(ay shl 6)]:=col;mem[ownseg:wo+(ly shl 8)+(ly shl 6)]:=col;end;
for wo:=ay to ly do begin mem[ownseg:(wo shl 8)+(wo shl 6)+ax]:=col;mem[ownseg:(wo shl 8)+(wo shl 6)+lx]:=col;end;
end;

procedure textxy(x,y:integer;col:byte;text:string);
begin
fastfont(text,x,y,col,0,ownseg,0,1);
end;

function getstring(x,y,col,maxpit,pcol:integer;stri:string;num:boolean):string;
var pla,po,i:integer;c1,c2:char;mi:boolean;
label exit_this;

begin mi:=false;if num=false then
for i:=16 downto 1 do if(stri[i]=#0)or(stri[i]=#32)and(mi=false)then delete(stri,i,1) else mi:=true;
pla:=1;fastfont(stri,x,y,col,0,ownseg,0,1);
repeat
for po:=1 to 5 do mem[$a000:320*(8+y)+x+6*(pla-1)+po-1]:=pcol;
asm mov ah,0;int 16h;mov c1,al;mov c2,ah;end;

{str(mem[seg(c1):ofs(c1)],s);
textxy(106,110,22,s);
wipe(ownseg,$a000,0,0,16000);
wait(50);}

if c1=#27 then begin c1:=#13;c2:=#28;end;

if(c1>=#32)and(length(stri)<maxpit)and(num=false)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1>=#48)and(c1<=#57)and(length(stri)<maxpit)and(num=true)and(pla<=maxpit)then begin
insert(c1,stri,pla);if length(stri)<maxpit then inc(pla);end;
if(c1=#8)and(pla>1)then begin dec(pla);delete(stri,pla,1);end;
if(c2=#83)then delete(stri,pla,1);
if(c2=#75)and(pla>1)then dec(pla);
if(c2=#77)and(pla<maxpit)and(pla<=length(stri))then inc(pla);
for i:=1 to 7 do move(de[1],mem[ownseg:(y+i)*320+x],maxpit*6+1);
fastfont(stri,x,y,col,0,ownseg,0,1);
for i:=1 to 8 do move(mem[ownseg:(y+i)*320+x],mem[$a000:(y+i)*320+x],maxpit*6+1);
until(c1=#13)or(c2=#28);
if num=false then for i:=length(stri)+1 to 20 do insert(#0,stri,i);

exit_this:
getstring:=stri;
end;

function checkrep(gru:byte):string;
var reps:string;
begin
a1:=grwins[gru];i1:=grloses[gru];mis:=a1+i1;
if mis>0 then begin tu:=a1-i1;tu:=round(tu/mis*10);end;
if tu<-0 then reps:='Troubled ';
if tu<-3 then reps:='Weak     ';
if(mis>=5)and(tu<-6)then reps:='Pathetic ';
if(mis>=10)and(tu<-9)then reps:='Crushed  ';
if tu>=0 then reps:='Average  ';
if tu>3 then reps:='Good     ';
if (mis>=10) and (tu>5) then reps:='Notorious';
if (mis>=15) and (tu>7) then reps:='Awesome  ';
if (mis>=20) and (tu>9) then reps:='Ultimate ';
if mis=0 then reps:='Average';
checkrep:=reps;
end;

function rank(grp,plr:byte):string;
var ranks:string;
begin
ranks:='Rookie    ';
if exp[grp,plr]>=500 then ranks:='Trooper   ';
if exp[grp,plr]>=1000 then ranks:='Private   ';
if exp[grp,plr]>=2500 then ranks:='Corporal  ';
if exp[grp,plr]>=4000 then ranks:='Sergeant  ';
if exp[grp,plr]>=6000 then ranks:='Lieutenant';
if exp[grp,plr]>=9000 then ranks:='Captain   ';
if exp[grp,plr]>=15000 then ranks:='Major     ';
if exp[grp,plr]>=30000 then ranks:='Colonel   ';
if exp[grp,plr]>=60000 then ranks:='General   ';
rank:=ranks;
end;

procedure updategr;
begin
line:=1;loadpic('gfx\grouped.svf');
textxy(3,12,22,'Update warrior');textxy(3,24,22,'Hire warrior  ');textxy(3,36,22,'Dismiss warrior');
textxy(3,48,22,'Storages');
textxy(142,24,22,'Credits      :');
textxy(142,36,22,'Warriors     :');
textxy(142,48,22,'Victories    :');
textxy(142,60,22,'Losses       :');
textxy(142,72,22,'Reputation   :');
textxy(142,12,22,grname[grnum]);
str(grmoney[grnum],s);textxy(244,24,22,s);str(grpls[grnum],s);textxy(244,36,22,s);
str(grwins[grnum],s);textxy(244,48,22,s);str(grloses[grnum],s);textxy(244,60,22,s);
textxy(244,72,22,checkrep(grnum));
textxy(142,116,22,'Hit points         :');
textxy(142,128,22,'Movement points    :');
textxy(142,140,22,'Reactions          :');
textxy(142,152,22,'Firing accuracy    :');
textxy(142,164,22,'Throwing accuracy  :');
textxy(142,176,22,'Melee accuracy     :');
textxy(142,188,22,'Rank  : ');
for i:=1 to 8 do textxy(3,90+12*i,22,plname[grnum,i]);
end;

procedure updatewe(wn:byte);
begin
textxy(3,113,22,'Type      :');textxy(99,113,22,typestr[weaptype[wn]]);
textxy(3,123,22,'Accuracy  :');textxy(163,123,22,'Acc. factor :');
str(accuracy[wn],s);s:=s+'  ';if(accuracy[wn]=0)then s:='-   ';textxy(99,123,22,s);
a:=trunc(accufact[wn]/10);str(a,s);s:=s+'.';a1:=accufact[wn]-a*10;str(a1,s1);s:=s+s1;if a<10 then s:=s+'  ';
if(weaptype[wn]>2)then s:='-    ';textxy(275,123,22,s);
textxy(3,133,22,'Damage    :');textxy(163,133,22,'Hands req.  :');
textxy(99,133,0,'       ');str(ydam[wn],s);str(xdam[wn]+ydam[wn],s1);textxy(99,133,22,s);xs:=107;if length(s)=2 then xs:=115;
if length(s)=3 then xs:=123;textxy(xs,133,22,'-');textxy(xs+8,133,22,s1);str(hreq[wn],s);textxy(275,133,22,s);
textxy(3,143,22,'Exp. rad. :');textxy(163,143,22,'Exp. factor :');
a1:=trunc(exprad[wn]/2);str(a1,s);if(exprad[wn]mod 2)=1 then s:=s+'.5' else s:=s+'.0';
if length(s)<4 then s:=s+' ';if exprad[wn]=1 then s:='-   ';
textxy(99,143,22,s);str(expfact[wn],s);s:=s+'  ';if expfact[wn]=0 then s:='-   ';textxy(275,143,22,s);
textxy(3,153,22,'MPS Cost  :');textxy(163,153,22,'MPS C. auto :');
str(mpscost[wn],s);s:=s+'  ';textxy(99,153,22,s);str(mpscosta[wn],s);s:=s+'  ';
if(mpscosta[wn]=0)then s:='-   ';textxy(275,153,22,s);
textxy(3,163,22,'Clip size :');textxy(163,163,22,'Max burst   :');
str(clsize[wn],s);if length(s)<4 then for a1:=1 to 4-length(s) do s:=s+' ';if clsize[wn]=0 then s:='-   ';textxy(99,163,22,s);
str(burst[wn],s);s:=s+'  ';if(weaptype[wn]<>2) then s:='-   ';textxy(275,163,22,s);
textxy(3,173,22,'Clip Type :');textxy(99,173,22,clnam[wn]);
end;

procedure updateitem(it:byte);
begin
textxy(3,113,22,'Type        :');
if(itemtype[it]>=1)and(itemtype[it]<=3)then textxy(115,113,22,itemtypestr[itemtype[it]]);
if itemtype[it]=1 then begin
textxy(3,123,22,'Head Armor  :');str(itemval[it,1],s);
if(itemval[it,1]<10)then s:=s+' ';if(itemval[it,1]<100)then s:=s+' ';
s:=s+'   ';textxy(115,123,22,s);
textxy(163,123,22,'Chest Armor :');str(itemval[it,2],s);s:=s+'  ';textxy(275,123,22,s);
textxy(3,133,22,'R.arm Armor :');str(itemval[it,3],s);s:=s+'  ';textxy(115,133,22,s);
textxy(163,133,22,'L.arm Armor :');str(itemval[it,4],s);s:=s+'  ';textxy(275,133,22,s);
textxy(3,143,22,'R.leg Armor :');str(itemval[it,5],s);s:=s+'  ';textxy(115,143,22,s);
textxy(163,143,22,'L.leg Armor :');str(itemval[it,6],s);s:=s+'  ';textxy(275,143,22,s);
textxy(3,153,22,'MPS Penalty :');str(itemval[it,7],s);s:=s+'  ';textxy(115,153,22,s);
end;
if(itemtype[it]=2)then begin
textxy(3,123,22,'Charges     :');str(itemval[it,1],s);
if(itemval[it,1]<10)then s:=s+' ';if(itemval[it,1]<100)then s:=s+' ';
s:=s+'   ';textxy(115,123,22,s);
textxy(163,123,22,'             ');textxy(275,123,22,'    ');
textxy(3,133,22,'Healing     :');str(itemval[it,2],s);s:=s+'  ';textxy(115,133,22,s);
textxy(163,133,22,'             ');textxy(275,133,22,'    ');
textxy(3,143,22,'             ');textxy(115,143,22,'    ');
textxy(163,143,22,'             ');textxy(275,143,22,'    ');
textxy(3,153,22,'             ');textxy(115,153,22,'    ');
end;
if(itemtype[it]=3)then begin
textxy(3,123,22,'Radius      :');
if(it=1)then textxy(115,123,22,'Short ');
if(it=2)then textxy(115,123,22,'Medium');
if(it=3)then textxy(115,123,22,'Long  ');
textxy(163,123,22,'             ');textxy(275,123,22,'    ');
textxy(3,133,22,'             ');textxy(115,133,22,'    ');
textxy(163,133,22,'             ');textxy(275,133,22,'    ');
textxy(3,143,22,'             ');textxy(115,143,22,'    ');
textxy(163,143,22,'             ');textxy(275,143,22,'    ');
textxy(3,153,22,'             ');textxy(115,153,22,'    ');
end;
end;

procedure updatepage;
var pli:word;tcol:byte;te:boolean;begin
for i:=(page-1)*8+1 to (page-1)*8+8 do begin pli:=i-(page-1)*8;
if i>totweps then te:=true else te:=false;
if te=false then begin
if(grstrg[grnum,i]>0)or(grstrg[grnum,100+i]>0)then tcol:=10 else tcol:=20;
textxy(12,19+pli*10,12+tcol,'  / ');textxy(233,19+pli*10,tcol+12,'    / ');
textxy(64,19+pli*10,12+tcol,wepnam[i]);
str(grstrg[grnum,i],s);if grstrg[grnum,i]<10 then insert(' ',s,1);
textxy(8,19+pli*10,tcol+12,s);str(grstrg[grnum,i+100],s);
if grstrg[grnum,100+i]<10 then insert(' ',s,1);textxy(32,19+pli*10,tcol+12,s);
str(wepprice[i],s);if length(s)<6 then for i1:=1 to 6-length(s) do insert(' ',s,1);textxy(209,19+pli*10,tcol+12,s);
str(clprice[i],s);if length(s)<6 then for i1:=1 to 6-length(s) do insert(' ',s,1);textxy(265,19+pli*10,tcol+12,s);end;
if te=true then begin textxy(209,19+pli*10,0,'                ');textxy(64,19+pli*10,0,cle);textxy(8,19+pli*10,0,'       ');
end;end;end;

procedure updateequip;
var pli:word;te:boolean;begin
for i:=(page-1)*8+1 to (page-1)*8+8 do begin pli:=i-(page-1)*8;
if(worddraw[i]=0)then te:=true else te:=false;

if te=false then begin
textxy(18,19+pli*10,22,' / ');textxy(251,19+pli*10,22,' / ');
textxy(64,19+pli*10,22,wepnam[worddraw[i]]);
str(grstrg[grnum,worddraw[i]],s);if grstrg[grnum,worddraw[i]]<10 then insert(' ',s,1);textxy(8,19+pli*10,22,s);
str(grstrg[grnum,worddraw[i]+100],s);if grstrg[grnum,100+worddraw[i]]<10 then insert(' ',s,1);textxy(32,19+pli*10,22,s);
str(tempstrg[worddraw[i]],s);if tempstrg[worddraw[i]]<10 then insert(' ',s,1);textxy(241,19+pli*10,22,s);
str(tempstrg[worddraw[i]+100],s);if tempstrg[100+worddraw[i]]<10 then insert(' ',s,1);textxy(265,19+pli*10,22,s);
end;

if te=true then begin textxy(209,19+pli*10,0,'                ');textxy(64,19+pli*10,0,cle);textxy(8,19+pli*10,0,'       ');
end;end;end;


procedure upitempage;
var pli:word;te:boolean;tcol2:byte;
begin
for i:=(otpage-1)*8+1 to (otpage-1)*8+8 do begin pli:=i-(otpage-1)*8;
if i>items then te:=true else te:=false;
if te=false then begin
if(grstrg[grnum,200+i]>0)then tcol2:=10 else tcol2:=20;
textxy(64,19+pli*10,12+tcol2,itemnam[i]);
str(grstrg[grnum,200+i],s);if grstrg[grnum,200+i]<10 then insert(' ',s,1);textxy(19,19+pli*10,12+tcol2,s);
str(itemprice[i],s);if length(s)<6 then for i1:=1 to 6-length(s) do insert(' ',s,1);textxy(231,19+pli*10,12+tcol2,s);end;
if te=true then begin textxy(209,19+pli*10,0,'             ');textxy(64,19+pli*10,0,cle);textxy(8,19+pli*10,0,'     ');end;
end;end;

procedure upitemequip;
var pli:word;te:boolean;begin
for i:=(otpage-1)*8+1 to (otpage-1)*8+8 do begin pli:=i-(otpage-1)*8;
if(iorddraw[i]=0)then te:=true else te:=false;
if te=false then begin
textxy(64,19+pli*10,22,itemnam[iorddraw[i]]);
str(grstrg[grnum,200+iorddraw[i]],s);
if grstrg[grnum,200+iorddraw[i]]<10 then insert(' ',s,1);
textxy(19,19+pli*10,22,s);
str(tempstrg[200+iorddraw[i]],s);
if tempstrg[200+iorddraw[i]]<10 then insert(' ',s,1);s:=s+'  ';textxy(234,19+pli*10,22,' '+s);
if itemtype[iorddraw[i]]=1 then textxy(204,19+pli*10,22,'       -      ');
if(arminuse[grnum,man]>0)and(arminuse[grnum,man]=iorddraw[i]-3) then textxy(206,19+pli*10,22,'     Worn    ');
{FLARES !}
end;
if te=true then begin textxy(203,19+pli*10,0,'             ');textxy(64,19+pli*10,0,cle);textxy(8,19+pli*10,0,'     ');end;
end;end;


procedure loadweps;var la:byte;begin
if checkfile('data\weapons.dat')=true then begin
assign(f1,'data\weapons.dat');reset(f1);wo:=filesize(f1);filr:=trunc(wo/59);totweps:=filr;
for wo:=1 to filr do begin
read(f1,weaptype[wo]);
wepnam[wo]:=cletri;for a:=1 to 16 do begin read(f1,by);wepnam[wo][a]:=chr(by);end;
la:=1;s:='      ';for a:=1 to 6 do begin read(f1,by);if by<>32then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,wepprice[wo],code);read(f1,by);accuracy[wo]:=by;
read(f1,by);accufact[wo]:=by;read(f1,by);xdam[wo]:=by;read(f1,by);ydam[wo]:=by;
read(f1,by);expfact[wo]:=by;read(f1,by);exprad[wo]:=by;read(f1,by);mpscost[wo]:=by;
read(f1,by);mpscosta[wo]:=by;read(f1,by);hreq[wo]:=by;read(f1,by);burst[wo]:=by;
delete(clnam[wo],0,256);clnam[wo]:=cletri;for a:=1 to 16 do begin read(f1,by);clnam[wo][a]:=chr(by);end;
la:=1;s:='    ';for a:=1 to 4 do begin read(f1,by);if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,5-la);val(s,clsize[wo],code);
la:=1;s:='      ';for a:=1 to 6 do begin read(f1,by);if(by<>32)then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,clprice[wo],code);
end;close(f1);end;end;

procedure loaditems;var la:byte;begin
if checkfile('data\items.dat')=true then begin
assign(f1,'data\items.dat');reset(f1);wo:=filesize(f1);filr:=trunc(wo/30);items:=filr+3;
for wo:=1+3 to filr+3 do begin read(f1,by);itemtype[wo]:=by;
itemnam[wo]:=cletri;for a:=1 to 16 do begin read(f1,by);itemnam[wo][a]:=chr(by);end;
la:=1;s:='      ';for a:=1 to 6 do begin read(f1,by);if by<>32then inc(la);s[a]:=chr(by);end;
delete(s,la,7-la);val(s,itemprice[wo],code);
read(f1,by);itemval[wo,1]:=by;read(f1,by);itemval[wo,2]:=by;read(f1,by);itemval[wo,3]:=by;
read(f1,by);itemval[wo,4]:=by;read(f1,by);itemval[wo,5]:=by;read(f1,by);itemval[wo,6]:=by;
read(f1,by);itemval[wo,7]:=by;
end;close(f1);end;
itemnam[1]:='Small flare     ';itemprice[1]:=100;itemtype[1]:=3;for wo:=1 to 7 do itemval[1,wo]:=0;
itemnam[2]:='Medium flare    ';itemprice[2]:=250;itemtype[2]:=3;for wo:=1 to 7 do itemval[2,wo]:=0;
itemnam[3]:='Large flare     ';itemprice[3]:=500;itemtype[3]:=3;for wo:=1 to 7 do itemval[3,wo]:=0;
end;

procedure lookinv(planu:byte);
begin for i:=0 to 255 do tempstrg[i]:=0;
for i:=1 to 15 do if invtype[grnum,planu,i]<>0 then inc(tempstrg[invtype[grnum,planu,i]]);
end;

procedure dumpinv(planu:byte);
begin for a:=1 to 15 do invtype[grnum,planu,a]:=0;a:=0;
for i:=1 to 255 do if tempstrg[i]<>0 then
for i1:=1 to tempstrg[i] do begin inc(a);invtype[grnum,planu,a]:=i;end;
end;

procedure updatescreen;
begin
textxy(3,32,22,'Choose Equipment');textxy(3,44,22,'Train Warrior   ');
textxy(3,56,22,'Heal Warrior    ');
s3:=rank(grnum,man);for i:=12 downto 1 do  if s3[i]=' ' then delete(s3,i,1);s3:=s3+'  '+plname[grnum,man];
textxy(3,10,22,s3);
textxy(164,32,22,'Experience :');str(exp[grnum,man],s);textxy(268,32,22,s);
textxy(164,44,22,'Skill Pts  :');str(skpoints[grnum,man],s);textxy(268,44,22,s);
textxy(164,68,22,'Hit points :');str(tothps[grnum,man],s);textxy(268,68,22,s);
textxy(164,80,22,'MPS        :');str(basmp[grnum,man],s);textxy(268,80,22,s);
textxy(164,92,22,'Reactions  :');str(react[grnum,man],s);textxy(268,92,22,s);
textxy(164,104,22,'Fir. Acc.  :');str(firaccu[grnum,man],s);textxy(268,104,22,s);

textxy(164,116,22,'Thro. acc. :');
str(throaccu[grnum,man],s);textxy(268,116,22,s);
textxy(164,128,22,'Mel. Acc.  :');
str(melaccu[grnum,man],s);textxy(268,128,22,s);

textxy(67,92,22,'HPS');textxy(106,92,22,'Armor');
textxy(3,104,22,'Head');textxy(3,116,22,'Chest');
textxy(3,128,22,'R.Arm');textxy(3,140,22,'L.Arm');
textxy(3,152,22,'R.Leg');textxy(3,164,22,'L.Leg');
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
str(locaps[grnum,man,1],s);if length(s)=1 then insert('  ',s,1);if length(s)=2 then insert(' ',s,1);textxy(115,104,22,s);
str(locaps[grnum,man,2],s);if length(s)=1 then insert('  ',s,1);if length(s)=2 then insert(' ',s,1);textxy(115,116,22,s);
str(locaps[grnum,man,3],s);if length(s)=1 then insert('  ',s,1);if length(s)=2 then insert(' ',s,1);textxy(115,128,22,s);
str(locaps[grnum,man,4],s);if length(s)=1 then insert('  ',s,1);if length(s)=2 then insert(' ',s,1);textxy(115,140,22,s);
str(locaps[grnum,man,5],s);if length(s)=1 then insert('  ',s,1);if length(s)=2 then insert(' ',s,1);textxy(115,152,22,s);
str(locaps[grnum,man,6],s);if length(s)=1 then insert('  ',s,1);if length(s)=2 then insert(' ',s,1);textxy(115,164,22,s);
end;

procedure checkhps;
begin
if round(tothps[grnum,man]*0.08)<>round((tothps[grnum,man]-1)*0.08) then inc(lochps[grnum,man,1]);
if round(tothps[grnum,man]*0.28)<>round((tothps[grnum,man]-1)*0.28) then inc(lochps[grnum,man,2]);
if round(tothps[grnum,man]*0.16)<>round((tothps[grnum,man]-1)*0.16) then begin inc(lochps[grnum,man,3]);
inc(lochps[grnum,man,4]);inc(lochps[grnum,man,5]);inc(lochps[grnum,man,6]);end;
end;

procedure updatehps;
begin
str(lochps[grnum,man,1],s);if length(s)=1 then insert(' ',s,1);textxy(59,104,22,s);textxy(75,104,22,'/');
str(round(tothps[grnum,man]*0.08),s);if length(s)=1 then insert(' ',s,1);textxy(83,104,22,s);
str(lochps[grnum,man,2],s);if length(s)=1 then insert(' ',s,1);textxy(59,116,22,s);textxy(75,116,22,'/');
str(round(tothps[grnum,man]*0.28),s);if length(s)=1 then insert(' ',s,1);textxy(83,116,22,s);
str(lochps[grnum,man,3],s);if length(s)=1 then insert(' ',s,1);textxy(59,128,22,s);textxy(75,128,22,'/');
str(round(tothps[grnum,man]*0.16),s);if length(s)=1 then insert(' ',s,1);textxy(83,128,22,s);
str(lochps[grnum,man,4],s);if length(s)=1 then insert(' ',s,1);textxy(59,140,22,s);textxy(75,140,22,'/');
str(round(tothps[grnum,man]*0.16),s);if length(s)=1 then insert(' ',s,1);textxy(83,140,22,s);
str(lochps[grnum,man,5],s);if length(s)=1 then insert(' ',s,1);textxy(59,152,22,s);textxy(75,152,22,'/');
str(round(tothps[grnum,man]*0.16),s);if length(s)=1 then insert(' ',s,1);textxy(83,152,22,s);
str(lochps[grnum,man,6],s);if length(s)=1 then insert(' ',s,1);textxy(59,164,22,s);textxy(75,164,22,'/');
str(round(tothps[grnum,man]*0.16),s);if length(s)=1 then insert(' ',s,1);textxy(83,164,22,s);
end;

procedure gotoupdatescr;
var loc:byte;
begin
man:=vline;loadpic('gfx\updatewa.svf');updatescreen;updatehps;

repeat
point(2,30+(line-1)*12,132,42+(line-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,30+(line-1)*12,132,42+(line-1)*12,0);
asm mov ah,0;int 16h;mov ch2,ah;end;
if(ch2=#80)then begin inc(line);if line>3 then line:=1;end;
if(ch2=#72)then begin dec(line);if line<1 then line:=3;end;

if(ch2=#28)and(line=1)then begin { Choose Equipment }
lookinv(man);line:=1;page:=1;otpage:=1;trline:=1;otline:=1;vline:=1;
loadpic('gfx\storages.svf');

textxy(25,3,22,'Weapons');textxy(139,3,22,'Clips');textxy(242,3,22,'Others');
textxy(12,16,22,'Unit');textxy(64,16,22,'Weapon name');textxy(233,16,22,'Warrior');

{ calculate array }
for i:=1 to 100 do wdraw[i]:=0;for i:=1 to 55 do idraw[i]:=0;
for i:=1 to 100 do worddraw[i]:=0;
for i:=1 to 55 do iorddraw[i]:=0;
for i:=1 to 200 do if(grstrg[grnum,i]>0)then
if(i<=100)then wdraw[i]:=1 else wdraw[i-100]:=1;

for i:=201 to 255 do if(grstrg[grnum,i]>0)then idraw[i-200]:=1;

for i:=1 to 15 do if(invtype[grnum,man,i]>=1)and(invtype[grnum,man,i]<=100)then wdraw[invtype[grnum,man,i]]:=1;
for i:=1 to 15 do if(invtype[grnum,man,i]>=101)and(invtype[grnum,man,i]<=200)then wdraw[invtype[grnum,man,i]-100]:=1;

for i:=1 to 15 do if(invtype[grnum,man,i]>=201)and(invtype[grnum,man,i]<=255)then idraw[invtype[grnum,man,i]-200]:=1;
if arminuse[grnum,man]>0 then idraw[arminuse[grnum,man]+3]:=1;

loc:=0;for i:=1 to 100 do if(wdraw[i]=1)then begin inc(loc);worddraw[loc]:=i;end;wcurmax:=loc;
loc:=0;for i:=1 to 55 do if(idraw[i]=1)then begin inc(loc);iorddraw[loc]:=i;end;icurmax:=loc;

{ calculate array }

updateequip;

repeat  { Choose eq. Storage }
if line=1 then point(23,2,82,13,4);if line=2 then point(137,2,180,13,4);if line=3 then point(240,2,291,13,4);
wipe(ownseg,$a000,0,0,16000);
if line=1 then point(23,2,82,13,0);if line=2 then point(137,2,180,13,0);if line=3 then point(240,2,291,13,0);
asm mov ah,0;int 16h;mov ch2,ah;end;
if(ch2=#77)then if line>=3 then line:=1 else inc(line);
if(ch2=#75)then if line<=1 then line:=3 else dec(line);


if(ch2=#28)and(line<=2)and(wcurmax>0)then begin { Weapons / Clips }
for i:=203 to 317 do for a:=27 to 109 do mem[ownseg:a*320+i]:=0;
lookinv(man);textxy(64,16,22,'Weapon name');updatewe(worddraw[(page-1)*8+trline]);updateequip;
repeat
point(62,18+trline*10,194,28+trline*10,4);
wipe(ownseg,$a000,0,0,16000);
point(62,18+trline*10,194,28+trline*10,0);
asm mov ah,0;int 16h;mov ch2,ah;end;

if(ch2=#80)and(trline+(page-1)*8<wcurmax)then begin if(trline>=8)and(page<1+trunc(wcurmax/8))then begin inc(page);
updateequip;trline:=1 end else inc(trline);updatewe(worddraw[(page-1)*8+trline]);end;
if(ch2=#72)and(trline+(page-1)*8>1)then begin if(page>1)and(trline<=1)then begin dec(page);updateequip;trline:=8;end
else dec(trline);updatewe(worddraw[(page-1)*8+trline]);end;

if(ch2=#81)and(page<1+trunc((wcurmax-1)/8))then begin inc(page);if trline+(page-1)*8>wcurmax then trline:=wcurmax-(page-1)*8;
updateequip;updatewe(worddraw[(page-1)*8+trline]);end;
if(ch2=#73)and(page>1)then begin dec(page);updateequip;updatewe(worddraw[(page-1)*8+trline]);end;

if(ch2=#77)and(grstrg[grnum,worddraw[trline+(page-1)*8]]>0)and(line=1)then begin
i:=0;for a:=1 to 255 do inc(i,tempstrg[a]);
if i<15 then begin inc(tempstrg[worddraw[trline+(page-1)*8]]);
dec(grstrg[grnum,worddraw[trline+(page-1)*8]]);updateequip;
end;end;

if(ch2=#75)and(tempstrg[worddraw[trline+(page-1)*8]]>0)and(grstrg[grnum,worddraw[trline+(page-1)*8]]<99)and(line=1)then
begin dec(tempstrg[worddraw[trline+(page-1)*8]]);
inc(grstrg[grnum,worddraw[trline+(page-1)*8]]);updateequip;
end;

if(ch2=#77)and(grstrg[grnum,100+worddraw[trline+(page-1)*8]]>0)and(line=2)then begin
i:=0;for a:=1 to 255 do inc(i,tempstrg[a]);
if i<15 then begin inc(tempstrg[100+worddraw[trline+(page-1)*8]]);
dec(grstrg[grnum,100+worddraw[trline+(page-1)*8]]);updateequip;
end;end;

if(ch2=#75)and(tempstrg[100+worddraw[trline+(page-1)*8]]>0)and(grstrg[grnum,100+worddraw[trline+(page-1)*8]]<99)and(line=2)then
begin dec(tempstrg[100+worddraw[trline+(page-1)*8]]);
inc(grstrg[grnum,100+worddraw[trline+(page-1)*8]]);updateequip;
end;

until ch2=#1;
dumpinv(man);if ch2=#1 then ch2:=#0;updateequip;for i:=2 to 317 do for a:=111 to 184 do mem[ownseg:a*320+i]:=0;
end;                             { Weapons / Clips }

if(ch2=#28)and(line=3)then begin { Others }
for i:=2 to 53 do for a:=27 to 109 do mem[ownseg:a*320+i]:=0;for i:=203 to 317 do for a:=27 to 109 do mem[ownseg:a*320+i]:=0;
lookinv(man);textxy(64,16,22,' Item name ');
if icurmax>0 then begin
updateitem(iorddraw[(otpage-1)*8+otline]);upitemequip;
repeat
point(62,18+otline*10,194,28+otline*10,4);
wipe(ownseg,$a000,0,0,16000);
point(62,18+otline*10,194,28+otline*10,0);

asm mov ah,0;int 16h;mov ch2,ah;end;

if(ch2=#80)and(otline+(otpage-1)*8<icurmax)then begin if(otline>=8)and(otpage<1+trunc(icurmax/8))then begin inc(otpage);
upitemequip;otline:=1 end else inc(otline);updateitem(iorddraw[(otpage-1)*8+otline]);end;
if(ch2=#72)and(otline+(otpage-1)*8>1)then begin if(otpage>1)and(otline<=1)then begin dec(otpage);upitemequip;otline:=8;end
else dec(otline);updateitem(iorddraw[(otpage-1)*8+otline]);end;

if(ch2=#81)and(otpage<1+trunc((icurmax-1)/8))then begin inc(otpage);
if otline+(otpage-1)*8>icurmax then otline:=icurmax-(otpage-1)*8;
upitemequip;updateitem(iorddraw[(otpage-1)*8+otline]);
end;

if(ch2=#73)and(otpage>1)then begin dec(otpage);
upitemequip;updateitem(iorddraw[(otpage-1)*8+otline]);end;

if(ch2=#75)and(grstrg[grnum,200+iorddraw[otline+(otpage-1)*8]]<99)then
if(itemtype[iorddraw[otline+(otpage-1)*8]]<>1)and(tempstrg[200+iorddraw[otline+(otpage-1)*8]]>0)then begin
dec(tempstrg[200+iorddraw[otline+(otpage-1)*8]]);
inc(grstrg[grnum,200+iorddraw[otline+(otpage-1)*8]]);upitemequip;end else
if(arminuse[grnum,man]>0)and(iorddraw[otline+(otpage-1)*8]=arminuse[grnum,man]+3)then begin
inc(grstrg[grnum,200+arminuse[grnum,man]+3]);
inc(basmp[grnum,man],itemval[arminuse[grnum,man]+3,7]);
arminuse[grnum,man]:=0;upitemequip;
for a1:=1 to 6 do locaps[grnum,man,a1]:=0;
 end;

if(ch2=#77)and(grstrg[grnum,200+iorddraw[otline+(otpage-1)*8]]>0)then begin
i:=0;for a:=1 to 255 do inc(i,tempstrg[a]);
if(i<15)and(itemtype[iorddraw[otline+(otpage-1)*8]]<>1)then begin
dec(grstrg[grnum,200+iorddraw[otline+(otpage-1)*8]]);
inc(tempstrg[200+iorddraw[otline+(otpage-1)*8]]);end
else if(arminuse[grnum,man]=0)and(itemtype[iorddraw[otline+(otpage-1)*8]]=1)then
if itemval[iorddraw[otline+(otpage-1)*8],7]<=basmp[grnum,man]-10 then begin
dec(grstrg[grnum,200+iorddraw[otline+(otpage-1)*8]]);
arminuse[grnum,man]:=iorddraw[otline+(otpage-1)*8]-3;{FLARES !}
for a1:=1 to 6 do locaps[grnum,man,a1]:=itemval[arminuse[grnum,man]+3,a1];
dec(basmp[grnum,man],itemval[arminuse[grnum,man]+3,7]);
end else begin textxy(70,188,22,'     Too heavy !           ');
wipe(ownseg,$a000,0,0,16000);
asm mov ah,0;int 16h;mov ch2,ah;end;ch2:=#0;end;
textxy(70,188,22,'                      ');
upitemequip;end;


until ch2=#1;
dumpinv(man);if ch2=#1 then ch2:=#0;upitemequip;for i:=2 to 317 do for a:=111 to 184 do mem[ownseg:a*320+i]:=0;
end;                             { Others }
end; {if icurmax>0}
until ch2=#1;            { Choose eq. Storage }
if ch2=#1 then ch2:=#0;trline:=1;vline:=1;line:=1;
loadpic('gfx\updatewa.svf');updatescreen;updatehps;

end;                             { Choose Equipment }

if(ch2=#28)and(line=2)then begin   { Use Skillpoints }
trline:=1;
repeat
point(162,66+(trline-1)*12,260,78+(trline-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(162,66+(trline-1)*12,260,78+(trline-1)*12,0);
asm mov ah,0;int 16h;mov ch2,ah;end;

{ If you want to fix your players please take the next 6 lines into use }
{if(ch2=#57)and(skpoints[grnum,man]<99000)then begin
inc(skpoints[grnum,man],1000);inc(exp[grnum,man],1000);
str(exp[grnum,man],s);
if(exp[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,32,22,s);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
if(grmoney[grnum]<990000)then inc(grmoney[grnum],10000);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;}

{textxy(164,128,22,'Mel. Acc.  :');
str(melaccu[grnum,man],s);
textxy(268,128,22,s);}

if(ch2=#80)then if trline>=6 then trline:=1 else inc(trline);
if(ch2=#72)then if trline<=1 then trline:=6 else dec(trline);

if(ch2=#28)and(trline=1)and(grmoney[grnum]>=(react[grnum,man]*50/2))and
(skpoints[grnum,man]>=round(tothps[grnum,man]/2))and
(tothps[grnum,man]<250)then
begin dec(grmoney[grnum],tothps[grnum,man]*25);
dec(skpoints[grnum,man],round(tothps[grnum,man]/2));inc(tothps[grnum,man]);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
str(tothps[grnum,man],s);textxy(268,68,22,s);checkhps;updatehps;
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;

if(ch2=#28)and(trline=2)then begin
if(arminuse[grnum,man]<>0)then a:=itemval[arminuse[grnum,man]+3,7] else a:=0;
if(skpoints[grnum,man]>=round((basmp[grnum,man]+a)/2))then begin
if(basmp[grnum,man]+a<250)and(grmoney[grnum]>=((basmp[grnum,man]+a)*50/2))then
begin dec(grmoney[grnum],(basmp[grnum,man]+a)*25);
dec(skpoints[grnum,man],round((basmp[grnum,man]+a)/2));inc(basmp[grnum,man]);
str(skpoints[grnum,man],s);s:=s+'  ';textxy(268,44,22,s);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
str(basmp[grnum,man],s);textxy(268,80,22,s);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;end;end;

if(ch2=#28)and(trline=3)and(grmoney[grnum]>=(react[grnum,man]*3*50))and
(skpoints[grnum,man]>=round(react[grnum,man]*3))and
(react[grnum,man]<90)then
begin dec(grmoney[grnum],react[grnum,man]*3*50);
dec(skpoints[grnum,man],round(react[grnum,man]*3));inc(react[grnum,man]);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
str(react[grnum,man],s);textxy(268,92,22,s);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;

if(ch2=#28)and(trline=4)and(grmoney[grnum]>=(firaccu[grnum,man]*2*50))and
(skpoints[grnum,man]>=firaccu[grnum,man]*2)and
(firaccu[grnum,man]<200)then
begin dec(grmoney[grnum],firaccu[grnum,man]*2*50);
dec(skpoints[grnum,man],firaccu[grnum,man]*2);inc(firaccu[grnum,man]);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
str(firaccu[grnum,man],s);textxy(268,104,22,s);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;

if(ch2=#28)and(trline=5)and(grmoney[grnum]>=(throaccu[grnum,man]*50))and
(skpoints[grnum,man]>=throaccu[grnum,man])and
(throaccu[grnum,man]<150)then
begin dec(grmoney[grnum],throaccu[grnum,man]*50);
dec(skpoints[grnum,man],throaccu[grnum,man]);inc(throaccu[grnum,man]);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
str(throaccu[grnum,man],s);textxy(268,116,22,s);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;

if(ch2=#28)and(trline=6)and(grmoney[grnum]>=(melaccu[grnum,man]*50))and
(skpoints[grnum,man]>=melaccu[grnum,man])and
(melaccu[grnum,man]<100)then
begin dec(grmoney[grnum],melaccu[grnum,man]*50);
dec(skpoints[grnum,man],melaccu[grnum,man]);inc(melaccu[grnum,man]);
str(skpoints[grnum,man],s);if(skpoints[grnum,man]<1000)then s:=s+' ';s:=s+' ';textxy(268,44,22,s);
str(melaccu[grnum,man],s);textxy(268,128,22,s);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;


until ch2=#1;
if ch2=#1 then ch2:=#0;
end;                               { Use Skillpoints }

if(ch2=#28)and(line=3)then begin   { Heal Warrior }
i1:=0;a:=0;
for i:=1 to 6 do inc(a,lochps[grnum,man,i]);
inc(i1,round(tothps[grnum,man]*0.08));inc(i1,round(tothps[grnum,man]*0.28));
inc(i1,round(tothps[grnum,man]*0.16));inc(i1,round(tothps[grnum,man]*0.16));
inc(i1,round(tothps[grnum,man]*0.16));inc(i1,round(tothps[grnum,man]*0.16));
a:=i1-a;a:=a*30;
if grmoney[grnum]>=a then begin dec(grmoney[grnum],a);
lochps[grnum,man,1]:=round(tothps[grnum,man]*0.08);
lochps[grnum,man,2]:=round(tothps[grnum,man]*0.28);
for i:=3 to 6 do lochps[grnum,man,i]:=round(tothps[grnum,man]*0.16);
updatehps;textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;end;                           { Heal Warrior }
until(ch2=#1);
end;

procedure intosaveseg(vl:byte);
begin
move(grs,mem[saveseg:ose],1);inc(ose,1);
for i:=1 to maxgr do if i<>vl then begin
move(grname[i,1],mem[saveseg:ose],16);inc(ose,16);
move(grmoney[i],mem[saveseg:ose],4);inc(ose,4);
move(grwins[i],mem[saveseg:ose],2);inc(ose,2);
move(grloses[i],mem[saveseg:ose],2);inc(ose,2);
move(grpls[i],mem[saveseg:ose],1);inc(ose,1);
move(grstrg[i,1],mem[saveseg:ose],200);
mem[saveseg:ose+250]:=grstrg[i,201+0];
mem[saveseg:ose+251]:=grstrg[i,201+1];  { Flares }
mem[saveseg:ose+252]:=grstrg[i,201+2];
move(grstrg[i,204],mem[saveseg:ose+200],50);inc(ose,255);

for a:=1 to maxpl do begin
move(plname[i,a,1],mem[saveseg:ose],16);inc(ose,16);
move(exp[i,a],mem[saveseg:ose],4);inc(ose,4);
move(skpoints[i,a],mem[saveseg:ose],4);inc(ose,4);
move(arminuse[i,a],mem[saveseg:ose],1);inc(ose,1);
move(tothps[i,a],mem[saveseg:ose],1);inc(ose,1);
move(basmp[i,a],mem[saveseg:ose],1);inc(ose,1);
move(react[i,a],mem[saveseg:ose],1);inc(ose,1);
move(firaccu[i,a],mem[saveseg:ose],1);inc(ose,1);
move(melaccu[i,a],mem[saveseg:ose],1);inc(ose,1);
move(throaccu[i,a],mem[saveseg:ose],1);inc(ose,1);
move(lochps[i,a,1],mem[saveseg:ose],6);inc(ose,6);
move(locaps[i,a,1],mem[saveseg:ose],6);inc(ose,6);
for n1:=1 to 15 do begin
n2:=invtype[i,a,n1];
if(n2>=201)and(n2<=203)then mem[saveseg:ose+n1-1]:=n2+50;
if(n2>=204)and(n2<=253)then mem[saveseg:ose+n1-1]:=n2-3;
if(n2<=200)then mem[saveseg:ose+n1-1]:=n2;
end;inc(ose,15);
{move(invtype[i,a,1],mem[saveseg:ose],15);inc(ose,15);}
end;end;
end;

procedure outfromsaveseg;
begin
ose:=0;
move(mem[saveseg:ose],grs,1);inc(ose,1);
for i:=1 to maxgr do begin
grname[i]:=cle;move(mem[saveseg:ose],grname[i,1],16);inc(ose,16);
move(mem[saveseg:ose],grmoney[i],4);inc(ose,4);
move(mem[saveseg:ose],grwins[i],2);inc(ose,2);
move(mem[saveseg:ose],grloses[i],2);inc(ose,2);
move(mem[saveseg:ose],grpls[i],1);inc(ose,1);
move(mem[saveseg:ose],grstrg[i,1],200);
grstrg[i,201+0]:=mem[saveseg:ose+250];
grstrg[i,201+1]:=mem[saveseg:ose+251];
grstrg[i,201+2]:=mem[saveseg:ose+252];
move(mem[saveseg:ose+200],grstrg[i,204],50);
inc(ose,255);

for a:=1 to maxpl do begin
plname[i,a]:=cle;move(mem[saveseg:ose],plname[i,a,1],16);inc(ose,16);
move(mem[saveseg:ose],exp[i,a],4);inc(ose,4);
move(mem[saveseg:ose],skpoints[i,a],4);inc(ose,4);
move(mem[saveseg:ose],arminuse[i,a],1);inc(ose,1);
move(mem[saveseg:ose],tothps[i,a],1);inc(ose,1);
move(mem[saveseg:ose],basmp[i,a],1);inc(ose,1);
move(mem[saveseg:ose],react[i,a],1);inc(ose,1);
move(mem[saveseg:ose],firaccu[i,a],1);inc(ose,1);
move(mem[saveseg:ose],melaccu[i,a],1);inc(ose,1);
move(mem[saveseg:ose],throaccu[i,a],1);inc(ose,1);
move(mem[saveseg:ose],lochps[i,a,1],6);inc(ose,6);
move(mem[saveseg:ose],locaps[i,a,1],6);inc(ose,6);
for n1:=1 to 15 do begin
n2:=mem[saveseg:ose+n1-1];
if(n2>=201)and(n2<=250)then invtype[i,a,n1]:=n2+3;
if(n2>=251)and(n2<=253)then invtype[i,a,n1]:=n2-50;
if(n2<=200)then invtype[i,a,n1]:=n2;
end;inc(ose,15);
{move(mem[saveseg:ose],invtype[i,a,1],15);inc(ose,15);}
end;end;
end;

procedure loadunits;
begin
if checkfile('data\groups.dat')=true then begin
clear(saveseg,7250);ose:=0;
assign(f,'data\groups.dat');reset(f,29000);blockread(f,mem[saveseg:0],1);close(f);
outfromsaveseg;for i:=1 to 6 do textxy(4,116+12*i,22,grname[i]);
clear(saveseg,7250);ose:=0;
end;end;

procedure saveunits;
begin
clear(saveseg,7250);ose:=0;intosaveseg(0);
assign(f,'data\groups.dat');rewrite(f,29000);blockwrite(f,mem[saveseg:0],1);close(f);
clear(saveseg,7250);ose:=0;
end;

begin   { Main Program }
asm mov ax,13h;int 10h;end;
getmem(ma,64000);ownseg:=seg(ma^);clear(ownseg,16000);
getmem(ma1,29000);saveseg:=seg(ma1^);clear(saveseg,7250);
getmem(ma,64000);picseg:=seg(ma^);clear(picseg,16000);
getmem(ma,6000);fontseg:=seg(ma^);

{for wo:=0 to 15 do setpal(picp[1+wo*4],picp[wo*4+2],picp[wo*4+3],picp[wo*4+4]);}
assign(f,'gamedata\pls.dat');reset(f,768);blockread(f,mem[fontseg:0],1);close(f);
for wo:=0 to 255 do
setpal(wo,mem[fontseg:wo*3],mem[fontseg:wo*3+1],mem[fontseg:wo*3+2]);

assign(f,'gfx\font.fnt');reset(f,6000);blockread(f,mem[fontseg:0],1);close(f);

loadpic('gfx\players.svf');
textxy(3,12,22,'Update unit');textxy(3,24,22,'Create unit');textxy(3,36,22,'Remove unit');
{textxy(3,48,22,'Load units');textxy(3,60,22,'Save units');}
textxy(140,36,22,'Credits      :');
textxy(140,48,22,'Warriors     :');
textxy(140,60,22,'Victories    :');
textxy(140,72,22,'Losses       :');
textxy(140,84,22,'Reputation   :');

grs:=1;line:=1;vline:=1;trline:=1;otline:=1;randomize;
loadweps;loaditems;loadunits;
repeat

point(2,10+(line-1)*12,92,22+(line-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,10+(line-1)*12,92,22+(line-1)*12,0);

asm mov ah,0;int 16h;mov ch1,al;mov ch2,ah;end;

if(ch2=#80)then begin inc(line);if line>3 then line:=1;end;
if(ch2=#72)then begin dec(line);if line<1 then line:=3;end;

if(ch2=#28)and(line=2)then if(grs<=maxgr)then begin { Create group }
textxy(106,110,22,'Name your unit');
wipe(ownseg,$a000,0,0,16000);
grname[grs]:=getstring(140,16,22,16,30,grname[grs],false);

{str(mem[seg(grname[grs]):ofs(grname[grs])+1],s);
textxy(106,110,22,s);
wipe(ownseg,$a000,0,0,16000);
wait(50);}

if mem[seg(grname[grs]):ofs(grname[grs])+1]=0 then goto exit1;

grmoney[grs]:=150000;grwins[grs]:=0;grloses[grs]:=0;grpls[grs]:=0;
str(grmoney[grs],s);textxy(244,36,22,s);str(grpls[grs],s);textxy(244,48,22,s);
str(grwins[grs],s);textxy(244,60,22,s);str(grloses[grs],s);textxy(244,72,22,s);textxy(244,84,22,checkrep(grs));

if grs<=6 then textxy(4,116+12*grs,22,grname[grs]);inc(grs);
textxy(140,16,0,cle);
for i:=244 to 318 do for a:=35 to 105 do mem[ownseg:a*320+i]:=0;
textxy(106,110,22,'              ');
wipe(ownseg,$a000,0,0,16000);

grnum:=grs-1;
goto update1;

exit1:
textxy(106,110,22,cle);

end else begin textxy(50,110,22,'You''ve already got 20 units');
wipe(ownseg,$a000,0,0,16000);ch2:=#0;
repeat asm mov ah,0;int 16h;mov ch2,ah;end;until ch2=#28;
textxy(50,110,22,'                            ');

wipe(ownseg,$a000,0,0,16000);ch2:=#0;

end;   { Create group }

if(ch2=#28)and(line=3)and(grs>1)then begin  { Delete group }
textxy(78,110,22,'Choose unit to remove');
repeat
for i:=244 to 318 do for a:=35 to 105 do mem[ownseg:a*320+i]:=0;textxy(140,16,0,cle);
str(grmoney[vline],s);textxy(244,36,22,s);str(grpls[vline],s);textxy(244,48,22,s);
str(grwins[vline],s);textxy(244,60,22,s);str(grloses[vline],s);textxy(244,72,22,s);
textxy(244,84,22,checkrep(vline));textxy(140,16,22,grname[vline]);
point(2,127+(trline-1)*12,134,138+(trline-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,127+(trline-1)*12,134,138+(trline-1)*12,0);

asm mov ah,0;int 16h;mov ch2,ah;end;
if(ch2=#80)and(vline<(grs-1))then begin inc(vline);if trline<6 then inc(trline) else
for i:=vline-5 to vline do textxy(4,128+12*(i-(vline-5)),22,grname[i]);end;
if(ch2=#72)and(vline>1)then begin dec(vline);if trline>1 then dec(trline) else
for i:=vline to vline+5 do textxy(4,128+12*(i-(vline)),22,grname[i]);end;

if(ch2=#28)then begin
textxy(70,110,22,'Are you sure ? (Y/N)    ');
wipe(ownseg,$a000,0,0,16000);
repeat asm mov ah,0;int 16h;mov ch2,ah;end;until(ch2=#1)or(ch2=#21)or(ch2=#49);
textxy(50,110,22,'                            ');
wipe(ownseg,$a000,0,0,16000);

if(ch2=#21)then begin clear(saveseg,7250);dec(grs);
ose:=0;intosaveseg(vline);ose:=0;outfromsaveseg;ch2:=#1;end;
if(ch2=#49)then ch2:=#1;
if(ch2=#1)then ch2:=#1;
end;

until(ch2=#1)or(ch2=#28);
if ch2=#1 then ch2:=#0;
for i:=1 to 6 do textxy(4,116+12*i,22,grname[i]);vline:=1;trline:=1;
for i:=244 to 318 do for a:=35 to 105 do mem[ownseg:a*320+i]:=0;
textxy(140,16,0,cle);textxy(58,110,22,'                          ');
wipe(ownseg,$a000,0,0,16000);
end;      { Delete group }


if(ch2=#28)and(line=1)and(grs>1)then begin { Update group }
textxy(78,110,22,'Choose unit to update');
repeat
for i:=244 to 318 do for a:=35 to 105 do mem[ownseg:a*320+i]:=0;textxy(140,16,0,cle);
str(grmoney[vline],s);textxy(244,36,22,s);str(grpls[vline],s);textxy(244,48,22,s);
str(grwins[vline],s);textxy(244,60,22,s);str(grloses[vline],s);textxy(244,72,22,s);
textxy(244,84,22,checkrep(vline));textxy(140,16,22,grname[vline]);
point(2,127+(trline-1)*12,134,138+(trline-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,127+(trline-1)*12,134,138+(trline-1)*12,0);
asm mov ah,0;int 16h;mov ch2,ah;end;
if(ch2=#80)and(vline<(grs-1))then begin inc(vline);if trline<6 then inc(trline) else
for i:=vline-5 to vline do textxy(4,128+12*(i-(vline-5)),22,grname[i]);end;
if(ch2=#72)and(vline>1)then begin dec(vline);if trline>1 then dec(trline) else
for i:=vline to vline+5 do textxy(4,128+12*(i-(vline)),22,grname[i]);end;

if(ch2=#28)then begin
grnum:=vline;
update1:
updategr;
repeat
str(grpls[grnum],s);textxy(244,36,22,s);
point(2,10+(line-1)*12,132,22+(line-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,10+(line-1)*12,132,22+(line-1)*12,0);
asm mov ah,0;int 16h;mov ch2,ah;end;

if(ch2=#80)then begin inc(line);if line>4 then line:=1;end;
if(ch2=#72)then begin dec(line);if line<1 then line:=4;end;

if(ch2=#28)and(line=1)and(grpls[grnum]>=1)then begin    { Update Warrior }
vline:=1;trline:=1;textxy(58,85,22,'Choose character to update');
wipe(ownseg,$a000,0,0,16000);
str(tothps[grnum,vline],s);textxy(285,116,22,s);str(basmp[grnum,vline],s);textxy(285,128,22,s);str(react[grnum,vline],s);
textxy(285,140,22,s);str(firaccu[grnum,vline],s);textxy(285,152,22,s);

str(throaccu[grnum,vline],s);textxy(285,164,22,s);
str(melaccu[grnum,vline],s);textxy(285,176,22,s);

textxy(142,102,22,plname[grnum,vline]);
textxy(198,188,22,rank(grnum,vline));
repeat
point(2,101+(trline-1)*12,132,111+(trline-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,101+(trline-1)*12,132,111+(trline-1)*12,0);
asm mov ah,0;int 16h;mov ch2,ah;end;
if(ch2=#80)and(vline<(grpls[grnum]))then begin inc(vline);if trline<8 then inc(trline) else
for i:=vline-7 to vline do textxy(3,102+12*(i-(vline-7)),22,plname[grnum,i]);end;
if(ch2=#72)and(vline>1)then begin dec(vline);if trline>1 then dec(trline) else
for i:=vline to vline+7 do textxy(3,102+12*(i-(vline)),22,plname[grnum,i]);end;
for i:=285 to 315 do for a:=115 to 185 do mem[ownseg:a*320+i]:=0;
str(tothps[grnum,vline],s);textxy(285,116,22,s);str(basmp[grnum,vline],s);textxy(285,128,22,s);str(react[grnum,vline],s);
textxy(285,140,22,s);str(firaccu[grnum,vline],s);
textxy(285,152,22,s);

str(throaccu[grnum,vline],s);textxy(285,164,22,s);
str(melaccu[grnum,vline],s);textxy(285,176,22,s);

textxy(142,102,22,plname[grnum,vline]);
textxy(198,188,22,rank(grnum,vline));

if(ch2=#28)then begin
gotoupdatescr;        { Go to update screen }
end;

until(ch2=#1)or(ch2=#28);
if ch2=#1 then ch2:=#0;
for i:=1 to 8 do textxy(3,90+12*i,22,plname[grnum,i]);vline:=1;trline:=1;
textxy(142,102,0,cle);for i:=280 to 315 do for a:=115 to 195 do mem[ownseg:a*320+i]:=0;textxy(198,188,22,'            ');
textxy(58,85,22,'                          ');
updategr;
end;  { update warrior }


if(ch2=#28)and(line=2)and(grmoney[grnum]>2999)then if(grpls[grnum]<maxpl)then begin { Create warrior }
inc(grpls[grnum]);
repeat
tothps[grnum,grpls[grnum]]:=40+random(30);str(tothps[grnum,grpls[grnum]],s);textxy(285,116,22,s);
basmp[grnum,grpls[grnum]]:=40+random(30);str(basmp[grnum,grpls[grnum]],s);textxy(285,128,22,s);
react[grnum,grpls[grnum]]:=40+random(30);str(react[grnum,grpls[grnum]],s);textxy(285,140,22,s);
firaccu[grnum,grpls[grnum]]:=40+random(30);str(firaccu[grnum,grpls[grnum]],s);textxy(285,152,22,s);


throaccu[grnum,grpls[grnum]]:=40+random(30);
str(throaccu[grnum,grpls[grnum]],s);textxy(285,164,22,s);

melaccu[grnum,grpls[grnum]]:=40+random(30);
str(melaccu[grnum,grpls[grnum]],s);textxy(285,176,22,s);

exp[grnum,grpls[grnum]]:=0;textxy(198,188,22,rank(grnum,grpls[grnum]));
skpoints[grnum,grpls[grnum]]:=0;arminuse[grnum,grpls[grnum]]:=0;for a:=1 to 15 do invtype[grnum,grpls[grnum],a]:=0;
for a:=1 to 6 do lochps[grnum,grpls[grnum],a]:=0;for a:=1 to 6 do locaps[grnum,grpls[grnum],a]:=0;
textxy(48,85,22,'Accept values ? (y/n)  -$3000');
dec(grmoney[grnum],3000);textxy(244,24,22,'         ');str(grmoney[grnum],s);textxy(244,24,22,s);
wipe(ownseg,$a000,0,0,16000);
repeat asm mov ah,0;int 16h;mov ch2,ah;end;until(ch2=#21)or(ch2=#49);
until(ch2=#21)or(grmoney[grnum]<3000);textxy(48,85,22,'    Name your character      ');
if(ch2=#21)then begin
wipe(ownseg,$a000,0,0,16000);
plname[grnum,grpls[grnum]]:=getstring(142,102,22,16,30,plname[grnum,grpls[grnum]],false);
lochps[grnum,grpls[grnum],1]:=round(tothps[grnum,grpls[grnum]]*0.08);
lochps[grnum,grpls[grnum],2]:=round(tothps[grnum,grpls[grnum]]*0.28);
for i:=3 to 6 do lochps[grnum,grpls[grnum],i]:=round(tothps[grnum,grpls[grnum]]*0.16);
if grpls[grnum]<=8 then textxy(3,90+12*(grpls[grnum]),22,plname[grnum,grpls[grnum]]);end
else begin tothps[grnum,grpls[grnum]]:=0;basmp[grnum,grpls[grnum]]:=0;react[grnum,grpls[grnum]]:=0;
firaccu[grnum,grpls[grnum]]:=0;melaccu[grnum,grpls[grnum]]:=0;throaccu[grnum,grpls[grnum]]:=0;dec(grpls[grnum]);end;ch2:=#0;
textxy(142,102,0,cle);for i:=280 to 315 do for a:=115 to 195 do mem[ownseg:a*320+i]:=0;
textxy(68,85,22,'                        ');textxy(198,188,22,'            ');
wipe(ownseg,$a000,0,0,16000);
end else begin
textxy(40,85,22,'You''ve already got 20 warriors');
wipe(ownseg,$a000,0,0,16000);ch2:=#0;
repeat asm mov ah,0;int 16h;mov ch2,ah;end;until ch2=#28;
textxy(40,85,22,'                               ');
wipe(ownseg,$a000,0,0,16000);
end;  { Create warrior }

if(ch2=#28)and(line=3)and(grpls[grnum]>=1)then begin  { Delete warrior }
vline:=1;trline:=1;textxy(58,85,22,'   Choose warrior to dismiss');
wipe(ownseg,$a000,0,0,16000);
str(tothps[grnum,vline],s);textxy(285,116,22,s);str(basmp[grnum,vline],s);textxy(285,128,22,s);str(react[grnum,vline],s);
textxy(285,140,22,s);str(firaccu[grnum,vline],s);textxy(285,152,22,s);str(melaccu[grnum,vline],s);textxy(285,164,22,s);
str(throaccu[grnum,vline],s);textxy(285,176,22,s);textxy(142,102,22,plname[grnum,vline]);
textxy(198,188,22,rank(grnum,vline));
repeat
point(2,101+(trline-1)*12,132,111+(trline-1)*12,4);
wipe(ownseg,$a000,0,0,16000);
point(2,101+(trline-1)*12,132,111+(trline-1)*12,0);
asm mov ah,0;int 16h;mov ch2,ah;end;

if(ch2=#80)and(vline<(grpls[grnum]))then begin inc(vline);if trline<8 then inc(trline) else

for i:=vline-7 to vline do textxy(3,102+12*(i-(vline-7)),22,plname[grnum,i]);end;
if(ch2=#72)and(vline>1)then begin dec(vline);if trline>1 then dec(trline) else

for i:=vline to vline+7 do textxy(3,102+12*(i-(vline)),22,plname[grnum,i]);end;
str(tothps[grnum,vline],s);textxy(285,116,22,s);str(basmp[grnum,vline],s);textxy(285,128,22,s);str(react[grnum,vline],s);
textxy(285,140,22,s);str(firaccu[grnum,vline],s);textxy(285,152,22,s);str(melaccu[grnum,vline],s);textxy(285,164,22,s);
str(throaccu[grnum,vline],s);textxy(285,176,22,s);textxy(142,102,22,plname[grnum,vline]);

if(ch2=#28)then begin for i:=vline to grpls[grnum] do begin
tothps[grnum,i]:=tothps[grnum,i+1];basmp[grnum,i]:=basmp[grnum,i+1];react[grnum,i]:=react[grnum,i+1];
firaccu[grnum,i]:=firaccu[grnum,i+1];melaccu[grnum,i]:=melaccu[grnum,i+1];throaccu[grnum,i]:=throaccu[grnum,i+1];
plname[grnum,i]:=cletri;plname[grnum,i]:=plname[grnum,i+1];exp[grnum,i]:=exp[grnum,i+1];
skpoints[grnum,i]:=skpoints[grnum,i+1];arminuse[grnum,i]:=arminuse[grnum,i+1];
for a:=1 to 15 do invtype[grnum,i,a]:=invtype[grnum,i+1,a];
for a:=1 to 6 do lochps[grnum,i,a]:=lochps[grnum,i+1,a];
for a:=1 to 6 do locaps[grnum,i,a]:=locaps[grnum,i+1,a];
end;

tothps[grnum,grpls[grnum]]:=0;basmp[grnum,grpls[grnum]]:=0;react[grnum,grpls[grnum]]:=0;firaccu[grnum,grpls[grnum]]:=0;
melaccu[grnum,grpls[grnum]]:=0;throaccu[grnum,grpls[grnum]]:=0;plname[grnum,grpls[grnum]]:=cletri;exp[grnum,grpls[grnum]]:=0;
for a:=1 to 15 do invtype[grnum,grpls[grnum],a]:=0;for a:=1 to 6 do lochps[grnum,grpls[grnum],a]:=0;
for a:=1 to 6 do locaps[grnum,grpls[grnum],a]:=0;dec(grpls[grnum]);

end;
until(ch2=#1)or(ch2=#28);
if ch2=#1 then ch2:=#0;
for i:=1 to 8 do textxy(3,90+12*i,22,plname[grnum,i]);vline:=1;trline:=1;
textxy(142,102,0,cle);for i:=280 to 315 do for a:=115 to 195 do mem[ownseg:a*320+i]:=0;textxy(198,188,22,'            ');
textxy(58,85,22,'                              ');
wipe(ownseg,$a000,0,0,16000);
end;  { Delete warrior }

if(ch2=#28)and(line=4)then begin { Storages }
line:=1;page:=1;otpage:=1;trline:=1;otline:=1;vline:=1;
loadpic('gfx\storages.svf');

textxy(25,3,22,'Weapons');textxy(139,3,22,'Clips');textxy(242,3,22,'Others');
textxy(8,16,22,'W / C');textxy(64,16,22,'Weapon name');textxy(209,16,22,'W / C Price');

textxy(70-50,188,22,'Credits :');
str(grmoney[grnum],s);
textxy(150-50,188,22,s);
textxy(190,188,22,'U = Undo (Menu only)');

undomoney:=grmoney[grnum];
for i:=1 to 255 do undostrg[i]:=grstrg[grnum,i];

updatepage;

repeat  { Storage }
if line=1 then point(23,2,82,13,4);if line=2 then point(137,2,180,13,4);if line=3 then point(240,2,291,13,4);
wipe(ownseg,$a000,0,0,16000);
if line=1 then point(23,2,82,13,0);if line=2 then point(137,2,180,13,0);if line=3 then point(240,2,291,13,0);
asm mov ah,0;int 16h;mov ch2,ah;end;
if(ch2=#77)then if line>=3 then line:=1 else inc(line);
if(ch2=#75)then if line<=1 then line:=3 else dec(line);
if(ch2=#$16)then begin undo;
textxy(70-50,188,22,'Credits :             ');
str(grmoney[grnum],s);textxy(150-50,188,22,s);
if(line<=2) then updatepage else upitempage;
end;

{ Need some money eh?? }
{ NO SHIT 'cause those challenging bastards keep nailing me all the time! }
{if(ch2=#57)and(grmoney[grnum]<9940000)then begin inc(grmoney[grnum],50000);
textxy(70,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150,188,22,s);
end;}

if(ch2=#28)and(line<=2)then begin { Weapons / Clips }
textxy(4,16,22,'       ');textxy(8,16,22,'W / C');textxy(64,16,22,'Weapon name');textxy(209,16,22,'W / C Price');
updatewe((page-1)*8+trline);updatepage;
repeat
point(62,18+trline*10,194,28+trline*10,4);
wipe(ownseg,$a000,0,0,16000);
point(62,18+trline*10,194,28+trline*10,0);
asm mov ah,0;int 16h;mov ch2,ah;end;

if(ch2=#80)and(trline+(page-1)*8<totweps)then begin if(trline>=8)and(page<1+trunc(totweps/8))then begin inc(page);
updatepage;trline:=1 end else inc(trline);updatewe((page-1)*8+trline);end;
if(ch2=#72)and(trline+(page-1)*8>1)then begin if(page>1)and(trline<=1)then begin dec(page);updatepage;trline:=8;end
else dec(trline);updatewe((page-1)*8+trline);end;

if(ch2=#81)and(page<1+trunc((totweps-1)/8))then begin inc(page);if trline+(page-1)*8>totweps then trline:=totweps-(page-1)*8;
updatepage;updatewe((page-1)*8+trline);end;
if(ch2=#73)and(page>1)then begin dec(page);updatepage;updatewe((page-1)*8+trline);end;

if(ch2=#75)and(grstrg[grnum,trline+(page-1)*8]>0)and(line=1)then
begin inc(grmoney[grnum],(wepprice[trline+(page-1)*8])div 3);
if(grmoney[grnum]>999999999)then grmoney[grnum]:=999999999;
dec(grstrg[grnum,trline+(page-1)*8]);updatepage;
textxy(70-50,188,22,'Credits :             ');
str(grmoney[grnum],s);textxy(150-50,188,22,s);
end;

if(ch2=#77)and(grstrg[grnum,trline+(page-1)*8]<99)and(grmoney[grnum]>=wepprice[trline+(page-1)*8])and(line=1)then
begin dec(grmoney[grnum],wepprice[trline+(page-1)*8]);
inc(grstrg[grnum,trline+(page-1)*8]);updatepage;
textxy(70-50,188,22,'Credits :             ');
str(grmoney[grnum],s);textxy(150-50,188,22,s);
end;

if(ch2=#75)and(grstrg[grnum,100+trline+(page-1)*8]>0)and(line=2)then
begin inc(grmoney[grnum],(clprice[trline+(page-1)*8])div 3);
if(grmoney[grnum]>999999999)then grmoney[grnum]:=999999999;
dec(grstrg[grnum,100+trline+(page-1)*8]);updatepage;
textxy(70-50,188,22,'Credits :             ');
str(grmoney[grnum],s);textxy(150-50,188,22,s);
end;

if(ch2=#77)and(grstrg[grnum,100+trline+(page-1)*8]<99)and(grmoney[grnum]>=clprice[trline+(page-1)*8])and(line=2)then
if weaptype[trline+(page-1)*8]<3 then
begin dec(grmoney[grnum],clprice[trline+(page-1)*8]);
inc(grstrg[grnum,100+trline+(page-1)*8]);updatepage;
textxy(70-50,188,22,'Credits :             ');
str(grmoney[grnum],s);textxy(150-50,188,22,s);
end;

until ch2=#1;
if ch2=#1 then ch2:=#0;updatepage;for i:=2 to 317 do for a:=111 to 184 do mem[ownseg:a*320+i]:=0;
end;                             { Weapons / Clips }

if(ch2=#28)and(line=3)then begin { Others }
textxy(4,16,22,'Amount');textxy(64,16,22,' Item name ');textxy(208,16,22,'    Price   ');
for i:=2 to 53 do for a:=27 to 109 do mem[ownseg:a*320+i]:=0;for i:=203 to 317 do for a:=27 to 109 do mem[ownseg:a*320+i]:=0;

updateitem(otline+(otpage-1)*8);upitempage;
repeat
point(62,18+otline*10,194,28+otline*10,4);
wipe(ownseg,$a000,0,0,16000);
point(62,18+otline*10,194,28+otline*10,0);

asm mov ah,0;int 16h;mov ch2,ah;end;

if(ch2=#80)and(otline+(otpage-1)*8<items)then begin if(otline>=8)and(otpage<1+trunc(items/8))then begin inc(otpage);
upitempage;otline:=1 end else inc(otline);updateitem((otpage-1)*8+otline);end;
if(ch2=#72)and(otline+(otpage-1)*8>1)then begin if(otpage>1)and(otline<=1)then begin dec(otpage);upitempage;otline:=8;end
else dec(otline);updateitem((otpage-1)*8+otline);end;

if(ch2=#81)and(otpage<1+trunc((items-1)/8))then begin inc(otpage);if otline+(otpage-1)*8>items then otline:=items-(otpage-1)*8;
upitempage;updateitem((otpage-1)*8+otline);end;
if(ch2=#73)and(otpage>1)then begin dec(otpage);upitempage;updateitem((otpage-1)*8+otline);end;

if(ch2=#75)and(grstrg[grnum,200+otline+(otpage-1)*8]>0)then
begin inc(grmoney[grnum],(itemprice[otline+(otpage-1)*8])div 3);
if(grmoney[grnum]>999999999)then grmoney[grnum]:=999999999;
dec(grstrg[grnum,200+otline+(otpage-1)*8]);upitempage;
textxy(70-50,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150-50,188,22,s);
end;
if(ch2=#77)and(grstrg[grnum,200+otline+(otpage-1)*8]<99)and(grmoney[grnum]>=itemprice[otline+(otpage-1)*8])then
begin dec(grmoney[grnum],itemprice[otline+(otpage-1)*8]);
inc(grstrg[grnum,200+otline+(otpage-1)*8]);upitempage;
textxy(70-50,188,22,'Credits :             ');str(grmoney[grnum],s);textxy(150-50,188,22,s);
end;

until ch2=#1;
if ch2=#1 then ch2:=#0;upitempage;for i:=2 to 317 do for a:=111 to 184 do mem[ownseg:a*320+i]:=0;
end;                             { Others }


until ch2=#1;
if ch2=#1 then ch2:=#0;updategr;
end;                             { Storages }


until(ch2=#1);                   { Update unit }
loadpic('gfx\players.svf');
textxy(3,12,22,'Update unit');textxy(3,24,22,'Create unit');textxy(3,36,22,'Remove unit');
{textxy(3,48,22,'Load units');textxy(3,60,22,'Save units');}
textxy(140,36,22,'Credits    :');textxy(140,48,22,'Warriors   :');textxy(140,60,22,'Victories  :');
textxy(140,72,22,'Losses     :');textxy(140,84,22,'Reputation :');
wipe(ownseg,$a000,0,0,16000);
end;

until(ch2=#1)or(ch2=#28);        { Update unit }
if ch2=#1 then ch2:=#0;
for i:=1 to 6 do textxy(4,116+12*i,22,grname[i]);vline:=1;trline:=1;grnum:=1;line:=1;
for i:=244 to 318 do for a:=35 to 105 do mem[ownseg:a*320+i]:=0;
textxy(140,16,0,cle);textxy(58,110,22,'                          ');
wipe(ownseg,$a000,0,0,16000);
end;

if(ch2=#28)and(line=4)then begin   { Load Units }
loadunits;
end;                               { Load Units }

if(ch2=#28)and(line=5)then begin   { Save Units }
saveunits;
end;                               { Save Units }

if(ch2=#1) then begin
textxy(50,110,22,'    Save before quitting ? (Y/N)    ');
wipe(ownseg,$a000,0,0,16000);
repeat asm mov ah,0;int 16h;mov ch2,ah;end;until(ch2=#21)or(ch2=#49)or(ch2=#1);
textxy(50,110,22,'                                            ');
wipe(ownseg,$a000,0,0,16000);

if(ch2=#21) then begin saveunits;
ch2:=#100;end;

if(ch2=#49) then ch2:=#100;
end;

until(ch2=#100);{ Main program }
asm mov ax,3h;int 10h;end;
end.

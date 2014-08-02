{$R-,Q-,S-,D-}
Unit UTILS;
Interface
Uses Windos, Crt;
Var key:word;
Procedure Setvideo(vmode:byte);
Procedure GoTweak(super:byte);
Procedure Setplanes(mask:byte);
Procedure SetOffset(offs:word);
Procedure Dpixel(xco,yco:word;col:byte;address:word);
Procedure Dtweakpixel(xco,yco:word;col:byte;address:word);
Procedure Dtweakshadep(xco,yco:word;col:byte;address:word);

Procedure Clearb(address,amount:word);
Procedure Copyb(address1,address2,offset1,offset2,amount:word);
Procedure Waittrace;
Procedure Setpal(n,r,g,b:byte);
Procedure Wait(amount:longint);
Procedure Dline(x1,y1,x2,y2:word;col:byte;address:word);
Procedure THline (X1,X2,Y:Word;Color:Byte;segi:word);
Procedure TVline(y1,y2,x:Word;Color:Byte;segi:word);
Procedure DTweakLine (X1,Y1,X2,Y2:Word;Color:Byte;segi:word);
Procedure DTShadeLine (X1,Y1,X2,Y2:Word;Color:Byte;segi:word);

Procedure XTetraGourad(X1,Y1,C1,X2,Y2,C2,X3,Y3,C3 : Integer; VideoSeg:Word);
Procedure XQuadra(X1,Y1,X2,Y2,X3,Y3,X4,Y4 :Integer;Color:Byte;VideoSeg:Word);
Procedure XTetraTexture320(X1,Y1,X2,Y2,X3,Y3,TX1,TY1,TX2,TY2,TX3,TY3 : Integer;
	Texture : PChar; VideoSeg : Word);
Function LoadPCX(FileName : String; Var Width,Height : Word; Var RGB; VideoSeg : Word) : Integer;
{ Returns:
	0 = Success
	1 = Unable to find/open file
	2 = Unable to read header from file
	3 = Invalid format (color/size/format/... (image too large))
	4 = Unable to read image
	5 = Not enough memory for buffers
	6 = Unable to read palette (image should be ok though)
}
Procedure Blit(address1,address2,x1,y1,x2,y2,widht,height:word);
Procedure Blit2(address1,address2,x1,y1,x2,y2,widht,height:word);
Function readkey:char;
Function blittest1(address1,address2,x1,y1,x2,y2,widht,height:word;vari1,vari2:byte):word;
Function blittest2(address1,address2,x1,y1,x2,y2,widht,height:word;vari1,vari2:byte):word;
Function Initkeys:pointer;
Procedure Freekeys(ad:pointer);
Procedure KeyHandler; interrupt;
Procedure blitclr(address1,address2,x1,y1,x2,y2,widht,height:word;color:byte);

Implementation
const scaler=16;

Procedure Setvideo(vmode:byte);
Assembler;
Asm
xor ax,ax
mov al,vmode
int 10h
End;

function readkey:char;
var c:char;
begin
asm
mov ah,0
int 16h
mov c,al
end;
readkey:=c;
end;


Function Initkeys:pointer;
var temp:pointer;
begin
GetIntVec($9,temp);
SetIntVec($9,Addr(KeyHandler));
Initkeys:=temp;
end;

Procedure Freekeys(ad:pointer);
begin
   SetIntVec($9,ad);
end;

Procedure Dpixel(xco,yco:word;col:byte;address:word);
Assembler;
Asm
mov bx,yco
mov di,bx
shl bx,8
shl di,6
add di,bx
add di,xco
mov es,address
mov al,col
mov [es:di],al
End;

Procedure Clearb(address,amount:word);
Assembler;
Asm
DB $66
xor		ax,ax
mov		cx,amount
shr             cx,2
mov		es,[address]
xor		di,di
cld
DB $66
rep		stosw

End;

Procedure Copyb(address1,address2,offset1,offset2,amount:word);
Assembler;
Asm
push ds
mov ax,address2 {where to}
mov es,ax
mov ds,address1 {from    }
mov di,offset2
mov si,offset1
mov cx,amount
shr cx,2
DB $66
rep movsw
pop ds
End;

Procedure Waittrace;
Assembler;
Asm
mov dx,3dah
@vert1:
in al,dx
test al,8
jz @vert1
@vert2:
in al,dx
test al,8
jnz @vert2
End;

Procedure Setpal(n,r,g,b:byte);
Assembler;
Asm
cli
mov dx,$3c8
mov al,n
cli
out dx,al
sti
inc dx
mov al,r
out dx,al
sti
mov al,g
cli
out dx,al
sti
mov al,b
cli
out dx,al
sti
End;

Procedure Wait(amount:longint);
var temp:longint;
begin
for temp:=1 to amount do Waittrace;
End;

Procedure Dline(x1,y1,x2,y2:word;col:byte;address:word);
Assembler;
label l1,l2,l3,l4,l5,l6,l7,l8;
var ddx,ddy,sx,sy:word;
Asm

    mov  ax,[y1]
    mov  es,address
    mov  bx,ax
    mov  di,[x1]
    shl  ax,8
    shl  bx,6
    mov  dl,[col]
    add  ax,bx
    add  di,ax

    clc
    mov  ax,[x2]
    mov  bx,1
    sub  ax,[x1]
    jnc  l1
    neg  ax
    mov  bx,-1
l1: mov  [ddx],ax
    mov  [sx],bx
    mov  ax,[y2]
    clc
    mov  bx,320
    sub  ax,[y1]
    jnc  l2
    neg  ax
    mov  bx,-320
l2: mov  [ddy],ax
    mov  [sy],bx
    cmp  ax,[ddx]
    ja   l5
    mov  cx,[ddx]
    mov  bx,[ddx]
    inc  cl
    shr  bx,1
    mov  al,dl
l3: mov  byte ptr [es:di],al
    clc
    add  di,[sx]
    sub  bx,[ddy]
    jnc  l4
    add  di,[sy]
    add  bx,[ddx]
l4: dec  cl
    jnz  l3
    jmp  l8
l5: mov  cx,[ddy]
    inc  cl
    mov  bx,[ddy]
    shr  bx,1
    mov  al,dl
l6: mov  byte ptr [es:di],al
    clc
    add  di,[sy]
    sub  bx,[ddx]
    jnc  l7
    add  di,[sx]
    add  bx,[ddy]
l7:
    dec  cl
    jnz  l6
l8:
End;

Procedure XTetraGourad(X1,Y1,C1,X2,Y2,C2,X3,Y3,C3 : Integer; VideoSeg : Word); Assembler;
Var
	X,Y			: Integer;
	XX1,XX2,XX3	: LongInt;
	CC1,CC2,CC3	: LongInt;
	DX1,DX2,DX3	: LongInt;
	DC1,DC2,DC3	: LongInt;
	MX1,MX2		: LongInt;
	MC1,MC2		: LongInt;
	PC1,PC2		: LongInt;
	CX1,CX2		: LongInt;
	DCC1		: LongInt;
Asm
			CLD
			MOV		AX,[X1]
			MOV		BX,[Y1]
			MOV		CX,[C1]
			MOV		DX,[X2]
			MOV		SI,[Y2]
			MOV		DI,[C2]

			CMP		BX,SI
			JLE		@@OK1
			XCHG	AX,DX
			XCHG	BX,SI
			XCHG	CX,DI
@@OK1:
			CMP		BX,[Y3]
			JLE		@@OK2
			XCHG	AX,[X3]
			XCHG	BX,[Y3]
			XCHG	CX,[C3]
@@OK2:
			CMP		SI,[Y3]
			JLE		@@OK3
			XCHG	DX,[X3]
			XCHG	SI,[Y3]
			XCHG	DI,[C3]
@@OK3:
			MOV		[X1],AX
			MOV		[Y1],BX
			MOV		[C1],CX
			MOV		[X2],DX
			MOV		[Y2],SI
			MOV		[C2],DI

	DB $66;	DB $0F, $BF, $46, OFFSET X1
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX1],AX
	DB $66;	DB $0F, $BF, $46, OFFSET X2
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX2],AX
	DB $66;	DB $0F, $BF, $46, OFFSET X3
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX3],AX

	DB $66;	DB $0F, $BF, $46, OFFSET C1
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR CC1],AX
	DB $66;	DB $0F, $BF, $46, OFFSET C2
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR CC2],AX
	DB $66;	DB $0F, $BF, $46, OFFSET C3
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR CC3],AX

			MOV		AX,[Y1]
			CMP		AX,[Y2]
			JNE		@@NONFLAT1
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX1],AX
	DB $66;	MOV		[WORD PTR DC1],AX
			JMP		@@OK6
@@NONFLAT1:
	DB $66;	DB $0F, $BF, $5E, OFFSET Y2
	DB $66;	DB $0F, $BF, $4E, OFFSET Y1
	DB $66;	SUB		BX,CX

	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	SUB		AX,[WORD PTR XX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DX1],AX

	DB $66;	MOV		AX,[WORD PTR CC2]
	DB $66;	SUB		AX,[WORD PTR CC1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DC1],AX
@@OK6:

			MOV		AX,[Y2]
			CMP		AX,[Y3]
			JNE		@@NONFLAT2
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX2],AX
	DB $66;	MOV		[WORD PTR DC2],AX
			JMP		@@OK9
@@NONFLAT2:
	DB $66;	DB $0F, $BF, $5E, OFFSET Y3
	DB $66;	DB $0F, $BF, $4E, OFFSET Y2
	DB $66;	SUB		BX,CX

	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	SUB		AX,[WORD PTR XX2]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DX2],AX

	DB $66;	MOV		AX,[WORD PTR CC3]
	DB $66;	SUB		AX,[WORD PTR CC2]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DC2],AX
@@OK9:

			MOV		AX,[Y1]
			CMP		AX,[Y3]
			JNE		@@NONFLAT3
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX3],AX
	DB $66;	MOV		[WORD PTR DC3],AX
			JMP		@@OK12
@@NONFLAT3:
	DB $66;	DB $0F, $BF, $5E, OFFSET Y3
	DB $66;	DB $0F, $BF, $4E, OFFSET Y1
	DB $66;	SUB		BX,CX

	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	SUB		AX,[WORD PTR XX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DX3],AX

	DB $66;	MOV		AX,[WORD PTR CC3]
	DB $66;	SUB		AX,[WORD PTR CC1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DC3],AX
@@OK12:

	DB $66;	MOV		AX,[WORD PTR XX1]
	DB $66;	MOV		[WORD PTR CX1],AX
	DB $66;	MOV		AX,[WORD PTR CC1]
	DB $66;	MOV		[WORD PTR PC1],AX

			MOV		AX,[Y1]
			CMP		AX,[Y2]
			JNE		@@NONFLAT4
	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	MOV		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR CC2]
	DB $66;	MOV		[WORD PTR PC2],AX
			JMP		@@OK13
@@NONFLAT4:
	DB $66;	MOV		AX,[WORD PTR XX1]
	DB $66;	MOV		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR CC1]
	DB $66;	MOV		[WORD PTR PC2],AX
@@OK13:

			MOV		AX,[Y1]
			MOV		[Y],AX

			MOV		ES,[VideoSeg]
			CMP		AX,0
			JGE		@@OK13_2
			XOR		AX,AX
@@OK13_2:
			MOV		DI,AX
			SHL		AX,8
			SHL		DI,6
			ADD		DI,AX
@@LINELOOP:
			MOV		AX,[Y]
			TEST	AX,AX
			JL		@@NEXTLINE
			CMP		AX,199
			JG		@@EXIT
			CMP		AX,[Y3]
			JG		@@EXIT
	DB $66;	MOV		AX,[WORD PTR CX1]
	DB $66;	CMP		AX,[WORD PTR CX2]
			JLE		@@OK14
	DB $66;	MOV		[WORD PTR MX2],AX
	DB $66;	MOV		AX,[WORD PTR CX2]
	DB $66;	MOV		[WORD PTR MX1],AX
	DB $66;	MOV		AX,[WORD PTR PC1]
	DB $66;	MOV		[WORD PTR MC2],AX
	DB $66;	MOV		AX,[WORD PTR PC2]
	DB $66;	MOV		[WORD PTR MC1],AX
			JMP		@@OK15
@@OK14:
	DB $66;	MOV		[WORD PTR MX1],AX
	DB $66;	MOV		AX,[WORD PTR CX2]
	DB $66;	MOV		[WORD PTR MX2],AX
	DB $66;	MOV		AX,[WORD PTR PC1]
	DB $66;	MOV		[WORD PTR MC1],AX
	DB $66;	MOV		AX,[WORD PTR PC2]
	DB $66;	MOV		[WORD PTR MC2],AX
@@OK15:

	DB $66;	XOR		CX,CX
	DB $66;	SAR		[WORD PTR MX1],Scaler
	DB $66;	ADC		[WORD PTR MX1],CX
	DB $66;	SAR		[WORD PTR MX2],Scaler
	DB $66;	ADC		[WORD PTR MX2],CX

	DB $66;	MOV		AX,[WORD PTR MX1]
	DB $66;	CMP		AX,[WORD PTR MX2]
			JNE		@@NONFLAT5
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DCC1],AX
			JMP		@@OK17
@@NONFLAT5:
	DB $66;	MOV		AX,[WORD PTR MC2]
	DB $66;	SUB		AX,[WORD PTR MC1]
	DB $66;	MOV		BX,[WORD PTR MX2]
	DB $66;	SUB		BX,[WORD PTR MX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DCC1],AX
@@OK17:
			MOV		SI,DI
			MOV		AX,[WORD PTR MX1]
			CMP		AX,0
			JL		@@LOOP1
			ADD		DI,AX
@@LOOP1:
			MOV		AX,[WORD PTR MX1]
			CMP		AX,0
			JL		@@NEXTPIXEL
			CMP		AX,319
			JG		@@ENDOFLINE
			CMP		AX,[WORD PTR MX2]
			JG		@@ENDOFLINE

	DB $66;	MOV		AX,[WORD PTR MC1]
	DB $66;	XOR		BX,BX
	DB $66;	SAR     AX,Scaler
	DB $66;	ADC		AX,BX

			MOV		[ES:DI],AL
			INC		DI
@@NEXTPIXEL:
			INC		[WORD PTR MX1]
	DB $66;	MOV		AX,[WORD PTR DCC1]
	DB $66;	ADD		[WORD PTR MC1],AX
			JMP		@@LOOP1
@@ENDOFLINE:
			MOV		DI,SI
			ADD		DI,320
@@NEXTLINE:

	DB $66;	MOV		AX,[WORD PTR DX3]
	DB $66;	ADD		[WORD PTR CX1],AX
	DB $66;	MOV		AX,[WORD PTR DC3]
	DB $66;	ADD		[WORD PTR PC1],AX

			MOV		AX,[Y]
			CMP		AX,[Y2]
			JL		@@TOPPART
	DB $66;	MOV		AX,[WORD PTR DX2]
	DB $66;	ADD		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR DC2]
	DB $66;	ADD		[WORD PTR PC2],AX
			JMP		@@OK18
@@TOPPART:
	DB $66;	MOV		AX,[WORD PTR DX1]
	DB $66;	ADD		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR DC1]
	DB $66;	ADD		[WORD PTR PC2],AX
@@OK18:
			INC		[Y]
			JMP		@@LINELOOP
@@EXIT:
End;

Procedure XQuadra(X1,Y1,X2,Y2,X3,Y3,X4,Y4 :Integer;Color:Byte;VideoSeg:Word); Assembler;
Var
	XX1,XX2		: LongInt;
	XX3,XX4		: LongInt;
	DX1,DX2		: LongInt;
	DX3,DX4		: LongInt;
	CX1,CX2		: LongInt;		{ Moves from 1 to 2, 2 to 3 }
	CX3,CX4		: LongInt;		{ Moves from 3 to 4, 1 to 4 }
	Min1,Min2	: Integer;
	Min3,Min4	: Integer;
	Max1,Max2	: Integer;
	Max3,Max4	: Integer;
	Y,YMin,YMax	: Integer;
	CDWord		: LongInt;
Asm
			CLD
			MOV		BL,[Color]
			MOV		BH,BL
			MOV		AX,BX
	DB $66;	SHL		AX,16
			MOV		AX,BX
	DB $66;	MOV		[WORD PTR CDWord],AX

			MOV		AX,[Y1]		{ AX = YMin }
			MOV		BX,AX		{ BX = YMax }
			CMP		AX,[Y2]
			JLE		@@OK1
			MOV		AX,[Y2]
@@OK1:
			CMP		AX,[Y3]
			JLE		@@OK2
			MOV		AX,[Y3]
@@OK2:
			CMP		AX,[Y4]
			JLE		@@OK3
			MOV		AX,[Y4]
@@OK3:
			CMP		BX,[Y2]
			JGE		@@OK4
			MOV		BX,[Y2]
@@OK4:
			CMP		BX,[Y3]
			JGE		@@OK5
			MOV		BX,[Y3]
@@OK5:
			CMP		BX,[Y4]
			JGE		@@OK6
			MOV		BX,[Y4]
@@OK6:
			MOV		[YMin],AX
			MOV		[YMax],BX

			DB $66, $0F, $BF, $46, OFFSET X1	{ MOVSX EAX,[X1] }
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX1],AX
			DB $66, $0F, $BF, $46, OFFSET X2	{ MOVSX EAX,[X2] }
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX2],AX
			DB $66, $0F, $BF, $46, OFFSET X3	{ MOVSX EAX,[X3] }
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX3],AX
			DB $66, $0F, $BF, $46, OFFSET X4	{ MOVSX EAX,[X4] }
	DB $66;	SAL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX4],AX

			MOV		AX,[Y1]
			CMP		AX,[Y2]
			JE		@@EQ1
	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	SUB		AX,[WORD PTR XX1]
	DB $66;	CWD
			MOV     BX,[Y2]
			SUB		BX,[Y1]
			DB $66, $0F, $BF, $CB				{ MOVSX ECX,BX }
	DB $66;	IDIV	CX
	DB $66;	MOV		[WORD PTR DX1],AX
			JMP		@@LINEISOK_1
@@EQ1:
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX1],AX
@@LINEISOK_1:

			MOV		AX,[Y2]
			CMP		AX,[Y3]
			JE		@@EQ2
	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	SUB		AX,[WORD PTR XX2]
	DB $66;	CWD
			MOV     BX,[Y3]
			SUB		BX,[Y2]
			DB $66, $0F, $BF, $CB				{ MOVSX ECX,BX }
	DB $66;	IDIV	CX
	DB $66;	MOV		[WORD PTR DX2],AX
			JMP		@@LINEISOK_2
@@EQ2:
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX2],AX
@@LINEISOK_2:

			MOV		AX,[Y3]
			CMP		AX,[Y4]
			JE		@@EQ3
	DB $66;	MOV		AX,[WORD PTR XX4]
	DB $66;	SUB		AX,[WORD PTR XX3]
	DB $66;	CWD
			MOV     BX,[Y4]
			SUB		BX,[Y3]
			DB $66, $0F, $BF, $CB				{ MOVSX ECX,BX }
	DB $66;	IDIV	CX
	DB $66;	MOV		[WORD PTR DX3],AX
			JMP		@@LINEISOK_3
@@EQ3:
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX3],AX
@@LINEISOK_3:

			MOV		AX,[Y1]
			CMP		AX,[Y4]
			JE		@@EQ4
	DB $66;	MOV		AX,[WORD PTR XX4]
	DB $66;	SUB		AX,[WORD PTR XX1]
	DB $66;	CWD
			MOV     BX,[Y4]
			SUB		BX,[Y1]
			DB $66, $0F, $BF, $CB				{ MOVSX ECX,BX }
	DB $66;	IDIV	CX
	DB $66;	MOV		[WORD PTR DX4],AX
			JMP		@@LINEISOK_4
@@EQ4:
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX4],AX
@@LINEISOK_4:

			MOV		BX,[Y1]
			CMP		BX,[Y2]
			JLE		@@DIR12
	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	MOV		[WORD PTR CX1],AX
			JMP		@@CHECKDIR2
@@DIR12:
	DB $66;	MOV		AX,[WORD PTR XX1]
	DB $66;	MOV		[WORD PTR CX1],AX

@@CHECKDIR2:
			MOV		BX,[Y2]
			CMP		BX,[Y3]
			JLE		@@DIR23
	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	MOV		[WORD PTR CX2],AX
			JMP		@@CHECKDIR3
@@DIR23:
	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	MOV		[WORD PTR CX2],AX

@@CHECKDIR3:
			MOV		BX,[Y3]
			CMP		BX,[Y4]
			JLE		@@DIR34
	DB $66;	MOV		AX,[WORD PTR XX4]
	DB $66;	MOV		[WORD PTR CX3],AX
			JMP		@@CHECKDIR4
@@DIR34:
	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	MOV		[WORD PTR CX3],AX

@@CHECKDIR4:
			MOV		BX,[Y1]
			CMP		BX,[Y4]
			JLE		@@DIR14
	DB $66;	MOV		AX,[WORD PTR XX4]
	DB $66;	MOV		[WORD PTR CX4],AX
			JMP		@@NODIRSLEFT
@@DIR14:
	DB $66;	MOV		AX,[WORD PTR XX1]
	DB $66;	MOV		[WORD PTR CX4],AX
@@NODIRSLEFT:
			MOV		AX,[Y1]
			MOV		BX,[Y2]
			CMP		AX,BX
			JLE		@@USELINE1
			XCHG	AX,BX
@@USELINE1:
			MOV		[Min1],AX
			MOV		[Max1],BX

			MOV		AX,[Y2]
			MOV		BX,[Y3]
			CMP		AX,BX
			JLE		@@USELINE2
			XCHG	AX,BX
@@USELINE2:
			MOV		[Min2],AX
			MOV		[Max2],BX

			MOV		AX,[Y3]
			MOV		BX,[Y4]
			CMP		AX,BX
			JLE		@@USELINE3
			XCHG	AX,BX
@@USELINE3:
			MOV		[Min3],AX
			MOV		[Max3],BX

			MOV		AX,[Y1]
			MOV		BX,[Y4]
			CMP		AX,BX
			JLE		@@USELINE4
			XCHG	AX,BX
@@USELINE4:
			MOV		[Min4],AX
			MOV		[Max4],BX

			MOV		AX,[YMin]
			MOV		[Y],AX
			TEST	AX,AX
			JGE		@@MOVEIT
			SUB		AX,AX
@@MOVEIT:
			MOV		DI,AX
			SHL		DI,6
			SHL		AX,8
			ADD		DI,AX
			MOV		ES,[VideoSeg]

@@LINELOOP:
			MOV		AX,[Y]
			CMP		AX,[YMax]
			JG		@@EXIT
			TEST	AX,AX
			JL		@@NEXTLINE
			CMP		AX,199
			JG		@@EXIT

	DB $66;	MOV		AX,$FFFF; DW $7FFF	{ MAX }
	DB $66;	MOV		BX,$0000; DW $8000	{ MIN }
			MOV		CX,[Y]

			CMP		CX,[Min1]
			JL		@@CHECK2
			CMP		CX,[Max1]
			JG		@@CHECK2
	DB $66;	CMP		AX,[WORD PTR CX1]
			JLE		@@CHECK1_2
	DB $66;	MOV		AX,[WORD PTR CX1]
@@CHECK1_2:
	DB $66;	CMP		BX,[WORD PTR CX1]
			JGE		@@CHECK2
	DB $66;	MOV		BX,[WORD PTR CX1]

@@CHECK2:
			CMP		CX,[Min2]
			JL		@@CHECK3
			CMP		CX,[Max2]
			JG		@@CHECK3
	DB $66;	CMP		AX,[WORD PTR CX2]
			JLE		@@CHECK2_2
	DB $66;	MOV		AX,[WORD PTR CX2]
@@CHECK2_2:
	DB $66;	CMP		BX,[WORD PTR CX2]
			JGE		@@CHECK3
	DB $66;	MOV		BX,[WORD PTR CX2]

@@CHECK3:
			CMP		CX,[Min3]
			JL		@@CHECK4
			CMP		CX,[Max3]
			JG		@@CHECK4
	DB $66;	CMP		AX,[WORD PTR CX3]
			JLE		@@CHECK3_2
	DB $66;	MOV		AX,[WORD PTR CX3]
@@CHECK3_2:
	DB $66;	CMP		BX,[WORD PTR CX3]
			JGE		@@CHECK4
	DB $66;	MOV		BX,[WORD PTR CX3]

@@CHECK4:
			CMP		CX,[Min4]
			JL		@@CHECK5
			CMP		CX,[Max4]
			JG		@@CHECK5
	DB $66;	CMP		AX,[WORD PTR CX4]
			JLE		@@CHECK4_2
	DB $66;	MOV		AX,[WORD PTR CX4]
@@CHECK4_2:
	DB $66;	CMP		BX,[WORD PTR CX4]
			JGE		@@CHECK5
	DB $66;	MOV		BX,[WORD PTR CX4]
@@CHECK5:

{	DB $66;	XOR		CX,CX}
	DB $66;	SAR		AX,Scaler
{	DB $66;	ADC		AX,CX}
	DB $66;	SAR		BX,Scaler
{	DB $66;	ADC		BX,CX}

			CMP		AX,319
			JG		@@NEXTLINE
			TEST	BX,BX
			JL		@@NEXTLINE

			CMP		BX,319
			JLE		@@MAXISOK
			MOV		BX,319
@@MAXISOK:
			TEST	AX,AX
			JGE		@@MINISOK
			SUB		AX,AX
@@MINISOK:
			MOV		SI,DI

			MOV		CX,BX
			SUB		CX,AX
			INC		CX
			ADD		DI,AX

	DB $66;	MOV		AX,[WORD PTR CDWord]
			JCXZ	@@SKIP2
			TEST	DI,$0001
			JZ		@@NOTONE
			MOV		[ES:DI],AL
			INC		DI
			DEC		CX
			JZ		@@SKIP2
@@NOTONE:
			CMP		CX,2
			JB		@@NOTTWO
			TEST	DI,$0002
			JZ		@@NOTTWO
			MOV		[ES:DI],AX
			ADD		DI,2
			SUB		CX,2
			JZ		@@SKIP2
@@NOTTWO:
			SHR		CX,1
			DB $0F, $92, $C3			{ SETC BL }
			SHR		CX,1
	DB $66;	REP		STOSW
			JNC		@@SKIP1
			MOV		[ES:DI],AX
			ADD		DI,2
@@SKIP1:
			OR		BL,BL
			JZ		@@SKIP2
			MOV		[ES:DI],AL
			INC		DI
@@SKIP2:
			MOV		DI,SI
@@NEXTLINE:
			MOV		AX,[Y]
			CMP		AX,[Min1]
			JL		@@ADJ2
			CMP		AX,[Max1]
			JG		@@ADJ2
	DB $66;	MOV		BX,[WORD PTR DX1]
	DB $66;	ADD		[WORD PTR CX1],BX
@@ADJ2:
			CMP		AX,[Min2]
			JL		@@ADJ3
			CMP		AX,[Max2]
			JG		@@ADJ3
	DB $66;	MOV		BX,[WORD PTR DX2]
	DB $66;	ADD		[WORD PTR CX2],BX
@@ADJ3:
			CMP		AX,[Min3]
			JL		@@ADJ4
			CMP		AX,[Max3]
			JG		@@ADJ4
	DB $66;	MOV		BX,[WORD PTR DX3]
	DB $66;	ADD		[WORD PTR CX3],BX
@@ADJ4:
			CMP		AX,[Min4]
			JL		@@ADJ5
			CMP		AX,[Max4]
			JG		@@ADJ5
	DB $66;	MOV		BX,[WORD PTR DX4]
	DB $66;	ADD		[WORD PTR CX4],BX
@@ADJ5:
			MOV		AX,[Y]
			CMP		AX,0
			JL		@@ONLY_Y
			ADD		DI,320
@@ONLY_Y:
			INC		[Y]
			JMP		@@LINELOOP
@@EXIT:
End;

Procedure XTetraTexture320(X1,Y1,X2,Y2,X3,Y3,TX1,TY1,TX2,TY2,TX3,TY3 : Integer;
	Texture : PChar; VideoSeg : Word); Assembler;
Var

        X,Y			: Integer;
	XX1,XX2,XX3		: LongInt;
	DX1,DX2,DX3		: LongInt;
	TXX1,TXX2,TXX3	: LongInt;
	TYY1,TYY2,TYY3	: LongInt;
	TDX1,TDX2,TDX3	: LongInt;
	TDY1,TDY2,TDY3	: LongInt;
	CX1,CX2			: LongInt;
	MX1,MX2			: LongInt;
	TCX1,TCY1		: LongInt;
	TCX2,TCY2		: LongInt;
	MTX1,MTY1		: LongInt;
	MTX2,MTY2		: LongInt;
	MDX1,MDY1		: LongInt;
	TEMPDI          : Word;
	TEMPDS          : Word;
Asm
			CLD
			MOV     [TEMPDS],DS
			LDS		SI,[DWORD PTR Texture]
			MOV		ES,[VideoSeg]

			MOV		AX,[Y1]
			CMP		AX,[Y2]
			JLE		@@OK1
			XCHG	AX,[Y2]
			MOV		[Y1],AX					{ SWAPPED Y1:Y2 }
			MOV		AX,[X1]
			XCHG	AX,[X2]
			MOV		[X1],AX					{ SWAPPED X1:X2 }
			MOV		AX,[TX1]
			XCHG	AX,[TX2]
			MOV		[TX1],AX				{ SWAPPED TX1:TX2 }
			MOV		AX,[TY1]
			XCHG	AX,[TY2]
			MOV		[TY1],AX				{ SWAPPED TY1:TY2 }
@@OK1:

			MOV		AX,[Y1]
			CMP		AX,[Y3]
			JLE		@@OK2
			XCHG	AX,[Y3]
			MOV		[Y1],AX					{ SWAPPED Y1:Y3 }
			MOV		AX,[X1]
			XCHG	AX,[X3]
			MOV		[X1],AX					{ SWAPPED X1:X3 }
			MOV		AX,[TX1]
			XCHG	AX,[TX3]
			MOV		[TX1],AX				{ SWAPPED TX1:TX3 }
			MOV		AX,[TY1]
			XCHG	AX,[TY3]
			MOV		[TY1],AX				{ SWAPPED TY1:TY3 }
@@OK2:

			MOV		AX,[Y2]
			CMP		AX,[Y3]
			JLE		@@OK3
			XCHG	AX,[Y3]
			MOV		[Y2],AX					{ SWAPPED Y2:Y3 }
			MOV		AX,[X2]
			XCHG	AX,[X3]
			MOV		[X2],AX					{ SWAPPED X2:X3 }
			MOV		AX,[TX2]
			XCHG	AX,[TX3]
			MOV		[TX2],AX				{ SWAPPED TX2:TX3 }
			MOV		AX,[TY2]
			XCHG	AX,[TY3]
			MOV		[TY2],AX				{ SWAPPED TY2:TY3 }
@@OK3:
			CMP		[Y1],199
			JG		@@EXIT
			CMP		[Y3],0
			JL		@@EXIT
			CMP		[X1],0
			JGE		@@OK22
			CMP		[X2],0
			JGE		@@OK22
			CMP		[X3],0
			JGE		@@OK22
			JMP		@@EXIT
@@OK22:
			CMP		[X1],319
			JLE		@@OK23
			CMP		[X2],319
			JLE		@@OK23
			CMP		[X3],319
			JLE		@@OK23
			JMP		@@EXIT
@@OK23:

	DB $66;	DB $0F, $BF, $46, OFFSET X1		{ MOVSX EAX,[X1] }
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX1],AX
	DB $66;	DB $0F, $BF, $46, OFFSET X2		{ MOVSX EAX,[X2] }
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX2],AX
	DB $66;	DB $0F, $BF, $46, OFFSET X3		{ MOVSX EAX,[X3] }
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR XX3],AX

	DB $66;	DB $0F, $BF, $46, OFFSET TX1	{ MOVSX EAX,[TX1] }
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR TXX1],AX
	DB $66;	DB $0F, $BF, $46, OFFSET TX2	{ MOVSX EAX,[TX2] }
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR TXX2],AX
	DB $66;	DB $0F, $BF, $46, OFFSET TX3	{ MOVSX EAX,[TX3]			}
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR TXX3],AX

	DB $66;	DB $0F, $BF, $46, OFFSET TY1	{ MOVSX EAX,[TY1]			}
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR TYY1],AX
	DB $66;	DB $0F, $BF, $46, OFFSET TY2	{ MOVSX EAX,[TY2]			}
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR TYY2],AX
	DB $66;	DB $0F, $BF, $46, OFFSET TY3	{ MOVSX EAX,[TY3]			}
	DB $66;	SHL		AX,Scaler
	DB $66;	MOV		[WORD PTR TYY3],AX

			MOV		AX,[Y1]
			CMP		AX,[Y2]
			JNE		@@NONFLAT1
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX1],AX
	DB $66;	MOV		[WORD PTR TDX1],AX
	DB $66;	MOV		[WORD PTR TDY1],AX
			JMP		@@OK7
@@NONFLAT1:
	DB $66;	DB $0F, $BF, $5E, OFFSET Y2		{ MOVSX EBX,[Y2]			}
	DB $66;	DB $0F, $BF, $4E, OFFSET Y1		{ MOVSX ECX,[Y1]			}
	DB $66;	SUB		BX,CX					{ SUB EBX,ECX				}

	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	SUB		AX,[WORD PTR XX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DX1],AX

	DB $66;	MOV		AX,[WORD PTR TXX2]
	DB $66;	SUB		AX,[WORD PTR TXX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR TDX1],AX

	DB $66;	MOV		AX,[WORD PTR TYY2]
	DB $66;	SUB		AX,[WORD PTR TYY1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR TDY1],AX

@@OK7:
			MOV		AX,[Y2]
			CMP		AX,[Y3]
			JNE		@@NONFLAT2
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX2],AX
	DB $66;	MOV		[WORD PTR TDX2],AX
	DB $66;	MOV		[WORD PTR TDY2],AX
			JMP		@@OK11
@@NONFLAT2:
	DB $66;	DB $0F, $BF, $5E, OFFSET Y3		{ MOVSX EBX,[Y3]			}
	DB $66;	DB $0F, $BF, $4E, OFFSET Y2		{ MOVSX ECX,[Y2]			}
	DB $66;	SUB		BX,CX					{ SUB EBX,ECX				}

	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	SUB		AX,[WORD PTR XX2]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DX2],AX

	DB $66;	MOV		AX,[WORD PTR TXX3]
	DB $66;	SUB		AX,[WORD PTR TXX2]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR TDX2],AX

	DB $66;	MOV		AX,[WORD PTR TYY3]
	DB $66;	SUB		AX,[WORD PTR TYY2]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR TDY2],AX

@@OK11:

			MOV		AX,[Y1]
			CMP		AX,[Y3]
			JNE		@@NONFLAT3
	DB $66;	XOR		AX,AX
	DB $66;	MOV		[WORD PTR DX3],AX
	DB $66;	MOV		[WORD PTR TDX3],AX
	DB $66;	MOV		[WORD PTR TDY3],AX
			JMP		@@OK15
@@NONFLAT3:
	DB $66;	DB $0F, $BF, $5E, OFFSET Y3		{ MOVSX EBX,[Y3]			}
	DB $66;	DB $0F, $BF, $4E, OFFSET Y1		{ MOVSX ECX,[Y2]			}
	DB $66;	SUB		BX,CX					{ SUB EBX,ECX				}

	DB $66;	MOV		AX,[WORD PTR XX3]
	DB $66;	SUB		AX,[WORD PTR XX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR DX3],AX

	DB $66;	MOV		AX,[WORD PTR TXX3]
	DB $66;	SUB		AX,[WORD PTR TXX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR TDX3],AX

	DB $66;	MOV		AX,[WORD PTR TYY3]
	DB $66;	SUB		AX,[WORD PTR TYY1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR TDY3],AX

@@OK15:

	DB $66;	MOV		AX,[WORD PTR XX1]
	DB $66;	MOV		[WORD PTR CX1],AX
	DB $66;	MOV		AX,[WORD PTR TXX1]
	DB $66;	MOV		[WORD PTR TCX1],AX
	DB $66;	MOV		AX,[WORD PTR TYY1]
	DB $66;	MOV		[WORD PTR TCY1],AX

			MOV		AX,[Y1]
			CMP		AX,[Y2]
			JNE		@@NONFLAT4
	DB $66;	MOV		AX,[WORD PTR XX2]
	DB $66;	MOV		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR TXX2]
	DB $66;	MOV		[WORD PTR TCX2],AX
	DB $66;	MOV		AX,[WORD PTR TYY2]
	DB $66;	MOV		[WORD PTR TCY2],AX
			JMP		@@OK16
@@NONFLAT4:
	DB $66;	MOV		AX,[WORD PTR XX1]
	DB $66;	MOV		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR TXX1]
	DB $66;	MOV		[WORD PTR TCX2],AX
	DB $66;	MOV		AX,[WORD PTR TYY1]
	DB $66;	MOV		[WORD PTR TCY2],AX
@@OK16:
			MOV		AX,[Y1]
			MOV		[Y],AX
			MOV		AX,[Y]
			TEST	AX,AX
			JGE		@@MOVEDOWN
			XOR		AX,AX
@@MOVEDOWN:
			MOV		DI,AX
			SHL		DI,6
			SHL		AX,8
			ADD		DI,AX
@@LINELOOP:
			MOV		AX,[Y]
			CMP		AX,0
			JL		@@NEXTLINE
			CMP		AX,199
			JG		@@EXIT

	DB $66;	MOV		AX,[WORD PTR CX1]
	DB $66;	CMP		AX,[WORD PTR CX2]
			JGE		@@MUSTSWAP
	DB $66;	MOV		[WORD PTR MX1],AX
	DB $66;	MOV		AX,[WORD PTR CX2]
	DB $66;	MOV		[WORD PTR MX2],AX
	DB $66;	MOV		AX,[WORD PTR TCX1]
	DB $66;	MOV		[WORD PTR MTX1],AX
	DB $66;	MOV		AX,[WORD PTR TCY1]
	DB $66;	MOV		[WORD PTR MTY1],AX
	DB $66;	MOV		AX,[WORD PTR TCX2]
	DB $66;	MOV		[WORD PTR MTX2],AX
	DB $66;	MOV		AX,[WORD PTR TCY2]
	DB $66;	MOV		[WORD PTR MTY2],AX
			JMP		@@OK17
@@MUSTSWAP:
	DB $66;	MOV		[WORD PTR MX2],AX
	DB $66;	MOV		AX,[WORD PTR CX2]
	DB $66;	MOV		[WORD PTR MX1],AX
	DB $66;	MOV		AX,[WORD PTR TCX1]
	DB $66;	MOV		[WORD PTR MTX2],AX
	DB $66;	MOV		AX,[WORD PTR TCY1]
	DB $66;	MOV		[WORD PTR MTY2],AX
	DB $66;	MOV		AX,[WORD PTR TCX2]
	DB $66;	MOV		[WORD PTR MTX1],AX
	DB $66;	MOV		AX,[WORD PTR TCY2]
	DB $66;	MOV		[WORD PTR MTY1],AX
@@OK17:
	DB $66;	XOR		CX,CX
	DB $66;	SAR		[WORD PTR MX1],Scaler
	DB $66;	ADC		[WORD PTR MX1],CX
	DB $66;	SAR		[WORD PTR MX2],Scaler
	DB $66;	ADC		[WORD PTR MX2],CX

	DB $66;	MOV		BX,[WORD PTR MX2]
	DB $66;	SUB		BX,[WORD PTR MX1]
	DB $66;	INC		BX

	DB $66;	MOV		AX,[WORD PTR MTX2]
	DB $66;	SUB		AX,[WORD PTR MTX1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR MDX1],AX

	DB $66;	MOV		AX,[WORD PTR MTY2]
	DB $66;	SUB		AX,[WORD PTR MTY1]
	DB $66;	CWD
	DB $66;	IDIV	BX
	DB $66;	MOV		[WORD PTR MDY1],AX

			CMP		[WORD PTR MX2],319
			JLE		@@OK20
			MOV		[WORD PTR MX2],319
@@OK20:

			MOV     [TEMPDI],DI
			CMP		[WORD PTR MX1],0
			JL		@@LOOP1
			ADD		DI,[WORD PTR MX1]
@@LOOP1:
			MOV		AX,[WORD PTR MX1]
			CMP		AX,0
			JL		@@NEXTPIXEL
			CMP		AX,[WORD PTR MX2]
			JG		@@ENDOFLINE
	DB $66;	MOV		AX,[WORD PTR MTY1]
	DB $66;	XOR		CX,CX
	DB $66;	SAR		AX,Scaler
	DB $66;	ADC		AX,CX
			MOV		BX,AX
			SHL		AX,6
			SHL		BX,8
			ADD		BX,AX
	DB $66;	MOV		AX,[WORD PTR MTX1]
	DB $66;	SAR		AX,Scaler
			ADC		BX,AX
			MOV		AL,[DS:SI+BX]
			MOV		[ES:DI],AL
			INC		DI
@@NEXTPIXEL:
			INC		[WORD PTR MX1]
	DB $66;	MOV		AX,[WORD PTR MDX1]
	DB $66;	ADD		[WORD PTR MTX1],AX
	DB $66;	MOV		AX,[WORD PTR MDY1]
	DB $66;	ADD		[WORD PTR MTY1],AX
			JMP		@@LOOP1
@@ENDOFLINE:
			MOV     DI,[TEMPDI]
			ADD		DI,320
@@NEXTLINE:
	DB $66;	MOV		AX,[WORD PTR DX3]
	DB $66;	ADD		[WORD PTR CX1],AX
	DB $66;	MOV		AX,[WORD PTR TDX3]
	DB $66;	ADD		[WORD PTR TCX1],AX
	DB $66;	MOV		AX,[WORD PTR TDY3]
	DB $66;	ADD		[WORD PTR TCY1],AX
			MOV		AX,[Y]
			CMP		AX,[Y2]
			JL		@@TOPPART
	DB $66;	MOV		AX,[WORD PTR DX2]
	DB $66;	ADD		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR TDX2]
	DB $66;	ADD		[WORD PTR TCX2],AX
	DB $66;	MOV		AX,[WORD PTR TDY2]
	DB $66;	ADD		[WORD PTR TCY2],AX
			JMP		@@OK21
@@TOPPART:
	DB $66;	MOV		AX,[WORD PTR DX1]
	DB $66;	ADD		[WORD PTR CX2],AX
	DB $66;	MOV		AX,[WORD PTR TDX1]
	DB $66;	ADD		[WORD PTR TCX2],AX
	DB $66;	MOV		AX,[WORD PTR TDY1]
	DB $66;	ADD		[WORD PTR TCY2],AX
@@OK21:
			INC		[Y]
			MOV		AX,[Y]
			CMP		AX,199
			JG		@@EXIT
			CMP		AX,[Y3]
			JLE		@@LINELOOP
@@EXIT:
			MOV     DS,[TEMPDS]
End;
Function LoadPCX(FileName : String; Var Width,Height : Word; Var RGB; VideoSeg : Word) : Integer;
Var
	PCXFile		: File;
	OldMode		: Byte;
	BytesRead	: Word;
	Error		: Boolean;
	Buffer1		: PChar;
	InBuffer1	: Word;
	BufferSize1	: Word;
	Buffer2		: PChar;
	InBuffer2	: Word;
	BufferSize2	: Word;
	PCXHeader	: Record
		Manufacturer	: Byte;
		Version			: Byte;
		Encoding		: Byte;
		BitsPerPixel	: Byte;
		Window			: Record
			X1			: Integer;
			Y1			: Integer;
			X2			: Integer;
			Y2			: Integer;
		End;
		DPI				: Record
			Horizontal	: Integer;
			Vertical	: Integer;
		End;
		ColorMap		: Array[0..47] Of Byte;
		Reserved		: Byte;
		NPlanes			: Byte;
		BytesPerLine	: Integer;
		PaletteInfo		: Integer;
		ScreenSize		: Record
			Horizontal	: Integer;
			Vertical	: Integer;
		End;
		Filler			: Array[1..54] Of Byte;
	End;

	Procedure DeCode(VideoSeg : Word; ToDeCode : Word; Buffer1,Buffer2 : PChar; InBuffer1,InBuffer2 : Word); Assembler;
	Asm
		PUSH	DS
		MOV		CX,[ToDeCode]
		LDS		SI,[DWORD PTR Buffer1]
		MOV		DX,[InBuffer1]
		MOV		ES,[VideoSeg]
		XOR		DI,DI
	@@LOOP1:
		JCXZ	@@EXIT
		MOV		AL,[DS:SI]
		INC		SI
		DEC		DX
		JNZ		@@SKIP1
		LDS		SI,[DWORD PTR Buffer2]
		MOV		DX,[InBuffer2]
	@@SKIP1:
		MOV		AH,AL
		AND		AH,$C0
		CMP		AH,$C0
		JE		@@RLE
		MOV		[ES:DI],AL
		INC		DI
		DEC		CX
		JMP		@@LOOP1
	@@RLE:
		MOV		AH,AL
		AND		AH,$3F
	@@LOOP2:
		MOV		AL,[DS:SI]
		INC		SI
		DEC		DX
		JNZ		@@SKIP2
		LDS		SI,[DWORD PTR Buffer2]
		MOV		DX,[InBuffer2]
	@@SKIP2:
		MOV		[ES:DI],AL
		INC		DI
		DEC		CX
		DEC		AH
		JNZ		@@SKIP2
		JMP		@@LOOP1
	@@EXIT:
		POP		DS
	End;

Begin
	Assign(PCXFile,FileName);
	OldMode:=FileMode;
	FileMode:=0;
	{$I-}
	ReSet(PCXFile,1);
	FileMode:=OldMode;
	{$I+}
	If IOResult<>0 Then Begin
		LoadPCX:=1;
		Exit;
	End;
	BlockRead(PCXFile,PCXHeader,SizeOf(PCXHeader),BytesRead);
	If BytesRead<>SizeOf(PCXHeader) Then Begin
		Close(PCXFile);
		LoadPCX:=2;
		Exit;
	End;
	Error:=FALSE;
	With PCXHeader Do Begin
		If Manufacturer<>10 Then
			Error:=TRUE;
		If EnCoding<>1 Then
			Error:=TRUE;
		If BitsPerPixel<>8 Then
			Error:=TRUE;
		If LongInt(Window.X2-Window.X1+1)*LongInt(Window.Y2-Window.Y1+1)>65528 Then
			Error:=TRUE;
		If NPlanes<>1 Then
			Error:=TRUE;
		If PaletteInfo<>1 Then
			Error:=TRUE;
		Width:=Window.X2-Window.X1+1;
		Height:=Window.Y2-Window.Y1+1;
	End;
	If Error Then Begin
		LoadPCX:=3;
		Close(PCXFile);
		Exit;
	End;
	If FileSize(PCXFile)-FilePos(PCXFile)-768<=65528 Then Begin
		BufferSize1:=FileSize(PCXFile)-FilePos(PCXFile)-768;
		BufferSize2:=0;
	End Else Begin
		BufferSize1:=65528;
		BufferSize2:=FileSize(PCXFile)-FilePos(PCXFile)-66296;
	End;
	GetMem(Buffer1,BufferSize1);
	If Buffer1=NIL Then Begin
		Close(PCXFile);
		LoadPCX:=5;
		Exit;
	End;
	BlockRead(PCXFile,Buffer1^,BufferSize1,InBuffer1);
	If BufferSize2<>0 Then Begin
		GetMem(Buffer2,BufferSize2);
		If Buffer2=NIL Then Begin
			FreeMem(Buffer1,BufferSize1);
			Close(PCXFile);
			LoadPCX:=5;
			Exit;
		End;
		BlockRead(PCXFile,Buffer2^,BufferSize2,InBuffer2);
	End Else
		InBuffer2:=0;
	If (BufferSize1<>InBuffer1) Or (BufferSize2<>InBuffer2) Then Begin
		Close(PCXFile);
		FreeMem(Buffer1,BufferSize1);
		If BufferSize2<>0 Then
			FreeMem(Buffer2,BufferSize2);
		LoadPCX:=4;
		Exit;
	End;
	With PCXHeader Do
		DeCode(VideoSeg,Width*Height,Buffer1,Buffer2,InBuffer1,InBuffer2);
	FreeMem(Buffer1,BufferSize1);
	If BufferSize2<>0 Then
		FreeMem(Buffer2,BufferSize2);
	LoadPCX:=4;
	Seek(PCXFile,FileSize(PCXFile)-768);
	BlockRead(PCXFile,RGB,768,BytesRead);
	Close(PCXFile);
	If BytesRead<>768 Then Begin
		LoadPCX:=6;
		Exit;
	End;
	Asm
		LES		DI,[DWORD PTR RGB]
		MOV		CX,768
	@@LOOP1:
		SHR		[BYTE PTR ES:DI],2
		INC		DI
		DEC		CX
		JNZ		@@LOOP1
	End;
	LoadPCX:=0;
End;

procedure blit(address1,address2,x1,y1,x2,y2,widht,height:word);
assembler;
label loopy,loopx,next;
asm
push ds
mov  ds,address2 {where to}
mov  es,address1 {from    }
mov  ax,y1  {calculate source offset}
mov  di,ax
shl  ax,8
shl  di,6
add  di,ax
add  di,x1
mov  ax,y2  {calculate dest offset}
mov  si,ax
shl  ax,8
shl  si,6
add  si,ax
add  si,x2
mov  dx,height
loopy:
mov  ax,widht
loopx:
mov  bl,[es:di] {byte}
or   bl,bl
je   next
mov  [ds:si],bl
next:
inc  di
inc  si
dec  ax
jnz  loopx
sub  di,widht
sub  si,widht
add  di,320
add  si,320
dec  dx
jnz  loopy
pop ds
end;

procedure blit2(address1,address2,x1,y1,x2,y2,widht,height:word);
assembler;
label loopy,loopx,next;
asm
push ds
mov  ds,address2 {where to}
mov  es,address1 {from    }
mov  ax,y1  {calculate source offset}
mov  di,ax
shl  ax,8
shl  di,6
add  di,ax
add  di,x1
mov  ax,y2  {calculate dest offset}
mov  si,ax
shl  ax,8
shl  si,6
add  si,ax
add  si,x2
mov  dx,height
loopy:
mov  ax,widht
loopx:
mov  bl,[es:di] {byte}
or   bl,bl
je   next
xor  cx,cx
mov  cl,[ds:si]
cmp  bl,cl
jae  next
mov  [ds:si],bl
next:
inc  di
inc  si
dec  ax
jnz  loopx
sub  di,widht
sub  si,widht
add  di,320
add  si,320
dec  dx
jnz  loopy
pop ds
end;

function blittest1(address1,address2,x1,y1,x2,y2,widht,height:word;vari1,vari2:byte):word;
var palaute:word;
label loopy1,loopx1,ylit1,ylit2,endit,joops;
begin
asm
push ds
mov  ds,address2 {where to}
mov  es,address1 {from    }
mov  ax,y1  {calculate source offset}
mov  di,ax
shl  ax,8
shl  di,6
add  di,ax
add  di,x1
mov  ax,y2  {calculate dest offset}
mov  si,ax
shl  ax,8
shl  si,6
add  si,ax
add  si,x2
mov  dx,height
loopy1:
mov  ax,widht
loopx1:
mov  bl,[es:di] {byte}
or   bl,bl
je   ylit2

mov  cl,[ds:si]
cmp  cl,vari1
jae  ylit1
mov  ax,111
jmp  endit

ylit1:

cmp  cl,vari2
jbe  ylit2
mov  ax,111
jmp  endit

ylit2:

inc  di
inc  si
dec  ax
jnz  loopx1
sub  di,widht
sub  si,widht
add  di,320
add  si,320
dec  dx
jnz  loopy1
mov  ax,0
endit:
mov  palaute,ax
pop  ds
end;
blittest1:=palaute;
end;

function blittest2(address1,address2,x1,y1,x2,y2,widht,height:word;vari1,vari2:byte):word;
var palaute:word;
label loopy1,loopx1,ylit1,ylit2,ylit3,endit,joops;
begin
asm
push ds
mov  palaute,0
mov  ds,address2 {where to}
mov  es,address1 {from    }
mov  ax,y1  {calculate source offset}
mov  di,ax
shl  ax,8
shl  di,6
add  di,ax
add  di,x1
mov  ax,y2  {calculate dest offset}
mov  si,ax
shl  ax,8
shl  si,6
add  si,ax
add  si,x2
mov  dx,height
loopy1:
mov  ax,widht
loopx1:
mov  bl,[es:di] {byte}
or   bl,bl
je   ylit3

mov  cl,[ds:si]
cmp  cl,vari1
jae  ylit1
jmp  ylit3

ylit1:

cmp  cl,vari2
jbe  ylit2
jmp  ylit3

ylit2:
mov  palaute,111

ylit3:

inc  di
inc  si
dec  ax
jnz  loopx1
sub  di,widht
sub  si,widht
add  di,320
add  si,320
dec  dx
jnz  loopy1

endit:
pop  ds
end;
blittest2:=palaute;
end;

procedure blitclr(address1,address2,x1,y1,x2,y2,widht,height:word;color:byte);
assembler;
label loopy,loopx,next;
asm
push ds
mov  ds,address2 {where to}
mov  es,address1 {from    }
mov  ax,y1  {calculate source offset}
mov  di,ax
shl  ax,8
shl  di,6
add  di,ax
add  di,x1
mov  ax,y2  {calculate dest offset}
mov  si,ax
shl  ax,8
shl  si,6
add  si,ax
add  si,x2
mov  dx,height
loopy:
mov  ax,widht
loopx:
mov  bl,[es:di] {byte}
or   bl,bl
je   next
mov  cl,color
mov  [ds:si],cl
next:
inc  di
inc  si
dec  ax
jnz  loopx
sub  di,widht
sub  si,widht
add  di,320
add  si,320
dec  dx
jnz  loopy
pop ds
end;

procedure KeyHandler;
   begin
   asm
   push ax
   push ds
   push es
   mov ax,0
   in   al,60h
   mov  key,ax
   mov  al,20h
   out  20h,al
   pop es
   pop ds
   pop ax
   end;
   end;

Procedure GoTweak(super:byte);
assembler;
label eih;
asm;
cli
mov  dx,003c4h
mov  al,4
mov  ah,6
out  dx,ax
mov  dx,003d4h
mov  al,014h
out  dx,al
inc  dx
in   al,dx
and  al,0bfh
out  dx,al
dec  dx
mov  al,017h
out  dx,al
inc  dx
in   al,dx
or   al,040h
out  dx,al
dec  dx
sti
cmp  super,1
jne  eih
mov  dx,003d4h
mov  al,9
out  dx,al
inc  dx
in   al,dx
and  al,0e0h
out  dx,al
eih:

end;

Procedure Setplanes(mask:byte);
assembler;
asm
mov ah,mask
mov al,2
mov dx,$3c4
out dx,ax
end;

Procedure Dtweakpixel(xco,yco:word;col:byte;address:word);
assembler;
asm
  mov dx,03c4h
  mov al,2
  mov cx,[xco]
  and cx,3
  mov ah,1
  shl ah,cl
  out dx,ax
  mov es,address
  mov ax,[yco]
  shl ax,4
  mov di,ax
  shl ax,2
  add di,ax
  mov dx,[xco]
  shr dx,2
  add di,dx
  mov al,[col]
  mov [es:di],al
end;

Procedure Dtweakshadep(xco,yco:word;col:byte;address:word);
assembler;
asm
  mov dx,03c4h
  mov al,2
  mov cx,[xco]
  and cx,3
  mov ah,1
  shl ah,cl
  out dx,ax
  mov es,address
  mov ax,[yco]
  shl ax,4
  mov di,ax
  shl ax,2
  add di,ax
  mov dx,[xco]
  shr dx,2
  add di,dx
  mov al,[col]
  add [es:di],al
end;

Procedure SetOffset(offs:word);
assembler;
asm
mov dx,3d4h
mov al,0ch
mov ah,[byte(offs)+1]
out dx,ax
mov al,0dh
mov ah,[byte(offs)]
out dx,ax
end;

Procedure THline (X1,X2,Y:Word;Color:Byte;segi:word); Assembler;
{NO CHECKS!!! NO CLIPPINGS!!!}
Var
  tmp : Word;
  Asm
    mov dX, Y
    mov DI, dx

    shl dx, 6
    ShL DI, 4
    add di,dx
{t„h„n joku y kerroin}

    mov BX, X1
    mov CX, X2
    cmp BX, CX
    jle @no_c
    xchg CX, BX
    @no_C:
    cmp CX, 320
    jle @no_round1
    mov CX, 320
    @no_round1:
    cmp BX, 320
    jle @no_round2
    mov BX, 320
    @no_round2:
    cmp CX, 0
    jge @no_round3
    mov CX, 0
    @no_round3:
    cmp BX, 0
    jge @no_round4
    mov BX, 0
    @no_round4:
    mov X2, CX
    mov X1, BX

    sub CX, BX              {Calculate length}
    cmp CX, 10              {If greater than 10, then use 4pixel/byte drawing}
    jg  @method_2

    mov ES, segi    {segment to draw}
    mov BX, X1

    @loopp:
    mov CL, BL
    And CL, 3
    mov AH, 1
    ShL AH, CL
    mov AL, 2
    mov DX, 3c4h
    out DX, AX
    mov DX, BX
    ShR DX, 2
    push DI
    add DI, DX
    mov AL, Color
    mov ES: [DI], AL
    pop DI
    Inc BX
    cmp BX, X2
    jle @loopp
    jmp @loppu_filling

    @method_2:                    {If the horz. line is enough long,
    It's wise to minimize the plane
    selections.}

    mov ES, segi {segment to draw}

    mov dx, y
    mov DI, dx
    shl dx, 6
    ShL DI, 4
    add di, dx
{    mov DI, cs: [Offset gadr + DI]
     y kerroin}

    mov BX, X1

    @loopp2:
    mov CL, BL
    And CL, 3
    cmp CL, 0
    je  @alku_ok
    mov AH, 1
    ShL AH, CL
    mov AL, 2
    mov DX, 3c4h
    out DX, AX
    mov DX, BX
    ShR DX, 2
    push DI
    add DI, DX
    mov AL, Color
    mov ES: [DI], AL
    pop DI
    Inc BX
    cmp BX, X2
    jle @loopp2
    @alku_ok:

    pusha
    mov BX, X2
    mov CX, BX
    And CX, 3
    sub BX, CX
    mov tmp, BX

    mov dx, y
    mov DI, dx
    shl dx, 6
    ShL DI, 4
    add di, dx
{    mov DI, cs: [Offset gadr + DI]
y kerroin
}
    @loopp3:
    mov CL, BL
    And CL, 3
    mov AH, 1
    ShL AH, CL
    mov AL, 2
    mov DX, 3c4h
    out DX, AX
    mov DX, BX
    ShR DX, 2
    push DI
    add DI, DX
    mov AL, Color
    mov ES: [DI], AL
    pop DI
    Inc BX
    cmp BX, X2
    jle @loopp3
    popa


    mov X1, BX
    mov CX, X2
    mov BX, CX
    And CX, 3
    sub BX, CX
    mov SI, BX     {x1=start of 4pixel system, si=end}

    mov AX, 0f02h  {All planes -> 4pixels at one stosb!}
    mov DX, 3c4h
    out DX, AX
    mov BX, 1
    mov AL, Color
    cld
    mov CX, SI
    sub CX, X1     {How many bytes}
    ShR CX, 2

    mov dx, y
    mov DI, dx
    shl dx, 6
    ShL DI, 4
    add di,dx
{    mov DI, cs: [Offset gadr + DI]
y kerroin
}    mov DX, X1
    ShR DX, 2
    add DI, DX
    rep stosb

    @loppu_filling:
  End; {hline}

Procedure TVline(y1,y2,x:Word;Color:Byte;segi:word);
Assembler;
Asm
  mov  DX, X
  cmp  DX, 320                  {If x out of screen, no need for further processing}
  jg   @q_exitt
  cmp  DX, 0
  jl   @q_exitt

  mov  BX, Y2
  mov  DI, Y1
  cmp  DI, BX                    {Compare y1 with y2}
  jle  @no_swap_y               {If y1=<y2, then jmp over next command}
  xchg DI, BX                    {y1>y2, so swap them!}
  @no_swap_y:
  cmp  DI, 200
  jle  @no_max_y1
  mov  DI, 200
  @no_max_y1:
  cmp  BX, 200
  jle  @no_max_y2
  mov  BX, 200
  @no_max_y2:
  cmp  DI, 0
  jge  @no_less_y1
  mov  DI, 0
  @no_less_y1:
  cmp  BX, 0
  jge  @no_less_y2
  mov  BX, 0
  @no_less_y2:

  mov  AH, 1
  mov  CX, DX                    {Take x coordinate to cx}
  And  CL, 3                     {Only values(planes) 0-3}
  ShL  AH, CL
  mov  DX, 3c4h                  {CRT Controller}
  mov  AL, 2                     {Plane select}
  out  DX, AX                    {Select plane}

  mov  DX, X
  ShR  DX, 2                     {Divide x coordinate with 4}

{  ShL  DI, 1 }                    {DI=y1*2}
  mov  ax, di
  shl  ax, 6
  shl  di, 4
  add  di, ax

{  ShL  BX, 1 }                    {BX=y2*2,}
  mov  ax, bx
  shl  ax, 6
  shl  bx, 4
  add  bx, ax

{  mov  DI, cs: [Offset gadr + DI]
  mov  BX, cs: [Offset gadr + BX]
}

  add  DI, DX
  add  di, 80
  add  BX, DX
  mov  AL, Color

  cmp  DI, BX
  jne  @normal
  stosb
  jmp  @q_exitt
  @normal:
  cld                                 {Forward direction flag}
  @next_pixel:
  stosb                               {Same as mov es:[di],al}
  add  DI, 79                        {STOSB increments di with 1}
  cmp  DI, BX
  jne  @next_pixel
  @q_exitt:
End;  {vline}

Procedure DTweakLine (X1,Y1,X2,Y2:Word;Color:Byte;segi:word);
Assembler;
Var
  diagonal_x_increment,
  diagonal_y_increment,
  short_distance,
  straight_x_increment,
  straight_y_increment,
  straight_count,
  diagonal_count: Integer;
label eip1;
  Asm

    mov ES, segi

    mov CX, 1 {Set initial increments for each pixel position }
    mov DX, 1
    mov DI, Y2 {Calculate Vert. distance }
    sub DI, Y1
    jge @keep_y
    neg DX
    neg DI
    @Keep_Y:
    mov diagonal_y_increment, DX
    mov SI, X2 { Calculate horiz. distance }
    sub SI, X1
    jge @keep_x
    neg CX
    neg SI
    @Keep_X:
    mov diagonal_x_increment, CX
    cmp SI, DI { Figure whether straight segments are horizontal or vertical }
    jge @horz_seg
    mov CX, 0
    xchg SI, DI
    jmp @Save_Values
    @Horz_seg:
    mov DX, 0
    @Save_values:
    mov short_distance, DI
    mov straight_x_increment, CX
    mov straight_y_increment, DX
    mov AX, short_distance { Calculate adjustment factor }
    ShL AX, 1
    mov straight_count, AX
    sub AX, SI
    mov BX, AX
    sub AX, SI
    mov diagonal_count, AX
    mov CX, X1 { prepare to draw the line }
    mov DX, Y1
    Inc SI
    mov AL, Color
    @MainLoop: { Now draw the line }
    Dec SI
    jz  @line_finished
    { Plot Pixel, dx=y coordinate, cx=x coordinate }
    pusha

    mov  DI, DX
    cmp  dx,0
    jb   eip1
    cmp  dx,199
    ja   eip1

    cmp  cx,0
    jb   eip1
    cmp  cx,319
    ja   eip1


    ShL  DI, 6
    shl  dx, 4
    add  di, dx

    mov  AH, 1
    mov  BX, CX
    And  CL, 3
    ShL  AH, CL
    ShR  BX, 2
    add  DI, BX
    mov  DX, 3c4h
    mov  AL, 02h
    out  DX, AX
    mov  AL, Color
    stosb

    eip1:

    popa
    { End Plot }
    cmp BX, 0
    jge @diagonal_line
    add CX, straight_x_increment { Draw Stright Line Segments }
    add DX, straight_y_increment
    add BX, straight_count
    jmp @MainLoop
    @Diagonal_line: { Draw Diagonal Line Segments }
    add CX, diagonal_x_increment
    add DX, diagonal_y_increment
    add BX, diagonal_count
    jmp @MainLoop
    @Line_Finished:
  End;      {line}

Procedure DTShadeLine (X1,Y1,X2,Y2:Word;Color:Byte;segi:word);
Assembler;
Var
  diagonal_x_increment,
  diagonal_y_increment,
  short_distance,
  straight_x_increment,
  straight_y_increment,
  straight_count,
  diagonal_count: Integer;
label eip1;
  Asm

    mov ES, segi

    mov CX, 1 {Set initial increments for each pixel position }
    mov DX, 1
    mov DI, Y2 {Calculate Vert. distance }
    sub DI, Y1
    jge @keep_y
    neg DX
    neg DI
    @Keep_Y:
    mov diagonal_y_increment, DX
    mov SI, X2 { Calculate horiz. distance }
    sub SI, X1
    jge @keep_x
    neg CX
    neg SI
    @Keep_X:
    mov diagonal_x_increment, CX
    cmp SI, DI { Figure whether straight segments are horizontal or vertical }
    jge @horz_seg
    mov CX, 0
    xchg SI, DI
    jmp @Save_Values
    @Horz_seg:
    mov DX, 0
    @Save_values:
    mov short_distance, DI
    mov straight_x_increment, CX
    mov straight_y_increment, DX
    mov AX, short_distance { Calculate adjustment factor }
    ShL AX, 1
    mov straight_count, AX
    sub AX, SI
    mov BX, AX
    sub AX, SI
    mov diagonal_count, AX
    mov CX, X1 { prepare to draw the line }
    mov DX, Y1
    Inc SI
    mov AL, Color
    @MainLoop: { Now draw the line }
    Dec SI
    jz  @line_finished
    { Plot Pixel, dx=y coordinate, cx=x coordinate }
    pusha

    mov  DI, DX
    cmp  dx,0
    jb   eip1
    cmp  dx,199
    ja   eip1

    cmp  cx,0
    jb   eip1
    cmp  cx,319
    ja   eip1


    ShL  DI, 6
    shl  dx, 4
    add  di, dx

    mov  AH, 1
    mov  BX, CX
    And  CL, 3
    ShL  AH, CL
    ShR  BX, 2
    add  DI, BX
    mov  DX, 3c4h
    mov  AL, 02h
    out  DX, AX
    mov  AL, Color
    add [es:di],al

    eip1:

    popa
    { End Plot }
    cmp BX, 0
    jge @diagonal_line
    add CX, straight_x_increment { Draw Stright Line Segments }
    add DX, straight_y_increment
    add BX, straight_count
    jmp @MainLoop
    @Diagonal_line: { Draw Diagonal Line Segments }
    add CX, diagonal_x_increment
    add DX, diagonal_y_increment
    add BX, diagonal_count
    jmp @MainLoop
    @Line_Finished:
  End;      {line}


End.

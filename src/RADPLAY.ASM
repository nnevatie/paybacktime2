.Model Tpascal

.Data

.Code

PUBLIC InitPlayer,EndPlayer,PlayMusic

locals
.386

jumps

; Tracker commands
cmPortamentoUp	=	1		; Portamento up
cmPortamentoDwn	=	2		; Portamento down
cmToneSlide	=	3		; Tone Slide: xx is speed of slide
cmToneVolSlide	=	5		; Tone slide of 00 + Vol. Slide
cmVolSlide	=	10		; Volume Slide: <50=down, >50=up
cmSetVol	=	12		; set volume
cmJumpToLine	=	13		; Jump to line in next track
cmSetSpeed	=	15		; set speed

FreqStart	=	156h		; low end of frequency in each octave
FreqEnd		=	2aeh		; high end of frequency in each octave
FreqRange	=	FreqEnd-FreqStart


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; This stops music playback (stops sound channels).
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC EndPlayer
              	push	ax
		mov	ax,020h shl 8
	@@la0:	call	Adlib
		inc	ah
		cmp	ah,00f6h
		jb	@@la0
		pop	ax
		ret
ENDP EndPlayer


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; This routine initialises the player.
; IN:
;	ES:	- points to .RAD module to play
; OUT:
;	Carry	- set on error (such as invalid module)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC InitPlayer musicseg:WORD
                pusha

                mov     es,musicseg
		call    EndPlayer	; clear Adlib ready for tune

	; initialise certain Adlib registers that aren't changed
		mov	ax,0120h	; allow waveforms
		call	Adlib
		mov	ax,0800h
		call	Adlib
		mov	ah,0bdh		; no drums, etc.
		call	Adlib

	; check to see if it is a RAD file first
		cmp	word ptr es:[0],'AR'
		jnz	@@err
		cmp	word ptr es:[2],' D'
		jnz	@@err
		cmp	byte ptr es:[16],10h		; correct version?
		jnz	@@err

		mov	cs:ModSeg,es		; keep the segment of module

	; read initial speed
		mov	al,es:[17]
		mov	ah,al
		and	al,1fh
		mov	cs:Speed,al

	; see if there's a description to skip
		mov	si,18
		test	ah,80h			; description flag
		jz	@@lc			; no description

		xor	al,al
		jmp	@@le

	@@ld:	inc	si
	@@le:	cmp	es:[si],al		; look for null-termination
		jnz	@@ld
		inc	si			; move past null

	; create table of instrument pointers
	@@lc:	xor	bx,bx

	@@la8:	mov	bl,es:[si]		; instrument no.
		inc	si
		add	bx,bx
		jz	@@lb			; no more instruments

		mov	cs:InstPtrs-2[bx],si	; record pointer to instrument
		add	si,11
		jmp	@@la8

	; record offset of order list
	@@lb:	xor	ax,ax
		mov	al,es:[si]		; no. of orders in order-list
		mov	cs:OrderSize,ax
		inc	si
		mov	cs:OrderList,si
		xor	bx,bx
		mov	bl,es:[si]		; first pattern to play
		add	bx,bx
		add	si,ax			; move to end of list

	; record table of pattern offsets
		mov	cs:PatternList,si
		mov	ax,es:[si+bx]		; first pattern offset
		mov	cs:PatternPos,ax	; pointer to first pattern

	; initial pointers
		xor	ax,ax
		mov	cs:OrderPos,ax		; start at position 0.
		mov	cs:SpeedCnt,al
		mov	cs:Line,al		; start at line 0

		clc
		jmp	@@lx0			; successful initialisation

	@@err:	stc
	@@lx0:	popa
		ret
ENDP    InitPlayer




;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; This routine does the actual playing.  It MUST be called 50 times a second
; to maintain accurate music playback.  Refer to accompanying timer source-code
; for ways of providing a 50/sec timer service.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC PlayMusic
              	pusha
		push	ds

		mov	ds,cs:ModSeg	; segment of module

		cmp	cs:SpeedCnt,0
		jz	@@la		; play a line of music
		dec	cs:SpeedCnt

	; no new line, so just update any effects
		call	UpdateNotes
		jmp	@@lx

	; switch off any effects that are in operation
	@@la:	mov	si,8
		xor	al,al

	@@laa:	mov	cs:PortSlide[si],al	; reset any slides
		mov	cs:VolSlide[si],al	; reset any slides
		mov	cs:ToneSlide[si],al	; reset any slides
		dec	si
		jns	@@laa

	; playing a new line, PatternPos should have been set-up already
		mov	si,cs:PatternPos
		or	si,si
		jz	@@lb		; rest of this pattern is blank

		mov	al,[si]		; line indicator
		and	al,7fh		; eliminate bit 7
		cmp	al,cs:Line	; is this current line?
		jnz	@@lb		; haven't reached it yet

		test	byte ptr [si],80h	; last line?
		jz	@@lc		; no, still more to check
		mov	cs:PatternPos,0	; mark rest of pattern as blank

	@@lc:	inc	si		; move to first channel

	; play channels
	@@lf:	mov	cl,[si]		; channel we are processing
		push	cx
		and	cl,7fh		; get rid of bit 7
		mov	ax,1[si]	; AL=octave/note, AH=inst/command
		add	si,3

		test	ah,15		; if there's a cmd, there'll be a param.
		jz	@@le		; no parameter byte
		mov	ch,[si]		; read parameter
		inc	si

	@@le:	call	PlayNote	; play the note

		pop	cx
		jc	@@lg		; skip rest of line, AX has new line

		test	cl,80h		; last channel to play?
		jz	@@lf		; not yet

		mov	cs:PatternPos,si; keep position in crunched track

	; update pointers
	@@lb:	mov	al,cs:Speed	; needs to be set AFTER note playing
		dec	al
		mov	cs:SpeedCnt,al	;    for new speeds to take effect!

		inc	cs:Line
		cmp	cs:Line,64	; end of pattern?
		jb	@@lx		; nope

		mov	cs:Line,0	; top of next pattern
		call	NextPattern

	@@lx:	pop	ds
		popa
		ret

	; jump to line AX
	@@lg:	mov	bl,cs:Speed	; needs to be set AFTER note playing
		mov	cs:SpeedCnt,bl	;    for new speeds to take effect!

		mov	cs:Line,al

		; find start of next pattern
		call	NextPattern
		jz	@@lx		; there isn't any data in next pattern

		; find line that is greater or equal to the current line
	@@ll:	mov	cl,[si]		; line id.
		and	cl,7fh		; ignore bit 7
		cmp	cl,al
		jae	@@lh		; found line

		test	byte ptr [si],80h
		jz	@@li		; not last line
		xor	si,si
		jmp	@@lh		; ignore rest of pattern as it's last

		; skip to next line definition
	@@li:	inc	si
	@@lj:	mov	cl,[si]
		add	si,3
		test	byte ptr cs:[si-1],15	; is there a valid command?
		jz	@@lk
		inc	si		; skip parameter

	@@lk:	add	cl,cl
		jnc	@@lj		; wasn't last channel spec.
		jmp	@@ll		; check next line

	@@lh:	mov	cs:PatternPos,si
		jmp	@@lx
ENDP PlayMusic




;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Advances pointers to next pattern in order list.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NextPattern:	mov	bx,cs:OrderPos
		inc	bx
		cmp	bx,cs:OrderSize
		jb	@@ld
		xor	bx,bx		; end of tune, move back to start

	@@ld:	mov	cs:OrderPos,bx
		mov	si,cs:OrderList
		mov	bl,[si+bx]	; no. of next pattern

		test	bl,80h
		jz	@@lda
		and	bl,7fh
		jmp	@@ld		; bit 7 = jump to new order

	@@lda:	mov	si,cs:PatternList
		add	bx,bx
		mov	si,[si+bx]	; offset of next pattern
		mov	cs:PatternPos,si
		or	si,si
		ret





;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Plays a note on a channel.
; IN:
;	AL	- Octave (high nibble), Note (low nibble)
;	AH	- instrument (high nibble), command (low nibble)
;	CL	- channel to play note on (0..8)
;	CH	- parameter byte if command is non-zero
; OUT:
;	CARRY	- set if a line is to be jumped to
;	AX	- line to jump to if CARRY set
; Note: don't use SI or segment regs., otherwise registers do not need saving.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PlayNote:	mov	di,cx
		and	di,15
		mov	dh,ah
		and	dh,15		; command

		or	al,al
		jz	@@lb1		; no note playing, process command

	; check to see if we are actually performing a tone slide
		cmp	dh,cmToneSlide
		jnz	@@lt		; nope, play note

		; note/octave are used as parameters then (instrument ignored)
		mov	bx,ax
		and	bx,15		; note
		shr	al,4
		and	ax,7		; octave
		dec	bx		; we want 1..12
		cmp	bx,12
		jae	@@lx1		; not a valid note (probably KEY-OFF)

		imul	ax,FreqRange	; scale octave
		add	bx,bx
		add	ax,cs:NoteFreq[bx]	; add frequency of this note
		sub	ax,FreqStart	; so range starts from zero
		mov	cs:ToneSlideFreqL[di],al	; destination frequency
		mov	cs:ToneSlideFreqH[di],ah

		; set tone slide speed
		mov	byte ptr cs:ToneSlide[di],1	; switch tone slide on
		or	ch,ch
		jz	@@lx1		; use last speed setting
		mov	cs:ToneSlideSpeed[di],ch
		jmp	@@lx1

	; KEY-OFF the previous note
	@@lt:	push	ax
		mov	al,cs:OldB0[di]	; old register value
		and	al, not 20h	; clear KEY-ON bit
		mov	cs:OldB0[di],al	; so slides after KEYOFF work correctly
		mov	ah,cl
		add	ah,0b0h
		call	Adlib
		pop	ax

	; load instrument (if any)
		mov	dl,ah
		add	al,al
		rcr	dl,1
		shr	dl,3		; instrument no.
		jz	@@la1		; no instrument to load
		call	LoadInst

	; load note into channel
	@@la1:	mov	bl,al
		and	bx,15*2		; note * 2
		cmp	bx,15*2
		jz	@@lb1		; just a KEY-OFF so we're done

		mov	bx,cs:NoteFreq-2[bx]	; frequency of note (BX-1)
		shr	al,3		; octave
		and	al,7*4
		or	al,20h		; KEY-ON
		or	al,bh		; Frequency high byte
		mov	ah,0b0h
		add	ah,cl
		mov	cs:OldB0[di],al	; record the register value
		push	ax

		sub	ah,10h
		mov	al,bl		; Frequency low byte
		mov	cs:OldA0[di],al
		call	Adlib

		pop	ax
		call	Adlib

	; process command (if any), DH has command, CH has parameter
	@@lb1:	xor	bx,bx
		mov	bl,dh		; command
		add	bx,bx
		jmp	cs:Effects[bx]

	@@lx1:	clc
	@@lxx:	ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Portamento up
@@PortUp:	mov	cs:PortSlide[di],ch
		jmp	@@lx1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Portamento down
@@PortDown:	neg	ch
		mov	cs:PortSlide[di],ch
		jmp	@@lx1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Tone slide to note (no note supplied)
@@ToneSlide:	or	ch,ch		; parameter has speed of tone slide
		jz	@@lja		; keep last tone slide speed
		mov	cs:ToneSlideSpeed[di],ch

	@@lja:	mov	byte ptr cs:ToneSlide[di],1	; tone slide on
		jmp	@@lx1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Volume slide & Volume + Tone Slide
@@ToneVolSlide:
@@VolSlide:	cmp	ch,50		; <50 = slide down, >50 = slide up
		jb	@@lga
		sub	ch,50
		neg	ch

	@@lga:	mov	cs:VolSlide[di],ch

		cmp	dh,cmToneVolSlide	; just plain volume slide
		jnz	@@lx1
		mov	byte ptr cs:ToneSlide[di],1	; tone slide on
		jmp	@@lx1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Set volume
@@SetVolume:	call	SetVolume	; CH has volume, CL has channel
		jmp	@@lx1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; jump to line in next pattern
@@JumpToLine:	cmp	ch,64
		jae	@@lx1		; ignore as it is invalid
		xor	ax,ax
		mov	al,ch
		stc
		ret			; skip rest of channels
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Set speed
@@SetSpeed:	mov	cs:Speed,ch
		jmp	@@lx1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Effects		dw	@@lx1
		dw	@@PortUp
		dw	@@PortDown
		dw	@@ToneSlide
		dw	@@lx1
		dw	@@ToneVolSlide
		dw	@@lx1
		dw	@@lx1
		dw	@@lx1
		dw	@@lx1
		dw	@@VolSlide
		dw	@@lx1
		dw	@@SetVolume
		dw	@@JumpToLine
		dw	@@lx1
		dw	@@SetSpeed

NoteFreq	dw	16bh,181h,198h,1b0h,1cah,1e5h	; 156h = C
		dw	202h,220h,241h,263h,287h,2aeh






;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Check each channel for ongoing effects to update.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
UpdateNotes:	xor	bh,bh		; channel index
		xor	si,si

	; process portamentos
	@@la22:	mov	bl,cs:PortSlide[si]
		or	bl,bl
		jz	@@lb11		; no slide for this channel
		call	GetFreq
		mov	ch,bl
		sar	cx,8		; sign extend 8bit->16bit
		add	ax,cx
		call	SetFreq

	; process volume slides
	@@lb11:	mov	ch,cs:VolSlide[si]
		mov	cl,cs:Old43[si]	; contains current volume
		and	cl,3fh
		xor	cl,3fh
		or	ch,ch
		jz	@@lc11
		jns	@@lba

		; slide volume up
		sub	cl,ch
		cmp	cl,64
		jb	@@lbb
		mov	cl,63
		jmp	@@lbb

		; slide volume down
	@@lba:	sub	cl,ch
		jns	@@lbb
		xor	cl,cl

	@@lbb:	mov	ch,cl
		mov	cl,bh		; channel to set
		call	SetVolume

	; process tone slides
	@@lc11:	cmp	cs:ToneSlide[si],0
		jz	@@lx11		; no tone slide
		mov	bl,cs:ToneSlideSpeed[si]	; shouldn't get wiped uc

		; get current absolute frequency
		call	GetFreq

		; sign extend speed/direction
		mov	dh,bl
		sar	dx,8

		; get destination frequency
		mov	cl,cs:ToneSlideFreqL[si]
		mov	ch,cs:ToneSlideFreqH[si]
		cmp	ax,cx
		jz	@@le11		; already at destination?!
		ja	@@ld11		; tone slide down (source > dest)

		; doing a tone slide up
		add	ax,dx
		cmp	ax,cx
		jb	@@lg11		; still under destination
		jmp	@@le11		; reached destination

		; doing a tone slide down
	@@ld11:	sub	ax,dx
		cmp	ax,cx
		ja	@@lg11		; still over destination

		; reached destination so stop tone slide
	@@le11:	mov	ax,cx		; clip it onto destination
		mov	cs:ToneSlide[si],0	; disables tone slide

		; write new frequency back to channel
	@@lg11:	call	SetFreq

	@@lx11:	inc	bh
		inc	si
		cmp	si,9
		jb	@@la22
		ret





;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Returns the current absolute frequency of channel
; IN:
;	SI	- channel
; OUT:
;	AX	- frequency
; USES:
;	CX, DX
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GetFreq:	mov	cl,cs:OldA0[si]
		mov	ch,cs:OldB0[si]
		and	ch,3		; mask to get high frequency
		sub	cx,FreqStart
		mov	al,cs:OldB0[si]
		shr	al,2
		and	ax,7		; mask to get octave
		mov	dx,FreqRange
		mul	dx
		add	ax,cx
		ret





;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Sets the channel's frequency
; IN:
;	AX	- absolute frequency
;	SI	- channel
; USES:
;	CX, DX
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetFreq:	mov	cx,FreqRange
		xor	dx,dx
		div	cx		; extracts octave in AX and freq. in DX
		add	dx,FreqStart

		mov	ah,cs:OldB0[si]
		and	ah,11100000b	; keep old toggles
		shl	al,2		; move octave to correct bit position
		or	al,ah		; insert octave
		or	al,dh		; insert high frequency
		mov	ah,bh
		add	ah,0b0h
		mov	cs:OldB0[si],al
		call	Adlib

		sub	ah,10h
		mov	al,dl		; low frequency
		mov	cs:OldA0[si],al
		jmp	Adlib





;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Load in instrument data into a given channel.
; IN:
;	CL	- channel to load instrument into (0..8)
;	DL	- instrument no. (1..31)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
LoadInst:	push	ax bx si

		mov	si,cx
		and	si,0ffh
		mov	ah,cs:ChannelOffs[si]	; Adlib register offsets

		xor	bx,bx
		mov	bl,dl
		dec	bx
		add	bx,bx
		mov	bx,cs:InstPtrs[bx]	; get instrument offset
		or	bx,bx
		jz	@@lx33		; no instrument data ?!

		mov	al,2[bx]
		mov	cs:Old43[si],al	; old 43.. value

		mov	dl,4

	@@la33:	mov	al,1[bx]
		call	Adlib		; load carrier
		add	ah,3
		mov	al,[bx]
		call	Adlib		; load modulator
		add	bx,2

		add	ah,20h-3
		dec	dl
		jnz	@@la33

		add	ah,40h		; do E0 range now
		mov	al,2[bx]
		call	Adlib
		add	ah,3
		mov	al,1[bx]
		call	Adlib

		mov	ah,0c0h
		add	ah,cl
		mov	al,[bx]
		call	Adlib

	@@lx33:	pop	si bx ax
		ret

ChannelOffs	db	20h,21h,22h,28h,29h,2ah,30h,31h,32h






;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Outputs a value to an ADLIB register.
; IN:
;	CL	- channel to set volume on
;	CH	- new volume
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetVolume:	push	ax bx

		xor	bx,bx
		mov	bl,cl

	; ensure volume is within range
		cmp	ch,64
		jb	@@la44
		mov	ch,63

	; get old 43.. value
	@@la44:	mov	al,cs:Old43[bx]
		and	al,0c0h		; mask out volume bits
		xor	ch,3fh
		or	al,ch		; insert volume
		mov	cs:Old43[bx],al	; keep new 43.. value

	; write new volume into Adlib
		mov	ah,cs:ChannelOffs[bx]
		add	ah,23h
		call	Adlib

		pop	bx ax
		ret





;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Outputs a value to an ADLIB register.
; IN:
;	AH	- register no.
;	AL	- value
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Adlib:
                push	ax dx

		mov	dx,cs:AdlibPort
		xchg	ah,al
		out	dx,al
		rept	6
		in	al,dx
		endm

		inc	dx
		mov	al,ah
		out	dx,al
		dec	dx
		mov	ah,22
	@@la55:	in	al,dx
		dec	ah
		jnz	@@la55

		pop	dx ax
		ret

AdlibPort	dw	388h		; default Adlib base port

InstPtrs	dw	31 dup (0)	; offsets of instrument data
Old43		db	9 dup (0)	; record of 43..   register values
OldA0		db	9 dup (0)	; record of A0..A8 register values
OldB0		db	9 dup (0)	; record of B0..B8 register values

ToneSlideSpeed	db	9 dup (1)	; speed of tone slide
ToneSlideFreqL	db	9 dup (?)	; destination frequency of tone slide
ToneSlideFreqH	db	9 dup (?)

ToneSlide	db	9 dup (?)	; tone slide flag
PortSlide	db	9 dup (?)	; portamento slide
VolSlide	db	9 dup (?)	; volume slide

ModSeg		dw	?	; segment of module (starts at offset 0)
Speed		db	?	; speed (n/50Hz) of tune
SpeedCnt	db	?	; counter used for deriving speed

OrderSize	dw	?	; no. of entries in Order List
OrderList	dw	?	; offset in module of Order List
OrderPos	dw	?	; current playing position in Order List

PatternList	dw	?	; offset of pattern offset table in module
PatternPos	dw	?	; offset to current line in current pattern
Line		db	?	; current line being played (usually +1)

end
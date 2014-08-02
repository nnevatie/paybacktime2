{       SBDSP is Copyright 1994 by Ethan Brodsky.  All rights reserved.      }
unit VOC;
    interface
        const
            EndBlockNum            = 0;
            VoiceBlockNum          = 1;
            VoiceContinueBlockNum  = 2;
            SilenceBlockNum        = 3;
            MarkerBlockNum         = 4;
            MessageBlockNum        = 5;
            RepeatBlockNum         = 6;
            RepeatEndBlockNum      = 7;
            ExtendedInfoBlockNum   = 8;
            NewVoiceBlockNum       = 9;
            BlockNames : array[0..9] of string =
                (
                 'Terminator',
                 'Voice Data',
                 'Voice Continuation',
                 'Silence',
                 'Marker',
                 'Message',
                 'Repeat Loop',
                 'End Repeat Loop',
                 'Extended Info',
                 'New Voice Data'
                );
            {Used in block type 1 and 8}
            Unpacked8  = 0; {8 bit (Uncompressed)}
            Packed4    = 1; {4 bit}
            Packed26   = 2; {2.6 bit}
            Packed2    = 3; {2 bit}
            PackingNames : array[0..10] of string =
                (
                 '8 bit unpacked',
                 '4 bit packed',
                 '2.6 bit packed',
                 '2 bit packed',
                 '1 channel multi',
                 '2 channel multi',
                 '3 channel multi',
                 '4 channel multi',
                 '5 channel multi',
                 '6 channel multi',
                 '7 channel multi'
                );
            {Used in block type 9}
            Uncompressed8     = $0000;
            Compressed4       = $0001;
            Compressed26      = $0002;
            Compressed2       = $0003;
            Uncompressed16    = $0004;
            CompressedALAW    = $0006;
            CompressedMULAW   = $0007;
            CompressedADPCM   = $0200; {Why couldn't they make this $0008?}
            CompressionNames : array[0..7] of string =
                (
                    '8 bit uncompressed',
                    '4 bit compressed',
                    '2.6 bit compressed',
                    '2 bit compressed',
                    '16 bit uncompressed',
                    '',
                    'ALAW compressed',
                    'MULAW compressed'
                );
            ExtendedMono   = 0;
            ExtendedStereo = 1;
            ExtendedModeNames : array[0..1] of string = ('Mono', 'Stereo');

            NewMono   = 1;      {This is Creative Labs' fault}
            NewStereo = 2;      {Blame it on Creative Labs}
            NewModeNames : array[1..2] of string = ('Mono', 'Stereo');
        type
            PSound = ^TSound;
            TSound = array[0..65520] of byte;

            PVOCHeader = ^TVOCHeader;
            TVOCHeader = array[1..26] of byte;

            TripleByte = array[1..3] of byte;

            PBlock = ^TBlock;
            TBlock =
                record
                    BlockType: byte;
                    BlockLength: TripleByte;
                end;

            PEndBlock = ^TEndBlock;
            TEndBlock =
                record
                    BlockType : byte;
                end;

            PVoiceBlock = ^TVoiceBlock;
            TVoiceBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    SR : byte;
                    Packing : byte;
                    Data : array[0..65520] of byte;
                end;

            PVoiceContinueBlock = ^TVoiceContinueBlock;
            TVoiceContinueBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Data : array[0..65520] of byte;
                end;

            PSilenceBlock = ^TSilenceBlock;
            TSilenceBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Duration : word;
                    SR : byte;
                end;

            PMarkerBlock = ^TMarkerBlock;
            TMarkerBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Marker : word;
                end;

            PMessageBlock = ^TMessageBlock;
            TMessageBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Data: array[0..65520] of char;
                end;

            PRepeatBlock = ^TRepeatBlock;
            TRepeatBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Count: word;
                end;

            PRepeatEndBlock = ^TRepeatEndBlock;
            TRepeatEndBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                end;
            PExtendedInfoBlock = ^TExtendedInfoBlock;
            TExtendedInfoBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    ExtendedSR : word;
                    Packing : byte;
                    Mode : byte; {0 = mono, 1 = stereo}
                end;
            PNewVoiceBlock = ^TNewVoiceBlock;
            TNewVoiceBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    SamplingRate : word; {HZ}
                    Dummy1 : array[1..2] of byte;
                    BitsPerSample : byte; {Uncompressed bits per sample}
                    Mode : byte; {1 = mono, 2 = stereo}
                    Compression: word;
                    Dummy2 : array[1..4] of byte;
                    Data : array[0..64000] of byte;
                end;
        function TripleByteToLongint(TB: TripleByte): LongInt;
        function GetSamplingRate(SR: byte): LongInt;
        function GetSRByte(SamplingRate: word): byte;
        function GetExtendedSamplingRate(ExtendedSR: word; Mode: byte): LongInt;
        function BlockSize(Block: PBlock): LongInt;
        procedure IncrementPtr(var P: pointer; Count: word);
        function FindNextBlock(Block: PBlock): PBlock;
        function LoadVOCFile(FileName: string; var Sound: PSound;fsize:word): LongInt;
    implementation
        uses
            vocmem;
        function TripleByteToLongint(TB: TripleByte): LongInt;
            begin
                TripleByteToLongint := LongInt(TB[1]) + LongInt(TB[2]) SHL 8 + LongInt(TB[3]) SHL 16;
            end;
        function GetSamplingRate(SR: byte): LongInt;
            begin
                GetSamplingRate := -1000000 div (SR - 256);
            end;
        function GetSRByte(SamplingRate: word): byte;
            begin
                GetSRByte := 256-(1000000 div SamplingRate);
            end;
        function GetExtendedSamplingRate(ExtendedSR: word; Mode: byte): LongInt;
            begin
                case Mode
                    of
                        ExtendedMono:
                            GetExtendedSamplingRate := -256000000 div (ExtendedSR-65536);
                        ExtendedStereo:
                            GetExtendedSamplingRate := (-256000000 div (ExtendedSR-65536)) div 2;
                    end;
            end;
        function BlockSize(Block: PBlock): LongInt;
            begin
                BlockSize := TripleByteToLongInt(Block^.BlockLength) + 4;
            end;
        procedure IncrementPtr(var P: pointer; Count: word);
          {Easier to implement in assembly}
            begin
                asm
                    LES  DI, P
                    MOV  BX, Count
                    MOV  AX, ES:[DI]
                    MOV  DX, ES:[DI+2]
                    ADD  AX, BX
                    CMP  AX, $000F
                    JNA  @1
                    MOV  BX, AX
                    AND  AX, $F
                    AND  BX, $FFF0
                    MOV  CL, 4
                    SHR  BX, CL
                    ADD  DX, BX
                  @1:
                    MOV  ES:[DI], AX
                    MOV  ES:[DI+2], DX
                end;
            end;
        function FindNextBlock(Block: PBlock): PBlock;
            var
                NewBlock: PBlock;
                BlockSize: LongInt;
            begin
                if Block^.BlockType = EndBlockNum
                    then
                        begin
                            FindNextBlock := nil;
                            Exit;
                        end;
                NewBlock := Block;
                BlockSize := TripleByteToLongInt(Block^.BlockLength) + 4;
                while BlockSize > 0 do
                    begin
                        if BlockSize > 64000
                            then
                                begin
                                    IncrementPtr(pointer(NewBlock), 64000);
                                    Dec(BlockSize, 64000);
                                end
                            else
                                begin
                                    IncrementPtr(pointer(NewBlock), BlockSize);
                                    BlockSize := 0;
                                end;
                    end;
                FindNextBlock := NewBlock;
            end;
        function LoadVOCFile(FileName: string; var Sound: PSound;fsize:word): LongInt;
           var
                f: file;
                Dummy: Pointer;
                LeftToRead: LongInt;
                Header: PVOCHeader;
            begin
(*                Assign(f, FileName);
                {$I-}
                Reset(f, 1);
                {$I+}
                if IOResult <> 0
                    then
                        begin
                            LoadVOCFile := 0; {Couldn't open file}
                            Exit;
                        end;
                LeftToRead := FileSize(f) - SizeOf(Header^);
                LoadVOCFile := LeftToRead;
                New(Header);
                BlockRead(f, Header^, SizeOf(Header^));

                if GetBuffer(pointer(Sound), LeftToRead) <> true
                    then
                        begin
                            LoadVOCfile := 0; {Failed to allocate memory}
                            Exit;
                        end;*)

                Dummy := Sound;
                lefttoread:=fsize;
                while LeftToRead > 0 do
                    begin
                        if LeftToRead < 64000
                            then
                                begin
                                    BlockRead(f, Dummy^, LeftToRead);
                                    LeftToRead := 0;
                                end
                            else
                                begin
                                    BlockRead(f, Dummy^, 64000);
                                    LeftToRead := LeftToRead - 64000;
                                    IncrementPtr(Dummy, 64000);
                                end;
                    end;
                Close(f);
{                Dispose(Header);}
            end;
    begin
    end.

{       SBDSP is Copyright 1994 by Ethan Brodsky.  All rights reserved.      }
unit vocmem;
    interface
        function GetBuffer(var Buffer: pointer; BufferLength: LongInt): boolean;
        procedure FreeBuffer(Buffer: pointer; BufferLength: LongInt);
        function GetAbsoluteAddress(p: pointer): LongInt;
    implementation
        function GetBuffer(var Buffer: pointer; BufferLength: LongInt): boolean;
            var
                Dummy: pointer;
            begin
                if MaxAvail < BufferLength
                    then
                        begin
                            GetBuffer := false;
                            Buffer := nil;
                            Exit;
                        end;
                GetBuffer := true;
                if BufferLength < $FFFF
                    then
                        GetMem(Buffer, BufferLength)
                    else
                        begin
                            GetMem(Buffer, $FFFF);
                            BufferLength := BufferLength - $FFFF;
                            while BufferLength > $FFFF do
                                begin
                                    GetMem(Dummy, $FFFF);
                                    BufferLength := BufferLength - $FFFF;
                                end;
                            GetMem(Dummy, BufferLength);
                        end;
            end;
        procedure FreeBuffer(Buffer: pointer; BufferLength: LongInt);
            var
                Dummy: pointer;
                LeftToFree: LongInt;
            begin
                if BufferLength < $FFFF
                    then
                        FreeMem(Buffer, BufferLength)
                    else
                        begin
                            Dummy := Buffer;
                            LeftToFree := BufferLength;
                            FreeMem(Buffer, $FFFF);
                            LeftToFree := LeftToFree - $FFFF;
                            Dummy := Ptr(Seg(Dummy^) + $1000, Ofs(Dummy^));
                            while LeftToFree > $FFFF do
                                begin
                                    FreeMem(Dummy, $FFFF);
                                    LeftToFree := LeftToFree - $FFFF;
                                    Dummy := Ptr(Seg(Dummy^) + $1000, Ofs(Dummy^));
                                end;
                            FreeMem(Dummy, LeftToFree);
                        end;
            end;
        function GetAbsoluteAddress(p: pointer): LongInt;
            begin
                GetAbsoluteAddress := LongInt(Seg(p^))*16 + LongInt(Ofs(p^));
            end;
    end.

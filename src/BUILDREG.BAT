rem deltree /Y \pt

del e:\pt\*.* /s /q
rd e:\pt /s /q

md e:\pt

xcopy *.* \pt\ /s
del e:\pt\*.pas
del e:\pt\*.tpu
del e:\pt\*.asm
del e:\pt\*.obj
del e:\pt\*.bat
del e:\pt\font.exe
del e:\pt\route*.exe
del e:\pt\tileconv.exe
del e:\pt\manconv.exe
del e:\pt\itemconv.exe
del e:\pt\depconv.exe
del e:\pt\chop.exe
del e:\pt\intropt.exe
del e:\pt\pcxconv.exe
del e:\pt\data\groups.da0
del e:\pt\register.txt
del e:\pt\install.exe
del e:\pt\ptbump.exe
del e:\pt\payback.cfg
del e:\pt\unmain.pic
del e:\pt\regmain.pic
del e:\pt\tilaus.txt
del e:\pt\orderfrm.txt
del e:\pt\register.*
del e:\pt\regist.lst
del e:\pt\revision.txt
del e:\pt\file_id.diz
del e:\pt\intro*.exe
del e:\pt\3ds*.exe
del e:\pt\logo.dat

md  e:\pt\dosexe

rem move e:\pt\3dgame.ovr e:\pt\dosexe
move e:\pt\mapconv*.* e:\pt\dosexe
rem move e:\pt\pt2.exe e:\pt\dosexe
rem move e:\pt\setup.exe e:\pt\dosexe
move e:\pt\transgrp.exe e:\pt\dosexe

cd\pt21

rem deltree /Y \pt2reg

del e:\pt2reg /s /q
rd e:\pt2reg /s /q

mkdir \pt2reg
cd\pt

rar a -sfx -r -y -m2 e:\pt2reg\pt.exe *.*
ren e:\pt2reg\pt.exe pt2.dat
copy e:\pt21\install.exe e:\pt2reg
cd\pt21

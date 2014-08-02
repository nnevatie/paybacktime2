ECHO OFF

ECHO                 - PT2 REGISTERED VERSION COMPILE -

e:\turbo\tpc 3dgame.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S- -$O+
e:\turbo\tpc pt2.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
e:\turbo\tpc grouped.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
e:\turbo\tpc weaponed.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
e:\turbo\tpc itemed.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
e:\turbo\tpc mapedit.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
e:\turbo\tpc install.pas -B -Ue:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-

call cop.bat
copy regmain.pic gfx\main.svf
copy data\groups.da0 data\groups.dat

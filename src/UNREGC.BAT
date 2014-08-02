
@ECHO OFF

ECHO                 - PT2 UNREGISTERED VERSION COMPILE -

tpc 3dgame.pas -B -Uc:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S- -$O+ -Dunregistered
tpc pt2.pas -B -Uc:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S- -Dunregistered
tpc grouped.pas -B -Uc:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S- -Dunregistered
rem tpc weaponed.pas -B -Uc:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
rem tpc itemed.pas -B -Uc:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
rem tpc mapedit.pas -B -Uc:\turbo -$A- -$D- -$E+ -$G+ -$I- -$L- -$N+ -$Q- -$R- -$S-
call cop.bat
copy unmain.pic gfx\main.svf


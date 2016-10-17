@ECHO OFF
ECHO *********************************
ECHO ** COMPILACAO PALM
ECHO ** Versao = %1
ECHO ** Idioma = %2
ECHO ** SDK    = %3
ECHO *********************************

IF %2 == 1 GOTO POR
IF %2 == 2 GOTO ENG
IF %2 == 3 GOTO SPA


:POR
@ECHO ON
C:\eadvpl\eadvpl.exe exemplo.prg -name="SFA-CRM" -TARGET=PALMOS -sdk=%3 -version=%1 -implib=sfacrm_palm5_1.a -g
GOTO FIM

:ENG
@ECHO ON
C:\eadvpl\eadvpl.exe exemplo.prg -name="SFA-CRM" -TARGET=PALMOS -sdk=%3 -version=%1 -implib=sfacrm_palm5_1.a -g -dENGLISH
GOTO FIM

:SPA
@ECHO ON
C:\eadvpl\eadvpl.exe exemplo.prg -name="SFA-CRM" -TARGET=PALMOS -sdk=%3 -version=%1 -implib=sfacrm_palm5_1.a -g -dSPANISH


:FIM
@ECHO OFF
Copy sfacrm.prc sfacrm_palm%3_%2.prc

@ECHO OFF
ECHO *********************************
ECHO ** COMPILACAO PALM
ECHO ** Versao = %1
ECHO ** Idioma = %2
ECHO *********************************

IF %2 == 1 GOTO POR
IF %2 == 2 GOTO ENG
IF %2 == 3 GOTO SPA


:POR
@ECHO ON
C:\eadvpl\eadvpl.exe exemplo.prg -name="SFA-CRM" -TARGET=POCKETPC -CPU=ARM -version=%1 -implib=sfacrm_arm_1.lib -g
GOTO FIM

:ENG
@ECHO ON
C:\eadvpl\eadvpl.exe exemplo.prg -name="SFA-CRM" -TARGET=POCKETPC -CPU=ARM -version=%1 -implib=sfacrm_arm_1.lib -g -dENGLISH
GOTO FIM

:SPA
@ECHO ON
C:\eadvpl\eadvpl.exe exemplo.prg -name="SFA-CRM" -TARGET=POCKETPC -CPU=ARM -version=%1 -implib=sfacrm_arm_1.lib -g -dSPANISH


:FIM
@ECHO OFF
Copy sfacrm.exe sfacrm_arm_%2.exe

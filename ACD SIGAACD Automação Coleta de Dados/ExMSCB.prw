#INCLUDE "RWMAKE.CH"

User Function TESTE()

    U_ZEBRA()
    ALERT("ENVIADO ZEBRA")

    U_ALLEGRO()
    ALERT("ENVIADO ALLEGRO")

    U_ELTRON()
    ALERT("ENVIADO ELTRON")

Return


User Function ZEBRA()
Local nX
Local cPorta
/*
cPorta := "COM2:9600,n,8,1"
cPorta := "COM2:9600,n,8,2"
cPorta := "COM2:9600,n,7,1"
cPorta := "COM2:9600,n,7,2"
cPorta := "COM2:9600,e,8,1"
cPorta := "COM2:9600,e,8,2"
cPorta := "COM2:9600,e,7,1"
cPorta := "COM2:9600,e,7,2"
*/

cPorta := "9100"

MSCBPRINTER("S400",cPorta,,,.f.)//,,,,,"/TESTE") 
MSCBCHKStatus(.f.)
MSCBLOADGRF("SIGA.GRF")
For nx:=1 to 1
   MSCBBEGIN(1,6)                            
   MSCBBOX(02,01,76,35)
   MSCBLineH(30,05,76,3) 
   MSCBLineH(02,13,76,3,"B") 
   MSCBLineH(02,20,76,3,"B") 
	MSCBLineV(30,01,13)
	MSCBGRAFIC(2,3,"SIGA")                   
	MSCBSAY(33,02,'PRODUTO',"N","0","025,035") 
	MSCBSAY(33,06,"CODIGO","N","A","015,008")
	MSCBSAY(33,09, "000006", "N", "0", "032,035") 
	MSCBSAY(05,14,"DESCRICAO","N","A","015,008")
	MSCBSAY(05,17,"IMPRESSORA ZEBRA S500-8","N", "0", "020,030")
	MSCBSAYBAR(23,22,"00000006","N","C",8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)
	MSCBEND()
Next	
MSCBCLOSEPRINTER()
Return 

User Function ALLEGRO()
Local nX
Local cPorta

cPorta := "LPT1"
MSCBPRINTER("ALLEGRO",cPorta,,,.f.,,,,,"/TESTE") 
MSCBLOADGRF("SIGA.BMP")
For nx:=1 to 3
   MSCBBEGIN(1,6)                            
   MSCBBOX(02,01,76,34,1)    
   MSCBLineH(30,30,76,1) 
   MSCBLineH(02,23,76,1) 
   MSCBLineH(02,15,76,1) 
	MSCBLineV(30,23,34,1)
	MSCBGRAFIC(2,26,"SIGA")                   
	MSCBSAY(33,31,'PRODUTO',"N","2","01,01") 
	MSCBSAY(33,27,"CODIGO","N","2","01,01")
	MSCBSAY(33,24, "000006", "N", "2", "01,01") 
	MSCBSAY(05,20,"DESCRICAO","N","2","01,01")
	MSCBSAY(05,16,"IMPRESSORA ALLEGRO 2 BR","N", "2", "01,01")
	MSCBSAYBAR(22,03,"00000006","N","E",8.36,.F.,.T.,.F.,,3,2,.F.,.F.,"1",.T.)
	MSCBEND()
Next	
MSCBCLOSEPRINTER()
Return 


User Function ELTRON()
Local nX
Local cPorta

cPorta := "LPT1"
MSCBPRINTER("ELTRON",cPorta,,,.f.,,,,,"/TESTE") 
MSCBCHKStatus(.f.)
CDMSCBLOADGRF("SIGA.PCX")
For nx:=1 to 3
   MSCBBEGIN(1,6)                            
	MSCBGRAFIC(04,02,"SIGA")                   
   MSCBBOX(05,01,76,30,2)
   MSCBLineH(30,06,71,2) 
   MSCBLineH(05,12,71,2) 
   MSCBLineH(05,18,71,2) 
	MSCBLineV(30,1,1.3,90) //Monta Linha Vertical
	MSCBSAY(33,02,'PRODUTO',"N","2","1,2") 
	MSCBSAY(33,07,"CODIGO", "N", "1", "1,1") 
	MSCBSAY(33,09,"000006", "N", "1", "1,2") 
	MSCBSAY(07,13,"DESCRICAO","N","1","1,1")
	MSCBSAY(07,15,"IMPRESSORA ELTRON TLP2742","N", "1", "1,2")
	MSCBSAYBAR(28,19,"00000006",'N','1',50,.T.,,,,2,2,,,,)
	MSCBEND()
Next	
MSCBCLOSEPRINTER()
Return 

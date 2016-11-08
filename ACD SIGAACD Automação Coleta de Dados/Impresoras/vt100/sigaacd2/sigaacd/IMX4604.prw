#include "protheus.ch"

//Autor: Marco Olvera C.
//email: molvera@ideas.mx
//Fecha de creación: 2015/05/20
//Fecha de revisión:
//Versión: 0
//Tipo: Conexion
//Uso : Impresion de Etiquetas en Zebra
User Function IMX4604()
	Private	nCantEti		:=	1
	Private	cDescripcion	:=	space(30)	
	Private cProd			:=	space(30)
	Private nCantItem		:=	0  //Cantidad de articulos contenidos en la unidad logistica
	Private cGTIN			:=	space(13)	//Numero Global de Articulo Comercial (GTIN)
	Private cLote			:=	space(20)	//Numero de Lote
	Private dFecha			:=	dDatabase + 365
	Private	nPrinter		:=	1
	Private oDialog
	Private oCantEti, oProd, oDescripcion, oCantItem, oGTIN, oLote, oFecha, oPrinter
	Private oButton1, oButton2                   
	
	DEFINE MSDIALOG oDialog TITLE "Impresión de etiquetas" from 0,0 to 300,310 PIXEL 
		@01,01 SAY "Cantidad Etiquetas"
		@02,01 SAY "Codigo"
		@03,01 SAY "Descripción"
		@04,01 SAY "GTIN 13"
		@05,01 SAY "Cant. de artículos"
		@06,01 SAY "Lote"
		@07,01 SAY "Consumo preferente"
		@08,01 SAY "Impresora"
		@01,10 MSGET oCantEti VAR nCantEti SIZE 20, 010 OF oDialog WHEN .T.
		@02,10 MSGET oProd VAR cProd F3 "SB1" SIZE 70, 010 OF oDialog WHEN .T. VALID descripcion()
		@03,10 MSGET oDescripcion VAR cDescripcion SIZE 70, 010 OF oDialog WHEN .F.
		@04,10 MSGET oGTIN VAR cGTIN SIZE 70, 010 OF oDialog WHEN .F.
		@05,10 MSGET oCantItem VAR nCantItem SIZE 40, 010 OF oDialog PICTURE "@E 999999" WHEN .T.
		@06,10 MSGET oLote VAR cLote SIZE 70, 010 OF oDialog WHEN .T.
		@07,10 MSGET oFecha VAR dFecha SIZE 70, 010 OF oDialog WHEN .T.
		@08,10 MSGET oPrinter VAR nPrinter SIZE 10, 010 OF oDialog WHEN .T.
		@13,25 BUTTON oButton1 PROMPT "Imprimir" SIZE 40, 10 OF oDialog ACTION imprimir()
	ACTIVATE MSDIALOG oDialog CENTERED
Return                                                                                       

Static Function descripcion()
	Local	cQry	:=	""
	Local	cSql	:=	"PT001"
	
	cQry := " SELECT B1_DESC, B1_CODBAR"
	cQry += " FROM " + retSqlName("SB1") + " SB1"
	cQry += " WHERE B1_COD = '" + cProd + "'"
	cQry += " AND SB1.D_E_L_E_T_ = ' '"
	dbUseArea(.T., "TOPCONN", TcGenQry(, , cQry), cSql, .T., .T.)
	If .Not. (cSql)->(eof())
		cDescripcion	:=	(cSql)->B1_DESC
		cGTIN			:=	(cSql)->B1_CODBAR
	Else 
		alert("No se encontro el archivo.")
	End If
	(cSql)->(dbCloseArea())
Return(.T.)

Static Function IMPRIMIR()
	Local	cCodigo		:=	""
	Local	cPort		:=	""
	Local	cBuffer 	:=	""
	Local	nResult 	:=	0
	Local	oSocket 	:=	tSocketClient():New()
	Local	cConfig		:=	""
	Local	lConnect	:=	.F.
	Local	nHandler	:=	0
	Local	nStep		:=	0
	Local	cValor		:=	""
	Local	nCantidad	:=	0
	
	
	If len(allTrim(cGTIN)) == 12
		cCodigo	:=	allTrim(cGTIN)
	ElseIf len(allTrim(cGTIN)) == 13
		cCodigo	:=	allTrim(cGTIN) + eanDigito(allTrim(cGTIN))
	Else
		alert("Código GTIN inválido.")
		Return
	End If
	
	If nPrinter == 0
		cPort		:=	superGetMv("MV_IMX4605", .F., "192.168.1.140")
	    nResult		:=	oSocket:Connect(9100, allTrim(cPort), 60)
	ElseIf nPrinter == 1
		cPort		:=	superGetMv("MV_IMX4606", .F., "COM3")
		cConfig		:=	allTrim(cPort) + ":9600,n,8,1"
		lConnect	:=	msOpenPort(nHandler, cConfig)
	End If

    If oSocket:IsConnected() .Or. lConnect
		cBuffer +="^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR5,5~SD15^JUS^LRN^CI0^XZ"
//Definicion del Grafico		
		cBuffer +="~DG000.GRF,03584,028,
		cBuffer +=",:::::::::::::::::::::::::gO02,gO0780,gO0H80,gN07070,gN0E038,gM07C01F,gM0B800F80,gI01547F0H07F454,gI02FAFE0H03FAFE,gI07FHFC0H01FIF,gI0JF80I07FHF80,gH07FIFK07FIF0,gH07FHFC0K0JF0,gG01FIFM07FHFC,gG01FFE0N03FFE,gG07FFC0N017FF,gG0HFE0P03FF80,g01FFC0P01FFC0,g03FF80Q0HFE0,g07FF0R07FFC,g0HFE0R03FFC,Y03FHFS03FHF,Y07FFC0R01FHF80,X01FHFC0R01FHFC0,X03FHF80S07FFE0,X07F5F0T07D7F0,X0F8080U080F8,W01F0g07E,W0380gG0E,V01F0gH0780,V0180gI0C0,V070gJ070,V0E0gJ038,U0180gJ01C,,::::M07F4,L02EBA0gN08,L070170S010R01C,L0E00380R030R018,K01E001C0R070R07C,L0E0H080R070R03E,K01C0H0C0R070R07F,K01C0V070R07E,K01E0H040R070R05F0P04,L0E0K02A0J020H0F80H02A0L08F0J02A0I0A,K01F0J01FFC07C7FD07FFC01FFC0J018F801F97FC01FFD0,L0F80I0381E00EE0F00F800383E0J01878003983C0180F0,L07F0I0701F01FC07C070H0701F0J0107C007F05E03C078,L03F80H0600F00F0038070H0600E0J0303C003E00E030038,L01FC0H0400700F007C070H0400F0J0303C001C01F01003C,M0HFL0380E003C070K0B0J0203E001C00F0I038,M07FC0J07007007C070K070J0601F005C0070I07C,N0FE0J0780E003C070K0780I0400E003C00F0I03C,N07F0J07817003C070K070J0C01F001C0070I01C,N01F80H0AF80E003C0F0J0AF80I0800F001C00F0H02B8,N01FC05FHFC07003C070H05FHF40H01C407801C007007FFC,O03E03E0380E003C070H03E0780H01FIF803C00F01E03C,K010H01E07C07807003C070H078070I01D5D7C01C00703C01C,O01E0F00380E003C070H0F00380H020H03801C00B038038,K010H01E1F407807007C07001F4070I070H03C05C00707C03C,K0180H0E0E00380E003C070H0E00780H060H03E03C00F03803C,K018001C1F007817003C07001F00780H040H01F01C00707801C,K018001C0F00380E003C07800E00780H080I0E01800F038038,K01C001C0F00FC07003C07C00F01F40H0C0I0F01C00707C07C,L0E00380781F80E003C03800783F80H080I0783C00F03E0FC,L07D1F007FF380F003C03D707FF3800180I01D1C00F01FF9C,M0HF80H0F808020H0800F800F80P0A080J03E08,M0H5J040P040H040g04,,::::V0H5H0H5H01D50018050J0750H0540,V0808030E00C380080180I080I0820,U01C0C03070041C01C01C0401C0401010,V080H030300C0800800E0H03002010,U01C0H01030041C01801704030I018,V0E0H030300C080080030H020J08,V070H03070045C01C011C4070J0F,V0380030600E20H0802080020J0380,V01F0011C005C0018010C407007001C0,W0380380H0860H080H060020020H030,W01C030I047001C01074070060H070,X08030I0C20H0802038020020H018,U0101C010I04100180101C0100601018,V0808030I0C080080I0C008020H018,V0C14030I041C01C010040040601C70,V0H2H020K020020L0H2800220,V010gK01,,:::::::"
		cBuffer +="^XA"
		cBuffer +="^MMT"
		cBuffer +="^PW812"
		cBuffer +="^LL1218"
		cBuffer +="^LS0"                        
//Codigo de barras 1
		cBuffer +="^FT115,850,0"
		cBuffer +="^A0N,32,31^FH\^FD(01)" + cCodigo + "(37)" + strZero(nCantItem, 6) + "^FS"
		cBuffer +="^BY3,3,140"
		cBuffer +="^FT115,820^BCN,,N,N"
		cBuffer +="^FD>;>801" + cCodigo + "37" + strZero(nCantItem, 6) + "^FS"
//Codigo de barras 2
		cBuffer +="^FT115,1100,0"
		cBuffer +="^A0N,32,31^FH\^FD(15)" + subStr(dTos(dFecha), 3, 6) + "(10)" + cLote + "^FS"
		cBuffer +="^BY3,3,140"
		cBuffer +="^FT115,1070"
		cBuffer +="^BCN,,N,N"
		cBuffer +="^FD>;>815" + subStr(dTos(dFecha), 3, 6) + "10" + cLote + "^FS"
//Grafico		
		cBuffer +="^FT295,160^XG000.GRF,1,1^FS"
//Rectangulo
		cBuffer +="^FO30,35"
		cBuffer +="^GB770,561,8^FS"  
//Lineas Horizontales		
		cBuffer +="^FO30,493^GB770,0,8^FS"
		cBuffer +="^FO30,364^GB770,0,8^FS"
		cBuffer +="^FO30,276^GB770,0,8^FS"
		cBuffer +="^FO30,188^GB770,0,8^FS"	
		cBuffer +="^FT50,406^A0N,28,28^FH\^FDCantidad de Articulos:^FS"
		cBuffer +="^FT475,406^A0N,28,28^FH\^FDF. CONSUMO PREFERENTE^FS"
		cBuffer +="^FT50,471^A0N,54,55^FH\FS"   
		cBuffer +="^FD" + strZero(nCantItem, 6) + "^FS"   		//Cantidad de Articulos
		cBuffer +="^FT50,561^A0N,54,55^FH\"
		cBuffer +="^FDLote: " + cLote + "^FS"	//Lote
		cBuffer +="^FT528,471^A0N,54,55^FH\
		cBuffer +="^FD" + dToC(dFecha) + "^FS"			//Consumo Preferente
		cBuffer +="^FT50,344^A0N,54,55^FH\"
		cBuffer +="^FDGTIN: " + cGTIN  + "^FS" 	//GTIN
		cBuffer +="^FT50,256^A0N,54,55^FH\"
		cBuffer +="^FD" + cDescripcion + "^FS" //Descripcion   
		cBuffer +="^FO446,364^GB0,137,8^FS"
		cBuffer +="^PQ" + allTrim(str(nCantEti)) + ",0,1,Y^XZ"
		cBuffer +="^XA^ID000.GRF^FS^XZ"
		If nPrinter == 0
			nResult := oSocket:Send(cBuffer)
			nResult := oSocket:CloseConnection()
		ElseIf nPrinter == 1
			msWrite(nHandler, cBuffer)
			msClosePort(nHandler)
		End If
	End If
Return
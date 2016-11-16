#include "protheus.ch"

//Autor: Cuauhtémoc Olvera C.
//email: quau@ideas.mx
//Fecha de creación: 2016/03/11
//Fecha de revisión 1: 2016/03/14
//Fecha de revisión 2: 2016/03/23
//Versión: 2
//Uso : Pick-List
User Function IMX4607()
	Local	cPedido	:=	space(6)
	Local	dialogMain, textPedido, buttonPrint
	Private	cTitle	:=	"Pick-List"
	DEFINE MSDIALOG dialogMain TITLE cTitle FROM 000, 000 TO 150, 250 PIXEL
	@010, 010 SAY "Pedido:" SIZE 050, 010 OF dialogMain PIXEL
	@008, 040 MSGET textPedido VAR cPedido SIZE 060, 010 WHEN .T. OF dialogMain PIXEL
	@030, 050 BUTTON buttonPrint PROMPT "Imprimir" SIZE 040, 020 WHEN .T. ACTION U_IMX4607A(cPedido) OF dialogMain PIXEL
	ACTIVATE MSDIALOG dialogMain CENTERED
return

//Imprimir
User Function IMX4607A(cPedido)
	Local	aCliente	:=	{"", "", "", "", "", ""}
	Local	aUser		:=	{"", "", ""}
	Local	cDocumento	:=	""
	Local	cQuery		:=	""
	Local	cDatos		:=	"IMX4607A"
	Local	nLinea		:=	0
	Local	nCount		:=	0
	Local	nStep		:=	1
	Local	fontSR		:=	TFont():New("Courier new", , -12, .T., .F.)
	Local	cPagina		:=	""
	Private cClase		:=	""
	Private	cNotas		:=	""
	Private nPagina		:=	0
	Private	nTotal		:=	0
	Private	nPiezas		:=	0
	Private	nPeso		:=	0
	Private	oPrint
    
    oPrint := TMSPrinter():new(cTitle)
    oPrint:SetPortrait()
    
    cQuery	:=	" SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_MENNOTA, C5_XCLAVEN"
    cQuery	+=	" FROM " + retSqlName("SC5") + " SC5"
    cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
    cQuery	+=	" AND C5_NUM = '" + cPedido + "'"
    dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
    If .Not. (cDatos)->(eof())
    	aCliente[1]	:=	padR(allTrim((cDatos)->C5_CLIENTE), tamSX3("A1_COD")[1])
    	aCliente[2]	:=	padR(allTrim((cDatos)->C5_LOJACLI), tamSX3("A1_LOJA")[1])
    	cDocumento	:=	(cDatos)->C5_NUM
    	cClase		:=	(cDatos)->C5_XCLAVEN
    	cNotas		:=	(cDatos)->C5_MENNOTA
    	(cDatos)->(dbCloseArea())
    Else
    	(cDatos)->(dbCloseArea())
    	iw_MsgBox("El pedido " + cPedido + " es invalido.", "Módulo RF", "EXCLAM")
    	return
    End If
    
    dbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    SA1->(dbGoTop())
    If SA1->(dbSeek(xFilial("SA1") + aCliente[1] + aCliente[2]))
    	aCliente[3]	:=	allTrim(SA1->A1_NOME)
		aCliente[4]	:=	allTrim(SA1->A1_END) + ", " + allTrim(SA1->A1_BAIRRO)
		aCliente[5]	:=	allTrim(SA1->A1_MUN) + ", " + allTrim(SA1->A1_ESTADO) + ", CP " + allTrim(SA1->A1_CEP)
		aCliente[6]	:=	"TEL: " + allTrim(SA1->A1_TEL)
	End If
	
	cQuery	:=	" SELECT DC_LOCALIZ, DC_PRODUTO, DC_LOTECTL, DC_QUANT, B1_DESC"
    cQuery	+=	" FROM " + retSqlName("SDC") + " SDC, " + retSqlName("SB1") + " SB1"
    cQuery	+=	" WHERE SDC.D_E_L_E_T_ = ' '"
    cQuery	+=	" AND SB1.D_E_L_E_T_ = ' '"
    cQuery	+=	" AND B1_COD = DC_PRODUTO"
    cQuery	+=	" AND DC_PEDIDO = '" + cPedido + "'"
    cQuery	+=	" ORDER BY DC_LOCALIZ, DC_LOTECTL, DC_PRODUTO"	
    dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
    Do While .Not. (cDatos)->(eof())
    	nCount	+=	1
    	(cDatos)->(dbSkip())
    End
    (cDatos)->(dbCloseArea())
    
    //Páginas
    cPagina	:=	allTrim(str((nCount / 50)))
    nTotal	:=	val(strToKarr(cPagina, ".")[1])
    If nCount % 50 > 0
    	nTotal	+=	iIf(nCount % 50 < 35, 1, 2)
    Else
    	nTotal	+=	1
    End If
    nPagina	:=	1
    nCount	:=	0
    
    dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
    Do While .Not. (cDatos)->(eof())
    	//Encabezado
    	If nLinea	== 0
    		nLinea	:=	U_IMX4607B(cDocumento, aCliente)
    		loop
    	End If
    	
    	//Detalle
    	oPrint:Say(nLinea, 0050, allTrim((cDatos)->DC_LOCALIZ), fontSR)
		oPrint:Say(nLinea, 0350, padR(allTrim((cDatos)->DC_PRODUTO), 13), fontSR)
    	oPrint:Say(nLinea, 0750, padL(allTrim(transform((cDatos)->DC_QUANT, "9999")), 4), fontSR)
    	oPrint:Say(nLinea, 0930, subStr((cDatos)->B1_DESC, 1, 50), fontSR)
    	nPiezas	+=	(cDatos)->DC_QUANT
    	
    	//Pie de página
    	If nLinea	>= 3000
    		nLinea	:=	U_IMX4607C()
    		nCount	:=	0
    	Else
    		nCount	+=	1
    		nLinea	+=	40
    	End If
    	
    	(cDatos)->(dbSkip())
    End
    (cDatos)->(dbCloseArea())
    
    //Total
    If nCount > 35
    	//Pie de página
    	nLinea	:=	U_IMX4607C()
    	//Encabezado
    	nLinea	:=	U_IMX4607B(cDocumento, aCliente)
    	//Totales
    	nLinea	:=	U_IMX4607D(nLinea)
    Else
    	//Totales
    	nLinea	:=	U_IMX4607D(nLinea)
    End If
    
    //Termina la última página
    If nLinea > 0 .And. nLinea < 3000
    	nLinea	:=	U_IMX4607C()
    End If
    
    oPrint:Setup()
    oPrint:Preview()
Return

//Page Header
User Function IMX4607B(cDocumento, aCliente)
	Local	aNotas	:=	strToKarr(cNotas, " ")
	Local	aNotas2	:=	{"", "", "", ""}
	Local	fontOUP	:=	TFont():New("Times New Roman", , -20, .T., .F.)
	Local	fontXLB	:=	TFont():New("Tahoma", , -36, .T., .T.)
	Local	fontLB	:=	TFont():New("Tahoma", , -24, .T., .T.)
	Local	fontMR	:=	TFont():New("Tahoma", , -18, .T., .F.)
	Local	fontSB	:=	TFont():new("Tahoma", , -14, .T., .T.)
	Local	fontSR	:=	TFont():new("Tahoma", , -12, .T., .F.)
	Local	nLength	:=	17
	Local	nResult	:=	100
	Local	nStep	:=	50
	Local	i		:=	0
	
	For i := 1 To len(aNotas)
		If len(aNotas2[1]) <= nLength .And. (len(aNotas2[1]) + len(aNotas[i])) <= nLength
			aNotas2[1] += aNotas[i] + " "
		ElseIf len(aNotas2[2]) <= nLength .And. (len(aNotas2[2]) + len(aNotas[i])) <= nLength
			aNotas2[2] += aNotas[i] + " "
		ElseIf len(aNotas2[3]) <= nLength .And. (len(aNotas2[3]) + len(aNotas[i])) <= nLength
			aNotas2[3] += aNotas[i] + " "
		ElseIf len(aNotas2[4]) <= nLength .And. (len(aNotas2[4]) + len(aNotas[i])) <= nLength
			aNotas2[4] += aNotas[i] + " "
		End If
	Next
	
    oPrint:StartPage()
    oPrint:Say(nResult, 0350, "OXFORD UNIVERSITY PRESS MEXICO, S. A. DE C. V.", fontOUP)
    nResult	+=	100
    oPrint:Say(nResult, 0850, cTitle, fontXLB)
    nResult	+=	200
    oPrint:Say(nResult, 0060, "Pedido:", fontSB)
    oPrint:Say(nResult, 0350, cDocumento, fontSR)
    oPrint:Say(nResult, 1700, "Clase:", fontSB)
    oPrint:Say(nResult, 1900, cClase, fontSR)
    nResult	+=	nStep
    oPrint:Say(nResult, 0060, "Cliente:", fontSB)
    oPrint:Say(nResult, 0350, subStr(aCliente[3], 1, 50), fontSR)
    oPrint:Say(nResult, 1700, "Notas:", fontSB)
    oPrint:Say(nResult, 1900, aNotas2[1], fontSR)
    nResult	+=	nStep
    oPrint:Say(nResult, 0350, subStr(aCliente[4], 1, 50), fontSR)
    oPrint:Say(nResult, 1900, aNotas2[2], fontSR)
    nResult	+=	nStep
    oPrint:Say(nResult, 0350, subStr(aCliente[5], 1, 50), fontSR)
    oPrint:Say(nResult, 1900, aNotas2[3], fontSR)
    nResult	+=	nStep
    oPrint:Say(nResult, 0350, subStr(aCliente[6], 1, 50), fontSR)
    oPrint:Say(nResult, 1900, aNotas2[4], fontSR)
    nResult	+=	100
    oPrint:Line(nResult, 10, nResult, 2400)
    nResult	+=	10
    //Columnas
    oPrint:Say(nResult, 0020, "Ubicación", fontSB)
	oPrint:Say(nResult, 0420, "ISBN", fontSB)
	oPrint:Say(nResult, 0750, "Cant.", fontSB)
	oPrint:Say(nResult, 1100, "Título", fontSB)

    nResult	+=	70
    oPrint:Line(nResult, 10, nResult, 2400)
Return nResult

//Page Footer
User Function IMX4607C()
	Local	cTimeStamp	:=	""
	Local	fontSR		:=	TFont():New("Courier new", , -12, .T., .F.)
	Local	nResult		:=	2900
	cTimeStamp	:=	subStr(dToC(date()), 7, 4) + "-" + subStr(dToC(date()), 4, 2) + "-" + subStr(dToC(date()), 1, 2)
	cTimeStamp	+=	" " + subStr(time(), 1, 5)
	oPrint:Say(nResult, 0050, "Surtidor.......      __________________________", fontSR)    
	oPrint:Say(nResult, 1400, "Fecha y Hora     ____________________________", fontSR)
	nResult += 70
	oPrint:Say(nResult, 0050, "Empacador.......     __________________________", fontSR)    
	oPrint:Say(nResult, 1400, "Fecha y Hora     ____________________________", fontSR)
	nResult += 130
    oPrint:Say(nResult, 0020, cTimeStamp, fontSR)
    oPrint:Say(nResult, 1000, "Página " + allTrim(str(nPagina)) + " de " + allTrim(str(nTotal)), fontSR)
    oPrint:EndPage()
    nPagina	+=	1
    nCount	:=	0
    nResult	:=	0
Return nResult

//Totales
User Function IMX4607D(nPos)
	Local	nResult	:=	nPos + 80
	Local	fontSB	:=	TFont():new("Tahoma", , -14, .T., .T.)
	Local	nWeight	:=	3
	Local	i		:=	0
	For i := 1 To nWeight
		oPrint:Line(nResult, 10, nResult, 2400)
	Next
	oPrint:Line(nResult, 10, nResult, 2400)
	nResult	+=	10
	oPrint:Say(nResult, 0500, "Total Ítems", fontSB)
	nResult	+=	60
	oPrint:Say(nResult, 0580, allTrim(transform(nPiezas, "999999")), fontSB)
	nResult	+=	80
	For i := 1 To nWeight
		oPrint:Line(nResult, 10, nResult, 2400)
	Next
	nResult	+=	20
	For i := 1 To nWeight
		oPrint:Line(nResult, 10, nResult, 2400)
	Next
Return (nResult)
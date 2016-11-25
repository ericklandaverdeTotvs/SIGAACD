#include "protheus.ch"

//Autor: Cuauhtémoc Olvera C.
//email: quau@ideas.mx
//Fecha de creación: 2016/03/11
//Fecha de revisión 1: 2016/03/14
//Fecha de revisión 2: 2016/03/23
//Versión: 2
//Uso : Lista de empaque
User Function IMX4608()
	Local	cPedido	:=	space(6)
	Local	dialogMain, textPedido, textoContenido, buttonPrint, buttonSave
	Private	cTitle		:=	"Lista de empaque"
	Private	cContenido	:=	space(250)
	DEFINE MSDIALOG dialogMain TITLE cTitle FROM 000, 000 TO 250, 350 PIXEL
	@010, 010 SAY "Pedido:" SIZE 050, 010 OF dialogMain PIXEL
	@025, 010 SAY "Contenido:" SIZE 050, 010 OF dialogMain PIXEL
	@008, 040 MSGET textPedido VAR cPedido SIZE 060, 010 WHEN .T. VALID load(cPedido) OF dialogMain PIXEL
	@026, 040 GET textContenido VAR cContenido SIZE 130, 070 WHEN .T. MULTILINE OF dialogMain PIXEL
	@100, 130 BUTTON buttonPrint PROMPT "Imprimir" SIZE 040, 020 WHEN .T. ACTION U_IMX4608A(cPedido) OF dialogMain PIXEL
	@100, 010 BUTTON buttonSave PROMPT "Guardar" SIZE 040, 020 WHEN .T. ACTION save(cPedido, cContenido) OF dialogMain PIXEL
	ACTIVATE MSDIALOG dialogMain CENTERED
return

static Function load(cPedido)
	Local	lResult	:=	.F.
	Local	cQuery	:=	""
	Local	cDatos	:=	getNextAlias()
	If .Not. empty(cPedido)
		cQuery	:=	" SELECT Z3_WHDPACK"
		cQuery	+=	" FROM " + retSqlName("SZ3") + " SZ3, " + retSqlName("SZ1") + " SZ1"
		cQuery	+=	" WHERE SZ3.D_E_L_E_T_ = ' '"
		cQuery	+=	" AND SZ1.D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z1_FILIAL = '" + xFilial("SZ1") + "'"
		cQuery	+=	" AND Z1_SERIE = 'PK'"
		cQuery	+=	" AND Z1_DOCORI	= '" + cPedido + "'"
		cQuery	+=	" AND Z3_SERIE = Z1_SERIE"
		cQuery	+=	" AND Z3_FOLIO = Z1_FOLIO"
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			lResult		:=	.T.
			cContenido	:=	(cDatos)->Z3_WHDPACK
		End If
		(cDatos)->(dbCloseArea())
	End If
	
return lResult

static function save(cPedido, cContenido)
	Local	cQuery	:=	""
	Local	cDatos	:=	getNextAlias()
	If empty(cPedido)
		iw_MsgBox("Pedido inválido.", cTitle, "ERROR")
	Else
		cQuery	:=	" SELECT Z1_SERIE, Z1_FOLIO"
		cQuery	+=	" FROM " + retSqlName("SZ1")
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z1_FILIAL = '" + xFilial("SZ1") + "'"
		cQuery	+=	" AND Z1_SERIE = 'PK'"
		cQuery	+=	" AND Z1_DOCORI	= '" + cPedido + "'"
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			cQuery	:=	" UPDATE " + retSqlName("SZ3") + " SET"
			cQuery	+=	" Z3_WHDPACK = '" + cContenido + "'"
			cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
			cQuery	+=	" AND Z3_FILIAL = '" + xFilial("SZ3") + "'"
			cQuery	+=	" AND Z3_SERIE = 'PK'"
			cQuery	+=	" AND Z3_FOLIO = " + allTrim(str((cDatos)->Z1_FOLIO))
			If tcSqlExec(cQuery) < 0
				conOut(tcSqlError())
			End If
		Else
			iw_MsgBox("No se encontró el archivo.", cTitle, "ERROR")
		End If
		(cDatos)->(dbCloseArea())
	End If
return

//Imprimir
User Function IMX4608A(cPedido)
	Local	aCliente	:=	{"", "", "", "", "", ""}
	Local	aUser		:=	{"", "", ""}
	Local	cDocumento	:=	""
	Local	cQuery		:=	""
	Local	cDatos		:=	getNextAlias()
	Local	nLinea		:=	0
	Local	nCount		:=	0
	Local	nStep		:=	1
	Local	fontSR		:=	TFont():New("Courier new", , -12, .T., .F.)
	Local	cPagina		:=	""
	Private cPT			:=	superGetMv("MV_IMX4612", .F., "PA")
	Private	cME			:=	superGetMv("MV_IMX4613", .F., "EM")
	Private	cPV			:=	superGetMv("MV_IMX4614", .F., "PV")
	Private nPagina		:=	0
	Private	nTotal		:=	0
	Private	nCaja		:=	0
	Private	nCajas		:=	0
	Private	nTarima		:=	0
	Private nTarimas	:=	0
	Private	nPiezas		:=	0
	Private	nPeso		:=	0
	Private	oPrint
    
    oPrint := TMSPrinter():new(cTitle)
    oPrint:SetPortrait()
    
    cQuery	:=	" SELECT Z3_CAJA, Z3_WTPACK, Z3_QTYPACK, Z3_COD, Z3_DESC, Z3_TIPO, Z3_UID, Z3_UKEY, Z3_UNAME,"
    cQuery	+=	" Z1_CLIPRO, Z1_LOJA, Z1_NOMBRE, Z1_DOCORI, Z3_REMSER, Z3_REMDOC, Z3_IDXPACK, Z3_TARIMA, Z3_WHDPACK"
    cQuery	+=	" FROM " + retSqlName("SZ3") + " SZ3, " + retSqlName("SZ1") + " SZ1"
    cQuery	+=	" WHERE SZ3.D_E_L_E_T_ = ' '"
    cQuery	+=	" AND SZ3.D_E_L_E_T_ = ' '"
    cQuery	+=	" AND Z3_SERIE = Z1_SERIE"
    cQuery	+=	" AND Z3_FOLIO = Z1_FOLIO"
    cQuery	+=	" AND Z3_PACKING = 'S'
    cQuery	+=	" AND Z1_SERIE = 'PK'"
    cQuery	+=	" AND Z1_DOCORI = '" + cPedido + "'"
    cQuery	+=	" ORDER BY Z3_TARIMA, Z3_CAJA, Z3_IDXPACK"
    dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
    Do While .Not. (cDatos)->(eof())
    	aCliente[1]	:=	padR(allTrim((cDatos)->Z1_CLIPRO), tamSX3("A1_COD")[1])
    	aCliente[2]	:=	padR(allTrim((cDatos)->Z1_LOJA), tamSX3("A1_LOJA")[1])
    	aCliente[3]	:=	(cDatos)->Z1_NOMBRE
    	If .Not. empty((cDatos)->Z3_REMDOC)
    		cDocumento	:=	(cDatos)->Z3_REMSER + (cDatos)->Z3_REMDOC
    	End If
    	If .Not. empty((cDatos)->Z3_WHDPACK)
    		cContenido	:=	(cDatos)->Z3_WHDPACK
    	End If
    	cUser		:=	(cDatos)->Z3_UNAME
    	nPeso		:=	(cDatos)->Z3_WTPACK
    	nCount		+=	1
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
    
    dbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    SA1->(dbGoTop())
    If SA1->(dbSeek(xFilial("SA1") + aCliente[1] + aCliente[2]))
		aCliente[4]	:=	allTrim(SA1->A1_END) + ", " + allTrim(SA1->A1_BAIRRO)
		aCliente[5]	:=	allTrim(SA1->A1_MUN) + ", " + allTrim(SA1->A1_ESTADO) + ", CP " + allTrim(SA1->A1_CEP)
		aCliente[6]	:=	allTrim(SA1->A1_TEL)
	End If
    dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
    Do While .Not. (cDatos)->(eof())
    	//Encabezado
    	If nLinea	== 0
    		nLinea	:=	U_IMX4608B(cDocumento, aCliente)
    		loop
    	End If
    	
    	//Detalle
    	If allTrim((cDatos)->Z3_TIPO) == cPV
    		nTarimas	+=	1
    		nTarima		:=	nTarimas
    		(cDatos)->(dbSkip())
    		loop
    	ElseIf allTrim((cDatos)->Z3_TIPO) == cME
    		nCajas	+=	1
    		nCaja	:=	nCajas
    		(cDatos)->(dbSkip())
    		loop
    	ElseIf allTrim((cDatos)->Z3_TIPO) == cPT
    		nPiezas	+=	(cDatos)->Z3_QTYPACK
    		oPrint:Say(nLinea, 0050, padL(allTrim(transform(nTarima, "9999")), 4), fontSR)
    		oPrint:Say(nLinea, 0180, padL(allTrim(transform(nCaja, "9999")), 4), fontSR)
    		oPrint:Say(nLinea, 0330, padL(allTrim(transform((cDatos)->Z3_QTYPACK, "9999")), 4), fontSR)
    		oPrint:Say(nLinea, 0480, padR(allTrim((cDatos)->Z3_COD), 13), fontSR)
    		oPrint:Say(nLinea, 0850, subStr((cDatos)->Z3_DESC, 1, 30), fontSR)
    		//oPrint:Say(nLinea, 1550, padL(allTrim(transform((cDatos)->Z3_WTPACK, "9,999.99")), 13), fontSR)
    		//oPrint:Say(nLinea, 1900, allTrim((cDatos)->Z3_WHDPACK), fontSR)
    	End If
    	
    	//Pie de página
    	If nLinea	>= 3000
    		nLinea	:=	U_IMX4608C()
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
    	nLinea	:=	U_IMX4608C()
    	//Encabezado
    	nLinea	:=	U_IMX4608B(cDocumento, aCliente)
    	//Totales
    	nLinea	:=	U_IMX4608D(nLinea)
    Else
    	//Totales
    	nLinea	:=	U_IMX4608D(nLinea)
    End If
    
    //Termina la última página
    If nLinea > 0 .And. nLinea < 3000
    	nLinea	:=	U_IMX4608C()
    End If
    
    oPrint:Setup()
    oPrint:Preview()
Return

//Page Header
User Function IMX4608B(cDocumento, aCliente)
	Local	fontOUP	:=	TFont():New("Times New Roman", , -20, .T., .F.)
	Local	fontXLB	:=	TFont():New("Tahoma", , -36, .T., .T.)
	Local	fontLB	:=	TFont():New("Tahoma", , -24, .T., .T.)
	Local	fontMR	:=	TFont():New("Tahoma", , -18, .T., .F.)
	Local	fontSB	:=	TFont():new("Tahoma", , -14, .T., .T.)
	Local	nResult	:=	100
    oPrint:StartPage()
    oPrint:Say(nResult, 0350, "OXFORD UNIVERSITY PRESS MEXICO, S. A. DE C. V.", fontOUP)
    nResult	+=	100
    oPrint:Say(nResult, 0500, "LISTA DE EMPAQUE", fontXLB)
    nResult	+=	200
    oPrint:Say(nResult, 0060, "Cliente:", fontLB)
    nResult	+=	12
    oPrint:Say(nResult, 0550, aCliente[3], fontMR)
    nResult	+=	80
    oPrint:Say(nResult, 0060, "Destino:", fontLB)
    nResult	+=	12
    oPrint:Say(nResult, 0550, aCliente[4], fontMR)
    nResult	+=	80
    oPrint:Say(nResult, 0550, aCliente[5], fontMR)
    nResult	+=	80
    oPrint:Say(nResult, 0060, "Remisión:", fontLB)
    nResult	+=	12
    oPrint:Say(nResult, 0550, cDocumento, fontMR)
    nResult	+=	100
    oPrint:Line(nResult, 10, nResult, 2400)
    nResult	+=	10
    //Columnas
    oPrint:Say(nResult, 0010, "Tarima", fontSB)
	oPrint:Say(nResult, 0210, "Caja", fontSB)
	oPrint:Say(nResult, 0350, "Cant.", fontSB)
	oPrint:Say(nResult, 0550, "ISBN", fontSB)
	oPrint:Say(nResult, 1100, "Título", fontSB)
	oPrint:Say(nResult, 1700, "Peso", fontSB)
	oPrint:Say(nResult, 2000, "Dimensiones", fontSB)
    nResult	+=	70
    oPrint:Line(nResult, 10, nResult, 2400)
Return nResult

//Page Footer
User Function IMX4608C()
	Local	cTimeStamp	:=	""
	Local	fontSR		:=	TFont():New("Courier new", , -12, .T., .F.)
	Local	nResult		:=	3100
	cTimeStamp	:=	subStr(dToC(date()), 7, 4) + "-" + subStr(dToC(date()), 4, 2) + "-" + subStr(dToC(date()), 1, 2)
	cTimeStamp	+=	" " + subStr(time(), 1, 5)
    oPrint:Say(nResult, 0020, cTimeStamp, fontSR)
    oPrint:Say(nResult, 1000, "Página " + allTrim(str(nPagina)) + " de " + allTrim(str(nTotal)), fontSR)
    oPrint:EndPage()
    nPagina	+=	1
    nCount	:=	0
    nResult	:=	0
Return nResult

//Totales
User Function IMX4608D(nPos)
	Local	aContenido	:=	{}
	Local	nStep		:=	0
	Local	nResult		:=	nPos + 80
	Local	fontSB		:=	TFont():new("Tahoma", , -14, .T., .T.)
	oPrint:Line(nResult, 10, nResult, 2400)
	nResult	+=	1
	oPrint:Line(nResult, 10, nResult, 2400)
	nResult	+=	10
	oPrint:Say(nResult, 0050, "Total Tarimas", fontSB)
	oPrint:Say(nResult, 0500, "Total Cajas", fontSB)
	oPrint:Say(nResult, 0850, "Total Ítems", fontSB)
	oPrint:Say(nResult, 1200, "Total Peso", fontSB)
	oPrint:Say(nResult, 1600, "Empacado por", fontSB)
	nResult	+=	60
	oPrint:Say(nResult, 0200, allTrim(transform(nTarimas, "999999")), fontSB)
	oPrint:Say(nResult, 0580, allTrim(transform(nCajas, "999999")), fontSB)
	oPrint:Say(nResult, 0900, allTrim(transform(nPiezas, "999999")), fontSB)
	oPrint:Say(nResult, 1250, allTrim(transform(nPeso, "999,999.99")), fontSB)
	oPrint:Say(nResult, 1600, allTrim(cUser), fontSB)
	nResult	+=	80
	oPrint:Line(nResult, 10, nResult, 2400)
	
	oPrint:Line(nResult, 10, nResult, 2400)
	nResult	+=	80
	aContenido	:=	strToKarr(cContenido, CRLF)
	For nStep	:=	1 To len(aContenido)
		oPrint:Say(nResult, 0050, aContenido[nStep], fontSB)
		nResult	+=	60
	Next
Return (nResult)
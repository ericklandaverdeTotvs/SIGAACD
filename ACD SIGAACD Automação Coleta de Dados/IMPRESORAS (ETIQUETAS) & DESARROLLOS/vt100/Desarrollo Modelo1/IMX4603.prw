//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-19
//Fecha de revisión:
//Versión: 1
//Descripción: Packing.

#include "protheus.ch"

User Function IMX4603()
	Private cPT			:=	superGetMv("MV_IMX4612", .F., "PA")
	Private	cME			:=	superGetMv("MV_IMX4613", .F., "EM")
	Private	cPV			:=	superGetMv("MV_IMX4614", .F., "PV")
	Private	cTipos		:=	allTrim(cPT) + ";" + allTrim(cME) + ";" + allTrim(cPV)
	Private	cSerie		:=	""
	Private	nFolio		:=	0
	Private	aCliente	:=	{"", ""}
	Private cDocument	:=	criaVar("Z3_DOC")
	Private	cPicking	:=	space(9)
	Private	cPedido		:=	criaVar("Z1_DOCORI")
	Private cCliente	:=	criaVar("Z1_NOMBRE")
	Private cItem		:=	criaVar("B1_COD")
	Private	cDesc		:=	criaVar("B1_DESC")
	Private	cTipo		:=	criaVar("B1_TIPO")
	Private	cLot		:=	""
	Private	cLoc		:=	""
	Private	cDepot		:=	""
	Private	nCosto		:=	0
	Private	nCantidad	:=	0
	Private nPeso		:=	0
	Private	nCaja		:=	0
	Private	nCajas		:=	0
	Private	nTarima		:=	0
	Private	nTarimas	:=	0
	Private	aPicking	:=	U_IMX4603A("N")
	Private	aPacking	:=	U_IMX4603A("S")
	Private bmpRed		:=	loadBitmap(getResources(), "BR_VERMELHO")
	Private bmpGreen	:=	loadBitmap(getResources(), "BR_VERDE")
	Private bmpBlue		:=	loadBitmap(getResources(), "BR_AZUL")
	Private bmpBlack	:=	loadBitmap(getResources(), "BR_PRETO")
	Private bmpWhite	:=	loadBitmap(getResources(), "BR_BRANCO")
	Private bmpOrange	:=	loadBitmap(getResources(), "BR_LARANJA")
	Private bmpPink		:=	loadBitmap(getResources(), "BR_PINK")
	Private	bmpCancel	:=	loadBitmap(getResources(), "BR_CANCEL")
	Private	bmpViolet	:=	loadBitmap(getResources(), "BR_VIOLETA")
	Private	bmpYellow	:=	loadBitmap(getResources(), "BR_AMARELO")
	Private	cTitle		:=	"Picking v1.0"
	Private	cValue		:=	""
	Private	lHeader		:=	.T.
	Private	lDetail		:=	.F.
	Private	aButtons	:=	{}
	Private	dialogMain, flagPicking, flagPacking, groupDocument, groupPicking, groupPacking, listPicking, listPacking
	Private buttonSelect, textPicking, textPedido, textCliente
	Private	textItem, textDescripcion, textTipo, textCantidad, textPeso, buttonAdd, buttonPeso
	Private enchoiceBar	:=	{|| enchoiceBar(dialogMain, {|| dialogMain:end()}, {|| dialogMain:end()}, nil, aButtons)}
	
	aAdd(aButtons, {"EDIT", { || U_IMX4603D(listPacking:nAt) }, "EDIT", "Anular ítem"})
	aAdd(aButtons, {"EDIT", { || U_IMX4603E() }, "EDIT", "Generar remisión"})
	
	DEFINE MSDIALOG dialogMain TITLE cTitle FROM 000, 000 TO 570, 885 PIXEL
	
	@035, 005 GROUP groupDocument TO 060, 440 LABEL "Documento" OF dialogMain PIXEL
	@044, 010 MSGET textPedido VAR cPedido F3 "IMX_PK" SIZE 050, 010 WHEN lHeader VALID setHeader(1) OF dialogMain PIXEL
	@046, 070 SAY "Cliente"  SIZE 050, 010 OF dialogMain PIXEL
	@044, 100 MSGET textCliente VAR cCliente SIZE 140, 010 WHEN .F. OF dialogMain PIXEL
	@046, 270 SAY "Picking"  SIZE 050, 010 OF dialogMain PIXEL
	@044, 300 MSGET textPicking VAR cPicking SIZE 050, 010 WHEN lHeader VALID setHeader(2) OF dialogMain PIXEL
	@042, 380 BUTTON buttonSelect PROMPT "Seleccionar" SIZE 040, 015 OF dialogMain WHEN lHeader ACTION setDocument() PIXEL
	
	@065, 005 GROUP groupPicking TO 235, 165 LABEL "Picking" OF dialogMain PIXEL
	@075, 010 LISTBOX listPicking VAR cValue FIELDS HEADER "", "Código      ", "Picking", "Packing", COLSIZES 010, 050, 040, 040 SIZE 150, 155 OF dialogMain PIXEL
	listPicking:setArray(aPicking)
	listPicking:bLine		:=	{|| {colorPicking(aPicking[listPicking:nAt, 1]), aPicking[listPicking:nAt, 2], aPicking[listPicking:nAt, 4], aPicking[listPicking:nAt, 5]}}
	listPicking:bLDBLClick	:=	{|| showItem(listPicking:nAt)}
	@240, 010 BITMAP NAME "BR_VERMELHO" SIZE 008, 008 OF dialogMain PIXEL
	@240, 020 SAY "1. Pendiente." SIZE 080, 010 OF dialogMain PIXEL	
	@250, 010 BITMAP NAME "BR_LARANJA" SIZE 008, 008 OF dialogMain PIXEL
	@250, 020 SAY "2. Parcialmente empacado." SIZE 080, 010 OF dialogMain PIXEL	
	@260, 010 BITMAP NAME "BR_VERDE" SIZE 008, 008 OF dialogMain PIXEL
	@260, 020 SAY "3. Totalmente empacado." SIZE 080, 010 OF dialogMain PIXEL	
	
	@065, 170 GROUP groupPacking TO 235, 440 LABEL "Packing" OF dialogMain PIXEL
	@077, 175 SAY "Producto" SIZE 040, 010 OF dialogMain PIXEL
	@075, 220 MSGET textItem VAR cItem F3 "SB1" SIZE 050, 010 WHEN lDetail VALID itemOK() OF dialogMain PIXEL
	@075, 275 MSGET textDescripcion VAR cDesc SIZE 145, 010 WHEN .F. OF dialogMain PIXEL
	@097, 175 SAY "Tipo (" + cTipos + ")" SIZE 050, 010 OF dialogMain PIXEL
	@095, 220 MSGET textTipo VAR cTipo SIZE 050, 010 WHEN .F. OF dialogMain PIXEL
	@097, 275 SAY "Cantidad" SIZE 050, 010 OF dialogMain PIXEL
	@095, 300 MSGET textCantidad VAR nCantidad PICTURE "@E 999,999,999.99" SIZE 050, 010 WHEN lDetail VALID positivo() OF dialogMain PIXEL
	@092, 380 BUTTON buttonAdd PROMPT "Agregar" SIZE 040, 015 OF dialogMain WHEN lDetail ACTION U_IMX4603B(listPacking:nAt) PIXEL
	@115, 175 LISTBOX listPacking VAR cValue FIELDS HEADER "", "Código", "Descripción", "Cantidad", "Caja", "Tarima" COLSIZES 010, 040, 070, 050, 040, 040 SIZE 260, 115 OF dialogMain PIXEL
	listPacking:SetArray(aPAcking)
	listPacking:bLine		:=	{|| {colorPacking(aPacking[listPacking:nAt, 1]), aPacking[listPacking:nAt, 2], aPacking[listPacking:nAt, 3], aPacking[listPacking:nAt, 5], aPacking[listPacking:nAt, 15], aPacking[listPacking:nAt, 16]}}	
	@240, 175 BITMAP NAME "BR_PINK" SIZE 008, 008 OF dialogMain PIXEL
	@240, 185 SAY "Empaque" SIZE 060, 010 OF dialogMain PIXEL
	@250, 175 BITMAP NAME "BR_PRETO" SIZE 008, 008 OF dialogMain PIXEL
	@250, 185 SAY "Producto" SIZE 060, 010 OF dialogMain PIXEL
	
	@244, 270 SAY "Peso aproximado" SIZE 050, 010 OF dialogMain PIXEL
	@242, 320 MSGET textPeso VAR nPeso PICTURE "@E 999,999,999.99" SIZE 050, 010 WHEN lDetail VALID positivo() OF dialogMain PIXEL
	@240, 380 BUTTON buttonPeso PROMPT "Actualizar" SIZE 040, 015 WHEN lDetail ACTION setWeight() OF dialogMain PIXEL
	
	ACTIVATE MSDIALOG dialogMain ON INIT eval(enchoiceBar) CENTERED
Return


static Function setHeader(nOption)
	Local	lResult	:=	.T.
	Local	cDatos	:=	"IMX4603"
	Local	cQuery	:=	""
	If nOption == 1 .And. empty(cPedido)
		return lResult
	ElseIf nOption == 2 .And. empty(cPicking)
		return lResult
	End If
	cQuery	:=	" SELECT Z1_SERIE, Z1_FOLIO, Z1_SERORI, Z1_DOCORI, Z1_ST, Z1_CLIPRO, Z1_LOJA, Z1_NOMBRE"
	cQuery	+=	" FROM " + retSqlName("SZ1") + " SZ1"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_ST >= 11 AND Z1_ST < 13"
	cQuery	+=	" AND Z1_FILIAL = '" + xFilial("SZ1") + "'"
	cQuery	+=	" AND Z1_SERIE = 'PK'"
	If nOption == 1
		cQuery	+=	" AND Z1_DOCORI = '" + cPedido + "'"
	ElseIf nOption == 2
		cQuery	+=	" AND Z1_FOLIO = " + cPicking
	End If
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		cSerie		:=	(cDatos)->Z1_SERIE
		nFolio		:=	(cDatos)->Z1_FOLIO
		cPicking	:=	padR(allTrim(str(nFolio)), 9)
		cPedido		:=	(cDatos)->Z1_DOCORI
		cCliente	:=	(cDatos)->Z1_NOMBRE
		aCliente[1]	:=	(cDatos)->Z1_CLIPRO
		aCliente[2]	:=	(cDatos)->Z1_LOJA
	End If
	(cDatos)->(dbCloseArea())
return lResult


static Function setDocument()
	If lHeader .And. !empty(cPicking)
		aPicking	:=	U_IMX4603A("N")
		If len(aPicking) == 0
			iw_MsgBox("El documento seleccionado es inválido.", cTitle, "ERROR")
			return
		End If
		aPacking	:=	U_IMX4603A("S")
		lHeader		:=	.F.
		lDetail		:=	.T.
		listPicking:refresh()
		listPacking:refresh()
		setFocus(textItem:HWND)
	End If
return

static Function itemOK()
	Local	lResult	:=	.T.
	cDesc	:=	posicione("SB1", 1, xFilial("SB1") + cItem, "B1_DESC")
	cTipo	:=	posicione("SB1", 1, xFilial("SB1") + cItem, "B1_TIPO")
return lResult


static Function colorPicking(nOption)
	Do Case
		Case nOption == 1 //En espera
			flagPicking	:=	bmpRed
		Case nOption == 2 //En proceso
			flagPicking	:=	bmpOrange
		Case nOption == 3 //Finalizada
			flagPicking	:=	bmpGreen
		Otherwise
			flagPicking	:=	bmpWhite
	End
return (flagPicking)


static Function colorPacking(nOption)
	Do Case
		Case nOption == 1 .Or. nOption == 4 //Empaque
			flagPacking	:=	bmpPink
		Case nOption == 2 //Mercadería
			flagPacking	:=	bmpBlack
		Case nOption == 3 //Cancelado
			flagPacking	:=	bmpCancel
		Otherwise
			flagPacking	:=	bmpWhite
	End
return (flagPacking)


static Function refreshDialog()
	aPicking	:=	U_IMX4603A("N")
	aPacking	:=	U_IMX4603A("S")
	cItem		:=	criaVar("B1_COD")
	cDesc		:=	criaVar("B1_DESC")
	cTipo		:=	criaVar("B1_TIPO")
	nCantidad	:=	0
	listPicking:refresh()
	listPacking:refresh()
	setFocus(textItem:HWND)
return


static Function showItem(nRow)
	Local cResult	:=	aPicking[nRow, 3]
	If aPicking[nRow, 1] == 1 .Or. aPicking[nRow, 1] == 2
		cItem	:=	aPicking[nRow, 2]
		cDesc	:=	aPicking[nRow, 3]
		cTipo	:=	aPicking[nRow, 9]
		textCantidad:setFocus()
	Else
		If .Not. empty(cResult)
			iw_MsgBox(allTrim(cResult), "Producto", "INFO")
		End If
	End If
return


static Function setWeight()
	Local	cQuery	:=	""
	If nPeso > 0
		cQuery	+=	" UPDATE " + retSqlName("SZ3") + " SET"
		cQuery	+=	" Z3_WTPACK = " + allTrim(str(nPeso))
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z3_SERIE = '" + cSerie + "'"
		cQuery	+=	" AND Z3_FOLIO = " + allTrim(str(nFolio))
		If tcSqlExec(cQuery) < 0
			conOut(tcSqlError())
		End If
	End If
return


//Ítems SZ3
User Function IMX4603A(cPacking)
	Local	aResult	:=	{}
	Local	cDatos	:=	"IMX4603A"
	Local	cQuery	:=	""
	Local	nDex	:=	80
	Local	cCod	:=	space(20)
	Local	cDex	:=	space(nDex)
	Local	cQty	:=	space(12)
	Local	cQpa	:=	space(12)
	Local	nST		:=	0
	
	If cPacking == "S"
		nCaja		:=	0
		nCajas		:=	0
		nTarima		:=	0
		nTarimas	:=	0
	End If
	
	cQuery	:=	" SELECT *"
	cQuery	+=	" FROM " + retSqlName("SZ3") + " SZ3"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z3_FILIAL = '" + xFilial("SZ3") + "'"
	cQuery	+=	" AND Z3_SERIE = '" + cSerie + "'"
	cQuery	+=	" AND Z3_FOLIO = " + allTrim(str(nFolio))
	cQuery	+=	" AND Z3_PACKING = '" + cPacking + "'"
	cQuery	+=	" ORDER BY Z3_TARIMA, Z3_CAJA, Z3_IDXPACK, Z3_IDX"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(eof())
		cDocument	:=	(cDatos)->Z3_DOC
		nPeso		:=	(cDatos)->Z3_WTPACK
		If cPacking == "N"
			Do Case
				Case (cDatos)->Z3_QTYPACK == (cDatos)->Z3_QTY
					nST	:=	3
				Case (cDatos)->Z3_QTYPACK > 0 .And. (cDatos)->Z3_QTYPACK < (cDatos)->Z3_QTY
					nST	:=	2
				Case (cDatos)->Z3_QTYPACK == 0
					nST	:=	1
				Otherwise
					nST	:=	0
			End
		Else
			Do Case
				Case allTrim((cDatos)->Z3_TIPO) == cPV
					nTarimas	+=	1
					nST			:=	4
				Case allTrim((cDatos)->Z3_TIPO) == cME
					nCajas	+=	1
					nST		:=	1
				Case allTrim((cDatos)->Z3_TIPO) == cPT
					nST	:=	2
				Otherwise
					nST	:=	3
				End
		End If
		cCod	:=	(cDatos)->Z3_COD
		cDex	:=	subStr((cDatos)->Z3_DESC, 1, nDex)
		cQty	:=	padL(allTrim(transform((cDatos)->Z3_QTY, "9,999,999.99")), 9)
		cQpa	:=	padL(allTrim(transform((cDatos)->Z3_QTYPACK, "9,999,999.99")), 9)
		//				1	2		3	4		5				6				7					8					9					10					11				12						13				14					15				16
		aAdd(aResult, {nST, cCod, cDex, cQty, cQpa, (cDatos)->Z3_LOT, (cDatos)->Z3_LOC, (cDatos)->Z3_DEPOT, (cDatos)->Z3_TIPO, (cDatos)->Z3_COSTO, (cDatos)->Z3_QTY, (cDatos)->Z3_QTYPACK, (cDatos)->Z3_IDX, (cDatos)->Z3_IDXPACK, (cDatos)->Z3_CAJA, (cDatos)->Z3_TARIMA})
		(cDatos)->(dbSkip())
	End
	(cDatos)->(dbCloseArea())
	cCod	:=	space(20)
	cDex	:=	space(nDex)
	cQty	:=	space(12)
	cQpa	:=	space(12)
	For i := iIf(len(aResult) == 0, 1, len(aResult)) To 1000
		aAdd(aResult, {0, cCod, cDex, cQty, cQpa, "", "", "", "", "", "", "", "", "", "", ""})
	Next
Return (aResult)

//Agregar registro
User Function IMX4603B(nRow)
	Local	aUser		:=	pswRet()
	Local	aRecord		:=	{}
	Local	aInsert		:=	{}
	Local	cDatos		:=	"IMX4603B"
	Local	cQuery		:=	""
	Local	cKey		:=	""
	Local	nPos		:=	0
	Local	nPicking	:=	0
	Local	nPacking	:=	0
	Local	nIDX		:=	0
	Local	nItem		:=	0
	Local	i			:=	0
	If nCantidad <= 0
		iw_MsgBox("La cantidad capturada es inválida.", cTitle, "ERROR")
		return
	End If
	If .Not. allTrim(cTipo) $ cTipos
		iw_MsgBox("El producto seleccionado es inválido.", cTitle, "ERROR")
		return
	End If
	If allTrim(cTipo) == cPT .And. aPacking[nRow, 1] != 1
		iw_MsgBox("Debe seleccionar  un ítem de embalaje.", cTitle, "ERROR")
		return
	End If
	If allTrim(cTipo) == cPT
		nPos	:=	aScan(aPicking, {|x| allTrim(x[2]) == allTrim(cItem)})
		If nPos == 0
			iw_MsgBox("El producto no pertenece al pedido.", cTitle, "ERROR")
			return
		End If
		nPicking	:=	U_IMX4603C(1)
		nPacking	:=	U_IMX4603C(2) + nCantidad
		If nPacking > nPicking
			iw_MsgBox("La cantidad capturada es inválida.", cTitle, "ERROR")
			return
		End If
	End If
	
	If allTrim(cTipo) == cME //Caja
		nCajas	+=	1
		nCaja	:=	nCajas
		If aPacking[nRow, 1] == 4
			nTarima	:=	aPacking[nRow, 16]
		Else
			nTarima	:=	0
		End If
	ElseIf allTrim(cTipo) == cPV //Tarima
		nTarimas	+=	1
		nTarima		:=	nTarimas
	ElseIf allTrim(cTipo) == cPT
		nCaja	:=	aPacking[nRow, 15]
		nTarima	:=	aPacking[nRow, 16]
	End If
	
	//IDX
	cQuery	:=	" SELECT MAX(Z3_IDXPACK) AS ULTIMO"
	cQuery	+=	" FROM " + retSqlName("SZ3")
	cQuery	+=	" WHERE Z3_DOC = '" + cDocument + "'"
	cQuery	+=	" AND Z3_PACKING = 'S'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nIDX	:=	(cDatos)->ULTIMO + 1
	Else
		nIDX	:=	1
	End If
	(cDatos)->(dbCloseArea())
	
	//Update SZ3
	If allTrim(cTipo) == cPT
		nPicking	:=	nCantidad
		cKey		:=	xFilial("SZ3") + cDocument + cItem
		dbSelectArea("SZ3")
		SZ3->(dbSetOrder(6))
		SZ3->(dbSeek(cKey))
		Do While .Not. SZ3->(eof()) .And. allTrim(SZ3->Z3_FILIAL + SZ3->Z3_DOC + SZ3->Z3_COD) == allTrim(cKey) .And. nPicking > 0
			If SZ3->Z3_QTY == SZ3->Z3_QTYPACK
				SZ3->(dbSkip())
				loop
			End If
			If SZ3->Z3_QTY >= nPicking
				nPacking	:=	nPicking
				nPicking	:=	0
			ElseIf SZ3->Z3_QTY < nPicking
				nPacking	:=	SZ3->Z3_QTY
				nPicking	:=	nPicking - SZ3->Z3_QTY
			End If
			aRecord	:=	{}
			aAdd(aRecord, xFilial("SZ3"))
			aAdd(aRecord, cDocument)
			aAdd(aRecord, SZ3->Z3_IDX)
			aAdd(aRecord, cItem)
			aAdd(aRecord, cDesc)
			aAdd(aRecord, cTipo)
			aAdd(aRecord, nPacking)
			aAdd(aRecord, nPacking)
			aAdd(aRecord, SZ3->Z3_LOT)
			aAdd(aRecord, SZ3->Z3_LOC)
			aAdd(aRecord, SZ3->Z3_DEPOT)
			aAdd(aRecord, SZ3->Z3_COSTO)
			aAdd(aRecord, "S")
			aAdd(aRecord, cSerie)
			aAdd(aRecord, nFolio)
			aAdd(aRecord, nIDX)
			aAdd(aRecord, SZ3->Z3_ITEM)
			aAdd(aRecord, nPeso)
			aAdd(aRecord, nCaja)
			aAdd(aRecord, nTarima)
			aAdd(aInsert, aClone(aRecord))
			
			recLock("SZ3", .F.)
			SZ3->Z3_QTYPACK	+=	nPacking
			msUnlock("SZ3")
			SZ3->(dbCommit())
			nIDX	+=	1
			SZ3->(dbSkip())
		End
	Else
		aRecord	:=	{}
		aAdd(aRecord, xFilial("SZ3"))
		aAdd(aRecord, cDocument)
		aAdd(aRecord, 0)
		aAdd(aRecord, cItem)
		aAdd(aRecord, cDesc)
		aAdd(aRecord, cTipo)
		aAdd(aRecord, nCantidad)
		aAdd(aRecord, nCantidad)
		aAdd(aRecord, criaVar("Z3_LOT"))
		aAdd(aRecord, criaVar("Z3_LOC"))
		aAdd(aRecord, criaVar("Z3_DEPOT"))
		aAdd(aRecord, 0)
		aAdd(aRecord, "S")
		aAdd(aRecord, cSerie)
		aAdd(aRecord, nFolio)
		aAdd(aRecord, nIDX)
		aAdd(aRecord, 0)
		aAdd(aRecord, nPeso)
		aAdd(aRecord, nCaja)
		aAdd(aRecord, nTarima)
		aAdd(aInsert, aClone(aRecord))
	End If
		
	//Graba registros
	dbSelectArea("SZ3")
	SZ3->(dbGoBottom())
	For i := 1 To len(aInsert)
		recLock("SZ3", .T.)
		SZ3->Z3_FILIAL	:=	aInsert[i, 1]
		SZ3->Z3_DOC		:=	aInsert[i, 2]
		SZ3->Z3_IDX		:=	aInsert[i, 3]
		SZ3->Z3_COD		:=	aInsert[i, 4]
		SZ3->Z3_DESC	:=	aInsert[i, 5]
		SZ3->Z3_TIPO	:=	aInsert[i, 6]
		SZ3->Z3_QTY		:=	aInsert[i, 7]
		SZ3->Z3_QTYPACK	:=	aInsert[i, 8]
		SZ3->Z3_LOT		:=	aInsert[i, 9]
		SZ3->Z3_LOC		:=	aInsert[i, 10]
		SZ3->Z3_DEPOT	:=	aInsert[i, 11]
		SZ3->Z3_COSTO	:=	aInsert[i, 12]
		SZ3->Z3_PACKING	:=	aInsert[i, 13]
		SZ3->Z3_SERIE	:=	aInsert[i, 14]
		SZ3->Z3_FOLIO	:=	aInsert[i, 15]
		SZ3->Z3_IDXPACK	:=	aInsert[i, 16]
		SZ3->Z3_ITEM	:=	aInsert[i, 17]
		SZ3->Z3_WTPACK	:=	aInsert[i, 18]
		SZ3->Z3_CAJA	:=	aInsert[i, 19]
		SZ3->Z3_TARIMA	:=	aInsert[i, 20]
		//Usuario
		SZ3->Z3_UID		:=	aUser[1, 1]
		SZ3->Z3_UKEY	:=	aUser[1, 2]
		SZ3->Z3_UNAME	:=	aUser[1, 4]
		msUnlock("SZ3")
		SZ3->(dbCommit())
	Next
	refreshDialog()
Return

//Cantidad total
User Function IMX4603C(nOption)
	Local	nResult	:=	0
	Local	i
	Do Case
		Case nOption == 1
			For i := 1 To len(aPicking)
				If aPicking[i, 1] == 0
					Exit
				End If
				If allTrim(aPicking[i, 2]) == allTrim(cItem)
					nResult	+=	aPicking[i, 11]
				End If
			Next
		Case nOption == 2
			For i := 1 To len(aPacking)
				If aPacking[i, 1] == 0
					Exit
				End If
				If allTrim(aPacking[i, 2]) == allTrim(cItem)
					nResult	+=	aPacking[i, 12]
				End If
			Next
	End
Return nResult

//Anular registro
User Function IMX4603D(nRow)
	Local	cQuery	:=	""
	If aPacking[nRow, 1] != 0
		dbSelectArea("SZ3")
		SZ3->(dbSetOrder(7))
		If SZ3->(dbSeek(xFilial("SZ3") + cDocument + str(aPacking[nRow, 13], 2, 0) + str(aPacking[nRow, 14], 2, 0)))
			recLock("SZ3", .F.)
			SZ3->(dbDelete())
			msUnlock("SZ3")
			SZ3->(dbCommit())
		End If
		If aPacking[nRow, 1] == 2
			SZ3->(dbSetOrder(1))
			If SZ3->(dbSeek(xFilial("SZ3") + cDocument + str(aPacking[nRow, 13], 2, 0)))
				recLock("SZ3", .F.)
				SZ3->Z3_QTYPACK	:=	SZ3->Z3_QTYPACK - aPacking[nRow, 11]
				msUnlock("SZ3")
				SZ3->(dbCommit())
			End If
		End If
		refreshDialog()
	End If
Return


//Crea remisión
User Function IMX4603E()
	Local	aUsuario	:=	pswRet()
	Local	cContext	:=	""
	Local	cDatos		:=	"IMX4603E"
	Local	cQuery		:=	""
	Local	cSecuencia	:=	""
	Local	nLength		:=	tamSX3("F2_DOC")[1]
	Local	cD2_ITEM	:=	""
	Local	cTES		:=	superGetMv("MV_IMX4603", .F., "600")
	Local	cCF			:=	posicione("SF4", 1, xFilial("SF4") + cTES, "F4_CF")
	Local	cSER		:=	superGetMv("MV_IMX4600", .F., "R")
	Local	cFOL		:=	""
	Local	nItem		:=	0
	Local	nTotal		:=	0
	Local	nEtiquetas	:=	0
	Local	lError		:=	.F.
	Local	i
	
	For i := 1 To len(aPicking)
		If aPicking[i, 1] != 0 .And. aPicking[i, 11] != aPicking[i, 12]
			lError		:=	.T.
			cContext	+=	aPicking[i, 2] + "; " + aPicking[i, 5] + " <> " + aPicking[i, 4] + CRLF
		End If
	Next
	
	If lError
		If .Not. iw_MsgBox(cContext, "¿Confirma divergencias?", "YESNO")
			return
		End If
	End If
	
	cQuery	:=	" SELECT MAX(D2_DOC) AS ULTIMO"
	cQuery	+=	" FROM " + retSqlName("SD2")
	cQuery	+=	" WHERE D2_SERIE = '" + cSER + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		cFOL	:=	soma1((cDatos)->ULTIMO)
	End If
	(cDatos)->(dbCloseArea())            
	
	cSecuencia	:=	proxNum()
	dbSelectArea("SD2")
	nLength	:=	tamSX3("D2_ITEM")[1]
	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(8))
	SZ3->(dbSeek(xFilial("SZ3") + cDocument))
	Do While .Not. SZ3->(eof()) .And. SZ3->Z3_DOC == cDocument
		If SZ3->Z3_PACKING == "N" .Or. allTrim(SZ3->Z3_TIPO) == cME
			nEtiquetas	+= iIf(allTrim(SZ3->Z3_TIPO) == cME, 1, 0)
			SZ3->(dbSkip())
			Loop
		End If
		nItem		+=	1
		cD2_ITEM	:=	strZero(nItem, tamSX3("D2_ITEM")[1])
		cDepot		:=	SZ3->Z3_DEPOT
		cDepot		:=	padR(cDepot, tamSX3("B2_LOCAL")[1])
		nCosto		:=	SZ3->Z3_COSTO
		If nCosto == 0
			nCosto		:=	posicione("SB2", 2, xFilial("SB2") + cDepot + padR(SZ3->Z3_COD, tamSX3("B2_COD")[1]), "B2_CM1")
		End If
		nValor		:=	(SZ3->Z3_QTY * nCosto)
		nTotal		+=	nValor
		recLock("SD2", .T.)
		SD2->D2_FILIAL	:=	xFilial("SD2")
		SD2->D2_ITEM	:=	cD2_ITEM
		SD2->D2_COD		:=	SZ3->Z3_COD
		SD2->D2_UM		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_UM")
		SD2->D2_TP		:=	SZ3->Z3_TIPO
		SD2->D2_QUANT	:=	SZ3->Z3_QTY
		SD2->D2_CUSTO1	:=	nCosto
		SD2->D2_PRCVEN	:=	nCosto
		SD2->D2_TOTAL	:=	nValor
		SD2->D2_TES		:=	cTES
		SD2->D2_CF		:=	cCF
		//SD2->D2_PEDIDO	:=	aDatos[4]
		//SD2->D2_ITEMPV	:=	cItem
		SD2->D2_CLIENTE	:=	aCliente[1]
		SD2->D2_LOJA	:=	aCliente[2]
		SD2->D2_LOCAL	:=	cDepot
		SD2->D2_DOC		:=	cFOL
		SD2->D2_EMISSAO	:=	dDatabase
		SD2->D2_DTDIGIT	:=	dDatabase
		SD2->D2_TIPO	:=	"N"
		SD2->D2_SERIE	:=	cSER
		If U_IMXLIB_TRACE(SZ3->Z3_COD)
			SD2->D2_LOTECTL	:=	SZ3->Z3_LOT
		End If
		If U_IMXLIB_GPS(SZ3->Z3_COD)
			SD2->D2_LOCALIZ	:=	SZ3->Z3_LOC
		End If
		SD2->D2_EST		:=	posicione("SA1", 1, xFilial("SA1") + aCliente[1] + aCliente[2], "A1_EST")
		SD2->D2_STSERV	:=	"1"
		SD2->D2_FORMUL	:=	"S"
		SD2->D2_ESPECIE	:=	"RFN" + space(tamSX3("D2_ESPECIE")[1] - 3)
		SD2->D2_TIPODOC	:=	"50"
		SD2->D2_TIPOREM	:=	"0"
		SD2->D2_NUMSEQ	:=	cSecuencia
		SD2->D2_GERANF	:=	"S"
		SD2->D2_QTDAFAT	:=	SZ3->Z3_QTY
		msUnlock("SD2")
		SD2->(dbCommit())
		SD2->(dbSkip())
		
		updatePedido(cPedido, strZero(SZ3->Z3_ITEM, tamSX3("C9_ITEM")[1]), SZ3->Z3_QTY, cFOL, cSER)
		
		updateSTK(strZero(SZ3->Z3_IDXPACK, nLength), allTrim(cDepot), allTrim(SZ3->Z3_COD), SZ3->Z3_LOT, (SZ3->Z3_QTY * -1), nValor, SZ3->Z3_LOC)
		
		recLock("SZ3", .F.)
		SZ3->Z3_REMSER	:=	cSER
		SZ3->Z3_REMDOC	:=	cFOL
		SZ3->Z3_REMIDX	:=	cD2_ITEM
		msUnlock("SZ3")
		SZ3->(dbCommit())
		SZ3->(dbSkip())
	End
	
	dbSelectArea("SF2")
	recLock("SF2", .T.)
	SF2->F2_FILIAL	:=	xFilial("SF2")
	SF2->F2_DOC		:=	cFOL
	SF2->F2_SERIE	:=	cSER
	SF2->F2_CLIENTE	:=	aCliente[1]
	SF2->F2_LOJA	:=	aCliente[2]
	SF2->F2_EMISSAO	:=	dDatabase
	SF2->F2_EST		:=	posicione("SA1", 1, xFilial("SA1") + aCliente[1] + aCliente[2], "A1_EST")
	SF2->F2_TIPOCLI	:=	posicione("SA1", 1, xFilial("SA1") + aCliente[1] + aCliente[2], "A1_TIPO")
	SF2->F2_VALMERC	:=	nTotal
	SF2->F2_VALBRUT	:=	nTotal
	SF2->F2_TIPO	:=	"N"
	SF2->F2_DTDIGIT	:=	dDatabase
	SF2->F2_FORMUL	:=	"S"
	SF2->F2_ESPECIE	:=	"RFN" + space(tamSX3("F2_ESPECIE")[1] - 3)
	SF2->F2_HORA	:=	time()
	SF2->F2_MOEDA	:=	1
	SF2->F2_TXMOEDA	:=	1
	SF2->F2_TIPORET	:=	"3"
	SF2->F2_TIPODOC	:=	"50"
	SF2->F2_TIPOREM	:=	"0"
	msUnlock("SF2")
	SF2->(dbCommit())
	SF2->(dbSkip())
	
	//Update SZ1
	cQuery	+=	" UPDATE " + retSqlName("SZ1") + " SET"
	cQuery	+=	" Z1_ST = 13,"
	cQuery	+=	" Z1_FUNC2 = 'IMX4603',"
	cQuery	+=	" Z1_FECHA2 = '" + dToS(dDatabase) + "',"
	cQuery	+=	" Z1_HORA2 = '" + subStr(time(), 1, 5) + "',"
	cQuery	+=	" Z1_UID2 = '" + aUsuario[1, 1] + "',"
	cQuery	+=	" Z1_UKEY2 = '" + aUsuario[1, 2] + "',"
	cQuery	+=	" Z1_UNAME2 = '" + aUsuario[1, 4] + "'"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = '" + cSerie + "'"
	cQuery	+=	" AND Z1_FOLIO = " + str(nFolio)
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
	cQuery	+=	" UPDATE " + retSqlName("SZ2") + " SET"
	cQuery	+=	" Z2_ST	= 13"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_SERIE = '" + cSerie + "'"
	cQuery	+=	" AND Z2_FOLIO = " + str(nFolio)
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If	
	
	//Éxito
	U_IMX4606(cPedido)
	
	dialogMain:end()
return

static Function updatePedido(cPedido, cItem, nCantidad, cFOL, cSER)
	Local	aSC5	:=	{}
	Local	aSC6	:=	{}
	Local	cST		:=	""
	aSC6	:=	SC6->(getArea())
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	If SC6->(dbSeek(xFilial("SC6") + padR(allTrim(cPedido), tamSX3("C6_NUM")[1]) + padR(allTrim(cItem), tamSX3("C6_ITEM")[1])))
		recLock("SC6", .F.)
		SC6->C6_QTDENT	+=	nCantidad
		SC6->C6_QTDEMP	-=	nCantidad
		SC6->C6_NOTA	:=	cFOL
		SC6->C6_SERIE	:=	cSER
		SC6->C6_DATFAT	:=	dDatabase
		Do Case
			Case SC6->C6_QTDENT == SC6->C6_QTDVEN
				cST	:=	"TOTAL"
			Case SC6->C6_QTDENT < SC6->C6_QTDVEN
				cST	:=	"PARCIAL"
			Case SC6->C6_QTDENT > SC6->C6_QTDVEN
				cST	:=	"EXCESO"
		End
		msUnlock("SC6")
		SC6->(dbCommit())
	End If
	restArea(aSC6)
	aSC5	:=	SC5->(getArea())
	SC5->(dbSetOrder(1))
	SC5->(dbGoTop())
	If SC5->(dbSeek(xFilial("SC5") + padR(allTrim(cPedido), tamSX3("C5_NUM")[1])))
		recLock("SC5", .F.)
		SC5->C5_STACD	:=	cST
		msUnlock("SC5")
		SC5->(dbCommit())
	End If
	restArea(aSC5)
return


static Function updateSTK(cItem, cDepot, cCod, cLot, nQty, nVal, cUbi)
	Local	cKey	:=	""
	//Actualiza saldo SB2
	dbSelectArea("SB2")
	SB2->(dbSetOrder(2))
	SB2->(dbGoTop())
	If SB2->(dbSeek(xFilial("SB2") + padR(cDepot, tamSX3("B2_LOCAL")[1]) + padR(cCod, tamSX3("B2_COD")[1])))
		recLock("SB2", .F.)
		SB2->B2_QATU	+=	nQty
		SB2->B2_RESERVA	+=	nQty
		SB2->B2_VATU1	:=	SB2->B2_QATU * SB2->B2_CM1
		msUnlock("SB2")
	Else
		recLock("SB2", .T.)
		SB2->B2_FILIAL	:=	xFilial("SB2")
		SB2->B2_COD		:=	padR(cCod, tamSX3("B2_COD")[1])
		SB2->B2_LOCAL	:=	padR(cDepot, tamSX3("B2_LOCAL")[1])
		SB2->B2_QATU	:=	nQty
		SB2->B2_CM1		:=	nVal
		SB2->B2_VATU1	:=	SB2->B2_QATU * SB2->B2_CM1
		msUnlock("SB2")
	End If
	
	If U_IMXLIB_TRACE(cCod) //Controla lote
		dbSelectArea("SB8")
		SB8->(dbSetOrder(2))
		SB8->(dbGoTop())
		cKey	:=	xFilial("SB8") + criaVar("B8_NUMLOTE") + padR(cLot, tamSX3("B8_LOTECTL")[1])
		cKey	+=	padR(cCod, tamSX3("B8_PRODUTO")[1]) + padR(cDepot, tamSX3("B8_LOCAL")[1])
		If SB8->(dbSeek(cKey))
			recLock("SB8", .F.)
			SB8->B8_SALDO	+=	nQty
			SB8->B8_EMPENHO	+=	nQty
			msUnlock("SB8")
		Else
			recLock("SB8", .T.)
			SB8->B8_FILIAL	:=	xFilial("SB8")
			SB8->B8_QTDORI	:=	nQty
			SB8->B8_PRODUTO	:=	padR(cCod, tamSX3("B8_PRODUTO")[1])
			SB8->B8_LOCAL	:=	padR(cDepot, tamSX3("B8_LOCAL")[1])
			SB8->B8_DATA	:=	dDatabase
			SB8->B8_DTVALID	:=	dDatabase + 365
			SB8->B8_SALDO	:=	nQty
			SB8->B8_EMPENHO	:=	0.00
			SB8->B8_ORIGLAN	:=	"NF"
			SB8->B8_LOTEFOR	:=	cLot
			SB8->B8_LOTECTL	:=	cLot
			SB8->B8_DOC		:=	allTrim(str(nFolio))
			SB8->B8_SERIE	:=	cSerie
			SB8->B8_ITEM	:=	cItem
			SB8->B8_CLIFOR	:=	aCliente[1]
			SB8->B8_LOJA	:=	aCliente[2]
			msUnlock("SB8")
		End If
	End If
	
	If U_IMXLIB_GPS(cCod) //Controla ubicación
		dbSelectArea("SBF")
		SBF->(dbSetOrder(1))
		SBF->(dbGoTop())
		cKey	:=	xFilial("SBF")
		cKey	+=	padR(allTrim(cDepot), tamSX3("BF_LOCAL")[1])
		cKey	+=	padR(allTrim(cUbi), tamSX3("BF_LOCALIZ")[1])
		cKey	+=	padR(allTrim(cCod), tamSX3("BF_PRODUTO")[1])
		cKey	+=	criaVar("BF_NUMSERI")
		cKey	+=	padR(allTrim(cLot), tamSX3("BF_LOTECTL")[1])
		cKey	+=	criaVar("BF_NUMLOTE")
		If SBF->(dbSeek(cKey))
			recLock("SBF", .F.)
			SBF->BF_QUANT	+=	nQty
			SBF->BF_EMPENHO	+=	nQty
			msUnlock("SBF")
		Else
			//registro no existe
		End If
	End If
return
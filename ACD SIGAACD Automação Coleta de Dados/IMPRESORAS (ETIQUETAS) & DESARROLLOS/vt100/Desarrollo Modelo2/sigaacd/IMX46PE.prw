#Include "Protheus.ch"

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-06-08
//Fecha de revisión:
//Versión: 1
//Descripción: Al finalizar el registro de la factura de entrada. Sobrescribe la cantidad entregada en SC7.
User Function LOCXPE11()
	If funName() == "MATA101N"
		U_IMX46PEC()
	End If
Return

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-06-01
//Fecha de revisión:
//Versión: 1
//Descripción: Opciones en el menu de pedidos. Agrega el comando finalizar ACD.
User Function MT120BRW()
	aAdd(aRotina, {"Finalizar", "U_IMX4601M(funName())", 0, 6, 0, nil})
Return

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-06-01
//Fecha de revisión:
//Versión: 1
//Descripción: Opciones en el menu de pedidos. Agrega el comando finalizar ACD.
User Function MA410MNU()
	aAdd(aRotina, {"Finalizar", "U_IMX4601M(funName())", 0, 6, 0, nil})
	//Autor: Maxson Secchin
	//Fecha de creación: 2015-06-05
	//Descripción: Informe MATR730 - Pre-nota
	aAdd(aRotina, {"Imp. Ped.", "MATR730()", 0, 1, 0, nil})
Return

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-05-06
//Versión: 1
//Fecha de revisión:
//Descripción: Punto de entrada antes de contabilizar el pedido de compra. Crea estructura ACD.
User Function MT120GOK()
	Local	aSC7	:=	SC7->(GetArea())
	Local	cSerie	:=	"RX"
	U_IMX46PEB(cSerie, SC7->C7_NUM)
	U_IMX46PEA(cSerie, funName())
	RestArea(aSC7)
Return

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-05-06
//Versión: 1
//Descripción: Punto de entrada en la aprobación del pedido de ventas. Crea estructura ACD.
User Function MTA440C9()
	Local	aSC5	:=	SC5->(GetArea())
	Local	aSC9	:=	SC9->(GetArea())
	Local	cSerie	:=	"PK"
	U_IMX46PEB(cSerie, SC5->C5_NUM)
	U_IMX46PEA(cSerie, funName())
	dbSelectArea("SC5")
	recLock("SC5", .F.)
	SC5->C5_STACD	:=	"** NO **"
	msUnlock("SC5")
	SC5->(dbCommit())
	restArea(aSC5)
	restArea(aSC9)
Return

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-08-17
//Versión: 1
//Descripción: Punto de entrada en la anulación de la aprobación del pedido de ventas.
User Function M469ITEM()
	Local	aSC5	:=	SC5->(GetArea())
	Local	cSerie	:=	"PK"
	dbSelectArea("SC5")
	If SC5->(dbSeek(xFilial("SC5") + SC6->C6_NUM))
		U_IMX46PEB(cSerie, SC5->C5_NUM)
		recLock("SC5", .F.)
		SC5->C5_STACD	:=	""
		msUnlock("SC5")
		SC5->(dbCommit())
	End If
	RestArea(aSC5)
Return (.T.)

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-08-17
//Versión: 1
//Descripción: Punto de entrada en la eliminación del pedido de compras.
User Function MA120E()
	Local	expN1	:=	PARAMIXB[1]
	Local	cSerie	:=	"RX"
	Local	lResult	:=	.F.
	If expN1 == 1
		U_IMX46PEB(cSerie, SC7->C7_NUM)
		lResult	:=	.T.
	End If
Return (lResult)

//Autor: Cuauhtémoc Olvera
//Fecha de creación: 2015-08-17
//Versión: 1
//Descripción: Punto de entrada durante la eliminación del pedido de venta.
User Function A410EXC()
	Local	aSC5	:=	SC5->(GetArea())
	Local	cSerie	:=	"PK"
	If empty(SC5->C5_STACD)
		U_IMX46PEB(cSerie, SC5->C5_NUM)
	End If
	RestArea(aSC5)
Return (.T.)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-04-08
//Fecha de revisión: 2015-05-13
//Versión: 2
//Descripción: Crea los registros SZ1 y SZ2
User Function IMX46PEA(cSerie, cFuncion)
	Local	aUsuario		:=	pswRet()
	Local	cCampo1			:=	""
	Local	cCampo2			:=	""
	Local	cCampo3			:=	""
	Local	cSerieOrigen	:=	""
	Local	cFolioOrigen	:=	""
	Local	cPrefijo		:=	""
	Local	cTabla			:=	""
	Local	cTime			:=	subStr(time(), 1, 5)
	Local	dDate			:=	dDatabase
	Local	nFolio			:=	0
	Local	nStep			:=	0
	If	cSerie == "RX"
		cFolioOrigen	:=	SC7->C7_NUM
		cPrefijo		:=	"C7_"
		cTabla			:=	"SC7"
	Else
		cFolioOrigen	:=	SC9->C9_PEDIDO
		cPrefijo		:=	"C9_"
		cTabla			:=	"SC9"
	End If
	nFolio := U_IMX4600F(cSerie)
	dbSelectArea("SZ1")
	RecLock("SZ1", .T.)
	SZ1->Z1_FILIAL	:=	xFilial("SZ1")
	SZ1->Z1_SERIE	:=	cSerie
	SZ1->Z1_FOLIO	:=	nFolio
	SZ1->Z1_SERORI	:=	cSerieOrigen
	SZ1->Z1_DOCORI	:=	cFolioOrigen
	SZ1->Z1_ST		:=	0
	SZ1->Z1_FUNC1	:=	cFuncion
	SZ1->Z1_UID1	:=	aUsuario[1, 1]
	SZ1->Z1_UKEY1	:=	aUsuario[1, 2]
	SZ1->Z1_UNAME1	:=	aUsuario[1, 4]
	SZ1->Z1_FECHA1	:=	dDate
	SZ1->Z1_HORA1	:=	cTime
	If cSerie == "RX"
		SZ1->Z1_CLIPRO	:=	SA2->A2_COD
		SZ1->Z1_LOJA	:=	SA2->A2_LOJA
		SZ1->Z1_NOMBRE	:=	SA2->A2_NOME
	Else
		SZ1->Z1_CLIPRO	:=	SA1->A1_COD
		SZ1->Z1_LOJA	:=	SA1->A1_LOJA
		SZ1->Z1_NOMBRE	:=	SA1->A1_NOME
	End If
	MsUnlock("SZ1")
	dbSelectArea("SZ2")
	dbSelectArea(cTabla)
	&(cTabla)->(dbSetORder(1))
	&(cTabla)->(dbGoTop())
	&(cTabla)->(dbSeek(xFilial(cTabla) + cFolioOrigen))
	cCampo1	:=	cTabla + "->" + cPrefijo + "FILIAL"
	cCampo2	:=	cTabla + "->" + iIf(cTabla == "SC7", "C7_NUM", "C9_PEDIDO")
	Do While &(cCampo1) == xFilial(cTabla) .And. &(cCampo2) == cFolioOrigen
		nStep	+=	1
		RecLock("SZ2", .T.)
		SZ2->Z2_FILIAL	:=	xFilial("SZ2")
		SZ2->Z2_SERIE	:=	cSerie
		SZ2->Z2_FOLIO	:=	nFolio
		cCampo3			:=	cTabla + "->" + cPrefijo + "ITEM"
		SZ2->Z2_ITEM	:=	val(&(cCampo3))
		SZ2->Z2_ST		:=	0
		cCampo3			:=	cTabla + "->" + cPrefijo + iIf(cTabla == "SC7", "PRECO", "PRCVEN")
		SZ2->Z2_COSTO	:=	&(cCampo3)
		cCampo3			:=	cTabla + "->" + cPrefijo + "LOCAL"
		SZ2->Z2_DEPOT1	:=	&(cCampo3)
		cCampo3			:=	cTabla + "->" + cPrefijo + "PRODUTO"
		SZ2->Z2_COD1	:=	&(cCampo3)
		SZ2->Z2_DESC1	:=	posicione("SB1", 1, xFilial("SB1") + &(cCampo3), "B1_DESC")
		SZ2->Z2_UM1		:=	posicione("SB1", 1, xFilial("SB1") + &(cCampo3), "B1_UM")
		cCampo3			:=	cTabla + "->" + cPrefijo + "LOTECTL"
		SZ2->Z2_LOTE1	:=	iIf(cTabla == "SC7", criaVar("Z2_LOTE1"), &(cCampo3))
		cCampo3			:=	cTabla + "->" + cPrefijo + iIf(cTabla == "SC7", "QUANT", "QTDLIB")
		SZ2->Z2_CANT1	:=	&(cCampo3)
		MsUnlock("SZ2")
		&(cTabla)->(dbSkip())
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-04-08
//Versión: 1
//Fecha de revisión:
//Descripción: Cancela los registros SZ1, SZ2, SZ3
User Function IMX46PEB(cSerie, cFolio)
	Local	cSerieOrigen	:=	""
	Local	cFolioOrigen	:=	cFolio
	Local	nFolio			:=	0
	Local	cQuery			:=	""
	Local	cDatos			:=	"IMX46PEB"
	cQuery	:=	" SELECT Z1_SERIE, Z1_FOLIO"
	cQuery	+=	" FROM " + RetSqlName("SZ1")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = '" + cSerie + "'"
	cQuery	+=	" AND Z1_DOCORI = '" + cFolioOrigen + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nFolio	:=	(cDatos)->Z1_FOLIO
	End If
	(cDatos)->(dbCloseArea())	
	cQuery	:=	" UPDATE " + RetSqlName("SZ1") + " SET"
	cQuery	+=	" D_E_L_E_T_ = '*'"
	cQuery	+=	" WHERE	D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = '" + cSerie + "'"
	cQuery	+=	" AND Z1_FOLIO = " + allTrim(str(nFolio))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
	cQuery	:=	strTran(cQuery, "Z1", "Z2")
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-06-08
//Versión: 1
//Fecha de revisión:
//Descripción: Actualiza la información "Cantidad ya entregada en SC7"
User Function IMX46PEC()
	Local	aSD1	:=	SD1->(getArea())
	Local	aSC7	:=	SC7->(getArea())
	Local	cTES	:=	superGetMv("MV_IMX4607", .F., "301")
	Local	cFilLoc	:=	SD1->D1_FILIAL
	Local	cSerie	:=	SD1->D1_SERIE
	Local	cFolio	:=	SD1->D1_DOC
	Local	nQty	:=	0
	
	SD1->(dbSetOrder(1))
	SD1->(dbGoTop())
	SD1->(dbSeek(cFilLoc + cFolio + cSerie))
	Do While cFilLoc + cFolio + cSerie == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE
		If allTrim(SD1->D1_TES) == allTrim(cTES) .And. !empty(SD1->D1_PEDIDO) .And. !empty(SD1->D1_ITEMPC)
			nQty	:=	cantidadSZ2(SD1->D1_PEDIDO, SD1->D1_ITEMPC)
			SC7->(dbSetOrder(1))
			SC7->(dbGoTop())
			If SC7->(dbSeek(xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC))
				recLock("SC7", .F.)
				SC7->C7_QUJE	:=	nQty
				msUnlock("SC7")
				SC7->(dbCommit())
			End If
		End If
		SD1->(dbSkip())
	End
	restArea(aSD1)
	restArea(aSC7)
Return

Static Function cantidadSZ2(cPedido, cItem)
	Local	cSerie	:=	"RX"
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX46PEC"
	Local	nResult	:=	0
	
	cQuery	:=	" SELECT Z1_FOLIO"
	cQuery	+=	" FROM " + retSqlName("SZ1")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = 'RX'"
	cQuery	+=	" AND Z1_DOCORI = '" + cPedido + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nResult	:=	(cDatos)->Z1_FOLIO
	End If
	(cDatos)->(dbCloseArea())
	
	If nResult > 0
		cQuery	:=	" SELECT Z2_CANT2"
		cQuery	+=	" FROM " + retSqlName("SZ2")
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z2_SERIE = 'RX'"
		cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(nResult))
		cQuery	+=	" AND Z2_ITEM = " + cItem
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			nResult	:=	(cDatos)->Z2_CANT2
		End If
		(cDatos)->(dbCloseArea())
	End If	
Return (nResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-11
//Fecha de revisión:
//Versión: 1
//Descripción: Saldo por producto.
User Function IMXLIB_QTY(cItem, cDepot)
	Local	cDatos	:=	"IMXLIB1"
	Local	cQuery	:=	""
	Local	nResult	:=	0
	cQuery	:=	" SELECT B2_COD, B2_LOCAL, B2_QATU"
	cQuery	+=	" FROM " + retSqlName("SB2")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND B2_FILIAL = '" + xFilial("SB2") + "'"
	cQuery	+=	" AND B2_COD = '" + cItem + "'"
	cQuery	+=	" AND B2_LOCAL = '" + cDepot + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nResult	:=	(cDatos)->B2_QATU
	End If
	(cDatos)->(dbCloseArea())
Return (nResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-11
//Fecha de revisión:
//Versión: 1
//Descripción: Saldo por lote.
User Function IMXLIB_LOTS(cItem, cDepot)
	Local	aResult	:=	{}
	Local	cDatos	:=	"IMXLIB1"
	Local	cQuery	:=	""
	cQuery	:=	" SELECT B8_PRODUTO, B8_LOCAL, B8_SALDO, B8_LOTECTL, B8_DTVALID"
	cQuery	+=	" FROM " + retSqlName("SB8")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND B8_FILIAL = '" + xFilial("SB8") + "'"
	cQuery	+=	" AND B8_PRODUTO = '" + cItem + "'"
	cQuery	+=	" AND B8_LOCAL = '" + cDepot + "'"
	cQuery	+=	" AND B8_DTVALID >= '" + dToS(DDATABASE) + "'"
	cQuery	+=	" ORDER BY B8_DATA ASC"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(eof())
		aAdd(aResult, {(cDatos)->B8_LOTECTL, (cDatos)->B8_SALDO, sToD((cDatos)->B8_DTVALID)})
		(cDatos)->(dbSkip())
	End If
	(cDatos)->(dbCloseArea())
Return (aResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-11
//Fecha de revisión:
//Versión: 1
//Descripción: Saldo por ubicación.
User Function IMXLIB_UX(cItem, cDepot, cLot)
	Local	aResult	:=	{}
	Local	cDatos	:=	"IMXLIB1"
	Local	cQuery	:=	""
	cQuery	:=	" SELECT BF_PRIOR, BF_LOCALIZ, BF_QUANT"
	cQuery	+=	" FROM " + retSqlName("SBF")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND BF_FILIAL = '" + xFilial("SBF") + "'"
	cQuery	+=	" AND BF_PRODUTO = '" + cItem + "'"
	cQuery	+=	" AND BF_LOCAL = '" + cDepot + "'"
	If cLot != nil .And. !empty(cLot)
		cQuery	+=	" AND BF_LOTECTL = '" + cLot + "'"
	End If
	cQuery	+=	" ORDER BY BF_PRIOR DESC, BF_LOCALIZ ASC"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(eof())
		aAdd(aResult, {(cDatos)->BF_PRIOR, (cDatos)->BF_LOCALIZ, (cDatos)->BF_QUANT})
		(cDatos)->(dbSkip())
	End If
	(cDatos)->(dbCloseArea())
Return (aResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-11
//Fecha de revisión:
//Versión: 1
//Descripción: Controla lote.
User Function IMXLIB_TRACE(cItem)
	Local	aArea	:=	SB1->(getArea())
	Local	lResult	:=	.F.
	If getMV("MV_RASTRO") == "S"
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		If SB1->(dbSeek(xFilial("SB1") + cItem))
			lResult	:=	(SB1->B1_RASTRO == "L")
		End If
	End If
	restArea(aArea)
Return (lResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-11
//Fecha de revisión:
//Versión: 1
//Descripción: Controla ubicación.
User Function IMXLIB_GPS(cItem)
	Local	aArea	:=	SB1->(getArea())
	Local	lResult	:=	.F.
	If getMV("MV_LOCALIZ") == "S"
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		If SB1->(dbSeek(xFilial("SB1") + cItem))
			lResult	:=	(SB1->B1_LOCALIZ == "S")
		End If
	End If
	restArea(aArea)
Return (lResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-11
//Fecha de revisión:
//Versión: 1
//Descripción: Crear tablas.
User Function IMXLIB_SZ(cTable)
	axCadastro(cTable)
Return
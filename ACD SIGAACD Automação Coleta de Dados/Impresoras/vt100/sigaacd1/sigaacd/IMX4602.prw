#Include "APVT100.ch"
#Include "Protheus.ch"
#Include "SIGAACD.ch"

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Versión: 1
//Fecha de revisión:
//Descripción: Movimientos al inventario
User Function IMX4602()
	Local cOpcion  := Space(1)
	Local lProcess := .F.
	Do While .Not. lProcess
		VTClear()
		@00, 00 VTSay "Transferencias de almacen "
		@02, 00 VTSay "1) Nueva transferencia"
		//@03, 00 VTSay "2) Transf. y confirmacion"
		//@04, 00 VTSay "3) Confirmar transferencia"
		//@05, 00 VTSay "4) Revertir documento"
		
		@06, 00 VTSay "0) Menu principal"
		@12, 00 VTSay "Opcion: " VTGet cOpcion Pict "9"
		VTRead()
		Do Case
			Case cOpcion == "0"
				lProcess := .T.
				U_IMX4600A()
			Case cOpcion $ "1|2"
				U_IMX4602A(val(cOpcion))
			Case cOpcion == "3"
				lProcess := .T.
				U_IMX4601A(2, nil)
			/*
			Case cOpcion == "4"
				lProcess := .T.
				U_IMX4602F()
				*/
			Otherwise
				lProcess := .F.
				VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Versión: 1
//Fecha de revisión:
//Descripción: Menú de captura
User Function IMX4602A(nOpcion)
	Local	cOpcion 	:=	space(1)
	Local	cTipo		:=	IIF(nOpcion == 1, "NORM", "CONF")
	Local	lContinuar	:=	.T.	
	Private	lConfirma	:=	(nOpcion == 2)
	Private	aDatos		:=	{}
	Private	aItems		:=	{}
	Private	cDepot1		:=	criaVar("D3_LOCAL")
	Private	cDepot2		:=	criaVar("D3_LOCAL")
	Private	cItems		:=	space(2)
	Private	cDocumento	:=	space(10)
	Do While lContinuar
		vtClear()
		If nOpcion == 1
			@00, 00 vtSay "Nueva transferencia simple"
		ElseIf nOpcion == 2
			@00, 00 vtSay "Nva. trans. y confirmacion"
		ElseIf nOpcion == 3
			@00, 00 vtSay cDepot1 + " >> " + cDepot2 + " | " + cTipo + " | Items " + cItems
		End If
		@02, 00 vtSay "1) Encabezado"
		@03, 00 vtSay "2) Detalle"
		@04, 00 vtSay "3) Capturar productos"
		@05, 00 vtSay "4) Anular captura"
		@06, 00 vtSay "5) Finalizar captura"
		@07, 00 vtSay "6) Cancelar transferencia"
		@09, 00 vtSay "0) Menu anterior"
		@12, 00 vtSay "Opcion: " VTGet cOpcion Pict "9"
		vtRead()
		Do Case
			Case cOpcion == "0"
				lContinuar	:=	.F.
			Case cOpcion == "1"
				U_IMX4602B()
				cDocumento	:=	U_IMX4601K(2, aDatos)
				nOpcion		:=	3
			Case cOpcion == "2"
				If len(aDatos) > 0
					U_IMX4601J(2, aDatos, nil, nil)
				Else
					vtAlert("Primero debe llenar el encabezado.")
				End If
			Case cOpcion $ "3|4"
				If !empty(cDepot1) .And. !empty(cDepot2)
					U_IMX4601D(2, aDatos, val(cOpcion))
				End If
			Case cOpcion == "5"
				grabaSZ2(lConfirma)
				If .Not. lConfirma
					U_IMX4602E(aDatos)
					vtAlert(Chr(13) + Chr(10) + "Transferencia exitosa.", "SIGAACD", .T.)
				End If
				lContinuar	:=	.F.
			Case cOpcion == "6" //Cancelar aquí mismo
				U_IMX4602F(aDatos)
				lContinuar	:=	.F.
			Otherwise
				VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Versión: 1
//Fecha de revisión:
//Descripción: Captura de encabezado
User Function IMX4602B()
	Local	cOrigen		:=	cDepot1
	Local	cDestino	:=	cDepot2
	Local	lContinuar	:=	.T.
	Do While lContinuar
		vtClear()
		@01, 00 vtSay "Almacen origen:  " vtGet cOrigen  VALID existCpo("NNR", cOrigen)
		@02, 00 vtSay "Almacen destino: " vtGet cDestino VALID existCpo("NNR", cDestino)
		vtRead()
		If vtLastKey() == 13
			If .Not. empty(cOrigen) .And. .Not. empty(cDestino)
				cDepot1		:=	cOrigen
				cDepot2		:=	cDestino
				aDatos		:=	newSZ1()
				lContinuar	:=	.F.
			End If
		ElseIf vtLastKey() == 27
			lContinuar	:=	.F.
		End If
	End
Return

static function newSZ1()
	Local	aResult	:=	{}
	Local	cSerie	:=	"TX"
	Local	cQuery	:=	""
	Local	nFolio	:=	0
	Local	nStep	:=	0
	aResult	:=	U_IMX4600B(cSerie, 0)
	For nStep := 1 To Len(aResult)
		If aResult[nStep, 9] == aUser[1, 1]
			nFolio	:=	aResult[nStep, 2]
			cDepot1	:=	IIF(cDepot1 != aResult[nStep, 11], cDepot1, aResult[nStep, 11])
			cDepot2	:=	IIF(cDepot2 != aResult[nStep, 12], cDepot2, aResult[nStep, 12])
			cQuery	:=	" UPDATE " + retSqlName("SZ1") + " SET"
			cQuery	+=	" Z1_DEPOT1 = '" + cDepot1 + "',"
			cQuery	+=	" Z1_DEPOT2 = '" + cDepot2 + "'"
			cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
			cQuery	+=	" AND Z1_SERIE = '" + cSerie + "'"
			cQuery	+=	" AND Z1_FOLIO = " + allTrim(str(nFolio))
			If tcSqlExec(cQuery) < 0
				conOut(tcSqlError())
			End If
			Exit
		End If
	Next
	If nFolio == 0
		nFolio	:=	U_IMX4600F(cSerie)
		RecLock("SZ1", .T.)
		SZ1->Z1_SERIE	:=	cSerie
		SZ1->Z1_FOLIO	:=	nFolio
		SZ1->Z1_ST		:=	0
		SZ1->Z1_FUNC1	:=	"IMX4602"
		SZ1->Z1_DEPOT1	:=	cDepot1
		SZ1->Z1_FECHA1	:=	DDATABASE
		SZ1->Z1_HORA1	:=	subStr(time(), 1, 5)
		SZ1->Z1_UID1	:=	aUser[1, 1]
		SZ1->Z1_UKEY1	:=	aUser[1, 2]
		SZ1->Z1_UNAME1	:=	aUser[1, 4]
		SZ1->Z1_DEPOT2	:=	cDepot2
		MsUnlock()
		aResult	:=	U_IMX4600B(cSerie, 0)
		For nStep := 1 To Len(aResult)
			If aResult[nStep, 9] == aUser[1, 1]
				Exit
			End If
		Next
	End If
return (aResult[nStep])

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión: 2015-04-14
//Versión: 3
//Descripción: Captura de productos (SZ2)
User Function IMX4602C(aDatos)
	Local	lContinuar	:=	.T.
	Private	cZ2_COD		:=	criaVar("Z2_COD1")
	Private	cZ2_DESC	:=	criaVar("Z2_DESC1")
	Private cZ2_LOTE	:=	criaVar("Z2_LOTE1")
	Private cZ2_CANT	:=	Space(8)
	Do While lContinuar
		vtClear()
		@00, 00 vtSay aDatos[1] + " " + allTrim(str(aDatos[2]))
		@01, 00 vtSay "Codigo: " vtGet cZ2_COD Valid decode(cZ2_COD, 1)
		@02, 00 vtGet cZ2_DESC Valid .T.
		@03, 00 vtSay "Lote:   " vtGet cZ2_LOTE Valid decode(cZ2_LOTE, 2)
		@04, 00 vtSay "Cantidad: " vtGet cZ2_CANT Valid decode(cZ2_CANT, 3)
		VTRead()
		If VTLastKey() == 13 //Enter
			If .Not. empty(cZ2_COD) .And. val(cZ2_CANT) > 0
				U_IMX4602D(aDatos)
				cZ2_COD		:=	Space(15)
				cZ2_DESC	:=	Space(23)
				cZ2_LOTE	:=	Space(15)
				cZ2_CANT	:=	Space(7)
			End If
		ElseIf VTLastKey() == 27 //ESC
			lContinuar	:=	.F.
		End If
		vtClear()
		vtClearBuffer()
	End	
Return

static function decode(cBuffer, nOpcion)
	Local	aCodigo	:=	U_IMX4600D(cBuffer)
	Local	lResult	:=	.F.
	If nOpcion == 1
		If .Not. empty(aCodigo[1])
			cZ2_COD		:=	aCodigo[01]
			cZ2_DESC	:=	aCodigo[10]
			lResult	:=	.T.
		End If
	ElseIf nOpcion == 2
		cZ2_LOTE	:=	cBuffer
		lResult	:=	.T.
	ElseIf nOpcion == 3
		If val(cBuffer) > 0
			cZ2_CANT	:=	allTrim(transform(val(cBuffer), "9999.99"))
			lResult	:=	.T.
		End If
	End If
return (lResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-20
//Fecha de revisión:
//Versión: 1
//Descripción: Grabar registro en SZ2
User Function IMX4602D(aDatos)
	Local	nItem	:=	len(U_IMX4600C(aDatos[1], aDatos[2], 1)) + 1
	Local	nRecNo	:=	0
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX4602D"
	cQuery	:=	" SELECT MAX(R_E_C_N_O_) AS ULTIMO FROM " + retSqlName("SZ2")
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nRecNo	:=	(cDatos)->ULTIMO + 1
	End If
	(cDatos)->(dbCloseArea())
	cQuery	:=	" INSERT INTO " + retSqlName("SZ2")
	cQuery	+=	" (D_E_L_E_T_, R_E_C_N_O_, Z2_SERIE, Z2_FOLIO, Z2_ITEM, Z2_ST,
	cQuery	+=	" Z2_COD1, Z2_DESC1, Z2_LOTE1, Z2_CANT1, Z2_FECHA, Z2_HORA) VALUES("
	cQuery	+=	"' ',"
	cQuery	+=	allTrim(str(nRecNo)) + ","
	cQuery	+=	"'" + aDatos[1] + "',"
	cQuery	+=	allTrim(str(aDatos[2])) + ","
	cQuery	+=	allTrim(str(nItem)) + ","
	cQuery	+=	"0,"
	cQuery	+=	"'" + cZ2_COD + "',"
	cQuery	+=	"'" + cZ2_DESC + "',"
	cQuery	+=	"'" + cZ2_LOTE + "',"
	cQuery	+=	cZ2_CANT + ","
	cQuery	+=	"'" + dToS(DDATABASE) + "',"
	cQuery	+=	"'" + subStr(time(), 1, 5) + "')"
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
return

static function grabaSZ2(lConfirma)
	Local	cQuery	:=	""
	dbSelectArea("SZ2")
	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(1))
	SZ3->(dbSeek(xFilial("SZ3") + cDocumento))
	Do While SZ3->Z3_DOC == cDocumento .And. !SZ3->(eof())		
		recLock("SZ2", .T.)
		SZ2->Z2_FILIAL	:=	xFilial("SZ2")
		SZ2->Z2_SERIE	:=	aDatos[1]
		SZ2->Z2_FOLIO	:=	aDatos[2]
		SZ2->Z2_ITEM	:=	SZ3->Z3_IDX
		SZ2->Z2_ST		:=	2
		SZ2->Z2_COD1	:=	SZ3->Z3_COD
		SZ2->Z2_DESC1	:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_DESC")
		SZ2->Z2_UM1		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_UM")
		SZ2->Z2_CANT1	:=	SZ3->Z3_QTY
		SZ2->Z2_LOTE1	:=	SZ3->Z3_LOT
		If .Not. lConfirma
			SZ2->Z2_COD2	:=	SZ3->Z3_COD
			SZ2->Z2_DESC2	:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_DESC")
			SZ2->Z2_UM2		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_UM")
			SZ2->Z2_CANT2	:=	SZ3->Z3_QTY
			SZ2->Z2_LOTE2	:=	SZ3->Z3_LOT
			SZ2->Z2_FECHA	:=	dDatabase
			SZ2->Z2_HORA	:=	subStr(time(), 1, 5)
		End If
		msUnlock("SZ2")
		SZ2->(dbCommit())		
		SZ3->(dbSkip())
	End
	
	cQuery	+=	" UPDATE " + retSqlName("SZ1") + " SET"
	cQuery	+=	" Z1_ST	= 2"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z1_FOLIO = " + allTrim(str(aDatos[2]))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If

Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión:
//Versión: 1
//Descripción: Confirmar movimiento
User Function IMX4602E(aDatos)
	Local	aItem		:=	{}
	Local	aMATA261	:=	{}
	Local	cQuery		:=	""
	Local	cDatos		:=	"IMX4601E"
	Local	cSerie		:=	""
	Local	cFolio		:=	""
	Local	xFolio
	Private	lMsErroAuto	:=	.F.
		
	//Siguiente número
	xFolio	:=	nextNumero("SD3", 2, "D3_DOC", .T.)

	//Encabezado
	aAdd(aMATA261, {xFolio, DDATABASE})
	
	cQuery	:=	" SELECT * FROM " + retSqlName("SZ2")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(eof())
		aItem	:=	{}
		aAdd(aItem, subStr((cDatos)->Z2_COD1, 1, 15))
		aAdd(aItem, subStr((cDatos)->Z2_DESC1, 1, 30))
		aAdd(aItem, subStr((cDatos)->Z2_UM1, 1, 2))
		aAdd(aItem, subStr(cDepot1, 1, 2))
		aAdd(aItem, space(15)) //ubicacion
		aAdd(aItem, subStr((cDatos)->Z2_COD1, 1, 15))
		aAdd(aItem, subStr((cDatos)->Z2_DESC1, 1, 30))
		aAdd(aItem, subStr((cDatos)->Z2_UM1, 1, 2))
		aAdd(aItem, subStr(cDepot2, 1, 2))
		aAdd(aItem, criaVar("D3_LOCALIZ"))
		aAdd(aItem, criaVar("D3_NUMSERI"))
		aAdd(aItem, subStr((cDatos)->Z2_LOTE1, 1, 10))
		aAdd(aItem, criaVar("D3_NUMLOTE"))
		aAdd(aItem, criaVar("D3_DTVALID"))
		aAdd(aItem, criaVar("D3_POTENCI"))
		aAdd(aItem, (cDatos)->Z2_CANT1)
		aAdd(aItem, criaVar("D3_QTSEGUM"))
		aAdd(aItem, criaVar("D3_ESTORNO"))
		aAdd(aItem, criaVar("D3_NUMSEQ"))
		aAdd(aItem, subStr((cDatos)->Z2_LOTE1, 1, 10))
		aAdd(aItem, criaVar("D3_DTVALID"))
		aAdd(aItem, criaVar("D3_ITEMGRD"))
		aAdd(aMATA261, aClone(aItem))
		(cDatos)->(dbSkip())
	End
	(cDatos)->(dbCloseArea())
	
	//Llamada a función automática
	MSExecAuto({|X| MATA261(X)}, aMATA261, 3) //3 = Incluir
	//Si existen errores
	If lMsErroAuto
		DisarmTransaction()
		cFileLog := NomeAutoLog()
		MostraErro(GetSrvProfString("Startpath",""), cFileLog + ".log")	
	End If
	
	cQuery	:=	" UPDATE " + retSqlName("SZ2") + " SET"
	cQuery	+=	" Z2_ST = 3"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
	
	cQuery	:=	" UPDATE " + retSqlName("SZ1") + " SET"
	cQuery	+=	" Z1_DOCORI = '" + xFolio + "',"
	cQuery	+=	" Z1_ST = 3,"
	cQuery	+=	" Z1_FUNC2 = 'MATA261',"
	cQuery	+=	" Z1_FECHA2 = '" + dToS(DDATABASE) + "',"
	cQuery	+=	" Z1_HORA2 = '" + subStr(time(), 1, 5) + "',"
	cQuery	+=	" Z1_UID2 = '" + aUser[1, 1] + "',"
	cQuery	+=	" Z1_UKEY2 = '" + aUser[1, 2] + "',"
	cQuery	+=	" Z1_UNAME2 = '" + aUser[1, 4] + "'"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z1_FOLIO = " + allTrim(str(aDatos[2]))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión:
//Versión: 1
//Descripción: Cancelar la captura
User Function IMX4602F(aDatos)
	Local	cQuery	:=	""
	cQuery	+=	" UPDATE " + retSqlName("SZ1") + " SET"
	cQuery	+=	" Z1_ST	= 99"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z1_FOLIO = " + allTrim(str(aDatos[2]))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
	cQuery	+=	" UPDATE " + retSqlName("SZ2") + " SET"
	cQuery	+=	" Z2_ST	= 99"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
Return

//Confirmar transferencia
User Function IMX4602G(aDatos)
	Private	cDocumento	:=	""
	//crea un nuevo documento en SZ3 para la misma TX
	/*dialogo con la lista:
	1)Ver detalle //ejecuta el detalle SZ2
	2)Ver captura //ejecuta el detalle SZ3
	2)Capturar productos //ejecuta captura
	3)Anular captura // ejecuta captura anulación
	4)Confirmar transferencia //ejecuta actualización sz2 y mxexecauto, avisa al usuario el éxito.	
	*/
Return

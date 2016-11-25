#include "apvt100.ch"
#include "fileio.ch"
#include "protheus.ch"
#include "sigaacd.ch"

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2016-01-20
//Fecha de revisión 2: 2016-03-11
//Versión: 2
//Descripción: Devoluciones, menú principal
User Function IMX4609(nApp)
	Local	cOpcion		:=	Space(1)
	Local	lContinuar	:=	.T.
	Do While lContinuar
		vtClear()
		If nApp == 4
			@00, 00 vtSay "======== Devoluciones ========"
		End If
		@02, 00 vtSay "1) Seleccionar documento"
		@05, 00 vtSay "0) Menu principal"
		@12, 00 vtSay "Opcion: " vtGet cOpcion Pict "9"
		vtRead()
		Do Case
			Case cOpcion == "0"
				lContinuar	:=	.F.
				U_IMX4600A()
			Case cOpcion == "1"
				U_IMX4609A(nApp)
			Otherwise
				vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión: 2015-05-11
//Versión: 2
//Descripción: Listado de documentos.
User Function IMX4609A(nApp, nOpcion)
	Local	aDatos		:=	{}
	Local	cOpcion		:=	space(1)
	Local	lContinuar	:=	.T.
	Local	nPos		:=	0
	Local	nStart		:=	0
	Local	nStep		:=	0
	Local	cPageNo		:=	space(3)
	Do While lContinuar
		nPos := 0
		vtClear()
		If nOpcion == Nil
			cPageNo	:=	PADL("1", 3)
		Else
			cPageNo	:=	PADL(nOpcion + 1, 3)
		End If
		If nApp == 4
			aDatos	:=	U_IMX4600L(1)
			@00, 00 vtSay "======= Devoluciones ======" + cPageNo
		End If
		If nOpcion == Nil
			nStart	:=	1
		Else
			nStart	:=	1 + (nOpcion * 8)
		End If
		For nStep := nStart To nStart + 7
			If Len(aDatos) >= nStep
				nPos += 1
				If nApp != 2
					@nPos, 00 vtSay allTrim(STR(nPos)) + ") " + aDatos[nStep][1] + ":" + subStr(aDatos[nStep][4], 1, 16)
				Else
					@nPos, 00 vtSay allTrim(STR(nPos)) + ") " + aDatos[nStep][1] + "-" + strZero(aDatos[nStep][2], 12)
				End If
			End If
		Next nStep
		If Len(aDatos) > nStep
			@09, 00 vtSay "9) Pagina siguiente"
		End If
		If nOpcion != Nil
			@10, 00 vtSay "0) Pagina anterior"
		Else
			@10, 00 vtSay "0) Menu anterior"
		End If
		@12, 00 vtSay "Opcion: " vtGet cOpcion Pict "9"
		vtRead()
		Do Case
			Case cOpcion == "0"
				lContinuar	:=	.F.
				If nOpcion != Nil
					nOpcion	-=	1
					If nOpcion == 0
						nOpcion	:=	Nil
					End If
					U_IMX4609A(nApp, nOpcion)
				Else
					U_IMX4609(nApp)
				End If
			Case cOpcion $ "1|2|3|4|5|6|7|8"
				If Val(cOpcion) <= nPos
					lContinuar	:=	.F.
					nPos		:=	iIf(nOpcion != Nil, (nOpcion * 8) + val(cOpcion), val(cOpcion))
					If nApp != 2
						U_IMX4609B(nApp, aDatos[nPos])
					End If
				Else
					vTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
				End If
			Case cOpcion == "9"
				If Len(aDatos) > nStep
					lContinuar	:=	.F.
					If nOpcion != Nil
						nOpcion	+=	1
					Else
						nOpcion	:=	1
					End If
					U_IMX4609A(nApp, nOpcion)
				Else
					vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
				End If
			Otherwise
				vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión: 2015-05-11
//Versión: 2
//Descripción: Opciones del documento
User Function IMX4609B(nApp, aDatos)
	Local	cOpcion		:=	Space(1)
	Local	lContinuar	:=	.T.
	Private	cDocumento	:=	aDatos[1]
	Do While lContinuar
		vtClear()
		@00, 00 vtSay aDatos[1] + ":" + SubSTR(aDatos[4], 1, 20)
		@02, 00 vtSay "1) Detalle del documento"
		@03, 00 vtSay "2) Ver captura actual"
		@04, 00 vtSay "3) Capturar productos"
		@05, 00 vtSay "4) Anular producto"
		@06, 00 vtSay "5) Finalizar captura"
		@09, 00 vtSay "0) Menu anterior"
		@12, 00 vtSay "Opcion: " vtGet cOpcion Pict "9"
		vtRead()
		Do Case
			Case cOpcion == "0" //Menu anterior
				lContinuar := .F.
				If nApp == 4
					U_IMX4609A(nApp)
				End If
			Case cOpcion == "1" //Ver documento
				U_IMX4609C(nApp, aDatos)
			Case cOpcion == "2" //Ver captura
				U_IMX4609J(nApp, aDatos)
			Case cOpcion $ "3|4" //Capturar productos
				U_IMX4609D(nApp, aDatos, val(cOpcion))
			Case cOpcion == "5" //Finalizar captura
				U_IMX4609G(nApp, aDatos)
				lContinuar := .F.
			Otherwise
				vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
		End
		vtClear()
		vtClearBuffer()
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión: 2015-05-11
//Versión: 2
//Descripción: Lista el contenido del documento.
User Function IMX4609C(nApp, aDatos, nOpcion, aSZ2)
	Local	aItems 		:=	IIf(aSZ2 != Nil, aClone(aSZ2), U_IMX4600L(2, aDatos[1]))
	Local	cCodigo		:=	""
	Local	cCant		:=	""
	Local	cItem		:=	""
	Local	cOpcion		:=	Space(1)
	Local	lContinue	:=	.T.
	Local	nPos		:=	0
	Local	nStart		:=	0
	Local	nStep		:=	0
	Local 	nCantidad	:=	0
	Do While lContinue
		vtClear()
		@00, 00 vtSay aDatos[1] + ":" + SubSTR(aDatos[4], 1, 20)
		@01, 00 vtSay "  |   Producto    |  Dev.Per. "
		@02, 00 vtSay "--|---------------|-----------"
		nPos := 2
		If nOpcion == Nil
			nStart := 1
		Else
			nStart := 1 + (nOpcion * 7)
		End If
		For nStep := nStart To nStart + 6
			If Len(aItems) >= nStep
				cItem	:=	space(2)
				If len(aItems[nStep][6]) >= 15
					cCodigo	:=	subStr(aItems[nStep][6], 1, 15)
				Else
					cCodigo	:=	padR(aItems[nStep][6], 15)
				End If
				nCantidad	:=	aItems[nStep][12] - aItems[nStep][16]
				cCant	:=	allTrim(transform(nCantidad, "999,999.99"))
				cCant	:=	padL(cCant, 11)
				nPos	+=	1
				@nPos, 00 vtSay cItem + "|" + cCodigo + "|" + cCant
			End If
		Next
		If len(aItems) > nStep
			@10, 00 vtSay "9) Pagina siguiente"
		End If
		If nOpcion != Nil
			@11, 00 vtSay "0) Pagina anterior"
		Else
			@11, 00 vtSay "0) Menu anterior"
		End If
		@12, 00 vtSay "Opcion: " VTGet cOpcion Pict "9"
		vtRead()
		Do Case
			Case cOpcion == "0"
				lContinue	:=	.F.
				If nOpcion != Nil
					nOpcion -= 1
					If nOpcion == 0
						nOpcion := Nil
					End If
					U_IMX4609C(nApp, aDatos, nOpcion, aItems)
				End If
			Case cOpcion == "9"
				If Len(aItems) > nStep
					lContinue	:=	.F.
					If nOpcion != Nil
						nOpcion	+=	1
					Else
						nOpcion	:=	1
					End If
					U_IMX4609C(nApp, aDatos, nOpcion, aItems)
				Else
					vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
				End If
			Otherwise
				vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Fecha de revisión: 2015-05-13
//Versión: 3
//Descripción: Captura de productos
User Function IMX4609D(nApp, aDatos, nOpcion, lConfirma)
	Local	lContinuar	:=	.T.
	Private	AUTO_LOT	:=	(superGetMv("MV_IMX4611", .F., "S") == "S")
	Private	nZ3_ITEM	:=	0
	Private cLote		:=	criaVar("Z3_LOT")
	Private cLocX		:=	criaVar("Z3_LOC")
	Private	cZ3_COD		:=	criaVar("Z3_COD")
	Private	cZ3_DESC	:=	criaVar("Z3_DESC")
	Private cZ3_LOT		:=	criaVar("Z3_LOT")
	Private cZ3_LOC		:=	criaVar("Z3_LOC")
	Private cZ3_DEPOT	:=	criaVar("Z3_DEPOT")
	Private cZ3_QTY		:=	Space(11)
	Private nZ8_DEVPER	:=	0
	Private nZ3_COSTO	:=	0
	Private	lAnula		:= (nOpcion == 4)
	Do While lContinuar
		drawDialog(nApp, aDatos)
		If vtLastKey() == 13 //Enter
			U_IMX4609F(nApp, aDatos, nOpcion)
			cZ3_COD		:=	criaVar("Z3_COD")
			cZ3_DESC	:=	criaVar("Z3_DESC")
			cZ3_LOT		:=	criaVar("Z3_LOT")
			cLote		:=	criaVar("Z3_LOT")
			cZ3_LOC		:=	criaVar("Z3_LOC")
			cLocX		:=	criaVar("Z3_LOC")
			cZ3_QTY		:=	Space(11)
		ElseIf vtLastKey() == 27 //ESC
			lContinuar	:=	.F.
			vtSetKey(12)
			vtSetKey(21)
		End If
	End
Return

static function drawDialog(nApp, aDatos)
	vtClear()
	@00, 00 vtSay aDatos[1] + ":" + subSTR(aDatos[4], 1, 20)
	@02, 00 vtSay "Codigo: " vtGet cZ3_COD VALID actualizar(nApp, 1, cZ3_COD, aDatos)
	If AUTO_LOT
		@03, 00 vtSay "Cant. : " vtGet cZ3_QTY PICT "99999999.99" VALID actualizar(nApp, 3, cZ3_QTY, aDatos)
		vtSetKey(12)
		vtSetKey(21)
	Else
		@03, 00 vtGet cZ3_DESC
		@04, 00 vtSay "Lote " vtGet cZ3_LOT VALID actualizar(nApp, 2, cZ3_LOT, aDatos)
		@05, 00 vtSay "Cant " vtGet cZ3_QTY PICT "99999999.99" VALID actualizar(nApp, 3, cZ3_QTY, aDatos)
		@06, 00 vtSay "Ubic " vtGet cZ3_LOC VALID actualizar(nApp, 4, cZ3_LOC, aDatos)
		vtSetKey(12, {||lote(nApp, aDatos)})
		vtSetKey(21, {||ubic(nApp, aDatos)})
	End If
	vtRead()
return nil

static function lote(nApp, aDatos)
	Local	aPrev	:=	{}
	Local	aItems	:=	{}
	Local	aValid	:=	{}
	Local	aSaldo	:=	{}
	Local	cLine	:=	""
	Local	lLine	:=	.F.
	Local	nPos	:=	0
	Local	i
	If .Not. empty(cZ3_COD)
		If .Not. U_IMXLIB_TRACE(cZ3_COD)
			Return nil
		End If
		aPrev	:=	vtSave()
		aSaldo	:=	U_IMXLIB_LOTS(cZ3_COD, cZ3_DEPOT)
		If len(aSaldo) == 0
			vtAlert("El producto no cuenta con lotes disponibles.", "Modulo RF", .T.)
			Return nil
		End If
		For i := -1 To len(aSaldo)
			Do Case
				Case i == -1
					cLine	:=	"     Lote     |Vigencia| Cant."
				Case i == 0
					cLine	:=	"--------------|--------|------"
				Otherwise
					cLine	:=	padR(subStr(aSaldo[i, 1], 1, 14), 14) + "|"
					cLine	+=	subStr(dToC(aSaldo[i, 3]), 1, 6) + subStr(dToC(aSaldo[i, 3]), 9, 2) + "|"
					cLine	+=	padL(allTrim(transform(aSaldo[i, 2], "99999")), 5)
					lLine	:=	.T.
			End
			aAdd(aItems, cLine)
			aAdd(aValid, lLine)
		Next
		nPos	:=	vtAChoice(0, 0, vtMaxRow(), vtMaxCol(), aItems, aValid) - 2
		cLote	:=	iIf(nPos > 0, aSaldo[nPos, 1], criaVar("Z3_LOT"))
		cZ3_LOT	:=	cLote
		drawDialog(nApp, aDatos)
	Else
		vtAlert("Primero debe capturar el producto", "Modulo RF", .T.)
	End If
return nil

static function ubic(nApp, aDatos)
	Local	aPrev	:=	{}
	Local	aItems	:=	{}
	Local	aValid	:=	{}
	Local	aSaldo	:=	{}
	Local	cLine	:=	""
	Local	lLine	:=	.F.
	Local	nPos	:=	0
	Local	i
	If .Not. empty(cZ3_COD)
		If .Not. U_IMXLIB_GPS(cZ3_COD)
			Return nil
		End If
		aPrev	:=	vtSave()
		aSaldo	:=	U_IMXLIB_UX(cZ3_COD, cZ3_DEPOT, cZ3_LOT)
		If len(aSaldo) == 0
			Return nil
		End If
		For i := -1 To len(aSaldo)
			Do Case
				Case i == -1
					cLine	:=	" * |   Ubicacion   | Cantidad "
				Case i == 0
					cLine	:=	"---|---------------|----------"
				Otherwise
					cLine	:=	padR(subStr(aSaldo[i, 1], 1, 3), 3) + "|"
					cLine	+=	padR(subStr(aSaldo[i, 2], 1, 15), 15) + "|"
					cLine	+=	padL(allTrim(transform(aSaldo[i, 3], "999,999.99")), 9)
					lLine	:=	.T.
			End
			aAdd(aItems, cLine)
			aAdd(aValid, lLine)
		Next
		nPos	:=	vtAChoice(0, 0, vtMaxRow(), vtMaxCol(), aItems, aValid) - 2
		cLocX	:=	iIf(nPos > 0, aSaldo[nPos, 2], criaVar("Z3_LOC"))
		cZ3_LOC	:=	cLocX
		drawDialog(nApp, aDatos)
	Else
		vtAlert("Primero debe capturar el producto", "Modulo RF", .T.)
	End If
return nil

static function actualizar(nApp, nOpcion, cBuffer, aDatos)
	Local	nOriPK	:=	0
	Local	nQtyPK	:=	0
	Local	nTotPK	:=	0
	Local	lResult	:=	.F.
	lResult	:=	U_IMX4609E(nApp, nOpcion, cBuffer, aDatos)
	If .Not. AUTO_LOT
		vtGetRefresh(cZ3_COD)
		vtGetRefresh(cZ3_DESC)
		vtGetRefresh(cZ3_LOT)
		vtGetRefresh(cZ3_QTY)
		If nOpcion == 2
			cZ3_LOT	:=	iIf(empty(cBuffer), cLote, cBuffer)
			If U_IMXLIB_TRACE(cZ3_COD) .And. empty(cZ3_LOT)
				vtAlert("El producto controla lote.", "Modulo RF", .T.)
				lResult	:=	.F.
			Else
				@04, 00 vtSay "Lote " vtGet cZ3_LOT VALID actualizar(nApp, 2, cZ3_LOT, aDatos)
			End If
		ElseIf nOpcion == 4
			cZ3_LOC	:=	iIf(empty(cBuffer), cLocX, cBuffer)
			If U_IMXLIB_GPS(cZ3_COD) .And. empty(cZ3_LOC) .And. nApp == 3
				vtAlert("El producto controla ubicacion.", "Modulo RF", .T.)
				lResult	:=	.F.
			Else
				lResult	:=	.T.
				@06, 00 vtSay "Ubic " vtGet cZ3_LOC VALID actualizar(nApp, 4, cZ3_LOC, aDatos)
			End If
		End
	Else
		If nOpcion == 3 .And. .Not. lAnula
			nOriPK	:=	nZ8_DEVPER
			nQtyPK	:=	val(cZ3_QTY)
			nTotPK	:=	totalPicking(nApp, nOpcion, cBuffer, aDatos, cZ3_COD)
			If (nTotPK + nQtyPK) > nOriPK
				vtAlert("La cantidad no puede exceder a la autorizada.", "Modulo RF", .T.)
				lResult	:=	.F.
			End IF
		ElseIf nOpcion == 1 .And. .Not. lResult
			vtAlert("El producto no pertenece al pedido.", "Modulo RF", .T.)
		End If
	End If
return (lResult)

static Function totalPicking(nApp, nOpcion, cBuffer, aDatos, cItem, cLot, cLoc)
	Local	nResult	:=	0
	Local	cDatos	:=	"IMX46_SZ3"
	Local	cQuery	:=	""
	cQuery	:=	" SELECT SUM(Z3_QTY) AS SUMA"
	cQuery	+=	" FROM " + retSqlName("SZ3")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z3_FILIAL = '" + xFilial("SZ3") + "'"
	cQuery	+=	" AND Z3_DOC = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z3_COD = '" + allTrim(cItem) + "'"
	If cLot != nil .And. !empty(cLot)
		cQuery	+=	" AND Z3_LOT = '" + allTrim(cLot) + "'"
	End If
	If cLoc != nil .And. !empty(cLoc)
		cQuery	+=	" AND Z3_LOC = '" + allTrim(cLoc) + "'"
	End If
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nResult	:=	(cDatos)->SUMA
	End If
	(cDatos)->(dbCloseArea())
return nResult

static Function pickingQty(nApp, nOpcion, cBuffer, aDatos, cItem)
	Local	nResult	:=	0
	Local	nResult	:=	0
	Local	cDatos	:=	"IMX46_SZ2"
	Local	cQuery	:=	""
	cQuery	:=	" SELECT SUM(Z2_CANT1) AS SUMA"
	cQuery	+=	" FROM " + retSqlName("SZ2")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_FILIAL = '" + xFilial("SZ2") + "'"
	cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
	cQuery	+=	" AND Z2_COD1 = '" + allTrim(cItem) + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nResult	:=	(cDatos)->SUMA
	End If
	(cDatos)->(dbCloseArea())
return nResult

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-20
//Fecha de revisión: 2015-05-14
//Versión: 2
//Descripción: Decodificación/Validación del código de barras.
User Function IMX4609E(nApp, nOpcion, cBuffer, aDatos, lConfirma)
	Local	aCodigo	:=	U_IMX4600D(cBuffer)
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX4609E"
	Local	lResult	:=	.F.
	Local	nCant2	:=	0
	If nOpcion == 1
		If aCodigo[1] != "" .Or. aCodigo[3] != ""
			If nApp != 2 .Or. lConfirma != Nil
				cQuery	:=	" SELECT DISTINCT Z8_COD AS COD, SUM(Z8_SOLQTY) AS QTY"
				cQuery	+=	" FROM " + RetSqlName("SZ8")
				cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
				cQuery	+=	" AND Z8_DOC = '" + aDatos[1] + "'"
				cQuery	+=	" AND Z8_COD = '" + aCodigo[1] + "'"
				cQuery	+=	" GROUP BY Z8_COD"
				dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
				If .Not. (cDatos)->(eof())
					lResult		:=	.T.
					nZ3_ITEM	:=	0
					cZ3_COD		:= 	(cDatos)->COD
					cZ3_DESC	:= 	posicione("SB1", 1, xFilial("SB1") + (cDatos)->COD, "B1_DESC")
					cZ3_DEPOT	:=	posicione("SB1", 1, xFilial("SB1") + (cDatos)->COD, "B1_LOCPAD")
					nZ3_COSTO	:=	posicione("SB2", 1, xFilial("SB2") + padR(allTrim((cDatos)->COD), tamSX3("B2_COD")[1]) + cZ3_DEPOT, "B2_CM1")
					nZ8_DEVPER	:=	(cDatos)->QTY
					(cDatos)->(dbCloseArea())
				Else
					vtAlert("El producto no pertenece a este pedido.", "Modulo RF", .T.)
					(cDatos)->(dbCloseArea())
					Return (lResult)
				End If
			Else
				cQuery	:=	" SELECT B1_COD, B1_DESC"
				cQuery	+=	" FROM " + RetSqlName("SB1")
				cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
				cQuery	+=	" AND B1_COD = '" + aCodigo[1] + "'"
				dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
				If .Not. (cDatos)->(eof())
					lResult		:=	.T.
					nZ3_ITEM	:=	0
					cZ3_COD		:= 	(cDatos)->B1_COD
					cZ3_DESC	:= 	subStr((cDatos)->B1_DESC, 1, 23)
					nZ3_COSTO	:=	0
					(cDatos)->(dbCloseArea())
				Else
					vtAlert("Archivo no encontrado.", "Modulo RF", .T.)
					(cDatos)->(dbCloseArea())
					Return (lResult)
				End If
			End If
		End If
	ElseIf nOpcion == 2
		lResult	:=	.T.
		If !empty(aCodigo[4])
			cZ3_LOT	:=	space(30)
			vtGetRefresh(cZ3_LOT)
			cZ3_LOT	:=	aCodigo[4]
			vtGetRefresh(cZ3_LOT)
		Else
			If .Not. empty(cBuffer)
				cZ3_LOT	:=	cBuffer
			End If
		End If
	ElseIf nOpcion == 3
		If aCodigo[9] > 0
			lResult	:=	.T.
			cZ3_QTY	:=	allTrim(transform(aCodigo[9], "99999999.99"))
		Else
			If val(cBuffer) > 0
				lResult	:=	.T.
				cZ3_QTY	:=	allTrim(transform(val(cBuffer), "99999999.99"))
			End If
		End If
	End If
	If aCodigo[9] > 0 .And. val(cZ3_QTY) <= 0
		cZ3_QTY	:=	allTrim(transform(aCodigo[9], "99999999.99"))
	End If
Return (lResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-20
//Fecha de revisión 2: 2015-05-14
//Fecha de revisión 3: 2016-03-09
//Versión: 3
//Descripción: Registro en SZ3
User Function IMX4609F(nApp, aDatos, nOpcion)
	Local	aUser		:=	pswRet()
	Local	cDatos	:=	"IMX4609F"
	Local	cQuery	:=	""
	Local	lDelete	:=	.F.
	Local	lUpdate	:=	.F.
	Local	nRecord	:=	0
	Local	nTotPK	:=	0
	Local	nCant	:=	0
	Local	nSaldo	:=	0
	Local	nCount	:=	0
	
	If nOpcion == 3
		cQuery	:=	" SELECT MAX(Z3_IDX) AS ULTIMO"
		cQuery	+=	" FROM " + RetSqlName("SZ3")
		cQuery	+=	" WHERE Z3_DOC = '" + cDocumento + "'"
		dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			lUpdate	:=	.T.
			nRecord	:=	(cDatos)->ULTIMO + 1
		Else
			nRecord	:=	1
		End If
		(cDatos)->(dbCloseArea())
	ElseIf	nOpcion == 4
		cQuery	:=	" SELECT R_E_C_N_O_"
		cQuery	+=	" FROM " + retSqlName("SZ3")
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z3_REMSER = ''"
		cQuery	+=	" AND Z3_REMDOC = ''"
		cQuery	+=	" AND Z3_DOC = '" + cDocumento + "'"
		cQuery	+=	" AND Z3_COD = '" + cZ3_COD + "'"
		cQuery	+=	" AND Z3_QTY = "  + cZ3_QTY
		If .Not. AUTO_LOT
			If U_IMXLIB_TRACE(cZ3_COD)
				cQuery	+=	" AND Z3_LOT = '" + cZ3_LOT + "'"
			End If
			If U_IMXLIB_GPS(cZ3_COD)
				cQuery	+=	" AND Z3_LOC = '" + cZ3_LOC + "'"
			End If
		End If
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			lDelete	:=	.T.
			nRecord	:=	(cDatos)->R_E_C_N_O_
		Else
			vtAlert("Archivo no encontrado.", "Modulo RF", .T.)
		End If
		(cDatos)->(dbCloseArea())
	End If
	
	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(1))
	If lDelete
		SZ3->(dbGoTo(nRecord))
		recLock("SZ3", .F.)
		SZ3->(dbDelete())
		msUnlock("SZ3")
		SZ3->(dbCommit())
	End If
	
	If nOpcion == 3 .And. AUTO_LOT .And. (U_IMXLIB_TRACE(cZ3_COD) .Or. U_IMXLIB_GPS(cZ3_COD))
		nSaldo	:=	val(cZ3_QTY)
		cQuery	:=	" SELECT DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ, DC_QUANT"
		cQuery	+=	" FROM " + retSqlName("SDC")
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND DC_FILIAL = '" + xFilial("SDC") + "'"
		cQuery	+=	" AND DC_ORIGEM = 'SC6'"
		cQuery	+=	" AND DC_PEDIDO = '" + aDatos[4] + "'"
		cQuery	+=	" AND DC_ITEM = '" + strZero(nZ3_ITEM, tamSX3("DC_ITEM")[1]) + "'"
		cQuery	+=	" AND DC_PRODUTO = '" + cZ3_COD + "'"
		cQuery	+=	" AND DC_LOCAL = '" + cZ3_DEPOT + "'"
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		Do While .Not. (cDatos)->(eof())
			If nSaldo > 0
				nTotPK	:=	totalPicking(nApp, nOpcion, nil, aDatos, (cDatos)->DC_PRODUTO, (cDatos)->DC_LOTECTL, (cDatos)->DC_LOCALIZ)
				If ((cDatos)->DC_QUANT - nTotPK) >= nSaldo
					nCant	:=	nSaldo
					nSaldo	:=	0
				Else
					nCant	:=	((cDatos)->DC_QUANT - nTotPK)
					nSaldo	:=	val(cZ3_QTY) - (((cDatos)->DC_QUANT - nTotPK))
				End If
				//Grabar
				If nCant > 0
					recLock("SZ3", .T.)
					SZ3->Z3_FILIAL	:=	xFilial("SZ3")
					SZ3->Z3_DOC		:=	cDocumento
					SZ3->Z3_IDX		:=	nRecord + nCount
					SZ3->Z3_COD		:=	(cDatos)->DC_PRODUTO
					SZ3->Z3_LOT		:=	(cDatos)->DC_LOTECTL
					SZ3->Z3_LOC		:=	(cDatos)->DC_LOCALIZ
					SZ3->Z3_DEPOT	:=	cZ3_DEPOT
					SZ3->Z3_QTY		:=	nCant
					SZ3->Z3_DESC	:=	cZ3_DESC
					SZ3->Z3_SERIE	:=	aDatos[1]
					SZ3->Z3_FOLIO	:=	aDatos[2]
					SZ3->Z3_ITEM	:=	nZ3_ITEM
					SZ3->Z3_COSTO	:=	nZ3_COSTO
					SZ3->Z3_PACKING	:=	"N"
					SZ3->Z3_TIPO	:=	posicione("SB1", 1, xFilial("SB1") + cZ3_COD, "B1_TIPO")
					//Usuario
					SZ3->Z3_UID		:=	aUser[1, 1]
					SZ3->Z3_UKEY	:=	aUser[1, 2]
					SZ3->Z3_UNAME	:=	aUser[1, 4]
					msUnlock("SZ3")
				End If
			End If
			lUpdate	:=	.F.
			nCount	+=	1
			(cDatos)->(dbSkip())
		End
		(cDatos)->(dbCloseArea())
		//Si no hay reservas en SDC deberá usar lotes y ubicaciones FIFO
		If nCount == 0
			//lógica aquí
		End If
	End If
	
	If lUpdate .And. val(cZ3_QTY) > 0
		recLock("SZ3", .T.)
		SZ3->Z3_FILIAL	:=	xFilial("SZ3")
		SZ3->Z3_DOC		:=	cDocumento
		SZ3->Z3_IDX		:=	nRecord
		SZ3->Z3_COD		:=	cZ3_COD
		SZ3->Z3_LOT		:=	cZ3_LOT
		SZ3->Z3_LOC		:=	cZ3_LOC
		SZ3->Z3_DEPOT	:=	cZ3_DEPOT
		SZ3->Z3_QTY		:=	val(cZ3_QTY)
		SZ3->Z3_DESC	:=	cZ3_DESC
		SZ3->Z3_SERIE	:=	"DV"
		SZ3->Z3_FOLIO	:=	val(cDocumento)
		SZ3->Z3_ITEM	:=	nZ3_ITEM
		SZ3->Z3_COSTO	:=	nZ3_COSTO
		SZ3->Z3_PACKING	:=	"N"
		SZ3->Z3_TIPO	:=	posicione("SB1", 1, xFilial("SB1") + cZ3_COD, "B1_TIPO")
		//Usuario
		SZ3->Z3_UID		:=	aUser[1, 1]
		SZ3->Z3_UKEY	:=	aUser[1, 2]
		SZ3->Z3_UNAME	:=	aUser[1, 4]
		msUnlock("SZ3")
	End If
		
	//updateSZ2(aDatos, lDelete)
	
Return

Static Function updateSZ2(aDatos, lDelete)
	Local	cQuery	:=	""
	cQuery	+=	" UPDATE " + retSqlName("SZ2") + " SET"
	If lDelete
		cQuery	+=	" Z2_CANT2 = (Z2_CANT2 - " + cZ3_QTY + ")"
	Else
		cQuery	+=	" Z2_COD2 = '" + cZ3_COD + "',"
		cQuery	+=	" Z2_DESC2 = '" + cZ3_DESC + "',"
		cQuery	+=	" Z2_UM2 = Z2_UM1,"
		cQuery	+=	" Z2_LOTE2 = '" + cZ3_LOT + "',"
		cQuery	+=	" Z2_CANT2 = (Z2_CANT2 + " + cZ3_QTY + "),"
		cQuery	+=	" Z2_FECHA = '" + DTOS(dDatabase) + "',"
		cQuery	+=	" Z2_HORA = '" + subStr(time(), 1, 5) + "'"
	End If
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
	cQuery	+=	" AND Z2_ITEM = " + allTrim(str(nZ3_ITEM))
	If tcSqlExec(cQuery) < 0
		conOut(tcSqlError())
	End If
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-20
//Fecha de revisión: 2015-06-08
//Versión: 2
//Descripción: Finalización del documento.
User Function IMX4609G(nApp, aDatos)
	Local	aDetail		:=	{}
	Local	aHeader		:=	{}
	Local	aItem		:=	{}
	Local	aUsuario	:=	pswRet()
	Local	cItem		:=	""
	Local	cSecuencia	:=	""
	Local	cSD7Next	:=	""
	Local	cDepot		:=	""
	Local	cTES		:=	""
	Local	cCF			:=	""
	Local	cQuery		:=	""
	Local	cDatos		:=	"IMX4609G"
	Local	cLlave		:=	""
	Local	nLength		:=	0
	Local	nCosto		:=	0
	Local	nValor		:=	0
	Local	nTotal		:=	0
	Local	cLlave		:=	""
	Local	nB2_CM1		:=	0
	Local	nD1_ITEM	:=	0
	Private	cSerie		:=	superGetMv("MV_IMX4600", .F., "R")
	Private	cFolio		:=	""
	Private	lUbicar		:=	.F.
	
	If nApp == 4
		cTES	:=	superGetMv("MV_IMX4609", .F., "401")
		cDepot	:=	superGetMv("MV_IMX4602", .F., "4000")
		nLength	:=	tamSX3("F1_DOC")[1]
		cQuery	:=	" SELECT MAX(D1_DOC) AS ULTIMO"
		cQuery	+=	" FROM " + RetSqlName("SD1")
		cQuery	+=	" WHERE D1_SERIE = '" + cSerie + "'"
	Else
		cTES	:=	superGetMv("MV_IMX4603", .F., "600")
		cDepot	:=	superGetMv("MV_IMX4604", .F., "02")
		nLength	:=	tamSX3("F2_DOC")[1]
		cQuery	:=	" SELECT MAX(D2_DOC) AS ULTIMO"
		cQuery	+=	" FROM " + RetSqlName("SD2")
		cQuery	+=	" WHERE D2_SERIE = '" + cSerie + "'"
	End If
	dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		cFolio	:=	soma1((cDatos)->ULTIMO)
	End If
	(cDatos)->(dbCloseArea())            
	
	cCF		:=	posicione("SF4", 1, xFilial("SF4") + cTES, "F4_CF")
	
	If nApp == 4
		cSecuencia	:=	proxNum()
		dbSelectArea("SD1")
		nLength	:=	tamSX3("D1_ITEM")[1]
		dbSelectArea("SZ3")
		SZ3->(dbSetOrder(1))
		SZ3->(dbSeek(xFilial("SZ3") + cDocumento))
		Do While SZ3->Z3_DOC == cDocumento .And. !SZ3->(eof())
			If .Not. empty(SZ3->Z3_REMDOC)
				SZ3->(dbSkip())
				loop
			End If
			//cDepot	:=	U_IMX4600I(SZ3->Z3_ITEM, SZ3->Z3_COD, aDatos)
			//cItem	:=	xFilial("SC7") + padR(SZ3->Z3_COD, tamSX3("C7_PRODUTO")[1]) + subStr(aDatos[4], 1, tamSX3("C7_NUM")[1])
			//cItem	:=	posicione("SC7", 4, cItem, "C7_ITEM")
			nD1_ITEM	+=	1
			cItem		:=	strZero(SZ3->Z3_ITEM, tamSX3("C7_ITEM")[1])
			nValor		:=	SZ3->Z3_QTY * SZ3->Z3_COSTO
			nTotal		+=	nValor
			
			recLock("SD1", .T.)
			SD1->D1_FILIAL	:=	xFilial("SD1")
			SD1->D1_ITEM	:=	strZero(nD1_ITEM, tamSX3("D1_ITEM")[1])
			SD1->D1_COD		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_COD")
			SD1->D1_UM		:=	posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_UM")
			SD1->D1_QUANT	:=	SZ3->Z3_QTY
			SD1->D1_QTDACLA	:=	SZ3->Z3_QTY
			SD1->D1_TES		:=	cTES
			SD1->D1_CF		:=	cCF
			SD1->D1_PEDIDO	:=	criaVar("D1_PEDIDO")
			SD1->D1_ITEMPC	:=	criaVar("D1_ITEMPC")
			SD1->D1_FORNECE	:=	aDatos[2]
			SD1->D1_LOJA	:=	aDatos[3]
			SD1->D1_LOCAL	:=	posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_LOCPAD")
			SD1->D1_VUNIT	:=	posicione("SB2", 1, xFilial("SB2") + padR(allTrim(SD1->D1_COD), tamSX3("B2_COD")[1]) + SD1->D1_LOCAL, "B2_CM1")
			SD1->D1_TOTAL	:=	SD1->D1_QUANT * SD1->D1_VUNIT
			SD1->D1_CUSTO	:=	SD1->D1_VUNIT
			SD1->D1_CUSORI	:=	SD1->D1_VUNIT
			SD1->D1_DOC		:=	cFolio
			SD1->D1_EMISSAO	:=	dDatabase
			SD1->D1_DTDIGIT	:=	dDatabase
			SD1->D1_TIPO	:=	"D"
			SD1->D1_SERIE	:=	cSerie
			If U_IMXLIB_TRACE(SD1->D1_COD)
				SD1->D1_LOTECTL	:=	getLote(cDocumento, SD1->D1_COD)
				SD1->D1_DTVALID	:=	dDatabase + 366
			End If
			If U_IMXLIB_GPS(SD1->D1_COD)
				SD1->D1_LOCALIZ	:=	getUbicacion(SD1->D1_COD, SD1->D1_LOCAL)
				lUbicar	:= empty(SD1->D1_LOCALIZ)
			End If
			SD1->D1_TP		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_TIPO")
			SD1->D1_FORMUL	:=	"N"
			SD1->D1_ESPECIE	:=	"RFD" + space(tamSX3("F1_ESPECIE")[1] - 3)
			SD1->D1_TIPODOC	:=	"53"
			SD1->D1_GARANTI	:=	"N"
			SD1->D1_NUMSEQ	:=	cSecuencia
			msUnlock("SD1")
			SD1->(dbCommit())
			//SD1->(dbSkip())
			
			//Control de calidad
			If cDepot == allTrim(superGetMV("MV_CQ"))
				cSD7Next	:=	U_IMX4600J()
				recLock("SD7", .T.)
				SD7->D7_FILIAL	:=	xFilial("SD7")
				SD7->D7_SEQ		:=	"001"
				SD7->D7_PRODUTO	:=	SZ3->Z3_COD
				SD7->D7_TIPO	:=	0
				SD7->D7_QTDE	:=	0
				SD7->D7_SALDO	:=	SZ3->Z3_QTY
				SD7->D7_USUARIO	:=	aUsuario[1, 2]
				SD7->D7_NUMSEQ	:=	cSecuencia
				SD7->D7_LOCAL	:=	cDepot
				SD7->D7_LOCDEST	:=	posicione("SZ2", 1, xFilial("SZ2") + aDatos[1] + str(aDatos[2], 12, 0) + str(SZ3->Z3_ITEM, 2, 0), "Z2_DEPOT1")
				SD7->D7_NUMERO	:=	cSD7Next
				SD7->D7_DATA	:=	dDataBase
				If U_IMX4600H(SZ3->Z3_COD)
					SD7->D7_LOTECTL	:=	SZ3->Z3_LOT
				End If
				SD7->D7_ORIGLAN	:=	"CP"
				SD7->D7_TIPOCQ	:=	"M"
				SD7->D7_DOC		:=	cFolio
				SD7->D7_SERIE	:=	cSerie
				SD7->D7_FORNECE	:=	aDatos[5]
				SD7->D7_LOJA	:=	aDatos[6]
				msUnlock("SD7")
				SD7->(dbCommit())
				SD7->(dbSkip())
			End If
			
			//Movimientos de lote
			If U_IMXLIB_TRACE(SD1->D1_COD) .And. !empty(SD1->D1_LOTECTL)
				dbSelectArea("SD5")
				SD5->(dbGoBottom())
				recLock("SD5", .T.)
				SD5->D5_FILIAL	:=	xFilial("SD5")
				SD5->D5_PRODUTO	:=	SD1->D1_COD
				SD5->D5_LOCAL	:=	SD1->D1_LOCAL
				SD5->D5_DOC		:=	SD1->D1_DOC
				SD5->D5_SERIE	:=	SD1->D1_SERIE
				SD5->D5_DATA	:=	SD1->D1_EMISSAO
				SD5->D5_ORIGLAN	:=	SD1->D1_TES
				SD5->D5_NUMSEQ	:=	SD1->D1_NUMSEQ
				SD5->D5_CLIFOR	:=	SD1->D1_FORNECE
				SD5->D5_LOJA	:=	SD1->D1_LOJA
				SD5->D5_QUANT	:=	SD1->D1_QUANT
				SD5->D5_LOTECTL	:=	SD1->D1_LOTECTL
				SD5->D5_DTVALID	:=	SD1->D1_DTVALID
				msUnlock("SD5")
				SD5->(dbCommit())
			End If
			
			//Ubicar
			If lUbicar
				dbSelectArea("SDA")
				SDA->(dbGoBottom())
				recLock("SDA", .T.)
				SDA->DA_FILIAL	:=	xFilial("SDA")
				SDA->DA_PRODUTO	:=	SD1->D1_COD
				SDA->DA_QTDORI	:=	SD1->D1_QUANT
				SDA->DA_SALDO	:=	SD1->D1_QUANT
				SDA->DA_DATA	:=	SD1->D1_EMISSAO
				SDA->DA_LOTECTL	:=	SD1->D1_LOTECTL
				SDA->DA_LOCAL	:=	SD1->D1_LOCAL
				SDA->DA_DOC		:=	SD1->D1_DOC
				SDA->DA_CLIFOR	:=	SD1->D1_FORNECE
				SDA->DA_LOJA	:=	SD1->D1_LOJA
				SDA->DA_TIPONF	:=	"N"
				SDA->DA_ORIGEM	:=	"SD1"
				SDA->DA_NUMSEQ	:=	SD1->D1_NUMSEQ
				msUnlock("SDA")
				SDA->(dbCommit())
				SDA->(dbSkip())
			ElseIf .Not. lUbicar .And. U_IMXLIB_GPS(SD1->D1_COD)
				dbSelectArea("SDB")
				SDB->(dbGoBottom())
				recLock("SDB", .T.)
				SDB->DB_FILIAL	:=	xFilial("SDB")
				SDB->DB_ITEM	:=	SD1->D1_ITEM
				SDB->DB_PRODUTO	:=	SD1->D1_COD
				SDB->DB_LOCAL	:=	SD1->D1_LOCAL
				SDB->DB_LOCALIZ	:=	SD1->D1_LOCALIZ
				SDB->DB_DOC		:=	SD1->D1_DOC
				SDB->DB_SERIE	:=	SD1->D1_SERIE
				SDB->DB_CLIFOR	:=	SD1->D1_FORNECE
				SDB->DB_LOJA	:=	SD1->D1_LOJA
				SDB->DB_TM		:=	SD1->D1_TES
				SDB->DB_ORIGEM	:=	"SD1"
				SDB->DB_QUANT	:=	SD1->D1_QUANT
				SDB->DB_DATA	:=	SD1->D1_EMISSAO
				SDB->DB_LOTECTL	:=	SD1->D1_LOTECTL
				SDB->DB_NUMSEQ	:=	SD1->D1_NUMSEQ
				SDB->DB_TIPO	:=	"M"
				SDB->DB_SERVIC	:=	"499"
				SDB->DB_ATIVID	:=	"ZZZ"
				SDB->DB_HRINI	:=	subStr(time(), 1, 5)
				SDB->DB_ATUEST	:=	"S"
				SDB->DB_STATUS	:=	"M"
				SDB->DB_ORDATIV	:=	"ZZ"
				SDB->DB_IDOPERA	:=	getSx8Num("SDB", "DB_IDOPERA")
				msUnlock("SDB")
				SDB->(dbCommit())
				ConfirmSX8()
				SDB->(dbSkip())
			End If
			
			updatePedido(nApp, cDocumento, SD1->D1_COD, SD1->D1_LOTECTL, SD1->D1_QUANT)
			
			updateSTK(nApp, strZero(SZ3->Z3_IDX, nLength), SD1->D1_LOCAL, SD1->D1_COD, SD1->D1_LOTECTL, SD1->D1_QUANT, SD1->D1_CUSTO, aDatos, SD1->D1_LOCALIZ)
			
			recLock("SZ3", .F.)
			SZ3->Z3_REMSER	:=	cSerie
			SZ3->Z3_REMDOC	:=	cFolio
			SZ3->Z3_REMIDX	:=	strZero(SZ3->Z3_IDX, nLength)
			msUnlock("SZ3")
			SZ3->(dbCommit())
			SZ3->(dbSkip())
			SD1->(dbSkip())
		End
		
		dbSelectArea("SF1")
		recLock("SF1", .T.)
		SF1->F1_FILIAL	:=	xFilial("SF1")
		SF1->F1_DOC		:=	cFolio
		SF1->F1_SERIE	:=	cSerie
		SF1->F1_FORNECE	:=	aDatos[2]
		SF1->F1_LOJA	:=	aDatos[3]
		SF1->F1_COND	:=	criaVar("F1_COND")
		SF1->F1_EMISSAO	:=	dDatabase
		SF1->F1_EST		:=	posicione("SA2", 1, xFilial("SA2") + aDatos[2] + aDatos[3], "A2_EST")
		SF1->F1_VALMERC	:=	nTotal
		SF1->F1_VALBRUT	:=	nTotal
		SF1->F1_TIPO	:=	"D"
		SF1->F1_DTDIGIT	:=	dDatabase
		SF1->F1_FORMUL	:=	"N"
		SF1->F1_ESPECIE	:=	"RFD" + space(tamSX3("F1_ESPECIE")[1] - 3)
		SF1->F1_HORA	:=	time()
		SF1->F1_MOEDA	:=	1
		SF1->F1_TXMOEDA	:=	1
		SF1->F1_STATUS	:=	"A"
		SF1->F1_RECBMTO	:=	dDatabase
		SF1->F1_TIPODOC	:=	"53"
		msUnlock("SF1")
		SF1->(dbCommit())
		SF1->(dbSkip())
		
		//Termina documento
		//If superGetMv("MV_IMX4608", .F., "N") == "S"
			//U_IMX4609M("MATA121")
		//End If
		
	ElseIf	nApp == 3
		cSecuencia	:=	proxNum()
		dbSelectArea("SD2")
		nLength	:=	tamSX3("D2_ITEM")[1]
		dbSelectArea("SZ3")
		SZ3->(dbSetOrder(1))
		SZ3->(dbSeek(xFilial("SZ3") + cDocumento))
		Do While SZ3->Z3_DOC == cDocumento .And. !SZ3->(eof())
			cItem	:=	strZero(SZ3->Z3_ITEM, tamSX3("C9_ITEM")[1])
			cDepot	:=	posicione("SC9", 1, xFilial("SC9") + allTrim(aDatos[4]) + cItem, "C9_LOCAL")
			nCosto	:=	posicione("SB2",2,xFilial("SB2")+padR(cDepot,tamSX3("B2_LOCAL")[1])+padR(SZ3->Z3_COD,tamSX3("B2_COD")[1]),"B2_CM1")
			nValor	:=	(SZ3->Z3_QTY * SZ3->Z3_COSTO)
			nTotal	+=	nValor
			recLock("SD2", .T.)
			SD2->D2_FILIAL	:=	xFilial("SD2")
			SD2->D2_ITEM	:=	strZero(SZ3->Z3_IDX, nLength)
			SD2->D2_COD		:=	SZ3->Z3_COD
			SD2->D2_UM		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_UM")
			SD2->D2_TP		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_TIPO")
			SD2->D2_QUANT	:=	SZ3->Z3_QTY
			SD2->D2_CUSTO1	:=	nCosto
			SD2->D2_PRCVEN	:=	SZ3->Z3_COSTO
			SD2->D2_TOTAL	:=	nValor
			SD2->D2_TES		:=	cTES
			SD2->D2_CF		:=	cCF
			//SD2->D2_PEDIDO	:=	aDatos[4]
			//SD2->D2_ITEMPV	:=	cItem
			SD2->D2_CLIENTE	:=	aDatos[5]
			SD2->D2_LOJA	:=	aDatos[6]
			SD2->D2_LOCAL	:=	cDepot
			SD2->D2_DOC		:=	cFolio
			SD2->D2_EMISSAO	:=	dDatabase
			SD2->D2_DTDIGIT	:=	dDatabase
			SD2->D2_TIPO	:=	"N"
			SD2->D2_SERIE	:=	cSerie
			If U_IMX4600H(SZ3->Z3_COD)
				SD2->D2_LOTECTL	:=	SZ3->Z3_LOT
			End If
			SD2->D2_TP		:=	posicione("SB1", 1, xFilial("SB1") + SZ3->Z3_COD, "B1_TIPO")
			SD2->D2_EST		:=	posicione("SA1", 1, xFilial("SA1") + aDatos[5] + aDatos[6], "A1_EST")
			SD2->D2_STSERV	:=	"1"
			SD2->D2_FORMUL	:=	"S"
			SD2->D2_ESPECIE	:=	"RFN" + space(tamSX3("D2_ESPECIE")[1] - 3)
			SD2->D2_TIPODOC	:=	"50"
			SD2->D2_TIPOREM	:=	"0"
			SD2->D2_NUMSEQ	:=	cSecuencia
			SD2->D2_GERANF	:=	"S"
			SD2->D2_QTDAFAT	:=	SZ3->Z3_QTY
			msUnlock("SD2")
			SD2->(dbSkip())
			
			updatePedido(nApp, allTrim(aDatos[4]), cItem, SZ3->Z3_QTY, cFolio, cSerie)
			
			updateSTK(nApp, strZero(SZ3->Z3_IDX, nLength), cDepot, SZ3->Z3_COD, SZ3->Z3_LOT, (SZ3->Z3_QTY * -1), nValor, aDatos)
			
			recLock("SZ3", .F.)
			SZ3->Z3_REMSER	:=	cSerie
			SZ3->Z3_REMDOC	:=	cFolio
			SZ3->Z3_REMIDX	:=	strZero(SZ3->Z3_IDX, nLength)
			msUnlock("SZ3")
			
			SZ3->(dbSkip())
		End
		
		dbSelectArea("SF2")
		recLock("SF2", .T.)
		SF2->F2_FILIAL	:=	xFilial("SF2")
		SF2->F2_DOC		:=	cFolio
		SF2->F2_SERIE	:=	cSerie
		SF2->F2_CLIENTE	:=	aDatos[5]
		SF2->F2_LOJA	:=	aDatos[6]
		SF2->F2_EMISSAO	:=	dDatabase
		SF2->F2_EST		:=	posicione("SA1", 1, xFilial("SA1") + aDatos[5] + aDatos[6], "A1_EST")
		SF2->F2_TIPOCLI	:=	posicione("SA1", 1, xFilial("SA1") + aDatos[5] + aDatos[6], "A1_TIPO")
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
		SF2->(dbSkip())
	End If
	vtAlert("Se genero la remision:" + CRLF + cSerie + cFolio, "Modulo RF")
Return

static Function getLote(cDoc, cCod)
	Local	cNum	:=	""
	Local	cResult	:=	""
	Local	cQuery	:=	""
	Local	cDatos	:=	getNextAlias()
	Local	lSD2	:=	.F.
	
	cQuery	:=	" SELECT Z8_NOPEDIM, Z8_FACTURA"
	cQuery	+=	" FROM " + retSqlName("SZ8")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z8_FILIAL = '" + xFilial("SZ8") + "'"
	cQuery	+=	" AND (Z8_SOLQTY - Z8_SUMDEV) > 0
	cQuery	+=	" AND Z8_DOC = '" + cDoc + "'"
	cQuery	+=	" AND Z8_COD = '" + cCod + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		If empty((cDatos)->Z8_NOPEDIM)
			lSD2	:=	.T.
			cNum	:=	(cDatos)->Z8_FACTURA
		Else
			cResult	:=	(cDatos)->Z8_NOPEDIM
		End If
	End If
	(cDatos)->(dbCloseArea())
	
	If lSD2
		cQuery	:=	" SELECT D2_LOTECTL"
		cQuery	+=	" FROM " + retSqlName("SD2")
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND D2_FILIAL = '" + xFilial("SD2") + "'"
		cQuery	+=	" AND D2_DOC = '" + cNum + "'"
		cQuery	+=	" AND D2_COD = '" + cCod + "'"
		cQuery	+=	" ORDER BY R_E_C_N_O_ DESC"
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			cResult	:=	(cDatos)->D2_LOTECTL
		End If
		(cDatos)->(dbCloseArea())
	End If
		
return (cResult)

static Function getUbicacion(cProducto, cAlmacen, nOpcion)
	Local	cResult	:=	""
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX4609"
	
	cQuery	:=	" SELECT BE_LOCALIZ, BE_PRIOR"
	cQuery	+=	" FROM " + retSqlName("SBE")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND BE_FILIAL = '" + xFilial("SBE") + "'"
	cQuery	+=	" AND BE_CODPRO = '" + cProducto + "'"
	cQuery	+=	" AND BE_LOCAL = '" + cAlmacen + "'"
	cQuery	+=	" ORDER BY BE_PRIOR"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		If nOpcion == nil
			cResult	:=	(cDatos)->BE_LOCALIZ
		Else
			cResult	:=	(cDatos)->BE_PRIOR
		End IF
	End If
	(cDatos)->(dbCloseArea())
return cResult

Static Function updatePedido(nApp, cDoc, cCod, cLot, nQty)
	Local	cKey	:=	xFilial("SZ8")
	Local	nSaldo	:=	nQty
	cKey	+=	padR(allTrim(cDoc), tamSX3("Z8_DOC")[1])
	cKey	+=	padR(allTrim(cCod), tamSX3("Z8_COD")[1])
	dbSelectArea("SZ8")
	SZ8->(dbSetOrder(1))
	SZ8->(dbGoTop())
	SZ8->(dbSeek(cKey))
	Do While nSaldo > 0 .And. SZ8->Z8_FILIAL + SZ8->Z8_DOC + SZ8->Z8_COD == cKey .And. .Not. SZ8->(eof())
		If (SZ8->Z8_SUMDEV + nSaldo) < SZ8->Z8_SOLQTY
			nQty	:=	nSaldo
			nSaldo	:=	0
		Else
			nQty	:=	SZ8->Z8_SOLQTY - SZ8->Z8_SUMDEV
			nSaldo	:=	nSaldo - nQty
		End If
		recLock("SZ8", .F.)
		SZ8->Z8_SUMDEV += nQty
		msUnlock("SZ8")
		SZ8->(dbCommit())
		SZ8->(dbSkip())
	End
Return

Static Function updateSTK(nApp, cItem, cDepot, cCod, cLot, nQty, nVal, aDatos, cLocX)
	Local	cKey	:=	""
	//Actualiza saldo SB2
	dbSelectArea("SB2")
	SB2->(dbSetOrder(2))
	SB2->(dbGoTop())
	If SB2->(dbSeek(xFilial("SB2") + padR(cDepot, tamSX3("B2_LOCAL")[1]) + padR(cCod, tamSX3("B2_COD")[1])))
		recLock("SB2", .F.)
		SB2->B2_QATU	+=	nQty
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
			//aquí
			recLock("SB8", .F.)
			SB8->B8_SALDO	+=	nQty
			If nApp == 3 .And. SB8->B8_EMPENHO > (nQty * -1)
				SB8->B8_EMPENHO	+=	nQty
			End If
			msUnlock("SB8")
		Else
			recLock("SB8", .T.)
			SB8->B8_FILIAL	:=	xFilial("SB8")
			SB8->B8_QTDORI	:=	nQty
			SB8->B8_PRODUTO	:=	padR(cCod, tamSX3("B8_PRODUTO")[1])
			SB8->B8_LOCAL	:=	padR(cDepot, tamSX3("B8_LOCAL")[1])
			SB8->B8_DATA	:=	dDatabase
			SB8->B8_DTVALID	:=	dDatabase + 366
			SB8->B8_SALDO	:=	nQty
			SB8->B8_EMPENHO	:=	0.00
			SB8->B8_ORIGLAN	:=	"NF"
			SB8->B8_LOTEFOR	:=	cLot
			SB8->B8_LOTECTL	:=	cLot
			SB8->B8_DOC		:=	cFolio
			SB8->B8_SERIE	:=	cSerie
			SB8->B8_ITEM	:=	cItem
			SB8->B8_CLIFOR	:=	aDatos[2]
			SB8->B8_LOJA	:=	aDatos[3]
			msUnlock("SB8")
		End If
	End If
	
	//Controla ubicación
	If .Not. lUbicar .And. U_IMXLIB_GPS(cCod)
		cKey	:=	xFilial("SBF")
		cKey	+=	padR(allTrim(cDepot), tamSX3("BF_LOCAL")[1])
		cKey	+=	padR(allTrim(cLocX), tamSX3("BF_LOCALIZ")[1])
		cKey	+=	padR(allTrim(cCod), tamSX3("BF_PRODUTO")[1])
		cKey	+=	criaVar("BF_NUMSERI")
		cKey	+=	padR(allTrim(cLot), tamSX3("BF_LOTECTL")[1])
		dbSelectArea("SBF")
		SBF->(dbSetOrder(1))
		SBF->(dbGoTop())
		If SB8->(dbSeek(cKey))
			recLock("SBF", .F.)
			SBF->BF_QUANT	+=	nQty
			msUnlock("SBF")
		Else
			recLock("SBF", .T.)
			SBF->BF_FILIAL	:=	xFilial("SBF")
			SBF->BF_PRODUTO	:=	padR(allTrim(cCod), tamSX3("BF_PRODUTO")[1])
			SBF->BF_LOCAL	:=	padR(allTrim(cDepot), tamSX3("BF_LOCAL")[1])
			SBF->BF_PRIOR	:=	getUbicacion(SBF->BF_PRODUTO, SBF->BF_LOCAL, 2)
			SBF->BF_LOCALIZ	:=	padR(allTrim(cLocX), tamSX3("BF_LOCALIZ")[1])
			SBF->BF_LOTECTL	:=	cLot
			SBF->BF_QUANT	:=	nQty
			msUnlock("SBF")
		End If
	End If
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-20
//Versión: 1
//Fecha de revisión:
//Descripción: Reversión de la captura.
User Function IMX4609I(nPrograma)
	Local	cSerie		:=	Space(4)
	Local	cFolio		:=	Space(20)
	Local	cQuery		:=	""
	Local	cDatos		:=	"IMX4609I"
	Local	lContinuar	:=	.T.
	Do While lContinuar
 		VTClear()
		@00, 00 VTSay "Documento a revertir:"
		@01, 00 VTSay "Serie:"
		@02, 00 VTGet cSerie
		@03, 00 VTSay "Documento:"
		@04, 00 VTGet cFolio
		VTRead()
		If VTLastKey() == 13 //Enter
			If .Not. empty(cFolio)
				cQuery	:=	" SELECT Z1_SERIE, Z1_FOLIO"
				cQuery	+=	" FROM " + retSqlName("SZ1")
				cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
				cQuery	+=	" AND Z1_ST = 3"
				cQuery	+=	" AND Z1_SERIE = '" + IIF(nPrograma == Nil .Or. nPrograma == 1, "MP", "PK") + "'"
				cQuery	+=	" AND Z1_SERORI = '" + cSerie + "'"
				cQuery	+=	" AND Z1_DOCORI = '" + cFolio + "'"
				dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
				If .Not. (cDatos)->(eof())
					cQuery	:=	" UPDATE " + retSqlName("SZ2") + " SET"
					cQuery	+=	" Z2_ST = 0,"
					cQuery	+=	" Z2_FECHA = '',"
					cQuery	+=	" Z2_HORA = '',"
					cQuery	+=	" Z2_CODBAR = '',"
					cQuery	+=	" Z2_COD2 = '',"
					cQuery	+=	" Z2_DESC2 = '',"
					cQuery	+=	" Z2_UM2 = '',"
					cQuery	+=	" Z2_LOTE2 = '',"
					cQuery	+=	" Z2_CANT2 = 0"
					cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
					cQuery	+=	" AND Z2_SERIE = '" + (cDatos)->Z1_SERIE + "'"
					cQuery	+=	" AND Z2_FOLIO = " + allTrim(str((cDatos)->Z1_FOLIO))
					If tcSqlExec(cQuery) < 0
						conOut(tcSqlError())
					Else
						cQuery	:=	" UPDATE " + retSqlName("SZ1") + " SET"
						cQuery	+=	" Z1_ST = 0,"
						cQuery	+=	" Z1_FUNC2 = '',"
						cQuery	+=	" Z1_FECHA2 = '',"
						cQuery	+=	" Z1_HORA2 = '',"
						cQuery	+=	" Z1_UID2 = '',"
						cQuery	+=	" Z1_UKEY2 = '',"
						cQuery	+=	" Z1_UNAME2 = ''"
						cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
						cQuery	+=	" AND Z1_SERIE = '" + (cDatos)->Z1_SERIE + "'"
						cQuery	+=	" AND Z1_FOLIO = " + allTrim(str((cDatos)->Z1_FOLIO))
						If tcSqlExec(cQuery) < 0
							conOut(tcSqlError())
						Else
							lContinuar	:=	.F.
						End If
					End If
				Else
					VTAlert(Chr(13) + Chr(10) + "No se encontro el archivo", "Modulo RF", .T.)
				End If
				(cDatos)->(dbCloseArea())
			End If
		ElseIf VTLastKey() == 27 //ESC
			lContinuar	:=	.F.
		End If
	End
	VTClearBuffer()
	VTClKey()
Return


//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-05-12
//Fecha de revisión:
//Versión: 1
//Descripción: Lista los elementos capturados SZ3
User Function IMX4609J(nApp, aDatos, nOpcion, aSZ3)
	Local	aItems 		:=	IIf(aSZ3 != nil, aClone(aSZ3), U_IMX4600G(nil, nil, cDocumento))
	Local	cCod		:=	""
	Local	cLot		:=	""
	Local	cLoc		:=	""
	Local	cQty		:=	""
	Local	cOpcion		:=	Space(1)
	Local	lContinue	:=	.T.
	Local	nPos		:=	0
	Local	nStart		:=	0
	Local	nStep		:=	0
	If len(aItems) <= 0
		lContinue	:=	.F.
		vtAlert("No se econtro el archivo.", "Modulo RF", .T.)
	End If
	Do While lContinue
		nPos	:=	0
		vtClear()
		If nOpcion == Nil
			nStart := 1
		Else
			nStart := 1 + (nOpcion * 3)
		End If
		For nStep := nStart To nStart + 2
			If Len(aItems) >= nStep
				If len(aItems[nStep][2][aScan(aItems[nStep][1], {|x| x == "Z3_COD"})]) >= 13
					cCod	:=	subStr(aItems[nStep][2][aScan(aItems[nStep][1], {|x| x == "Z3_COD"})], 1, 13)
				Else
					cCod	:=	padR(aItems[nStep][2][aScan(aItems[nStep][1], {|x| x == "Z3_COD"})], 13)
				End If
				cLot	:=	padR(aItems[nStep][2][aScan(aItems[nStep][1], {|x| x == "Z3_LOT"})], 15)
				cLoc	:=	subStr(aItems[nStep][2][aScan(aItems[nStep][1], {|x| x == "Z3_LOC"})], 1, 11)
				cQty	:=	allTrim(transform(aItems[nStep][2][aScan(aItems[nStep][1], {|x| x == "Z3_QTY"})], "999999999.9"))
				cQty	:=	padL(cQty, 11)
				@nPos, 00 vtSay "SKU:" + cCod + "|" + cQty
				nPos	+=	1
				@nPos, 00 vtSay "LOT:" + cLot + cLoc
				nPos	+=	1
				@nPos, 00 vtSay "------------------------------"
				nPos	+=	1
			End If
		Next
		nStep	:=	nStep - 1
		If len(aItems) > nStep
			@10, 00 vtSay "9) Pagina siguiente"
		End If
		If nOpcion != Nil
			@11, 00 vtSay "0) Pagina anterior"
		Else
			@11, 00 vtSay "0) Menu anterior"
		End If
		@12, 00 vtSay "Opcion: " VTGet cOpcion Pict "9"
		vtRead()
		Do Case
			Case cOpcion == "0"
				lContinue	:=	.F.
				If nOpcion != Nil
					nOpcion -= 1
					If nOpcion == 0
						nOpcion	:=	Nil
					End If
					U_IMX4609J(nApp, aDatos, nOpcion, aItems)
				End If
			Case cOpcion == "9"
				If Len(aItems) > nStep
					lContinue	:=	.F.
					If nOpcion != Nil
						nOpcion	+=	1
					Else
						nOpcion	:=	1
					End If
					U_IMX4609J(nApp, aDatos, nOpcion, aItems)
				Else
					vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
				End If
			Otherwise
				vtAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "Modulo RF", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-05-12
//Fecha de revisión:
//Versión: 1
//Descripción: Carga el documento, si existe.
User Function IMX4609K(nApp, aDatos)
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX4609K"
	Local	cResult	:=	criaVar("Z3_DOC")
	cQuery	:=	"SELECT Z3_DOC "
	cQuery	+=	"FROM " + retSqlName("SZ3") + " SZ3 "
	cQuery	+=	"WHERE D_E_L_E_T_ = ' ' "
	cQuery	+=	"AND Z3_SERIE = '" + aDatos[1] + "' "
	cQuery	+=	"AND Z3_FOLIO = " + allTrim(str(aDatos[2])) + " "
	cQuery	+=	"AND Z3_REMDOC = '' AND Z3_REMSER = ''"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(bof()) .And. .Not. (cDatos)->(eof())
		cResult	:=	(cDatos)->Z3_DOC
	Else
		cResult	:=	subStr(dToS(dDataBase), 3, 6) + subStr(time(), 1, 2) + subStr(time(), 4, 2)
	End If
	(cDatos)->(dbCloseArea())
Return (cResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-05-13
//Fecha de revisión 2: 2016-01-20
//Fecha de revisión 3: 2016-03-09
//Versión: 2
//Descripción: Termina documento SZ1 en terminal.
User Function IMX4609L(nApp, aDatos)
	Local	cContext	:=	""
	Local	cDatos		:=	"IMX4609L"
	Local	cQuery		:=	""
	Local	lGraba		:=	.T.
	Local	lError		:=	.F.
	Local	nTotPK		:=	0
	
	cQuery	:=	" SELECT Z2_COD1, Z2_CANT1"
	cQuery	+=	" FROM " + retSqlName("SZ2")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z2_FILIAL = '" + xFilial("SZ2") + "'"
	cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
	cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(eof())
		nTotPK	:=	totalPicking(nApp, nil, nil, aDatos, (cDatos)->Z2_COD1, nil, nil)
		If (cDatos)->Z2_CANT1 != nTotPK
			cContext	+=	subStr((cDatos)->Z2_COD1, 1, 15) + "; " + allTrim(str(nTotPK)) + "<>" + allTrim(str((cDatos)->Z2_CANT1)) + CRLF
			lError		:=	.T.
		End If
		(cDatos)->(dbSkip())
	End
	(cDatos)->(dbCloseArea())
	
	If lError
		//lGraba	:=	vtYesNo("Divergencia de productos." + CRLF + "¿Desea continuar?", "Modulo RF", .T.)
		lGraba	:=	vtYesNo(cContext, "Finaliza con divergencias?", .T.)
	End If
	
	If lGraba
		cQuery	+=	" UPDATE " + retSqlName("SZ1") + " SET"
		cQuery	+=	" Z1_ST	= 11"
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z1_SERIE = '" + aDatos[1] + "'"
		cQuery	+=	" AND Z1_FOLIO = " + allTrim(str(aDatos[2]))
		If tcSqlExec(cQuery) < 0
			conOut(tcSqlError())
		End If
		cQuery	+=	" UPDATE " + retSqlName("SZ2") + " SET"
		cQuery	+=	" Z2_ST	= 11"
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z2_SERIE = '" + aDatos[1] + "'"
		cQuery	+=	" AND Z2_FOLIO = " + allTrim(str(aDatos[2]))
		If tcSqlExec(cQuery) < 0
			conOut(tcSqlError())
		End If
	End If
Return lGraba

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-06-02
//Fecha de revisión:
//Versión: 1
//Descripción: Termina documento SZ1 estación de trabajo.
User Function IMX4609M(cApp)
	Local	aSC5		:=	{}
	Local	aSC7		:=	{}
	Local	aUsuario	:=	pswRet()
	Local	cDatos		:=	"IMX4609M"
	Local	cFilLoc		:=	""
	Local	cPedido		:=	""
	Local	cQuery		:=	""
	Local	cSerie		:=	""
	Local	cFolio		:=	""
	Local	nST			:=	0
	
	If cApp == "MATA121"
   		cFilLoc	:=	SC7->C7_FILIAL
   		cPedido	:=	SC7->C7_NUM
   		cSerie	:=	"RX"
   		aSC7	:=	SC7->(getArea())
   	ElseIf cApp == "MATA410"
   		cFilLoc	:=	SC5->C5_FILIAL
   		cPedido	:=	SC5->C5_NUM
   		cSerie	:=	"PK"
   		aSC5	:=	SC5->(getArea())
   	End If
   	
   	cQuery	:=	" SELECT Z1_FOLIO, Z1_ST FROM " + retSqlName("SZ1")
    cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
    cQuery	+=	" AND Z1_SERIE = '" + cSerie + "'"
    cQuery	+=	" AND Z1_DOCORI = '" + cPedido + "'"
    dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
    If .Not. (cDatos)->(eof())
    	cFolio	:=	allTrim(str((cDatos)->Z1_FOLIO))
    	nST		:=	(cDatos)->Z1_ST
    End If
    (cDatos)->(dbCloseArea())
	
	If	nST	>= 3
		IW_MsgBox("El pedido " + cPedido + " es invalido.", "Colecta de datos", "EXCLAM")
		Return
	End If
	
    If IW_MsgBox("El pedido " + cPedido + " será finalizado.", "Colecta de datos", "YESNO")
    	If cApp == "MATA121"
    		SC7->(dbGoTop())
    		SC7->(dbSeek(cFilLoc + cPedido))
    		Do While SC7->C7_FILIAL + SC7->C7_NUM == cFilLoc + cPedido
    			recLock("SC7", .F.)
    			SC7->C7_RESIDUO	:=	"S"
    			SC7->C7_ENCER	:=	"E"
    			msUnlock("SC7")
    			SC7->(dbSkip())
    		End
    		restArea(aSC7)
    	ElseIf cApp == "MATA410"
    		recLock("SC5", .F.)
    		SC5->C5_NOTA	:=	"REMITO"
    		SC5->C5_SERIE	:=	"RXX"
    		msUnlock("SC5")
    		restArea(aSC5)
    	End If
    	
		cQuery	+=	" UPDATE " + retSqlName("SZ1") + " SET"
		cQuery	+=	" Z1_ST = 3,"
		cQuery	+=	" Z1_FUNC2 = '" + cApp + "',"
		cQuery	+=	" Z1_FECHA2 = '" + dToS(dDatabase) + "',"
		cQuery	+=	" Z1_HORA2 = '" + subStr(time(), 1, 5) + "',"
		cQuery	+=	" Z1_UID2 = '" + aUsuario[1, 1] + "',"
		cQuery	+=	" Z1_UKEY2 = '" + aUsuario[1, 2] + "',"
		cQuery	+=	" Z1_UNAME2 = '" + aUsuario[1, 4] + "'"
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z1_SERIE = '" + cSerie + "'"
		cQuery	+=	" AND Z1_FOLIO = " + cFolio
		If tcSqlExec(cQuery) < 0
			conOut(tcSqlError())
		End If
		cQuery	+=	" UPDATE " + retSqlName("SZ2") + " SET"
		cQuery	+=	" Z2_ST	= 3"
		cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
		cQuery	+=	" AND Z2_SERIE = '" + cSerie + "'"
		cQuery	+=	" AND Z2_FOLIO = " + cFolio
		If tcSqlExec(cQuery) < 0
			conOut(tcSqlError())
		End If
    End If
Return
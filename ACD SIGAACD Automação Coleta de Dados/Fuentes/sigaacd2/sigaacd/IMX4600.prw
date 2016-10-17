
//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-09
//Versión: 1
//Fecha de revisión:
//Descripción: Programa inicial ACD. Crea el entorno de operación.

#Include "APVT100.ch"
#Include "Protheus.ch"
#Include "SIGAACD.ch"

User Function IMX4600(cArgs)
	Local dSysData    := MsDate()
	Local tRealIni    := Time()
	Local aEmprx      := {}
	Local aEmpChoice  := Array(2)
	Local lAcceso     := .F.
	Local nHandler    := 0
	Local nMaxCol     := Val(GetPvProfString("TELNET", "MAXCOL", "30", GetADV97()))
	Local nMaxRow     := Val(GetPvProfString("TELNET", "MAXROW", "14", GetADV97()))
	
	Private aUser     := {}
	Private cMainMenu := Space(1)
	
	MsApp():New('SIGAACD', .T.)
	oApp:cInternet := NIL
	oApp:lIsBlind  := .T.
	oApp:CreateEnv()
	
	//Define tamaño del diálogo y valores predeterminados.
	VTSetSize(nMaxRow, nMaxCol)
	TerProtocolo("VT100")
	SetsDefault()
	
	//Mensaje de bienvenida
	If cArgs == Nil
		VTAlert(STR0001 + Chr(13) + Chr(10) + STR0003 + Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0004, "BIENVENIDO", .T.)
	End If
	
	//Verifica la existencia del archivo de empresas
	If .Not. File(cArqEmp)
		Final(STR0005,STR0006) //"Instale"###"Configurador"
	EndIf
	
	//Verifica la existencia del archivo de contraseñas
	If .Not. File("SIGAADV.PSS") .And. .Not. File("SIGAPSS.SPF")
		Final(STR0005,STR0006) //"Instale"###"Configurador"
	EndIf

	PTInternal(1, STR0008) //"Colector RF"

	//Login
	Do While .Not. lAcceso
		aUser	:=	VTGetSenha(@dSysData, tRealIni)
		aEmprx	:=	aClone(aUser[2, 6])
		
		//lista empresas
		aEmpChoice := VTNewEmpr(@aEmprx)
		dDataBase := dSysData
		
		//Generá variables globales con la información del usuario
		aEmpresas  := aClone(aUser[2, 6])
		__RELDIR   := Trim(aUser[2, 3])
		__DRIVER   := AllTrim(aUser[2, 4])
		__IDIOMA   := aUser[2, 02]
		__GRPUSER  := ""
		__VLDUSER  := aUser[1, 06]
		__ALTPSW   := aUser[1, 08]
		__CUSERID  := aUser[1, 01]
		__NUSERACS := aUser[1, 15]
		__AIMPRESS := {aUser[2, 8], aUser[2, 9], aUser[2, 10], aUser[2, 12]}
		__LDIRACS  := aUser[2, 13]
		cAcesso    := Subs(cUsuario, 22, 512)
		
		If __CUSERID # "000000"
			nHandler := aScan(aUser[3], {|x| Left(x, 2) == "46"})
			If SubSTR(aUser[3] [nHandler], 3, 1) == "X"
				VTAlert("ACCESO" + Chr(13) + Chr(10) + "RESTRINGIDO", "SIGAACD", .T.)
			Else
				lAcceso := .T.
			End If
		Else
			lAcceso := .T.
		End If
	End
	PtInternal(1, STR0012 + cEmpAnt + "/" + cFIlAnt + " " + STR0013 + AllTrim(Subs(cUsuario, 7, 15)) + " [" + STR0008 + "]")

	//Crea el entorno de operación
	RpcSetType(3)
	RpcSetEnv(cEmpAnt, cFIlAnt, , , "SIGAEST")
	
	dbSelectArea("SA1")
	dbSelectArea("SA2")
	dbSelectArea("SA5")
	dbSelectArea("SB1")
	dbSelectArea("SB2")
	dbSelectArea("SB8")
	dbSelectArea("SC5")
	dbSelectArea("SC6")
	dbSelectArea("SC7")
	dbSelectArea("SC9")
	dbSelectArea("SD1")
	dbSelectArea("SD2")
	dbSelectArea("SD3")
	dbSelectArea("SD4")
	dbSelectArea("SF1")
	dbSelectArea("SF2")
	dbSelectArea("SM0")
	dbSelectArea("SX1")
	dbSelectArea("SX2")
	dbSelectArea("SX3")
	dbSelectArea("SZ1")
	dbSelectArea("SZ2")
	dbSelectArea("SZ3")
	
	//Despliega el menú principal
	U_IMX4600A()
	VTDisconnect()
	
	//Elimina el entorno de operación
	RpcClearEnv()
	
	//Término normal
	Final(STR0007)
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-09
//Versión: 1
//Fecha de revisión:
//Descripción: Menú principal.
User Function IMX4600A()
	Local cOpcion  := Space(1)
	Local lProcess := .F.
	
	Do While .Not. lProcess
		VTClear()
		VTSetKey(27)
		@00, 00 VTSay "======= Menu Principal ======="
		
		@02, 00 VTSay "1) Recepción"
		@03, 00 VTSay "2) Transferencias"
		@04, 00 VTSay "3) Picking"
		
		@06, 00 VTSay "0) Cerrar sesion"
		
		@12, 00 VTSay "Opcion: " VTGet cOpcion Pict "9"
		VTRead()
		
		Do Case
			Case cOpcion == "1"
				lProcess := .T.
				//Programas "Recepción"
				U_IMX4601(1)
			Case cOpcion == "2"
				lProcess := .T.
				//Programas "Transferencias"
				U_IMX4602(2)
			Case cOpcion == "3"
				lProcess := .T.
				//Programas "Picking"
				U_IMX4601(3)
			Case cOpcion == "0"
				//Salir del sistema
				lProcess := .T.
				U_IMX4600("OK")
			Otherwise
				lProcess := .F.
				VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-09
//Versión: 2
//Fecha de revisión: 2015-04-06
//Descripción: Listado de documentos SZ1.
User Function IMX4600B(cSerie, nST)
	Local cQuery	:=	""
	Local cDatos	:=	"IMX4600B"
	Local aDatos	:=	{}
	Local aItem 	:=	{"", 0, "", "", "", "", "", 0, "", "", "", ""}
	
	cQuery := " SELECT Z1_SERIE, Z1_FOLIO, Z1_SERORI, Z1_DOCORI, Z1_CLIPRO, Z1_LOJA, Z1_NOMBRE, Z1_ST, Z1_UID1, Z1_UID2,"
	cQuery += " Z1_DEPOT1, Z1_DEPOT2"
	cQuery += " FROM " + retSqlName("SZ1") + " SZ1"
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery += " AND Z1_SERIE = '" + cSerie + "'"
	If nST == Nil
		cQuery += " AND Z1_ST IN (0, 1)"
	Else
		cQuery += " AND Z1_ST = " + allTrim(str(nST))
	End If
	dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(eof())
		aItem[01]	:=	(cDatos)->Z1_SERIE
		aItem[02]	:=	(cDatos)->Z1_FOLIO
		aItem[03]	:=	(cDatos)->Z1_SERORI
		aItem[04]	:=	(cDatos)->Z1_DOCORI
		aItem[05]	:=	(cDatos)->Z1_CLIPRO
		aItem[06]	:=	(cDatos)->Z1_LOJA
		aItem[07]	:=	(cDatos)->Z1_NOMBRE
		aItem[08]	:=	(cDatos)->Z1_ST
		aItem[09]	:=	(cDatos)->Z1_UID1
		aItem[10]	:=	(cDatos)->Z1_UID2
		aItem[11]	:=	(cDatos)->Z1_DEPOT1
		aItem[12]	:=	(cDatos)->Z1_DEPOT2
		aAdd(aDatos, aClone(aItem))
		(cDatos)->(dbSkip())
	End
	(cDatos)->(dbCloseArea())   
	
Return (aDatos)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-13
//Versión: 1
//Fecha de revisión:
//Descripción: Listado de registros SZ2.
User Function IMX4600C(cSerie, nFolio, nST)
	Local cTable  := "SZ2"
	Local cQuery  := ""
	Local cDatos  := "IMX4600C"
	Local aDatos  := {}
	Local aItem   := {}
	Local aFields := {}
	Local aTipos  := {}
	Local aValues := {}
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbGoTop())
	SX3->(dbSeek(cTable))
	Do While AllTrim(SX3->X3_ARQUIVO) == cTable
		AAdd(aFields, AllTrim(SX3->X3_CAMPO))
		AAdd(aTipos,  ALLTrim(SX3->X3_TIPO))
		AAdd(aValues, CriaVar(SX3->X3_CAMPO))
		SX3->(dbSkip())
	End
	SX3->(dbCloseArea())
	
	cQuery := "SELECT "
	For i := 1 To Len(aFields)
		cQuery += aFields[i] + IIf(i < Len(aFields), ", ", "")
	Next
	cQuery += " FROM " + RetSqlName(cTable) + " " + cTable
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery += " AND Z2_SERIE = '" + cSerie + "'"
	cQuery += " AND Z2_FOLIO = " + AllTrim(STR(nFolio))
	If nST != Nil
		cQuery += " AND Z2_ST < " + allTrim(str(nST))
	End If
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(Eof())
		aItem := AClone(aValues)
		For i:= 1 To Len(aValues)
			aItem[i] := IIf(aTipos[i] != "D", (cDatos)->&(aFields[i]), STOD((cDatos)->&(aFields[i])))
		Next
		AAdd(aDatos, {aFields, aItem})
		(cDatos)->(dbSkip())
	End
	(cDatos)->(dbCloseArea())   
	
Return (aDatos)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-04-01
//Versión: 1
//Fecha de revisión:
//Descripción: Decodificación de códigos de barras
User Function IMX4600D(cBuffer)
	Local	aResult		:=	{}
	Local	cB1_COD		:=	""
	Local	cB1_DESC	:=	""
	Local	cGTIN		:= 	""
	Local	cLote		:=	""
	Local	cSSCC		:=	""
	Local	cValor		:=	""
	Local	cQuery		:=	""
	Local	cDatos		:=	"IMX4600D"
	Local	dProduccion	:=	CTOD("  /  /  ")
	Local	dEnvasado	:=	CTOD("  /  /  ")
	Local	dConsumo	:=	CTOD("  /  /  ")
	Local	dCaducidad	:=	CTOD("  /  /  ")
	Local	nCantidad	:=	0
	Local	nStep		:=	0
	aResult := {cB1_COD, cSSCC, cGTIN, cLote, dProduccion, dEnvasado, dConsumo, dCaducidad, nCantidad, cB1_DESC}
	If empty(cBuffer)		
		Return aResult
	End If
	Do While len(cBuffer) > 2
		Do Case
			Case subSTR(cBuffer, 1, 2) == "00" .And. len(allTrim(cBuffer)) >= 20 //SSCC
				cSSCC	:=	subStr(cBuffer, 3, 18)
				cBuffer	:=	subStr(cBuffer, 19, len(cBuffer) - 18)
			Case subSTR(cBuffer, 1, 2) $ "01|02" .And. len(allTrim(cBuffer)) >= 14 //GTIN & QTY
				If len(allTrim(cBuffer)) == 22
					cValor	:=	subStr(cBuffer, 3, 12)
					cGTIN	:=	subStr(cValor, 1, 12)
					cBuffer	:=	subStr(cBuffer, 15, len(cBuffer) - 14)
				ElseIf len(allTrim(cBuffer)) == 24
					cValor	:=	subStr(cBuffer, 3, 14)
					cGTIN	:=	subStr(cValor, 1, 13)
					cBuffer	:=	subStr(cBuffer, 17, len(cBuffer) - 16)
				Else
					cBuffer	:=	""
				End If
				//cDigito2	:=	eanDigito(cValor)
			Case subStr(cBuffer, 1, 2) == "10" //Lote
				cLote		:=	subStr(cBuffer, 3, len(cBuffer) - 2)
				cBuffer		:=	""
			Case subStr(cBuffer, 1, 2) == "11" //Fecha de producción
				dProduccion	:=	sToD("20" + subStr(cBuffer, 3, 6))
				cBuffer		:=	subStr(cBuffer, 9, len(cBuffer) - 8)
			Case subStr(cBuffer, 1, 2) == "13" //Fecha de envasado
				dEnvasado	:=	sToD("20" + subStr(cBuffer, 3, 6))
				cBuffer		:=	subStr(cBuffer, 9, len(cBuffer) - 8)
			Case subStr(cBuffer, 1, 2) == "15" //Fecha de consumo
				dConsumo	:=	sToD("20" + subStr(cBuffer, 3, 6))
				cBuffer		:=	subStr(cBuffer, 9, len(cBuffer) - 8)
			Case subStr(cBuffer, 1, 2) == "17" //Fecha de caducidad
				dCaducidad	:=	sToD("20" + subStr(cBuffer, 3, 6))
				cBuffer		:=	subStr(cBuffer, 9, Len(cBuffer) - 8)
			Case subStr(cBuffer, 1, 2) == "37" //Cantidad
				nCantidad	:=	val(subStr(cBuffer, 3, len(cBuffer) - 2))
				cBuffer		:=	""
			Otherwise
				cValor		:=	cBuffer
				cBuffer		:=	""
		End
	End
	//Buscar B1_COD en SB1
	cValor	:=	iIf(cGTIN == "", cValor, cGTIN)
	cQuery	:=	" SELECT B1_COD, B1_DESC"
	cQuery	+=	" FROM " + RetSqlName("SB1")
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND B1_CODBAR = '" + cValor + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		cB1_COD		:=	(cDatos)->B1_COD
		cB1_DESC	:=	(cDatos)->B1_DESC
	End If
	(cDatos)->(dbCloseArea())
	If empty(cB1_COD)
		cQuery	:=	strTran(cQuery, "B1_CODBAR", "B1_COD")
		dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
		If .Not. (cDatos)->(eof())
			cB1_COD		:=	(cDatos)->B1_COD
			cB1_DESC	:=	(cDatos)->B1_DESC
		End If
		(cDatos)->(dbCloseArea())
	End IF
	aResult := {cB1_COD, cSSCC, cGTIN, cLote, dProduccion, dEnvasado, dConsumo, dCaducidad, nCantidad, cB1_DESC}
Return (aResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-04-08
//Versión: 1
//Fecha de revisión:
//Descripción: Número consecutivo para SZ1
User Function IMX4600F(cSerie)
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX4600F"
	Local	nValor	:=	0
	cQuery	:=	" SELECT MAX(Z1_FOLIO) AS ULTIMO"
	cQuery	+=	" FROM " + RetSqlName("SZ1")
	cQuery	+=	" WHERE Z1_SERIE = '" + cSerie + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		nValor	:=	(cDatos)->ULTIMO + 1
	Else
		nValor	:=	1
	End If
	(cDatos)->(dbCloseArea())
Return (nValor)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-05-13
//Fecha de revisión:
//Versión: 1
//Descripción: Listado de registros SZ3.
User Function IMX4600G(cSerie, nFolio, cDocument)
	Local cTable  := "SZ3"
	Local cQuery  := ""
	Local cDatos  := "IMX4600G"
	Local aDatos  := {}
	Local aItem   := {}
	Local aFields := {}
	Local aTipos  := {}
	Local aValues := {}
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbGoTop())
	SX3->(dbSeek(cTable))
	Do While AllTrim(SX3->X3_ARQUIVO) == cTable
		AAdd(aFields, AllTrim(SX3->X3_CAMPO))
		AAdd(aTipos,  ALLTrim(SX3->X3_TIPO))
		AAdd(aValues, CriaVar(SX3->X3_CAMPO))
		SX3->(dbSkip())
	End
	SX3->(dbCloseArea())
	
	cQuery := "SELECT "
	For i := 1 To Len(aFields)
		cQuery += aFields[i] + IIf(i < Len(aFields), ", ", "")
	Next
	cQuery += " FROM " + RetSqlName(cTable) + " " + cTable
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery += " AND Z3_SERIE = '" + cSerie + "'"
	cQuery += " AND Z3_FOLIO = " + AllTrim(STR(nFolio))
	If cDocument != Nil .And. !empty(cDocument)
		cQuery += " AND Z3_DOC = '" + cDocument + "'"
	End If
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cDatos, .T., .T.)
	Do While .Not. (cDatos)->(Eof())
		aItem := aClone(aValues)
		For i:= 1 To Len(aValues)
			aItem[i] := IIf(aTipos[i] != "D", (cDatos)->&(aFields[i]), STOD((cDatos)->&(aFields[i])))
		Next
		aAdd(aDatos, {aFields, aItem})
		(cDatos)->(dbSkip())
	End
	(cDatos)->(dbCloseArea())
Return (aDatos)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-05-13
//Fecha de revisión:
//Versión: 1
//Descripción: Control de lote, porque rastro() no funciona en VT100.
User Function IMX4600H(cCodigo)
	Local	aArea	:=	SB1->(getArea())
	Local	lResult	:=	.F.
	If superGetMV("MV_RASTRO") == "S"
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		If SB1->(dbSeek(xFilial("SB1") + cCodigo))
			lResult	:=	(SB1->B1_RASTRO == "L")
		End If
	End If
	restArea(aArea)
Return (lResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-06-02
//Fecha de revisión:
//Versión: 1
//Descripción: Almacén de entrada
User Function IMX4600I(nItem, cProducto, aDatos)
	Local	aSA5	:=	SA5->(getArea())
	Local	aSB1	:=	SB1->(getArea())
	Local	cProv	:=	padR(allTrim(aDatos[5]), tamSX3("A5_FORNECE")[1])
	Local	cLoja	:=	padR(allTrim(aDatos[6]), tamSX3("A5_LOJA")[1])
	Local	cResult	:=	posicione("SZ2", 1, xFilial("SZ2") + aDatos[1] + str(aDatos[2], 12, 0) + str(nItem, 2, 0), "Z2_DEPOT1")
	Local	nNota1	:=	posicione("SB1", 1, xFilial("SB1") + cProducto, "B1_NOTAMIN")
	Local	nNota2	:=	posicione("SA5", 1, xFilial("SA5") + cProv + cLoja + cProducto, "A5_NOTA")
	
	If nNota1 > nNota2 .And. nNota1 > 0
		cResult	:=	allTrim(superGetMV("MV_CQ"))
	End If
	
Return (cResult)

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-07-20
//Fecha de revisión:
//Versión: 1
//Descripción: Número consecutivo para SD7
User Function IMX4600J()
	Local	cQuery	:=	""
	Local	cDatos	:=	"IMX4600J"
	Local	cValor	:=	""
	cQuery	:=	" SELECT MAX(D7_NUMERO) AS ULTIMO"
	cQuery	+=	" FROM " + RetSqlName("SD7")
	dbUseArea(.T., "TOPCONN", tcGenQry(, ,cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		cValor	:=	SOMA1((cDatos)->ULTIMO)
	End If
	(cDatos)->(dbCloseArea())
Return (cValor)

User Function IMX4600K()
	//axCadastro("SZ1")
	//axCadastro("SZ2")
	axCadastro("SZ3")
Return
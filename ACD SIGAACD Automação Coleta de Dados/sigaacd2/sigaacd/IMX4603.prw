#Include "APVT100.ch"
#Include "Protheus.ch"
#Include "SIGAACD.ch"

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-11
//Versión: 1
//Fecha de revisión:
//Descripción: Picking
User Function IMX4603()
	Local cOpcion  := Space(1)
	Local lProcess := .F.
	dbSelectArea("SF1")
	dbSelectArea("SF2")
	dbSelectArea("SD1")
	dbSelectArea("SD2")
	dbSelectArea("SD3")
	dbSelectArea("SD4")
	dbSelectArea("SB1")
	dbSelectArea("SZ1")
	dbSelectArea("SZ2")
	Do While .Not. lProcess
		VTClear()
		@00, 00 VTSay "Orden de seleccion/Picking"
		@02, 00 VTSay "1) Seleccionar documento"
		@03, 00 VTSay "2) Revertir captura"
		@05, 00 VTSay "0) Menu principal"
		@12, 00 VTSay "Opcion: " VTGet cOpcion Pict "9"
		VTRead()
		Do Case
			Case cOpcion == "0"
				lProcess := .T.
				U_IMX4600A()
			Case cOpcion == "1"
				U_IMX4603A()
			Case cOpcion == "2"
				U_IMX4601I(3)
			Otherwise
				lProcess := .F.
				VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-12
//Versión: 1
//Fecha de revisión:
//Descripción: Listar documentos
User Function IMX4603A(nOpcion)
	Local aDatos   := U_IMX4600B("PK")
	Local cOpcion  := Space(1)
	Local lProcess := .F.
	Local nPos     := 0
	Local nStart   := 0
	Local nStep    := 0
	Do While .Not. lProcess
		nPos := 0
		VTClear()
		@00, 00 VTSay "Orden de Seleecion/Picking"
		If nOpcion == Nil
			nStart := 1
		Else
			nStart := 1 + (nOpcion * 8)
		End If
		For nStep := nStart To nStart + 7
			If Len(aDatos) >= nStep
				nPos += 1
				@nPos, 00 VTSay allTrim(STR(nPos)) + ") " + strZero(val(aDatos[nStep][4]), 7) + aDatos[nStep][3] + " " + SubSTR(aDatos[nStep][7], 1, 14)
			End If
		Next nStep
		If Len(aDatos) > nStep
			@09, 00 VTSay "9) Pagina siguiente"
		End If
		If nOpcion != Nil
			@10, 00 VTSay "0) Pagina anterior"
		Else
			@10, 00 VTSay "0) Menu anterior"
		End If
		@12, 00 VTSay "Opcion: " VTGet cOpcion Pict "9"
		VTRead()
		Do Case
			Case cOpcion == "0"
				lProcess := .T.
				If nOpcion != Nil
					nOpcion -= 1
					If nOpcion == 0
						nOpcion := Nil
					End If
					U_IMX4603A(nOpcion)
					Return
				Else
					U_IMX4603()
					Return
				End If
			Case cOpcion $ "1|2|3|4|5|6|7|8"
				If Val(cOpcion) <= nPos
					lProcess := .T.
					nPos := IIf(nOpcion != Nil, (nOpcion * 8) + Val(cOpcion), Val(cOpcion))
					U_IMX4603B(aDatos[nPos])
					Return
				Else
					lProcess := .F.
					VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
				End If
			Case cOpcion == "9"
				If Len(aDatos) > nStep
					lProcess := .T.
					If nOpcion != Nil
						nOpcion += 1
					Else
						nOpcion := 1
					End If
					U_IMX4603A(nOpcion)
					Return
				Else
					lProcess := .F.
					VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
				End If
			Otherwise
				lProcess := .F.
				VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
		End
	End
Return

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-03-12
//Versión: 1
//Fecha de revisión:
//Descripción: Opciones del documento
User Function IMX4603B(aDatos)
	Local cOpcion := Space(1)
	Local lProc   := .F.
	Do While .Not. lProc
		VTClear()
		@00, 00 VTSay strZero(val(aDatos[4]), 7) + aDatos[3] + " " + SubSTR(aDatos[7], 1, 14)
		@02, 00 VTSay "1) Ver detalle"
		@03, 00 VTSay "2) Capturar productos"
		@04, 00 VTSay "3) Finalizar documento"
		@06, 00 VTSay "0) Menu anterior"
		@12, 00 VTSay "Opcion: " VTGet cOpcion Pict "9"
		VTRead()
		Do Case
			Case cOpcion == "0" //Menu anterior
				lProc	:=	.T.
				U_IMX4603A()
			Case cOpcion == "1" //Ver detalle
				U_IMX4601C(aDatos, Nil, Nil, 3)
			Case cOpcion == "2" //Capturar productos
				lProc	:=	.T.
				U_IMX4601D(aDatos, 3)
			Case cOpcion == "3" //Finalizar documento
				lProc	:=	.T.
				U_IMX4601G(aDatos, 3)
			Otherwise
				VTAlert(Chr(13) + Chr(10) + "Opcion" + Chr(13) + Chr(10) + "invalida", "SIGAACD", .T.)
		End
	End
Return
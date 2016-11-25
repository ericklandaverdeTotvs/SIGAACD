#Include "Protheus.ch"
#Include "rwmake.ch"

//Autor: Cuauhtémoc Olvera Carmona
//Fecha de creación: 2015-05-15
//Fecha de revisión:
//Versión: 1
//Descripción: Recepción de materia prima, menú principal
User Function IMX4605()
	Local	cPregunta		:=	"IMX4605"
	Local	ReportHandler	:=	TReport():New("IMX4605", "Divergencias", cPregunta, {|ReportHandler| __PRPrint(ReportHandler)},,,,,,,,)
	Local	ReportBreak
	Local	ReportSection
	
	creaSX1(cPregunta)
	pergunte(cPregunta, .F.)

	ReportHandler:SetTotalInLine(.F.)
	ReportHandler:SetTitle("Reporte de divergencias")
	ReportHandler:SetLineHeight(60)
	ReportHandler:SetColSpace(1)
	ReportHandler:SetLeftMargin(0)
	ReportHandler:oPage:SetPageNumber(1)
	ReportHandler:cFontBody := "Tahoma"
	ReportHandler:nFontBody := 10
	ReportHandler:lBold := .F.
	ReportHandler:lUnderLine := .F.
	ReportHandler:lHeaderVisible := .T.
	ReportHandler:lFooterVisible := .F.
	ReportHandler:lParamPage := .F.


	ReportSection:= TRSection():New(ReportHandler, "",,,,,,,,,,,,,,,,,,,)
	ReportSection:SetTotalInLine(.F.)
	ReportSection:SetTotalText("Total")
	ReportSection:lUserVisible := .T.
	ReportSection:lHeaderVisible := .T.
	ReportSection:SetLineStyle(.F.)
	ReportSection:SetLineHeight(30)
	ReportSection:SetColSpace(1)
	ReportSection:SetLeftMargin(0)
	ReportSection:SetLinesBefore(0)
	ReportSection:SetCols(0)
	ReportSection:SetHeaderSection(.T.)
	ReportSection:SetHeaderPage(.F.)
	ReportSection:SetHeaderBreak(.F.)
	ReportSection:SetLineBreak(.F.)
	ReportSection:SetAutoSize(.F.)
	ReportSection:SetPageBreak(.F.)
	ReportSection:SetClrBack(16777215)
	ReportSection:SetClrFore(0)
	ReportSection:SetBorder('')
	ReportSection:SetBorder('',,,.T.)
	ReportSection:aTable := {}
	ReportSection:AddTable("SZ1")
	ReportSection:AddTable("SZ2")
	ReportSection:OnPrintLine({|| .T.})


	TRCell():New(ReportSection,'__NEW__001','P2','P3',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__001"):SetName("Z2_COD1")
	ReportSection:Cell("Z2_COD1"):cAlias := "SZ2"
	ReportSection:Cell("Z2_COD1"):SetTitle("PRODUCTO")
	ReportSection:Cell("Z2_COD1"):SetSize(20)
	ReportSection:Cell("Z2_COD1"):SetPicture("@!")
	ReportSection:Cell("Z2_COD1"):SetAutoSize(.F.)
	ReportSection:Cell("Z2_COD1"):SetLineBreak(.F.)
	ReportSection:Cell("Z2_COD1"):SetHeaderSize(.F.)
	ReportSection:Cell("Z2_COD1"):nAlign := 1
	ReportSection:Cell("Z2_COD1"):nHeaderAlign := 1
	ReportSection:Cell("Z2_COD1"):SetClrBack(16777215)
	ReportSection:Cell("Z2_COD1"):SetClrFore(0)
	ReportSection:Cell("Z2_COD1"):cOrder := "A0"
	ReportSection:Cell("Z2_COD1"):nType := 1
	ReportSection:Cell("Z2_COD1"):cFormula := ""
	ReportSection:Cell("Z2_COD1"):cRealFormula := ""
	ReportSection:Cell("Z2_COD1"):cUserFunction := ""
	ReportSection:Cell("Z2_COD1"):lVisible := .T.
	ReportSection:Cell("Z2_COD1"):SetBorder("")
	ReportSection:Cell("Z2_COD1"):SetBorder("",,,.T.)
	
	TRCell():New(ReportSection,'__NEW__002','','',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__002"):SetName("Z2_DESC1")
	ReportSection:Cell("Z2_DESC1"):cAlias := "SZ2"
	ReportSection:Cell("Z2_DESC1"):SetTitle("DESCRIPCION")
	ReportSection:Cell("Z2_DESC1"):SetSize(50)
	ReportSection:Cell("Z2_DESC1"):SetPicture("@!")
	ReportSection:Cell("Z2_DESC1"):SetAutoSize(.F.)
	ReportSection:Cell("Z2_DESC1"):SetLineBreak(.F.)
	ReportSection:Cell("Z2_DESC1"):SetHeaderSize(.F.)
	ReportSection:Cell("Z2_DESC1"):nAlign := 1
	ReportSection:Cell("Z2_DESC1"):nHeaderAlign := 1
	ReportSection:Cell("Z2_DESC1"):SetClrBack(16777215)
	ReportSection:Cell("Z2_DESC1"):SetClrFore(0)
	ReportSection:Cell("Z2_DESC1"):cOrder := "A1"
	ReportSection:Cell("Z2_DESC1"):nType := 1
	ReportSection:Cell("Z2_DESC1"):cFormula := ""
	ReportSection:Cell("Z2_DESC1"):cRealFormula := ""
	ReportSection:Cell("Z2_DESC1"):cUserFunction := ""
	ReportSection:Cell("Z2_DESC1"):lVisible := .T.
	ReportSection:Cell("Z2_DESC1"):SetBorder("")
	ReportSection:Cell("Z2_DESC1"):SetBorder("",,,.T.)
	
	TRCell():New(ReportSection,'__NEW__003','','',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__003"):SetName("Z2_CANT1")
	ReportSection:Cell("Z2_CANT1"):cAlias := "SZ2"
	ReportSection:Cell("Z2_CANT1"):SetTitle("CANT. ORIGINAL")
	ReportSection:Cell("Z2_CANT1"):SetSize(18)
	ReportSection:Cell("Z2_CANT1"):SetPicture("@E 9999.99")
	ReportSection:Cell("Z2_CANT1"):SetAutoSize(.F.)
	ReportSection:Cell("Z2_CANT1"):SetLineBreak(.F.)
	ReportSection:Cell("Z2_CANT1"):SetHeaderSize(.F.)
	ReportSection:Cell("Z2_CANT1"):nAlign := 3
	ReportSection:Cell("Z2_CANT1"):nHeaderAlign := 1
	ReportSection:Cell("Z2_CANT1"):SetClrBack(16777215)
	ReportSection:Cell("Z2_CANT1"):SetClrFore(0)
	ReportSection:Cell("Z2_CANT1"):cOrder := "A2"
	ReportSection:Cell("Z2_CANT1"):nType := 1
	ReportSection:Cell("Z2_CANT1"):cFormula := ""
	ReportSection:Cell("Z2_CANT1"):cRealFormula := ""
	ReportSection:Cell("Z2_CANT1"):cUserFunction := ""
	ReportSection:Cell("Z2_CANT1"):lVisible := .T.
	ReportSection:Cell("Z2_CANT1"):SetBorder("")
	ReportSection:Cell("Z2_CANT1"):SetBorder("",,,.T.)
	
	TRCell():New(ReportSection,'__NEW__004','','',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__004"):SetName("Z2_CANT2")
	ReportSection:Cell("Z2_CANT2"):cAlias := "SZ2"
	ReportSection:Cell("Z2_CANT2"):SetTitle("CANT. FINAL")
	ReportSection:Cell("Z2_CANT2"):SetSize(18)
	ReportSection:Cell("Z2_CANT2"):SetPicture("@E 9999.99")
	ReportSection:Cell("Z2_CANT2"):SetAutoSize(.F.)
	ReportSection:Cell("Z2_CANT2"):SetLineBreak(.F.)
	ReportSection:Cell("Z2_CANT2"):SetHeaderSize(.F.)
	ReportSection:Cell("Z2_CANT2"):nAlign := 3
	ReportSection:Cell("Z2_CANT2"):nHeaderAlign := 1
	ReportSection:Cell("Z2_CANT2"):SetClrBack(16777215)
	ReportSection:Cell("Z2_CANT2"):SetClrFore(0)
	ReportSection:Cell("Z2_CANT2"):cOrder := "A3"
	ReportSection:Cell("Z2_CANT2"):nType := 1
	ReportSection:Cell("Z2_CANT2"):cFormula := ""
	ReportSection:Cell("Z2_CANT2"):cRealFormula := ""
	ReportSection:Cell("Z2_CANT2"):cUserFunction := ""
	ReportSection:Cell("Z2_CANT2"):lVisible := .T.
	ReportSection:Cell("Z2_CANT2"):SetBorder("")
	ReportSection:Cell("Z2_CANT2"):SetBorder("",,,.T.)
	
	
	TRCell():New(ReportSection,'__NEW__005','','',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__005"):SetName("Z2_UM1")
	ReportSection:Cell("Z2_UM1"):cAlias := "SZ2"
	ReportSection:Cell("Z2_UM1"):SetTitle("UM")
	ReportSection:Cell("Z2_UM1"):SetSize(6)
	ReportSection:Cell("Z2_UM1"):SetPicture("@!")
	ReportSection:Cell("Z2_UM1"):SetAutoSize(.F.)
	ReportSection:Cell("Z2_UM1"):SetLineBreak(.F.)
	ReportSection:Cell("Z2_UM1"):SetHeaderSize(.F.)
	ReportSection:Cell("Z2_UM1"):nAlign := 1
	ReportSection:Cell("Z2_UM1"):nHeaderAlign := 1
	ReportSection:Cell("Z2_UM1"):SetClrBack(16777215)
	ReportSection:Cell("Z2_UM1"):SetClrFore(0)
	ReportSection:Cell("Z2_UM1"):cOrder := "A4"
	ReportSection:Cell("Z2_UM1"):nType := 1
	ReportSection:Cell("Z2_UM1"):cFormula := ""
	ReportSection:Cell("Z2_UM1"):cRealFormula := ""
	ReportSection:Cell("Z2_UM1"):cUserFunction := ""
	ReportSection:Cell("Z2_UM1"):lVisible := .T.
	ReportSection:Cell("Z2_UM1"):SetBorder("")
	ReportSection:Cell("Z2_UM1"):SetBorder("",,,.T.)
	

	TRCell():New(ReportSection,'__NEW__006','','',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__006"):SetName("Z1_DOCORI")
	ReportSection:Cell("Z1_DOCORI"):cAlias := "SZ1"
	ReportSection:Cell("Z1_DOCORI"):SetTitle("PEDIDO")
	ReportSection:Cell("Z1_DOCORI"):SetSize(20)
	ReportSection:Cell("Z1_DOCORI"):SetPicture("@!")
	ReportSection:Cell("Z1_DOCORI"):SetAutoSize(.F.)
	ReportSection:Cell("Z1_DOCORI"):SetLineBreak(.F.)
	ReportSection:Cell("Z1_DOCORI"):SetHeaderSize(.F.)
	ReportSection:Cell("Z1_DOCORI"):nAlign := 1
	ReportSection:Cell("Z1_DOCORI"):nHeaderAlign := 1
	ReportSection:Cell("Z1_DOCORI"):SetClrBack(16777215)
	ReportSection:Cell("Z1_DOCORI"):SetClrFore(0)
	ReportSection:Cell("Z1_DOCORI"):cOrder := "A5"
	ReportSection:Cell("Z1_DOCORI"):nType := 1
	ReportSection:Cell("Z1_DOCORI"):cFormula := ""
	ReportSection:Cell("Z1_DOCORI"):cRealFormula := ""
	ReportSection:Cell("Z1_DOCORI"):cUserFunction := ""
	ReportSection:Cell("Z1_DOCORI"):lVisible := .T.
	ReportSection:Cell("Z1_DOCORI"):SetBorder("")
	ReportSection:Cell("Z1_DOCORI"):SetBorder("",,,.T.)
	
	TRCell():New(ReportSection,'__NEW__007','','',,,,,,,,,,,,)
	ReportSection:Cell("__NEW__007"):SetName("Z1_FECHA1")
	ReportSection:Cell("Z1_FECHA1"):cAlias := "SZ1"
	ReportSection:Cell("Z1_FECHA1"):SetTitle("Fecha")
	ReportSection:Cell("Z1_FECHA1"):SetSize(20)
	//ReportSection:Cell("Z1_FECHA1"):SetPicture("")
	ReportSection:Cell("Z1_FECHA1"):SetAutoSize(.F.)
	ReportSection:Cell("Z1_FECHA1"):SetLineBreak(.F.)
	ReportSection:Cell("Z1_FECHA1"):SetHeaderSize(.F.)
	ReportSection:Cell("Z1_FECHA1"):nAlign := 1
	ReportSection:Cell("Z1_FECHA1"):nHeaderAlign := 1
	ReportSection:Cell("Z1_FECHA1"):SetClrBack(16777215)
	ReportSection:Cell("Z1_FECHA1"):SetClrFore(0)
	ReportSection:Cell("Z1_FECHA1"):cOrder := "A5"
	ReportSection:Cell("Z1_FECHA1"):nType := 1
	ReportSection:Cell("Z1_FECHA1"):cFormula := ""
	ReportSection:Cell("Z1_FECHA1"):cRealFormula := ""
	ReportSection:Cell("Z1_FECHA1"):cUserFunction := ""
	ReportSection:Cell("Z1_FECHA1"):lVisible := .T.
	ReportSection:Cell("Z1_FECHA1"):SetBorder("")
	ReportSection:Cell("Z1_FECHA1"):SetBorder("",,,.T.)
	
	ReportSection:BeginQuery()
	BeginSql Alias "IMX4605"
		Select Z2_SERIE, Z2_FOLIO, Z2_COD1, Z2_DESC1, Z2_CANT1, Z2_UM1, Z2_CANT2, Z1_FECHA1, Z1_DOCORI
		FROM %Table:SZ2% SZ2, %Table:SZ1% SZ1
		WHERE SZ1.%notDel% AND SZ2.%notDel%
		AND Z1_SERIE = Z2_SERIE AND Z1_FOLIO = Z2_FOLIO
		AND Z2_CANT1 <> Z2_CANT2
		//AND Z1_ST = 3
		AND Z2_SERIE = 'RX'
		AND Z1_FECHA1 BETWEEN %Exp:dToS(MV_PAR01)% AND %Exp:dToS(MV_PAR02)%
		ORDER BY Z2_FOLIO
	EndSql
	ReportSection:EndQuery()
	ReportSection:LoadOrder()
	ReportHandler:PrintDialog()
Return

Static Function creaSX1(cPregunta)
putSx1(cPregunta, "01", "", "¿ Desde ?", "", "MV_CH1", "D", 8, 0, 0, "G", "", "", "", "", "MV_PAR01")
putSx1(cPregunta, "02", "", "¿ Hasta ?", "", "MV_CH2", "D", 8, 0, 0, "G", "", "", "", "", "MV_PAR02")
Return
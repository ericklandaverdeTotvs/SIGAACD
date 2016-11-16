#include "protheus.ch"

//Autor: Cuauhtémoc Olvera C.
//email: quau@ideas.mx
//Fecha de creación: 2016/02/12
//Fecha de revisión: 2016/05/23
//Versión: 2
//Uso : Impresion de etiquetas Zebra
user function IMX4606(cPedido) //impresoras en CB5
	local	i
	private aPrinters	:=	impresoras()
	private aNames		:=	{}
	private	aPedido		:=	{}
	private	aDireccion	:=	{}
	private	cTitle		:=	"Etiquetas para empaque"
	private	cNumero		:=	space(tamSX3("C5_NUM")[1])
	private	nQty		:=	0
	private cCliente	:=	space(tamSX3("A1_COD")[1])
	private	cLoja		:=	space(tamSX3("A1_LOJA")[1])
	private cContext	:= space(250)
	private	nPrinter	:=	1
	private dialogMain, textPedido, textCantidad, textCliente, textLoja, textContext, comboPrinters, buttonPrint
	
	for i := 1 to len(aPrinters)
		aAdd(aNames, aPrinters[i, 1])
	next
	
	if cPedido != nil .And. pedido(cPedido)
		cNumero	:=	aPedido[3]
	end if
	
	DEFINE MSDIALOG dialogMain TITLE cTitle FROM 000, 000 TO 250,400 PIXEL
		@011, 010 SAY "Pedido" PIXEL
		@010, 070 MSGET textPedido VAR cNumero SIZE 050, 010 OF dialogMain WHEN empty(cNumero) VALID pedido(cNumero) PIXEL
		@026, 010 SAY "Cantidad de etiquetas" PIXEL
		@025, 070 MSGET textCantidad VAR nQty PICTURE "@E 9999" SIZE 050, 010 OF dialogMain WHEN .F. PIXEL
		@041, 010 SAY "Cliente" SIZE 050, 010 OF dialogMain PIXEL
		@040, 070 MSGET textCliente VAR cCliente F3 "SA1" SIZE 050, 010 OF dialogMain WHEN .T. PIXEL
		@041, 135 SAY "Tienda" SIZE 050, 010 OF dialogMain PIXEL
		@040, 161 MSGET textLoja VAR cLoja SIZE 020, 010 OF dialogMain WHEN .T. VALID direccion() PIXEL
		@065, 010 SAY "Dirección entrega" SIZE 050, 010 OF dialogMain PIXEL
		@055, 070 GET textContext VAR cContext SIZE 110, 040 MULTILINE WHEN .T. OF dialogMain PIXEL
		@100, 070 MSCOMBOBOX comboPrinters VAR nPrinter ITEMS aNames SIZE 050, 010 OF dialogMaing WHEN .T. PIXEL
		@101, 010 SAY "Impresora" SIZE 050, 010 OF dialogMain PIXEL
		@100, 135 BUTTON buttonPrint PROMPT "Imprimir" SIZE 045, 010 WHEN .T. ACTION imprimir() OF dialogMain PIXEL
	ACTIVATE MSDIALOG dialogMain CENTERED
return

static function pedido(cPedido)
	local	cDatos	:=	getNextAlias()
	local	cQuery	:=	""
	local	lResult	:=	.F.
	cQuery	:=	" SELECT Z1_SERIE, Z1_FOLIO, Z1_SERORI, Z1_DOCORI, Z1_ST, Z1_CLIPRO, Z1_LOJA, Z1_NOMBRE"
	cQuery	+=	" FROM " + retSqlName("SZ1") + " SZ1"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z1_FILIAL = '" + xFilial("SZ1") + "'"
	cQuery	+=	" AND Z1_ST >= 13"
	cQuery	+=	" AND Z1_SERIE = 'PK'"
	cQuery	+=	" AND Z1_DOCORI = '" + cPedido + "'"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	If .Not. (cDatos)->(eof())
		aAdd(aPedido, (cDatos)->Z1_SERIE)
		aAdd(aPedido, (cDatos)->Z1_FOLIO)
		aAdd(aPedido, (cDatos)->Z1_DOCORI)
		aAdd(aPedido, (cDatos)->Z1_CLIPRO)
		aAdd(aPedido, (cDatos)->Z1_LOJA)
		aAdd(aPedido, (cDatos)->Z1_NOMBRE)
		cCliente	:=	aPedido[4]
		cLoja		:=	aPedido[5]
		lResult	:=	.T.
		direccion()
	End If
	(cDatos)->(dbCloseArea())
return lResult

static Function direccion()
	local	lResult	:=	.F.
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())
	if SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
		aAdd(aDireccion, SA1->A1_END)
		aAdd(aDireccion, SA1->A1_BAIRRO)
		aAdd(aDireccion, SA1->A1_MUN)
		aAdd(aDireccion, SA1->A1_ESTADO)
		aAdd(aDireccion, SA1->A1_CEP)
		lResult		:=	.T.
	end if	
	if lResult
		cContext	:=	aPedido[6] + CRLF
		cContext	:=	aDireccion[1] + CRLF
		cContext	+=	aDireccion[2] + CRLF
		cContext	+=	aDireccion[3] + ", " + aDireccion[4] + CRLF
		cContext	+=	"C. P. " + aDireccion[5]
	end if
return lResult

static function imprimir()
	local	cDatos		:=	getNextAlias()
	local	cQuery		:=	""
	local	cBuffer		:=	""
	local	aContent	:=	{}
	local	nCaja		:=	0
	local	nCajas		:=	0
	local	nHandler	:=	0
	local	tcpSocket	:=	TSocketClient():New()
	local	i			:=	0
	
	cQuery	:=	" SELECT *"
	cQuery	+=	" FROM " + retSqlName("SZ3") + " SZ3"
	cQuery	+=	" WHERE D_E_L_E_T_ = ' '"
	cQuery	+=	" AND Z3_FILIAL = '" + xFilial("SZ3") + "'"
	cQuery	+=	" AND Z3_SERIE = '" + aPedido[1] + "'"
	cQuery	+=	" AND Z3_FOLIO = " + allTrim(str(aPedido[2]))
	cQuery	+=	" AND Z3_PACKING = 'S'"
	cQuery	+=	" ORDER BY Z3_TARIMA, Z3_CAJA, Z3_IDXPACK, Z3_IDX"
	dbUseArea(.T., "TOPCONN", tcGenQry(, , cQuery), cDatos, .T., .T.)
	do while .Not. (cDatos)->(eof())
		if nCaja != (cDatos)->Z3_CAJA
			nCajas	+=	1
			nCaja	:=	(cDatos)->Z3_CAJA
		end if
		cBuffer	+=	allTrim((cDatos)->Z3_COD)+ ";" + allTrim(str((cDatos)->Z3_QTYPACK)) + "\0D\0A"
		(cDatos)->(dbSkip())
		if nCaja != (cDatos)->Z3_CAJA
			aAdd(aContent, cBuffer)
			cBuffer	:=	""
		end if
	end
	(cDatos)->(dbCloseArea())
	
	nHandler	:=	tcpSocket:Connect(val(aPrinters[comboPrinters:nAt, 6]), allTrim(aPrinters[comboPrinters:nAt, 5]), 60)
    if tcpSocket:isConnected()
    	for i := 1 to nCajas
			cBuffer		:=	"^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR5,5~SD15^JUS^LRN^CI0^XZ^XA^MMT^PW812^LL1218^LS0"
			cBuffer		+=	"^FT751,216^A0R,39,38^FH\^FD" + "OXFORD UNIVERSITY PRESS MEXICO, S.A. de C.V." + "^FS"
			cBuffer		+=	"^FT645,57^A0R,85,84^FH\^FD" + "PEDIDO" + cNumero + "^FS"
			cBuffer		+=	"^FT649,909^A0R,85,84^FH\^FD" + allTrim(str(i)) + " de " + allTrim(str(nCajas)) + "^FS"
			cBuffer		+=	"^FT570,55^A0R,45,45^FH\^FD" + aPedido[6] + "^FS"
			cBuffer		+=	"^FT515,55^A0R,36,33^FH\^FD" + aDireccion[1] + ", " + aDireccion[2] + "^FS"
			cBuffer		+=	"^FT471,55^A0R,36,33^FH\^FD" + aDireccion[3] + ", " + aDireccion[4] + " C.P. " + aDireccion[5] + "^FS"
			cBuffer		+=	"^FT52,146^A0R,23,24^FB946,1,0,C^FH\^FDVia Gustavo Baz Num.110, Col. San Pedro Barrientos, Tlalnepantla Estado de M\8Axico C.P. 54030 ^FS"
			cBuffer		+=	"^FT24,146^A0R,23,24^FB946,1,0,C^FH\^FDTEL: 53115672, 53115683 RFC: OUP950801BN5 REG.CAM.NAL.IEM. 723^FS"
			cBuffer		+=	"^FO741,217^GB0,792,3^FS"
			cBuffer		+=	"^BY4,7^FT115,63^B7R,7,0,,,N"
			cBuffer		+=	"^FH\^FD" + aContent[i] + "^FS"
			cBuffer		+=	"^PQ1,0,1,Y^XZ"
			nHandler	:=	tcpSocket:Send(cBuffer)
		next
		nHandler	:=	tcpSocket:CloseConnection()
	else
		iw_MsgBox("Error de conexión (" + allTrim(str(nHandler)) + ")", "Módulo RF", "EXCLAM")
	end if
return

static function impresoras()
	local	aResult	:=	{}
	dbSelectArea("CB5")
	CB5->(dbSetOrder(1))
	CB5->(dbGoTop())
	do while .Not. CB5->(eof())
		aAdd(aResult, {CB5->CB5_CODIGO, CB5->CB5_DESCRI, CB5->CB5_MODELO, CB5->CB5_TIPO, CB5->CB5_SERVER, CB5->CB5_PORTIP})
		CB5->(dbSkip())
	end
return aResult
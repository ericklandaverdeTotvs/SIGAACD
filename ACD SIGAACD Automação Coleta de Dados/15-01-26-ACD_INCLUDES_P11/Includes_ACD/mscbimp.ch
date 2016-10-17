#ifdef SPANISH
	#define STR0001 "Esperando... Buffer lleno "
	#define STR0002 "Semaforo cerrado "
	#define STR0003 "\ctrl.seq"
	#define STR0004 "Prueba "
	#define STR0005 "Servidor"
	#define STR0006 "Abrir"
	#define STR0007 "¡Se abrio!"
	#define STR0008 "¡No abrio!"
	#define STR0009 "Pale"
	#define STR0010 "Cod. Barras"
	#define STR0011 "Lote"
	#define STR0012 "Produccion"
	#define STR0013 "Vencimiento"
	#define STR0014 "Almacenamiento"
	#define STR0015 "Validez Min."
	#define STR0016 "Validez Max."
	#define STR0017 "Variante"
	#define STR0018 "Serie"
	#define STR0019 "Cant."
	#define STR0020 "Lote"
	#define STR0021 "Medida"
	#define STR0022 "Cantidad"
	#define STR0023 "Pedido cliente"
	#define STR0024 "Consignacion"
	#define STR0025 "Cod. Expedicion"
	#define STR0026 "Ruta"
	#define STR0027 "Ubicacion"
	#define STR0028 "Pais origen"
	#define STR0029 "Serie"
	#define STR0030 "Producto"
	#define STR0031 "Precio Un."
	#define STR0032 "Cod. Barras"
	#define STR0033 "Uso interno"
	#define STR0034 "Cliente"
	#define STR0035 "SRN"
	#define STR0036 "NSC"
#else
	#ifdef ENGLISH
		#define STR0001 "Waiting... Buffer Full "
		#define STR0002 "Closed traffic light "
		#define STR0003 "\ctrl.seq"
		#define STR0004 "Test "
		#define STR0005 "Server"
		#define STR0006 "Open"
		#define STR0007 "Opened!!!!!"
		#define STR0008 "Did not open!!!!!"
		#define STR0009 "Pallet"
		#define STR0010 "Bar Code"
		#define STR0011 "Lot"
		#define STR0012 "Production"
		#define STR0013 "Due Date"
		#define STR0014 "Storage"
		#define STR0015 "Min. Validity"
		#define STR0016 "Max. Validity"
		#define STR0017 "Variant"
		#define STR0018 "Series"
		#define STR0019 "Qty."
		#define STR0020 "Lot"
		#define STR0021 "Size"
		#define STR0022 "Quantity"
		#define STR0023 "Customer Order"
		#define STR0024 "Consignment"
		#define STR0025 "Shipping Code"
		#define STR0026 "Route"
		#define STR0027 "Localization"
		#define STR0028 "Origin Country"
		#define STR0029 "Series"
		#define STR0030 "Product"
		#define STR0031 "Unit Price"
		#define STR0032 "Bar Code"
		#define STR0033 "Internal use."
		#define STR0034 "Customer"
		#define STR0035 "SRN"
		#define STR0036 "NSC"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", , "Aguardando... Buffer Cheio " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", , "Semaforo fechado " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", , "\ctrl.seq" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", , "Teste " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", , "Servidor" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", , "Abrir" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", , "Abriu!!!!!" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", , "Não abriu !!!!!" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", , "Pallet" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", , "Cod.Barras" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", , "Lote" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", , "Producao" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", , "Vencimento" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", , "Armazenagem" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", , "Validade Min." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", , "Validade Max." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", , "Variante" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", , "Serie" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", , "Qtde" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", , "Lote" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", , "Medida" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", , "Quantidade" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", , "Pedido Cliente" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", , "Consignacao" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", , "Cod.Expedicao" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", , "Rota" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", , "Localizacao" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", , "Pais origem" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", , "Serie" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", , "Produto" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", , "Preco Un." )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", , "Cod.Barras" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", , "Uso interno" )
		#define STR0034 "Cliente"
		#define STR0035 "SRN"
		#define STR0036 "NSC"
	#endif
#endif

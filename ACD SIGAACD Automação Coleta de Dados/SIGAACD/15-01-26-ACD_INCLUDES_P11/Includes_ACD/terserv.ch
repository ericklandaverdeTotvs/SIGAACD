#ifdef SPANISH
	#define STR0001 "Conmutadora"
	#define STR0002 "Administrador de microterminales"
	#define STR0003 "Conmutadora"
	#define STR0004 "Administrador de microterminales"
	#define STR0005 "Termino normal"
	#define STR0006 "Falla al cargar la DLL 'TERGER.DLL'. Esta debe estar junto a las DLL de la Wilbor-Gradual"
	#define STR0007 "TERGER.DLL"
	#define STR0008 "El administrador de microterminales de conexion paralela esta activado"
	#define STR0009 "Puerta de comunicacion no valida"
	#define STR0010 "Error de comunicacion"
	#define STR0011 "Error de conexion "
	#define STR0012 "Error de comunicacion"
	#define STR0013 "El administrador de microterminales de conexion TCPIP está activado"
	#define STR0014 "Microterminal desactivado  "
	#define STR0015 "Administrador de microterminales desactivado "
	#define STR0016 "Termino normal"
	#define STR0017 "Terminal activado "
	#define STR0018 "Terminal inhabilitado "
	#define STR0019 "MICROTERMINAL FINALIZADO"
	#define STR0020 "MICROTERMINAL FINALIZADO"
	#define STR0021 "Falla en la configuracion de la LPT1, por favor verifique la infraestructura"
	#define STR0022 "Terger.dll no compatible, por favor actualice la DLL"
	#define STR0023 "problema al enviar datos a la DLL"
	#define STR0024 "TerServ - Problema de conexion TCPIP"
	#define STR0025 "TerServ - Se excedio el limite de intentos de lectura del retorno de la impresion paralela"
	#define STR0026 "TerServ - Se excedio el limite de intentos de lectura del retorno de la impresion serial"
	#define STR0027 "Atencion"
#else
	#ifdef ENGLISH
		#define STR0001 "Commuter"
		#define STR0002 "Micro terminal Manager"
		#define STR0003 "Commuter"
		#define STR0004 "Micro terminal Manager"
		#define STR0005 "Regular end"
		#define STR0006 "Failing in loading DLL 'TERGER.DLL'. It must be along with the DLLs of Wilbor-Gradual"
		#define STR0007 "TERGER.DLL"
		#define STR0008 "Manager of Parallel Connection Micro terminal is activated"
		#define STR0009 "Invalid communication port"
		#define STR0010 "Communication error"
		#define STR0011 "Connection error "
		#define STR0012 "Communication error"
		#define STR0013 "Manager of TCPIP Connection Micro terminal is activated"
		#define STR0014 "Micro terminal deactivated "
		#define STR0015 "Micro terminal manager deactivated "
		#define STR0016 "Regular End"
		#define STR0017 "Terminal activated "
		#define STR0018 "Terminal deactivated "
		#define STR0019 "FINALIZED MICROTERMINAL"
		#define STR0020 "FINALIZED MICROTERMINAL"
		#define STR0021 "Failure in the LPT1 settings, check infrastructure"
		#define STR0022 "Terger.dll not compatible, update DLL"
		#define STR0023 "problem sending data for DLL"
		#define STR0024 "TerServ - TCPIP connection problem"
		#define STR0025 "TerServ - Attempts of parallel printing return reading exceeded"
		#define STR0026 "TerServ - Attempts of serial printing return reading exceeded"
		#define STR0027 "Attention"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", , "Comutadora" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", , "Gerenciador de Microterminais" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", , "Comutadora" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", , "Gerenciador de Microterminais" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", , "Termino normal" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", , "Falha ao carregar a DLL 'TERGER.DLL'. Ela deve estar junto as DLLs da Wilbor-Gradual" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", , "TERGER.DLL" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", , "Ativado o gerenciador de Microterminais conexao Paralela" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", , "Porta de comunicao invalida" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", , "Erro de comunicacao" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", , "Erro de Conexao " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", , "Erro de comunicacao" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", , "Ativado o gerenciador de Microterminais conexao TCPIP" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", , "Desativado Microterminal " )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", , "Desativado o gerenciador de Microterminais " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", , "Termino Normal" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", , "Ativado o terminal " )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", , "Desabilitado o terminal " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", , "MICROTERMINAL FINALIZADO" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", , "MICROTERMINAL FINALIZADO" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", , "Falha na configuracao da LPT1, favor verificar infra-estrutura" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", , "Terger.dll nao compativel, favor atualizar DLL" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", , "problema no envio de dados para DLL" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", , "TerServ - Problema de conexao TCPIP" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", , "TerServ - Estouro de tentativas da leitura do retorno da impressao paralela" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", , "TerServ - Estouro de tentativas da leitura do retorno da impressao serial" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", , "Atencao" )
	#endif
#endif

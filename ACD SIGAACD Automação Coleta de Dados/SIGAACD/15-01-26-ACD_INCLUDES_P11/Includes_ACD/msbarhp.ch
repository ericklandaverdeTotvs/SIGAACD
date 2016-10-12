#ifdef SPANISH
	#define STR0001 "Obligatorio a que el tipo sea EAN128"
	#define STR0002 "***Contenido invalido para codigo EAN13***"
	#define STR0003 "***Contenido invalido para codigo EAN8***"
	#define STR0004 "***Contenido invalido para codigo UPCA***"
	#define STR0005 "***Codigo de barras con banderola no disponible p/ vertical****"
#else
	#ifdef ENGLISH
		#define STR0001 "Mandatory type must be EAN128"
		#define STR0002 "***Invalid content for code EAN13***"
		#define STR0003 "***Invalid content for code EAN8***"
		#define STR0004 "***Invalid content for code UPCA***"
		#define STR0005 "***Bar code with Banner not available for vertical****"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", , "Obrigatorio o tipo ser EAN128" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", , "***Conteudo invalido para codigo EAN13***" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", , "***Conteudo invalido para codigo EAN8***" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", , "***Conteudo invalido para codigo UPCA***" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", , "***Codigo de barras com Banner nao disponivel p/ vertical****" )
	#endif
#endif

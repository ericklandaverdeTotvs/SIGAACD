#ifdef SPANISH
	#define STR0001 "Archivo de operadores"
	#define STR0002 "¡Atencion! "
	#define STR0003 "Este registro esta siendo utilizado por el sistema"
	#define STR0004 "y no puede ser borrado por el sistema"
#else
	#ifdef ENGLISH
		#define STR0001 "Operators File"
		#define STR0002 "Attention! "
		#define STR0003 "This record is being used by system"
		#define STR0004 "and cannot be deleted by system"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Registo de operadores", "Cadastro de operadores" )
		#define STR0002 "Atenção! "
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Este registo está a ser utilizado pelo sistema", "Este registro está sendo utilizado pelo sistema" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "e não pode ser excluído pelo sistema", "e não pode ser excluido pelo sistema" )
	#endif
#endif

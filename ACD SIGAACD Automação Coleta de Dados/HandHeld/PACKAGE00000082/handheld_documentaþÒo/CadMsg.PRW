#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO2     � Autor � Marcelo Vieira     � Data �  06/08/01   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP5 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CadPlmMsg
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cPrefix := ""
Private cCadastro := "Cadastro de Mensagens"

//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Incluir","AxInclui",0,3} ,;
             {"Alterar","AxAltera",0,4} ,;
             {"Excluir","AxDeleta",0,5} }

//���������������������������������������������������������������������Ŀ
//� Monta array com os campos para o Browse                             �
//�����������������������������������������������������������������������
Private cString := GetMv("MV_TBLMSG",,"")
Private aCampos := {}
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

If Empty(cString)
	MsgAlert("Verifique o parametro MV_TBLMSG, alias de mensagens nao configurado")
	Return .T.
Endif

cPrefix := Right(cString, 2) + "_"
aCampos := { {"Cod Mensagem",cPrefix + "CODMSG","@!"} ,;
                   {"Vendedor",cPrefix+"CODVEND","@!"} ,;
                   {"Data",cPrefix+"DATAMSG","@!"} ,;
                   {"Vigencia",cPrefix+"DATAVIG","@!"} ,;
                   {"Origem",cPrefix+"ORIMSG","@!"} ,;
                   {"Mensagem",cPrefix+"MENSAGE","@!"} }

dbSelectArea(cString)
dbSetOrder(1)
dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,aCampos,)

Return
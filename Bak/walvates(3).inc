; Prototipos funcoes WIN32
include windows.inc
include kernel32.inc
include user32.inc
include	comdlg32.inc
include	Comctl32.inc

; Bibliotecas funcoes WIN32
includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib comdlg32.lib

; Variável para passagem de ponteiro da janela
.data
Inst_principal dd ?
ponteiro_imagem dd ?
byte_inicio dd 13418        ;primeira parte de 6 digitos
byte_inicio_parte2 dw 13512 ;segunda parte de 6 digitos
tamanho db 13
bytes_por_numero db 7
buffer_linha db 84 dup (0)
buffer db 13816 dup(0) 
buffer_lido db 14 dup(0)
bytes_read dw ?
contador_a db ?
contador_b db ?
valor db ?

;parte Leandro
retorno_arquivo db 2263 dup(0)
ponteiro_produtos dd ?
bytes_escritos db ?
buffer_inf_produtos db 2263 dup(0)
contador dw 10
contador1 dw 10
Array db 14 dup(0)
Array_Arquivo db 14 dup(0)

preco_linha db 'R$',0
final_linha db 9,13,10,0
buffer_vazio db 0
digito1 dd ?
digito2 dd ?
digito3 dd ?
digito4 dd ?
digito5 dd ?
parte_baixa dd ?
parte_alta dd ?
total dd 0

JANELA_PRINCIPAL EQU 1000
NOME_ARQUIVO EQU 1003
UPLOAD EQU 1004
CODIGO_BARRAS EQU 1005

CAMPO_PRODUTO EQU 1001
CAMPO_MARCA EQU 1002
CAMPO_VALOR EQU 1007

ADICIONAR EQU 1012
CAMPO_ITENS EQU 1011
CAMPO_TOTAL EQU 1013

;para o upload do arquivo
ClassName			db 'MCLASS',0
AddFilter   			db "(*.bmp)", 0, "*.bmp" ,0 
            			db "All Files (*.*)",0,"*.*",0,0
AddTitle    			db "Selecione codigo de barra", 0
hInstance			dd		?
ofn   				OPENFILENAME <?>
FileN   			db 260 dup(?)

.const
erro db "Erro",0
erro_ler db "Erro ao ler o arquivo enviado. Verifique se é um arquivo válido",0
erro_lista db "Erro ao ler lista de produtos",0
erro_nao_bmp db "Arquivo enviado não é .bmp!",0
erro_abrir db "Ocorreu um erro ao abrir o arquivo. Tente novamente",0
erro_adicionar db "Erro ao adicionar produto a lista de itens.",0

;Leandro
MEMORYSIZE EQU 65535
NomeArquivo db "C:\RadASM\Masm\Projects\walvates\listaprodutos.txt",0
ErroProduto db "Não achou o produto",0

;valor de cada binario do codigo de barras
bar_0 db 114 ;1110010b
bar_1 db 102 ;1100110b
bar_2 db 108 ;1101100b
bar_3 db 66  ;1000010b
bar_4 db 92  ;1011100b
bar_5 db 78  ;1001110b
bar_6 db 80  ;1010000b
bar_7 db 68  ;1000100b
bar_8 db 72  ;1001000b
bar_9 db 116 ;1110100b


; prototipos
Proc_Evento PROTO :HWND,:UINT,:WPARAM,:LPARAM
getBarcode  PROTO :UINT,:HWND
leProduto PROTO :HWND
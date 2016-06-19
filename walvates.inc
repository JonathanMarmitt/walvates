; Prototipos funcoes WIN32
include windows.inc
include kernel32.inc
include user32.inc

; Bibliotecas funcoes WIN32
includelib kernel32.lib
includelib user32.lib

; Variável para passagem de ponteiro da janela
.data
Inst_principal dd ?
ponteiro_imagem dd ?
;buffer db [128]
;buffer_linha dw [91] ;largura
;largura_linha db 161
byte_inicio dd 13418        ;primeira parte de 6 digitos
byte_inicio_parte2 dw 13512 ;segunda parte de 6 digitos
tamanho db 13
bytes_por_numero db 7

buffer_linha db 84 dup (0)
buffer db 13816 dup(0) 
buffer_lido db 7 dup(0)

teste1 db 40 dup('A')
teste2 db 20 dup(0)
tes db 7 dup(0)

bytes_read dw ?
contador_a db ?
contador_b db ?
valor db ?

JANELA_PRINCIPAL EQU 1000
BOTAO EQU 1001
CAMPO EQU 1002

.const
path db "C:\RadASM\Masm\Projects\walvates\barcodes\7898112512114.bmp",0
erro db "Erro",0
erro_nao_bmp db "Arquivo enviado não é .bmp!",0

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
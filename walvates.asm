; Inicialização
.386
.model flat, stdcall ;Modelo de memória a ser usado

include walvates.inc
;include leProduto.inc

; Inicio do código
.code
start:
invoke GetModuleHandle,NULL ;pega o ponteiro deste programa, retorna em eax
mov    Inst_principal,eax
invoke InitCommonControls
invoke DialogBoxParam, Inst_principal,JANELA_PRINCIPAL,NULL,addr Proc_Evento,NULL
invoke ExitProcess,0

; Inicio do processo
.code
Proc_Evento proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

;Código do processo
	
	;Leitura do tipo de evento que ocorreu
	mov eax,uMsg
	;Evento de inicialização (abertura) de janela
	.if eax==WM_INITDIALOG
		;invoke GetDlgItem,hWin,1002
	.elseif eax==WM_COMMAND
		;wParam informa tipo (parte alta) e ID (parte baixa)
		mov eax,wParam
		mov edx,eax
		shr edx,16
		and eax,0FFFFh
		
		.if edx==BN_CLICKED
			.if eax == UPLOAD	
				;ver se da pra fazer uma funcao pra upload
				invoke RtlZeroMemory,offset ofn,sizeof ofn
				mov  ofn.lStructSize,SIZEOF ofn
				push hWin
				pop  ofn.hwndOwner
				push hInstance
				pop  ofn.hInstance
				mov  ofn.lpstrFilter, offset AddFilter
				mov  ofn.lpstrFile, offset FileN
				mov  ofn.nMaxFile, 260
				mov  ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
				mov  ofn.lpstrTitle, offset AddTitle
				
				invoke GetOpenFileName, offset ofn
				;se conseguiu abrir o arquivo
				.if eax==TRUE
					invoke SetDlgItemText, hWin, NOME_ARQUIVO, offset FileN
					
					invoke CreateFile,addr FileN, GENERIC_READ or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
				
					.if eax== INVALID_HANDLE_VALUE
						invoke MessageBox, hWin, addr erro_ler, addr erro, MB_OK
						ret
					.endif
					
					invoke getBarcode, eax, hWin
					
					.if ebx != 1 ;so prossegue se nao der erro
						invoke SetDlgItemText, hWin, CODIGO_BARRAS, eax
						;incluir aqui logica para procurar no arquivo
						
						;internamente, leProduto le no buffer_lido
						invoke leProduto, hWin
					.else
						mov eax, 0
						invoke SetDlgItemText,hWin, CODIGO_BARRAS, eax
					.endif
				.else
					invoke MessageBox, hWin, addr erro_abrir, addr erro, MB_OK
					ret
				.endif
			.elseif eax==ADICIONAR
				;adiciona um produto na lista de itens
				invoke GetDlgItemText, hWin, CAMPO_PRODUTO, addr buffer_linha, sizeof buffer_linha
				
				.if eax > 0
					;recupera a informacao da lista
					invoke GetDlgItemText, hWin, CAMPO_ITENS, addr buffer, sizeof buffer
					
					;pega o preco
					invoke GetDlgItemText,hWin, CAMPO_VALOR, addr Array, sizeof Array
					
					;junta o nome + preco + conteudo
					invoke lstrcat, addr buffer_linha, addr preco_linha
					invoke lstrcat, addr buffer_linha, addr Array
					invoke lstrcat, addr buffer_linha, addr final_linha
					invoke lstrcat, addr buffer,       addr buffer_linha
					
					;joga nos itens
					invoke SetDlgItemText,hWin, CAMPO_ITENS, addr buffer
					
					;limpa os campos
					invoke SetDlgItemText, hWin, NOME_ARQUIVO,  addr buffer_vazio
					invoke SetDlgItemText, hWin, CODIGO_BARRAS, addr buffer_vazio
					invoke SetDlgItemText, hWin, CAMPO_PRODUTO, addr buffer_vazio
					invoke SetDlgItemText, hWin, CAMPO_MARCA,   addr buffer_vazio
					invoke SetDlgItemText, hWin, CAMPO_VALOR,   addr buffer_vazio
					
					invoke getValorDecimal ;joga em eax o valor do produto atual em decimal
					
					add total, eax ;soma com o total
					
					;transforma o total em um numero com virgula
					invoke getTotal
					
					;invoke SetDlgItemInt, hWin, CAMPO_TOTAL, total, FALSE
					invoke SetDlgItemText, hWin, CAMPO_TOTAL, addr array_total					
				.else
					invoke MessageBox, hWin, addr erro_adicionar, addr erro, MB_OK	
				.endif
			.endif
		.endif
	;Evento de fechamento de janela
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret

;fim do código
Proc_Evento endp

getBarcode proc ponteiro:UINT, window:HWND				
	invoke ReadFile, ponteiro,addr buffer, sizeof buffer, bytes_read, FALSE
	
	.if buffer[0] != 'B' || buffer[1] != 'M'
		invoke MessageBox, window, addr erro_nao_bmp, addr erro, MB_OK
		mov ebx, 1 ;sinal de erro
		ret
	.endif

	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	
	mov contador_a, 0
	.while contador_a < 12
		mov contador_b, 0
		.while contador_b < 7
			mov al, contador_a
			mov dl, 7
			mul dl
			add al, contador_b
			
			mov cl, al ;index
			
			mov dl, 2
			mul dl
			mov bl, al ;index * 2
			
			mov esi, offset buffer ;source
			add esi, byte_inicio
			add esi, ebx
			.if contador_a > 5
				add esi, 10
			.endif
			
			mov edi, offset buffer_linha ;dest
			add edi, ecx ;index
			
			mov ecx, 1
			rep movsb
			
			inc contador_b
		.endw
		inc contador_a
	.endw
				
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	; aqui buffer_linha ja esta com toda a informacao, basta apenas decodificar
	mov contador_a, 0
	.while contador_a < 12
		mov bx, 0
		mov contador_b, 0
		.while contador_b < 7
			;0, 2 e 4: trocar 0 por 1
			;1, 3 e 5: inverter
			;    < 5 : normal
			
			mov al, contador_a
			mov dl, 7
			mul dl
			add al, contador_b
			
			.if	contador_a == 0 || contador_a == 2 || contador_a == 4
				; logica 1
				.if contador_b > 0
					rol bl, 1
				.endif
				
				mov cl, bl ;guardando valor
				mov bl, al ;recuperando indice
				.if buffer_linha[bx] == 255
					mov bl, cl
					add bl, 1
				.else
					mov bl, cl
					add bl, 0
				.endif
			.elseif contador_a == 1 || contador_a == 3 || contador_a == 5
				; logica 2
				mov cl, bl ;guardando valor
				mov bl, al ;recuperando indice
				.if buffer_linha[bx] == 255
					mov bl, cl
					add bl, 0
					ror bl, 1
				.else
					mov bl, cl
					add bl, 1
					ror bl, 1
				.endif
			.elseif  contador_a > 5
				; logica 3
				.if contador_b > 0
					rol bl, 1
				.endif
				
				mov cl, bl ;guardando valor
				mov bl, al ;recuperando indice
				.if buffer_linha[bx] == 255
					mov bl, cl
					add bl, 0
				.else
					mov bl, cl
					add bl, 1
				.endif						
			.endif
			inc contador_b
		.endw
		
		.if contador_a == 1 || contador_a == 3 || contador_a == 5
			ror bl, 1
		.endif
		
		mov ax, 0
		mov al, bl
		
		mov bx, 0
		mov bl, contador_a
		inc bl
		.if al == bar_0
			mov buffer_lido[bx], '0'
		.elseif al == bar_1
			mov buffer_lido[bx], '1'
		.elseif al == bar_2
			mov buffer_lido[bx], '2'
		.elseif al == bar_3
			mov buffer_lido[bx], '3'
		.elseif al == bar_4
			mov buffer_lido[bx], '4'
		.elseif al == bar_5
			mov buffer_lido[bx], '5'
		.elseif al == bar_6
			mov buffer_lido[bx], '6'
		.elseif al == bar_7
			mov buffer_lido[bx], '7'
		.elseif al == bar_8
			mov buffer_lido[bx], '8'
		.elseif al == bar_9
			mov buffer_lido[bx], '9'
		.endif
		
		inc contador_a
	.endw
	
	mov buffer_lido[0], '7'

	invoke CloseHandle, ponteiro
	
	mov eax, offset buffer_lido
	
	ret 
getBarcode endp

leProduto proc window:HWND
	mov contador, 0
	
	invoke CreateFile,addr NomeArquivo,GENERIC_READ or GENERIC_WRITE,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL

	.if eax == INVALID_HANDLE_VALUE
		invoke MessageBox, window, addr erro_lista, addr erro, MB_OK
		ret
	.endif	
	
	mov ponteiro_produtos, eax
    invoke ReadFile,ponteiro_produtos, addr retorno_arquivo, sizeof retorno_arquivo, addr bytes_escritos, NULL
	
	;Inicia o contador			
	mov bx, 0
	
	Inicio_Codigo:
	mov bx, contador
	;Chega no primeiro codigo 
	.while bx < 2262
		.if retorno_arquivo[bx] == 13	
		;invoke SetDlgItemInt,hWin, 1006, bx, FALSE
		jmp continua
		.endif
		add bx, 1
	.endw	
	jmp mensagem_nao_encontrou
					
	;Ajusta para o inicio do codigo de barras			
	continua:
	mov contador, bx			
	mov contador1, 0	
	add bx, 2

	;pega o codigo do produto
	.while retorno_arquivo[bx] != 9
		mov al, retorno_arquivo[bx]
		add bx, 1
		mov contador, bx
		
		mov bx, contador1
		mov Array_Arquivo[bx] , al
		add bx, 1
		mov contador1, bx
	
		mov bx, contador
	.endw	
	mov bx, contador
	mov al, retorno_arquivo[bx]
	mov bx, contador1
	
	
	mov bx, 0		
	.while bx < 14
		mov ah, Array_Arquivo[bx]
		.if ah == buffer_lido[bx] ;Array[bx] FIXME?
		add bx, 1
		.elseif
		jmp diferente
		.endif
	.endw
			
			
	jmp pula_diferente			
	diferente:
	jmp Inicio_Codigo
	pula_diferente:
	
	
	;reseta o buffer_inf_produtos_inf_produtos_inf_produtos
	mov bx, 0
	.while bx < 40
		mov buffer_inf_produtos[bx],32
		add bx, 1
	.endw
	mov bx, contador
	add bx, 1
	mov contador, bx
	mov contador1, 0	
	
	;pega o nome do produto
	.while retorno_arquivo[bx] != 9
		mov bx, contador
		mov al, retorno_arquivo[bx]
		add bx, 1
		mov contador, bx
		
		mov bx, contador1
		mov buffer_inf_produtos[bx] , al
		add bx, 1
		mov contador1, bx
	
		mov bx, contador
	.endw	
	invoke SetDlgItemText,window, CAMPO_PRODUTO, addr buffer_inf_produtos	
	
	
	;reseta o buffer_inf_produtos_inf_produtos
	mov bx, 0
	.while bx < 40
		mov buffer_inf_produtos[bx],32
		add bx, 1
	.endw
	
	mov bx, contador
	add bx, 1
	mov contador1, 0	
	;pega a marca do produto
	.while retorno_arquivo[bx] != 9
		mov al, retorno_arquivo[bx]
		add bx, 1
		mov contador, bx
		
		mov bx, contador1
		mov buffer_inf_produtos[bx] , al
		add bx, 1
		mov contador1, bx
	
		mov bx, contador
	.endw	
	invoke SetDlgItemText,window, CAMPO_MARCA, addr buffer_inf_produtos	
			
	;reseta o buffer_inf_produtos
	mov bx, 0
	.while bx < 40
		mov buffer_inf_produtos[bx],32
		add bx, 1
	.endw
	
	mov bx, contador
	add bx, 1
	mov contador1, 0	

	;pega o valor do produto
	.while retorno_arquivo[bx] != 13
		mov al, retorno_arquivo[bx]
		add bx, 1
		mov contador, bx
		
		mov bx, contador1
		mov buffer_inf_produtos[bx] , al
		add bx, 1
		mov contador1, bx
	
		mov bx, contador
	.endw	
	invoke SetDlgItemText,window, CAMPO_VALOR, addr buffer_inf_produtos
	
	invoke CloseHandle, ponteiro_produtos
					
	jmp fim	
	mensagem_nao_encontrou:
	invoke SetDlgItemText,window, CAMPO_PRODUTO, addr ErroProduto	
	fim:
	
	mov eax, 1 ; o que vai retornar?
	ret
leProduto endp

getValorDecimal proc
	
	;calculo do total
	mov eax,0
	mov ebx,0
	mov ecx,0
	mov edx,0
	.if Array[2] == ','
		; numero xx,xx
		mov al, Array[0]
		mov bl, Array[1]
		mov cl, Array[3]
		mov dl, Array[4]
		sub al, 48
	.elseif Array[1] == ','
		mov al, 0
		mov bl, Array[0]
		mov cl, Array[2]
		mov dl, Array[3]
	.endif
	sub bl, 48
	sub cl, 48
	sub dl, 48
	
	mov digito1, eax
	mov digito2, ebx
	mov digito3, ecx
	mov digito4, edx
	
	;parte baixa
	mov eax, digito3
	mov edx, 10
	mul edx
	add eax, digito4
	mov parte_baixa, eax
	
	;parte alta
	mov eax, digito2
	mov edx, 100
	mul edx
	mov parte_alta, eax
	
	mov eax, digito1
	mov edx, 1000
	mul edx
	add parte_alta, eax
	
	mov eax, parte_baixa
	add eax, parte_alta
	
	ret
getValorDecimal endp

getTotal proc
	mov eax,0
	
	.if total < 1000 ;3
		mov array_total[0], '0'
		mov array_total[1], ','
		mov array_total[2], '0'
		mov array_total[3], '0'
		mov array_total[4], 0
	.elseif total < 10000 ;4
		mov array_total[0], '0'
		mov array_total[1], '0'
		mov array_total[2], ','
		mov array_total[3], '0'
		mov array_total[4], '0'
		mov array_total[5], 0
	.else ;5
		mov array_total[0], '0'
		mov array_total[1], '0'
		mov array_total[2], '0'
		mov array_total[3], ','
		mov array_total[4], '0'
		mov array_total[5], '0'
		mov array_total[6], 0
	.endif
	
	ret
getTotal endp

;fim do código
end start
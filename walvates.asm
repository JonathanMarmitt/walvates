; Inicialização
.386
.model flat, stdcall ;Modelo de memória a ser usado

include walvates.inc

; Inicio do código
.code
start:
invoke GetModuleHandle,NULL ;pega o ponteiro deste programa, retorna em eax
mov    Inst_principal,eax
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
			.if eax == BOTAO				
				invoke CreateFile,addr path, GENERIC_READ or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
				
				.if eax== INVALID_HANDLE_VALUE
					invoke MessageBox, hWin, addr erro, addr erro, MB_OK
					ret
				.endif
				
				mov ponteiro_imagem, eax
				
				invoke ReadFile, ponteiro_imagem,addr buffer, sizeof buffer, bytes_read, FALSE
				
				.if buffer[0] != 'B' || buffer[1] != 'M'
					invoke MessageBox, hWin, addr erro_nao_bmp, addr erro, MB_OK
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
						;invoke MessageBox, hWin, addr erro, addr erro, MB_OK
						;invoke SetDlgItemInt,hWin, CAMPO, ecx, FALSE
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
						
						;mov bl, al ;index
						
						.if	contador_a == 0 || contador_a == 2 || contador_a == 4
							; logica 1
							
						.elseif contador_a == 1 || contador_a == 3 || contador_a == 5
							; logica 2
							
						.else ; contador_a > 5
							;.if contador_a == 6					
								;invoke SetDlgItemInt,hWin, CAMPO, al, FALSE
								;invoke MessageBox, hWin, addr erro, addr erro, MB_OK
							;.endif
							
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
					
					mov ax, 0
					mov al, bl
					
					mov bx, 0
					mov bl, contador_a
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
					;.else
						;.if contador_a > 5
						;	invoke SetDlgItemInt,hWin, CAMPO, al, FALSE
						;	invoke MessageBox, hWin, addr erro, addr erro, MB_OK
						;.endif
					.endif
					
					inc contador_a
				.endw
				
				mov buffer_lido[0], 'A'
				mov buffer_lido[1], 'A'
				mov buffer_lido[2], 'A'
				mov buffer_lido[3], 'A'
				mov buffer_lido[4], 'A'
				mov buffer_lido[5], 'A'
				
				invoke SetDlgItemText, hWin, 1003, addr buffer_lido
				;invoke MessageBox, hWin, addr erro_nao_bmp, addr erro, MB_OK
				;invoke SetDlgItemInt,hWin, CAMPO, buffer_lido[6], FALSE
				
				invoke CloseHandle, ponteiro_imagem
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

;fim do código
end start
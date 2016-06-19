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
				
				
				;invoke MessageBox, hWin, addr erro_nao_bmp, addr erro, MB_OK
				;invoke SetDlgItemInt,hWin, CAMPO, buffer_linha[45], FALSE
				
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
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
				
				
				
				
				invoke SetDlgItemInt,hWin, CAMPO, buffer[0], FALSE
				
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
option casemap:none
OPTION DOTNAME

include driver_install.inc
 .data?
dwTLS_Index dd  ?

OPTION    DOTNAME
;; 定义一个TLS节          
.tls  SEGMENT                        
TLS_Start LABEL  DWORD
 dd    0100h    dup ("slt.")
TLS_End   LABEL  DWORD
.tls   ENDS

.data
TLS_CallBackStart  dq  TlsCallBack0
TLS_CallBackEnd    dq  0
PUBLIC _tls_used
_tls_used IMAGE_TLS_DIRECTORY64 <TLS_Start, TLS_End, dwTLS_Index, TLS_CallBackStart, 0, ?>
.code

TlsCallBack0 proc uses rbx rsi rdi Dllhandle:LPVOID,dwReason:QWORD,lpvReserved:LPVOID  
     mov     rax,dwReason ;判断dwReason发生的条件
     cmp     eax,DLL_PROCESS_ATTACH  ; 在进行加载时被调用
     jnz     ExitTlsCallBack0
     invoke  FindWindow,addr ClassName,NULL  ;通过类名进行检测
     mov rbx,rax
     .if     eax {}0     ;找到
            invoke    SendMessage,rbx,WM_SYSCOMMAND, SC_MINIMIZE,NULL;SC_RESTORE  WM_CLOE
           	invoke    SendMessage,rbx,WM_SYSCOMMAND, SC_RESTORE,NULL;SC_RESTORE  WM_CLOE
          ;  invoke  
            invoke ExitProcess,0
     .endif
    ; invoke  MessageBox,NULL,addr szInTls,addr szTitle,MB_OK
    ; mov     dword ptr[TLS_Start],0  
     xor     eax,eax
   
ExitTlsCallBack0: 
     ret
TlsCallBack0   ENDP
WinMain proc  hInst:qword,hPrevInst:qword,CmdLine:qword,CmdShow:qword
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG
	LOCAL @hInst:qword
	LOCAL @hPrevInst:qword
	LOCAL @CmdLine:qword
	LOCAL @CmdShow:qword
	LOCAL icex:INITCOMMONCONTROLSEX
	
	
	
	invoke GetModuleHandle,0

	mov    hInstance,rax
	invoke GetCommandLine
	mov		CommandLine,rax
	invoke RtlZeroMemory,addr wc,sizeof wc
	invoke InitCommonControls
	 mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
   	 mov icex.dwICC,ICC_TAB_CLASSES
   	 invoke InitCommonControlsEx,addr icex
	
	
	
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	lea rax,WndProc
	mov		wc.lpfnWndProc,rax;offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU;0
	lea rax, ClassName
	mov		wc.lpszClassName,rax;offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,rax
	mov		wc.hIconSm,rax
	invoke LoadCursor,0,IDC_ARROW
	mov		wc.hCursor,rax
	invoke RegisterClassEx,addr wc
	
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	
	
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,0,0,0
		 .if eax == 0
	  		.break
	  	.endif
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	
	invoke ExitProcess,0
	mov rax,msg.wParam
	
	
	ret


WinMain endp

ASCII2HEX proc uses rbx rsi rdi pret_buffer:qword,size_ret_buffer:qword,pascii_buffer:qword,size_ascii_buffer:qword
	
		;内存中的ASCII码是高位在前低位在后（符合人们的阅读习惯） 比如 456 在内存中就是34 35 36 写作 四百五十六 并且显示的内容为16进制
		;存入pret_buffer内存中的数据是16进制,符合windows 的小尾模式：低位字节在前高位字节在后。
		
		mov rbx,size_ascii_buffer
		.if rbx { rsa_n_length*2
		
			mov rax,-1
			ret
		.endif
	
		mov rbx,size_ret_buffer
		.if rbx { rsa_n_length
		
			mov rax,-1
			ret
		.endif
	
	
		mov rcx,size_ascii_buffer
		mov rsi,pascii_buffer
		
		mov rdx,size_ret_buffer
		mov rdi,pret_buffer
				
		.while sqword ptr rcx } 0 && sqword ptr rdx } 0
			and rax,0
			and rbx,0
					
			mov al, byte ptr [rsi]
					
			.if al }= "0" && al {= "9"
						
				sub al,"0"
						
			.elseif al }= "A" && al {= "F"
				sub al,"0"
				sub al,7
			.elseif al }= "a" && al {= "f"	
						
				sub al,"0"
				sub al,27h	
			.elseif al == 0
						
						
			;	invoke MessageBox,0,addr compcheck1,0,MB_OK
			;	mov rax,-1
			;	ret		
			.else
				mov rax,-1
				ret	
			.endif
					
					
			dec rcx
			
			inc rsi
			mov bl, byte ptr [rsi]
					
			.if bl }= "0" && bl {= "9"
						
				sub bl,"0"
						
						
			.elseif bl }= "A" && bl {= "F"
				sub bl,"0"
				sub bl,7
			.elseif bl }= "a" && bl {= "f"	
						
				sub bl,"0"
				sub bl,27h	
			.elseif bl == 0;ascii 结束标志
				
						
			.else
				mov rax,-1
				ret	
			.endif
			shl al,4
			or al,bl
			cld
			stosb 
					
					
			
			dec rcx
			dec rdx
			inc rsi
		.endw
			
	ret

ASCII2HEX endp

comment ~
ASCII2HEX proc uses rbx rsi rdi pret_buffer:qword,size_ret_buffer:qword,pascii_buffer:qword,size_ascii_buffer:qword
		LOCAL @real_ascii_buffer_length:qword
		;内存中的ASCII码是高位在前低位在后（符合人们的阅读习惯） 比如 456 在内存中就是34 35 36 写作 四百五十六 并且显示的内容为16进制
		;存入pret_buffer内存中的数据是16进制,符合windows 的小尾模式：低位字节在前高位字节在后。
		invoke RtlZeroMemory,pret_buffer,size_ret_buffer
		invoke lstrlen,pascii_buffer
		mov @real_ascii_buffer_length,rax
		
		mov rcx,size_ascii_buffer
		.if rax { rcx
			
			mov rcx,rax
		.endif
		
		mov rsi,pascii_buffer
		lea rsi,[rsi+rax-1]		;从最后一个开始 (如果是三个字节 这里只用加2就可以了)
		
		mov rdx,size_ret_buffer
		mov rdi,pret_buffer
				
		.while sqword ptr rcx } 0 && sqword ptr rdx } 0
			and rax,0
			and rbx,0
					
			mov al, byte ptr [rsi]
					
			.if al }= "0" && al {= "9"
						
				sub al,"0"
						
						
			.elseif al }= "A" && al {= "F"
				sub al,"0"
				sub al,7
			.elseif al }= "a" && al {= "f"	
						
				sub al,"0"
				sub al,27h	
			.elseif al == 0	;ascii 结束标志
						
			;	.break		
			;	invoke MessageBox,0,addr compcheck1,0,MB_OK
			;	mov rax,-1
			;	ret		
			.else
				mov rax,-1
				ret	
			.endif
			;相减之后4位就可以表达，一个字节8位，所以可以再计算一个字节	，但有可能这已经是最后一位了。	
			or byte ptr [rdi],al
				
			dec rcx
			dec rsi
			
			.if rcx == 0	;如果是奇数，这里就结束了。
				mov rax,1
				ret
				
			.endif
			
			mov bl, byte ptr [rsi]
					
			.if bl }= "0" && bl {= "9"
						
				sub bl,"0"
						
			.elseif bl }= "A" && bl {= "F"
				sub bl,"0"
				sub bl,7
			.elseif bl }= "a" && bl {= "f"	
						
				sub bl,"0"
				sub bl,27h	
			.elseif bl == 0
				;已经到最后了，需要计算之前的数据
				.break		
			.else
				mov rax,-1
				ret	
			.endif
			
			shl bl,4
			or bl,al
			or byte ptr [rdi],bl
					
			dec rcx
			dec rdx
			dec rsi
			inc rdi
		.endw
			mov rax,1
	ret

ASCII2HEX endp
comment ~
HEX2ASCII proc uses rbx rsi rdi pret_buffer:qword,size_ret_buffer:qword,phex_buffer:qword,size_hex_buffer:qword	;16进制转ascii
	
	
		invoke RtlZeroMemory,pret_buffer,size_ret_buffer
		
		mov rsi,phex_buffer		;16进制是低位在前，高位在后，转换到内存中是高位在前，低位在后
		mov rdi,pret_buffer
		
		mov rcx,size_hex_buffer
		mov rdx,size_ret_buffer
		
		lea rsi,[rsi+rcx-4]		;从最高位开始，一次读4字节
		.while sqword ptr rcx } 0
			mov ebx,dword ptr [rsi]
			mov r8,8	;每次处理4位
			.while r8 } 0
				
				rol ebx,4	;先把最高位移到最低位
				mov eax,ebx
				and al,0fh	;先算低4位
			
				.if al }=0 && al {= 9
					add al,30h
				.elseif al }=0ah && al {= 0fh
					add al,37h
				.else
					mov rax,-1
					ret
				.endif
				
				mov byte ptr [rdi],al
				
				inc rdi
				dec r8
			.endw
			
		
			
			sub rsi,4
			sub rcx,4
		.endw
		
		mov rsi,pret_buffer
		mov rcx,size_ret_buffer
		
		.while rcx }0	;检测开头的“0”去掉
			
			.if byte ptr [rsi] == 30h;"0"
				inc rsi
			.else
				.break	
			.endif
			
			dec rcx
			
		.endw
		
		mov rdi,pret_buffer
		cld
		rep movsb
		
		mov rax,1
	
	
	ret

HEX2ASCII endp
rsa_calmod proc uses rbx rsi rdi r11 r12 r13 r14 r15 prsa_n_buffer_and_value:qword,_prsacalbuffer_for_mid:qword,count:qword
	
	LOCAL @addflags_craay:qword
	
	
		mov r12,prsa_n_buffer_and_value
		lea r12,[r12+rsa_n_length_8*63]
		lea r12,[r12+rsa_n_length_8-8]
		mov rbx,rsa_n_length_8*64
	
		.while rbx {} 0
			mov rdi,r12
			mov  rsi,_prsacalbuffer_for_mid
			add rsi,rsa_n_length_8-8
		
			
			mov ecx,rsa_n_length_8/8
			std
			repz cmpsq
		
		
			.if ~(CARRY?) && ~ZERO?	;大于就减
			
				mov r15,0
				mov  @addflags_craay,0
				mov  rdi,_prsacalbuffer_for_mid
				mov rsi,r12
				sub rsi,rsa_n_length;定位到头部
			
				.while r15 {} rsa_n_length_8 
					shr @addflags_craay,1
					
					mov rax,[rsi+r15]
					
					sbb [rdi+r15],rax
					setc byte ptr @addflags_craay	;把进位保存
					add r15,8
				.endw
				
			
			.endif
		
			sub rbx,rsa_n_length_8 
			sub r12,rsa_n_length_8 ;指向上一个中间数据的尾部的8字节
		.endw
	
		
		.if count } 8
		
			nop
			mov  rsi,_prsacalbuffer_for_mid
			
			lea rsi,[rsi+rsa_n_length_8-8-8]
		
			mov rdi,_prsacalbuffer_for_mid
			lea rdi,[rdi+rsa_n_length_8-8]
			mov rcx,rsa_n_length/8	;少移动8字节，小心内存泄漏
			std 
			rep movsq
	
			mov rsi,_prsacalbuffer_for_mid
			mov qword ptr [rsi],0;相当于左移64位 最低位补0
			
		;	invoke rsa_calmod,prsa_n_buffer_and_value,_prsacalbuffer_for_mid,0
		
			mov r12,prsa_n_buffer_and_value
			lea r12,[r12+rsa_n_length_8*63]
			lea r12,[r12+rsa_n_length_8-8]
			mov rbx,rsa_n_length_8*64
	
			.while rbx {} 0
				mov rdi,r12
				mov  rsi,_prsacalbuffer_for_mid
				add rsi,rsa_n_length_8-8
		
				
				mov ecx,rsa_n_length_8/8
				std
				repz cmpsq
		
		
				.if ~(CARRY?) && ~ZERO?	;大于就减
			
					mov r15,0
					mov  @addflags_craay,0
					mov  rdi,_prsacalbuffer_for_mid
					mov rsi,r12
					sub rsi,rsa_n_length;定位到头部
			
					.while r15 {} rsa_n_length_8 
						shr @addflags_craay,1
					
						mov rax,[rsi+r15]
					
						sbb [rdi+r15],rax
						setc byte ptr @addflags_craay	;把进位保存
						add r15,8
					.endw
				
			
				.endif
		
				sub rbx,rsa_n_length_8 
				sub r12,rsa_n_length_8 ;指向上一个中间数据的尾部的8字节
			.endw
	
		
		.endif
		
	ret

rsa_calmod endp

rsamul_to_mod proc	uses rbx rsi rdi r11 r12 r13 r14 r15 preturn_rsa:qword, pmingma:qword,pmingma1:qword,_prsa_n_buffer_and_value:qword		; pmingma*pmingma1 mod prsa_n_buffer_and_value
	
	LOCAL @addflags_craay:qword ;每次相加产生的进位
	
	LOCAL @flags_c_mod:qword
	
	LOCAL @count:qword
	LOCAL @pmidvalue:qword
	LOCAL @prsacalbuffer_for_mid:qword
	
	invoke GetProcessHeap
	mov rbx,rax
	
	cld ;如果是std 的话会分配错误
	invoke HeapAlloc,rbx,HEAP_ZERO_MEMORY,rsa_n_length_8*68
	
	mov @prsacalbuffer_for_mid,rax	;相乘的结果					
	
	invoke HeapAlloc, rbx, HEAP_ZERO_MEMORY,rsa_n_length_8*68
	
    mov @pmidvalue, rax;被乘数的中间值 
	
	mov rcx,(rsa_n_length_8 )/8
	mov rsi,pmingma
	mov rdi,@pmidvalue ;被乘数的中间值 68*88
	cld 
	rep movsq
	
	mov rsi,@pmidvalue
	
			
	mov ebx,63	;64位系统，单次就可以处理64位长度的数据:我们把pmingma值的总共左移63次的结果全部保存下来，用来加快求余的过程
	.while ebx {}0
			
		mov ecx,rsa_n_length_8  ;字节长度	;每次加密的数据长度是80h字节，我们在内存中按88h字节处理，移位后的进位项需要占用一些内存，最多占用64位
		
		mov  @flags_c_mod,0
		.while ecx {} 0	;80h个数据整体左移一位的结果，*2
			cld	
			shr @flags_c_mod,1
			lodsq;	mov rax,qword ptr [rsi]
			rcl rax,1
			setc byte ptr @flags_c_mod
			stosq;	mov qword ptr [rdi],rax
			sub rcx,8
		.endw	
		dec ebx
	.endw
	
		
	mov rsi,pmingma1	
	lea rsi,[rsi+rsa_n_length_8 ];定位到最高位 
	sub rsi,8 ;减去8字节 开始获取最高位的8字节数据
	sub rdi,8	
	mov r12,rdi	;@pmidvalue 最高位
	
	mov r13,@prsacalbuffer_for_mid
	mov r14,_prsa_n_buffer_and_value
	
	mov ebx,rsa_n_length_8 	
	.while ebx {} 0
		std	;从高位向低位获取
		lodsq
			
		mov r11,rax
		mov r14,64	;
		.while r14{}0
			shl r11,1	;从最高位开始测试
			
			.if CARRY?
				mov r15,0
				mov  @addflags_craay,0
				sub r12,rsa_n_length;定位到头部 会影响cf标志
				.while r15 {} rsa_n_length_8 
					
						
					shr @addflags_craay,1
					mov rax,[r12+r15]
					
					adc [r13+r15],rax
					setc byte ptr @addflags_craay	;把进位保存
					add r15,8
				.endw
					
				add r12,rsa_n_length;重新定位到尾部
				
			.endif
			sub r12,rsa_n_length_8 ;指向上一个中间数据的尾部的8字节
			dec r14
		.endw
		invoke rsa_calmod,_prsa_n_buffer_and_value,@prsacalbuffer_for_mid,rbx
			
		sub ebx,8
		mov r12,rdi
	.endw
	mov rsi,@prsacalbuffer_for_mid
	
	mov rdi,preturn_rsa
	mov rcx,rsa_n_length/8
	cld
	rep movsq	
	invoke GetProcessHeap
	mov rbx,rax
	invoke HeapFree,rbx,0,@prsacalbuffer_for_mid
	invoke HeapFree,rbx,0,@pmidvalue
	
	ret

rsamul_to_mod endp

rsadec proc uses rsi rdi rbx r11 r12 r13 r14 r15 _preturn_rsa:qword,_pmingma:qword
	LOCAL @heap:qword
	LOCAL @pn_value_buffer:qword
	
	LOCAL @prsa_n_buffer_for_value:qword
	
	LOCAL @flags_c_mod:qword
	LOCAL @pd_value_buffer:qword
	LOCAL @pmingma1:qword
			invoke GetProcessHeap
			mov @heap,rax
			
			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8
    		mov @pmingma1, rax
    		
			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8
    		mov @pn_value_buffer, rax
			
			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8
    		mov @pd_value_buffer, rax
    		
			
    	
   			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8*68
   		
    		mov @prsa_n_buffer_for_value,rax
    		
								
	
			invoke ASCII2HEX,@pn_value_buffer,rsa_n_length_8,addr rsa_n_ascii,256
			;内存中的数据需要低位在前高位在后
			
		
			mov rcx,rsa_n_length
			mov rbx,rsa_n_length/2
			mov rsi,@pn_value_buffer
			mov rax,0
			.while rbx } 0
				
				
				mov dl,[rsi+rax]
				xchg [rsi+rcx-1],dl
				xchg [rsi+rax],dl
				
				
				inc rax
				dec rcx
				dec rbx
			.endw
			
			invoke ASCII2HEX,@pd_value_buffer,rsa_n_length_8,addr rsa_d_ascii,256
			;内存中的数据需要低位在前高位在后
			
		
			mov rcx,rsa_n_length
			mov rbx,rsa_n_length/2
			mov rsi,@pd_value_buffer
			mov rax,0
			.while rbx } 0
				
				
				mov dl,[rsi+rax]
				xchg [rsi+rcx-1],dl
				xchg [rsi+rax],dl
				
				
				inc rax
				dec rcx
				dec rbx
			.endw
			
			mov rsi,@pn_value_buffer
			mov rdi,@prsa_n_buffer_for_value	;
			mov ecx,rsa_n_length/8
			cld
			rep movsq
			add rdi,8	
			
			mov rsi,@prsa_n_buffer_for_value	
			
			mov ebx,63	;64位系统，单次就可以处理64位长度的数据:我们把n值的总共左移63次的结果全部保存下来，用来加快求余的过程 
					;;64个80h+8字节的缓冲区，存放x*2^1 到x*2^63 的数据 （2x 4x 8x 16x 32x 64x 128x 256x ....)
			.while ebx {}0
			
				mov ecx,rsa_n_length_8  ;字节长度	;每次加密的数据长度是80h字节，我们在内存中按88h字节处理，移位后的进位项需要占用一些内存，最多占用64位
				mov edx,0
			
				mov  @flags_c_mod,0
				.while ecx {} 0	;80h个数据整体左移一位的结果，*2
					cld
					shr @flags_c_mod,1
					lodsq;	mov rax,qword ptr [rsi]
					rcl rax,1
					setc byte ptr @flags_c_mod
					cld
					stosq;	mov qword ptr [rdi],rax
					sub rcx,8
				.endw	
				dec ebx
			.endw
	
			and @flags_c_mod,0
			mov rax,@pmingma1
			or qword ptr [rax],1	;第一次是1
			mov rsi,@pd_value_buffer	
			lea rsi,[rsi+rsa_n_length];定位到最高位 
			sub rsi,8 ;减去8字节 开始获取最高位的8字节数据
			
			mov ebx,rsa_n_length
			.while ebx {} 0
				std	;从高位向低位获取
				lodsq
				mov r12,rax
				
				mov r13,64	;每次处理64位数据
				.while sqword ptr r13 }0
					
					shl r12,1;从最高位开始测试
			
					setc byte ptr @flags_c_mod	;保存最高位的值
				
					
					invoke rsamul_to_mod,_preturn_rsa,@pmingma1,@pmingma1,@prsa_n_buffer_for_value	
					
					push rsi
					
					mov rsi, _preturn_rsa
					mov rdi,  @pmingma1
				
					mov ecx,rsa_n_length/8
			
					cld 
					rep movsq
					pop rsi
					shr  dword  ptr @flags_c_mod,1	;
					.if CARRY?	;最高位的值如果为真
					
						invoke rsamul_to_mod,_preturn_rsa,_pmingma,@pmingma1,@prsa_n_buffer_for_value
						
						push rsi
						mov rsi, _preturn_rsa
						mov rdi,  @pmingma1
				
						mov ecx,rsa_n_length/8
			
						cld 
						rep movsq
						
						pop rsi
						
						
					.endif
					dec r13
				
				.endw
				sub ebx,8
			.endw
			invoke GetProcessHeap
			mov rbx,rax
			invoke HeapFree,rbx,0,@pmingma1
			invoke HeapFree,rbx,0,@pn_value_buffer
			invoke HeapFree,rbx,0,@pd_value_buffer
			invoke HeapFree,rbx,0,@prsa_n_buffer_for_value
		
	ret
rsadec endp


rsaenc proc uses rsi rdi rbx r11 r12 r13 r14 r15 _preturn_rsa:qword,_pmingma:qword
	LOCAL @heap:qword
	LOCAL @pn_value_buffer:qword
	
	LOCAL @prsa_n_buffer_for_value:qword
	
	LOCAL @flags_c_mod:qword
	LOCAL @pe_value_buffer:qword
	LOCAL @pmingma1:qword
			invoke GetProcessHeap
			mov @heap,rax
			
			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8
    		mov @pmingma1, rax
    		
			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8
    		mov @pn_value_buffer, rax
			
			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8
    		mov @pe_value_buffer, rax
    		
			
    	
   			invoke HeapAlloc, @heap, HEAP_ZERO_MEMORY,rsa_n_length_8*68
   		
    		mov @prsa_n_buffer_for_value,rax
    		
								

			invoke ASCII2HEX,@pn_value_buffer,rsa_n_length_8,addr rsa_n_ascii,256
			;内存中的数据需要低位在前高位在后
			
		
			mov rcx,rsa_n_length
			mov rbx,rsa_n_length/2
			mov rsi,@pn_value_buffer
			mov rax,0
			.while rbx } 0
				
				mov dl,[rsi+rax]
				xchg [rsi+rcx-1],dl
				xchg [rsi+rax],dl
				
				
				inc rax
				dec rcx
				dec rbx
			.endw
			
			invoke ASCII2HEX,@pe_value_buffer,rsa_n_length_8,addr rsa_e_ascii,256
			;内存中的数据需要低位在前高位在后
			
		
			mov rcx,rsa_n_length
			mov rbx,rsa_n_length/2
			mov rsi,@pe_value_buffer
			mov rax,0
			.while rbx } 0
				
				
				mov dl,[rsi+rax]
				xchg [rsi+rcx-1],dl
				xchg [rsi+rax],dl
				
				
				inc rax
				dec rcx
				dec rbx
			.endw
			
			mov rsi,@pn_value_buffer
			mov rdi,@prsa_n_buffer_for_value	;
			mov ecx,rsa_n_length/8
			cld
			rep movsq
			add rdi,8	
			
			mov rsi,@prsa_n_buffer_for_value	
			
			mov ebx,63	;64位系统，单次就可以处理64位长度的数据:我们把n值的总共左移63次的结果全部保存下来，用来加快求余的过程 
					;;64个80h+8字节的缓冲区，存放x*2^1 到x*2^63 的数据 （2x 4x 8x 16x 32x 64x 128x 256x ....)
			.while ebx {}0
			
				mov ecx,rsa_n_length_8  ;字节长度	;每次加密的数据长度是80h字节，我们在内存中按88h字节处理，移位后的进位项需要占用一些内存，最多占用64位
				mov edx,0
			
				mov  @flags_c_mod,0
				.while ecx {} 0	;80h个数据整体左移一位的结果，*2
					cld
					shr @flags_c_mod,1
					lodsq;	mov rax,qword ptr [rsi]
					rcl rax,1
					setc byte ptr @flags_c_mod
					cld
					stosq;	mov qword ptr [rdi],rax
					sub rcx,8
				.endw	
				dec ebx
			.endw
	
			and @flags_c_mod,0
			mov rax,@pmingma1
			or qword ptr [rax],1	;第一次是1
			mov rsi,@pe_value_buffer	
			lea rsi,[rsi+rsa_n_length];定位到最高位 
			sub rsi,8 ;减去8字节 开始获取最高位的8字节数据
			
			mov ebx,rsa_n_length
			.while ebx {} 0
				std	;从高位向低位获取
				lodsq
				mov r12,rax
				
				mov r13,64	;每次处理64位数据
				.while sqword ptr r13 }0
					
					shl r12,1;从最高位开始测试
			
					setc byte ptr @flags_c_mod	;保存最高位的值
				
					
					invoke rsamul_to_mod,_preturn_rsa,@pmingma1,@pmingma1,@prsa_n_buffer_for_value	
					
					push rsi
					
					mov rsi, _preturn_rsa
					mov rdi,  @pmingma1
				
					mov ecx,rsa_n_length/8
			
					cld 
					rep movsq
					pop rsi
					shr  dword  ptr @flags_c_mod,1	;
					.if CARRY?	;最高位的值如果为真
					
						invoke rsamul_to_mod,_preturn_rsa,_pmingma,@pmingma1,@prsa_n_buffer_for_value
						
						push rsi
						mov rsi, _preturn_rsa
						mov rdi,  @pmingma1
				
						mov ecx,rsa_n_length/8
			
						cld 
						rep movsq
						
						pop rsi
						
						
					.endif
					dec r13
				
				.endw
				sub ebx,8
			.endw
			invoke GetProcessHeap
			mov rbx,rax
			invoke HeapFree,rbx,0,@pmingma1
			invoke HeapFree,rbx,0,@pn_value_buffer
			invoke HeapFree,rbx,0,@pe_value_buffer
			invoke HeapFree,rbx,0,@prsa_n_buffer_for_value
			
	ret
rsaenc endp

check_box_proc proc uses rsi rdi rbx r11 r12 r13 r14 r15 hWin:qword,uMsg:UINT64,wParam:WPARAM,lParam:LPARAM 
	LOCAL @temp_buffer [256]:qword
	LOCAL @hex_buffer:qword
	mov	rax,uMsg
	.if eax ==BM_SETCHECK
		
		.if wParam == BST_CHECKED	;将按钮状态设置为选中。
		
			
			invoke GetDlgItemText,hwnd_vm_hook,2026,addr @temp_buffer,sizeof @temp_buffer
			invoke ASCII2HEX,addr @hex_buffer,sizeof @hex_buffer,addr @temp_buffer,sizeof @temp_buffer
				
			
			invoke GetDlgCtrlID,hWin
			.if rax == 2029
				mov rax,@hex_buffer
				bts rax,flags_CF
				
			.elseif rax == 2030
				mov rax,@hex_buffer
				bts rax,flags_PF
			
			.elseif rax == 2031
				mov rax,@hex_buffer
				bts rax,flags_AF
			
			.elseif rax == 2032
				mov rax,@hex_buffer
				bts rax,flags_ZF
			
			.elseif rax == 2033
				mov rax,@hex_buffer
				bts rax,flags_SF
			
			.elseif rax == 2034
				mov rax,@hex_buffer
				bts rax,flags_TF
			
			.elseif rax == 2035
				mov rax,@hex_buffer
				bts rax,flags_IF
			
			.elseif rax == 2036
				mov rax,@hex_buffer
				bts rax,flags_DF
			
			.elseif rax == 2037
				mov rax,@hex_buffer
				bts rax,flags_OF
			.endif	
			bts rax,flags_reserved4_1
				
			btr rax,flags_reserved3_ZERO
			btr rax,flags_reserved2_ZERO
			btr rax,flags_reserved1_ZERO
			
			mov rdx,not mask flags_reserved_32_23;该字段在总位数中的位置 用1置位
			and rax,rdx
		;	and eax,not mask flags_reserved_32_23
			mov @hex_buffer,rax
			invoke HEX2ASCII,addr @temp_buffer,sizeof @temp_buffer,addr @hex_buffer,sizeof @hex_buffer
			invoke SetDlgItemText,hwnd_vm_hook,2026,addr @temp_buffer
			
		.elseif  wParam ==BST_UNCHECKED	;将按钮状态设置为“已清除”。
			invoke GetDlgItemText,hwnd_vm_hook,2026,addr @temp_buffer,sizeof @temp_buffer
			invoke ASCII2HEX,addr @hex_buffer,sizeof @hex_buffer,addr @temp_buffer,sizeof @temp_buffer
				
			
			
			
			invoke GetDlgCtrlID,hWin
			.if rax == 2029
				mov rax,@hex_buffer
				btr rax,flags_CF
				
			.elseif rax == 2030
				mov rax,@hex_buffer
				btr rax,flags_PF
			
			.elseif rax == 2031
				mov rax,@hex_buffer
				btr rax,flags_AF
			
			.elseif rax == 2032
				mov rax,@hex_buffer
				btr rax,flags_ZF
			
			.elseif rax == 2033
				mov rax,@hex_buffer
				btr rax,flags_SF
			
			.elseif rax == 2034
				mov rax,@hex_buffer
				btr rax,flags_TF
			
			.elseif rax == 2035
				mov rax,@hex_buffer
				btr rax,flags_IF
			
			.elseif rax == 2036
				mov rax,@hex_buffer
				btr rax,flags_DF
			
			.elseif rax == 2037
				mov rax,@hex_buffer
				btr rax,flags_OF
			.endif	
			
			bts rax,flags_reserved4_1
				
			btr rax,flags_reserved3_ZERO
			btr rax,flags_reserved2_ZERO
			btr rax,flags_reserved1_ZERO
			
			mov rdx,not mask flags_reserved_32_23;该字段在总位数中的位置 用1置位
			and rax,rdx
			
			mov @hex_buffer,rax
			invoke HEX2ASCII,addr @temp_buffer,sizeof @temp_buffer,addr @hex_buffer,sizeof @hex_buffer
			invoke SetDlgItemText,hwnd_vm_hook,2026,addr @temp_buffer
			
		.elseif wParam ==BST_INDETERMINATE;将按钮状态设置为灰色，指示不确定状态。 仅当按钮具有 BS_3STATE 或 BS_AUTO3STATE 样式时，才使用此值。
		.endif
		;我们并没有完美处理这个消息，所以还需要“默认”处理程序继续处理
		
		
		
		
		invoke  CallWindowProcA, lpOrg_check_box_cf_Proc, hWin, uMsg, wParam, lParam
	
		mov rax,0;不需要默认处理
		ret
	.else
		invoke GetDlgCtrlID,hWin
		.if rax == 2029
			mov rcx,lpOrg_check_box_cf_Proc
			
		.elseif rax == 2030
			mov rcx,lpOrg_check_box_pf_Proc
			
		.elseif rax == 2031
			mov rcx,lpOrg_check_box_af_Proc
			
		.elseif rax == 2032
			mov rcx,lpOrg_check_box_zf_Proc
			
		.elseif rax == 2033
			mov rcx,lpOrg_check_box_sf_Proc
			
		.elseif rax == 2034
			mov rcx,lpOrg_check_box_tf_Proc
			
		.elseif rax == 2035
			mov rcx,lpOrg_check_box_if_Proc
			
		.elseif rax == 2036
			mov rcx,lpOrg_check_box_df_Proc
			
		.elseif rax == 2037
			mov rcx,lpOrg_check_box_of_Proc
		.endif	
		invoke  CallWindowProcA, rcx, hWin, uMsg, wParam, lParam
	.endif	
	ret

check_box_proc endp
edit_proc proc uses rsi rdi rbx r11 r12 r13 r14 r15 hWin:qword,uMsg:UINT64,wParam:WPARAM,lParam:LPARAM 
	LOCAL @temp_buffer [256]:qword
	LOCAL @hex_buffer:qword
	
		mov	rax,uMsg
		.if eax ==WM_KILLFOCUS;WM_SETFOCUS
			
			invoke GetDlgItemText,hwnd_vm_hook,2026,addr @temp_buffer,sizeof @temp_buffer
			invoke ASCII2HEX,addr @hex_buffer,sizeof @hex_buffer,addr @temp_buffer,sizeof @temp_buffer
			mov rbx,@hex_buffer
		
			mov eax,ebx
			and eax,mask flags_CF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2029,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2029,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov eax,ebx
			and eax,mask flags_PF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2030,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2030,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov eax,ebx
			and eax,mask flags_AF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2031,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2031,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov eax,ebx
			and eax,mask flags_ZF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2032,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2032,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			
			mov eax,ebx
			and eax,mask flags_SF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2033,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2033,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov eax,ebx
			and eax,mask flags_TF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2034,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2034,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov eax,ebx
			and eax,mask flags_IF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2035,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2035,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov eax,ebx
			and eax,mask flags_DF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2036,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2036,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			
			mov eax,ebx
			and eax,mask flags_OF
			.if eax {} 0
				invoke SendDlgItemMessage,hwnd_vm_hook,2037,BM_SETCHECK,BST_CHECKED,0
			.elseif eax == 0	
				invoke SendDlgItemMessage,hwnd_vm_hook,2037,BM_SETCHECK,BST_UNCHECKED,0
			.endif
			
			mov rcx,lpOrg_edit_Proc
			invoke  CallWindowProcA, rcx, hWin, uMsg, wParam, lParam
			
		
		.else
			mov rcx,lpOrg_edit_Proc
			invoke  CallWindowProcA, rcx, hWin, uMsg, wParam, lParam
		.endif
	
	ret

edit_proc endp
_ProcDlg_vm_hook proc  uses rsi rdi rbx r11 r12 r13 r14 r15 hWin:qword,uMsg:UINT64,wParam:WPARAM,lParam:LPARAM 
	local @mingma_buffer[88h]:byte
	
	LOCAL @return_rsa  [88h]:byte
	LOCAL @pprogram_address_buffer:qword
	LOCAL @all_count:qword
	LOCAL @pprogram_address_buffer_back:qword
	LOCAL @dwBytesReturned:qword 
		mov	rax,uMsg
		.if eax ==	WM_INITDIALOG
			mov rax,hWin
			mov hwnd_vm_hook,rax
			
			
			invoke GetDlgItem,hwnd_vm_hook,2029
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_cf_Proc,rax
			
			
			invoke GetDlgItem,hwnd_vm_hook,2030
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_pf_Proc,rax
			
			invoke GetDlgItem,hwnd_vm_hook,2031
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_af_Proc,rax
			
			
			invoke GetDlgItem,hwnd_vm_hook,2032
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_zf_Proc,rax
			
			
			invoke GetDlgItem,hwnd_vm_hook,2033
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_sf_Proc,rax
			
			invoke GetDlgItem,hwnd_vm_hook,2034
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_tf_Proc,rax
			
			invoke GetDlgItem,hwnd_vm_hook,2035
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_if_Proc,rax
			
			
			invoke GetDlgItem,hwnd_vm_hook,2036
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_df_Proc,rax
			
			invoke GetDlgItem,hwnd_vm_hook,2037
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr check_box_proc;rsi;addr list_proc
			mov lpOrg_check_box_of_Proc,rax
			
			
			invoke GetDlgItem,hwnd_vm_hook,2026 ;edit
			invoke SetWindowLongPtrA ,rax,GWL_WNDPROC,addr edit_proc;rsi;addr list_proc
			mov lpOrg_edit_Proc,rax
			
		.elseif	eax == WM_COMMAND
				mov	rax,wParam
				.if	ax == 2028		;取消退出
					invoke	EndDialog,hwnd_vm_hook,NULL
				.elseif rax == 2027;保存退出
					
					invoke GetProcessHeap
					invoke HeapAlloc,rax,HEAP_ZERO_MEMORY,80h*8
					.if rax {} 0
						mov @pprogram_address_buffer,rax
					.endif
					mov rdi,@pprogram_address_buffer
					mov [rdi+program_address.type_count],4
					
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemTextW,hWin,2004,addr mingma_buffer,sizeof mingma_buffer	
					.if sqword ptr rax }78h
						ret
					.endif
					
					mov rdi,@pprogram_address_buffer
					lea rdi,[rdi+program_address.v.api_name_count]
					shl rax,1		;长度为UNICODE格式 所以要加一倍
					mov [rdi],rax
					lea rsi,mingma_buffer
					mov rcx,[rdi]
					add rdi,8
					cld
					rep movsb
					
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
				
					invoke GetDlgItemText,hWin,2006,addr mingma_buffer,sizeof mingma_buffer
					.if sqword ptr rax }78h
						ret
					.endif
				
					mov [rdi],rax
					shr qword ptr  [rdi],1
					invoke ASCII2HEX,addr [rdi+8],[rdi],addr mingma_buffer,rax
					add rdi,[rdi]
					add rdi,8
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2009,addr mingma_buffer,sizeof mingma_buffer	
					.if sqword ptr rax }78h
						ret
					.endif
					mov [rdi],rax
					shr qword ptr  [rdi],1
					invoke ASCII2HEX,addr [rdi+8],[rdi],addr mingma_buffer,rax
					add rdi,[rdi]
					add rdi,8
					
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2010,addr mingma_buffer,sizeof mingma_buffer	
					.if sqword ptr rax }78h
						ret
					.endif
					mov [rdi],rax
					shr  qword ptr [rdi],1
					invoke ASCII2HEX,addr [rdi+8],[rdi],addr mingma_buffer,rax
					add rdi,[rdi]
					add rdi,8
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2038,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rax],8,addr mingma_buffer,rax
					
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rax_f],1
					.endif
					
					
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2001,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rbx],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rbx_f],1
					.endif
					
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2012,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rcx],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rcx_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2011,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rdx],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rdx_f],1
					.endif
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2020,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rsi],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rsi_f],1
					.endif
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2019,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rdi],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rdi_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2018,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rbp],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rbp_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2017,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._rsp],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._rsp_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2016,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r8],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r8_f],1
					.endif
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2015,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r9],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r9_f],1
					.endif
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2014,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r10],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r10_f],1
					.endif
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2013,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r11],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r11_f],1
					.endif
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2024,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r12],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r12_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2023,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r13],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r13_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2022,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r14],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r14_f],1
					.endif
					
					
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2021,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._r15],8,addr mingma_buffer,rax
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._r15_f],1
					.endif
					invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
					invoke GetDlgItemText,hWin,2026,addr mingma_buffer,sizeof mingma_buffer
					invoke ASCII2HEX,addr [rdi+_sfGUEST_REGS._flags],8,addr mingma_buffer,rax
					
					.if rax {}0
						mov [rdi+_sfGUEST_REGS._flags_f],1
					.endif
					
					
					
					
					add rdi,sizeof _sfGUEST_REGS
					
					mov rsi,@pprogram_address_buffer
					mov rcx,rdi
					sub rcx,rsi
					sub rcx,8		;再减8字节防溢出
					mov rsi,@pprogram_address_buffer
					mov rax,0
					
					.while rcx {} 0
						CRC32 rax,qword ptr [rsi]
						inc rsi
						dec rcx
					.endw
					mov [rdi],rax
					
					add rdi,8
					mov rcx,rdi
					mov rsi,@pprogram_address_buffer
					sub rcx,rsi
					mov @all_count,rcx
					
					invoke GetProcessHeap
					invoke HeapAlloc,rax,HEAP_ZERO_MEMORY,1000h
					
					.if rax {} 0
						mov @pprogram_address_buffer_back,rax
					.endif
					
					mov rsi,@pprogram_address_buffer
					mov rdx , 0
					mov rax,@all_count
					mov rcx,78h
					div rcx
					mov r14,rax
					mov r13,rdx
					mov rbx,0
					mov r15,0
					.while r14 {} 0
						
						invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
						invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
						mov rsi,@pprogram_address_buffer
						lea rsi,[rsi+rbx]
						mov rcx,78h
						lea rdi,mingma_buffer
						rep movsb
						invoke rsadec,addr return_rsa,addr mingma_buffer	;将78H个字符计算成80H字符
						mov	rcx,10h 
						lea rsi,return_rsa
						mov rdi,@pprogram_address_buffer_back		;将80H字符存入这里
						lea rdi,[rdi+r15]
						cld
						rep movsq
						
						add rbx,78h
						add r15,80h
						dec r14
					.endw
					
					.if r13 {} 0 ;如果还有剩余就继续计算
						invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
						invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
						mov rsi,@pprogram_address_buffer
						lea rsi,[rsi+rbx]
						mov rcx,r13
						lea rdi,mingma_buffer
						cld
						rep movsb
						
						invoke rsadec,addr return_rsa,addr mingma_buffer
						mov	rcx,10h
						lea rsi,return_rsa
						mov rdi,@pprogram_address_buffer_back
						lea rdi,[rdi+r15]
						cld
						rep movsq
						add rbx,78h
						add r15,80h
					
					.endif
					and @dwBytesReturned,0
					and r15,not 7fh			;取整
					mov rax,@pprogram_address_buffer_back
					
					invoke DeviceIoControl, hDevice, IOCTL_vmm_fix_program_,@pprogram_address_buffer_back,r15,  NULL, NULL,addr @dwBytesReturned, NULL
					
					mov rax,@dwBytesReturned
					.if eax == 12345678h
						
						invoke GetProcessHeap
						invoke HeapFree,rax,0,@pprogram_address_buffer
						invoke GetProcessHeap
						invoke HeapFree,rax,0,@pprogram_address_buffer_back
						invoke	EndDialog,hwnd_vm_hook,NULL
					.else
						invoke GetProcessHeap
						invoke HeapFree,rax,0,@pprogram_address_buffer
						invoke GetProcessHeap
						invoke HeapFree,rax,0,@pprogram_address_buffer_back
						invoke 	MessageBox,hWin,addr error_device_io,addr error_device_io,MB_OK
						
					.endif
				.endif	
					
		.else	
			mov	eax,FALSE
			ret
		.endif		   
		mov	eax,TRUE
		ret	
	
	
	
	ret

_ProcDlg_vm_hook endp


WndProc proc hWin:HWND,uMsg:UINT64,wParam:WPARAM,lParam:LPARAM 
	
	LOCAL @dwBytesReturned:qword
	LOCAL @DROPFILEBUFFER [MAX_PATH]:BYTE
	
	
	LOCAL @pprogram_address_buffer:qword
	LOCAL @status_ioctl:current_satae
	
	LOCAL @info:SYSTEM_CODEINTEGRITY_INFORMATION
	LOCAL @debug:SYSTEM_KERNEL_DEBUGGER_INFORMATION
	LOCAL @NtQuerySystemInformation:qword
	mov		rax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
	.elseif rax == WM_DROPFILES
	  
		invoke 	DragQueryFileA,wParam,0,addr @DROPFILEBUFFER,MAX_PATH
		invoke SetDlgItemTextA,hWnd,1001,addr @DROPFILEBUFFER
				
	.elseif eax==WM_COMMAND
		mov		rax,wParam
		and		rax,0FFFFh
		.if rax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif rax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
			
		.elseif rax == 1005
			invoke SendMessageA,hWnd,WM_CLOSE,0	
		
		
		.elseif rax == 1003;装载驱动
			
		   .if rax==rax	
			invoke OpenSCManagerA, NULL, NULL, SC_MANAGER_ALL_ACCESS
	
			.if rax {} NULL
				mov hSCManager, rax
			.else
				invoke MessageBoxA, hWnd,addr err_scm, NULL, MB_OK + MB_ICONSTOP
				ret
			.endif
															;SERVICE_START | SERVICE_STOP | DELETE
			invoke OpenServiceA,hSCManager,addr service_vmm,SERVICE_START + SERVICE_STOP + DELETE;If the function succeeds, the return value is a handle to the service.If the function fails, the return value is NULL.
			.if rax {} 0
				mov hService, rax
				
			.else	
				
				invoke GetLastError
				.if rax == ERROR_SERVICE_DOES_NOT_EXIST	
					invoke MessageBox,hWnd,addr ERROR_SERVICE_DOES_NOT_EXIST_text,0,MB_OK
					
				.elseif eax == ERROR_ACCESS_DENIED		
					invoke MessageBox,hWnd,addr ERROR_ACCESS_DENIED_text,0,MB_OK
					ret
				
				
				.elseif eax == ERROR_INVALID_HANDLE		
					invoke MessageBox,hWnd,addr ERROR_INVALID_HANDLE_text,0,MB_OK	
					ret
				
				.elseif eax == ERROR_INVALID_NAME	
			
					invoke MessageBox,hWnd,addr ERROR_INVALID_NAME_text,0,MB_OK
					ret
				.endif	
			
				@@:
				invoke GetDlgItemText,hWnd,1001,addr patch_addr,sizeof patch_addr
				invoke CreateServiceA, hSCManager, addr service_vmm,addr service_vmm, SC_MANAGER_ALL_ACCESS,\
				SERVICE_KERNEL_DRIVER, SERVICE_DEMAND_START , \
				SERVICE_ERROR_IGNORE, addr patch_addr, NULL, NULL, NULL, NULL, NULL	
					
				.if rax {} NULL
				
					mov hService, rax
				.else
					invoke GetLastError
					.if rax == ERROR_ACCESS_DENIED		;	The handle to the SCM database does not have the SC_MANAGER_CREATE_SERVICE access right.
						lea r8, ERROR_ACCESS_DENIED_text
						
					.elseif rax== ERROR_CIRCULAR_DEPENDENCY  	;	A circular service dependency was specified.
						lea r8, ERROR_CIRCULAR_DEPENDENCY_text
					.elseif rax == ERROR_DUPLICATE_SERVICE_NAME	;The display name already exists in the service control manager database either as a service name or as another display name.	
						lea r8, ERROR_DUPLICATE_SERVICE_NAME_text
					.elseif rax == ERROR_INVALID_HANDLE
						lea r8, ERROR_INVALID_HANDLE_text
					.elseif rax == ERROR_INVALID_NAME
						lea r8, ERROR_INVALID_NAME_text
					.elseif rax == ERROR_INVALID_PARAMETER	
						lea r8, ERROR_INVALID_PARAMETER_text
					.elseif rax == ERROR_INVALID_SERVICE_ACCOUNT	
						lea r8, ERROR_INVALID_SERVICE_ACCOUNT_text
					.elseif rax == ERROR_SERVICE_EXISTS
						lea r8, ERROR_SERVICE_EXISTS_text
					.elseif rax == ERROR_SERVICE_MARKED_FOR_DELETE
						lea r8, ERROR_SERVICE_MARKED_FOR_DELETE_text
					.endif
					
					
					
					
					invoke MessageBoxA, hWnd,addr err_CreateService, r8, MB_OK + MB_ICONSTOP
					ret
				.endif	
				
			.endif	
			invoke StartServiceA, hService, 0, NULL	;if the function succeeds, the return value is nonzero
			
			.if eax {}0 
					
					invoke SendMessageA,hWnd,WM_SETTEXT,0,addr ok_driver_start
			.else
				invoke GetLastError
					
				.if eax == ERROR_SERVICE_ALREADY_RUNNING
					invoke SendMessageA,hWnd,WM_SETTEXT,0,addr ok_driver_start	
				
				.else
				
					invoke MessageBox,NULL, addr err_driver_start, NULL, MB_RETRYCANCEL
					.if eax == IDRETRY;IDRYAGAIN
					jmp @b
					
					.else
						ret	
					.endif
					
				.endif
					
			.endif		
				
			invoke CreateFile, addr SymbolicLinkName, GENERIC_READ + GENERIC_WRITE, \
					FILE_SHARE_READ + FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL

			.if rax {} INVALID_HANDLE_VALUE
				mov hDevice, rax
				invoke SendMessageA,hWnd,WM_SETTEXT,0,addr ok_SymbolicLinkName	
					
				invoke CreateEventA,0,0,0,0
				mov hevent,rax
				
				invoke DeviceIoControl, hDevice, IOCTL_vmm_event, addr hevent, sizeof hevent,NULL, NULL,  \
								addr @dwBytesReturned, NULL
					
			.else
				
				
				invoke MessageBoxA,0,addr err_SymbolicLinkName,0,MB_OK	
			.endif
			
			invoke GetDlgItem,hWnd,1003
			invoke EnableWindow,rax,FALSE
				
			invoke GetDlgItem,hWnd,1004
			invoke EnableWindow,rax,TRUE
				
			invoke GetDlgItem,hWnd,1006
			invoke EnableWindow,rax,TRUE
			invoke GetDlgItem,hWnd,1007
			invoke EnableWindow,rax,FALSE
		   .endif	
		.elseif rax == 1004;卸载驱动
			
		   .if rax==rax	
			invoke CloseHandle,hDevice
			
			invoke ControlService,hService,SERVICE_CONTROL_STOP,addr status
			.if rax {} 0
				invoke SendMessage,hWnd,WM_SETTEXT,0,addr ok_stop_server
				;invoke MessageBoxA, hWnd, addr ok_stop_server, NULL, MB_OK \
				
				invoke GetDlgItem,hWnd,1003
				invoke EnableWindow,rax,TRUE
			
					
			
				
				invoke GetDlgItem,hWnd,1004
				invoke EnableWindow,rax,FALSE
					
				invoke GetDlgItem,hWnd,1006
				invoke EnableWindow,rax,FALSE
				
				invoke GetDlgItem,hWnd,1007
				invoke EnableWindow,rax,FALSE
					
			.endif
			invoke DeleteService,hService
			invoke CloseServiceHandle, hService
			invoke CloseServiceHandle, hSCManager
			
			
			invoke GetDlgItem,hWnd,1003
			invoke EnableWindow,rax,TRUE
				
			invoke GetDlgItem,hWnd,1004
			invoke EnableWindow,rax,FALSE
				
			invoke GetDlgItem,hWnd,1006
			invoke EnableWindow,rax,FALSE
			invoke GetDlgItem,hWnd,1007
			invoke EnableWindow,rax,FALSE
			
		   .endif	
			
		
		.elseif rax == 1006;加载虚拟机
		   .if	rax==rax	
			and @dwBytesReturned,0
			invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
			invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
			invoke lstrcat,addr mingma_buffer,addr start
			
			invoke rsadec,addr return_rsa,addr mingma_buffer
			invoke DeviceIoControl, hDevice, IOCTL_vmm_start,addr return_rsa,80h,  NULL, NULL, \
								addr @dwBytesReturned, NULL
			mov rax,@dwBytesReturned
			.if eax == 12345678h
				
				and @dwBytesReturned,0
				invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
				invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
				invoke lstrcat,addr mingma_buffer,addr fake
				invoke rsadec,addr return_rsa,addr mingma_buffer
			;	invoke DeviceIoControl, hDevice, IOCTL_vmm_fake_program,addr return_rsa,80h,  NULL, NULL, \
			;					addr @dwBytesReturned, NULL
			;	mov rax,@dwBytesReturned
			;	.if eax {} 12345678h
			;		ret
			;	.endif
				
				invoke SendMessageA,hWnd,WM_SETTEXT,0,addr ok_vt_start
				
				invoke GetDlgItem,hWnd,1007
				invoke EnableWindow,rax,TRUE
			
					
			
				invoke GetDlgItem,hWnd,1003
				invoke EnableWindow,rax,FALSE
					
				invoke GetDlgItem,hWnd,1004
				invoke EnableWindow,rax,FALSE
					
				invoke GetDlgItem,hWnd,1006
				invoke EnableWindow,rax,FALSE
				
				
				
			.endif
		   .endif	
			
		.elseif rax == 1007;退出虚拟机
			
		   .if	rax==rax	
			and @dwBytesReturned,0
			invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
			invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
			invoke lstrcat,addr mingma_buffer,addr exit_vm
			invoke rsadec,addr return_rsa,addr mingma_buffer
			invoke DeviceIoControl, hDevice, IOCTL_vmm_exit,addr return_rsa,80h,  NULL, NULL, \
								addr @dwBytesReturned, NULL
			mov rax,@dwBytesReturned
			.if eax == 12345678h
				invoke SendMessageA,hWnd,WM_SETTEXT,0,addr ok_vt_end
				
				invoke GetDlgItem,hWnd,1003
				invoke EnableWindow,rax,FALSE
				
				invoke GetDlgItem,hWnd,1004
				invoke EnableWindow,rax,TRUE
				
				invoke GetDlgItem,hWnd,1006
				invoke EnableWindow,rax,FALSE
				invoke GetDlgItem,hWnd,1007
				invoke EnableWindow,rax,FALSE
					
				
					
			
			.endif		
			
		   .endif
		.elseif rax ==1008;test SystemCodeIntegrity
		   .if	rax==rax	
		   
			
			invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
			invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
			invoke lstrcat,addr mingma_buffer,addr test_only
			invoke rsadec,addr return_rsa,addr mingma_buffer
			invoke DeviceIoControl, hDevice, IOCTL_vmm_SystemCodeIntegrity,addr return_rsa,80h,  addr temp_buffer, sizeof temp_buffer, \
								addr @dwBytesReturned, NULL
			mov rax,@dwBytesReturned
			.if eax == 12345678h
			;	invoke HEX2ASCII,
				lea rax, temp_buffer
				mov eax,[rax]
				
				
				invoke wsprintf,addr temp_buffer,addr hex_to_ascii_format,rax
				invoke SendMessageA,hWnd,WM_SETTEXT,0,addr temp_buffer
				
			.endif		
			
			
			
		   .endif	
				
		.elseif rax == 1010 ;vm_hook	
				
			invoke	DialogBoxParam,hInstance,IDD_DIALOG2000,hWnd,addr _ProcDlg_vm_hook,0
		 	invoke	EndDialog,hwnd_vm_hook,NULL	
				
		.elseif rax == 1012;要保护的程序 标记外部行为		
			
			.if eax == eax
				
				and @dwBytesReturned,0
				
				invoke RtlZeroMemory,addr mingma_buffer,sizeof mingma_buffer
				invoke lstrcat,addr mingma_buffer,addr record_attack_method
				
				invoke GetDlgItemTextW,hWnd,1013,addr return_rsa,sizeof return_rsa
				shl rax,1
				mov rcx,rax
				.if rcx } 80h-sizeof record_attack_method-1
					ret
				.endif
				lea rsi,return_rsa
				lea rdi,mingma_buffer
				lea rdi,[rdi+sizeof record_attack_method-1]
				cld
				rep movsb
				
				invoke RtlZeroMemory,addr return_rsa,sizeof return_rsa
				invoke rsadec,addr return_rsa,addr mingma_buffer
				invoke DeviceIoControl, hDevice, IOCTL_vmm_record_attack_method,addr return_rsa,80h,  NULL, NULL, \
								addr @dwBytesReturned, NULL
				mov rax,@dwBytesReturned
				.if eax {} 12345678h
					ret
				.endif
				
				invoke SendMessageA,hWnd,WM_SETTEXT,0,addr ok_vmm_record_attack_method
				
			.endif			
			
			
		.elseif rax == 1014;测试模式检测		
			and @dwBytesReturned,0
			
			invoke LoadLibrary,addr ntdll_text
			mov rbx,rax
			invoke GetProcAddress,rbx,addr NtQuerySystemInformation_text
			mov @NtQuerySystemInformation,rax
			SystemCodeIntegrityInformation equ 103
			mov @info._Length,sizeof @info
			mov @info.CodeIntegrityOptions,0
			invoke @NtQuerySystemInformation,SystemCodeIntegrityInformation,addr @info,8,0
			
			mov eax,@info.CodeIntegrityOptions			;0x01 CODEINTEGRITY_OPTION_ENABLED 内核模式代码完整性已启用
														;0x02 CODEINTEGRITY_OPTION_TESTSIGN Test Mode / BCD testsigning
														;0x04 CODEINTEGRITY_OPTION_UMCI_ENABLED 用户模式 CI 已启用
														;0x08 CODEINTEGRITY_OPTION_UMCI_AUDITMODE_ENABLED UMCI 审计模式
														;0x10 CODEINTEGRITY_OPTION_UMCI_EXCLUSIONPATHS_ENABLED UMCI 排除路径
														;0x20 CODEINTEGRITY_OPTION_TEST_BUILD CI 来自测试构建
														;0x40 CODEINTEGRITY_OPTION_PREPRODUCTION_BUILD CI 来自预生产构建
														;0x80 CODEINTEGRITY_OPTION_DEBUGMODE_ENABLED 内核调试器已附加，可能允许未签名代码
														;0x100 CODEINTEGRITY_OPTION_FLIGHT_BUILD CI 来自 flight 构建
														;0x200 CODEINTEGRITY_OPTION_FLIGHTING_ENABLED 允许 flight 签名内容
														;0x400 CODEINTEGRITY_OPTION_HVCI_KMCI_ENABLED HVCI / 内存完整性 已启用
														;0x800 CODEINTEGRITY_OPTION_HVCI_KMCI_AUDITMODE_ENABLED HVCI 审计模式
														;0x1000 CODEINTEGRITY_OPTION_HVCI_KMCI_STRICTMODE_ENABLED HVCI 严格模式
														;0x2000 CODEINTEGRITY_OPTION_HVCI_IUM_ENABLED
														;
														;
														;200282	== 
			invoke wsprintf,addr temp_buffer,addr hex_to_ascii_format,rax
			invoke SendMessageA,hWnd,WM_SETTEXT,0,addr temp_buffer
		
		.elseif rax == 1015;调试模式检测
			and @dwBytesReturned,0
			
			invoke LoadLibrary,addr ntdll_text
			mov rbx,rax
			invoke GetProcAddress,rbx,addr NtQuerySystemInformation_text
			mov @NtQuerySystemInformation,rax
			SystemKernelDebuggerInformation equ 23h
			mov @info._Length,sizeof @info
			mov @info.CodeIntegrityOptions,0
			invoke @NtQuerySystemInformation,SystemKernelDebuggerInformation,addr @debug,8,0
			
			lea rax,@debug
			.if [rax+SYSTEM_KERNEL_DEBUGGER_INFORMATION.KernelDebuggerEnabled] == 1
				invoke MessageBox,hWnd,addr debug_find,addr debug_find,MB_OK
			.endif
			
			.if @debug.KernelDebuggerNotPresent == 0
				invoke MessageBox,hWnd,addr debug_find_1,addr debug_find_1,MB_OK
			.endif
			
		.endif
;	.elseif eax==WM_SIZE
	.elseif eax==WM_CLOSE
		
		.if hDevice {} 0
			;如果没有点击加载驱动的话，是没有创建设备的。
			and @dwBytesReturned,0
			invoke DeviceIoControl, hDevice, IOCTL_current_state, NULL, NULL, addr @status_ioctl,sizeof @status_ioctl,addr @dwBytesReturned, NULL
			.if @dwBytesReturned == sizeof @status_ioctl
				lea rsi,@status_ioctl
				.if [rsi+current_satae.current_drive_on] {} 0
				
					invoke GetDlgItem,hWnd,1003
					invoke EnableWindow,rax,FALSE
				
				.else
					invoke GetDlgItem,hWnd,1003
					invoke EnableWindow,rax,TRUE
				
				.endif
			
				.if [rsi+current_satae.current_VmxOnOFF] {} 0
					invoke MessageBox,hWin,addr exit_message,addr exit_message,MB_OK
			
					invoke GetDlgItem,hWnd,1003
					invoke EnableWindow,rax,FALSE
			
					invoke GetDlgItem,hWnd,1004
					invoke EnableWindow,rax,FALSE
			
					invoke GetDlgItem,hWnd,1006
					invoke EnableWindow,rax,FALSE	
				
					invoke GetDlgItem,hWnd,1007
					invoke EnableWindow,rax,TRUE	
			
					ret
				.endif
				
				invoke MessageBox,hWin,addr unload_driver_message,addr unload_driver_message,MB_OK
				ret
				
			.endif
			
			
		.endif	
		invoke DestroyWindow,hWin
		
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    rax,rax
	ret

WndProc endp
end


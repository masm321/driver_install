option casemap:none
OPTION DOTNAME

include rsa64.inc

.code

ASCII2HEX proc uses rbx rsi rdi pret_buffer:qword,size_ret_buffer:qword,pascii_buffer:qword,size_ascii_buffer:qword
	
	
		
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
			.elseif bl == 0
				
						
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

HEX2ASCII proc uses rbx rsi rdi pret_buffer:qword,size_ret_buffer:qword,phex_buffer:qword,size_hex_buffer:qword	;16进制转ascii
	
	
	mov rsi,phex_buffer
	
	mov rdi,pret_buffer
	mov rbx,0
	mov rdx,0
	mov rax,0
	
	mov rcx,size_hex_buffer
	
	.if rcx { rsa_n_length
		mov rax,-1
		ret
	.endif
	
	
	mov rcx,size_ret_buffer
	.if rcx { rsa_n_length
		mov rax,-1
		ret
	.endif
	
	mov rcx,size_hex_buffer
	mov rdx,size_ret_buffer
	.while sqword ptr rcx } 0 && sqword ptr rdx } 0
		
		
		
		mov al,[rsi]
		
		shr al,4
		.if al }=0 && al {= 9
			add al,30h
		.elseif al }=0ah && al {= 0fh
			add al,37h
		.else
			mov rax,-1
		;	int 3
		;	ret	
		.endif
		cld
		stosb
		
		
		mov al,[rsi]
		and al,0fh
		.if al }=0 && al {= 9
			add al,30h
		.elseif al }=0ah && al {= 0fh
			add al,37h
		.else
			mov rax,-1
		;	int 3
		;	ret	
		.endif
		
		cld
		stosb
		
		
		inc rsi
		
		dec rcx
		dec rdx
		dec rdx
	.endw
	
	;mov dword ptr [rdi],0
	
	
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
			
	
end
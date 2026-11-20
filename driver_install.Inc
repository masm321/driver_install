include win64.inc
include ksamd64.inc
include Macros\x64macros.inc
include Macros\x64calling.inc
include Macros\vasily.inc

include user32.inc
include kernel32.inc
include advapi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include	common.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib AdvAPI32.Lib

WinMain				PROTO :QWORD,:QWORD,:QWORD,:QWORD
WndProc				PROTO :QWORD,:QWORD,:QWORD,:QWORD

IDD_DIALOG			equ 1000
IDD_DIALOG2000		equ 2000
IDD_DIALOG3000		equ 3000
IDM_MENU			equ 10000
IDM_FILE_EXIT		equ 10001
IDM_HELP_ABOUT		equ 10101

_TSS_SEGMENT_DESCRIPTOR 	record  TSS_offset32_24:8, TSS_attr_G:1,TSS_attr_D_B:1,TSS_attr_L:1, TSS_attr_AVL:1,LMT:4,TSS_attr_P:1,\
					TSS_attr_DPL:2,TSS_attr_S:1,TSS_attr_Type_code_or_data:1,TSS_attr_Type_CRA:3,TSS_offset24_1:24,TSS_Limit_16_1:16
_eflags 	record  flags_reserved_32_23:10,flags_ID:1,flags_VIP:1,flags_VIF:1,flags_AC:1,flags_VM:1,flags_RF:1,flags_reserved1_ZERO:1,flags_NT:1,\

					flags_IOPL:2,flags_OF:1,flags_DF:1,flags_IF:1,flags_TF:1,flags_SF:1,flags_ZF:1,flags_reserved2_ZERO:1,\
					
					flags_AF:1,flags_reserved3_ZERO:1,flags_PF:1,flags_reserved4_1:1,flags_CF:1

_sfGUEST_REGS struct	;
	
	_r15 	dq ?;                 
	_r14 	dq ?;
	_r13 	dq ?;                 
	_r12 	dq ?;
	
	_r11 	dq ?;
	_r10 	dq ?;
	_r9 	dq ?;
	_r8 	dq ?;                  
	
	
	_rdi 	dq ?;
	_rsi 	dq ?;    
	_rsp 	dq ?
	_rbp	dq ?
	 
	_rbx 	dq ?;                 
	_rdx 	dq ?;
	_rcx 	dq ?;                
	_rax	dq ?;
	
	_flags	dq ?
	_flags_f dq ?
	_r15_f 	dq ?;                 
	_r14_f 	dq ?;
	_r13_f 	dq ?;                 
	_r12_f 	dq ?;
	
	_r11_f 	dq ?;
	_r10_f 	dq ?;
	_r9_f 	dq ?;
	_r8_f 	dq ?;                  
	
	
	_rdi_f 	dq ?;
	_rsi_f 	dq ?;    
	_rsp_f 	dq ?
	_rbp_f	dq ?
	 
	_rbx_f 	dq ?;                 
	_rdx_f 	dq ?;
	_rcx_f 	dq ?;                
	_rax_f	dq ?;
	
	
_sfGUEST_REGS ends


current_satae struct
	current_drive_on		dq ? ;;驱动已启动==1
	current_vm_count		dq ?	;系统虚拟机计数
	current_VmxOnOFF		dq ?	;虚拟机已启动 == 1
current_satae ends	

program_address struct 
			;客户端发送过来数据结构 
			hook_address		dq ?						;原始数据地址 必须是8字节长度 和 u 结构数据一样，只是为了快速查找
			type_count			dq ?						;类目计数 一般为4 		4个结构
			union
				struct v
					api_name_count		dq ?	
					api_name			db 1h dup (?)		;要修改模块名（带扩展名）;这里应该是动态长度
				ends
				struct u
					org_address_length			dq ?;;要HOOK的地址;	64位系统8字节
					org_address					db 1h dup (?)				
				ends
				
				struct w
					org_address_data_length			dq ?							;只用32位
					org_address_data		db  1h dup (?)				;HOOK地址处的数据，为将来读写操作时，恢复到原始数据，目前没有使用
				ends
				
				struct x
					fix_length			dq ?
					fix_data			db  1h dup (?)				;修改后的数据	;这里应该是动态长度
				ends
				
			ends
			user_GUEST_REGS     	_sfGUEST_REGS <>
			crc_32				dq ?						;以上项的CRC32	所有数据用1024rsa 加密
program_address		ends

SYSTEM_CODEINTEGRITY_INFORMATION struct
	_Length dd ?
	CodeIntegrityOptions dd ?
SYSTEM_CODEINTEGRITY_INFORMATION ends

SYSTEM_KERNEL_DEBUGGER_INFORMATION struct
    KernelDebuggerEnabled		dd ?;  对应BCD debug on/off // 对应KdDebuggerEnabled    1== debug
    KernelDebuggerNotPresent	dd ?;		// 是否无调试器附着						0 == debug 	true = 没有windbg附着
SYSTEM_KERNEL_DEBUGGER_INFORMATION ends
rsa_n_length equ 80h ;128字节
rsa_n_length_8 equ 88h
.const
debug_find	db "debug_find",0
debug_find_1	db "debug_find_1",0
ntdll_text							db "ntdll.dll",0
NtQuerySystemInformation_text	db "NtQuerySystemInformation",0
ClassName			db 'DLGCLASS',0
AppName				db 'Dialog as main',0
AboutMsg			db 'MASM64 RadASM Dialog as main',13,10,'Copyright ? masm64 2001',0
err_scm				db "Can't open scmange",0
format_RIP			db "RIP:%X",;064 位平台上的 64 位无符号十六进制整数（小写或大写），在 32 位平台上，32 位无符号十六进制整数（小写或大写）。

AAAAAAA dt 12H,34H,56H,78H,0
align 8
service_vmm			db "test_vmm",0
err_CreateService		db "CreateService错误",0
err_driver_start		db "驱动启动失败",0
ok_driver_start			db "驱动启动成功",0
SymbolicLinkName 		db "\\.\test_vmm",0
err_SymbolicLinkName		db "打开设备失败",0
ok_SymbolicLinkName		db "打开设备成功",0
ok_stop_server			db "驱动已卸载",0
ok_vt_start			db "成功加载虚拟机",0	
ok_vt_end			db "成功卸载虚拟机",0		
ok_vt_test			db "驱动接收到测试按钮信息",0	
ok_vmm_record_attack_method	db "标记外部程序功能已发送!",0
error_KiSystemCall	db "error_KiSystemCall",0
error_register		db "error_register",0
exit_message		db "请点击 退出虚拟机",0
unload_driver_message	db "卸载驱动时发生错误请重试",0
start				db "start...",0
fake				db "fake....",0
exit_vm				db "exit_vm.",0
exit_driver			db "exitdriv",0

test_only			db "test....",0
record_attack_method db "record_attack_method",0
org_data_address	db "原始数据地址长度错误，必须为16字节。",0
org_data			db "原始数据内容长度错误，必须为8字节。",0
fix_data			db "修改数据内容长度错误，必须为8字节。",0
RROR_SERVICE_DOES_NOT_EXIST	db "RROR_SERVICE_DOES_NOT_EXIST",0
_ACCESS_DENIED			db "ERROR_ACCESS_DENIED",0
_INVALID_HANDLE		db "ERROR_INVALID_HANDLE",0
_INVALID_NAME			db "ERROR_INVALID_NAME",0

server_error		db "虚拟机初始化错误",0
error_device_io		db "虚拟机没有响应",0

error_hook			db "虚拟机hook错误",0

 ERROR_SERVICE_DOES_NOT_EXIST_text	 db "ERROR_SERVICE_DOES_NOT_EXIST_text",0
 ERROR_ACCESS_DENIED_text			db "ERROR_ACCESS_DENIED_text",0
 ERROR_INVALID_HANDLE_text			db "ERROR_INVALID_HANDLE_text",0
 ERROR_INVALID_NAME_text			db "ERROR_INVALID_NAME_text",0
 
 
 ;ERROR_ACCESS_DENIED_text			db "ERROR_ACCESS_DENIED_text",0
 ERROR_CIRCULAR_DEPENDENCY_text		db "ERROR_CIRCULAR_DEPENDENCY_text",0
 ERROR_DUPLICATE_SERVICE_NAME_text	db "ERROR_DUPLICATE_SERVICE_NAME_text",0
 ;ERROR_INVALID_HANDLE_text			db "ERROR_INVALID_HANDLE_text",0
 ;ERROR_INVALID_NAME_text			db "ERROR_INVALID_NAME_text",0
 ERROR_INVALID_PARAMETER_text		db "ERROR_INVALID_PARAMETER_text",0
 ERROR_INVALID_SERVICE_ACCOUNT_text db "ERROR_INVALID_SERVICE_ACCOUNT_text",0
 ERROR_SERVICE_EXISTS_text			db "ERROR_SERVICE_EXISTS_text",0
 ERROR_SERVICE_MARKED_FOR_DELETE_text db "ERROR_SERVICE_MARKED_FOR_DELETE_text",0
 
 



;;;;16进制ascii码 高位在前低位在后

rsa_n_ascii	db "5F0CE351CC62F959C093364CACCFA63C390EA0C299B37A6A42FC4D13208D8285A58CFE9CCDD278"
			db "C7BBF75DF430A83B40BB2962C3549062F320F755EB4D849CCEFDEE82E1E9BE8151FC3C663DD414D"
			db "54B9CCDD5614E14F10591535A76CB6A2629B8EB41B7417B776E8886EFCE2373DCD9859029F7F7928"
			db "3168E2D4B30902E7E11",0
		
		
align 8	



rsa_e_ascii	db "59B279DAB97C353F63A208BDF6DEC64B52B4E134838381E4416E82F5A7E4A2E5A843140BB998036EC98D38D6B60C2C4E7BD124689CA6DD19FF64296A"
			db "B26E90E306CE887300CEA9A37066D74DD370892236BE71FAEFF6AD5331184ED91379C833134DAB2061E589D6DB0B0D39B2F8E1DA07B59528AEBAC262"
			db "C14B1B3558C44179",0

align 8		
rsa_d_ascii	db "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
			db "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
			db "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001",0
			
	dq	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
error_tips1	db "11长度不在范围内",0	
error_tips2	db "22长度不在范围内",0	
error_tips3	db "33长度不在范围内",0	
error_tips4	db "44长度不在范围内",0	
;exit_message		db "Please click exit-vm",0,0,0



;;launcher
_Assistant_exe  			dq offset Assistant_exe
_base_dll					dq offset base_dll
_bugreport_exe				dq offset bugreport_exe
_cjson_dll					dq offset cjson_dll
_Client_exe					dq offset Client_exe
_crash_report_helper_dll 	dq offset crash_report_helper_dll
_dbghelp_dll				dq offset dbghelp_dll
_Lua51_dll					dq offset Lua51_dll
_rail_independent_dll		dq offset rail_independent_dll
_rail_sdk_platform_dll		dq offset rail_sdk_platform_dll
_railtr_dll					dq offset railtr_dll
_sail_api_impl_dll			dq offset sail_api_impl_dll
_sail_api_impl64_dll		dq offset sail_api_impl64_dll
_sail_api_platform_dll		dq offset sail_api_platform_dll
_service_core_dll			dq offset service_core_dll
_startup_runner_exe			dq offset startup_runner_exe
_TasLoginGuard_dll			dq offset TasLoginGuard_dll
_TinyDL_exe					dq offset TinyDL_exe
_TinyDLProxy_dll			dq offset TinyDLProxy_dll
_tinyget_dll				dq offset tinyget_dll
_ucrtbase_dll				dq offset ucrtbase_dll
_WGLogin_dll				dq offset WGLogin_dll
_wxlogin_dll				dq offset wxlogin_dll


;;\WeGameLauncher
_WeGameLauncher_bugreport_exe			dq offset WeGameLauncher_bugreport_exe
_WeGameLauncher_crash_report_helper_dll	dq offset WeGameLauncher_crash_report_helper_dll
_WeGameLauncher_dbghelp_dll				dq offset WeGameLauncher_dbghelp_dll
_launcher_exe							dq offset launcher_exe
_normaliz_dll							dq offset normaliz_dll
_platform_health_dll					dq offset platform_health_dll
_wegame_health_dll						dq offset wegame_health_dll


;;;\WeGameLauncher\Tenio
_June_dll								dq offset June_dll
_MemoryAlloctor_dll						dq offset MemoryAlloctor_dll
_TenFact_dll							dq offset TenFact_dll
_TenioTPF_dll							dq offset TenioTPF_dll
_xRender_dll							dq offset xRender_dll

;;;\LeagueClient
_ACE_GDPClient64_dll					dq offset ACE_GDPClient64_dll
;_ACE_Helper_dat					dq offset ACE_Helper_dat
_ACE_Helper_exe							dq offset ACE_Helper_exe
_ACE_Tips_Message64_dll					dq offset ACE_Tips_Message64_dll
_ACE_Tips_Render64_dll					DQ OFFSET ACE_Tips_Render64_dll
_DLLLoader64_6C83_exe					DQ offset DLLLoader64_6C83_exe
_GbSpy_dll								dq offset GbSpy_dll
_GCloudVoice_dll						dq offset GCloudVoice_dll
_LeagueClient_exe						dq offset LeagueClient_exe
_LeagueClientBase_dll					dq offset LeagueClientBase_dll
_LeagueClientUx_exe						dq offset LeagueClientUx_exe
_LeagueClientUxRender_exe				dq offset LeagueClientUxRender_exe
_LeagueCrashHandler64_exe				dq offset LeagueCrashHandler64_exe
_rail_api_dll							dq offset rail_api_dll
_rail_launcher_dll						dq offset rail_launcher_dll
_rail_tcls_dll							dq offset rail_tcls_dll
_SSOCommon_dll							dq offset SSOCommon_dll
_SSOPlatform_dll						dq offset SSOPlatform_dll
_WeGameLauncher_TasLoginGuard_dll		dq offset WeGameLauncher_TasLoginGuard_dll
_wegame_auth_dll						dq offset wegame_auth_dll
_WeGameLauncher_wxlogin_dll				dq offset WeGameLauncher_wxlogin_dll


protect_sizelength EQU $ -_Assistant_exe

;;launcher
Assistant_exe			db "Assistant.exe",0
base_dll				db "base.dll",0
bugreport_exe			db "bugreport.exe",0
cjson_dll				db "cjson.dll",0
Client_exe				db "Client.exe",0
crash_report_helper_dll	db "crash_report_helper.dll",0
dbghelp_dll				db "dbghelp.dll",0
Lua51_dll				db "Lua51.dll",0
rail_independent_dll	db "rail_independent.dll",0
rail_sdk_platform_dll	db "rail_sdk_platform.dll",0
railtr_dll				db "railtr.dll",0
sail_api_impl_dll		db "sail_api_impl.dll",0
sail_api_impl64_dll		db "sail_api_impl64.dll",0
sail_api_platform_dll	db "sail_api_platform.dll",0
service_core_dll		db "service_core.dll",0
startup_runner_exe		db "startup_runner.exe",0
TasLoginGuard_dll		db "TasLoginGuard.dll",0
TinyDL_exe				db "TinyDL.exe",0
TinyDLProxy_dll			db "TinyDLProxy.dll",0
tinyget_dll				db "tinyget.dll",0
ucrtbase_dll			db "ucrtbase.dll",0
WGLogin_dll				db "WGLogin.dll",0
wxlogin_dll				db "wxlogin.dll",0
;;;\Launcher\AntiCheatExpert\x86

;;;;\WeGameLauncher
WeGameLauncher_bugreport_exe			db "bugreport.exe",0
WeGameLauncher_crash_report_helper_dll 	db "crash_report_helper.dll",0
WeGameLauncher_dbghelp_dll				db "dbghelp.dll",0
launcher_exe			db "launcher.exe",0
normaliz_dll			db "normaliz.dll",0
platform_health_dll		db "platform_health.dll",0

wegame_health_dll		db "wegame_health.dll",0

;;;\WeGameLauncher\Tenio
June_dll				db "June.dll",0
MemoryAlloctor_dll		db "MemoryAlloctor.dll",0
TenFact_dll				db "TenFact.dll",0
TenioTPF_dll			db "TenioTPF.dll",0
xRender_dll				db "xRender.dll",0


;;;\LeagueClient
ACE_GDPClient64_dll 	db "ACE-GDPClient64.dll",0
ACE_Helper_dat			db "ACE-Helper.dat",0
ACE_Helper_exe			db "ACE-Helper.exe",0
ACE_Tips_Message64_dll 	db "ACE-Tips-Message64.dll",0
ACE_Tips_Render64_dll 	db "ACE-Tips-Render64.dll",0
DLLLoader64_6C83_exe	db "DLLLoader64_6C83.exe",0
GbSpy_dll				db "GbSpy.dll",0
GCloudVoice_dll			db "GCloudVoice.dll",0
LeagueClient_exe 		db "LeagueClient.exe",0
LeagueClientBase_dll 	db "LeagueClientBase.dll",0
LeagueClientUx_exe 		db "LeagueClientUx.exe",0
LeagueClientUxRender_exe db "LeagueClientUxRender.exe",0
LeagueCrashHandler64_exe db "LeagueCrashHandler64.exe",0
rail_api_dll			db "rail_api.dll",0
rail_launcher_dll		db "rail_launcher.dll",0
rail_tcls_dll			db "rail_tcls.dll",0
SSOCommon_dll			db "SSOCommon.dll",0
SSOPlatform_dll			db "SSOPlatform.dll",0
WeGameLauncher_TasLoginGuard_dll		db "TasLoginGuard.dll",0
wegame_auth_dll							db "wegame_auth.dll",0
WeGameLauncher_wxlogin_dll				db "wxlogin.dll",0




;;;;;;\WeGameLauncher\TenioDL
;;主要是下载使用的DLL



;;;;\Riot Client
Riot_Client_GCloudVoice_dll		db "GCloudVoice.dll",0
Riot_Client_normaliz_dll		db "normaliz.dll",0
pthreadVC2_dll					db "pthreadVC2.dll",0
rail_api_v1_dll					db "rail_api_v1.dll",0
rail_api_v2_dll					db "rail_api_v2.dll",0
Riot_Client_rail_tcls_dll		db "rail_tcls.dll",0
RCRpcs_dll						db "RCRpcs.dll",0
RiotClientCrashHandler_exe 		db "RiotClientCrashHandler.exe",0
RiotClientFoundation_dll 		db "RiotClientFoundation.dll",0
RiotClientServices_exe			db "RiotClientServices.exe",0
RiotGamesApi_dll				db "RiotGamesApi.dll",0
Riot_Client_SSOCommon_dll				db "SSOCommon.dll",0
Riot_Client_SSOPlatform_dll				db "SSOPlatform.dll",0
Riot_Client_TasLoginGuard_dll			db "TasLoginGuard.dll",0
tss_api_dll								db "tss_api.dll",0
vgrl_dll								db "vgrl.dll",0
Riot_Client_wegame_auth_dll				db "wegame_auth.dll",0
Riot_Client_wxlogin_dll					db "wxlogin.dll",0

;;;;;\TCLS

hex_to_ascii_format	db "标志位%x",0



.data?
;status_ioctl		current_satae <?>
hInstance			dq ?
CommandLine			dq ?
hWnd				dq ?
hwnd_vm_hook		dq ?
hSCManager			dq ?
hService			dq ?
hDevice				dq ?
hevent				dq ?
patch_addr			db 256 dup (?)
mingma_buffer db 88h dup (?)
	
return_rsa   db 88h dup (?)

temp_buffer	db 256 dup (?)


status		SERVICE_STATUS <>
ext_hand			dq ?

lpOrg_check_box_cf_Proc dq ?
lpOrg_check_box_pf_Proc dq ?
lpOrg_check_box_af_Proc	dq ?
lpOrg_check_box_zf_Proc dq ?
lpOrg_check_box_sf_Proc dq ?
lpOrg_check_box_tf_Proc dq ?
lpOrg_check_box_if_Proc dq ?
lpOrg_check_box_df_Proc dq ?
lpOrg_check_box_of_Proc dq ?

lpOrg_edit_Proc			dq ?



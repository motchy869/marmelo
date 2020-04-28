/*
	motchyGUI
	GUIモジュール
	author : motchy
*/
/* Win32API */
	#define global WS_VISIBLE	0x10000000
	#define global WS_CHILD		0x40000000

/* 定数群 */
	/* 数学定数 */
		#define global DCINT	0
	/* ウィンドウメッセージ */
		#define global WM_GETTEXT		0x00D
		#define global WM_GETTEXTLENGTH	0x00E
		#define global LVM_INSERTCOLUMN	0x101B
		#define global LVM_SETITEM		0x1006
		#define global LVM_INSERTITEM	0x1007
	
	/* コモンコントロール */
		#define global LVS_REPORT	1
		#define global LVCF_FMT		1
		#define global LVCF_WIDTH	2
		#define global LVCF_TEXT	4
		#define global LVCFMT_LEFT	0
		#define global LVIF_TEXT	1
	
/* ユニット */
	#include "motchyGUI_scrollArea.as"
	#include "motchyGUI_ListView.as"
	#include "motchyGUI_misc.as"

/* 定数後片付け */
	#undef WS_VISIBLE
	#undef WS_CHILD
	
	#undef DCINT
	
	#undef WM_GETTEXT
	#undef WM_GETTEXTLENGTH
	#undef LVM_INSERTCOLUMN
	#undef LVM_SETITEM
	#undef LVM_INSERTITEM
	
	#undef LVS_REPORT
	#undef LVCF_FMT
	#undef LVCF_WIDTH
	#undef LVCF_TEXT
	#undef LVCFMT_LEFT
	#undef LVIF_TEXT
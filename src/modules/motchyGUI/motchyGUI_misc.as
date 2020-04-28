/*
	雑多処理
*/
#module mgui_misc
	#defcfunc mgui_getEditText int hwnd_edit_	//エディットコントロールのテキストを取得
		//hwnd_edit_ : エディットコントロールのウィンドウハンドル
		sendmsg hwnd_edit_, WM_GETTEXTLENGTH, 0,0
		sdim buf, stat+1 : sendmsg hwnd_edit_, WM_GETTEXT, stat+1,varptr(buf)
		return buf
#global
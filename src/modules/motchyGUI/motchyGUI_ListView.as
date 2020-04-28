#module mgui_ListView
	#defcfunc mgui_createListView int sx_,int sy_
		/*
			カレントポジションにリストボックスを設置する
			
			sx_,sy_ : リストボックスのx,yサイズ
	
			[戻り値]
				作成されたリストビューのハンドル
		*/
		winobj "SysListView32", "ListView", 0, WS_VISIBLE|WS_CHILD|LVS_REPORT, sx_,sy_
		return objinfo(stat,2)
	
	#deffunc mgui_addLVCol int hwndLV_, int id_, int fmt_, int cx_, str szText_
		/*
			リストボックスにカラムを追加する
	
			hwndLV_	: リストビューのウィンドウハンドル
			id_		: カラムのID(左から0,1,2,…)
			fmt_	: LVCOLUMN構造体のfmtメンバ
			cx_		: カラムの幅[px]
			szText_	: カラムヘッダのテキスト
	
			[戻り値]
				(-1,other)=(失敗,作成されたカラムのID)
		*/
		szText=szText_ : lvcolumn = LVCF_FMT|LVCF_WIDTH|LVCF_TEXT, fmt_, cx_, varptr(szText)
		sendmsg hwndLV_, LVM_INSERTCOLUMN, id_, varptr(lvcolumn)
		return stat
	
	#deffunc mgui_addLVItem int hwndLV_, int id_, str szText_
		/*
			リストボックスにアイテムを追加する
	
			hwndLV_	: リストボックスのウィンドウハンドル
			id_		: アイテムのID(上から0,1,2,…)
			szText_	: アイテムの文字列
	
			[戻り値]
				(-1,other)=(失敗,追加されたアイテムのインデックス)
		*/
		szText=szText_ : lvitem = LVIF_TEXT, id_, 0, DCINT,DCINT, varptr(szText)
		sendmsg hwndLV_, LVM_INSERTITEM, 0, varptr(lvitem)
		return stat
	
	#deffunc mgui_setLVSubItem int hwndLV_, int idItem_, int idSubItem_, str szText_
		/*
			リストビューにサブアイテムを設定する
	
			hwndLV_	: リストビューのウィンドウハンドル
			idItem_	: アイテムのID
			idSubItem	: サブアイテムのID
	
			[戻り値]
				(TRUE,FALSE)=(成功,失敗)
		*/
		szText=szText_ : lvitem = LVIF_TEXT, idItem_, idSubItem_, DCINT,DCINT, varptr(szText)
		sendmsg hwndLV_, LVM_SETITEM, 0, varptr(lvitem)
		return stat
#global
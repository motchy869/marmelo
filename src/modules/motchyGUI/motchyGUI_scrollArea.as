#module mgui_residSA wid,h_wnd, x,y, wstyle_old	//スクロールエリアの住人(ウィンドウ)モジュール変数
	/*
		wid	: ウィンドウID
		h_wnd : ウィンドウハンドル
		x,y	: エリア内座標
		wstyle_old	: 住人になる前のウィンドウスタイル
	*/
	id=0
	#modinit
		mref id,2
		return id
	#modfunc local setMembers int wid_,int h_wnd_, int wstyle_old_
		wid=wid_ : h_wnd=h_wnd_ : wstyle_old=wstyle_old_
		return
	#modcfunc local getWid
		return wid
	#modcfunc local getHwnd
		return h_wnd
	#modcfunc local getWstyle_old
		return wstyle_old
#global

#module mgui_SA wid,h_wnd, x,y, sxLine,syLine, scx,scy, numResids,resids	//スクロールエリアモジュール変数
	#define NULL	0
	#define FALSE	0
	#define TRUE	1
	#define DONTCARE	0
	
	#define ctype HIWORD(%1)	(%1>>16)
	#define ctype LOWORD(%1)	(%1&0xFFFF)
	
	#define WM_HSCROLL	0x114
	#define WM_VSCROLL	0x115
	#define WM_PAINT 	0x15
	#define WM_NCPAINT	0x85
	
	#uselib "user32.dll"
		#cfunc GetWindowLong "GetWindowLongA" int,int
			#define GWL_STYLE	-16
			#define GWL_HWNDPARENT	-8
		#func SetWindowLong "SetWindowLongA" int,int,int
			#define WS_CHILD		0x40000000
			#define WS_POPUP		0x80000000
			#define WS_EX_APPWINDOW	0x40000
		#func SetWindowPos "SetWindowPos" int,int, int,int,int,int, int
			#define SWP_NOACTIVATE 0x10
			#define SWP_NOMOVE 2
			#define SWP_NOSIZE	1
			#define SWP_NOZORDER 4
		#func SetParent	"SetParent" int,int
		#func SetScrollInfo "SetScrollInfo" int,int,var,int
			#define SB_HORZ	0
			#define SB_VERT	1
		#func ScrollWindowEx "ScrollWindowEx" int,int,int,int,int,int,int,int
			#define SW_SCROLLCHILDREN 1
			#define SW_INVALIDATE 2
			#define SW_ERASE 4
			
		#func UpdateWindow "UpdateWindow" int
	
	#define SIF_ALL	23
	
	#define SB_LINEUP		0
	#define SB_LINEDOWN		1
	#define SB_PAGEUP		2
	#define SB_PAGEDOWN		3
	#define SB_THUMBTRACK	5
	/*
		wid	: エリアのウィンドウID
		h_wnd	: エリアのウィンドウハンドル
		x,y	: 親ウィンドウにおけるエリアの位置
		sxLine,syLine	: ラインサイズ(スクロール・バーの両端にある三角形のついたボタンを押したときの移動量[px])
		scx,scy	: スクロール量[px]
		numResids	: 擁するウィンドウの数
		resids	: mgui_residSA の配列
	*/
	id=0
	#modinit
		resids=0 : newmod resids,mgui_residSA : delmod resids(0) : numResids=0
		scx=0 : scy=0
		mref id,2
		return id
	#modfunc local setMembers int wid_,int h_wnd_, int x_,int y_, int sxLine_,int syLine_
		wid=wid_ : h_wnd=h_wnd_ : x=x_ : y=y_ : sxLine=sxLine_ : syLine=syLine_
		return
	#modcfunc local getWid
		return wid
	#modcfunc local getScx
		return scx
	#modcfunc local getscy
		return scy
	#modfunc local attachWnd int wid_
		gsel_prev=ginfo_sel : gsel wid_
		wstyle_old=GetWindowLong(hwnd,GWL_STYLE) : SetWindowLong hwnd,GWL_STYLE, (wstyle_old&(WS_POPUP-1))|WS_CHILD	//WS_POPUPを取り除く
		SetParent hwnd,h_wnd : width ,,0,0
		newmod resids, mgui_residSA : idResid=stat : setMembers@mgui_residSA resids(idResid), wid_,hwnd, wstyle_old : numResids++
		gsel gsel_prev
		return
	#modfunc local releaseWnd int wid_
		if (numResids==0) : return 1
		idResid=-1 : foreach resids : if (getWid@mgui_residSA(resids(cnt))==wid_) {idResid=cnt : break} : loop
		if (idResid==-1) : return 1
		hwndResid=getHwnd@mgui_residSA(resids(idResid)) : wstyle_old=getWstyle_old@mgui_residSA(resids(idResid))
		SetParent hwndResid,NULL : SetWindowLong hwndResid,GWL_STYLE, wstyle_old
		delmod resids(idResid) : numResids--
		return 0
	#modfunc local releaseAllResids
		if (numResids==0) : return
		foreach resids
			idResid=cnt
			hwndResid=getHwnd@mgui_residSA(resids(idResid)) : wstyle_old=getWstyle_old@mgui_residSA(resids(idResid))
			SetParent hwndResid,NULL : SetWindowLong hwndResid,GWL_STYLE, wstyle_old
			delmod resids(idResid) : numResids--
		loop
		return
	#modfunc local scroll int dx_,int dy_
		gsel_prev=ginfo_sel : gsel wid
		scx_prev=scx : scx=limit(scx+dx_,0,ginfo_sx-1) : scy_prev=scy : scy=limit(scy+dy_,0,ginfo_sy-1)
		si=28, SIF_ALL, 0,ginfo_sx-1, ginfo_winx,scx, 0 : SetScrollInfo h_wnd, SB_HORZ, si, TRUE
		si=28, SIF_ALL, 0,ginfo_sy-1, ginfo_winy,scy, 0 : SetScrollInfo h_wnd, SB_VERT, si, TRUE
		ScrollWindowEx h_wnd, -dx_,-dy_, NULL,NULL,NULL,NULL, SW_SCROLLCHILDREN : redraw 1
		if (numResids) : foreach resids : widResid=getWid@mgui_residSA(resids(cnt)) : gsel widResid,-1 : gsel widResid,1 : loop	//住人の再描画。UpdateWindowもRedrawWindowもShowWindowも効かないので、邪道だがgsel-1,gsel1で対処する
		gsel gsel_prev
		return
	#modfunc local int_scroll int wp_,int ip_
		code=LOWORD(wp_)
		if (ip_==WM_HSCROLL) {	//水平スクロールバー
			switch code
				case SB_LINEUP : dx=-sxLine : swbreak
				case SB_LINEDOWN : dx=sxLine : swbreak
				case SB_PAGEUP : dx=-ginfo_winx : swbreak
				case SB_PAGEDOWN : dx=ginfo_sx : swbreak
				case SB_THUMBTRACK : dx=HIWORD(wp_) - scx : swbreak
				default : dx=0
			swend
			scroll thismod, dx,0
		} else {	//垂直スクロールバー
			switch code
				case SB_LINEUP : dy=-syLine : swbreak
				case SB_LINEDOWN : dy=syLine : swbreak
				case SB_PAGEUP : dy=-ginfo_winy : swbreak
				case SB_PAGEDOWN : dy=ginfo_sy : swbreak
				case SB_THUMBTRACK : dy=HIWORD(wp_) - scy : swbreak
				default : dy=0
			swend
			scroll thismod, 0,dy
		}
		return
	#modfunc local resize int winx_,int winy_
		gsel_prev=ginfo_sel : gsel wid
		if ((winx_>ginfo_sx)||(winy_>ginfo_sy)||(winx_<1)||(winy_<1)) : return 1
		SetWindowPos hwnd, DONTCARE, DONTCARE,DONTCARE,winx_,winy_, SWP_NOACTIVATE|SWP_NOMOVE|SWP_NOZORDER
		gsel gsel_prev
		return 0
	#modfunc local int_WM_SIZE
		gsel_prev=ginfo_sel : gsel wid
		si=28, SIF_ALL, 0,ginfo_sx-1, ginfo_winx,scx, 0 : SetScrollInfo hwnd, SB_HORZ, si, TRUE	//大きさが変わったことをスクロールバーに教えてやる
		si=28, SIF_ALL, 0,ginfo_sy-1, ginfo_winy,scy, 0 : SetScrollInfo hwnd, SB_VERT, si, TRUE
		gsel gsel_prev
		return
	#modfunc local move int x_,int y_
		gsel_prev=ginfo_sel : gsel wid
		SetWindowPos hwnd, DONTCARE, x_,y_,DONTCARE,DONTCARE, SWP_NOACTIVATE|SWP_NOSIZE|SWP_NOZORDER
		gsel gsel_prev
		return
#global

#module mgui_handle_SA	//スクロールエリア
	#define NULL
	#define FALSE		0
	#define TRUE		1
	#define DONTCARE	0
	
	#define ctype HIWORD(%1)	(%1>>16)
	#define ctype LOWORD(%1)	(%1&0xFFFF)
	
	#define WM_HSCROLL	0x114
	#define WM_VSCROLL	0x115
	#define WM_SIZE	5
	
	#uselib "user32.dll"
		#cfunc GetWindowLong "GetWindowLongA" int,int
			#define GWL_STYLE	-16
		#func SetWindowLong "SetWindowLongA" int,int,int
			#define WS_CHILD	0x40000000
			#define WS_EX_APPWINDOW	0x40000
			#define WS_HSCROLL	0x100000
			#define WS_POPUP	0x80000000
			#define WS_VSCROLL	0x200000
			#define WS_MAXIMIZEBOX	0x10000
		#func SetWindowPos "SetWindowPos" int,int, int,int,int,int, int
			#define SWP_NOACTIVATE 0x10
			#define SWP_NOZORDER 4
		#func SetParent	"SetParent" int,int
		#func SetScrollInfo "SetScrollInfo" int,int,var,int
			#define SB_HORZ	0
			#define SB_VERT	1
	
	#define SIF_ALL	23
	
	#deffunc local init
		SAs=0 : newmod SAs, mgui_SA : delmod SAs(0) : numSAs=0
		return
	
	#deffunc setScrollArea int widSA_, int sxSA_,int sySA_, int winxSA_,int winySA_, int sxLine_,int syLine_	//スクロールエリア設置
		/*
			現在gselされているウィンドウのカレントポジションにスクロールエリアを設置する
			
			widSA_	: エリア用ウィンドウのID
			sxSA_,sySA_	: エリア初期化サイズ
			winxSA_,winySA_	: エリア表示サイズ
			sxLine,syLine	: ラインサイズ(スクロール・バーの両端にある三角形のついたボタンを押したときの移動量[px])

			[stat]
				(-1,other) : (失敗,エリアID)
		*/
		if ((widSA_<0)||(winxSA_>sxSA_)||(winySA_>sxSA_)||(sxLine_<1)||(syLine_<1)) : return -1
		widDst=ginfo_sel : hwndDst=hwnd : xdst=ginfo_cx : ydst=ginfo_cy
		oncmd 0 : bgscr widSA_, sxSA_,sySA_, 2 : hwndSA=hwnd : oncmd 1	//こうしないとhwndの取得に失敗することがある
		style=GetWindowLong(hwnd,GWL_STYLE) : SetWindowLong hwnd, GWL_STYLE, style|WS_CHILD^WS_POPUP|WS_HSCROLL|WS_VSCROLL
		SetParent hwnd,hwndDst : SetWindowPos hwnd, DONTCARE, xdst,ydst, winxSA_,winySA_, SWP_NOACTIVATE|SWP_NOZORDER : gsel widSA_,1
		si=28, SIF_ALL, 0,sxSA_-1, winxSA_,0 : SetScrollInfo hwnd, SB_HORZ, si, TRUE
		si=28, SIF_ALL, 0,sySA_-1, winySA_,0 : SetScrollInfo hwnd, SB_VERT, si, TRUE
		oncmd gosub *int_scroll, WM_HSCROLL : oncmd gosub *int_scroll, WM_VSCROLL
		oncmd gosub *int_WM_SIZE, WM_SIZE
		newmod SAs, mgui_SA : idSA=stat : setMembers@mgui_SA SAs(idSA), widSA_,hwndSA, xdst,ydst, sxLine_,syLine_
		numSAs++
		return idSA
	#defcfunc local existSA int idSA_
		if (numSAs==0) : return FALSE
		if (varuse(SAs(idSA_))==0) : return FALSE
		return TRUE
	#deffunc getScxyScrollArea int idSA_, var scx_,var scy_	//スクロール量の取得
		/*
			idSA_ : エリアID
			scx_,scy_ : スクロール量[px]を格納する変数
	
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		scx_=getScx@mgui_SA(SAs(idSA_)) : scy_=getScy@mgui_SA(SAs(idSA_))
		return 0
	#deffunc scScrollArea int idSA_, int dx_,int dy_
		/*
			idSA_ : エリアID
			dx_,dy_ : 移動量[px]
	
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		scroll@mgui_SA SAs(idSA_), dx_,dy_
		return 0
	#deffunc resizeScrollArea int idSA_, int winxSA_,int winySA_	//エリアのリサイズ
		/*
			idSA_ : エリアID
			winxSA_,winySA_ : 大きさ
			
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		resize@mgui_SA SAs(idSA), winxSA_,winySA_
		return stat
	#deffunc moveScrollArea int idSA_, int x_,int y_	//スクロールエリアの移動
		/*
			idSA_ : エリアID
			x_,y_	: 位置
			
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		move@mgui_SA SAs(idSA_), x_,y_
		return 0
	#deffunc attachWndToScrollArea int idSA_ ,int widResid_	//エリアにウィンドウを入れる
		/*
			(0,0)に置く
			
			idSA_ : エリアID
			widResid_	: 入れるウィンドウのID
	
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		attachWnd@mgui_SA SAs(idSA_), widResid_
		return 0
	#deffunc releaseWndFromScrollArea int idSA_, int widResid_	//エリアからウィンドウを出す
		/*
			idSA_ : エリアID
			widResid_	: 出すウィンドウのID
	
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		releaseWnd@mgui_SA SAs(idSA_), widResid_
		return stat
	#deffunc deleteScrollArea int idSA_	//エリアの削除
		/*
			idSA_ : エリアID
	
			エリア内のウィンドウは全て開放される。
			エリアとして使われていたウィンドウを別の用途で使うにはscreenで最初期化すること。
	
			[stat]
				(0,1)=(成功,失敗)
		*/
		if (existSA(idSA_)==FALSE) : return 1
		releaseAllResids@mgui_SA SAs(idSA_)	//住人の開放
		gsel getWid@mgui_SA(SAs(idSA)),-1 : SetParent hwnd,NULL
		oncmd gosub *dummy, WM_HSCROLL : oncmd gosub *dummy, WM_VSCROLL : oncmd gosub *dummy, WM_SIZE	//oncmd割り込みを無意味化
		delmod SAs(idSA_) : numSAs--
		return 0
*int_scroll
	widSA=ginfo_intid : foreach SAs : if (getWid@mgui_SA(SAs(cnt))==widSA) {idSA=cnt : break} : loop
	int_scroll@mgui_SA SAs(idSA), wparam,iparam
	return
*int_WM_SIZE
	widSA=ginfo_intid : foreach SAs : if (getWid@mgui_SA(SAs(cnt))==widSA) {idSA=cnt : break} : loop	//通知を受けたエリアIDの特定
	int_WM_SIZE@mgui_SA SAs(idSA)
	return
*dummy
	return
#global
init@mgui_handle_SA
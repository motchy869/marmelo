/*
	描画ライブラリ "motchyDraw"
	
	作者 : motchy
	MITライセンス
*/

#ifndef NULL
	#define global NULL	0
#endif
#ifndef DONTCARE_INT
	#define global DONTCARE_INT	0
#endif

/* 2D */
	#module mdraw2D_0
		#uselib "gdi32.dll"
			#func PlgBlt "PlgBlt" int, var, int, int,int, int,int, int, int,int
		
		vramSrc=0 : vramDst=0	//未初期化変数警告回避
		
		#deffunc boldLine_2D int Ax,int Ay,int Bx,int By, int b
			/*
				太さbの太線AB; A=(Ax,Ay),B=(Bx,By) を描く。
				色はカレントカラー。gmodeの半透明設定が適用される。
		
				[書式]
						boldLine_2D Ax,Ay,Bx,By, b
						
				[備考]
						bは奇数を推奨。
			*/
			dx = double(Bx-Ax) : dy = double(By-Ay)
			if ((dx==0)&&(dy==0)) : return
			λ = double(b-1)*0.5/sqrt(dx*dx+dy*dy)
			xrect = Ax-dy*λ, Ax+dy*λ, xrect(1)+dx, xrect+dx
			yrect = Ay+dx*λ, Ay-dx*λ, yrect(1)+dy, yrect+dy
			gsquare -1, xrect,yrect
			return
		
		#deffunc arrowLine_2D int Ax,int Ay, int Bx,int By, double a, double θ
			/*
				太さ1の矢印AB; A=(Ax,Ay),B=(Bx,By) を描く。
				色はカレントカラー。
		
				[書式]
						arrowLine_2D Ax,Ay,Bx,By, a,θ
		
						a : 髪の長さ
						θ : ヘッドの開き角度の半分[rad]
			*/
			dx = double(Bx-Ax) : dy = double(By-Ay)
			λ = a/sqrt(dx*dx+dy*dy)
			cosθ = cos(θ) : sinθ = sin(θ)
			line Bx,By,Ax,Ay
			line Bx-(cosθ*dx-sinθ*dy)*λ, By-(sinθ*dx+cosθ*dy)*λ
			line Bx-(cosθ*dx+sinθ*dy)*λ, By+(sinθ*dx-cosθ*dy)*λ, Bx,By
			return
		
		#deffunc rotBmp90DegStep int widSrc_, int xSrc_,int ySrc_, int sx_,int sy_, int deg_
			/*
				ビットマップを+90度の整数倍回転してコピーする。
				コピー先は現在選択されているウィンドウ。貼り付け先左上座標はカレントポジション。
	
				widSrc_ : コピー元ウィンドウID
				xSrc_,ySrc_	: コピー元左上座標
				sx_sy_ : コピーする縦横サイズ
				deg_	: 回転角度。90,180,270 のいずれか。
	
				[備考]
					コピー元とコピー先が重なる場合の動作は未定。
					コピー元,コピー先でウィンドウの初期化サイズからはみ出る部分はスキップする。
					コピー先でredrawは行わない。
			*/
			assert ((sx_>0)&&(sy_>0))
			/* コピー先情報 */
				xDst=ginfo_cx : yDst=ginfo_cy	//貼り付け先左上座標
				sxWndDst=ginfo_sx : syWndDst=ginfo_sy	//バッファxyサイズ
				mref vramDst,66 : if (sxWndDst\4==0) {srVramDst=3*sxWndDst} else {srVramDst=(3*sxWndDst)/4*4+4}	//VRAMバッファ行メモリサイズ
			/* コピー元情報 */
				wid_sel=ginfo_sel : gsel widSrc_
				sxWndSrc=ginfo_sx : syWndSrc=ginfo_sy
				mref vramSrc,66 : if (sxWndSrc\4==0) {srVramSrc=3*sxWndSrc} else {srVramSrc=(3*sxWndSrc)/4*4+4}
				gsel wid_sel
			switch deg_	//高速化のために角度別に処理する
				case 90
					memo_x2=xDst+sy_-1+ySrc_ : memo_y2=yDst-xSrc_
					repeat sx_*sy_
						x1=xSrc_+cnt\sx_ : y1=ySrc_+cnt/sx_
						if ((x1<0)||(x1>=sxWndSrc)||(y1<0)||(y1>=syWndSrc)) {continue}	//コピー元からはみ出す
						x2=memo_x2-y1 : y2=memo_y2+x1
						if ((x2<0)||(x2>=sxWndDst)||(y2<0)||(y2>=syWndDst)) {continue}	//コピー先からはみ出す
						adrVramSrc=(syWndSrc-y1-1)*srVramSrc+3*x1	//コピー元の着目点のB値のアドレス
						adrVramDst=(syWndDst-y2-1)*srVramDst+3*x2	//コピー先の〃
						wpoke vramDst, adrVramDst, wpeek(vramSrc,adrVramSrc) : poke vramDst,adrVramDst+2,peek(vramSrc,adrVramSrc+2)	//1ドットコピー
					loop
				swbreak
				case 180
					memo_x2=xDst+sx_-1+xSrc_ : memo_y2=yDst+sy_-1+ySrc_
					repeat sx_*sy_
						x1=xSrc_+cnt\sx_ : y1=ySrc_+cnt/sx_ : if ((x1<0)||(x1>=sxWndSrc)||(y1<0)||(y1>=syWndSrc)) {continue}
						x2=memo_x2-x1 : y2=memo_y2-y1 : if ((x2<0)||(x2>=sxWndDst)||(y2<0)||(y2>=syWndDst)) {continue}
						adrVramSrc=(syWndSrc-y1-1)*srVramSrc+3*x1 : adrVramDst=(syWndDst-y2-1)*srVramDst+3*x2
						wpoke vramDst, adrVramDst, wpeek(vramSrc,adrVramSrc) : poke vramDst,adrVramDst+2,peek(vramSrc,adrVramSrc+2)
					loop
				swbreak
				case 270
					memo_x2=xDst-ySrc_ : memo_y2=yDst+sx_-1+xSrc_
					repeat sx_*sy_
						x1=xSrc_+cnt\sx_ : y1=ySrc_+cnt/sx_ : if ((x1<0)||(x1>=sxWndSrc)||(y1<0)||(y1>=syWndSrc)) {continue}
						x2=memo_x2+y1 : y2=memo_y2-x1 : if ((x2<0)||(x2>=sxWndDst)||(y2<0)||(y2>=syWndDst)) {continue}
						adrVramSrc=(syWndSrc-y1-1)*srVramSrc+3*x1 : adrVramDst=(syWndDst-y2-1)*srVramDst+3*x2
						wpoke vramDst, adrVramDst, wpeek(vramSrc,adrVramSrc) : poke vramDst,adrVramDst+2,peek(vramSrc,adrVramSrc+2)
					loop
				swbreak
			swend
			return
	
		#deffunc rotBmp90DegStep_PlgBlt int widSrc_, int xSrc_,int ySrc_, int sx_,int sy_, int deg_
			/*
				PlgBltを利用してビットマップを+90度の整数倍回転してコピーする。
				コピー先は現在選択されているウィンドウ。貼り付け先左上座標はカレントポジション。
	
				widSrc_ : コピー元ウィンドウID
				xSrc_,ySrc_	: コピー元左上座標
				sx_sy_ : コピーする縦横サイズ
				deg_	: 回転角度。90,180,270 のいずれか。
	
				[備考]
					コピー元とコピー先が重なる場合の動作は未定。
					コピー先でredrawは行わない。
			*/
			assert ((sx_>0)&&(sy_>0))
			hdcDst=hdc : wid_sel=ginfo_sel : gsel widSrc_ : hdcSrc=hdc : gsel wid_sel
			switch deg_
				//量子化誤差を補償するために座標指定がcrazy
				case 90 : point=ginfo_cx+sy_,ginfo_cy, ginfo_cx+sy_,ginfo_cy+sx_, ginfo_cx,ginfo_cy : swbreak
				case 180 : point=ginfo_cx+sx_-1,ginfo_cy+sy_-1, ginfo_cx-1,ginfo_cy+sy_-1, ginfo_cx+sx_-1,ginfo_cy-1 : swbreak
				case 270 : point=ginfo_cx,ginfo_cy+sx_, ginfo_cx,ginfo_cy, ginfo_cx+sy_,ginfo_cy+sx_ : swbreak
			swend
			PlgBlt hdcDst, point, hdcSrc, xSrc_,ySrc_, sx_,sy_, NULL, DONTCARE_INT, DONTCARE_INT
			return
	#global
	
	#module mdraw2D_1
		#deffunc boldArrowLine_2D int Ax,int Ay, int Bx,int By, int b, double a, double θ
			/*
				太さbの矢印AB; A=(Ax,Ay),B=(Bx,By) を描く。
				色はカレントカラー。gmodeの半透明設定が適用される。
		
				[書式]
						boldArrowLine_2D Ax,Ay,Bx,By, b,a,θ
		
						a : 髪の長さ
						θ : ヘッドの開き角度の半分[rad]
		
				[備考]
						bは奇数を推奨。
			*/
			cosθ = cos(θ) : sinθ = sin(θ)
			dx = double(Bx-Ax) : dy = double(By-Ay)
			len = sqrt(dx*dx+dy*dy)
			λ = a/len
			h = a*cosθ	//ヘッドの高さ
			if len > h : boldLine_2D Ax,Ay, Ax+dx*(1.0-(h-1.0)/len), Ay+dy*(1.0-(h-1.0)/len), b	//ABが十分長ければシャフトを描く。gsquareが1pxほど欠けるのでhをh-1として補正する。
			xrect = Bx, Bx, Bx-(cosθ*dx+sinθ*dy)*λ, Bx-(cosθ*dx-sinθ*dy)*λ
			yrect = By, By, By+(sinθ*dx-cosθ*dy)*λ, By-(sinθ*dx+cosθ*dy)*λ
			gsquare -1, xrect,yrect
			return
	#global

#undef NULL
#undef DONTCARE_INT
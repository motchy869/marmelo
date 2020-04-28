#module MM_geo2D_0
	/*
		2つの線分 (Ax0,Ay0)-(Ax1,Ay1), (Bx0,By0)-(Bx1,By1) が交差しているかどうか調べる

		[書式]
				rv = isCross_2D(Ax0,Ay0,Ax1,Ay1, Bx0,By0,Bx1,By1)

		[戻り値]
				(0,1)=(no,yes)

		[注意]
				2つの線分はともに長さが正でなければならない
	*/
	#defcfunc isCross_2D double Ax0,double Ay0,double Ax1,double Ay1, double Bx0,double By0,double Bx1,double By1
		#define Ax	Ax1-Ax0
		#define Ay	Ay1-Ay0
		#define Bx	Bx1-Bx0
		#define By	By1-By0
		if isLinIndep_2D(Ax,Ay, Bx,By) {
			rslvVctr_2D Bx1-Ax0,By1-Ay0, Ax,Ay, Bx,By, a,b
			return (0.0<a)&(a<1.0)&(0.0<b)&(b<1.0)
		} else {
			return 0
		}
		#undef Ax
		#undef Ay
		#undef Bx
		#undef By
#global

#module MM_geo2D_1
	/*
		点 P=(Px,Py) が三角形ABC; A=(Ax,Ay),B=(Bx,By),C=(Cx,Cy) の周及び内部に入っているかどうか調べる

		[書式]
				rv = isPntInTriAngl(Px,Py, Ax,Ay, Bx,By, Cx,Cy)

		[戻り値]
				(0,1)=(no,yes)
	*/
	#defcfunc isPntInTriAngl double Px,double Py, double Ax,double Ay,double Bx,double By,double Cx,double Cy
		rslvVctr_2D Px-Ax,Py-Ay, Bx-Ax,By-Ay, Cx-Ax,Cy-Ay, a,b
		return (0.0<=a)&(0.0<=b)&(a+b<=1.0)
#global

#module MM_geo2D_2
	/*
		矩形 R1 と R2 が重なっているかどうか調べる。
		x1,y1 : 矩形1の左上座標
		w1,h1 : 矩形1の幅,高さ
		矩形2についても同様

		[書式]
			rv = is2RectOverlapped(x1,y1, w1,h1, x2,y2, w2,h2)

		[戻り値]
			(0,1)=(no,yes)
	*/
	#defcfunc is2RectOverlapped double x1,double y1, double w1,double h1, double x2,double y2, double w2,double h2
		return (x1-w2 < x2)&&(x2 < x1+w1)&&(y1-h2 < y2)&&(y2 < y1+h1)
#global
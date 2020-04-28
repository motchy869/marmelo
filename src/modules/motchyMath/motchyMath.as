/*
	数学ライブラリ "motchyMath"
	
	作者 : motchy
	MITライセンス
*/
motchyMath_init	//初期化
#module motchyMath
	/*
		モジュールの初期化
	*/
	#deffunc motchyMath_init
		/* 変数初期化 */
			a@MM_geo2D_0 = 0.0 : b@MM_geo2D_0 = 0.0
			a@MM_geo2D_1 = 0.0 : b@MM_geo2D_1 = 0.0
		return
#global

#include "motchymath_sort.as"
#include "motchymath_geo2D.as"
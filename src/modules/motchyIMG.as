/*
	最終更新	2018/10/11
*/

/*
	MIT License
	
	Copyright (c) 2018 motchy
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/
#module motchyIMG
	#define TRUE	1
	#define FALSE	0
	
	#deffunc local init
		sdim sigPng,8 : poke sigPng,0,0x89 : poke sigPng,1,"PNG" : poke sigPng,4,0x0D : poke sigPng,5,0x0A : poke sigPng,6,0x1A : poke sigPng,7,0x0A	//pngシグネチャ
		loadSize = 26	//ファイルを読み込むサイズ
		return
	
	#defcfunc l2b4 int val_	//リトルエンディアン→ビッグエンディアン
		return ((val_>>24)&0xFF)|((val_>>8)&0xFF00)|((val_<<8)&0xFF0000)|((val_<<24)&0xFF000000)
	
	#deffunc mimg_getXYsizeFromFile str fmt_, str path_, var sx_, var sy_	//画像ファイルから縦横サイズを取得する
		/*
			[書式]
				getXYsizeFromFile fmt,path,sx,sy
				fmt : フォーマット。現在対応しているのは("bmp","png")。全て小文字で書くこと。
				path : ファイルのパス
				sx,sy : サイズ格納先(初期化不要)
			[stat]
				(0,1)=(正常,エラー)
		*/
		exist path_ : if (strsize==-1) : return 1
		sdim bin, loadSize : bload path_, bin, loadSize
		rc=0
		switch fmt_
			case "bmp" : gosub *bmp : swbreak
			case "png" : gosub *png : swbreak
			default : rc=1
		swend
		return rc
	*bmp
		if (strmid(bin,0,2)=="BM") {	//シグネチャ確認
			sx_=lpeek(bin,18) : sy_=lpeek(bin,22)
		} else : rc=1
		return
	*png
		if ((strmid(bin,0,8)==sigPng)) {	//シグネチャ確認
			sx_=l2b4(lpeek(bin,16)) : sy_=l2b4(lpeek(bin,20))
		} else : rc=1
		return
#global

init@motchyIMG
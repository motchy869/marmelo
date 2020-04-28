#module MM_sort_0
	/*
		クイックソート
	
		[書式]
	
			quickSort a,s,e,o
	
			a	: 対象配列(int,double)
			s,e	: 対象区間開始,終了位置(int)
			o	: (昇順,降順)=(0,1)
			
	*/
	#deffunc quickSort array a, int s, int e, int o, local l, local r
		if (s<e) {
			if (o) {	//降順
				/* 分割段階 */
					p = a(e)	//ピボット
					l = s : r = e-1
					repeat
						repeat
							if (a(l)>p) : l++ : else : break
						loop
						repeat
							if (l>r) : break	//同じ値を複数持つデータ列に対してはrが負になることがあるので単独でチェックしないとオーバーフローする
							if (a(r)<=p) : r-- : else : break
						loop
						if (l<r) {x=a(l) : a(l)=a(r) : a(r)=x} else : break
					loop
					x=a(l) : a(l)=a(e) : a(e)=x
				/* 再帰呼び出し */
						if (l-1-s < e-l-1) {	//短い区間を優先的に処理してsublevを節約
							quickSort a,s,l-1, 1 : quickSort a,l+1,e, 1
						} else {
							quickSort a,l+1,e, 1 : quickSort a,s,l-1, 1
						}
			} else {	//昇順
					/* 分割段階 */
						p = a(e)
						l = s : r = e-1
						repeat
							repeat
								if (a(l)<p) : l++ : else : break
							loop
							repeat
								if (l>r) : break
								if (a(r)>=p) : r-- : else : break
							loop
							if (l<r) {x=a(l) : a(l)=a(r) : a(r)=x} else : break
						loop
						x=a(l) : a(l)=a(e) : a(e)=x
					/* 再帰呼び出し */
						if (l-1-s < e-l-1) {
							quickSort a,s,l-1, 0 : quickSort a,l+1,e, 0
						} else {
							quickSort a,l+1,e, 0 : quickSort a,s,l-1, 0
						}
			}
		}
		return
	
	/*
		同期クイックソート
	
		[書式]
	
			quickSortSync a,b,s,e,o
	
			a	: マスター配列(int,double)
			b	: スレーブ配列
			s,e	: 対象区間開始,終了位置(int)
			o	: (昇順,降順)=(0,1)
	*/
	#deffunc quickSortSync array a, array b, int s, int e, int o, local l, local r
		if (s<e) {
			if (o) {	//降順
				/* 分割段階 */
					p = a(e)	//ピボット
					l = s : r = e-1
					repeat
						repeat
							if (a(l)>p) : l++ : else : break
						loop
						repeat
							if (l>r) : break	//同じ値を複数持つデータ列に対してはrが負になることがあるので単独でチェックしないとオーバーフローする
							if (a(r)<=p) : r-- : else : break
						loop
						if (l<r) {
							x=a(l) : a(l)=a(r) : a(r)=x
							y=b(l) : b(l)=b(r) : b(r)=y	//※変数の型変換による遅延を避けるために変数をx,yで使い分ける
						} else : break
					loop
					x=a(l) : a(l)=a(e) : a(e)=x
					y=b(l) : b(l)=b(e) : b(e)=y
				/* 再帰呼び出し */
					if (l-1-s < e-l-1) {	//短い区間を優先的に処理してsublevを節約
						quickSortSync a,b,s,l-1, 1 : quickSortSync a,b,l+1,e, 1
					} else {
						quickSortSync a,b,l+1,e, 1 : quickSortSync a,b,s,l-1, 1
					}
			} else {	//昇順
				/* 分割段階 */
					p = a(e)	//ピボット
					l = s : r = e-1
					repeat
						repeat
							if (a(l)<p) : l++ : else : break
						loop
						repeat
							if (l>r) : break
							if (a(r)>=p) : r-- : else : break
						loop
						if (l<r) {
							x=a(l) : a(l)=a(r) : a(r)=x
							y=b(l) : b(l)=b(r) : b(r)=y
						} else : break
					loop
					x=a(l) : a(l)=a(e) : a(e)=x
					y=b(l) : b(l)=b(e) : b(e)=y
				/* 再帰呼び出し */
					if (l-1-s < e-l-1) {
						quickSortSync a,b,s,l-1, 0 : quickSortSync a,b,l+1,e, 0
					} else {
						quickSortSync a,b,l+1,e, 0 : quickSortSync a,b,s,l-1, 0
					}
			}
		}
		return
#global

#module MM_sort_1
	/*
		クイックソート(非再帰高速版)
	
		[書式]
	
			quickSort_nr a,s,e,o
	
			a	: 対象配列(int,double)
			s,e	: 対象区間開始,終了位置(int)
			o	: (昇順,降順)=(0,1)
	*/
	#deffunc quickSort_nr array a, int _s,int _e, int o
		if (_e<=_s) : return
		stack=_s,_e	//スタック。[2*i],[2*i+1] = i個目の領域の左端,右端インデックス
		sc=1	//スタックカウンタ
		if (o) {	//降順
			repeat
				if (sc==0) : break
				s=stack(2*sc-2) : e=stack(2*sc-1) : sc--	//pop
				p = a(e)	//ピボット
				l=s : r=e-1
				repeat
					repeat
						if (a(l)>p) : l++ : else : break
					loop
					repeat
						if (l>r) : break
						if (a(r)<=p) : r-- : else : break
					loop
					if (l<r) {x=a(l) : a(l)=a(r) : a(r)=x} else : break
				loop
				x=a(l) : a(l)=a(e) : a(e)=x
				/* push */
				if (s<l-1) : stack(2*sc)=s,l-1 : sc++
				if (l+1<e) : stack(2*sc)=l+1,e : sc++
			loop
		} else {	//昇順
			repeat
				if (sc==0) : break
				s=stack(2*sc-2) : e=stack(2*sc-1) : sc--	//pop
				p = a(e)	//ピボット
				l=s : r=e-1
				repeat
					repeat
						if (a(l)<p) : l++ : else : break
					loop
					repeat
						if (l>r) : break
						if (a(r)>=p) : r-- : else : break
					loop
					if (l<r) {x=a(l) : a(l)=a(r) : a(r)=x} else : break
				loop
				x=a(l) : a(l)=a(e) : a(e)=x
				/* push */
				if (s<l-1) : stack(2*sc)=s,l-1 : sc++
				if (l+1<e) : stack(2*sc)=l+1,e : sc++
			loop
		}
		return
	
	/*
		同期クイックソート(非再帰高速版)
	
		[書式]
	
			quickSortSync_nr a,b,s,e,o
	
			a	: マスター配列(int,double)
			b	: スレーブ配列
			s,e	: 対象区間開始,終了位置(int)
			o	: (昇順,降順)=(0,1)
	*/
	#deffunc quickSortSync_nr array a,array b, int _s,int _e, int o
		if (_e<=_s) : return
		stack=_s,_e	//スタック。[2*i],[2*i+1] = i個目の領域の左端,右端インデックス
		sc=1	//スタックカウンタ
		if (o) {	//降順
			repeat
				if (sc==0) : break
				s=stack(2*sc-2) : e=stack(2*sc-1) : sc--	//pop
				p = a(e)	//ピボット
				l=s : r=e-1
				repeat
					repeat
						if (a(l)>p) : l++ : else : break
					loop
					repeat
						if (l>r) : break
						if (a(r)<=p) : r-- : else : break
					loop
					if (l<r) {
						x=a(l) : a(l)=a(r) : a(r)=x
						y=b(l) : b(l)=b(r) : b(r)=y
					} else : break
				loop
				x=a(l) : a(l)=a(e) : a(e)=x
				y=b(l) : b(l)=b(e) : b(e)=y
				/* push */
				if (s<l-1) : stack(2*sc)=s,l-1 : sc++
				if (l+1<e) : stack(2*sc)=l+1,e : sc++
			loop
		} else {	//昇順
			repeat
				if (sc==0) : break
				s=stack(2*sc-2) : e=stack(2*sc-1) : sc--	//pop
				p = a(e)	//ピボット
				l=s : r=e-1
				repeat
					repeat
						if (a(l)<p) : l++ : else : break
					loop
					repeat
						if (l>r) : break
						if (a(r)>=p) : r-- : else : break
					loop
					if (l<r) {
						x=a(l) : a(l)=a(r) : a(r)=x
						y=b(l) : b(l)=b(r) : b(r)=y
					} else : break
				loop
				x=a(l) : a(l)=a(e) : a(e)=x
				y=b(l) : b(l)=b(e) : b(e)=y
				/* push */
				if (s<l-1) : stack(2*sc)=s,l-1 : sc++
				if (l+1<e) : stack(2*sc)=l+1,e : sc++
			loop
		}
		return
#global
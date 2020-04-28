#module motchyDB_array
	#defcfunc searchLinearIntArray int val_, array a_, int s_,int e_
		/*
			1次元int配列から値を検索する
	
			val_	: 検索する値
			a_		: 配列
			s_,e_	: 検索開始,終了インデックス
	
			[戻り値]
				(-1,other)=(無かった,最初にヒットしたインデックス)
		*/
		if (e_<s_) {return -1}
		rc=-1 : repeat e_-s_+1,s_ : if (a_(cnt)==val_) {rc=cnt : break} : loop
		return rc
#global
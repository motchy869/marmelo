#module mstr_misc_0
	/*
		serializeStrArray
	
		[機能]
			文字列型配列の直列化
	
		[書式]
			serializeStrArray strArray, text
	
			strArray	: 直列化したい文字列型配列
			text		: 変換結果の格納先変数
	
		[実行後のstatの値]
			正常終了 : 0
			異常終了 : 1
	*/
	#deffunc serializeStrArray array strArray, var text
		if (vartype(strArray)!=vartype("str")) : return 1
		l=length(strArray),length2(strArray),length3(strArray),length4(strArray)	//l(i) : 第i次元の長さ
		nd=0 : repeat 4 : if (l(cnt)!=0){nd++}else{break} : loop	//意味のある次元の数
		if (nd==0) : return 1
		/*
			直列化データのフォーマット
	
			text = "nd,l1,l2,l3,l4,l[0,0,0,0],str[0,0,0,0],l[0,0,0,1],str[0,0,0,1], ... ,l[a-1,b-1,c-1,d-1],str[a-1,b-1,c-1,d-1]"
	
			l1,l2,l3,l4 : 第1,2,3,4次元長さ
			l[x,y,z,w] : 第(x,y,z,w)要素の文字列のバイト長
			str[x,y,z,w] : 第(x,y,z,w)要素
	
			　但し、例えば nd=2 の様にフル次元でない場合(そういう場合が殆ど)は長さ0の次元に関するデータは書き込まない。
			この場合、l3,l4 は書き込まれないし、l[0,0,0,0]やstr[0,0,0,0]も書き込まれない。
		*/
		sdim text,64
		text+=str(nd)+"," : repeat nd : text+=str(l(cnt))+"," : loop
		repeat l
			if (nd==1) {text+=str(strlen(strArray(cnt)))+","+strArray(cnt)+","} else {
				cnt0=cnt
				repeat l(1)
					if (nd==2) {text+=str(strlen(strArray(cnt0,cnt)))+","+strArray(cnt0,cnt)+","} else {
						cnt1=cnt
						repeat l(2)
							if (nd==3) {text+=str(strlen(strArray(cnt0,cnt1,cnt)))+","+strArray(cnt0,cnt1,cnt)+","} else {
								cnt2=cnt : repeat l(3) : text+=str(strlen(strArray(cnt0,cnt1,cnt2,cnt)))+","+strArray(cnt0,cnt1,cnt2,cnt)+"," : loop
							}
						loop
					}
				loop
			}
		loop
		poke text, strlen(text)-1, 0 //末尾の余計な","を消す
		return 0
	
	/*
		deserializeStrArray
	
		[機能]
			直列化データから文字列型配列を復元
	
		[書式]
			deserializeStrArray strArray, text
	
			strArray	: 復元先文字列型配列
			text		: 直列化データ
	
		[実行後のstatの値]
			正常終了 : 0
			異常終了 : 1
	*/
	#deffunc deserializeStrArray array strArray, var text
		sdim buf,64
		getstr buf,text,0,',' : rc=strsize : nd=int(buf)	//rc : readCounter
		if (nd==0) : return 1
		flg_error=0
		repeat nd
			getstr buf,text,rc,',' : rc+=strsize : l(cnt)=int(buf)
			if (l(cnt)==0) : flg_error=1 : break
		loop
		if (flg_error) : return 1
		sdim strArray, 64, l,l(1),l(2),l(3)
		
		repeat l
			if (nd==1) {gosub *getElement : strArray(cnt)=buf} else {
				cnt0=cnt
				repeat l(1)
					if (nd==2) {gosub *getElement : strArray(cnt0,cnt)=buf} else {
						cnt1=cnt
						repeat l(2)
							if (nd==3) {gosub *getElement : strArray(cnt0,cnt1,cnt)=buf} else {
								cnt2=cnt : repeat l(3) : gosub *getElement : strArray(cnt0,cnt1,cnt2,cnt)=buf : loop
							}
						loop
					}
				loop
			}
		loop
		return 0
		*getElement	//1要素読み出してbufに格納
			getstr buf,text,rc,',' : rc+=strsize : ls=int(buf)	//文字列長
			buf = strmid(text,rc,ls) : rc+=ls+1	//getstrは使わない
			return
#global

#module mstr_misc_1
	#defcfunc hex2int str txt_	//16進文字列からintへ変換
		//txt_ : 変換元文字列。プレフィックス(0x)はあってもなくてもよい。文字列が異常な場合は0を返す。
		txt=txt_
		lenTxt=strlen(txt) : if (lenTxt==0) {return 0}
		if (lenTxt>=2) {if (strmid(txt,0,2)=="0x") {memcpy txt,txt, lenTxt-2, 0,2 : lenTxt-=2}}	//プレフィックスがあれば取り除く
		x=0	//変換結果の代入先
		repeat lenTxt
			digit=peek(txt,lenTxt-1-cnt)	//1桁読む
			if ((digit>=48)&&(digit<=57)) {x+=(digit-48)<<(4*cnt) : continue}	//0～9
			if ((digit>=65)&&(digit<=70)) {x+=(digit-55)<<(4*cnt) : continue}	//A～F
			if ((digit>=97)&&(digit<=102)) {x+=(digit-87)<<(4*cnt) : continue}	//a～f
			x=0 : break	//異常
		loop
		return x
#global
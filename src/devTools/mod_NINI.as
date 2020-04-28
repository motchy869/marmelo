/*
	mod_NINI
	
	author : motchy
*/

#ifndef FALSE
	#define global	FALSE	0
#endif
#ifndef TRUE
	#define global	TRUE	1
#endif

#define global MAX_LEN_SECTION_NAME	127
#define global MAX_LEN_KEY_NAME	127

#module mv_nini txt,curDepth,curSectName,count
	id=0
	#modinit str txt_
		txt=txt_
		curDepth=0
		curSectName="body"
		count=0	//カウンタ。常に現在のセクションの"<"の左側にある。
		mref id,2
		return id
	#modcfunc local getText
		return txt
	#modcfunc local getCurLine	//現在カウンタのある行を取得する
		tmp=strmid(txt,0,count) : strrep tmp, "\n","\n"
		return stat
	#modcfunc local existSection str sectionName_
		if (sectionName_=="!") {return 0}
		selSection thismod,sectionName_
		if (stat) {return 0}
		goUp thismod
		return 1
	#modfunc local enumSections array list_
		count_enum=0
		depth2=0	//現在位置基準の相対深さ
		count2=count
		repeat
			buf=peek(txt,count2) : count2++
			if (buf=='<') {	//<>の中身を読みながら対応する">"を探す
				buf=peek(txt,count2) : count2++
				if (buf=='/') {depth2--} else {depth2++}
				sdim buf2,MAX_LEN_SECTION_NAME+1 : poke buf2, 0, buf : len_buf2=1
				repeat
					buf=peek(txt,count2) : count2++
					if (buf=='>') {break}
					poke buf2, len_buf2, buf : len_buf2++
				loop
				if ((depth2==2)&&(peek(buf2,0)!='!')&&(peek(buf2,0)!='/')) {list_(count_enum)=buf2 : count_enum++}
				if (depth2==0) {break}
			}
		loop
		return count_enum
	#modfunc local selSection str sectionName_
		depth2=0
		count2=count
		flg_found=0
		repeat
			buf=peek(txt,count2) : count2++
			if (buf=='<') {	//<>の中身を読みながら対応する">"を探す
				buf=peek(txt,count2) : count2++
				if (buf=='/') {depth2--} else {depth2++}
				sdim buf2,MAX_LEN_SECTION_NAME+1 : poke buf2, 0, buf : len_buf2=1
				repeat
					buf=peek(txt,count2) : count2++
					if (buf=='>') {break}
					poke buf2, len_buf2, buf : len_buf2++
				loop
				if ((depth2==2)&&(buf2==sectionName_)) {flg_found=1 : break}
				if (depth2==0) {break}
			}
		loop
		if (flg_found==0) {return 1}
		count=count2-2-strlen(sectionName_)
		curDepth++
		curSectName=sectionName_
		return 0
	#modcfunc local getCurDepth
		return curDepth
	#modfunc local goUp
		if (curDepth==0) {return 1}
		count2=count-1
		depth2=0	//現在位置基準の相対深さ
		repeat	//左向きに読む
			buf=peek(txt,count2) : count2--
			if (buf=='>') {	//対応する"<"を探す
				repeat
					buf=peek(txt,count2) : count2--
					if (buf=='<') {
						if (peek(txt,count2+2)=='/') {depth2++} else {depth2--}
						break
					}
				loop
				if (depth2==-1) {break}
			}
		loop
		count=count2+1
		curDepth--
		/* セクション名を取得 */
			getstr curSectName, txt, count+1,'>'
		return 0
	#modcfunc local getEndOfCurSection	//選択中のセクションに対応する"</"の位置を返す
		depth2=0
		count2=count
		repeat
			buf=peek(txt,count2) : count2++
			if (buf=='<') {	//対応する">"を探す
				if (peek(txt,count2)=='/') {depth2--} else {depth2++}
				repeat
					buf=peek(txt,count2) : count2++
					if (buf=='>') {break}
				loop
				if (depth2==0) {break}
			}
		loop
		return count2-3-strlen(curSectName)
	#modfunc local newSection str sectionName_
		buf=sectionName_
		if (existSection(thismod,sectionName_)|(peek(buf,0)=='!')) {return 1}
		sep=getEndOfCurSection(thismod)-curDepth
		/* セクション挿入 */
			txt2=strmid(txt,sep,strlen(txt)-sep) : txt=strmid(txt,0,sep)	//後半,前半
			repeat curDepth+1 : txt+="	" : loop	//Tab
			txt+="<"+sectionName_+">"+"\n"
			repeat curDepth+1 : txt+="	" : loop	//Tab
			txt+="</"+sectionName_+">"+"\n"
			txt+=txt2
		return 0
	#modfunc local delCurSection
		if (curDepth==0) : return 1
		c1=count-curDepth : c2=getEndOfCurSection(thismod)+3+strlen(curSectName)+2	//+2:改行コード
		goUp thismod
		txt=strmid(txt,0,c1)+strmid(txt,c2,strlen(txt)-c2)
		return 0
	#modcfunc local getStartOfKey str keyName_	//指定されたキーを探し、あればその位置を,なければ-1を返す。
		depth2=0
		count2=count
		flg_found=0
		repeat
			buf=peek(txt,count2) : count2++
			if (buf=='<') {	//対応する">"を探す
				if (peek(txt,count2)=='/') {depth2--} else {depth2++}
				repeat
					buf=peek(txt,count2) : count2++
					if (buf=='>') {break}
				loop
				if (depth2==0) {break}
			} else {
				if ((depth2==1)&&(buf=='=')) {	//対応するキーをbuf2に読み出す
					count3=count2-2 : sdim buf2,MAX_LEN_KEY_NAME+1 : len_buf2=0
					repeat	//左向きに読む
						buf=peek(txt,count3) : count3--
						if (buf=='	') {	//Tabにぶつかったら(※キーの左には必ずTabがある)
							if (buf2==keyName_) : flg_found=1
							break
						}
						memcpy buf2,buf2, len_buf2, 1,0 : poke buf2, 0, buf : len_buf2++
					loop
					if (flg_found) {break}
				}
			}
		loop
		if (flg_found==0) {return -1}
		return count3+2
	#modcfunc local existKey str keyName_
		return limit(getStartOfKey(thismod,keyName_),0,1)
	#modfunc local emumKeys	array list_
		depth2=0
		count2=count
		count_enum=0
		repeat
			buf=peek(txt,count2) : count2++
			if (buf=='<') {	//対応する">"を探す
				if (peek(txt,count2)=='/') {depth2--} else {depth2++}
				repeat
					buf=peek(txt,count2) : count2++
					if (buf=='>') {break}
				loop
				if (depth2==0) {break}
			} else {
				if ((depth2==1)&&(buf=='=')) {	//対応するキーをbuf2に読み出す
					count3=count2-2 : sdim buf2,MAX_LEN_KEY_NAME+1 : len_buf2=0
					repeat	//左向きに読む
						buf=peek(txt,count3) : count3--
						if (buf=='	') {	//Tabにぶつかったら(※キーの左には必ずTabがある)
							list_(count_enum)=buf2 : count_enum++
							break
						}
						memcpy buf2,buf2, len_buf2, 1,0 : poke buf2, 0, buf : len_buf2++
					loop
				}
			}
		loop
		return count_enum
	#modfunc local newKey str keyName_, str val_
		if (existKey(thismod,keyName_)) {return 1}
		sep=getEndOfCurSection(thismod)-curDepth
		/* キー挿入 */
			txt2=strmid(txt,sep,strlen(txt)-sep) : txt=strmid(txt,0,sep)	//後半,前半
			repeat curDepth+1 : txt+="	" : loop	//Tab
			txt+=keyName_+"="+val_+"\n"
			txt+=txt2
		return 0
	#modfunc local delKey str keyName_
		c1=getStartOfKey(thismod,keyName_) : if (c1==-1) : return 1
		c2=c1+instr(txt,c1,"=")+1
		count2=c2
		repeat	//値の終わりを探す。右側のコメントも消える。
			buf=peek(txt,count2) : count2++
			if (buf==13) {if (peek(txt,count2)==10) {break}}
		loop
		c2=c1-curDepth-1 : c3=count2+1
		txt=strmid(txt,0,c2)+strmid(txt,c3,strlen(txt)-c3)
		return 0
	#modcfunc local getVal str keyName_, str default_
		c1=getStartOfKey(thismod,keyName_) : if (c1==-1) : return default_
		c2=c1+instr(txt,c1,"=")+1	//値の始まり
		count2=c2
		repeat	//値の終わりを探す
			buf=peek(txt,count2) : count2++
			if (buf==13) {if (peek(txt,count2)==10) {break}}
			if (buf=='<') {break}
		loop
		return strmid(txt,c2,count2-1-c2)
	#modfunc local setVal str keyName_, str val_
		c1=getStartOfKey(thismod,keyName_) : if (c1==-1) : return 1
		c1+=instr(txt,c1,"=")+1	//値の始まり
		repeat	//値の終わりを探す
			buf=peek(txt,count2) : count2++
			if (buf==13) {if (peek(txt,count2)==10) {break}}
			if (buf=='<') {break}
		loop : c2=count2-1
		txt=strmid(txt,0,c1)+val_+strmid(txt,c2,strlen(txt)-c2)
		return 0
#global

#module mod_nini_inspect
	#defcfunc nini_isValidNini str nini_, var errLine_	//niniデータの検査
		/*
			(in) nini_ : niniデータ
			(in) errLine_ : エラー発生時にこの変数にその行番号が保存される
		*/
		nini=nini_
		len_nini=strlen(nini) : if (len_nini<strlen("<body>\n</body>")) {return FALSE}
		if (strmid(nini,0,strlen("<body>"))!="<body>") {return FALSE}	//<body>で始まらなくてはならない
		nini+="abcde"	//オーバーリードに備える
		//※コメントも特殊なセクションとして扱う
		count=strlen("<body>")	//現在までに読み進めたバイト数
		depthSect=1	//現在のセクション深度
		offsetFromLineHead=count	//行頭からのバイト数
		cntTabFromLineHead=0	//行頭からのTab数
		sectStack="body" : cntSectStack=1	//セクションスタック
		sdim bufToken,strlen(nini) : len_token=0	//トークンバッファ
		/* 期待されているトークンの種類 */
			#define TTE_SECTNAME	0
			#define TTE_KEY			1
			#define TTE_VAL			2
			#define TTE_COMMENT		4
			tte=TTE_KEY|TTE_VAL
		flg_broken=FALSE
		repeat
			if (count>=len_nini) {break}
			byte=peek(nini,count) : count++
			switch byte
				case '<'
					if (tte==TTE_SECTNAME) {flg_broken=TRUE : break}
					resetToken
					tte=TTE_SECTNAME
				swbreak
				case '>'
					if (tte!=TTE_SECTNAME) {flg_broken=TRUE : break}
					if (len_token==0) {flg_broken=TRUE : break}
					repeat 1
						if (bufToken=="!") {	//コメント開始
							sectStack(cntSectStack)="!" : cntSectStack++
							depthSect++
							tte=TTE_COMMENT
							break
						}
						if (peek(bufToken,0)=='/') {	//セクションの終わり
							bufToken_term=strtrim(bufToken,1,'/')
							if (bufToken_term!=sectStack(cntSectStack-1)) {flg_broken=TRUE : break}
							if (bufToken_term!="!") {	//コメントでないなら
								if (cntTabFromLineHead!=depthSect-1) {flg_broken=TRUE : break}
							}
							cntSectStack--
							depthSect--
							break
						}
						/* セクションの開始 */
							if (cntTabFromLineHead!=depthSect) {flg_broken=TRUE : break}
							sectStack(cntSectStack)=bufToken : cntSectStack++
							depthSect++
					loop
					resetToken
					tte=TTE_KEY
				swbreak
				case '='
					if (tte!=TTE_KEY) {continue}
					if (len_token==0) {flg_broken=TRUE : break}	//キー名が空文字列
					resetToken
					tte=TTE_VAL
				swbreak
				case '	'
					if ((tte==TTE_SECTNAME)||(tte==TTE_VAL)) {flg_broken=TRUE : break}
					offsetFromLineHead++ : cntTabFromLineHead++
				swbreak
				case 10
					if (peek(nini,count-2)==13) {	//改行
						offsetFromLineHead=0 : cntTabFromLineHead=0
						resetToken
						tte=TTE_KEY
					}
				swbreak
				default
					poke bufToken, len_token, byte : len_token++
					poke bufToken, len_token, 0
			swend
		loop
		errLine_=getCurLine()
		if (flg_broken) {return FALSE}
		if (cntSectStack!=0) {return FALSE}
		return TRUE
	#defcfunc local getCurLine //現在カウンタがある行を返す
		tmp=strmid(nini,0,count) : strrep tmp, "\n","\n"
		return stat
	#deffunc local resetToken
		poke bufToken,0,0 : len_token=0
		return
#global

#module mod_nini
	#deffunc local init
		ninis=0 : idSel=0 : errLine=0
		return
	#deffunc nini_mount str nini_, int opt_noInspect	//niniのマウント
		/*
			[書式]
				nini_mount nini, opt_noInspect
				nini : niniテキストデータ
				opt_noInspect : 検査オプション。(FALSE,TRUE)=(検査を行う,行わない)
			[stat]
				(-1,ID)=(データ異常,ID)
		*/
		if (opt_noInspect==FALSE) {
			if (nini_isValidNini(nini_,errLine)==FALSE) {return -1}
		}
		newmod ninis, mv_nini, nini_
		return stat
	#deffunc nini_unmount int id_	//niniのアンマウント
		/*
			[書式]
				nini_unmount id
				id : ID
			[stat]
				(0,1)=(正常,ID不正)
		*/
		if (existNini(id_)==FALSE) {return 1}
		delmod ninis(id_)
		return 0
	#defcfunc local existNini int id_	//niniの存在確認
		if (id_<0) {return FALSE} : if (varuse(ninis(id_))==0) {return FALSE}
		return TRUE
	#deffunc nini_create	//空のniniを作成
		/*
			[書式]
				nini_create
			[stat]
				ID
		*/
		nini_mount "<body>\n</body>"
		return stat
	#deffunc nini_sel int id_	//操作先niniの設定
		/*
			[書式]
				nini_sel id
				id : ID
			[stat]
				(0,1)=(正常,ID不正)
		*/
		if (existNini(id_)==FALSE) {return 1}
		idSel=id_
		return 0
	#defcfunc nini_getCurLine	//現在のカウンタのある行を取得
		return getCurLine@mv_nini(ninis(idSel))
	#defcfunc nini_export	//niniのエクスポート
		/*
			[書式]
				nini = nini_export()
				nini : テキストデータの格納先(初期化不要)
		*/
		return getText@mv_nini(ninis(idSel))
	#defcfunc nini_existSection str sectionName_	//セクションの存在調査
		/*
			[書式]
				val = nini_existSection(name)
				name : セクション名
			[戻り値]
				(0,1)=(なし,あり)
		*/
		return existSection@mv_nini(ninis(idSel),sectionName_)
	#deffunc nini_enumSections array list_	//選択されているセクション内のセクションを列挙
		/*
			[書式]
				nini_enumSections list
				list : リストを格納する文字列型配列(初期化不要)
			[stat]
				見つかったセクションの数
		*/
		enumSections@mv_nini ninis(idSel),list_
		return stat
	#deffunc nini_selSection str sectionName_	//セクションの選択
		/*
			[書式]
				nini_selSection name
				name : セクション名
			[stat]
				(0,1)=(正常,該当なし)
		*/
		selSection@mv_nini ninis(idSel),sectionName_
		return stat
	#defcfunc nini_curDepth	//現在の深さ
		return getCurDepth@mv_nini(ninis(idSel))
	#deffunc nini_goUp	//階層を1つ上がる
		/*
			[書式]
				nini_goUp
			[stat]
				(0,1)=(正常,既に最浅)
		*/
		goUp@mv_nini ninis(idSel)
		return stat
	#deffunc nini_newSection str sectionName_	//新しいセクション
		/*
			[書式]
				nini_newSection name
				name : セクション名
			[stat]
				(0,1)=(正常,既存あるいは"!"で始まるので不可)
		*/
		newSection@mv_nini ninis(idSel),sectionName_
		return stat
	#deffunc nini_delCurSection	//選択中のセクションの削除
		/*
			[書式]
				nini_delCurSection
			[stat]
				(0,1)=(正常,bodyセクションなので消せない)
		*/
		delCurSection@mv_nini ninis(idSel)
		return stat
	#defcfunc nini_existKey str keyName_	//キーの存在調査
		/*
			[書式]
				val = nini_existKey(name)
				name : キー名
			[戻り値]
				(0,1)=(なし,あり)
		*/
		return existKey@mv_nini(ninis(idSel),keyName_)
	#deffunc nini_enumKeys array list_	//選択されているセクション内のキーの列挙
		/*
			[書式]
				nini_enumKeys list
				list : リストを格納する文字列型配列(初期化不要)
			[stat]
				見つかったキーの数
		*/
		emumKeys@mv_nini ninis(idSel),list_
		return stat
	#deffunc nini_newKey str keyName_, str val_	//新しいキー
		/*
			[書式]
				nini_newKey name,val
				name : キー名
				val : 値
			[stat]
				(0,1)=(正常,既存なので不可)
		*/
		newKey@mv_nini ninis(idSel),keyName_,val_
		return stat
	#deffunc nini_delKey str keyName_	//キーの削除
		/*
			[書式]
				nini_delKey name
				name : キー名
			[stat]
				(0,1)=(正常,無かった)
		*/
		delKey@mv_nini ninis(idSel),keyName_
		return stat
	#defcfunc nini_getVal str keyName_, str default_	//値の読み出し
		/*
			[書式]
				val=nini_getVal(name,default)
				name : キー名
				defaule : キーが存在しなかった場合の戻り値
		*/
		return getVal@mv_nini(ninis(idSel),keyName_,default_)
	#deffunc nini_setVal str keyName_, str val_	//値の書き込み
		/*
			[書式]
				nini_setVal name,val
				name : キー名
				val : 値(文字列)
			[stat]
				(0,1)=(正常,キーが無かった)
		*/
		setVal@mv_nini ninis(idSel),keyName_,val_
		return stat
#global

init@mod_nini
#undef FALSE
#undef TRUE
#undef MAX_LEN_SECTION_NAME
#undef MAX_LEN_KEY_NAME
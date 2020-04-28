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

#include "hspinet.as"

#module mod_json
	#enum TYPEVAL_FALSE = 0
	#enum TYPEVAL_TRUE
	#enum TYPEVAL_NULL
	#enum TYPEVAL_INT
	#enum TYPEVAL_STR
	#enum TYPEVAL_ARRAY
	#enum TYPEVAL_DICT

	jsonputs@ : jsonputi@ : jsonout@	//書いておかないと何故かコンパイルエラーになる

	//jsonopen の関数版
	#defcfunc jsonOpen_f var file, local json
		jsonopen@ json, file
		return json

	//jsongetobj の関数版
	#defcfunc jsonGetObj_f str name, int parent, local ret
		jsongetobj@ ret, name, parent
		return ret

	//jsongets の関数版
	//dflt : オブジェクトが存在しない場合の戻り値
	#defcfunc jsonGets_f str name, int parent, str dflt, local ret
		if (name == "") {
			assert (jsonNext_f(parent, 3) == TYPEVAL_STR)
		} else {
			assert (jsonNext_f(jsonGetObj_f(name, parent), 3) == TYPEVAL_STR)
		}
		ret = dflt : jsongets@ ret, name, parent
		return ret

	//jsongeti の関数版
	//dflt : オブジェクトが存在しない場合の戻り値
	#defcfunc jsonGeti_f str name, int parent, int dflt, local ret
		if (name == "") {
			assert (jsonNext_f(parent, 3) <= TYPEVAL_INT)
		} else {
			assert (jsonNext_f(jsonGetObj_f(name, parent), 3) <= TYPEVAL_INT)
		}
		ret = dflt : jsongeti@ ret, name, parent
		return ret

	//jsonnext の関数版
	#defcfunc jsonNext_f int parent, int opt, local ret
		jsonnext@ ret, parent, opt
		return ret

	//int型の配列を全部読み出す
	//戻り値 : 要素数
	#defcfunc jsonGetIntArray array A, int ptr_array, local ptr, local len
		assert (jsonNext_f(ptr_array, 3) == TYPEVAL_ARRAY)
		len = 0
		ptr = jsonNext_f(ptr_array, 2)
		while ptr != 0
			A(len) = jsonGeti_f("", ptr, 0) : len++
			ptr = jsonNext_f(ptr, 0)
		wend
		return len

	//str型の配列を全部読み出す
	//戻り値 : 要素数
	#defcfunc jsonGetStrArray array A, int ptr_array, local ptr, local len
		assert (jsonNext_f(ptr_array, 3) == TYPEVAL_ARRAY)
		len = 0
		ptr = jsonNext_f(ptr_array, 2)
		while ptr != 0
			A(len) = jsonGets_f("", ptr, "") : len++
			ptr = jsonNext_f(ptr, 0)
		wend
		return len

	//jsonnewobj の関数版
	#defcfunc jsonNewObj_f int parent, str name, local ret
		jsonnewobj@ ret, parent, name	//ここで得られる ret には意味がない。バグか？
		jsongetobj@ ret, name, parent
		return ret

	//配列を作ってそのJSONポインタを返す
	#defcfunc jsonNewArray int parent, str name, local ret
		ret = jsonNewObj_f(parent, name)
		jsonsetprm@ ret, TYPEVAL_ARRAY, 3
		return ret
#global
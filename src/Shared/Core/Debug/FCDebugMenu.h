/*
 Copyright (C) 2011-2012 by Martin Linklater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if !defined(ADHOC)
#define FC_DEBUGMENU
#endif

#ifndef _FCDebugMenu_h
#define _FCDebugMenu_h

#if defined(FC_DEBUGMENU)

#include <map>
#include "Shared/Core/FCCore.h"

class FCDebugMenu
{
public:
	static FCDebugMenu* Instance();
	
	FCDebugMenu();
	virtual ~FCDebugMenu();
	
	void Init();
	void Show();
	void Hide();
	
	void AddButton( std::string name, std::string lua, FCVoidIntFuncPtr pCFunc, uint32_t cFuncContext, const FCColor4f& color );
	
	void AddMulti( std::string name, std::string lua, const FCStringVector& options, const FCColor4f& color );

	void ButtonPressed( FCHandle h );
	
private:
	
	struct ButtonDetails {
		std::string			lua;
		FCVoidIntFuncPtr	cFuncPtr;
		uint32_t			cFuncContext;
	};
	
	typedef std::map<FCHandle, ButtonDetails>	ButtonMap;
	typedef ButtonMap::const_iterator			ButtonMapConstIter;
	typedef ButtonMap::iterator					ButtonMapIter;
	
	ButtonMap	m_buttons;
};

#endif // ADHOC

#endif

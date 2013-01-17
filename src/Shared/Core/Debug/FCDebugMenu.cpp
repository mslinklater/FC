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

#include "FCDebugMenu.h"

#if defined( FC_DEBUGMENU )

#include "Shared/FCPlatformInterface.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/Framework/FCApplication.h"

bool gLandscape;

static FCDebugMenu* s_pInstance = 0;

static int lua_AddButton( lua_State* _state )
{
	return 0;
}

static int lua_AddMulti( lua_State* _state )
{
	return 0;
}

void fc_FCDebugMenu_ButtonPressed( FCHandle handle )
{
	FCDebugMenu::Instance()->ButtonPressed( handle );
}

static void TestAssert( int context )
{
	FC_ASSERT(0);
}

FCDebugMenu* FCDebugMenu::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCDebugMenu;
	}
	return s_pInstance;
}

FCDebugMenu::FCDebugMenu()
{
	
}

FCDebugMenu::~FCDebugMenu()
{
	
}

void FCDebugMenu::Init()
{
	// add Lua bindings
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCDebugMenu");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddButton, "FCDebugMenu.AddButton");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddMulti, "FCDebugMenu.AddMulti");

	FCColor4f color = kFCColorGreen();
	AddButton("Warm Boot", "", FCApplication::RequestWarmBoot, 0, color);
	AddButton("Test Assert", "", TestAssert, 0, color);
}

void FCDebugMenu::Show()
{
	plt_FCDebugMenu_Show();
}

void FCDebugMenu::Hide()
{
	plt_FCDebugMenu_Hide();
}

void FCDebugMenu::ButtonPressed(FCHandle h)
{
	FC_ASSERT(m_buttons.find(h) != m_buttons.end());
	
	ButtonDetails details = m_buttons[h];
	
	// call Lua
	
	if( details.lua.size() )
	{
		FCLua::Instance()->CoreVM()->ExecuteLine( details.lua );
	}
	
	// call C
	
	if (details.cFuncPtr) {
		(details.cFuncPtr)(details.cFuncContext);
	}
	
	Hide();	
}

void FCDebugMenu::AddButton(std::string name, std::string lua, FCVoidIntFuncPtr pCFunc, uint32_t cFuncContext, const FCColor4f& color)
{
	FCHandle h = FCHandleNew();
	
	ButtonDetails	details;
	
	details.lua = lua;
	details.cFuncPtr = pCFunc;
	details.cFuncContext = cFuncContext;
	
	m_buttons[h] = details;
	
	plt_FCDebugMenu_AddButton( h, name.c_str(), color );
}

void FCDebugMenu::AddMulti(std::string name, std::string luaFunc, const FCStringVector& options, const FCColor4f& color)
{
	
}

#endif // FC_DEBUGMENU
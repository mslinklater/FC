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

#include "FCBuild.h"
#include "Shared/Lua/FCLua.h"

static FCBuild* s_pInstance = 0;

static int lua_Debug( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
#if DEBUG
	lua_pushboolean(_state, 1);
#else
	lua_pushboolean(_state, 0);
#endif
	
	return 1;
}

FCBuild::FCBuild()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCBuild");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Debug, "FCBuild.Debug");
}

FCBuild::~FCBuild()
{
	
}

FCBuild* FCBuild::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCBuild;
	}
	return s_pInstance;
}

bool FCBuild::Debug()
{
#if DEBUG
	return true;
#else
	return false;
#endif
}



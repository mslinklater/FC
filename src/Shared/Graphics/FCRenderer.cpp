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

#include "FCGraphics.h"

#include"FCRenderer.h"
#include "Shared/Lua/FCLua.h"


static std::map<std::string, IFCRenderer*>	s_renderers;
static IFCRenderer* s_luaRenderer = 0;

static int lua_SetCurrentRenderer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string name = lua_tostring(_state, 1);
	
	FC_ASSERT( s_renderers.find(name) != s_renderers.end() );
	s_luaRenderer = s_renderers[ name ];
	return 0;
}

IFCRenderer::IFCRenderer( std::string name )
{
	if( s_renderers.size() == 0 )
	{
		FCLua::Instance()->CoreVM()->CreateGlobalTable("FCRenderer");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCurrentRenderer, "FCRenderer.SetCurrentRenderer");
	}
	s_renderers[ name ] = this;
}

IFCRenderer::~IFCRenderer()
{
	FC_HALT; // what to do here ?
}


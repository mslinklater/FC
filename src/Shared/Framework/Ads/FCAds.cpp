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

#if defined( FC_ADS )

#include "FCAds.h"
#include <string>
#include "Shared/FCPlatformInterface.h"
#include "Shared/Lua/FCLua.h"

static FCAds* s_pInstance = 0;

static int lua_Visible( lua_State* _state )
{
	if (s_pInstance->Visible()) {
		lua_pushboolean( _state, 1);
	} else {
		lua_pushboolean( _state, 0);
	}
	return 1;
}

static int lua_ShowBanner( lua_State* _state )
{
	std::string key = lua_tostring(_state, 1);
	s_pInstance->ShowBanner(key);
	return 0;
}

static int lua_HideBanner( lua_State* _state )
{
	s_pInstance->HideBanner();
	return 0;
}

FCAds::FCAds()
: m_visible( false )
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCAds");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Visible, "FCAds.Visible");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ShowBanner, "FCAds.ShowBanner");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_HideBanner, "FCAds.HideBanner");
}

FCAds::~FCAds()
{
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCAds.Visible");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCAds.ShowBanner");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCAds.HideBanner");
	FCLua::Instance()->CoreVM()->DestroyGlobalTable("FCAds");
}

FCAds* FCAds::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCAds;
	}
	return s_pInstance;
}

void FCAds::ShowBanner( std::string key )
{
	plt_FCAds_ShowBanner( key.c_str() );
	m_visible = true;
}

void FCAds::HideBanner()
{
	plt_FCAds_HideBanner();
	m_visible = false;
}

#endif // FC_ADS

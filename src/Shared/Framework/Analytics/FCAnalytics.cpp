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

#include "FCAnalytics.h"
#include "Shared/Lua/FCLua.h"

extern void		plt_FCAnalytics_RegisterEvent( std::string event );
extern void		plt_FCAnalytics_BeginTimedEvent( std::string event );
extern void		plt_FCAnalytics_EndTimedEvent( std::string event );

static FCAnalytics* s_pInstance = 0;

static int lua_RegisterEvent( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	FCAnalytics::Instance()->RegisterEvent( lua_tostring(_state, 1) );
	
	return 0;
}

static int lua_BeginTimedEvent( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	FCHandle handle = FCAnalytics::Instance()->BeginTimedEvent( lua_tostring(_state, 1) );
	
	lua_pushinteger(_state, handle);
	
	return 1;
}

static int lua_EndTimedEvent( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCAnalytics::Instance()->EndTimedEvent( (FCHandle)lua_tointeger(_state, 1) );
	
	return 0;
}

FCAnalytics::FCAnalytics()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCAnalytics");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_RegisterEvent, "FCAnalytics.RegisterEvent");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_BeginTimedEvent, "FCAnalytics.BeginTimedEvent");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_EndTimedEvent, "FCAnalytics.EndTimedEvent");
}

FCAnalytics::~FCAnalytics()
{
	
}

FCAnalytics* FCAnalytics::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCAnalytics;
	}
	return s_pInstance;
}

void FCAnalytics::RegisterEvent(std::string event)
{
	plt_FCAnalytics_RegisterEvent( event );
}

FCHandle FCAnalytics::BeginTimedEvent(std::string event)
{
	plt_FCAnalytics_BeginTimedEvent( event );
	FCHandle h = NewFCHandle();
	m_timedEvents[h] = event;
	return h;
}

void FCAnalytics::EndTimedEvent(FCHandle hEvent)
{
	std::string event = m_timedEvents[hEvent];	
	plt_FCAnalytics_EndTimedEvent( event );
	m_timedEvents.erase( hEvent );
}



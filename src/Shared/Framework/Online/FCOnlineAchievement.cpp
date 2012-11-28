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

#include "FCOnlineAchievement.h"
#include "FCPlatformInterface.h"
#include "Shared/Lua/FCLua.h"

static FCOnlineAchievement* s_pInstance = 0;

void fc_FCOnlineAchievement_ServerProgress( const char* name, float progress )
{
	FC_ASSERT(0);	// Disabled for now...
	
	FC_ASSERT(name);
	FC_ASSERT( progress >= 0.0f );
	FC_ASSERT( progress <= 1.0f );
	
	s_pInstance->ServerProgress(name, progress);
}

static int lua_Register( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineAchievement.Register()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string name = lua_tostring(_state, 1);
	
	s_pInstance->Register( name );
	
	return 0;
}

static int lua_RefreshFromServer( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineAchievement.RefreshFromServer()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	s_pInstance->RefreshFromServer();
	return 0;
}

static int lua_SetProgress( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineAchievement.SetProgress()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER );
	
	std::string name = lua_tostring(_state, 1);
	float progress = lua_tonumber(_state, 2);
	
	s_pInstance->SetProgress(name, progress);
	
	return 0;
}

static int lua_ClearAll( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineAchievement.ClearAll()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->ClearAll();
	
	return 0;
}

static int lua_ReportUnreported( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineAchievement.ReportUnreported()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->ReportUnreported();
	return 0;
}

FCOnlineAchievement* FCOnlineAchievement::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCOnlineAchievement;
	}
	return s_pInstance;
}

FCOnlineAchievement::FCOnlineAchievement()
{
	// register Lua functions
	
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCOnlineAchievement");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Register, "FCOnlineAchievement.Register");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_RefreshFromServer, "FCOnlineAchievement.RefreshFromServer");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetProgress, "FCOnlineAchievement.SetProgress");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ReportUnreported, "FCOnlineAchievement.ReportUnreported");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ClearAll, "FCOnlineAchievement.ClearAll");
	
	plt_FCOnlineAchievement_Init();
}

FCOnlineAchievement::~FCOnlineAchievement()
{
	
}

void FCOnlineAchievement::Register(std::string name)
{
	FC_ASSERT( m_achievements.find(name) == m_achievements.end() );
	
	FCLog( std::string("FCOnlineAchievement register: " + name));
	   
	m_achievements[name] = 0.0f;
}

void FCOnlineAchievement::RefreshFromServer()
{
//	plt_FCOnlineAchievement_RefreshFromServer( );
}

void FCOnlineAchievement::SetProgress(std::string name, float progress)
{
	FC_ASSERT( m_achievements.find(name) != m_achievements.end() );
	FC_ASSERT( progress >= 0.0f );
	FC_ASSERT( progress <= 1.0f );
	
	if (m_achievements[name] <= progress) {
		m_achievements[name] = progress;
		
		// send to server
		plt_FCOnlineAchievement_UpdateProgress(name.c_str(), progress);
	}
}

void FCOnlineAchievement::ServerProgress(std::string name, float progress)
{
	FC_ASSERT( m_achievements.find(name) != m_achievements.end() );
	FC_ASSERT( progress >= 0.0f );
	FC_ASSERT( progress <= 1.0f );
	
	if (m_achievements[name] <= progress) {
		m_achievements[name] = progress;
	}
}

void FCOnlineAchievement::ReportUnreported()
{
	plt_FCOnlineAchievement_ReportUnreported();
}

void FCOnlineAchievement::ClearAll()
{
	FCLog("FCOnlineAchievement: ClearAll()");
	plt_FCOnlineAchievement_ClearAll();
}


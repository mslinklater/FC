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

#include "FCLuaThread.h"
#include "FCLuaCommon.h"
#include "Shared/Core/FCError.h"

FCLuaThread::FCLuaThread( lua_State* _state, FCHandle handle )
{
	m_luaState = lua_newthread(_state);
	
	char buffer[32];
	sprintf(&buffer[0], "thread%d", handle);		
	lua_setfield(_state, LUA_REGISTRYINDEX, &buffer[0]);
	m_threadState = kLuaThreadStateNew;
	m_sleepRealTimeRemaining = 0.0f;
	m_sleepGameTimeRemaining = 0.0f;
	m_handle = handle;
	m_numResumedArgs = lua_gettop(_state);
	lua_xmove(_state, m_luaState, m_numResumedArgs);
}

FCLuaThread::~FCLuaThread()
{
//	FC_HALT;
	
}

void FCLuaThread::Resume()
{
	m_threadState = kLuaThreadStateRunning;
	int ret = lua_resume(m_luaState , NULL, m_numResumedArgs - 1);
	m_numResumedArgs = 0;
	switch (ret) {
		case 0:
			m_threadState = kLuaThreadStateDying;
			break;
		case LUA_YIELD:
			break;
		case LUA_ERRRUN:
			FCLua_DumpStack(m_luaState);
			FC_FATAL("LUA_ERRRUN");
			break;
		case LUA_ERRSYNTAX:
			FCLua_DumpStack(m_luaState);
			FC_FATAL("LUA_ERRSYNTAX");
			break;
		case LUA_ERRMEM:
			FCLua_DumpStack(m_luaState);
			FC_FATAL("LUA_ERRMEM");
			break;
		case LUA_ERRERR:
			FCLua_DumpStack(m_luaState);
			FC_FATAL("LUA_ERRERR");
			break;
		default:
			break;
	}
}

void FCLuaThread::Update( float realDelta, float gameDelta )
{
	switch (m_threadState) 
	{
		case kLuaThreadStateNew:
			break;
		case kLuaThreadStateRunning:
		{
			int ret = lua_resume(m_luaState , NULL, 0);
			switch (ret) {
				case 0:
					m_threadState = kLuaThreadStateDying;
					break;
				case LUA_YIELD:
					break;
				case LUA_ERRRUN:
					FCLua_DumpStack(m_luaState);
					FC_FATAL("LUA_ERRRUN");
					break;
				case LUA_ERRSYNTAX:
					FCLua_DumpStack(m_luaState);
					FC_FATAL("LUA_ERRSYNTAX");
					break;
				case LUA_ERRMEM:
					FCLua_DumpStack(m_luaState);
					FC_FATAL("LUA_ERRMEM");
					break;
				case LUA_ERRERR:
					FCLua_DumpStack(m_luaState);
					FC_FATAL("LUA_ERRERR");
					break;
				default:
					FC_FATAL("default fallthrough");
					break;
			}
		}
		break;
		case kLuaThreadStateSleeping:
		{
			if (m_sleepRealTimeRemaining > 0.0f) {
				m_sleepRealTimeRemaining -= realDelta;
			}
			
			if (m_sleepGameTimeRemaining > 0.0f) {
				m_sleepGameTimeRemaining -= gameDelta;
			}
			
			if( (m_sleepRealTimeRemaining <= 0.0) && (m_sleepGameTimeRemaining <= 0.0)){
				m_threadState = kLuaThreadStateRunning;
				Update(realDelta, gameDelta);
			}
		}
			break;
		case kLuaThreadStateDying:
			m_threadState = kLuaThreadStateDead;
			lua_pushnil(m_luaState);
			char buffer[32];
			sprintf(&buffer[0], "thread%d", m_handle);		
			lua_setfield(m_luaState, LUA_REGISTRYINDEX, &buffer[0]);			
			break;
		case kLuaThreadStateDead:
			break;			
	}
	
}

void FCLuaThread::PauseRealTime( float seconds )
{
	m_sleepRealTimeRemaining += (float)seconds;
	m_threadState = kLuaThreadStateSleeping;	
}

void FCLuaThread::PauseGameTime( float seconds )
{
	m_sleepGameTimeRemaining += (float)seconds;
	m_threadState = kLuaThreadStateSleeping;
}

void FCLuaThread::Die()
{
	m_threadState = kLuaThreadStateDying;
}

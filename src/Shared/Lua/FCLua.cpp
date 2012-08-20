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

#include "FCLua.h"

static FCHandle common_newThread( lua_State* _state, std::string name )
{
	static int s_recurseCount = 0;
	
	s_recurseCount++;
	
	if (s_recurseCount > 100) {
		FC_FATAL("Recursive Lua thread creation - try inserting FCWait(0)");
	}
	
	FCLua* fcLua = FCLua::Instance();
	
	if (fcLua->m_threadsMap.size() > 1024) 
	{
		FC_FATAL("Too many Lua threads");
	}
	
	FCHandle handle = NewFCHandle();
	
	FCLuaThread* thread = new FCLuaThread( _state, handle );
	
	fcLua->m_threadsMap[handle] = FCLuaThreadRef( thread );
	
	thread->Resume();
	thread->SetName( name );
	
	s_recurseCount--;
	
	return thread->Handle();
}

#pragma mark - Lua Functions

static int lua_NewThread( lua_State* _state )
{
	FC_LUA_ASSERT_TYPE(1, LUA_TFUNCTION);
	
	std::string name = "";
	
	// check for name parameter - it is optional
	
	if (lua_gettop(_state) == 2)
	{
		name = lua_tostring(_state, 2);
	}
	
	if (lua_isfunction(_state, 1))
	{
		FCHandle threadId = common_newThread( _state, name );
		
		lua_settop( _state, 0 );
		
		lua_pushinteger( _state, threadId );
		return 1;
	}
	FC_FATAL("Creating thread from not a function");
	return 0;
}

static int lua_WaitThread( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	// find thread with this state
	FCLua* instance = FCLua::Instance();

	for (FCLuaThreadRefMapConstIter i = instance->m_threadsMap.begin(); i != instance->m_threadsMap.end(); ++i) {
		FCLuaThreadRef pThread = i->second;
		
		if (!pThread) {
			FC_FATAL(std::string("Trying to kill nonexistent thread " + i->first));
		}
		
		if (_state == pThread->LuaState()) {
			float time = (float)lua_tonumber(_state, 1);
			pThread->PauseRealTime(time);
			int yieldVal = lua_yield(_state, 0);
			return yieldVal;
		}
	}
	
	FC_FATAL("Cannot find thread");
	return 0;
}

static int lua_WaitGameThread( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	// find thread with this state
	FCLua* instance = FCLua::Instance();
	
	for (FCLuaThreadRefMapConstIter i = instance->m_threadsMap.begin(); i != instance->m_threadsMap.end(); ++i) {
		FCLuaThreadRef pThread = i->second;
		if (_state == pThread->LuaState()) {
			float time = (float)lua_tonumber(_state, 1);
			pThread->PauseGameTime(time);
			int yieldVal = lua_yield(_state, 0);
			return yieldVal;
		}
		
	}

	FC_FATAL("Cannot find thread");
	return 0;
}

static int lua_KillThread( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	if (!lua_isnumber(_state, -1)) {
		FC_FATAL("Trying to pass a non-number to thread kill");
	}
	FCHandle killid = (int)lua_tointeger(_state, -1);
	
	FCLua* instance = FCLua::Instance();
	
	FCLuaThreadRef thread = instance->m_threadsMap[ killid ];
	
	if (thread) {
		thread->Die();
	} else
	{
		FC_WARNING("Trying to kill non-existent Lua thread");
	}
	return 0;
}

static int lua_Log( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	char buffer[16];
	
	sprintf(buffer, "0x%08x", (unsigned int)_state);
	
	FC_LOG(std::string("Lua(") + std::string(buffer) + "): " + lua_tostring(_state, 1));
	return 0;
}

static int lua_Warning( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	char buffer[16];
	
	sprintf(buffer, "0x%08x", (unsigned int)_state);
	
	FC_WARNING(std::string("Lua(") + std::string(buffer) + "): " + lua_tostring(_state, 1));
	return 0;
}

static int lua_Fatal( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_FATAL(std::string("Lua: ") + lua_tostring(_state, 1));
	return 0;
}

FCLua* FCLua::s_pInstance = 0;

FCLua::FCLua()
{
	m_coreVM = new FCLuaVM;
	m_coreVM->AddStandardLibraries();
	
#if defined (FC_DEBUG)
	lua_pushboolean(m_coreVM->State(), 1);
#else
	lua_pushboolean(m_coreVM->State(), 0);
#endif
	lua_setglobal(m_coreVM->State(), "DEBUG");
	
	m_coreVM->LoadScript("fc_core");
	
	m_coreVM->RegisterCFunction(lua_NewThread, "FCNewThread");
	m_coreVM->RegisterCFunction(lua_WaitThread, "FCWait");
	m_coreVM->RegisterCFunction(lua_WaitGameThread, "FCWaitGame");
	m_coreVM->RegisterCFunction(lua_KillThread, "FCKillThread");
	m_coreVM->RegisterCFunction(lua_Log, "FCLog");
	m_coreVM->RegisterCFunction(lua_Warning, "FCWarning");
	m_coreVM->RegisterCFunction(lua_Fatal, "FCFatal");

	m_perfCounter = FCPerformanceCounterRef( new FCPerformanceCounter );
	m_maxCPUTime = 0.0f;
	m_avgCPUTime = 0.0f;
	m_avgCount = 0;
}

FCLua::~FCLua()
{
	
}

FCLua* FCLua::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCLua;
	}
	return s_pInstance;
}

void FCLua::UpdateThreads( float realDelta, float gameDelta )
{
	// check for stack crawl
	
	m_perfCounter->Zero();
	
	// update threads
	
	std::vector<FCLuaThreadRefMapIter> delList;
	
	for (FCLuaThreadRefMapIter i = m_threadsMap.begin(); i != m_threadsMap.end(); ++i) 
	{
		i->second->Update(realDelta, gameDelta);
		
		if (i->second->ThreadState() == kLuaThreadStateDead) {
			delList.push_back(i);
		}
	}

	for (auto i = delList.begin(); i != delList.end(); i++) {
		m_threadsMap.erase(*i);
	}
	
	float millisecs = (float)m_perfCounter->MilliValue();
	
	if (millisecs > m_maxCPUTime) {
		m_maxCPUTime = millisecs;
	}
	m_avgCPUTime += millisecs;
	m_avgCount++;
}

void FCLua::ExecuteLine( std::string line )
{
	m_coreVM->ExecuteLine(line);
}

void FCLua::PrintStats()
{
	FC_LOG("--- FCLua Stats ---");
	std::stringstream ss;
	ss << "Num threads: ";
	ss << m_threadsMap.size();
	FC_LOG(ss.str());
	
	ss.str("");
	ss << "Memory Allocs: ";
	ss << FCLuaMemory::Instance()->NumAllocs();
	FC_LOG(ss.str());
	
	ss.str("");
	ss << "Memory Bytes: ";
	ss << FCLuaMemory::Instance()->TotalMemory();
	FC_LOG(ss.str());
	
	ss.str("");
	ss << "Max CPU: ";
	ss << m_maxCPUTime;
	FC_LOG(ss.str());
	
	ss.str("");
	ss << "Avg CPU: ";
	ss << m_avgCPUTime;
	FC_LOG(ss.str());	
}


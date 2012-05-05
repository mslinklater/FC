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

#ifndef CR1_FCLuaThread_h
#define CR1_FCLuaThread_h

#include <map>

#include "FCLuaVM.h"
#include "Shared/Core/FCTypes.h"
#include "Shared/Core/FCSharedPtr.h"

enum eLuaThreadState {
	kLuaThreadStateNew,
	kLuaThreadStateRunning,
	kLuaThreadStateSleeping,
	kLuaThreadStateDying,
	kLuaThreadStateDead
};

class FCLuaThread {
public:
	FCLuaThread( lua_State* state, FCHandle handle );
	~FCLuaThread();
	
	void Resume();
	void Update( float realDelta, float gameDelta );
	void PauseRealTime( float seconds );
	void PauseGameTime( float seconds );
	void Die();
	FCHandle Handle(){ return m_handle; }
	lua_State* LuaState(){ return m_luaState; }
	eLuaThreadState ThreadState(){ return m_threadState; }
	
private:
	eLuaThreadState	m_threadState;
	double			m_sleepRealTimeRemaining;
	double			m_sleepGameTimeRemaining;
	FCHandle		m_handle;
	lua_State*		m_luaState;
	int32_t			m_numResumedArgs;
};

typedef FCSharedPtr<FCLuaThread> FCLuaThreadPtr;

typedef std::map<FCHandle, FCLuaThreadPtr> FCLuaThreadMap;
typedef FCLuaThreadMap::iterator FCLuaThreadMapIter;
typedef FCLuaThreadMap::const_iterator FCLuaThreadMapConstIter;

#endif

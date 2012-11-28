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

#ifndef _FCLua_h
#define _FCLua_h

#include <map>

#include "Shared/Core/Debug/FCPerformanceCounter.h"

#include "Shared/Core/FCCore.h"
#include "FCLuaVM.h"
#include "FCLuaThread.h"
#include "FCLuaCommon.h"
#include "FCLuaMemory.h"
#include "FCLuaAsserts.h"
#include "FCLuaUtils.h"

// Some helpers which shold probably be moved out

void lua_pushvector3f( lua_State* _state, FCVector3f& vec );
FCVector2f lua_tovector2f( lua_State* _state );
FCVector3f lua_tovector3f( lua_State* _state );
FCColor4f lua_tocolor4f( lua_State* _state );

class FCLua {
public:
	FCLua();
	~FCLua();
	
	static FCLua* Instance();
	void UpdateThreads( float realDelta, float gameDelta );
	FCLuaVM* CoreVM(){ return m_coreVM; }
	void ExecuteLine( std::string line );
	void PrintStats();

	FCLuaThreadRefMap	m_threadsMap;
	
private:
	static FCLua*	s_pInstance;
	FCLuaVM*		m_coreVM;

	FCPerformanceCounterRef	m_perfCounter;
	float					m_maxCPUTime;
	float					m_avgCPUTime;
	uint32_t				m_avgCount;
};

#endif


